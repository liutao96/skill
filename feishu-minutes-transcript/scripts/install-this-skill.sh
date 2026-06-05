#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SOURCE="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_NAME="$(basename "$SKILL_SOURCE")"
SKILL_DIR="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
TARGET_DIR="$SKILL_DIR/$SKILL_NAME"
REQUIRED_SCOPES="minutes:minutes.search:read minutes:minutes:readonly minutes:minutes.artifacts:read minutes:minutes.transcript:export minutes:minutes.media:export"
SKIP_DEPENDENCY_SETUP=0
SKIP_FEISHU_AUTH=0

for arg in "$@"; do
  case "$arg" in
    --skip-dependency-setup)
      SKIP_DEPENDENCY_SETUP=1
      ;;
    --skip-feishu-auth)
      SKIP_FEISHU_AUTH=1
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

has_command() {
  command -v "$1" >/dev/null 2>&1
}

require_brew() {
  if ! has_command brew; then
    echo "Homebrew is required to install missing tools automatically. Install Homebrew, then rerun this installer." >&2
    return 1
  fi
}

install_brew_formula() {
  local command_name="$1"
  local package_name="$2"
  local display_name="$3"

  if has_command "$command_name"; then
    echo "$display_name is already installed."
    return 0
  fi

  require_brew
  echo "Installing $display_name with Homebrew..."
  brew install "$package_name"

  if has_command "$command_name"; then
    echo "$display_name installed."
    return 0
  fi

  echo "$display_name install command finished, but $command_name is still not in PATH. Open a new terminal, then rerun this installer." >&2
  return 1
}

install_brew_cask() {
  local command_name="$1"
  local package_name="$2"
  local display_name="$3"

  if has_command "$command_name"; then
    echo "$display_name is already installed."
    return 0
  fi

  require_brew
  echo "Installing $display_name with Homebrew..."
  brew install --cask "$package_name"

  if has_command "$command_name"; then
    echo "$display_name installed."
    return 0
  fi

  echo "$display_name install command finished, but $command_name is still not in PATH. Open a new terminal, then rerun this installer." >&2
  return 1
}

complete_dependency_setup() {
  install_brew_formula npx node "Node.js/npx"

  if has_command lark-cli; then
    echo "lark-cli is already installed."
  else
    echo "Installing lark-cli..."
    npx @larksuite/cli@latest install
    if ! has_command lark-cli; then
      echo "lark-cli install command finished, but lark-cli is still not in PATH. Open a new terminal, then rerun this installer." >&2
      return 1
    fi
    echo "lark-cli installed."
  fi

  install_brew_formula ffmpeg ffmpeg "ffmpeg"
  install_brew_cask pwsh powershell "PowerShell 7"
}

complete_feishu_auth() {
  if ! has_command lark-cli; then
    echo "lark-cli is missing, so Feishu authorization cannot start." >&2
    return 1
  fi

  echo ""
  echo "Checking lark-cli configuration..."
  if ! lark-cli auth status >/dev/null 2>&1; then
    echo "lark-cli is not configured yet. Complete the browser/app setup that opens next."
    lark-cli config init --new
  else
    echo "lark-cli already has an auth profile."
  fi

  echo ""
  echo "Starting Feishu authorization. Complete it with your own Feishu account in the browser."
  lark-cli auth login --scope "$REQUIRED_SCOPES"

  echo ""
  echo "Verifying lark-cli..."
  lark-cli doctor
  lark-cli auth status
}

get_skill_version() {
  local skill_file="$1/SKILL.md"
  if [ ! -f "$skill_file" ]; then
    echo "unknown"
    return
  fi
  local version
  version="$(grep -E '^version:[[:space:]]*' "$skill_file" | head -n 1 | sed -E 's/^version:[[:space:]]*//')"
  if [ -z "$version" ]; then
    echo "unknown"
  else
    echo "$version"
  fi
}

if [ ! -f "$SKILL_SOURCE/SKILL.md" ]; then
  echo "Cannot find SKILL.md in the parent folder of this installer." >&2
  exit 1
fi

if [ "$SKILL_NAME" != "feishu-minutes-transcript" ]; then
  echo "This installer only supports feishu-minutes-transcript, got: $SKILL_NAME" >&2
  exit 1
fi

mkdir -p "$SKILL_DIR"
WAS_INSTALLED=0
if [ -d "$TARGET_DIR" ]; then
  WAS_INSTALLED=1
fi
rm -rf "$TARGET_DIR"
cp -R "$SKILL_SOURCE" "$TARGET_DIR"

INSTALLED_VERSION="$(get_skill_version "$TARGET_DIR")"
if [ "$WAS_INSTALLED" -eq 1 ]; then
  echo "Updated only this skill:"
else
  echo "Installed only this skill:"
fi
echo "$TARGET_DIR"
echo "Version: $INSTALLED_VERSION"
echo ""

if [ "$SKIP_DEPENDENCY_SETUP" -eq 0 ]; then
  complete_dependency_setup
else
  echo "Dependency setup skipped by --skip-dependency-setup."
fi

if [ "$SKIP_FEISHU_AUTH" -eq 0 ]; then
  complete_feishu_auth
else
  echo "Feishu authorization skipped by --skip-feishu-auth."
fi

echo ""
if [ "$SKIP_DEPENDENCY_SETUP" -ne 0 ] || [ "$SKIP_FEISHU_AUTH" -ne 0 ]; then
  echo "Skill installation is complete, but dependency setup or Feishu authorization was skipped."
  echo "Complete the skipped steps before restarting Codex or Claude Code."
else
  echo "Installation, dependencies, and Feishu authorization are complete."
  echo "Now restart Codex or Claude Code so it reloads this skill."
fi
echo ""
echo "This installer does not install any other skills."
echo "To update an existing installation later, rerun this same installer."
