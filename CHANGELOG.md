# Changelog

## 2026-06-19

### Changed
- Replaced three separate skills (`akidoc-rules`, `akidoc-flow-audit`, `akidoc-techbiz-optimizer`) with a single unified smart-router skill `akirule`.
- `akirule` uses a 3-tier loading strategy: core rules always embedded, additional rules and methods read on demand when task signals match.
- Renamed `SKILL-flow-audit.md` and `SKILL-techbiz-optimizer.md` to `METHOD-flow-audit.md` and `METHOD-techbiz-optimizer.md` to accurately reflect their role as reference frameworks, not skill definitions.
- `install.sh` now removes old skill directories and stale `skillOverrides` entries on upgrade.
- Hardened `install.sh` settings.json writer: `isinstance` guards on all dict/list fields, fixed idempotent read-permission logic.
- Updated global `~/.claude/CLAUDE.md` guidance to reflect `akirule` and the new file naming convention.
- `README.md` expanded to cover architecture, 3-tier router mechanism, file naming conventions, and how Claude Code skills work in this context.
- `CLAUDE.md` (repo root) documents the `RULE-*` / `METHOD-*` naming convention and consistency requirements.

### Added
- Pre-flight inspection in `install.sh` reports old skills that will be deleted and stale `skillOverrides` that will be removed.
- `payload/index.md` documents the Core / On-signal / Method file groupings.

### Removed
- `PLAN.md` removed after completion.
- Empty `scripts/` directory removed.

---

## 2026-05-22

Initial public release.

### Added
- `payload/` rule corpus: `RULE-agent-behavior.md`, `RULE-coding.md`, `RULE-content-write.md`, `RULE-docs.md`, `RULE-stack-akiNuxtCf.md`, `SKILL-flow-audit.md`, `SKILL-techbiz-optimizer.md`.
- Three Claude Code skills: `akidoc-rules`, `akidoc-flow-audit`, `akidoc-techbiz-optimizer`.
- `install.sh` with pre-flight inspection, confirmation prompt, timestamped backups, and `settings.json` management.
- Global `~/.claude/CLAUDE.md` guidance block.
