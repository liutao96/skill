# PostgreSQL 常见错误代码

快速参考高频错误代码及解决方案。完整列表请查询官方文档。

## 错误代码格式

PostgreSQL 错误代码格式：`XXXXX`（5位字符）
- 前两位：错误类别
- 后三位：具体错误

**示例**: `42P01` = Class 42（语法错误或访问规则违规）+ P01（未定义的表）

## 高频错误代码

### 类别 42 - 语法错误/访问规则

| 代码 | 含义 | 常见原因 | 快速修复 |
|------|------|----------|----------|
| **42P01** | undefined_table | 表不存在 | 检查表名拼写、schema、是否已创建 |
| **42703** | undefined_column | 列不存在 | 检查列名拼写、SELECT 中是否有该列 |
| **42601** | syntax_error | SQL 语法错误 | 检查关键字拼写、括号匹配、逗号 |
| **42P02** | undefined_parameter | 参数未定义 | 检查 `$1`, `$2` 等参数绑定 |
| **42883** | undefined_function | 函数不存在 | 检查函数名、参数类型、是否需要类型转换 |
| **42804** | datatype_mismatch | 数据类型不匹配 | 使用 CAST 或 :: 转换类型 |
| **42P18** | indeterminate_datatype | 无法确定数据类型 | 显式指定类型，如 `NULL::int` |
| **42501** | insufficient_privilege | 权限不足 | GRANT 授权或使用有权限的用户 |

### 类别 23 - 完整性约束违规

| 代码 | 含义 | 常见原因 | 快速修复 |
|------|------|----------|----------|
| **23505** | unique_violation | 唯一约束冲突 | 检查是否重复插入、使用 UPSERT |
| **23503** | foreign_key_violation | 外键约束冲突 | 确保引用的记录存在 |
| **23502** | not_null_violation | 非空约束冲突 | 提供必需字段值或修改表结构 |
| **23514** | check_violation | CHECK 约束冲突 | 确保数据满足约束条件 |

### 类别 22 - 数据异常

| 代码 | 含义 | 常见原因 | 快速修复 |
|------|------|----------|----------|
| **22P02** | invalid_text_representation | 文本格式无效 | 检查输入格式（日期、数字等） |
| **22003** | numeric_value_out_of_range | 数值超出范围 | 使用更大的数据类型（如 int → bigint） |
| **22007** | invalid_datetime_format | 日期时间格式错误 | 使用 `TO_DATE()` 或正确的格式 |
| **22012** | division_by_zero | 除零错误 | 添加 NULLIF 或条件判断 |
| **22001** | string_data_right_truncation | 字符串过长 | 增加字段长度或截断数据 |

### 类别 08 - 连接异常

| 代码 | 含义 | 常见原因 | 快速修复 |
|------|------|----------|----------|
| **08006** | connection_failure | 连接失败 | 检查网络、服务器状态、防火墙 |
| **08003** | connection_does_not_exist | 连接不存在 | 重新建立连接 |
| **08001** | sqlclient_unable_to_establish_sqlconnection | 无法建立连接 | 检查连接字符串、认证信息 |

### 类别 40 - 事务回滚

| 代码 | 含义 | 常见原因 | 快速修复 |
|------|------|----------|----------|
| **40001** | serialization_failure | 序列化失败 | 重试事务、调整隔离级别 |
| **40P01** | deadlock_detected | 检测到死锁 | 重试事务、优化事务顺序 |

### 类别 53 - 资源不足

| 代码 | 含义 | 常见原因 | 快速修复 |
|------|------|----------|----------|
| **53300** | too_many_connections | 连接数过多 | 增加 `max_connections`、使用连接池 |
| **53400** | configuration_limit_exceeded | 配置限制超出 | 调整相关参数（如 work_mem） |

## 典型场景示例

### 场景 1：42P01 - 表不存在

```
ERROR:  relation "users" does not exist
LINE 1: SELECT * FROM users;
                      ^
```

**可能原因**：
1. 表名拼写错误
2. 表在不同的 schema 中
3. 表还未创建

**解决方案**：
```sql
-- 查看当前 schema 的所有表
\dt

-- 查看所有 schema 的表
SELECT schemaname, tablename
FROM pg_tables
WHERE tablename LIKE '%user%';

-- 指定 schema
SELECT * FROM public.users;
```

### 场景 2：42883 - 函数不存在

```
ERROR:  function lower(integer) does not exist
HINT:  No function matches the given name and argument types.
```

**原因**：参数类型不匹配

**解决方案**：
```sql
-- 错误
SELECT lower(user_id) FROM users;

-- 正确：先转换类型
SELECT lower(user_id::text) FROM users;
```

### 场景 3：23505 - 唯一约束冲突

```
ERROR:  duplicate key value violates unique constraint "users_email_key"
DETAIL:  Key (email)=(test@example.com) already exists.
```

**解决方案**：
```sql
-- 方案 1：先检查是否存在
SELECT * FROM users WHERE email = 'test@example.com';

-- 方案 2：使用 UPSERT
INSERT INTO users (email, name)
VALUES ('test@example.com', 'John')
ON CONFLICT (email)
DO UPDATE SET name = EXCLUDED.name;

-- 方案 3：忽略冲突
INSERT INTO users (email, name)
VALUES ('test@example.com', 'John')
ON CONFLICT (email) DO NOTHING;
```

### 场景 4：22P02 - 无效的文本格式

```
ERROR:  invalid input syntax for type integer: "abc"
```

**解决方案**：
```sql
-- 使用安全转换函数
SELECT
  CASE
    WHEN value ~ '^[0-9]+$' THEN value::integer
    ELSE NULL
  END
FROM data_table;

-- 或使用 CAST 并处理异常
SELECT
  NULLIF(regexp_replace(value, '[^0-9]', '', 'g'), '')::integer
FROM data_table;
```

## 查询完整错误代码

使用 WebFetch 查询官方完整列表：

```
WebFetch(
  url: "https://www.postgresql.org/docs/current/errcodes-appendix.html",
  prompt: "查找错误代码 [XXXXX] 的含义、原因和解决建议"
)
```

## 系统目录查询

```sql
-- 查看错误代码定义
SELECT * FROM pg_catalog.pg_stat_statements;

-- 查看当前会话的错误
SHOW log_error_verbosity;
```
