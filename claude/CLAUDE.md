# Aki global Claude Code guidance

Keep global context small. Prefer current project files and runtime output over stale docs or memory.

## Shared Aki rule source

Aki's shared rule corpus lives at `~/.aki/claudedoc`.

The `akirule` skill is always active in Aki projects. It handles all routing: core rules load automatically on every task; contextual and analytical rules load on signal match with high sensitivity; full load is available on explicit command. See `~/.claude/skills/akirule/SKILL.md` for the complete routing spec and signal list.

**IMPORTANT — editing shared rules:**
The installed claudedoc directory is a **deployed copy**, not the source of truth.
To change a shared rule:
1. Edit from the **source AkiClaudeDoc project** (location varies per machine — ask the user if unknown).
2. Run the install script from that project to propagate changes to the installed copy.

Never edit the installed claudedoc files directly — changes will be silently overwritten on the next install.

## ref-ECC guard

`~/.aki/claudedoc/ref-ECC` is intentionally very large. Do not scan, summarize, or bulk-load it by default.

Only use `ref-ECC` when the user explicitly asks for it or when a task has a specific, narrow need for that reference corpus. Prefer targeted file/path lookup over broad search to avoid context bloat.
