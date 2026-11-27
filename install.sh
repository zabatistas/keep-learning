#!/usr/bin/env bash
# Universal installer for Vibe-Learn (Antigravity Plugin + Claude Code Plugin + Cursor Rules + Portable Learning Hub)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_HUB_DIR="$REPO_ROOT/learnings"
CURSOR_TARGET=""
CLAUDE_CODE=0
HUB_DIR="$DEFAULT_HUB_DIR"

# Windows (Git Bash / MSYS / Cygwin): the shell uses /c/Users/... paths, while native tools
# (the agent's file tools, editors, browsers) need C:/Users/.... cygpath converts both ways;
# on Linux/macOS it does not exist and paths pass through unchanged.
to_shell_path()  { if command -v cygpath >/dev/null 2>&1; then cygpath -u "$1"; else printf '%s\n' "$1"; fi; }
to_native_path() { if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else printf '%s\n' "$1"; fi; }
to_file_url() {
  local p
  p="$(to_native_path "$1")"
  case "$p" in
    /*) printf 'file://%s\n' "$p" ;;   # Linux/macOS: file:///home/...
    *)  printf 'file:///%s\n' "$p" ;;  # Windows:     file:///C:/Users/...
  esac
}

usage() {
  cat <<EOF
Usage: ./install.sh [options]

Options:
  --hub-dir <path>         Where to store your Central Learning Hub (default: $DEFAULT_HUB_DIR)
  --cursor-repo <path>     Also install Cursor (.cursor/rules/*.mdc) into the target git repo
  --claude-code            Also install the Claude Code plugin (requires the 'claude' CLI)
  -h, --help               Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --hub-dir)
      HUB_DIR="$(realpath -m "$(to_shell_path "$2")")"
      shift 2
      ;;
    --cursor-repo)
      CURSOR_TARGET="$(realpath -m "$(to_shell_path "$2")")"
      shift 2
      ;;
    --claude-code)
      CLAUDE_CODE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

# 1. Record the user's chosen Learning Hub path in ~/.config/vibe-learn/hub_path
mkdir -p "$HOME/.config/vibe-learn"
# Store the native form so agents on Windows can open it with their own file tools
to_native_path "$HUB_DIR" > "$HOME/.config/vibe-learn/hub_path"
echo "[1/4] Configured Central Learning Hub path -> $(to_native_path "$HUB_DIR")"
echo "      (Saved pointer in ~/.config/vibe-learn/hub_path)"

# 2. Initialize the Learning Hub if index.html / INDEX.md don't exist yet
chmod +x "$REPO_ROOT/skills/vibe-learn/scripts/resolve-hub.sh"
"$REPO_ROOT/skills/vibe-learn/scripts/resolve-hub.sh" >/dev/null

# 3. Install into Antigravity global plugins (~/.gemini/config/plugins/vibe-learn)
AGY_PLUGIN_DIR="$HOME/.gemini/config/plugins/vibe-learn"
mkdir -p "$AGY_PLUGIN_DIR"
cp -r "$REPO_ROOT/plugin.json" "$REPO_ROOT/README.md" "$REPO_ROOT/assets" "$REPO_ROOT/rules" "$REPO_ROOT/skills" "$REPO_ROOT/agents" "$AGY_PLUGIN_DIR/"
chmod +x "$AGY_PLUGIN_DIR/skills/vibe-learn/scripts/resolve-hub.sh"
echo "[2/4] Installed Antigravity plugin -> $AGY_PLUGIN_DIR"

# 4. Optional: Install the Claude Code plugin via this repo's local marketplace (.claude-plugin/marketplace.json)
if [[ "$CLAUDE_CODE" -eq 1 ]]; then
  if command -v claude >/dev/null 2>&1; then
    claude plugin marketplace add "$REPO_ROOT"
    claude plugin install vibe-learn@keep-learning
    echo "[3/4] Installed Claude Code plugin -> vibe-learn@keep-learning"
  else
    echo "[3/4] Skipped Claude Code: 'claude' CLI not found on PATH."
    echo "      Inside Claude Code you can run instead:"
    echo "        /plugin marketplace add $REPO_ROOT"
    echo "        /plugin install vibe-learn@keep-learning"
  fi
else
  echo "[3/4] Tip: To enable in Claude Code, run:"
  echo "      $REPO_ROOT/install.sh --claude-code"
fi

# 5. Optional: Install into a Cursor project repo if --cursor-repo was passed
if [[ -n "$CURSOR_TARGET" ]]; then
  mkdir -p "$CURSOR_TARGET/.cursor/rules"
  cp "$REPO_ROOT/.cursor/rules/vibe-mentor.mdc" "$CURSOR_TARGET/.cursor/rules/"
  cp "$REPO_ROOT/.cursor/rules/vibe-learn-workflow.mdc" "$CURSOR_TARGET/.cursor/rules/"
  echo "[4/4] Installed Cursor rules -> $CURSOR_TARGET/.cursor/rules/"
else
  echo "[4/4] Tip: To enable in any Cursor repository, run:"
  echo "      $REPO_ROOT/install.sh --cursor-repo /path/to/your/project"
fi

echo ""
echo "Done! Open your Learning Hub dashboard anytime at:"
echo "  $(to_file_url "$HUB_DIR/index.html")"
