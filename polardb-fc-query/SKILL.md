---
name: polardb-fc-query
description: 通过阿里云函数计算(FC)连接PolarDB数据库，提供REST API查询服务。用于创建可复用的数据库查询函数，支持Serverless Devs一键部署，供飞书妙搭等应用调用。使用场景：(1)需要为多个应用提供统一的数据库查询接口；(2)需要保护数据库连接信息不暴露给前端；(3)需要通过HTTP API查询PolarDB数据；(4)需要与飞书妙搭等低代码平台集成。
---

# PolarDB-FC Query Skill

## 概述

本Skill帮助快速创建和部署阿里云函数计算(FC)服务，提供PolarDB数据库的REST API查询能力。

## 核心能力

1. **一键部署FC函数** - 使用Serverless Devs快速部署
2. **安全查询接口** - 仅支持SELECT，SQL注入防护
3. **飞书妙搭集成** - 提供完整的调用示例代码
4. **多项目共享** - 一个FC函数供多个应用使用

## 工作流程

```
用户请求创建PolarDB查询服务
    ↓
复制assets/中的模板到目标项目
    ↓
指导用户配置数据库连接信息
    ↓
执行s deploy部署到阿里云
    ↓
提供飞书妙搭集成代码示例
    ↓
验证API接口可用性
```

## 使用步骤

### 步骤1: 复制模板到项目

将assets/目录下的模板文件复制到用户项目：

```bash
# 执行复制
cp -r assets/polardb-fc-template ./my-project/
cd my-project/polardb-fc-template
```

### 步骤2: 配置数据库连接

编辑 `s.yaml` 文件中的数据库配置：

```yaml
vars:
  db:
    host: your-polardb-host.rwlb.rds.aliyuncs.com  # 修改为实际地址
    port: "3306"
    database: your_database_name                    # 修改为实际库名
    username: your_username                         # 修改为实际用户名
    password: your_password                         # 修改为实际密码
```

### 步骤3: 部署到阿里云

```bash
# 安装依赖（如有需要）
npm install

# 使用Serverless Devs部署
s deploy
```

部署成功后会输出HTTP触发器地址：
```
https://your-function-name.cn-shenzhen.fcapp.run
```

### 步骤4: 配置PolarDB白名单

在阿里云控制台 → PolarDB → 白名单设置中添加：
- **IP地址**: `0.0.0.0/0` (开发测试用)

生产环境应使用VPC内网连接，配置安全组。

### 步骤5: 测试API接口

```bash
# 健康检查
curl https://your-function-url/health

# SQL查询
curl -X POST https://your-function-url/query \
  -H "Content-Type: application/json" \
  -d '{"sql":"SELECT COUNT(*) as total FROM your_table"}'
```

## 飞书妙搭集成

### 基础查询示例

```javascript
// 在妙搭代码块中调用
async function queryData() {
  const result = await fetch('https://your-function-url/query', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      sql: 'SELECT * FROM sales_data WHERE year = ?',
      params: [2025],
      options: { limit: 100 }
    })
  }).then(r => r.json());

  if (result.success) {
    form.setFieldValue('dataList', result.data);
    message.success(`查询成功，共${result.count}条数据`);
  } else {
    message.error('查询失败: ' + result.error);
  }
}
```

### 分页查询示例

```javascript
// 分页查询
async function queryWithPagination(page = 1) {
  const result = await fetch('https://your-function-url/query/paginated', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      sql: 'SELECT * FROM orders WHERE status = ?',
      params: ['completed'],
      page: page,
      pageSize: 20
    })
  }).then(r => r.json());

  form.setFieldValue('orders', result.data);
  form.setFieldValue('totalPages', result.pagination.totalPages);
}
```

## API端点说明

| 端点 | 方法 | 功能 |
|------|------|------|
| `/health` | GET | 健康检查 |
| `/tables` | GET | 列出所有表 |
| `/schema/:table` | GET | 获取表结构 |
| `/query` | POST | 执行SQL查询 |
| `/query/paginated` | POST | 分页查询 |

## 安全说明

- 仅支持SELECT查询
- 自动过滤危险SQL关键字（INSERT/UPDATE/DELETE等）
- 使用参数化查询防止SQL注入
- 单查询最大返回1000条记录

## 多项目共享方案

**推荐做法**: 部署一次，多个项目共享使用

```
                    ┌─────────────────┐
  飞书妙搭应用A     │                 │
  (销售报表)   ───→│   函数计算 FC   │←── PolarDB
                    │   (只部署一次)   │
  飞书妙搭应用B     │                 │
  (库存管理)   ───→└─────────────────┘
```

无需每个项目都复制部署，直接使用同一个FC地址即可。

## 生产环境建议

1. **使用VPC内网连接** - 降低延迟，提高安全性
2. **配置API密钥** - 添加访问权限控制
3. **设置监控告警** - 通过SLS查看调用日志
4. **配置限流** - 防止恶意调用

## 资源文件

- **assets/polardb-fc-template/** - 完整的FC函数模板代码
- **references/api-examples.md** - 详细的API调用示例
- **references/miaoda-integration.md** - 飞书妙搭完整集成指南

## 故障排查

| 问题 | 可能原因 | 解决方案 |
|------|---------|---------|
| 部署失败 | 阿里云密钥未配置 | 运行 `s config add` |
| 连接超时 | PolarDB白名单未配置 | 添加 `0.0.0.0/0` 到白名单 |
| 查询返回空 | SQL语句错误 | 检查SQL语法和表名 |
| 权限错误 | 数据库用户权限不足 | 检查MySQL用户权限 |
