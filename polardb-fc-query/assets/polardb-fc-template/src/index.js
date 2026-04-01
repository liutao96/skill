const mysqlPromise = require('mysql2/promise');
const rawMysql = require('mysql2');
const net = require('net');
const url = require('url');

// 连接池（复用连接）
let connectionPool = null;

/**
 * 获取数据库配置
 */
function getDbConfig() {
  return {
    host: process.env.POLARDB_HOST,
    port: parseInt(process.env.POLARDB_PORT || '3306'),
    database: process.env.POLARDB_DATABASE,
    user: process.env.POLARDB_USERNAME,
    password: process.env.POLARDB_PASSWORD,
    connectTimeout: 10000,
    acquireTimeout: 10000,
  };
}

/**
 * 获取连接池
 */
async function getConnection() {
  if (!connectionPool) {
    connectionPool = mysqlPromise.createPool({
      ...getDbConfig(),
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
      enableKeepAlive: true,
      keepAliveInitialDelay: 10000,
    });
  }
  return connectionPool;
}

/**
 * 关闭连接池（用于优雅关闭）
 */
async function closePool() {
  if (connectionPool) {
    await connectionPool.end();
    connectionPool = null;
  }
}

/**
 * TCP 连通性测试
 */
function testTcpConnection(host, port, timeoutMs = 5000) {
  return new Promise((resolve, reject) => {
    const socket = new net.Socket();
    let settled = false;

    socket.setTimeout(timeoutMs);

    socket.on('connect', () => {
      if (settled) return;
      settled = true;
      socket.destroy();
      resolve(true);
    });

    socket.on('timeout', () => {
      if (settled) return;
      settled = true;
      socket.destroy();
      reject(new Error(`TCP连接超时(${timeoutMs}ms) - 无法连接 ${host}:${port}`));
    });

    socket.on('error', (err) => {
      if (settled) return;
      settled = true;
      socket.destroy();
      reject(new Error(`TCP连接失败: ${err.message}`));
    });

    socket.connect(port, host);
  });
}

/**
 * 统一响应格式
 */
function createResponse(statusCode, data, success = true) {
  return {
    statusCode,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
    body: JSON.stringify({
      success,
      timestamp: new Date().toISOString(),
      ...data,
    }),
  };
}

/**
 * 解析请求体（兼容 FC3 格式）
 */
function parseBody(event) {
  try {
    let body = event.body;

    // FC3 可能使用 base64 编码
    if (event.isBase64Encoded && body) {
      body = Buffer.from(body, 'base64').toString('utf-8');
    }

    if (body) {
      return typeof body === 'string' ? JSON.parse(body) : body;
    }
    return {};
  } catch (e) {
    throw new Error('请求体解析失败: ' + e.message);
  }
}

/**
 * 解析查询参数
 */
function parseQueryParams(event) {
  const queryString = event.queryString || event.queryStringParameters || {};
  return queryString;
}

// ============================================================
// REST API 路由处理
// ============================================================

/**
 * GET /health - 健康检查
 */
async function handleHealth() {
  const host = process.env.POLARDB_HOST;
  const port = parseInt(process.env.POLARDB_PORT || '3306');

  try {
    await testTcpConnection(host, port, 5000);

    const pool = await getConnection();
    const [rows] = await pool.execute('SELECT 1 as test, NOW() as serverTime');

    return createResponse(200, {
      status: 'healthy',
      database: 'connected',
      host: host,
      port: port,
      serverTime: rows[0].serverTime,
    });
  } catch (error) {
    return createResponse(503, {
      status: 'unhealthy',
      error: error.message,
    }, false);
  }
}

/**
 * GET /tables - 列出所有表
 */
async function handleTables() {
  try {
    const pool = await getConnection();
    const [rows] = await pool.execute(`
      SELECT
        TABLE_NAME as tableName,
        TABLE_COMMENT as tableComment,
        TABLE_ROWS as tableRows,
        CREATE_TIME as createTime,
        UPDATE_TIME as updateTime
      FROM INFORMATION_SCHEMA.TABLES
      WHERE TABLE_SCHEMA = DATABASE()
      ORDER BY TABLE_NAME
    `);

    return createResponse(200, {
      data: rows,
      count: rows.length,
    });
  } catch (error) {
    return createResponse(500, { error: error.message }, false);
  }
}

/**
 * GET /schema/:table - 获取表结构
 */
async function handleSchema(event) {
  try {
    const tableName = event.pathParameters?.table;
    if (!tableName) {
      return createResponse(400, { error: '缺少表名参数' }, false);
    }

    // 验证表名安全（只允许字母数字下划线）
    if (!/^[a-zA-Z0-9_]+$/.test(tableName)) {
      return createResponse(400, { error: '无效的表名' }, false);
    }

    const pool = await getConnection();
    const [columns] = await pool.execute(`
      SELECT
        COLUMN_NAME as columnName,
        DATA_TYPE as dataType,
        IS_NULLABLE as isNullable,
        COLUMN_DEFAULT as columnDefault,
        COLUMN_COMMENT as columnComment,
        COLUMN_KEY as columnKey,
        EXTRA as extra
      FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?
      ORDER BY ORDINAL_POSITION
    `, [tableName]);

    const [indexes] = await pool.execute(`
      SELECT
        INDEX_NAME as indexName,
        COLUMN_NAME as columnName,
        NON_UNIQUE as nonUnique
      FROM INFORMATION_SCHEMA.STATISTICS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?
      ORDER BY INDEX_NAME, SEQ_IN_INDEX
    `, [tableName]);

    return createResponse(200, {
      tableName,
      columns,
      indexes,
    });
  } catch (error) {
    return createResponse(500, { error: error.message }, false);
  }
}

/**
 * POST /query - 执行SQL查询
 */
async function handleQuery(event) {
  const startTime = Date.now();

  try {
    const body = parseBody(event);
    const { sql, params = [], options = {} } = body;

    // 参数验证
    if (!sql || typeof sql !== 'string') {
      return createResponse(400, { error: '缺少 SQL 语句' }, false);
    }

    // SQL 安全检查
    const trimmedSql = sql.trim();
    const upperSql = trimmedSql.toUpperCase();

    // 必须是以 SELECT 开头
    if (!upperSql.startsWith('SELECT')) {
      return createResponse(403, {
        error: '只允许 SELECT 查询',
        hint: '如需执行其他操作，请联系管理员'
      }, false);
    }

    // 禁止危险关键字
    const forbiddenKeywords = [
      'INSERT', 'UPDATE', 'DELETE', 'DROP', 'TRUNCATE',
      'ALTER', 'CREATE', 'RENAME', 'REPLACE', 'MERGE',
      'GRANT', 'REVOKE', 'LOCK', 'UNLOCK'
    ];

    const foundForbidden = forbiddenKeywords.filter(kw =>
      upperSql.includes(kw)
    );

    if (foundForbidden.length > 0) {
      return createResponse(403, {
        error: 'SQL 包含禁止的操作',
        forbidden: foundForbidden,
      }, false);
    }

    // 限制最大返回条数
    const maxLimit = 1000;
    const limit = Math.min(parseInt(options.limit) || maxLimit, maxLimit);

    // 执行查询
    const pool = await getConnection();
    let querySql = trimmedSql;

    // 如果 SQL 中没有 LIMIT，自动添加
    if (!upperSql.includes('LIMIT') && limit < maxLimit) {
      querySql = `${trimmedSql} LIMIT ${limit}`;
    }

    const [rows] = await pool.execute(querySql, params);

    const executionTime = Date.now() - startTime;

    return createResponse(200, {
      data: rows,
      count: rows.length,
      executionTime: `${executionTime}ms`,
      sql: querySql,
    });

  } catch (error) {
    const executionTime = Date.now() - startTime;
    return createResponse(500, {
      error: error.message,
      executionTime: `${executionTime}ms`,
    }, false);
  }
}

/**
 * POST /query/paginated - 分页查询
 */
async function handlePaginatedQuery(event) {
  const startTime = Date.now();

  try {
    const body = parseBody(event);
    const {
      sql,
      params = [],
      page = 1,
      pageSize = 20
    } = body;

    if (!sql || typeof sql !== 'string') {
      return createResponse(400, { error: '缺少 SQL 语句' }, false);
    }

    // SQL 安全检查（同上）
    const upperSql = sql.trim().toUpperCase();
    if (!upperSql.startsWith('SELECT')) {
      return createResponse(403, { error: '只允许 SELECT 查询' }, false);
    }

    const forbiddenKeywords = [
      'INSERT', 'UPDATE', 'DELETE', 'DROP', 'TRUNCATE',
      'ALTER', 'CREATE', 'RENAME'
    ];

    if (forbiddenKeywords.some(kw => upperSql.includes(kw))) {
      return createResponse(403, { error: 'SQL 包含禁止的操作' }, false);
    }

    const pool = await getConnection();
    const trimmedSql = sql.trim();

    // 计算分页
    const currentPage = Math.max(1, parseInt(page) || 1);
    const size = Math.min(Math.max(1, parseInt(pageSize) || 20), 100);
    const offset = (currentPage - 1) * size;

    // 移除原 SQL 中的 LIMIT（如果有）
    const sqlWithoutLimit = trimmedSql.replace(/\s+LIMIT\s+\d+(\s*,\s*\d+)?/i, '');

    // 查询总数
    const countSql = `SELECT COUNT(*) as total FROM (${sqlWithoutLimit}) as t`;
    const [countResult] = await pool.execute(countSql, params);
    const total = countResult[0].total;

    // 查询分页数据
    const paginatedSql = `${sqlWithoutLimit} LIMIT ${size} OFFSET ${offset}`;
    const [rows] = await pool.execute(paginatedSql, params);

    const executionTime = Date.now() - startTime;

    return createResponse(200, {
      data: rows,
      pagination: {
        page: currentPage,
        pageSize: size,
        total,
        totalPages: Math.ceil(total / size),
        hasNext: currentPage * size < total,
        hasPrev: currentPage > 1,
      },
      executionTime: `${executionTime}ms`,
    });

  } catch (error) {
    return createResponse(500, { error: error.message }, false);
  }
}

/**
 * GET / - API 信息
 */
function handleRoot() {
  return createResponse(200, {
    name: 'PolarDB Query API',
    version: '1.0.0',
    description: '通过函数计算查询 PolarDB 的 REST API',
    endpoints: [
      { method: 'GET', path: '/health', description: '健康检查' },
      { method: 'GET', path: '/tables', description: '列出所有表' },
      { method: 'GET', path: '/schema/:table', description: '获取表结构' },
      { method: 'POST', path: '/query', description: '执行 SQL 查询' },
      { method: 'POST', path: '/query/paginated', description: '分页查询' },
    ],
  });
}

// ============================================================
// 主处理函数
// ============================================================

exports.handler = async function(event, context) {
  // 解析事件
  if (Buffer.isBuffer(event)) {
    try {
      event = JSON.parse(event.toString('utf-8'));
    } catch (e) {
      return createResponse(400, { error: 'Event 解析失败' }, false);
    }
  } else if (typeof event === 'string') {
    try {
      event = JSON.parse(event);
    } catch (e) {
      // 保持原样
    }
  }

  // FC3 HTTP 触发器事件格式：
  // - rawPath: 路径
  // - requestContext.http.method: HTTP 方法
  // - body: 请求体（可能是 base64 编码）
  const httpMethod = (event.requestContext?.http?.method || event.requestMethod || event.httpMethod || event.method || 'GET').toUpperCase();
  const path = event.rawPath || event.requestPath || event.path || '/';

  // 处理预检请求
  if (httpMethod === 'OPTIONS') {
    return {
      statusCode: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
      body: '',
    };
  }

  try {
    // 路由匹配
    if (path === '/' || path === '') {
      return handleRoot();
    }

    if (path === '/health' && httpMethod === 'GET') {
      return await handleHealth();
    }

    if (path === '/tables' && httpMethod === 'GET') {
      return await handleTables();
    }

    if (path.startsWith('/schema/') && httpMethod === 'GET') {
      const tableName = path.replace('/schema/', '');
      return await handleSchema({
        ...event,
        pathParameters: { table: tableName }
      });
    }

    if (path === '/query' && httpMethod === 'POST') {
      return await handleQuery(event);
    }

    if (path === '/query/paginated' && httpMethod === 'POST') {
      return await handlePaginatedQuery(event);
    }

    // 404
    return createResponse(404, {
      error: '接口不存在',
      path,
      method: httpMethod,
    }, false);

  } catch (error) {
    console.error('处理请求失败:', error);
    return createResponse(500, {
      error: '服务器内部错误',
      message: error.message,
    }, false);
  }
};
