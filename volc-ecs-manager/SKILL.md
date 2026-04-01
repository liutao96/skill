---
name: volc-ecs-manager
description: 管理火山引擎 ECS 服务器上的 OpenClaw 服务。当用户需要连接 118.196.144.232 服务器、检查 OpenClaw 状态、查看日志、重启服务或执行远程命令时触发。支持通过 SSH 密钥自动连接服务器，无需手动输入密码。
---

# Volc ECS Manager

管理火山引擎 ECS 服务器 (118.196.144.232) 上的 OpenClaw 服务。

## 服务器连接信息

- **IP**: 118.196.144.232
- **用户名**: root
- **SSH 密钥**: ~/.ssh/openclaw.pem
- **OpenClaw 配置**: /root/.openclaw/openclaw.json
- **OpenClaw 日志**: /var/log/openclaw.log

## 可用命令

### 1. 检查 OpenClaw 状态
```bash
ssh -i ~/.ssh/openclaw.pem -o StrictHostKeyChecking=no root@118.196.144.232 "ps aux | grep claw | grep -v grep && echo '---' && ss -tlnp | grep 18789"
```

### 2. 查看 OpenClaw 日志
```bash
ssh -i ~/.ssh/openclaw.pem -o StrictHostKeyChecking=no root@118.196.144.232 "cat /var/log/openclaw.log | tail -50"
```

### 3. 查看实时日志
```bash
ssh -i ~/.ssh/openclaw.pem -o StrictHostKeyChecking=no root@118.196.144.232 "tail -f /var/log/openclaw.log"
```

### 4. 启动 OpenClaw
```bash
ssh -i ~/.ssh/openclaw.pem -o StrictHostKeyChecking=no root@118.196.144.232 "unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY && nohup openclaw gateway --port 18789 > /var/log/openclaw.log 2>&1 &"
```

### 5. 停止 OpenClaw
```bash
ssh -i ~/.ssh/openclaw.pem -o StrictHostKeyChecking=no root@118.196.144.232 "pkill -f 'openclaw-gateway'"
```

### 6. 重启 OpenClaw
```bash
ssh -i ~/.ssh/openclaw.pem -o StrictHostKeyChecking=no root@118.196.144.232 "pkill -f 'openclaw-gateway' && sleep 2 && unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY && nohup openclaw gateway --port 18789 > /var/log/openclaw.log 2>&1 &"
```

### 7. 查看系统资源
```bash
ssh -i ~/.ssh/openclaw.pem -o StrictHostKeyChecking=no root@118.196.144.232 "df -h && echo '---' && free -h && echo '---' && uptime"
```

### 8. 执行自定义命令
```bash
ssh -i ~/.ssh/openclaw.pem -o StrictHostKeyChecking=no root@118.196.144.232 "<自定义命令>"
```

## 常见问题

### 1. 端口未监听
检查 bind 配置是否为 `lan`：
```bash
ssh -i ~/.ssh/openclaw.pem -o StrictHostKeyChecking=no root@118.196.144.232 "cat /root/.openclaw/openclaw.json | grep bind"
```

如果不是 `lan`，修改为监听所有接口：
```bash
ssh -i ~/.ssh/openclaw.pem -o StrictHostKeyChecking=no root@118.196.144.232 "sed -i 's/\"bind\": \"loopback\"/\"bind\": \"lan\"/' /root/.openclaw/openclaw.json"
```

### 2. 启动失败 (代理错误)
如果日志显示 `Invalid URL protocol` 错误，需要清除代理环境变量：
```bash
ssh -i ~/.ssh/openclaw.pem -o StrictHostKeyChecking=no root@118.196.144.232 "unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY && nohup openclaw gateway --port 18789 > /var/log/openclaw.log 2>&1 &"
```

### 3. 获取 Auth Token
```bash
ssh -i ~/.ssh/openclaw.pem -o StrictHostKeyChecking=no root@118.196.144.232 "cat /root/.openclaw/openclaw.json | grep -A 2 'auth'"
```

## 本地连接配置

帮助用户配置本地 OpenClaw 客户端连接到远程服务器：

1. 创建配置目录：`mkdir -p ~/.openclaw`
2. 创建配置文件 `~/.openclaw/openclaw.json`：
```json
{
  "gateway": {
    "url": "ws://118.196.144.232:18789",
    "auth": {
      "token": "<从服务器获取的token>"
    }
  }
}
```

3. 或者直接用命令连接：
```bash
openclaw tui --gateway ws://118.196.144.232:18789?auth.token=<token>
```
