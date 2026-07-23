# Aki-RULE

Shared source-of-truth rules for Aki projects.

## Purpose
Provides reusable rules for agent behavior, coding, content, docs, and stack-specific work. Project `CLAUDE.md` files bind these shared rules to a specific project.

## File manifest

| File | Topic | Tier | Loại | Purpose |
|------|-------|------|------|---------|
| `RULE-agent-behavior.md` | `agent` | Core | public | Response language, communication-vs-task discrimination (a question is not a request), report-for-fast-reorientation (density, conclusion-first, glossed references), scope discipline, verification, decision boundaries, no model-credit trailers in git artifacts |
| `RULE-coding.md` | `coding` | Core | public | Philosophy, source-of-truth, verification (narrowest tool; app runs are user-triggered; runtime-only risk that can't run → "unverified" handoff, never a false "Done"), error handling, security |
| `RULE-design-core.md` | `design` | Contextual (high-sensitivity) | public | Universal pattern philosophy: SSoT, Rule of Three, SRP "and"-test, OCP, composition, module boundaries, name-by-role, anti-patch. Sharpens RULE-coding; applies to every project type — load eagerly on any structural/decomposition decision |
| `RULE-docs.md` | `docs` | Contextual | public | Docs structure (incl. mandatory `docs/biz/` backbone), plan lifecycle, doc-sync behavior |
| `RULE-content-write.md` | `content` | Contextual | public | UI copy, semantic stability, writing style, i18n |
| `RULE-stack-akiNuxtCf.md` | `stack` | Contextual | **mixed** — group C is ⟨Aki⟩ | Nuxt/Vue/Cloudflare Pages/Workers, Tailwind, i18n, canonical component names, state (useState-first), build & TypeScript, admin layout isolation, dev workflow scripts (killport/D1), layout chrome (breadcrumb/scroll-to-top), layout width (single source of truth in the layout, pages/apps never redeclare max-w), deploy verification after push |
| `RULE-stack-tauri.md` | `tauri` | Contextual | public | Tauri v2 + Rust: absolute never-block-the-UI rule for any command running a subprocess/network call (`spawn_blocking`), titlebar boundary, version SSOT, IPC capability silent-fail, serde default for persisted JSON, cfg(target_os) scoping, subprocess PATH-resolution cold-start race, salient target context (ship platform) surfaced in the project CLAUDE.md |
| `RULE-ui-pattern.md` | `ui` | Contextual | public | Frontend enforcement of design-core: 4-tier class taxonomy, design tokens, arbitrary-value policy, atomic structure, variant API, UI audit/refactor playbook |
| `RULE-seo.md` | `seo` | Contextual | **mixed** — group C is ⟨Aki⟩ | Meta limits, schema.org matrix, robots, sitemap, OG, AI visibility, entity linking |
| `RULE-release.md` | `release` | Contextual | **mixed** — group C is ⟨Aki⟩ | CHANGELOG.md mandatory in every project, release notes vs changelog split, releases.json (web-only), release vs deploy boundary, cold-start version reconstruction, severity-driven bump, version minted only at the release event (`[Unreleased]` buffer, no local drift ahead of production), audit mode |
| `RULE-db-design.md` | `db` | Contextual | public | Immutability & Event Sourcing, 1NF, Bounded Context (DDD), flat-query discipline — load when designing schema/migration/DB refactor |
| `METHOD-flow-audit.md` | `flow` | Analytical | public | Flow integrity audit method |
| `METHOD-deep-think.md` | `think` | Analytical | public | Deep-think brain: goal excavation, first principles, critique, conditional techbiz lens; passive via akirule, active via /akithink |

Routing logic (which file loads when) is defined in `~/.claude/skills/akirule/SKILL.md`.

## Addressing scheme — `topic.A1`

Every file is internally organized into groups **A/B/C** (a topic's broad themes) and numbered items **1/2/3…** within each group — e.g. `coding.B2` (Changing existing code), `stack.C1` (Canonical component names). `topic` is the filename with its `RULE-`/`METHOD-` prefix dropped. This is purely a recall/reference convention — it does not change routing (still governed by `akirule/SKILL.md`) and does not rename any file.

**`⟨Aki⟩`** marks a group (always the last group in its file) that is specific to Aki's own AkiNuxtCf ecosystem rather than universal — currently `seo.C`, `release.C`, `stack.C`. These groups stay in this public repo (auto-load is more useful to Aki, the heaviest user, than a clean public/ private split), but are logically separable if a stripped public export is ever needed. Everything outside a `⟨Aki⟩` group is universal and applies to any project on the matching stack.

| Topic | Groups |
|---|---|
| `agent` | A Giao tiếp · B Kỷ luật phạm vi & quyết định · C File & bộ nhớ |
| `coding` | A Triết lý & nguồn sự thật · B Chất lượng & sửa code · C An toàn runtime |
| `design` | A 8 định luật · B Phân rã & quét rừng · C Chốt |
| `db` | A Nguyên tắc dữ liệu · B Unicode |
| `docs` | A Cấu trúc topic · B Vòng đời & đồng bộ |
| `content` | A Nguyên tắc nội dung · B Văn phong & pattern · C Tách bạch |
| `seo` | A Meta & cấu trúc · B Hiển thị AI & entity · **C ⟨Aki⟩ API & tooling stack** |
| `release` | A Versioning core · B Xác định & audit · **C ⟨Aki⟩ Web release artifacts** |
| `stack` | A Cloudflare & TypeScript nền · B Render · i18n · Vue patterns · **C ⟨Aki⟩ Quy ước hệ sinh thái** |
| `tauri` | A Không block UI · B Boundary & config |
| `ui` | A Taxonomy & tokens · B Cấu trúc component · C Audit playbook |
| `think` | A Khung quyết định · B 5 Modules · C Radar |
| `flow` | A Tư duy flow · B 8 câu hỏi first-principles · C Chốt & output |

Full item-level breakdown: `docs/research/public-private-abc-restructure.md`.

## Cross-cutting lens

Some subjects legitimately live in several files: one **root rule** stating the principle, plus **domain applications** that must stay inside their domain (moving them would strip the context where they are actually read). This section is an **address map only — never rule text** — so it stays a pointer, not a duplicate.

| Subject | Root | Domain applications |
|---|---|---|
| **Naming** | `design.A7` — name by role, never by concrete value | `agent.C1` file names · `ui.A` design tokens · `stack.C1` ⟨Aki⟩ canonical component names · `release.A3` version/tag format · `content.A3` semantic stability (renaming an existing concept) |

Add a second lens row only when a subject has actually caused a miss — `design.A2` (Rule of Three) applies to this rule corpus too.

## Precedence
When rules conflict, use this order:
1. Current local source code, runtime output, and build output
2. User's explicit instruction in the current conversation
3. Project `CLAUDE.md`
4. Aki-RULE shared files
5. Older docs, memory, or prior conversation context

Project `CLAUDE.md` may add project facts and stricter constraints. It must not silently weaken core safety, verification, or source-of-truth rules.

## Project binding
Each project should keep a root `CLAUDE.md` that:
- references the akirule skill as the rule loader (see SKILL.md for signal list)
- defines project-specific facts and overrides
- stays short
- avoids duplicating shared rules

## Change policy
Aki-RULE changes affect many projects. Before changing these files, clarify the intended rule, scope, and tradeoff unless the user explicitly requests the exact change.
