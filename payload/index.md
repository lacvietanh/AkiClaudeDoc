# Aki-RULE

Shared source-of-truth rules for Aki projects.

## Purpose
Provides reusable rules for agent behavior, coding, content, docs, and stack-specific work.
Project `CLAUDE.md` files bind these shared rules to a specific project.

## File manifest

| File | Tier | Purpose |
|------|------|---------|
| `RULE-agent-behavior.md` | Core | Response language, scope discipline, verification, decision boundaries |
| `RULE-coding.md` | Core | Philosophy, source-of-truth, error handling, security |
| `RULE-docs.md` | Contextual | Docs structure, plan lifecycle, doc-sync behavior |
| `RULE-content-write.md` | Contextual | UI copy, semantic stability, writing style, i18n |
| `RULE-stack-akiNuxtCf.md` | Contextual | Nuxt/Vue/Cloudflare Pages/Workers, Tailwind, i18n, layout chrome (breadcrumb/scroll-to-top) |
| `RULE-seo.md` | Contextual | Meta limits, schema.org matrix, robots, sitemap, OG, AI visibility, entity linking |
| `RULE-release.md` | Contextual | Release notes vs changelog split, bilingual releases.json, semver bump discipline |
| `METHOD-flow-audit.md` | Analytical | Flow integrity audit method |
| `METHOD-techbiz-optimizer.md` | Analytical | First-principles scope and value optimizer |

Routing logic (which file loads when) is defined in `~/.claude/skills/akirule/SKILL.md`.

## Precedence
When rules conflict, use this order:
1. Current local source code, runtime output, and build output
2. User's explicit instruction in the current conversation
3. Project `CLAUDE.md`
4. Aki-RULE shared files
5. Older docs, memory, or prior conversation context

Project `CLAUDE.md` may add project facts and stricter constraints.
It must not silently weaken core safety, verification, or source-of-truth rules.

## Project binding
Each project should keep a root `CLAUDE.md` that:
- references the akirule skill as the rule loader (see SKILL.md for signal list)
- defines project-specific facts and overrides
- stays short
- avoids duplicating shared rules

## Change policy
Aki-RULE changes affect many projects.
Before changing these files, clarify the intended rule, scope, and tradeoff unless the user explicitly requests the exact change.
