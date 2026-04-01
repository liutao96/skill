#!/bin/bash
# OSS 快捷命令封装脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 默认 Bucket（从配置文件读取或手动设置）
DEFAULT_BUCKET="liutaoxie"

# 使用说明
usage() {
    echo -e "${GREEN}OSS 管理工具${NC}"
    echo ""
    echo "用法: oss-manager <命令> [参数]"
    echo ""
    echo "命令:"
    echo "  ls [path]         列出 OSS 文件"
    echo "  push <local> <remote>  上传文件/目录"
    echo "  pull <remote> <local>  下载文件/目录"
    echo "  sync <local> <remote>  同步目录"
    echo "  rm <path>         删除文件/目录"
    echo "  stat              查看 Bucket 统计"
    echo ""
    echo "示例:"
    echo "  oss-manager ls"
    echo "  oss-manager ls openclaw/"
    echo "  oss-manager push ./myfile.txt files/"
    echo "  oss-manager pull files/myfile.txt ./downloads/"
}

# 检查 ossutil 是否安装
check_ossutil() {
    if ! command -v ossutil &> /dev/null; then
        echo -e "${RED}错误: ossutil 未安装${NC}"
        echo "请访问 https://help.aliyun.com/document_detail/120075.html 安装"
        exit 1
    fi
}

# 列出文件
cmd_ls() {
    local path="${1:-}"
    local recursive="${2:-}"
    
    echo -e "${YELLOW}列出 oss://$DEFAULT_BUCKET/$path${NC}"
    if [ "$recursive" = "-r" ] || [ "$recursive" = "--recursive" ]; then
        ossutil ls "oss://$DEFAULT_BUCKET/$path" --recursive
    else
        ossutil ls "oss://$DEFAULT_BUCKET/$path"
    fi
}

# 上传文件
cmd_push() {
    local local_path="$1"
    local remote_path="$2"
    
    if [ -z "$local_path" ] || [ -z "$remote_path" ]; then
        echo -e "${RED}错误: 需要本地路径和远程路径${NC}"
        echo "用法: oss-manager push <本地路径> <远程路径>"
        exit 1
    fi
    
    if [ ! -e "$local_path" ]; then
        echo -e "${RED}错误: 本地路径不存在: $local_path${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}上传 $local_path 到 oss://$DEFAULT_BUCKET/$remote_path${NC}"
    if [ -d "$local_path" ]; then
        ossutil cp -r "$local_path" "oss://$DEFAULT_BUCKET/$remote_path"
    else
        ossutil cp "$local_path" "oss://$DEFAULT_BUCKET/$remote_path"
    fi
    
    echo -e "${GREEN}上传完成${NC}"
}

# 下载文件
cmd_pull() {
    local remote_path="$1"
    local local_path="$2"
    
    if [ -z "$remote_path" ] || [ -z "$local_path" ]; then
        echo -e "${RED}错误: 需要远程路径和本地路径${NC}"
        echo "用法: oss-manager pull <远程路径> <本地路径>"
        exit 1
    fi
    
    echo -e "${YELLOW}下载 oss://$DEFAULT_BUCKET/$remote_path 到 $local_path${NC}"
    
    # 创建本地目录
    local parent_dir=$(dirname "$local_path")
    if [ ! -d "$parent_dir" ]; then
        mkdir -p "$parent_dir"
    fi
    
    ossutil cp -r "oss://$DEFAULT_BUCKET/$remote_path" "$local_path"
    
    echo -e "${GREEN}下载完成${NC}"
}

# 同步目录
cmd_sync() {
    local local_path="$1"
    local remote_path="$2"
    local direction="${3:-up}"  # up 或 down
    
    if [ -z "$local_path" ] || [ -z "$remote_path" ]; then
        echo -e "${RED}错误: 需要本地路径和远程路径${NC}"
        echo "用法: oss-manager sync <本地路径> <远程路径> [up|down]"
        exit 1
    fi
    
    if [ "$direction" = "up" ]; then
        echo -e "${YELLOW}同步本地 → OSS: $local_path → oss://$DEFAULT_BUCKET/$remote_path${NC}"
        ossutil sync "$local_path" "oss://$DEFAULT_BUCKET/$remote_path"
    else
        echo -e "${YELLOW}同步 OSS → 本地: oss://$DEFAULT_BUCKET/$remote_path → $local_path${NC}"
        # 创建本地目录
        if [ ! -d "$local_path" ]; then
            mkdir -p "$local_path"
        fi
        ossutil sync "oss://$DEFAULT_BUCKET/$remote_path" "$local_path"
    fi
    
    echo -e "${GREEN}同步完成${NC}"
}

# 删除文件
cmd_rm() {
    local path="$1"
    
    if [ -z "$path" ]; then
        echo -e "${RED}错误: 需要指定路径${NC}"
        echo "用法: oss-manager rm <路径>"
        exit 1
    fi
    
    echo -e "${RED}警告: 即将删除 oss://$DEFAULT_BUCKET/$path${NC}"
    read -p "确认删除? (y/N): " confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        ossutil rm -r -f "oss://$DEFAULT_BUCKET/$path"
        echo -e "${GREEN}删除完成${NC}"
    else
        echo "已取消"
    fi
}

# 查看 Bucket 统计
cmd_stat() {
    echo -e "${YELLOW}查看 Bucket 统计: oss://$DEFAULT_BUCKET${NC}"
    ossutil bucket-stat "oss://$DEFAULT_BUCKET"
}

# 主入口
check_ossutil

COMMAND="${1:-}"
shift || true

case "$COMMAND" in
    ls)
        cmd_ls "$@"
        ;;
    push)
        cmd_push "$@"
        ;;
    pull)
        cmd_pull "$@"
        ;;
    sync)
        cmd_sync "$@"
        ;;
    rm)
        cmd_rm "$@"
        ;;
    stat)
        cmd_stat
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        if [ -z "$COMMAND" ]; then
            usage
        else
            echo -e "${RED}未知命令: $COMMAND${NC}"
            echo "使用 'oss-manager help' 查看帮助"
            exit 1
        fi
        ;;
esac