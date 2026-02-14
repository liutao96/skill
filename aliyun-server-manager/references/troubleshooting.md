# Troubleshooting Guide

## Common Issues and Solutions

### Container Not Starting

**Symptoms:**
- Container status shows "Exited" or "Restarting"
- Application not accessible

**Diagnosis:**
```bash
# Check container status
ssh oms "docker ps -a -f name=<container-name>"

# View logs
ssh oms "docker logs --tail 100 <container-name>"

# Check for port conflicts
ssh oms "netstat -tlnp | grep <port>"
```

**Solutions:**
1. Check logs for error messages
2. Verify environment variables in docker-compose
3. Ensure dependent services are running (e.g., database)
4. Check disk space: `df -h`
5. Restart container: `docker restart <container-name>`

### Database Connection Issues

**Symptoms:**
- Application can't connect to database
- "Connection refused" errors

**Diagnosis:**
```bash
# Check PostgreSQL container
ssh oms "docker ps -f name=dy-oms-pg"

# Test database connection
ssh oms "docker exec dy-oms-pg pg_isready -U postgres"

# Check database logs
ssh oms "docker logs --tail 50 dy-oms-pg"
```

**Solutions:**
1. Verify PostgreSQL container is running
2. Check database credentials in application config
3. Verify network connectivity between containers
4. Check PostgreSQL max_connections setting
5. Restart database: `docker restart dy-oms-pg`

### High Memory Usage

**Symptoms:**
- Server slow or unresponsive
- OOM (Out of Memory) errors

**Diagnosis:**
```bash
# Check system memory
ssh oms "free -h"

# Check container memory usage
ssh oms "docker stats --no-stream"

# Check for memory leaks
ssh oms "docker logs <container> | grep -i 'memory\|oom'"
```

**Solutions:**
1. Identify memory-hungry containers
2. Restart problematic containers
3. Adjust container memory limits in docker-compose
4. Clean up unused Docker resources
5. Consider upgrading server resources

### Disk Space Full

**Symptoms:**
- "No space left on device" errors
- Containers failing to start

**Diagnosis:**
```bash
# Check disk usage
ssh oms "df -h"

# Check Docker disk usage
ssh oms "docker system df"

# Find large directories
ssh oms "du -sh /var/lib/docker/* | sort -h"
```

**Solutions:**
1. Run cleanup script: `bash scripts/cleanup_docker.sh`
2. Remove old logs: `journalctl --vacuum-time=7d`
3. Clean Docker: `docker system prune -a`
4. Remove old backups
5. Expand disk if needed

### SSH Connection Failed

**Symptoms:**
- "Connection refused" or "Connection timed out"
- "Permission denied"

**Diagnosis:**
```bash
# Test connectivity
ping 47.236.205.92

# Check SSH key
ls -la ~/.ssh/dy-oms-key.pem

# Test SSH with verbose output
ssh -vvv oms "echo test"
```

**Solutions:**
1. Verify SSH key exists and has correct permissions
2. Check SSH config: `cat ~/.ssh/config | grep oms`
3. Verify server is running (use Aliyun console)
4. Check firewall rules in Aliyun console
5. Verify sshguardctl is disabled on server

### Application Not Accessible

**Symptoms:**
- Can't access http://47.236.205.92:9001
- Connection timeout or refused

**Diagnosis:**
```bash
# Check if container is running
ssh oms "docker ps -f name=dy-oms-console"

# Check if port is listening
ssh oms "netstat -tlnp | grep 9001"

# Test from server
ssh oms "curl -I http://localhost:9001"

# Check Nginx if using reverse proxy
ssh oms "docker logs --tail 50 docker-nginx-1"
```

**Solutions:**
1. Verify container is running: `docker ps`
2. Check container logs for errors
3. Verify port mapping in docker-compose
4. Check firewall rules (port 9001 should be open)
5. Restart container: `docker restart dy-oms-console`

### Slow Performance

**Symptoms:**
- Application responds slowly
- High CPU usage

**Diagnosis:**
```bash
# Check CPU usage
ssh oms "top -bn1 | head -20"

# Check container stats
ssh oms "docker stats --no-stream"

# Check system load
ssh oms "uptime"

# Check for I/O issues
ssh oms "iostat -x 1 5"
```

**Solutions:**
1. Identify resource-intensive processes
2. Check for runaway processes
3. Review application logs for errors
4. Optimize database queries
5. Consider scaling resources

### Docker Daemon Issues

**Symptoms:**
- Docker commands hang or fail
- "Cannot connect to Docker daemon"

**Diagnosis:**
```bash
# Check Docker service status
ssh oms "systemctl status docker"

# Check Docker logs
ssh oms "journalctl -u docker -n 50"
```

**Solutions:**
1. Restart Docker service: `systemctl restart docker`
2. Check for disk space issues
3. Review Docker daemon logs
4. Verify Docker socket permissions
5. Reboot server if necessary

## Emergency Procedures

### Complete Service Restart

```bash
# Stop all containers
ssh oms "docker compose -f docker-compose.prod.yml down"

# Start all containers
ssh oms "docker compose -f docker-compose.prod.yml up -d"

# Verify all services
ssh oms "docker ps"
```

### Database Recovery

```bash
# Stop application
ssh oms "docker stop dy-oms-console"

# Backup current database
ssh oms "bash -s" < scripts/backup_db.sh

# Restart database
ssh oms "docker restart dy-oms-pg"

# Wait for database to be ready
ssh oms "docker exec dy-oms-pg pg_isready -U postgres"

# Start application
ssh oms "docker start dy-oms-console"
```

### System Reboot

```bash
# Gracefully stop all containers
ssh oms "docker compose -f docker-compose.prod.yml down"

# Reboot server
ssh oms "reboot"

# Wait 2-3 minutes, then verify services
ssh oms "docker ps"
```

## Monitoring Commands

### Quick Health Check

```bash
# Run comprehensive health check
ssh oms "bash -s" < scripts/check_health.sh
```

### Real-time Monitoring

```bash
# Watch container stats
ssh oms "docker stats"

# Watch system resources
ssh oms "watch -n 2 'free -h && df -h'"

# Follow application logs
ssh oms "docker logs -f dy-oms-console"
```

## Getting Help

If issues persist:

1. Collect diagnostic information:
   - Container logs
   - System logs
   - Resource usage stats
   - Error messages

2. Check Aliyun console for:
   - Server status
   - Security group rules
   - System events

3. Review recent changes:
   - Code deployments
   - Configuration changes
   - System updates
