/**
 * 飞书妙搭 × PolarDB FC 集成示例
 *
 * 使用场景：
 * 1. 从 PolarDB 查询数据并展示在妙搭表单
 * 2. 将查询结果写入妙搭内置数据库
 * 3. 定时同步数据
 */

// ============================================
// 配置信息 - 修改为你的 FC 函数地址
// ============================================
const CONFIG = {
  // 你的 FC 函数 HTTP 触发器地址
  API_BASE_URL: 'https://your-function-url.fcapp.run',
};

// ============================================
// 通用请求方法
// ============================================
async function callPolarDBApi(endpoint, body) {
  const url = `${CONFIG.API_BASE_URL}${endpoint}`;

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });

  const result = await response.json();

  if (!result.success) {
    throw new Error(result.error || '请求失败');
  }

  return result;
}

// ============================================
// 示例 1：按钮点击查询并填充表单
// ============================================
async function example1_QueryAndFillForm() {
  try {
    // 1. 查询 PolarDB
    const result = await callPolarDBApi('/query', {
      sql: 'SELECT id, name, email, phone FROM customers WHERE status = ?',
      params: ['active'],
      options: { limit: 50 }
    });

    // 2. 转换数据格式（适配妙搭表单）
    const formData = result.data.map(item => ({
      customerId: item.id,
      customerName: item.name,
      customerEmail: item.email,
      customerPhone: item.phone,
    }));

    // 3. 填充到子表单组件（假设子表单名为 "customerList"）
    form.setFieldValue('customerList', formData);

    // 4. 显示成功提示
    message.success(`成功加载 ${result.count} 条客户数据`);

    // 5. 记录执行时间
    console.log('查询耗时:', result.executionTime);

  } catch (error) {
    message.error('查询失败: ' + error.message);
    console.error(error);
  }
}

// ============================================
// 示例 2：分页查询
// ============================================
async function example2_PaginatedQuery(page = 1) {
  try {
    const result = await callPolarDBApi('/query/paginated', {
      sql: 'SELECT * FROM orders WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)',
      page: page,
      pageSize: 10
    });

    // 填充数据
    form.setFieldValue('orderList', result.data);

    // 更新分页信息（假设有分页控件）
    form.setFieldValue('currentPage', result.pagination.page);
    form.setFieldValue('totalPages', result.pagination.totalPages);
    form.setFieldValue('totalRecords', result.pagination.total);

    // 控制翻页按钮状态
    form.setFieldProps('prevBtn', { disabled: !result.pagination.hasPrev });
    form.setFieldProps('nextBtn', { disabled: !result.pagination.hasNext });

  } catch (error) {
    message.error('查询失败: ' + error.message);
  }
}

// ============================================
// 示例 3：动态下拉选项
// ============================================
async function example3_DynamicSelect(categoryId) {
  try {
    // 根据分类查询产品
    const result = await callPolarDBApi('/query', {
      sql: 'SELECT id, name, price, stock FROM products WHERE category_id = ? AND stock > 0',
      params: [categoryId],
      options: { limit: 100 }
    });

    // 更新下拉选项
    const options = result.data.map(item => ({
      label: `${item.name} (库存: ${item.stock}, ¥${item.price})`,
      value: item.id,
      // 可以附加额外数据
      extra: {
        price: item.price,
        stock: item.stock
      }
    }));

    form.setFieldProps('productSelect', { options });

  } catch (error) {
    message.error('加载产品列表失败: ' + error.message);
  }
}

// ============================================
// 示例 4：查询并写入妙搭内置数据库
// ============================================
async function example4_SyncToBuiltinDB() {
  try {
    message.loading('正在同步数据...', 0);

    // 1. 从 PolarDB 查询
    const result = await callPolarDBApi('/query', {
      sql: `
        SELECT
          DATE(created_at) as date,
          COUNT(*) as orderCount,
          SUM(total_amount) as totalAmount
        FROM orders
        WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
        GROUP BY DATE(created_at)
        ORDER BY date DESC
      `,
      options: { limit: 7 }
    });

    // 2. 写入妙搭内置数据库表
    // 假设目标表单为 "daily_stats"
    for (const row of result.data) {
      await form.createRecord('daily_stats', {
        date: row.date,
        order_count: row.orderCount,
        total_amount: row.totalAmount,
        sync_time: new Date().toISOString(),
        source: 'polardb'
      });
    }

    message.destroy();
    message.success(`成功同步 ${result.count} 条数据到内置数据库`);

  } catch (error) {
    message.destroy();
    message.error('同步失败: ' + error.message);
  }
}

// ============================================
// 示例 5：联动查询（省市区）
// ============================================
async function example5_CascadingQuery() {
  // 省份选择变化时
  async function onProvinceChange(provinceId) {
    // 查询城市
    const cityResult = await callPolarDBApi('/query', {
      sql: 'SELECT id, name FROM cities WHERE province_id = ?',
      params: [provinceId]
    });

    form.setFieldProps('citySelect', {
      options: cityResult.data.map(c => ({ label: c.name, value: c.id }))
    });

    // 清空区县
    form.setFieldValue('districtSelect', null);
    form.setFieldProps('districtSelect', { options: [] });
  }

  // 城市选择变化时
  async function onCityChange(cityId) {
    // 查询区县
    const districtResult = await callPolarDBApi('/query', {
      sql: 'SELECT id, name FROM districts WHERE city_id = ?',
      params: [cityId]
    });

    form.setFieldProps('districtSelect', {
      options: districtResult.data.map(d => ({ label: d.name, value: d.id }))
    });
  }

  return { onProvinceChange, onCityChange };
}

// ============================================
// 导出方法（供妙搭代码块使用）
// ============================================
export {
  callPolarDBApi,
  example1_QueryAndFillForm,
  example2_PaginatedQuery,
  example3_DynamicSelect,
  example4_SyncToBuiltinDB,
  example5_CascadingQuery,
};
