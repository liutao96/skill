#!/usr/bin/env bash
set -euo pipefail

REPO_ZIP_URL="${REPO_ZIP_URL:-https://codeload.github.com/liutao96/skill/zip/refs/heads/main}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SOURCE="$SCRIPT_DIR/feishu-minutes-transcript"
SKILL_DIR="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
TARGET_DIR="$SKILL_DIR/feishu-minutes-transcript"
TEMP_ROOT=""

cleanup() {
  if [ -n "$TEMP_ROOT" ] && [ -d "$TEMP_ROOT" ]; then
    rm -rf "$TEMP_ROOT"
  fi
}
trap cleanup EXIT

if [ -f "$LOCAL_SOURCE/SKILL.md" ]; then
  SOURCE_DIR="$LOCAL_SOURCE"
else
  TEMP_ROOT="$(mktemp -d)"
  ZIP_PATH="$TEMP_ROOT/repo.zip"
  EXTRACT_DIR="$TEMP_ROOT/repo"

  echo "Downloading feishu-minutes-transcript from GitHub..."
  if command -v curl >/dev/null 2>&1; then
    curl -L "$REPO_ZIP_URL" -o "$ZIP_PATH"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$ZIP_PATH" "$REPO_ZIP_URL"
  else
    echo "curl or wget is required to download the skill." >&2
    exit 1
  fi

  mkdir -p "$EXTRACT_DIR"
  unzip -q "$ZIP_PATH" -d "$EXTRACT_DIR"
  SOURCE_DIR="$(find "$EXTRACT_DIR" -type f -path '*/feishu-minutes-transcript/SKILL.md' -print -quit | xargs dirname)"
  if [ -z "$SOURCE_DIR" ] || [ ! -f "$SOURCE_DIR/SKILL.md" ]; then
    echo "Cannot find feishu-minutes-transcript/SKILL.md in downloaded repository." >&2
    exit 1
  fi
fi

mkdir -p "$SKILL_DIR"
rm -rf "$TARGET_DIR"
cp -R "$SOURCE_DIR" "$TARGET_DIR"

echo "Installed only this skill:"
echo "$TARGET_DIR"
echo ""
echo "Next steps:"
echo "1. Restart Codex or Claude Code so it reloads skills."
echo "2. Run the setup checker:"
echo "   pwsh \"$TARGET_DIR/scripts/feishu-minutes-picker.ps1\" -SetupHelp"
echo ""
echo "This installer does not install any other skills."
