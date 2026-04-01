# PolarDB-FC API 调用示例

## 基础信息

- **Base URL**: `https://your-function-url.fcapp.run`
- **响应格式**: JSON
- **字符编码**: UTF-8

## 统一响应格式

```json
{
  "success": true,
  "timestamp": "2024-01-15T08:30:00.000Z",
  "data": { ... },
  "count": 100
}
```

## 接口列表

### 1. 健康检查

```http
GET /health
```

**响应示例：**
```json
{
  "success": true,
  "timestamp": "2024-01-15T08:30:00.000Z",
  "status": "healthy",
  "database": "connected",
  "host": "xxx.rwlb.rds.aliyuncs.com",
  "port": 3306,
  "serverTime": "2024-01-15T08:30:00.000Z"
}
```

---

### 2. 获取所有表

```http
GET /tables
```

**响应示例：**
```json
{
  "success": true,
  "timestamp": "2024-01-15T08:30:00.000Z",
  "data": [
    {
      "tableName": "users",
      "tableComment": "用户表",
      "tableRows": 1000,
      "createTime": "2024-01-01T00:00:00.000Z"
    }
  ],
  "count": 1
}
```

---

### 3. 获取表结构

```http
GET /schema/:table
```

**示例：**
```http
GET /schema/users
```

**响应示例：**
```json
{
  "success": true,
  "timestamp": "2024-01-15T08:30:00.000Z",
  "tableName": "users",
  "columns": [
    {
      "columnName": "id",
      "dataType": "int",
      "isNullable": "NO",
      "columnKey": "PRI",
      "extra": "auto_increment"
    },
    {
      "columnName": "name",
      "dataType": "varchar",
      "isNullable": "YES",
      "columnComment": "用户姓名"
    }
  ],
  "indexes": [...]
}
```

---

### 4. 执行 SQL 查询

```http
POST /query
Content-Type: application/json

{
  "sql": "SELECT * FROM users WHERE age > ?",
  "params": [18],
  "options": {
    "limit": 100
  }
}
```

**响应示例：**
```json
{
  "success": true,
  "timestamp": "2024-01-15T08:30:00.000Z",
  "data": [...],
  "count": 50,
  "executionTime": "23ms",
  "sql": "SELECT * FROM users WHERE age > ? LIMIT 100"
}
```

---

### 5. 分页查询

```http
POST /query/paginated
Content-Type: application/json

{
  "sql": "SELECT * FROM users WHERE status = ?",
  "params": ["active"],
  "page": 1,
  "pageSize": 20
}
```

**响应示例：**
```json
{
  "success": true,
  "timestamp": "2024-01-15T08:30:00.000Z",
  "data": [...],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 100,
    "totalPages": 5,
    "hasNext": true,
    "hasPrev": false
  },
  "executionTime": "45ms"
}
```

## 错误处理

| 状态码 | 错误类型 | 说明 |
|--------|----------|------|
| 400 | 参数错误 | 缺少必要参数或格式不正确 |
| 403 | 权限错误 | SQL包含禁止的操作 |
| 404 | 接口不存在 | 请求的路径不存在 |
| 500 | 服务器错误 | 数据库连接或查询执行错误 |

**错误响应示例：**
```json
{
  "success": false,
  "timestamp": "2024-01-15T08:30:00.000Z",
  "error": "缺少 SQL 语句"
}
```
