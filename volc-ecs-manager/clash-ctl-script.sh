#!/bin/bash
# Clash 代理快捷开关脚本
# 用法: clash-ctl [on|off|status|restart]

CLASH_CONFIG="/etc/clash/config.yaml"
SERVICE_NAME="clash"
PROXY_PORT="7890"
API_PORT="9090"
API_SECRET="clash-admin-2025"

show_help() {
    echo "Clash 代理控制器"
    echo ""
    echo "用法: clash-ctl [命令]"
    echo ""
    echo "命令:"
    echo "  on       启动 Clash 代理服务"
    echo "  off      停止 Clash 代理服务"
    echo "  status   查看 Clash 运行状态"
    echo "  restart  重启 Clash 代理服务"
    echo "  test     测试代理连接"
    echo "  nodes    显示可用节点列表"
    echo ""
    echo "当前配置:"
    echo "  代理端口: 127.0.0.1:$PROXY_PORT"
    echo "  API端口: 0.0.0.0:$API_PORT"
    echo "  配置文件: $CLASH_CONFIG"
}

start_clash() {
    echo "🚀 正在启动 Clash 代理服务..."

    # 检查配置文件
    if [ ! -f "$CLASH_CONFIG" ]; then
        echo "❌ 错误: 配置文件不存在 $CLASH_CONFIG"
        return 1
    fi

    # 启动服务
    systemctl start $SERVICE_NAME 2>/dev/null
    sleep 2

    # 检查是否启动成功
    if systemctl is-active --quiet $SERVICE_NAME; then
        echo "✅ Clash 服务启动成功"
        echo ""
        echo "📊 服务信息:"
        echo "  代理地址: http://127.0.0.1:$PROXY_PORT"
        echo "  API地址: http://127.0.0.1:$API_PORT"
        echo "  API密钥: $API_SECRET"
        echo ""
        echo "🔧 设置环境变量:"
        echo "  export http_proxy=http://127.0.0.1:$PROXY_PORT"
        echo "  export https_proxy=http://127.0.0.1:$PROXY_PORT"
        echo ""
        echo "💡 使用方法:"
        echo "  curl -x http://127.0.0.1:$PROXY_PORT https://www.google.com"
        return 0
    else
        echo "❌ Clash 服务启动失败"
        echo "查看日志: journalctl -u $SERVICE_NAME -n 20"
        return 1
    fi
}

stop_clash() {
    echo "🛑 正在停止 Clash 代理服务..."

    if systemctl is-active --quiet $SERVICE_NAME; then
        systemctl stop $SERVICE_NAME
        echo "✅ Clash 服务已停止"
        echo ""
        echo "🧹 环境变量已清除"
        echo "  unset http_proxy"
        echo "  unset https_proxy"
    else
        echo "⚠️ Clash 服务未运行"
    fi
}

show_status() {
    echo "📊 Clash 代理服务状态"
    echo ""

    if systemctl is-active --quiet $SERVICE_NAME; then
        echo "✅ 服务状态: 运行中"
        echo ""
        echo "📡 连接信息:"
        echo "  代理地址: http://127.0.0.1:$PROXY_PORT"
        echo "  API地址: http://127.0.0.1:$API_PORT"
        echo "  API密钥: $API_SECRET"
        echo ""
        echo "🔌 端口监听:"
        ss -tlnp | grep -E ":($PROXY_PORT|$API_PORT)" || echo "  未找到监听端口"
        echo ""
        echo "🌐 当前代理:"
        curl -s -x http://127.0.0.1:$PROXY_PORT http://ip.sb 2>/dev/null || echo "  无法获取 IP"
    else
        echo "⚠️ 服务状态: 未运行"
        echo ""
        echo "💡 启动命令: clash-ctl on"
    fi
}

restart_clash() {
    echo "🔄 正在重启 Clash 代理服务..."
    stop_clash
    sleep 1
    start_clash
}

test_proxy() {
    echo "🧪 测试代理连接..."
    echo ""

    if ! systemctl is-active --quiet $SERVICE_NAME; then
        echo "❌ Clash 服务未运行"
        echo "请先执行: clash-ctl on"
        return 1
    fi

    echo "1️⃣ 测试国内连接 (百度)..."
    if curl -s -x http://127.0.0.1:$PROXY_PORT --connect-timeout 5 http://www.baidu.com -o /dev/null; then
        echo "   ✅ 国内连接正常"
    else
        echo "   ❌ 国内连接失败"
    fi

    echo ""
    echo "2️⃣ 测试国外连接 (Google)..."
    if curl -s -x http://127.0.0.1:$PROXY_PORT --connect-timeout 10 https://www.google.com -o /dev/null; then
        echo "   ✅ 国外连接正常"
    else
        echo "   ❌ 国外连接失败"
    fi

    echo ""
    echo "3️⃣ 测试当前 IP..."
    IP=$(curl -s -x http://127.0.0.1:$PROXY_PORT --connect-timeout 10 http://ip.sb 2>/dev/null)
    if [ -n "$IP" ]; then
        echo "   📍 当前出口 IP: $IP"
    else
        echo "   ❌ 无法获取 IP"
    fi
}

show_nodes() {
    echo "🌐 可用节点列表"
    echo ""

    if [ -f "/root/.config/mihomo/providers/sealos-sub.yaml" ]; then
        grep "name:" /root/.config/mihomo/providers/sealos-sub.yaml | head -20 | sed 's/.*name: //' | sed 's/^/  • /'
        echo ""
        TOTAL=$(grep -c "name:" /root/.config/mihomo/providers/sealos-sub.yaml)
        echo "📊 总计: $TOTAL 个节点"
    else
        echo "❌ 节点文件不存在"
    fi
}

case "$1" in
    on|start)
        start_clash
        ;;
    off|stop)
        stop_clash
        ;;
    status)
        show_status
        ;;
    restart|reload)
        restart_clash
        ;;
    test)
        test_proxy
        ;;
    nodes)
        show_nodes
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        ;;
esac
