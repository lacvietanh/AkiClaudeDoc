---
name: akirule
description: Aki's unified rule router. Loads core rules on every task and reads additional rule and skill files immediately when task signals match.
user-invocable: false
---

## Core rules (always loaded)

@~/.aki/claudedoc/index.md
@~/.aki/claudedoc/RULE-agent-behavior.md
@~/.aki/claudedoc/RULE-coding.md

---

## Dynamic rules — read the file NOW when any signal matches

### RULE-docs.md
Read `~/.aki/claudedoc/RULE-docs.md` NOW if the task involves any of:
- Editing or creating `docs/**`, `CLAUDE.md`, `README.md`, `PLAN.md`, or project instruction files
- Code that is complex, architectural, or references a `docs/feat/` or `docs/arch/` path — doc sync obligation may apply
- A complex function or flow where documentation coverage should be verified or added
- Creating, moving, or completing plan files under `docs/plan/`
- Deciding whether a flow or architecture diagram (Mermaid) is warranted
- Any question about docs structure, index, or discoverability

### RULE-content-write.md
Read `~/.aki/claudedoc/RULE-content-write.md` NOW if the task involves any of:
- UI text: button labels, field labels, headings, error messages, empty states, tooltips
- i18n locale files, or introducing / renaming translation keys
- Meta titles, meta descriptions, OG text, JSON-LD text fields, FAQ answers
- Article copy, landing page content, or any product-facing prose
- Renaming or redefining a concept or term used across the product (semantic stability)
- Content that appears across multiple channels: visible UI, SERP snippet, schema bots

### RULE-stack-akiNuxtCf.md
**Default: load for any Aki project context.**
Read `~/.aki/claudedoc/RULE-stack-akiNuxtCf.md` NOW if the task involves any of:
- Nuxt, Vue, Cloudflare Pages/Workers, or the Aki frontend stack
- Components, composables, pages, layouts, plugins, or middleware
- Routing, `wrangler.toml`, Tailwind classes, i18n config, or SEO helpers
- Skip only when the task is provably stack-independent (plain markdown, isolated scripts, pure config unrelated to the stack)

---

## Analytical skills — read the file NOW when task has analytical depth

### METHOD-flow-audit.md
Read `~/.aki/claudedoc/METHOD-flow-audit.md` NOW if the task involves any of:
- Refactoring, restructuring, or simplifying a function, component, or flow
- A bug fix that spans multiple files or requires tracing a chain of cause and effect
- Code described as fragile, over-guarded, hard to follow, or with accumulated conditionals
- A user journey, multi-step coordination, async chain, or state machine
- Questions such as "why is this complicated", "is this flow correct", or "how should this be restructured"
- Repeated guard patterns, fallbacks, or ownership / timing confusion

### METHOD-techbiz-optimizer.md
Read `~/.aki/claudedoc/METHOD-techbiz-optimizer.md` NOW if the task involves any of:
- Introducing a new feature or extending existing scope
- "Should we do X", "what's the simplest way", "is this worth it", or explicit tradeoff framing
- Architecture or tooling decisions that appear before evidence of need
- Unclear or contested effort/value ratio
- Signals of scope creep, rising complexity, or premature automation

---

## Full load override
If the user includes `[load full]` or `[nạp full]` or explicitly requests loading all rules:
Read every file matching `RULE-*.md` and `METHOD-*.md` in `~/.aki/claudedoc/` — excluding `ref-ECC/`.
