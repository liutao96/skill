# 内置数据库（PostgreSQL）

## 概述

妙搭内置基于 PostgreSQL 的托管数据库，每个应用拥有独立数据库实例，无需自行搭建和维护。

官方参考文档：https://www.postgresql.org/docs/current/sql-commands.html

## 操作方式

### 1. 可视化建表（无需写 SQL）

在「数据库」面板中：新建表 → 添加字段 → 选择字段类型 → 设置约束

### 2. SQL 编辑器

直接在编辑器内编写和执行 PostgreSQL SQL 语句，完整支持 DDL + DML。

### 3. 代码中调用

通过妙搭提供的数据库 API 在前端逻辑中操作数据（数据绑定到组件）。

## 支持的字段类型

| 类别 | 类型 |
|------|------|
| 文本 | TEXT、VARCHAR、CHAR |
| 数值 | INTEGER、BIGINT、FLOAT、DECIMAL、NUMERIC |
| 布尔 | BOOLEAN |
| 时间 | DATE、TIME、TIMESTAMP、TIMESTAMPTZ |
| JSON | JSON、JSONB |
| 其他 | UUID、ARRAY 等 PostgreSQL 原生类型 |

## SQL 命令速查

### 数据查询
```sql
SELECT * FROM table_name WHERE condition ORDER BY col LIMIT n;
-- 支持 JOIN、子查询、聚合函数、窗口函数
EXPLAIN SELECT ...;  -- 查看执行计划
```

### 数据操作
```sql
INSERT INTO table_name (col1, col2) VALUES (val1, val2);
-- Upsert（冲突时更新）
INSERT INTO table_name (id, col) VALUES (1, 'val')
  ON CONFLICT (id) DO UPDATE SET col = EXCLUDED.col;

UPDATE table_name SET col = val WHERE condition;
DELETE FROM table_name WHERE condition;
TRUNCATE table_name;
MERGE INTO target USING source ON condition
  WHEN MATCHED THEN UPDATE SET ...
  WHEN NOT MATCHED THEN INSERT ...;
```

### 表定义（DDL）
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  email TEXT UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE users ADD COLUMN avatar_url TEXT;
DROP TABLE users;
CREATE INDEX idx_users_email ON users(email);
CREATE VIEW active_users AS SELECT * FROM users WHERE active = true;
CREATE MATERIALIZED VIEW mv_stats AS SELECT ...;
REFRESH MATERIALIZED VIEW mv_stats;
```

### 事务控制
```sql
BEGIN;
  UPDATE accounts SET balance = balance - 100 WHERE id = 1;
  UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;
-- 或 ROLLBACK; 回滚
SAVEPOINT sp1;
ROLLBACK TO SAVEPOINT sp1;
```

### 高级特性
```sql
-- 存储过程
CREATE FUNCTION get_user(uid UUID) RETURNS TABLE(name TEXT, email TEXT) AS $$
  SELECT name, email FROM users WHERE id = uid;
$$ LANGUAGE SQL;

-- 触发器
CREATE TRIGGER update_timestamp
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- 序列
CREATE SEQUENCE order_seq START 1000 INCREMENT 1;
SELECT nextval('order_seq');
```

## 完整支持的命令分类

| 类别 | 主要命令 |
|------|----------|
| 数据查询 | SELECT, EXPLAIN, FETCH, DECLARE |
| 数据操作 | INSERT, UPDATE, DELETE, MERGE, TRUNCATE, COPY |
| 事务控制 | BEGIN, COMMIT, ROLLBACK, SAVEPOINT |
| 表定义 | CREATE/ALTER/DROP TABLE |
| 索引 | CREATE/DROP INDEX, REINDEX, CLUSTER |
| 视图 | CREATE/ALTER/DROP VIEW, CREATE MATERIALIZED VIEW, REFRESH MATERIALIZED VIEW |
| 函数/过程 | CREATE/ALTER/DROP FUNCTION, CREATE PROCEDURE, CALL |
| 触发器 | CREATE/ALTER/DROP TRIGGER |
| 序列 | CREATE/ALTER/DROP SEQUENCE |
| 权限 | GRANT, REVOKE |
| Schema | CREATE/ALTER/DROP SCHEMA |
| 类型 | CREATE/ALTER/DROP TYPE, CREATE DOMAIN |
| 维护 | ANALYZE, VACUUM, CHECKPOINT |
| 准备语句 | PREPARE, EXECUTE, DEALLOCATE |
| 会话 | SET, SHOW, RESET, DISCARD |

## 注意事项

- 每个应用数据库独立，应用间数据默认隔离
- 建议在 SQL 编辑器测试复杂查询后再集成到应用
- 数据变更实时反映在应用中
