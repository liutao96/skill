# PostgreSQL 文档章节索引

快速查找常用章节的 URL，用于 WebFetch 查询。

**基础 URL**: `https://www.postgresql.org/docs/current/`

## 核心章节

### SQL 语言

| 章节 | URL | 用途 |
|------|-----|------|
| SQL 语法 | `sql-syntax.html` | 语法规则、表达式 |
| 数据定义 | `ddl.html` | CREATE TABLE, ALTER, DROP |
| 数据操作 | `dml.html` | INSERT, UPDATE, DELETE |
| 查询 | `queries.html` | SELECT, JOIN, 子查询 |
| 数据类型 | `datatype.html` | 所有数据类型总览 |
| 函数和操作符 | `functions.html` | 所有函数分类 |
| 索引 | `indexes.html` | 索引类型、创建、使用 |
| 性能优化 | `performance-tips.html` | 查询优化建议 |

### 具体数据类型

| 类型 | URL | 说明 |
|------|-----|------|
| 数值类型 | `datatype-numeric.html` | int, decimal, float, serial |
| 字符类型 | `datatype-character.html` | char, varchar, text |
| 日期时间 | `datatype-datetime.html` | date, time, timestamp, interval |
| JSON 类型 | `datatype-json.html` | json, jsonb 对比 |
| 数组 | `arrays.html` | 数组操作 |
| 枚举 | `datatype-enum.html` | 自定义枚举 |
| UUID | `datatype-uuid.html` | UUID 使用 |
| 布尔 | `datatype-boolean.html` | boolean 类型 |

### 函数分类

| 函数类别 | URL | 内容 |
|----------|-----|------|
| 字符串函数 | `functions-string.html` | concat, substring, format |
| 数学函数 | `functions-math.html` | round, abs, random |
| 日期时间函数 | `functions-datetime.html` | now, extract, date_trunc |
| JSON 函数 | `functions-json.html` | json_build, jsonb_set |
| 聚合函数 | `functions-aggregate.html` | sum, avg, count, array_agg |
| 窗口函数 | `functions-window.html` | row_number, rank, lag, lead |
| 条件表达式 | `functions-conditional.html` | CASE, COALESCE, NULLIF |
| 数组函数 | `functions-array.html` | array_append, unnest |
| 模式匹配 | `functions-matching.html` | LIKE, 正则表达式 |
| 类型转换 | `typeconv.html` | CAST, :: 操作符 |

### 高级特性

| 特性 | URL | 说明 |
|------|-----|------|
| 窗口函数详解 | `tutorial-window.html` | 窗口函数教程 |
| CTE（WITH） | `queries-with.html` | 公共表表达式 |
| 全文搜索 | `textsearch.html` | 文本搜索功能 |
| 并发控制 | `mvcc.html` | 事务隔离级别 |
| 分区表 | `ddl-partitioning.html` | 表分区策略 |
| 继承 | `ddl-inherit.html` | 表继承 |

### 性能和优化

| 主题 | URL | 内容 |
|------|-----|------|
| 性能建议 | `performance-tips.html` | 通用优化策略 |
| 索引类型 | `indexes-types.html` | B-tree, Hash, GiST, GIN |
| EXPLAIN | `sql-explain.html` | 查询计划分析 |
| ANALYZE | `sql-analyze.html` | 更新统计信息 |
| VACUUM | `routine-vacuuming.html` | 清理和优化 |

### SQL 命令参考

| 命令 | URL | 说明 |
|------|-----|------|
| SELECT | `sql-select.html` | 查询语法完整参考 |
| INSERT | `sql-insert.html` | 插入数据 |
| UPDATE | `sql-update.html` | 更新数据 |
| DELETE | `sql-delete.html` | 删除数据 |
| CREATE TABLE | `sql-createtable.html` | 建表语法 |
| CREATE INDEX | `sql-createindex.html` | 建索引语法 |
| ALTER TABLE | `sql-altertable.html` | 修改表结构 |

### 附录

| 附录 | URL | 内容 |
|------|-----|------|
| 错误代码 | `errcodes-appendix.html` | 完整错误代码列表 |
| SQL 关键字 | `sql-keywords-appendix.html` | 保留字列表 |
| 限制说明 | `limits.html` | PostgreSQL 各项限制 |

## 使用示例

### 查询特定函数
```
WebFetch(
  url: "https://www.postgresql.org/docs/current/functions-json.html",
  prompt: "总结 jsonb_set 函数的用法、参数和示例"
)
```

### 查询数据类型
```
WebFetch(
  url: "https://www.postgresql.org/docs/current/datatype-json.html",
  prompt: "对比 json 和 jsonb 的区别、性能和使用场景"
)
```

### 查询错误代码
```
WebFetch(
  url: "https://www.postgresql.org/docs/current/errcodes-appendix.html",
  prompt: "查找错误代码 42P01 的含义和解决方法"
)
```

## 注意事项

- 所有 URL 都是相对于基础 URL 的路径
- 如果章节较大，可以在 prompt 中指定具体小节
- 某些章节包含大量子章节，可以先查询主章节获取结构
