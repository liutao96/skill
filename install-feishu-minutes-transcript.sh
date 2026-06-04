#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/feishu-minutes-transcript"
SKILL_DIR="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
TARGET_DIR="$SKILL_DIR/feishu-minutes-transcript"

if [ ! -f "$SOURCE_DIR/SKILL.md" ]; then
  echo "Cannot find feishu-minutes-transcript/SKILL.md next to this installer." >&2
  exit 1
fi

mkdir -p "$SKILL_DIR"
rm -rf "$TARGET_DIR"
cp -R "$SOURCE_DIR" "$TARGET_DIR"

echo "Installed only this skill:"
echo "$TARGET_DIR"
echo ""
echo "Next steps:"
echo "1. Restart Codex or Claude Code so it reloads skills."
echo "2. Run the first-use helper:"
echo "   pwsh \"$TARGET_DIR/scripts/feishu-minutes-picker.ps1\" -SetupHelp"
echo ""
echo "This installer does not install any other skills."
