#!/usr/bin/env python3
"""
批量更新 skills 的 description，添加中文说明
"""

import os
import re
from pathlib import Path

# 中文说明映射表
CHINESE_NAMES = {
    # 密码管理
    "1password": "1Password 密码管理器：管理密码和密钥",

    # Apple 生态
    "apple-notes": "Apple 备忘录管理：创建、查看、编辑备忘录",
    "apple-reminders": "Apple 提醒事项：管理提醒列表和任务",
    "bear-notes": "Bear 笔记管理：创建和搜索 Bear 笔记",
    "imsg": "iMessage 短信管理：发送和查看短信历史",
    "things-mac": "Things 3 任务管理：macOS 任务管理器",

    # 开发工具
    "github": "GitHub 操作：Issues、PRs、CI 管理",
    "github-sync": "GitHub 仓库同步：多仓库配置和同步管理",
    "gh-issues": "GitHub Issues 自动化：自动修复和监控 PR",
    "coding-agent": "编码代理：委派任务给 Codex/Claude Code",
    "mcporter": "MCP 服务器管理：配置和调用 MCP 工具",
    "node-connect": "OpenClaw 节点诊断：排查连接和配对问题",

    # AI/ML
    "gemini": "Google Gemini CLI：AI 问答和生成",
    "openai-whisper": "Whisper 本地语音转文字：离线语音识别",
    "openai-whisper-api": "OpenAI Whisper API：云端语音转文字",
    "model-usage": "模型使用统计：查看 Codex/Claude 费用",
    "capability-evolver": "AI 自我进化引擎：分析和改进运行历史",
    "self-improving-agent": "自我改进代理：从经验中学习",
    "proactive-agent": "主动型代理：预判需求并持续改进",

    # 搜索/信息
    "tavily-search": "Tavily 网络搜索：LLM 优化的搜索结果",
    "blogwatcher": "博客监控：监控 RSS/Atom 订阅更新",
    "gifgrep": "GIF 搜索：搜索和下载 GIF 动图",
    "summarize": "内容摘要：提取 URL、播客、视频的文字摘要",
    "goplaces": "Google 地点搜索：搜索地点详情和评论",
    "gog": "Google Workspace CLI：Gmail、日历、网盘管理",

    # 生产力
    "notion": "Notion 管理：页面、数据库和块操作",
    "obsidian": "Obsidian 知识库：管理 Markdown 笔记",
    "slack": "Slack 操作：发送消息和频道管理",
    "trello": "Trello 看板管理：卡片和列表操作",
    "tmux": "Tmux 远程控制：发送按键和捕获输出",
    "session-logs": "会话日志搜索：分析历史对话记录",

    # 媒体/娱乐
    "spotify-player": "Spotify 音乐播放器：终端控制音乐播放",
    "sonoscli": "Sonos 音箱控制：播放、音量、分组",
    "songsee": "音频可视化：生成频谱图和特征图",
    "voice-call": "语音通话：启动 OpenClaw 语音通话",
    "sherpa-onnx-tts": "本地语音合成：离线文字转语音",
    "video-frames": "视频帧提取：用 ffmpeg 提取视频帧",

    # 智能家居
    "openhue": "Philips Hue 灯光控制：控制灯光和场景",
    "blucli": "BluOS 音箱控制：发现和播放控制",
    "bluebubbles": "iMessage 集成：通过 BlueBubbles 发送消息",
    "eightctl": "Eight Sleep 智能床控制：温度和闹钟",

    # 云服务
    "oracle": "Oracle CLI 最佳实践：提示词和文件打包",
    "oss-manager": "阿里云 OSS 管理：对象存储操作",
    "healthcheck": "OpenClaw 安全检查：主机安全加固",
    "clawhub": "ClawHub 技能市场：搜索和安装技能",

    # 其他工具
    "discord": "Discord 操作：频道消息管理",
    "1password": "1Password 密码管理：密钥和凭证管理",
    "peekaboo": "macOS UI 自动化：捕获和自动化界面",
    "nano-pdf": "PDF 自然语言编辑：用自然语言修改 PDF",
    "camsnap": "摄像头截图：RTSP/ONVIF 摄像头",
    "ordercli": "Foodora 订单查询：查看历史订单",
    "wacli": "WhatsApp 消息：发送和搜索消息",
    "weather": "天气查询：当前天气和预报",
    "xurl": "X/Twitter API：发推文和回复",
    "canvas": "Canvas 画布：图形绘制",
    "skill-vetter": "技能安全检查：审查 OpenClaw 技能安全性",

    # 邮件
    "himalaya": "Himalaya 邮件客户端：IMAP/SMTP 邮件管理",

    # 已有中文的不需要修改
    "canvas-design": None,
    "doc-coauthoring": None,
    "docx": None,
    "feishu-miaoda": None,
    "frontend-design": None,
    "github-to-skills": None,
    "markitdown": None,
    "mcp-builder": None,
    "pdf": None,
    "polardb-fc-query": None,
    "PolarDB_Query": None,
    "postgresql-helper": None,
    "skill-creator": None,
    "skill-evolution-manager": None,
    "skill-manager": None,
    "volc-ecs-manager": None,
    "xlsx": None,
    "browser-use": None,
    "chrome-cdp": None,
    "aliyun-server-manager": None,
    "find-skills": None,
    "rpaframework": None,
    "product-manager-skills": None,
}

def update_skill_description(skill_dir):
    """更新单个 skill 的 description"""
    skill_name = skill_dir.name
    skill_md = skill_dir / "SKILL.md"

    if not skill_md.exists():
        return False, "SKILL.md not found"

    # 读取文件内容
    with open(skill_md, 'r', encoding='utf-8') as f:
        content = f.read()

    # 如果已经有中文前缀，跳过
    if '：' in content[:500] or '【' in content[:500]:
        return False, "Already has Chinese"

    # 获取中文说明
    chinese_desc = CHINESE_NAMES.get(skill_name)
    if not chinese_desc:
        return False, "No Chinese mapping"

    # 提取当前 description
    desc_match = re.search(r'^description:\s*(.+)$', content, re.MULTILINE)
    if not desc_match:
        return False, "No description found"

    original_desc = desc_match.group(1).strip()

    # 构建新的 description：中文说明 + 英文原文
    new_desc = f"{chinese_desc} - {original_desc}"

    # 替换 description
    new_content = re.sub(
        r'^(description:\s*).+$',
        rf'\1{new_desc}',
        content,
        flags=re.MULTILINE
    )

    # 写回文件
    with open(skill_md, 'w', encoding='utf-8') as f:
        f.write(new_content)

    return True, f"Updated: {new_desc[:80]}..."

def main():
    skills_dir = Path.home() / ".claude" / "skills"

    updated = 0
    skipped = 0
    failed = 0

    print("开始更新 skills description...\n")

    for skill_dir in sorted(skills_dir.iterdir()):
        if not skill_dir.is_dir():
            continue
        if skill_dir.name.startswith('.'):
            continue
        if skill_dir.name.startswith('_'):
            continue

        success, msg = update_skill_description(skill_dir)

        if success:
            print(f"✅ {skill_dir.name}")
            print(f"   {msg}")
            updated += 1
        else:
            if msg == "No Chinese mapping":
                print(f"⏭️  {skill_dir.name} - 跳过 (无中文映射)")
            elif msg == "Already has Chinese":
                print(f"⏭️  {skill_dir.name} - 跳过 (已有中文)")
            else:
                print(f"⚠️  {skill_dir.name} - {msg}")
            skipped += 1

    print(f"\n{'='*50}")
    print(f"更新完成!")
    print(f"✅ 已更新: {updated} 个")
    print(f"⏭️  已跳过: {skipped} 个")
    print(f"{'='*50}")

if __name__ == "__main__":
    main()
