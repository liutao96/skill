#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SOURCE="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_NAME="$(basename "$SKILL_SOURCE")"
SKILL_DIR="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
TARGET_DIR="$SKILL_DIR/$SKILL_NAME"

if [ ! -f "$SKILL_SOURCE/SKILL.md" ]; then
  echo "Cannot find SKILL.md in the parent folder of this installer." >&2
  exit 1
fi

if [ "$SKILL_NAME" != "feishu-minutes-transcript" ]; then
  echo "This installer only supports feishu-minutes-transcript, got: $SKILL_NAME" >&2
  exit 1
fi

mkdir -p "$SKILL_DIR"
rm -rf "$TARGET_DIR"
cp -R "$SKILL_SOURCE" "$TARGET_DIR"

echo "Installed only this skill:"
echo "$TARGET_DIR"
echo ""
echo "Next steps:"
echo "1. Restart Codex or Claude Code so it reloads skills."
echo "2. Run the setup checker:"
echo "   pwsh \"$TARGET_DIR/scripts/feishu-minutes-picker.ps1\" -SetupHelp"
echo ""
echo "This installer does not install any other skills."
