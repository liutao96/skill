#!/usr/bin/env python3
"""
GitHub 配置管理脚本
用于安全地保存、加载和管理 GitHub 仓库配置和 Token
"""

import json
import os
import sys
import argparse
from datetime import datetime
from pathlib import Path

# 配置文件路径
CONFIG_FILE = ".github-config.json"
CONFIG_PATH = Path.home() / ".openclaw/workspace" / CONFIG_FILE

def get_config_path():
    """获取配置文件路径，优先使用工作区目录"""
    # 检查环境变量或当前工作目录
    workspace = os.environ.get('OPENCLAW_WORKSPACE', os.getcwd())
    return Path(workspace) / CONFIG_FILE

def load_config():
    """加载配置文件"""
    config_path = get_config_path()
    if config_path.exists():
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except json.JSONDecodeError:
            print(f"错误：配置文件格式无效: {config_path}", file=sys.stderr)
            return None
    return {
        "version": "1.0",
        "encrypted": False,
        "default_repo": None,
        "repositories": {},
        "tokens": {}
    }

def save_config(config):
    """保存配置文件"""
    config_path = get_config_path()
    try:
        with open(config_path, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2, ensure_ascii=False)
        return True
    except Exception as e:
        print(f"错误：无法保存配置文件: {e}", file=sys.stderr)
        return False

def add_repository(name, full_name, clone_url, token_ref, local_path=None, default_branch="main"):
    """添加仓库配置"""
    config = load_config()
    if not config:
        return False
    
    if local_path is None:
        local_path = name
    
    repo_entry = {
        "name": name,
        "full_name": full_name,
        "clone_url": clone_url,
        "token_reference": token_ref,
        "local_path": local_path,
        "default_branch": default_branch
    }
    config["repositories"][name] = repo_entry
    
    # 如果没有默认仓库，设为默认
    if config.get("default_repo") is None:
        config["default_repo"] = name
        print(f"已设置 '{name}' 为默认仓库")
    
    success = save_config(config)
    if success:
        print(f"✓ 仓库 '{name}' 添加成功")
    else:
        print("✗ 保存配置失败")
    return success

def add_token(name, token_value, token_type="personal_access", scopes=None):
    """添加 Token 配置"""
    config = load_config()
    if not config:
        return False
    
    if scopes is None:
        scopes = ["repo"]
    
    # 生成 token ID
    token_id = f"token_{len(config['tokens']) + 1}"
    
    config["tokens"][token_id] = {
        "name": name,
        "type": token_type,
        "value": token_value,
        "scopes": scopes,
        "created_at": datetime.now().isoformat()
    }
    
    return token_id, save_config(config)

def get_repository(name=None):
    """获取仓库配置"""
    config = load_config()
    if not config:
        return None
    
    if name is None:
        name = config.get("default_repo")
    
    return config["repositories"].get(name)

def get_token(token_ref):
    """获取 Token 值"""
    config = load_config()
    if not config:
        return None
    
    token_info = config["tokens"].get(token_ref)
    if token_info:
        return token_info["value"]
    return None

def list_repositories():
    """列出所有仓库"""
    config = load_config()
    if not config:
        return []
    
    return list(config["repositories"].keys())

def set_default_repo(name):
    """设置默认仓库"""
    config = load_config()
    if not config:
        return False
    
    if name not in config["repositories"]:
        print(f"错误：仓库 '{name}' 不存在")
        return False
    
    config["default_repo"] = name
    return save_config(config)

def main():
    parser = argparse.ArgumentParser(description="GitHub 配置管理工具")
    subparsers = parser.add_subparsers(dest="command", help="可用命令")
    
    # list 命令
    subparsers.add_parser("list", help="列出所有仓库")
    
    # add-repo 命令
    add_repo_parser = subparsers.add_parser("add-repo", help="添加仓库")
    add_repo_parser.add_argument("--name", required=True, help="仓库名称")
    add_repo_parser.add_argument("--full-name", required=True, help="完整名称 (owner/repo)")
    add_repo_parser.add_argument("--url", required=True, help="clone URL")
    add_repo_parser.add_argument("--token", required=True, help="Token 引用 ID")
    add_repo_parser.add_argument("--path", help="本地路径")
    
    # add-token 命令
    add_token_parser = subparsers.add_parser("add-token", help="添加 Token")
    add_token_parser.add_argument("--name", required=True, help="Token 名称")
    add_token_parser.add_argument("--value", required=True, help="Token 值")
    
    # get-token 命令
    get_token_parser = subparsers.add_parser("get-token", help="获取 Token")
    get_token_parser.add_argument("ref", help="Token 引用 ID")
    
    # default 命令
    default_parser = subparsers.add_parser("default", help="设置默认仓库")
    default_parser.add_argument("name", help="仓库名称")
    
    args = parser.parse_args()
    
    if args.command == "list":
        repos = list_repositories()
        config = load_config()
        default = config.get("default_repo") if config else None
        
        print("已配置的仓库：")
        for repo in repos:
            marker = " (默认)" if repo == default else ""
            print(f"  - {repo}{marker}")
    
    elif args.command == "add-repo":
        local_path = args.path or args.name
        if add_repository(args.name, args.full_name, args.url, args.token, local_path):
            print(f"✓ 仓库 '{args.name}' 添加成功")
        else:
            print("✗ 添加失败")
            return 1
    
    elif args.command == "add-token":
        token_id, success = add_token(args.name, args.value)
        if success:
            print(f"✓ Token 添加成功，引用 ID: {token_id}")
        else:
            print("✗ 添加失败")
            return 1
    
    elif args.command == "get-token":
        ref = args.ref or input("Token 引用 ID: ")
        value = get_token(ref)
        if value:
            print(f"Token: {value}")
        else:
            print("未找到 Token")
            return 1
    
    elif args.command == "default":
        if args.name:
            if set_default_repo(args.name):
                print(f"✓ 默认仓库设置为 '{args.name}'")
            else:
                print("✗ 设置失败")
                return 1
        else:
            config = load_config()
            if config and config.get("default_repo"):
                print(f"当前默认仓库: {config['default_repo']}")
            else:
                print("未设置默认仓库")
    
    else:
        parser.print_help()
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
