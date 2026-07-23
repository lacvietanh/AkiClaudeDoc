# Aki global Claude Code guidance

Keep global context small. Prefer current project files and runtime output over stale docs or memory.

## Shared Aki rule source

Aki's shared rule corpus lives at `~/.aki/claudedoc`.

The `akirule` skill is always active in Aki projects. It handles all routing: core rules load automatically on every task; contextual and analytical rules load on signal match with high sensitivity; full load is available on explicit command. See `~/.claude/skills/akirule/SKILL.md` for the complete routing spec and signal list.

**IMPORTANT — editing shared rules:** The installed claudedoc directory is a **deployed copy**, not the source of truth. To change a shared rule:
1. Find the source repo: its absolute path on this machine is recorded in `~/.aki/claudedoc/.source-repo`, written by `install.sh` on every install. Read that file — do not guess a location, and do not ask the user for something already recorded. Ask only if the recorded path no longer exists.
2. Edit under `<source-repo>/payload/` (shared rule corpus) or `<source-repo>/claude/` (Claude runtime assets: global guidance, skills, hooks).
3. **Read `<source-repo>/CLAUDE.md` before editing.** It carries that repo's own operating rules — which files must be updated together (`payload/index.md`, `claude/skills/akirule/SKILL.md`, `README.md`, `CHANGELOG.md`), file-naming conventions, and non-goals. This step matters most when the request arrives from *another* project's working directory, where that file is not auto-loaded.
4. Run `bash <source-repo>/install.sh` to propagate changes to the installed copy.

Never edit the installed claudedoc files directly — changes will be silently overwritten on the next install.

## Named local corpora

Doc corpora that live outside any single project are often referred to by short name in conversation (e.g. "UNIDOC", "the standards doc"). Their names, paths, and usage notes are **machine-specific**, so they are recorded in `~/.claude/CLAUDE.local.md` — not in this shared file. When the user names a corpus you cannot resolve, read that file before searching the filesystem or asking.

## ref-ECC guard

`~/.aki/claudedoc/ref-ECC` is intentionally very large. Do not scan, summarize, or bulk-load it by default.

Only use `ref-ECC` when the user explicitly asks for it or when a task has a specific, narrow need for that reference corpus. Prefer targeted file/path lookup over broad search to avoid context bloat.
