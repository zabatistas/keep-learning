# Vibe-Learn: Portable Learning-While-Vibe-Coding Kit

Turn vibe coding into guided engineering mastery across **Antigravity**, **Claude Code** and **Cursor**.
Designed for engineers tackling tickets involving unfamiliar network/domain protocols, unfamiliar codebase architecture, or tricky concurrency primitives.

---

## Quick Start for Any Developer (1-Command Install)

Clone this repository anywhere on your machine and run `./install.sh`:

```bash
git clone <your-repo-url> vibe-learn
cd vibe-learn

# Install Antigravity plugin + initialize your personal Learning Hub:
./install.sh

# Also install the Claude Code plugin (needs the `claude` CLI on PATH):
./install.sh --claude-code

# Or choose a custom Learning Hub directory & install rules into a Cursor repo:
./install.sh --hub-dir ~/my-learnings --cursor-repo ~/projects/my-service
```

### Windows

The installer needs **Git for Windows** (it ships Git Bash). From PowerShell, use the wrapper, which takes the same options:

```powershell
.\install.ps1
.\install.ps1 --claude-code --hub-dir C:\Users\me\my-learnings
```

Or run `./install.sh` directly inside a Git Bash window. Don't run it with plain `bash` from PowerShell/cmd: that usually starts **WSL**, which installs into the Linux home directory instead of your Windows one. On Windows the saved hub path and dashboard link use the `C:/Users/...` form so agents, editors and browsers can open them.

### Claude Code

This repo is also a Claude Code plugin marketplace (`.claude-plugin/marketplace.json`). Without the installer, inside Claude Code run:

```
/plugin marketplace add <path-or-github-repo-of-this-clone>
/plugin install vibe-learn@keep-learning
```

To try it without installing: `claude --plugin-dir /path/to/this/clone`.

Claude Code plugins have no `rules/` directory, so a `SessionStart` hook (`hooks/hooks.json`) loads `rules/AGENTS.md` into context at the start of every session.

---

## How the Portable Learning Hub Works (`<LEARNING_HUB_DIR>`)

No user paths are hardcoded anywhere in the rules or skills. The agent dynamically resolves `<LEARNING_HUB_DIR>` in this priority order:

1. **`$VIBE_LEARN_HUB`** environment variable (if set)
2. **`~/.config/vibe-learn/hub_path`** (automatically created by `./install.sh`, pointing to `<cloned-repo>/learnings` by default)
3. **`<workspace-root>/.vibe-learn/learnings`** (if your team creates a `.vibe-learn` folder inside a project repo to check shared learnings into git!)
4. **`~/.vibe-learn/learnings`** (zero-config fallback on any OS)

Every learning session is saved under `<LEARNING_HUB_DIR>/<YYYY-MM-DD>-<slug>/` and indexed using **100% relative paths** (`./<YYYY-MM-DD>-<slug>/...`) in:
- **`<LEARNING_HUB_DIR>/index.html`** — Searchable, tag-filtered browser dashboard
- **`<LEARNING_HUB_DIR>/INDEX.md`** — Markdown table & concept index

Because all links inside `learnings/` are relative, you can move the directory, share it as a zip, or publish it to GitHub Pages / GitLab Pages with zero broken links.

---

## What's Included

- **`rules/AGENTS.md`**: Always-On Glass-Box Coding rule (adds concise 2–4 bullet **Learning Anchors** and **"Delete-This-Line" failure modes** whenever protocol or concurrency code is written).
- **`skills/vibe-learn/`**: The 4-Phase workflow (Pre-Flight Brief + Interactive HTML Sandbox -> Glass-Box Coding -> Background `shadow-tutor` -> PR Defense Check) plus `scripts/resolve-hub.sh` and `resources/dashboard-template.html`.
- **`agents/shadow-tutor.md`**: Background technical mentor subagent that builds line-linked `LEARNING_GUIDE.md` guides and flashcards from your `git diff`.
- **`.claude-plugin/`** + **`hooks/hooks.json`**: Claude Code plugin manifest, local marketplace, and the `SessionStart` hook that loads the always-on rule.
- **`.cursor/rules/*.mdc`**: Drop-in Cursor IDE rules (`vibe-mentor.mdc` and `vibe-learn-workflow.mdc`).
- **`examples/telco-magicsock/`**: Reference Go implementation & concurrency test suite for Ticket `TELCO-402` (Tailscale MagicSock Direct-UDP to DERP Relay fallback).
