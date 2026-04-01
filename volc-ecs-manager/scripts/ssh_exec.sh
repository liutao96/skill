#!/bin/bash
# SSH 执行脚本 - 火山引擎 ECS 服务器

SERVER_IP="118.196.144.232"
USER="root"
KEY_FILE="$HOME/.ssh/openclaw.pem"

if [ $# -eq 0 ]; then
    echo "用法: $0 '<命令>'"
    exit 1
fi

COMMAND="$1"

ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no -o ConnectTimeout=10 "${USER}@${SERVER_IP}" "$COMMAND"
