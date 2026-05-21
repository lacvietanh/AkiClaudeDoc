# Aki global Claude Code guidance

Keep global context small. Prefer current project files and runtime output over stale docs or memory.

## Shared Aki rule source

Aki's shared rule corpus lives at `~/.aki/claudedoc`.

Use the `akidoc-rules` skill when working in Aki projects, editing durable project files, creating/editing project instructions, or when the user asks to follow Aki rules.

The skill loads these core rules:
- `~/.aki/claudedoc/index.md` — rule index, precedence, and project binding policy
- `~/.aki/claudedoc/RULE-agent-behavior.md` — response language, scope discipline, verification, decision boundaries
- `~/.aki/claudedoc/RULE-coding.md` — coding philosophy, source-of-truth, verification, error handling, security
- `~/.aki/claudedoc/RULE-docs.md` — documentation structure, index, plan lifecycle, docs behavior
- `~/.aki/claudedoc/RULE-content-write.md` — UI copy, semantic stability, writing style, i18n usage

Load stack-specific rules only when relevant:
- `~/.aki/claudedoc/RULE-stack-akiNuxtCf.md` — load for Nuxt, Vue, Cloudflare Pages/Workers, Tailwind, i18n, SEO, or Aki Nuxt/Cloudflare stack work

## Shared Aki skills

Use these global skills when their trigger matches:
- `akidoc-rules` — load shared Aki rules
- `akidoc-flow-audit` — audit fragile workflows, repeated guards, state drift, or awkward flows
- `akidoc-techbiz-optimizer` — reduce over-scoped technical/business work to the smallest high-value next step

## ref-ECC guard

`~/.aki/claudedoc/ref-ECC` is intentionally very large. Do not scan, summarize, or bulk-load it by default.

Only use `ref-ECC` when the user explicitly asks for it or when a task has a specific, narrow need for that reference corpus. Prefer targeted file/path lookup over broad search to avoid context bloat.
