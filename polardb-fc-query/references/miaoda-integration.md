# 飞书妙搭集成指南

## 概述

本文档详细介绍如何在飞书妙搭应用中集成 PolarDB-FC 查询服务。

## 使用场景

### 场景1：将 PolarDB 数据同步到妙搭表单

**目标**: 从 PolarDB 查询数据，填充到妙搭表单子表单中

**步骤**:
1. 在妙搭表单中添加按钮
2. 按钮绑定代码块，调用 FC API
3. 将返回数据填充到子表单

**代码示例**:
```javascript
// 按钮点击事件
async function onButtonClick() {
  const response = await fetch('https://your-fc-url/query', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      sql: 'SELECT id, name, email FROM customers WHERE created_at > ?',
      params: ['2024-01-01'],
      options: { limit: 100 }
    })
  });

  const result = await response.json();

  if (!result.success) {
    message.error('查询失败: ' + result.error);
    return;
  }

  // 直接填充子表单
  form.setFieldValue('customerList', data.map(item => ({
    customerId: item.id,
    customerName: item.name,
    customerEmail: item.email
  })));

  message.success(`成功加载 ${data.length} 条数据`);
}
```

---

### 场景2：使用数据流定时同步

**目标**: 每天定时从 PolarDB 同步数据到妙搭内置数据库

**数据流配置**:

```
定时触发器（每天 8:00）
  ↓
HTTP 请求节点
  URL: https://your-fc-url/query
  Method: POST
  Body: {
    "sql": "SELECT * FROM daily_report WHERE date = CURDATE()"
  }
  ↓
数据转换节点
  将 API 返回转换为妙搭表单格式
  ↓
新增数据节点
  批量写入目标表单
```

---

### 场景3：动态查询并展示

**目标**: 下拉选择联动查询，实时更新选项

**代码示例**:
```javascript
// 下拉选择联动查询
async function onSelectChange(value) {
  const result = await fetch('https://your-fc-url/query', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      sql: 'SELECT product_name, price FROM products WHERE category_id = ?',
      params: [value]
    })
  }).then(r => r.json());

  if (result.success) {
    // 更新下拉选项
    form.setFieldProps('productSelect', {
      options: result.data.map(item => ({
        label: `${item.product_name} (¥${item.price})`,
        value: item.product_name
      }))
    });
  }
}
```

---

### 场景4：复杂报表展示

**目标**: 展示聚合统计报表

**代码示例**:
```javascript
// 加载销售报表
async function loadSalesReport() {
  const result = await fetch('https://your-fc-url/query', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      sql: `
        SELECT
          DATE_FORMAT(order_date, '%Y-%m') as month,
          COUNT(*) as order_count,
          SUM(amount) as total_amount,
          AVG(amount) as avg_amount
        FROM orders
        WHERE order_date >= ?
        GROUP BY DATE_FORMAT(order_date, '%Y-%m')
        ORDER BY month DESC
      `,
      params: ['2024-01-01']
    })
  }).then(r => r.json());

  if (result.success) {
    // 填充到表格组件
    form.setFieldValue('reportTable', result.data);
  }
}
```

## 常见问题

### Q: 跨域问题怎么办？

A: FC 函数已配置 CORS 响应头，支持所有域名访问：
```javascript
headers: {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
}
```

### Q: 大数据量如何处理？

A: 使用分页接口：
```javascript
// 分页查询
const result = await fetch('/query/paginated', {
  body: JSON.stringify({
    sql: 'SELECT * FROM large_table',
    page: 1,
    pageSize: 50  // 每页50条
  })
});
```

### Q: 如何防止 SQL 注入？

A: 必须使用参数化查询：
```javascript
// ✅ 正确做法 - 使用参数
{
  "sql": "SELECT * FROM users WHERE name = ?",
  "params": [userInput]  // 会被正确转义
}

// ❌ 错误做法 - 字符串拼接
{
  "sql": `SELECT * FROM users WHERE name = '${userInput}'`  // 危险！
}
```

## 最佳实践

1. **错误处理** - 始终检查 `result.success`
2. **加载状态** - 使用 `message.loading()` 提示用户
3. **数据转换** - 将数据库字段映射为表单字段名
4. **缓存策略** - 不频繁变化的数据可缓存到妙搭内置数据库
