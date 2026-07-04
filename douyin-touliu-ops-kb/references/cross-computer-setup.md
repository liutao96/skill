# Cross-computer setup

Use this when Liu Tao asks how to use `douyin-touliu-ops-kb` on another computer.

## Recommended answer

Tell Liu Tao he does not need to memorize commands. On the new computer, open the project folder and ask Codex:

```text
请读取当前项目里的《其他电脑使用说明_抖音投流运营知识库Skill.md》，帮我安装并自检 douyin-touliu-ops-kb Skill。
```

## Installation model

- Real knowledge base stays in the project folder: `抖音运营知识库/`.
- GitHub stores only the lightweight skill: `douyin-touliu-ops-kb/`.
- Codex auto-discovery requires one installation/link step per computer.
- The project script handles the link and writes `DOUYIN_TOULIU_KB_ROOT`.

## Commands

From the project root:

```powershell
powershell -ExecutionPolicy Bypass -File ".\tools\Install-DouyinTouliuOpsKbSkill.ps1" -UseLocalProjectSkill -Force
```

If the project is on a different drive:

```powershell
powershell -ExecutionPolicy Bypass -File ".\tools\Install-DouyinTouliuOpsKbSkill.ps1" -UseLocalProjectSkill -Force -KbRoot "F:\projects-test\短视频带货项目\投流和流程运营教程\抖音运营知识库"
```

Self-check:

```powershell
powershell -ExecutionPolicy Bypass -File ".\tools\Test-DouyinTouliuOpsKbSkill.ps1"
```

