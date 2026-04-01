# 服务器信息

## 基本信息

- **服务器 IP**: 118.196.144.232
- **提供商**: 火山引擎 (Volcengine)
- **类型**: ECS (云服务器)
- **登录用户**: root
- **SSH 密钥**: ~/.ssh/openclaw.pem

## OpenClaw 配置

- **安装路径**: /usr/bin/openclaw
- **配置文件**: /root/.openclaw/openclaw.json
- **日志文件**: /var/log/openclaw.log
- **服务端口**: 18789
- **监听地址**: 0.0.0.0 (所有接口)

## 已解决问题记录

### 问题 1: 端口只监听 127.0.0.1
**症状**: 无法从外部连接到 OpenClaw
**原因**: 配置中 `bind` 设置为 `loopback`
**解决**: 修改为 `lan`
```bash
sed -i 's/"bind": "loopback"/"bind": "lan"/' /root/.openclaw/openclaw.json
```

### 问题 2: 启动失败 (代理错误)
**症状**: 日志显示 `Invalid URL protocol: the URL must start with http: or https:`
**原因**: 服务器环境变量配置了 socks5 代理，OpenClaw 不支持
**解决**: 启动前清除代理环境变量
```bash
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
```

## 本地连接配置

创建 `~/.openclaw/openclaw.json`:

```json
{
  "gateway": {
    "url": "ws://118.196.144.232:18789",
    "auth": {
      "token": "50cedabcbc67ca7c63f2b113147d6e9b96052e5156b091d2"
    }
  }
}
```

或使用命令行连接:
```bash
openclaw tui --gateway ws://118.196.144.232:18789?auth.token=50cedabcbc67ca7c63f2b113147d6e9b96052e5156b091d2
```
