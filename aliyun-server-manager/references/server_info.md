# Server Information

## Server Details

- **IP Address**: 47.236.205.92
- **Domain**: oms.yingjiaec.com
- **SSH User**: root
- **SSH Key**: ~/.ssh/dy-oms-key.pem
- **SSH Alias**: `oms` or `dy-oms`

## SSH Configuration

Located at `~/.ssh/config`:

```
Host oms
    HostName 47.236.205.92
    User root
    IdentityFile /c/Users/刘涛/.ssh/dy-oms-key.pem
    StrictHostKeyChecking no
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

## Running Containers

### Main Application

| Container | Image | Ports | Description |
|-----------|-------|-------|-------------|
| dy-oms-console | dy-order-oms-console | 9001:9001 | 迎驾订单管理系统主应用 |
| dy-oms-pg | postgres:16 | 5432:5432 | PostgreSQL数据库 |

### Dify AI Platform

| Container | Image | Ports | Description |
|-----------|-------|-------|-------------|
| docker-web-1 | langgenius/dify-web:1.10.1-fix.1 | 3000 | Dify前端 |
| docker-api-1 | langgenius/dify-api:1.10.1-fix.1 | 5001 | Dify API |
| docker-worker-1 | langgenius/dify-api:1.10.1-fix.1 | 5001 | Dify Worker |
| docker-worker_beat-1 | langgenius/dify-api:1.10.1-fix.1 | 5001 | Dify Worker Beat |
| docker-plugin_daemon-1 | langgenius/dify-plugin-daemon:0.4.1-local | 5003:5003 | Dify插件守护进程 |
| docker-db_postgres-1 | postgres:15-alpine | 5432 | Dify数据库 |
| docker-redis-1 | redis:6-alpine | 6379 | Redis缓存 |
| docker-weaviate-1 | semitechnologies/weaviate:1.27.0 | - | 向量数据库 |
| docker-sandbox-1 | langgenius/dify-sandbox:0.2.12 | - | 代码沙箱 |

### Infrastructure

| Container | Image | Ports | Description |
|-----------|-------|-------|-------------|
| docker-nginx-1 | nginx:latest | 80:80, 443:443 | Nginx反向代理 |
| docker-ssrf_proxy-1 | ubuntu/squid:latest | 3128 | SSRF代理 |

## Port Mappings

| Port | Service | Access |
|------|---------|--------|
| 80 | Nginx HTTP | Public |
| 443 | Nginx HTTPS | Public |
| 5432 | PostgreSQL (dy-oms) | Public |
| 9001 | dy-oms-console | Public |
| 5678 | ~~n8n~~ (已删除) | - |
| 5003 | Dify Plugin Daemon | Internal |

## Database Configuration

### dy-oms PostgreSQL

- **Container**: dy-oms-pg
- **Database**: dy_order_oms
- **User**: postgres
- **Password**: YingJia@OMS2026!Secure
- **Port**: 5432

### Dify PostgreSQL

- **Container**: docker-db_postgres-1
- **Database**: dify
- **User**: postgres
- **Port**: 5432 (internal)

## Docker Compose Files

- **Development**: `docker-compose.yml`
- **Production**: `docker-compose.prod.yml`
- **Console**: `docker-compose.console.yml`

## Important Paths

- **Project Root**: `/root/dy-order-oms` (assumed)
- **Docker Data**: `/var/lib/docker`
- **Logs**: `/var/log`
- **Backups**: `/root/backups` (recommended)

## Security Notes

- **sshguardctl**: Disabled for SSH access (PAM configuration modified)
- **Firewall**: Ports 22, 80, 443, 5432, 5678, 9001 are open (0.0.0.0/0)
- **SSH Keys**: RSA key pair configured for root user

## Network

- **Docker Network**: app-network (bridge)
- **Public IP**: 47.236.205.92
- **Internal DNS**: Container names resolve within Docker network
