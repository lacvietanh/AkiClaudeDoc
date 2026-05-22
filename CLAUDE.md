# AkiClaudeDoc

This repository is the source of truth for Aki's reusable Claude Code rule and skill baseline.

## Project role

AkiClaudeDoc packages Markdown rules, Claude Code skills, global Claude guidance, and installer fragments so the same baseline can be installed into another user's local Claude environment.

Treat this repository as a standards distribution project, not as an application repository.

## Source of truth

- Edit canonical rule and skill content in this Git repository first.
- `payload/` contains the packaged Aki rule corpus installed to `~/.aki/claudedoc`.
- `claude/` contains Claude Code runtime assets installed to `~/.claude`.
- `README.md` is public-facing source material for explanation, quickstart, and docs-site content; do not rely on it as the full agent instruction source.

## Required operating rules

- Use the `akidoc-rules` skill before editing durable project files, rule files, skill files, installer behavior, or project instructions.
- Keep project instructions short and bind them to the current repository instead of duplicating the full shared rule corpus.
- Changes to rules, skills, install targets, or generated Claude configuration can affect many downstream environments; clarify scope and tradeoffs before broad changes unless the requested edit is explicit.
- Preserve the separation between packaged source files in this repository and installed runtime files under `~/.aki/claudedoc` or `~/.claude`.

## Non-goals

This project is not an auto-updater, daemon, package manager, application framework, or control plane.

Do not add runtime automation, background services, unrelated personal Claude settings, secrets, model-router tokens, localhost project permissions, or bundled large reference corpora unless explicitly requested.
