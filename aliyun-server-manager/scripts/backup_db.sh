#!/bin/bash
# Database Backup Script for dy-order-oms
# Usage: ssh oms "bash -s" < backup_db.sh

set -e

# Configuration
BACKUP_DIR="/root/backups"
DB_CONTAINER="dy-oms-pg"
DB_NAME="dy_order_oms"
DB_USER="postgres"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/dy_oms_backup_${TIMESTAMP}.sql"
KEEP_DAYS=7

echo "=========================================="
echo "  数据库备份"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="
echo ""

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER}$"; then
    echo "错误: 数据库容器 $DB_CONTAINER 未运行"
    exit 1
fi

# Check database connectivity
if ! docker exec "$DB_CONTAINER" pg_isready -U "$DB_USER" >/dev/null 2>&1; then
    echo "错误: 无法连接到数据库"
    exit 1
fi

echo "开始备份数据库: $DB_NAME"
echo "备份文件: $BACKUP_FILE"
echo ""

# Perform backup
docker exec "$DB_CONTAINER" pg_dump -U "$DB_USER" -d "$DB_NAME" > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    # Compress backup
    gzip "$BACKUP_FILE"
    BACKUP_FILE="${BACKUP_FILE}.gz"

    # Get file size
    FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)

    echo "✓ 备份成功"
    echo "  文件: $BACKUP_FILE"
    echo "  大小: $FILE_SIZE"
    echo ""

    # Clean up old backups
    echo "清理旧备份 (保留最近 $KEEP_DAYS 天)..."
    find "$BACKUP_DIR" -name "dy_oms_backup_*.sql.gz" -type f -mtime +$KEEP_DAYS -delete

    REMAINING=$(find "$BACKUP_DIR" -name "dy_oms_backup_*.sql.gz" -type f | wc -l)
    echo "✓ 当前保留 $REMAINING 个备份文件"
    echo ""

    # List recent backups
    echo "最近的备份文件:"
    ls -lh "$BACKUP_DIR"/dy_oms_backup_*.sql.gz | tail -5
else
    echo "✗ 备份失败"
    exit 1
fi

echo ""
echo "=========================================="
echo "  备份完成"
echo "=========================================="
