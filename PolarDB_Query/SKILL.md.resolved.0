---
name: PolarDB Query Assistant
description: 使用自然语言直接查询 PolarDB (MySQL) 数据库
version: 1.0.0
---

# PolarDB Query Assistant
这个技能允许你直接使用自然语言查询已连接的阿里云 PolarDB 数据库。

## 功能
- **全表扫描**：快速了解数据库有哪些表。
- **智能查询**：无需编写 SQL，直接问 "某某表有什么数据"。
- **数据分析**：支持 SUM, COUNT, MAX, MIN 等聚合查询。
- **多库支持**：自动识别并查询多个 Schema (sry_2025sz_yh_*)。

## 配置
在使用前，请确保 `config/db_config.json` 文件已正确配置：
- Host: `sry-2025sz-yh-w.rwlb.rds.aliyuncs.com` (公网)
- User: `luitao`
- Password: (请自行填写)

## 使用方法
在 Antigravity 中，你可以这样调用本技能：
> "帮我查询一下今日订单总额"
> "查看 net_order 表的数据结构"

## 维护
- 脚本路径: `scripts/db_bridge.py`
- 核心依赖: `pymysql` (Python 3.x)
