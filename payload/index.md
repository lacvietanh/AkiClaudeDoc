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
| `RULE-design-core.md` | Contextual (high-sensitivity) | Universal pattern philosophy: SSoT, Rule of Three, SRP "and"-test, OCP, composition, module boundaries, name-by-role, anti-patch. Sharpens RULE-coding; applies to every project type — load eagerly on any structural/decomposition decision |
| `RULE-docs.md` | Contextual | Docs structure (incl. mandatory `docs/biz/` backbone), plan lifecycle, doc-sync behavior |
| `RULE-content-write.md` | Contextual | UI copy, semantic stability, writing style, i18n |
| `RULE-stack-akiNuxtCf.md` | Contextual | Nuxt/Vue/Cloudflare Pages/Workers, Tailwind, i18n, canonical component names, state (useState-first), build & TypeScript, admin layout isolation, dev workflow scripts (killport/D1), layout chrome (breadcrumb/scroll-to-top), deploy verification after push |
| `RULE-stack-tauri.md` | Contextual | Tauri v2 + Rust: absolute never-block-the-UI rule for any command running a subprocess/network call (`spawn_blocking`), titlebar boundary, version SSOT, IPC capability silent-fail, serde default for persisted JSON, cfg(target_os) scoping, subprocess PATH-resolution cold-start race |
| `RULE-ui-pattern.md` | Contextual | Frontend enforcement of design-core: 4-tier class taxonomy, design tokens, arbitrary-value policy, atomic structure, variant API, UI audit/refactor playbook |
| `RULE-seo.md` | Contextual | Meta limits, schema.org matrix, robots, sitemap, OG, AI visibility, entity linking |
| `RULE-release.md` | Contextual | CHANGELOG.md mandatory in every project, release notes vs changelog split, releases.json (web-only), release vs deploy boundary, cold-start version reconstruction, severity-driven bump, audit mode |
| `RULE-db-design.md` | Contextual | Immutability & Event Sourcing, 1NF, Bounded Context (DDD), flat-query discipline — load when designing schema/migration/DB refactor |
| `METHOD-flow-audit.md` | Analytical | Flow integrity audit method |
| `METHOD-deep-think.md` | Analytical | Deep-think brain: goal excavation, first principles, critique, conditional techbiz lens; passive via akirule, active via /akithink |

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
