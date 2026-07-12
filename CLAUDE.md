# AkiClaudeDoc

This repository is the source of truth for Aki's reusable Claude Code rule and skill baseline.

## Project role

AkiClaudeDoc packages Markdown rules, Claude Code skills, global Claude guidance, and installer fragments so the same baseline can be installed into another user's local Claude environment.

Treat this repository as a standards distribution project, not as an application repository.

## Source of truth

- Edit canonical rule and skill content in this Git repository first.
- `payload/` contains the packaged Aki rule corpus installed to `~/.aki/claudedoc`.
- `claude/` contains Claude Code runtime assets installed to `~/.claude`.
- `README.md` documents the architecture, file conventions, and install flow for both humans and agents. Read it when you need to understand the full layout or how the smart router works. It is not an agent instruction file — it does not override this CLAUDE.md.

## File naming conventions

Files in `payload/` follow this convention:
- `RULE-*.md` — constraint rules: behavior, coding, content, stack requirements.
- `METHOD-*.md` — analytical frameworks loaded on demand for auditing or optimization tasks.

Do not rename existing files or introduce new top-level prefixes without updating `payload/index.md`, `claude/skills/akirule/SKILL.md`, `claude/CLAUDE.md`, `README.md`, and `install.sh` consistently.

## Required operating rules

- Use the `akirule` skill before editing durable project files, rule files, skill files, installer behavior, or project instructions.
- Keep project instructions short and bind them to the current repository instead of duplicating the full shared rule corpus.
- Changes to rules, skills, install targets, or generated Claude configuration can affect many downstream environments; clarify scope and tradeoffs before broad changes unless the requested edit is explicit.
- Preserve the separation between packaged source files in this repository and installed runtime files under `~/.aki/claudedoc` or `~/.claude`.
- Any change to `payload/*` or `claude/skills/*` that adds/removes a topic, changes what a file covers, or changes install behavior must also update `README.md` (file manifest / "What you get" / layout sections) wherever the change makes it stale. `claude/skills/akihelp/SKILL.md` reads live installed state at runtime and never needs manual updates for content — only touch it if the *mechanism* of introducing the system changes. Always update `CHANGELOG.md` for every change to `payload/` or `claude/`.

## Non-goals

This project is not an auto-updater, daemon, package manager, application framework, or control plane.

Do not add runtime automation, background services, unrelated personal Claude settings, secrets, model-router tokens, localhost project permissions, or bundled large reference corpora unless explicitly requested.
