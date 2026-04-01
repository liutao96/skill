#!/usr/bin/env python3
"""
GitHub 仓库操作脚本
用于执行 clone、pull、push 等 git 操作
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path

# 导入配置管理模块
sys.path.insert(0, os.path.dirname(__file__))
from config_manager import (
    load_config, get_repository, get_token, list_repositories,
    get_config_path
)

def run_git_command(args, cwd=None, check=True):
    """执行 git 命令"""
    try:
        result = subprocess.run(
            ["git"] + args,
            cwd=cwd,
            capture_output=True,
            text=True,
            check=check
        )
        return result
    except subprocess.CalledProcessError as e:
        print(f"Git 错误: {e.stderr}", file=sys.stderr)
        return None
    except FileNotFoundError:
        print("错误：未找到 git 命令，请确保 git 已安装", file=sys.stderr)
        return None

def get_auth_url(repo_info, token):
    """构建带认证的 URL"""
    url = repo_info["clone_url"]
    # 将 https://github.com/... 替换为 https://<token>@github.com/...
    if url.startswith("https://"):
        return url.replace("https://", f"https://{token}@")
    return url

def clone_repository(repo_name, target_path=None):
    """Clone 仓库到本地"""
    config = load_config()
    if not config:
        print("错误：无法加载配置", file=sys.stderr)
        return False
    
    repo_info = get_repository(repo_name)
    if not repo_info:
        print(f"错误：未找到仓库 '{repo_name}'", file=sys.stderr)
        print(f"已配置的仓库: {', '.join(list_repositories())}")
        return False
    
    token = get_token(repo_info["token_reference"])
    if not token:
        print(f"错误：无法获取 Token ({repo_info['token_reference']})", file=sys.stderr)
        return False
    
    # 确定本地路径
    if target_path:
        local_path = target_path
    else:
        local_path = repo_info.get("local_path", repo_name)
    
    # 检查目录是否已存在
    if os.path.exists(local_path):
        print(f"错误：目录 '{local_path}' 已存在")
        return False
    
    # 构建认证 URL
    auth_url = get_auth_url(repo_info, token)
    
    print(f"正在克隆仓库 '{repo_name}'...")
    print(f"来源: {repo_info['clone_url']}")
    print(f"目标: {local_path}")
    
    result = run_git_command(["clone", auth_url, local_path])
    if result and result.returncode == 0:
        print(f"✓ 克隆成功: {local_path}")
        return True
    else:
        print(f"✗ 克隆失败")
        return False

def pull_repository(repo_name=None, local_path=None):
    """拉取仓库更新"""
    if local_path and os.path.exists(os.path.join(local_path, ".git")):
        target_dir = local_path
    elif repo_name:
        repo_info = get_repository(repo_name)
        if not repo_info:
            print(f"错误：未找到仓库 '{repo_name}'")
            return False
        target_dir = repo_info.get("local_path", repo_name)
    else:
        # 尝试在当前目录执行
        target_dir = os.getcwd()
    
    if not os.path.exists(os.path.join(target_dir, ".git")):
        print(f"错误：'{target_dir}' 不是有效的 git 仓库")
        return False
    
    print(f"正在拉取更新: {target_dir}")
    result = run_git_command(["pull"], cwd=target_dir)
    if result and result.returncode == 0:
        print("✓ 拉取成功")
        print(result.stdout)
        return True
    else:
        print("✗ 拉取失败")
        return False

def push_repository(repo_name=None, local_path=None, commit_msg="更新"):
    """推送仓库更改"""
    if local_path and os.path.exists(os.path.join(local_path, ".git")):
        target_dir = local_path
    elif repo_name:
        repo_info = get_repository(repo_name)
        if not repo_info:
            print(f"错误：未找到仓库 '{repo_name}'")
            return False
        target_dir = repo_info.get("local_path", repo_name)
    else:
        # 尝试在当前目录执行
        target_dir = os.getcwd()
    
    if not os.path.exists(os.path.join(target_dir, ".git")):
        print(f"错误：'{target_dir}' 不是有效的 git 仓库")
        return False
    
    # 检查是否有更改要提交
    status_result = run_git_command(["status", "--porcelain"], cwd=target_dir, check=False)
    if not status_result or not status_result.stdout.strip():
        print("没有要提交的更改")
        return True
    
    print(f"正在推送更改: {target_dir}")
    
    # 添加更改
    add_result = run_git_command(["add", "."], cwd=target_dir)
    if not add_result or add_result.returncode != 0:
        print("✗ 添加更改失败")
        return False
    
    # 提交
    commit_result = run_git_command(["commit", "-m", commit_msg], cwd=target_dir)
    if not commit_result or commit_result.returncode != 0:
        print("✗ 提交失败")
        return False
    
    # 推送
    push_result = run_git_command(["push", "origin", "HEAD"], cwd=target_dir)
    if push_result and push_result.returncode == 0:
        print("✓ 推送成功")
        return True
    else:
        print("✗ 推送失败")
        return False

def main():
    parser = argparse.ArgumentParser(description="GitHub 仓库操作工具")
    subparsers = parser.add_subparsers(dest="command", help="可用命令")
    
    # clone 命令
    clone_parser = subparsers.add_parser("clone", help="克隆仓库")
    clone_parser.add_argument("repo", help="仓库名称（配置的）")
    clone_parser.add_argument("--path", help="本地路径")
    
    # pull 命令
    pull_parser = subparsers.add_parser("pull", help="拉取更新")
    pull_parser.add_argument("--repo", help="仓库名称")
    pull_parser.add_argument("--path", help="本地路径")
    
    # push 命令
    push_parser = subparsers.add_parser("push", help="推送更改")
    push_parser.add_argument("--repo", help="仓库名称")
    push_parser.add_argument("--path", help="本地路径")
    push_parser.add_argument("--message", "-m", default="更新", help="提交信息")
    
    args = parser.parse_args()
    
    if args.command == "clone":
        success = clone_repository(args.repo, args.path)
    elif args.command == "pull":
        success = pull_repository(args.repo, args.path)
    elif args.command == "push":
        success = push_repository(args.repo, args.path, args.message)
    else:
        parser.print_help()
        return 0
    
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())
