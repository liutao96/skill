#!/bin/bash
# Docker Cleanup Script
# Usage: ssh oms "bash -s" < cleanup_docker.sh

set -e

echo "=========================================="
echo "  Docker 清理"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="
echo ""

# Show current disk usage
echo "=== 清理前磁盘使用 ==="
docker system df
echo ""

# Ask for confirmation (when run interactively)
if [ -t 0 ]; then
    read -p "是否继续清理? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "取消清理"
        exit 0
    fi
fi

echo "开始清理..."
echo ""

# 1. Remove stopped containers
echo "[1/5] 删除已停止的容器..."
STOPPED=$(docker ps -aq -f status=exited)
if [ -n "$STOPPED" ]; then
    docker rm $STOPPED
    echo "✓ 已删除 $(echo $STOPPED | wc -w) 个容器"
else
    echo "✓ 没有已停止的容器"
fi
echo ""

# 2. Remove dangling images
echo "[2/5] 删除悬空镜像..."
DANGLING=$(docker images -qf dangling=true)
if [ -n "$DANGLING" ]; then
    docker rmi $DANGLING
    echo "✓ 已删除 $(echo $DANGLING | wc -w) 个悬空镜像"
else
    echo "✓ 没有悬空镜像"
fi
echo ""

# 3. Remove unused volumes
echo "[3/5] 删除未使用的数据卷..."
docker volume prune -f
echo "✓ 完成"
echo ""

# 4. Remove unused networks
echo "[4/5] 删除未使用的网络..."
docker network prune -f
echo "✓ 完成"
echo ""

# 5. Remove build cache
echo "[5/5] 清理构建缓存..."
docker builder prune -f
echo "✓ 完成"
echo ""

# Show disk usage after cleanup
echo "=== 清理后磁盘使用 ==="
docker system df
echo ""

echo "=========================================="
echo "  清理完成"
echo "=========================================="
echo ""
echo "提示: 如需更彻底的清理，可运行:"
echo "  docker system prune -a --volumes"
echo "  (警告: 这将删除所有未使用的镜像和数据卷)"
