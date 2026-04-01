import re
from pathlib import Path

skills_dir = Path.home() / ".claude" / "skills"

skills_to_update = {
    "spotify-player": ("Spotify音乐播放器", "Terminal Spotify playback"),
    "github": ("GitHub操作", "GitHub operations"),
    "obsidian": ("Obsidian知识库", "Work with Obsidian vaults"),
    "tavily-search": ("Tavily网络搜索", "Search the web with LLM"),
    "openai-whisper": ("Whisper本地语音转文字", "Local speech-to-text"),
    "1password": ("1Password密码管理", "Set up and use 1Password"),
    "apple-notes": ("Apple备忘录管理", "Manage Apple Notes"),
    "apple-reminders": ("Apple提醒事项", "Manage Apple Reminders"),
    "discord": ("Discord操作", "Discord ops"),
    "weather": ("天气查询", "Get current weather"),
    "tmux": ("Tmux远程控制", "Remote-control tmux"),
    "github-sync": ("GitHub仓库同步", "GitHub 仓库同步"),
    "gh-issues": ("GitHub Issues自动化", "Fetch GitHub issues"),
    "mcporter": ("MCP服务器管理", "Use the mcporter CLI"),
    "coding-agent": ("编码代理", "Delegate coding tasks"),
    "node-connect": ("OpenClaw节点诊断", "Diagnose OpenClaw node"),
    "capability-evolver": ("AI自我进化引擎", "A self-evolution engine"),
    "self-improving-agent": ("自我改进代理", "A universal self-improving"),
    "proactive-agent": ("主动型代理", "Transform AI agents"),
    "model-usage": ("模型使用统计", "Use CodexBar CLI"),
    "blogwatcher": ("博客监控", "Monitor blogs and RSS"),
    "gifgrep": ("GIF搜索", "Search GIF providers"),
    "summarize": ("内容摘要", "Summarize or extract"),
    "goplaces": ("Google地点搜索", "Query Google Places"),
    "gog": ("Google Workspace", "Google Workspace CLI"),
    "bear-notes": ("Bear笔记管理", "Create, search, and manage Bear"),
    "imsg": ("iMessage短信管理", "iMessage/SMS CLI"),
    "things-mac": ("Things 3任务管理", "Manage Things 3"),
    "blucli": ("BluOS音箱控制", "BluOS CLI"),
    "bluebubbles": ("BlueBubbles iMessage", "Use when you need to send"),
    "camsnap": ("摄像头截图", "Capture frames"),
    "clawhub": ("ClawHub技能市场", "Use the ClawHub CLI"),
    "eightctl": ("Eight Sleep智能床", "Control Eight Sleep"),
    "nano-pdf": ("PDF自然语言编辑", "Edit PDFs with natural-language"),
    "openhue": ("Philips Hue灯光", "Control Philips Hue"),
    "oracle": ("Oracle CLI最佳实践", "Best practices for using"),
    "ordercli": ("Foodora订单查询", "Foodora-only CLI"),
    "peekaboo": ("macOS UI自动化", "Capture and automate macOS"),
    "sag": ("ElevenLabs语音合成", "ElevenLabs text-to-speech"),
    "session-logs": ("会话日志搜索", "Search and analyze"),
    "sherpa-onnx-tts": ("本地语音合成", "Local text-to-speech"),
    "skill-vetter": ("技能安全检查", "Security-first vetting"),
    "songsee": ("音频可视化", "Generate spectrograms"),
    "sonoscli": ("Sonos音箱控制", "Control Sonos speakers"),
    "video-frames": ("视频帧提取", "Extract frames"),
    "voice-call": ("语音通话", "Start voice calls"),
    "wacli": ("WhatsApp消息", "Send WhatsApp messages"),
    "xurl": ("X/Twitter API", "A CLI tool for making"),
    "himalaya": ("Himalaya邮件客户端", "CLI to manage emails"),
}

updated = 0
for skill_name, (cn_name, en_keyword) in skills_to_update.items():
    skill_md = skills_dir / skill_name / "SKILL.md"
    if skill_md.exists():
        content = skill_md.read_text(encoding='utf-8')

        # 检查是否已有中文
        if '：' in content[:500] and cn_name.split('：')[0] in content[:500]:
            print(f"⏭️  {skill_name} - 已有中文")
            continue

        # 查找 description 行
        lines = content.split('\n')
        for i, line in enumerate(lines):
            if line.strip().startswith('description:'):
                original_desc = line.split(':', 1)[1].strip()
                # 如果还没有这个中文前缀
                if cn_name not in original_desc:
                    new_desc = f"{cn_name}：{original_desc}"
                    lines[i] = f"description: {new_desc}"
                    skill_md.write_text('\n'.join(lines), encoding='utf-8')
                    print(f"✅ {skill_name}")
                    updated += 1
                break
    else:
        print(f"❌ {skill_name} - 文件不存在")

print(f"\n共更新 {updated} 个 skills")
