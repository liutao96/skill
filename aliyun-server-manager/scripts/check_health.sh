#!/bin/bash
# Health Check Script for dy-order-oms Server
# Usage: ssh oms "bash -s" < check_health.sh

set -e

echo "=========================================="
echo "  服务器健康检查"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

# 1. System Resources
echo "=== 系统资源 ==="
echo ""

# CPU
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
echo "CPU使用率: ${CPU_USAGE}%"

# Memory
MEM_INFO=$(free -h | grep Mem)
MEM_TOTAL=$(echo $MEM_INFO | awk '{print $2}')
MEM_USED=$(echo $MEM_INFO | awk '{print $3}')
MEM_PERCENT=$(free | grep Mem | awk '{printf("%.1f"), $3/$2 * 100.0}')
echo "内存使用: ${MEM_USED} / ${MEM_TOTAL} (${MEM_PERCENT}%)"

# Disk
DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
DISK_AVAIL=$(df -h / | tail -1 | awk '{print $4}')
echo "磁盘使用: ${DISK_USAGE}% (可用: ${DISK_AVAIL})"

# Warnings
if [ $(echo "$CPU_USAGE > 80" | bc) -eq 1 ]; then
    echo -e "${YELLOW}⚠ CPU使用率过高${NC}"
fi

if [ $(echo "$MEM_PERCENT > 85" | bc) -eq 1 ]; then
    echo -e "${YELLOW}⚠ 内存使用率过高${NC}"
fi

if [ $DISK_USAGE -gt 85 ]; then
    echo -e "${YELLOW}⚠ 磁盘空间不足${NC}"
fi

echo ""

# 2. Docker Status
echo "=== Docker状态 ==="
echo ""

if systemctl is-active --quiet docker; then
    print_status 0 "Docker服务运行中"
else
    print_status 1 "Docker服务未运行"
fi

DOCKER_DISK=$(docker system df --format "{{.Type}}\t{{.Size}}" 2>/dev/null || echo "N/A")
echo "Docker磁盘使用:"
echo "$DOCKER_DISK"
echo ""

# 3. Container Status
echo "=== 容器状态 ==="
echo ""

# Key containers to check
CONTAINERS=("dy-oms-console" "dy-oms-pg" "docker-nginx-1")

for container in "${CONTAINERS[@]}"; do
    if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        STATUS=$(docker inspect --format='{{.State.Status}}' $container)
        if [ "$STATUS" == "running" ]; then
            print_status 0 "$container: 运行中"
        else
            print_status 1 "$container: $STATUS"
        fi
    else
        print_status 1 "$container: 未找到"
    fi
done

echo ""

# 4. Port Checks
echo "=== 端口检查 ==="
echo ""

PORTS=("80:Nginx" "443:Nginx HTTPS" "5432:PostgreSQL" "9001:dy-oms-console")

for port_info in "${PORTS[@]}"; do
    PORT=$(echo $port_info | cut -d':' -f1)
    NAME=$(echo $port_info | cut -d':' -f2)

    if netstat -tlnp 2>/dev/null | grep -q ":${PORT} "; then
        print_status 0 "端口 $PORT ($NAME): 监听中"
    else
        print_status 1 "端口 $PORT ($NAME): 未监听"
    fi
done

echo ""

# 5. Database Check
echo "=== 数据库检查 ==="
echo ""

if docker exec dy-oms-pg pg_isready -U postgres >/dev/null 2>&1; then
    print_status 0 "PostgreSQL: 可连接"

    # Connection count
    CONN_COUNT=$(docker exec dy-oms-pg psql -U postgres -d dy_order_oms -t -c "SELECT count(*) FROM pg_stat_activity;" 2>/dev/null | tr -d ' ')
    echo "  活动连接数: $CONN_COUNT"
else
    print_status 1 "PostgreSQL: 无法连接"
fi

echo ""

# 6. Application Health
echo "=== 应用健康检查 ==="
echo ""

# Check dy-oms-console
if curl -f -s http://localhost:9001 >/dev/null 2>&1; then
    print_status 0 "dy-oms-console: 可访问"
else
    print_status 1 "dy-oms-console: 无法访问"
fi

# Check Nginx
if curl -f -s http://localhost >/dev/null 2>&1; then
    print_status 0 "Nginx: 可访问"
else
    print_status 1 "Nginx: 无法访问"
fi

echo ""

# 7. Recent Errors
echo "=== 最近错误 (最近10分钟) ==="
echo ""

ERROR_COUNT=$(journalctl --since "10 minutes ago" --priority=err --no-pager 2>/dev/null | wc -l)
if [ $ERROR_COUNT -eq 0 ]; then
    print_status 0 "无系统错误"
else
    echo -e "${YELLOW}⚠ 发现 $ERROR_COUNT 个系统错误${NC}"
    echo "查看详情: journalctl --since '10 minutes ago' --priority=err"
fi

echo ""

# 8. Summary
echo "=========================================="
echo "  健康检查完成"
echo "=========================================="
echo ""

# Overall status
if [ $DISK_USAGE -lt 85 ] && [ $(echo "$MEM_PERCENT < 85" | bc) -eq 1 ] && [ $(echo "$CPU_USAGE < 80" | bc) -eq 1 ]; then
    echo -e "${GREEN}✓ 系统状态良好${NC}"
else
    echo -e "${YELLOW}⚠ 系统需要关注${NC}"
fi
