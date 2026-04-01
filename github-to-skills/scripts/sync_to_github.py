#!/usr/bin/env python3
"""
将本地 Skills 同步到 GitHub 仓库
用法: python sync_to_github.py <skills_dir> <github_repo_url>
"""

import os
import sys
import shutil
import subprocess
import json
from datetime import datetime
from pathlib import Path

# 需要同步的自建 Skills 列表
CUSTOM_SKILLS = [
    "volc-ecs-manager",
    "polardb-fc-query",
    "PolarDB_Query",
    "aliyun-server-manager",
    "postgresql-helper",
    "feishu-miaoda"
]

def sync_skill_to_repo(skill_path, repo_path, skill_name):
    """将单个 skill 同步到仓库目录"""
    source = Path(skill_path) / skill_name
    target = Path(repo_path) / skill_name

    if not source.exists():
        print(f"⚠️  Skill not found: {source}")
        return False

    # 如果目标存在，先删除
    if target.exists():
        print(f"🗑️  Removing old version: {target}")
        shutil.rmtree(target)

    # 复制整个 skill 目录
    print(f"📦 Copying {skill_name}...")
    shutil.copytree(source, target, ignore=shutil.ignore_patterns(
        '__pycache__', '*.pyc', '.git', '.DS_Store', 'node_modules'
    ))

    # 生成/更新 metadata.json
    metadata = {
        "name": skill_name,
        "synced_at": datetime.now().isoformat(),
        "source_path": str(source)
    }

    skill_md = source / "SKILL.md"
    if skill_md.exists():
        with open(skill_md, 'r', encoding='utf-8') as f:
            content = f.read()
            if 'name:' in content:
                metadata["has_frontmatter"] = True

    with open(target / ".skill-metadata.json", 'w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2, ensure_ascii=False)

    print(f"✅ Synced: {skill_name}")
    return True

def generate_readme(repo_path, skills):
    """生成仓库 README"""
    readme_content = f"""# Claude Skills Repository

个人 Claude Code Skills 集合

## 包含 Skills

| Skill | 描述 |
|-------|------|
"""

    for skill_name in skills:
        skill_path = Path(repo_path) / skill_name / "SKILL.md"
        description = "暂无描述"
        if skill_path.exists():
            with open(skill_path, 'r', encoding='utf-8') as f:
                content = f.read()
                # 提取 frontmatter 中的 description
                if 'description:' in content:
                    for line in content.split('\n'):
                        if line.strip().startswith('description:'):
                            description = line.split(':', 1)[1].strip()
                            break

        readme_content += f"| [{skill_name}](./{skill_name}/) | {description} |\n"

    readme_content += f"""
## 使用方法

```bash
# 安装指定 skill
npx skills add liutao96/skill@{skill_name}
```

## 同步时间

最后同步: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
"""

    readme_path = Path(repo_path) / "README.md"
    with open(readme_path, 'w', encoding='utf-8') as f:
        f.write(readme_content)

    print(f"📝 Generated README.md")

def main():
    if len(sys.argv) < 3:
        print("Usage: python sync_to_github.py <skills_dir> <github_repo_path>")
        print("Example: python sync_to_github.py ~/.claude/skills ~/projects/skill")
        sys.exit(1)

    skills_dir = sys.argv[1]
    repo_path = sys.argv[2]

    print(f"🚀 Syncing skills from {skills_dir} to {repo_path}")
    print(f"📋 Skills to sync: {', '.join(CUSTOM_SKILLS)}")
    print()

    # 确保仓库目录存在
    os.makedirs(repo_path, exist_ok=True)

    # 同步每个 skill
    synced = []
    for skill_name in CUSTOM_SKILLS:
        if sync_skill_to_repo(skills_dir, repo_path, skill_name):
            synced.append(skill_name)

    # 生成 README
    generate_readme(repo_path, synced)

    print()
    print("=" * 50)
    print(f"✅ 同步完成! 共同步 {len(synced)} 个 skills")
    print()
    print("下一步操作:")
    print(f"  cd {repo_path}")
    print("  git add .")
    print(f'  git commit -m "Sync skills: {', '.join(synced)}"')
    print("  git push origin main")

if __name__ == "__main__":
    main()
