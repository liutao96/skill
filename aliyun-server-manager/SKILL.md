---
name: aliyun-server-manager
description: Comprehensive management tool for Alibaba Cloud (Aliyun) servers. Use when the user needs to manage their Aliyun server, including: (1) Docker container operations (view, start, stop, restart, logs), (2) Server monitoring (CPU, memory, disk, network), (3) Database management (PostgreSQL backup, status check), (4) Log management and analysis, (5) System maintenance (cleanup, health checks), (6) Quick diagnostics and troubleshooting. Automatically handles SSH connections using pre-configured credentials.
---

# Aliyun Server Manager

Manage Alibaba Cloud servers with Docker containers, focusing on the dy-order-oms (迎驾订单管理系统) deployment.

## Server Configuration

See [references/server_info.md](references/server_info.md) for complete server details including:
- Server IP and SSH configuration
- Container list and port mappings
- Service architecture

## Quick Operations

### Container Management

**View all containers:**
```bash
ssh oms "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
```

**View specific container:**
```bash
ssh oms "docker ps -f name=<container-name>"
```

**Restart container:**
```bash
ssh oms "docker restart <container-name>"
```

**View container logs:**
```bash
# Last 100 lines
ssh oms "docker logs --tail 100 <container-name>"

# Follow logs (real-time)
ssh oms "docker logs -f <container-name>"

# With timestamps
ssh oms "docker logs --tail 100 -t <container-name>"
```

**Container resource usage:**
```bash
ssh oms "docker stats --no-stream"
```

### System Monitoring

**System resources:**
```bash
ssh oms "top -bn1 | head -20"
```

**Disk usage:**
```bash
ssh oms "df -h"
```

**Memory usage:**
```bash
ssh oms "free -h"
```

**Docker disk usage:**
```bash
ssh oms "docker system df"
```

### Database Management

**Backup PostgreSQL database:**
```bash
ssh oms "bash -s" < scripts/backup_db.sh
```

**Check database status:**
```bash
ssh oms "docker exec dy-oms-pg pg_isready -U postgres"
```

**View database connections:**
```bash
ssh oms "docker exec dy-oms-pg psql -U postgres -d dy_order_oms -c 'SELECT count(*) FROM pg_stat_activity;'"
```

### Health Checks

**Run comprehensive health check:**
```bash
ssh oms "bash -s" < scripts/check_health.sh
```

**Check specific service:**
```bash
ssh oms "curl -f http://localhost:9001/health || echo 'Service unhealthy'"
```

**Check all ports:**
```bash
ssh oms "netstat -tlnp | grep -E ':(80|443|5432|9001|5678)'"
```

### Maintenance

**Clean up Docker resources:**
```bash
ssh oms "bash -s" < scripts/cleanup_docker.sh
```

**View system logs:**
```bash
ssh oms "journalctl -n 50 --no-pager"
```

**Check disk space:**
```bash
ssh oms "df -h / && du -sh /var/lib/docker"
```

## Common Workflows

### Troubleshooting Container Issues

1. Check container status: `docker ps -a -f name=<container>`
2. View recent logs: `docker logs --tail 100 <container>`
3. Check resource usage: `docker stats --no-stream <container>`
4. Restart if needed: `docker restart <container>`

For detailed troubleshooting, see [references/troubleshooting.md](references/troubleshooting.md).

### Deploying Updates

1. Pull latest code/images
2. Stop containers: `docker compose -f docker-compose.prod.yml down`
3. Rebuild: `docker compose -f docker-compose.prod.yml build`
4. Start: `docker compose -f docker-compose.prod.yml up -d`
5. Verify: Run health check script

### Database Backup Routine

1. Run backup script: `bash scripts/backup_db.sh`
2. Verify backup file created
3. Optional: Download backup locally using `scp`

## SSH Connection

The skill uses the pre-configured SSH alias `oms` which connects to:
- Host: 47.236.205.92
- User: root
- Key: ~/.ssh/dy-oms-key.pem

If SSH connection fails, check:
1. SSH key file exists: `ls ~/.ssh/dy-oms-key.pem`
2. SSH config exists: `cat ~/.ssh/config | grep oms`
3. Server is reachable: `ping 47.236.205.92`

## Important Notes

- Always use `ssh oms` for connections (pre-configured alias)
- The server runs multiple services: dy-oms, Dify, PostgreSQL, Nginx
- Main application port: 9001
- Database port: 5432
- sshguardctl has been disabled for SSH access
