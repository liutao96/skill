#!/bin/bash
# OpenClaw 服务管理脚本

SERVER_IP="118.196.144.232"
USER="root"
KEY_FILE="$HOME/.ssh/openclaw.pem"
SSH_OPTS="-i $KEY_FILE -o StrictHostKeyChecking=no -o ConnectTimeout=10"

show_help() {
    echo "OpenClaw 服务管理工具"
    echo ""
    echo "用法: $0 <命令>"
    echo ""
    echo "命令:"
    echo "  status     查看 OpenClaw 状态（进程、端口）"
    echo "  logs       查看最近 50 行日志"
    echo "  logs-f     实时查看日志（tail -f）"
    echo "  start      启动 OpenClaw 服务"
    echo "  stop       停止 OpenClaw 服务"
    echo "  restart    重启 OpenClaw 服务"
    echo "  config     查看 OpenClaw 配置"
    echo "  token      获取 Auth Token"
    echo "  resources  查看系统资源（CPU、内存、磁盘）"
    echo "  exec       执行自定义命令"
    echo ""
    echo "示例:"
    echo "  $0 status"
    echo "  $0 logs"
    echo "  $0 restart"
}

cmd_status() {
    echo "=== OpenClaw 进程状态 ==="
    ssh $SSH_OPTS "${USER}@${SERVER_IP}" "ps aux | grep claw | grep -v grep"
    echo ""
    echo "=== 端口监听状态 ==="
    ssh $SSH_OPTS "${USER}@${SERVER_IP}" "ss -tlnp | grep 18789 || netstat -tlnp | grep 18789 || echo '端口未监听'"
}

cmd_logs() {
    ssh $SSH_OPTS "${USER}@${SERVER_IP}" "cat /var/log/openclaw.log | tail -50"
}

cmd_logs_f() {
    ssh $SSH_OPTS "${USER}@${SERVER_IP}" "tail -f /var/log/openclaw.log"
}

cmd_start() {
    echo "启动 OpenClaw..."
    ssh $SSH_OPTS "${USER}@${SERVER_IP}" "unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY && nohup openclaw gateway --port 18789 > /var/log/openclaw.log 2>&1 &"
    sleep 3
    cmd_status
}

cmd_stop() {
    echo "停止 OpenClaw..."
    ssh $SSH_OPTS "${USER}@${SERVER_IP}" "pkill -f 'openclaw-gateway'"
    sleep 1
    cmd_status
}

cmd_restart() {
    echo "重启 OpenClaw..."
    ssh $SSH_OPTS "${USER}@${SERVER_IP}" "pkill -f 'openclaw-gateway'; sleep 2; unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY && nohup openclaw gateway --port 18789 > /var/log/openclaw.log 2>&1 &"
    sleep 3
    cmd_status
}

cmd_config() {
    ssh $SSH_OPTS "${USER}@${SERVER_IP}" "cat /root/.openclaw/openclaw.json | head -80"
}

cmd_token() {
    ssh $SSH_OPTS "${USER}@${SERVER_IP}" "cat /root/.openclaw/openclaw.json | grep -A 2 'auth'"
}

cmd_resources() {
    echo "=== 磁盘使用 ==="
    ssh $SSH_OPTS "${USER}@${SERVER_IP}" "df -h"
    echo ""
    echo "=== 内存使用 ==="
    ssh $SSH_OPTS "${USER}@${SERVER_IP}" "free -h"
    echo ""
    echo "=== 系统负载 ==="
    ssh $SSH_OPTS "${USER}@${SERVER_IP}" "uptime"
}

cmd_exec() {
    if [ -z "$2" ]; then
        echo "错误: 需要指定要执行的命令"
        echo "用法: $0 exec '<命令>'"
        exit 1
    fi
    ssh $SSH_OPTS "${USER}@${SERVER_IP}" "$2"
}

# 主逻辑
case "$1" in
    status)
        cmd_status
        ;;
    logs)
        cmd_logs
        ;;
    logs-f)
        cmd_logs_f
        ;;
    start)
        cmd_start
        ;;
    stop)
        cmd_stop
        ;;
    restart)
        cmd_restart
        ;;
    config)
        cmd_config
        ;;
    token)
        cmd_token
        ;;
    resources)
        cmd_resources
        ;;
    exec)
        cmd_exec "$@"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "未知命令: $1"
        show_help
        exit 1
        ;;
esac
