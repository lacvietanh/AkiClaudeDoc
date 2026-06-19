# Aki global Claude Code guidance

Keep global context small. Prefer current project files and runtime output over stale docs or memory.

## Shared Aki rule source

Aki's shared rule corpus lives at `~/.aki/claudedoc`.

The `akirule` skill is always active in Aki projects. It loads core rules automatically and reads additional rule and skill files on demand based on task signals. See the skill definition for the full smart-router spec.

Core rules always loaded:
- `~/.aki/claudedoc/index.md` — rule index, precedence, and project binding policy
- `~/.aki/claudedoc/RULE-agent-behavior.md` — response language, scope discipline, verification, decision boundaries
- `~/.aki/claudedoc/RULE-coding.md` — coding philosophy, source-of-truth, verification, error handling, security

Additional rules loaded on signal:
- `~/.aki/claudedoc/RULE-docs.md` — docs structure, index, plan lifecycle, doc-sync behavior
- `~/.aki/claudedoc/RULE-content-write.md` — UI copy, semantic stability, writing style, i18n usage
- `~/.aki/claudedoc/RULE-stack-akiNuxtCf.md` — Nuxt, Vue, Cloudflare Pages/Workers, Tailwind, i18n, SEO
- `~/.aki/claudedoc/METHOD-flow-audit.md` — flow integrity audit method
- `~/.aki/claudedoc/METHOD-techbiz-optimizer.md` — first-principles scope and value optimizer

## ref-ECC guard

`~/.aki/claudedoc/ref-ECC` is intentionally very large. Do not scan, summarize, or bulk-load it by default.

Only use `ref-ECC` when the user explicitly asks for it or when a task has a specific, narrow need for that reference corpus. Prefer targeted file/path lookup over broad search to avoid context bloat.
