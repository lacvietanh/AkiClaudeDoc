# Changelog

## 2026-07-12

### Changed
- `payload/RULE-docs.md`: added `docs/biz/` as a standard, MANDATORY top-level doc topic — the business backbone (identity, USP, positioning, monetization) for any project with a business dimension. Added a "Business backbone" section making it the spine that all `arch/`/`feat/`/`plan/` product/money docs must reference, and the tie-breaker when code intent and a `biz/` doc disagree (the `biz/` doc wins). Originated from the vstshop.com repositioning work, where business strategy became the declared backbone.
- `payload/index.md`: updated the `RULE-docs.md` manifest description to note the mandatory `docs/biz/` backbone.
- `payload/RULE-stack-akiNuxtCf.md`: documented a new gotcha under the admin-SPA / `i18n.pages[x] = false` guidance — once a route is removed from i18n routing, links to it must use a plain string `to="/..."`, never `localePath()`/`switchLocalePath()`. `localePath()` silently returns `undefined` for such a route (no error, no console warning), so `<NuxtLink :to="undefined">` renders an `<a>` with no `href` at all — a link that looks correct in code review but never navigates. Traced to a real incident in `app.akinet.me` (sidebar `/me` link copied from `kinhdich.akinet.me`, where `/me` keeps normal i18n routing — but `app.akinet.me` disables it via `i18n.pages.me = false`, so the copied `localePath('/me')` call broke silently).
- `CLAUDE.md` (repo root, not `payload/`): added an explicit operating rule — any change to `payload/*` or `claude/skills/*` that adds/removes a topic or changes install behavior must also update `README.md` where it goes stale; `akihelp` reads live installed state so it's exempt from manual content updates; `CHANGELOG.md` must be updated for every `payload/`/`claude/` change. Closes the gap where the `docs/biz/` rule change above shipped without a README/CHANGELOG pass until the user asked for it.

## 2026-07-11

### Added
- `docs/research/2026-07-11-versioning-critique-akithink.md`: structured decision record (/akithink) analyzing and refining the versioning rewrite proposal.

### Changed
- `payload/RULE-release.md`: rewrote the versioning rules to use cold-start version reconstruction (unbounded git log checks with robust boundary commit fallbacks), severity-driven bump logic, and a legacy audit mode. Hardened the rewrite: restored the Pre-bump/Mid-release/Mismatch state table (double-bump guard), made the CHANGELOG-diff pickaxe (`git log -S`) the primary boundary-commit anchor with fixed-string message grep demoted, added user confirmation on ambiguous fallback, a fresh-repo case, the smaller-level tie-breaker, and an audit-mode rule against inventing unknown historical content.
- `payload/index.md`: updated manifest description for `RULE-release.md` to reflect cold-start versioning and audit mode.
- `payload/RULE-stack-akiNuxtCf.md`: documented the `__BUILD_DATE__` (footer build stamp) standard, specifying build-time JS computation via `vite.define` and client-side rendering within `<ClientOnly>` to avoid hydration mismatches.

## 2026-07-10

### Added
- `payload/RULE-design-core.md`: new Contextual (high-sensitivity) rule — the universal,
  stack-agnostic pattern-design philosophy (SSoT, Rule of Three, SRP "and"-test, OCP, composition
  over duplication, module boundaries, name-by-role, anti-patch). Sharpens `RULE-coding.md` without
  restating it and defers UI-specific enforcement to `RULE-ui-pattern.md`. Registered in `index.md`,
  the akirule Tier 2 signal block, and `README.md`.
- `payload/RULE-ui-pattern.md`: new Contextual rule — the frontend enforcement of
  `RULE-design-core.md` (4-tier class taxonomy, design tokens as the single source for visual values,
  arbitrary-value policy, atomic component structure, variant API, and a UI audit/refactor playbook).
  Registered in `index.md`, the akirule Tier 2 signal block, and `README.md`.

### Changed
- Tier vocabulary normalized to exactly three canonical labels — **Core / Contextual / Analytical** —
  across `payload/index.md`, `README.md`, `claude/skills/akirule/SKILL.md`, and the rule headers.
  Dropped the drift-prone variants "Core-adjacent" (`RULE-design-core.md` is Contextual
  high-sensitivity) and "Optional/Contextual" (`RULE-db-design.md` is Contextual), so every label now
  matches the actual routing mechanism. `RULE-design-core.md` is Contextual, not Core, on purpose:
  embedding it in Tier 1 would tax every conversation for every user; its near-universal reach is
  served by broad signals instead.
- `README.md`: added `RULE-design-core.md` and `RULE-ui-pattern.md` to both the tier list and the
  repository-layout tree (they were missing); rewrote the routing section so its "three tiers" match
  `akirule/SKILL.md` exactly — Tier 1 Core (embed), Tier 2 Contextual (contextual rules plus the
  signal-loaded analytical methods), Tier 3 Full-load on explicit command — instead of mislabeling the
  analytical methods as "Tier 3".
- `install.sh`: the post-install "Rules deployed" summary parser now accepts multi-word tier cells
  (regex `(\w+)` → `([^|]+?)`, plus a tolerant color lookup), so rows like `RULE-design-core.md` and
  `RULE-db-design.md` are no longer silently dropped from the printed manifest.
- `claude/skills/akihtmlreport/SKILL.md`: never `Read` an existing `REPORT.html` (it is large, dense
  HTML and the skill always regenerates it wholesale) — inspect metadata only; a stale file (older
  than ~12 h) is deleted without reading, a recent one still prompts. The generation timestamp is
  computed in UTC and rendered in the viewer's local time via inline JS; a compact table of contents
  with per-section `id` anchors is required at the top; a short final-summary section is now mandatory
  at the end. Evaluation reports (refactor/code-review/strategy/idea assessments) must also surface
  each item's side effects and edge cases as a first-class element, keep the MVP recommendation as
  the headline, and split autonomous-decidable from needs-user-decision. Added an optional
  glossary/notes appendix as the very last section for reports leaning on jargon or abbreviations.
- `.gitignore`: ignore the disposable `REPORT.html` visual export.
- `payload/RULE-coding.md`: expanded the lone `atob()` note into a **Unicode / UTF-8 safety**
  subsection — base64/JWT decoding via `TextDecoder`, NFC normalization before compare/store/dedupe/
  keys, byte (not `str.length`) measurement for size and length limits, and codepoint-safe truncation.
- `payload/RULE-stack-akiNuxtCf.md`: expanded the Cloudflare/Workers Unicode note — decode
  Firebase/JWT payloads via `TextDecoder` (with an explicit "corruption is an app-layer bug, D1 stores
  the bad bytes faithfully" clarification), percent-encode non-ASCII header/cookie values, count
  response size / `Content-Length` in bytes, and feed `crypto.subtle` encoded bytes.
- `payload/RULE-db-design.md`: added section 5 "The DB is not your Unicode safety net" — SQLite/D1
  stores UTF-8 faithfully but does not prevent mojibake (fixed at the decode/compare layer per
  `RULE-coding.md`); the one schema-level concern is using `utf8mb4`, never 3-byte `utf8`, on
  MySQL/MariaDB.
- `payload/METHOD-deep-think.md`: added Module 5 "MVP focus, side-effects & edge-cases weighed by
  severity" — an evaluation discipline (not business-gated, unlike Module 4). The MVP keeps the focus
  of effort, but SFX/EC are weighed by severity, not sequence: it is a feedback loop, not a one-way
  pipeline, so a material side-effect/edge-case can reshape or reopen the MVP itself. Scoped to the
  four cases of *discussing or evaluating* (not executing) a refactor, a code review, a strategy/plan,
  or an idea; trivial risks named out-of-scope, severe ones promoted immediately. On promotion, the
  agent resolves what first-principles/critical-thinking can settle (decide + report) and escalates
  to the owner only for genuine owner-calls (irreversible / cross-boundary / unverifiable) per
  `RULE-agent-behavior` Decision boundaries — not for what basic reasoning settles.
- `claude/skills/akirule/SKILL.md`: `METHOD-deep-think` now auto-loads on evaluation/discussion
  signals (`evaluate`, `assess`, `worth refactoring`, `side effect`, `edge case`, `đánh giá`,
  `bàn luận`, `đánh giá ý tưởng`, `đánh giá chiến lược`, …) so Module 5 fires on the four cases.

## 2026-07-08 (2)

### Added
- `payload/METHOD-deep-think.md`: replaces `METHOD-techbiz-optimizer.md` as the single analytical
  brain for deep thinking, consumed two ways — **passive** (akirule auto-loads it inline on
  matching signals) and **active** (`/akithink`). Restructured into 4 modules: Module 1 goal
  excavation (climb the goal hierarchy to the ultimate goal, flag conflicting goals), Module 2
  first principles (facts / real constraints / assumptions, reusing the old file's "Problem truth"
  / "Assumptions" / "Flow" material), Module 3 critique (mandatory adversarial pass — steelman,
  attack-the-favored-option, inversion, pre-mortem, second-order effects, anti-sycophancy rule),
  Module 4 techbiz lens (conditional — the old file's value/effort/scope/cost/alternatives/
  validation/decision-test/red-flags content, applied only when business/product context exists).
  Adds a one-way-door vs two-way-door framing and a closing radar rule: passive mode must say
  "this deserves a dedicated `/akithink` session" rather than settle for a shallow pass on
  irreversible or goal-ambiguous decisions.
- New skill `akithink` (`claude/skills/akithink/SKILL.md`): structured 5-phase deep-thinking
  session (model check → restate → goal excavation → first principles → mandatory critique →
  convergence) for big, hard-to-reverse, or goal-ambiguous decisions. Explicit-invoke only, reads
  `METHOD-deep-think.md` as its toolbox, recommends a top-tier model (Opus/Fable) without blocking,
  supports a "chốt" escape hatch to jump to convergence, and always proposes a `docs/` decision
  record on close (plus `/akihtmlreport` when the material is large/complex).
- New skill `akihelp` (`claude/skills/akihelp/SKILL.md`): `/akihelp` renders a live introduction to
  the whole Aki system (installed skills, the akirule 3-tier router, the deep-think passive/active
  split, editing-rules discipline) by reading `index.md` and installed skill frontmatters at
  runtime — never a hardcoded inventory, so it cannot go stale.

### Changed
- Renamed skill `akiadvise` → `akihtmlreport` (`claude/skills/akihtmlreport/SKILL.md`). Output
  filename `ADVISE.html` → `REPORT.html` everywhere (single-file rule, collision check,
  `.gitignore` guidance); invocation `/akiadvise` → `/akihtmlreport`; description sharpened to
  state the single purpose plainly (visualize existing conversation content, no new analysis);
  "After writing" now opens the file locally (`open REPORT.html` on macOS, `xdg-open` fallback on
  Linux, falls back to just printing the path) instead of refusing to launch a browser; notes it
  pairs naturally with `/akithink` Phase 5 output.
- `payload/index.md`: manifest row `METHOD-techbiz-optimizer.md` → `METHOD-deep-think.md` with
  updated purpose text.
- `claude/skills/akirule/SKILL.md`: Tier 2 signal block renamed `METHOD-techbiz-optimizer.md` →
  `METHOD-deep-think.md`; added thinking-session signals (`first principles`, `tư duy nguyên bản`,
  `phản biện`, `mục tiêu tối thượng`, `one-way door`, `quyết định lớn`, `decision record`,
  `pre-mortem`).
- `install.sh`: added `akiadvise` to the old-skill directory cleanup loop so renamed installs don't
  leave a stale skill; added an explicit `rm -f` for `~/.aki/claudedoc/METHOD-techbiz-optimizer.md`
  as a safety net alongside the `rsync --delete` payload sync.
- `README.md`: repo-layout tree, install-target file list, and prose updated for the
  `akithink`/`akihtmlreport`/`akihelp` skills and `METHOD-deep-think.md`; added a "One brain, two
  modes" section explaining the passive/active thinking architecture.
- `README.md`: full rewrite for concision — install command leads, skills presented as a table,
  installer behavior condensed to one numbered list, duplicate install-target section merged into
  the layout tree. Fixed the layout tree and akirule Tier 2 description, which were missing
  `RULE-seo.md`, `RULE-release.md`, and `RULE-db-design.md`; uninstall section now covers all five
  skills and the update-check hook.

## 2026-07-08

### Added
- Notify-only update-check hook (`claude/hooks/aki-update-check.py`), installed to
  `~/.claude/hooks/` and registered as a Claude Code `SessionStart` hook (`startup|resume`).
  On session start it compares the installed `CHANGELOG.md` top entry against the public repo
  copy (`raw.githubusercontent.com/lacvietanh/AkiClaudeDoc/master/CHANGELOG.md`); when the remote
  is newer it prints a user-visible `systemMessage` with the "what's new" delta, the update command,
  and the changelog link, and passes the same delta to Claude via `additionalContext`. Fail-silent
  (any error/offline → exit 0, no output), throttled to once per 24h, and never auto-updates — it
  only points at `git pull && bash install.sh`. Uses the CHANGELOG top header as the version marker,
  so there is no separate version file to bump. Does not nag machines whose local changelog is ahead
  of the remote (dev checkouts).

### Changed
- `install.sh`: copies the update-check hook into `~/.claude/hooks/`, writes `~/.aki/claudedoc/.source-repo`
  (this machine's source repo path, so the hook can print the correct update command), and registers
  the `SessionStart` hook in `settings.json` idempotently (drops any prior `aki-update-check` entry
  before adding the current one). Post-install summary now lists deployed hooks.
- `README.md`: documented the update-check hook in "What the installer does", the repo layout, and
  the install-target file list.

### Fixed
- `README.md`: one-line install command pointed at the non-existent `main` branch
  (`raw.githubusercontent.com/lacvietanh/AkiClaudeDoc/main/install.sh` → 404); corrected to
  `master`, the repo's actual default branch.

## 2026-07-07 (3)

### Added
- New skill `akiadvise` (`claude/skills/akiadvise/SKILL.md`): distills a complex analysis/report
  already discussed in conversation into a single-file, ultra-wide, visually dense HTML report
  (`ADVISE.html`, default at project root). Enforces a single-file discipline (one `ADVISE.html`
  per project at a time — never `ADVISE-2.html`/versioned variants; asks before overwriting an
  existing one) and only applies to genuinely dense/complex content, never proactively.

## 2026-07-07 (2)

### Added
- `RULE-stack-akiNuxtCf.md`: Admin layout isolation rules in Rendering — the admin layout owns its
  own chrome (`AdminSidebar.vue`, added to the canonical component names table) and never imports
  public chrome components; each admin feature area gets its own route under `/admin/**` instead
  of tab-state inside one page.
- `RULE-stack-akiNuxtCf.md`: New "Dev workflow scripts (package.json)" section — `killport` +
  `dev` chaining with a pinned per-site dev port; `db.init.local`/`db.push` patterns for projects
  with a D1 database.

### Changed
- Generalized ecosystem-specific wording so every rule stands alone for public readers:
  `RULE-stack-akiNuxtCf.md` deploy verification no longer names internal projects; `RULE-seo.md`
  entity-linking section now describes the parent/sibling pattern generically (concrete domain
  lists belong in each project's own docs), `/login` indexability is a default rather than a
  named-org policy, and the validate-seo baseline pointer no longer references an internal repo
  path. (Intentional exception kept: the AkiTao Favicon Generator tool link.)
- `payload/index.md`: Expanded `RULE-stack-akiNuxtCf.md` manifest description (admin layout
  isolation, dev workflow scripts).

## 2026-07-07

### Added
- `RULE-stack-akiNuxtCf.md`: New "Deploy verification — push is not done" section — a push only
  *requests* a Cloudflare build, task isn't closed until the newest build reaches a terminal state.
  Clarifies that most AkiNet projects deploy via **Cloudflare Pages**, not Workers — the
  `cloudflare-builds` MCP only covers the Workers Builds API and shows zero builds for a Pages
  project (confirmed against `kinhdich-akinet` 2026-07-07). Points to
  `wrangler pages deployment list` or the general-purpose `cloudflare` MCP
  (`https://mcp.cloudflare.com/mcp`) for Pages projects instead.
- `RULE-release.md`: "Release vs deploy — two different events" section separating release
  (CHANGELOG/releases.json/GitHub Release, all stacks) from deploy (web build going live,
  web-only, owned by `RULE-stack-akiNuxtCf.md`).

### Changed
- `RULE-release.md`: Scope widened from "projects with CHANGELOG.md" to **every Aki project,
  any stack** — `CHANGELOG.md` is mandatory from project creation, a repo without one is broken
  not exempt. Clarified `releases.json` is web-only (exists only where a public release-notes
  page renders it); Tauri/CLI/non-web projects keep `CHANGELOG.md` only. "Identify the current
  version before bumping" now runs per closed problem, not once per session.
- `claude/skills/akigitcommit/SKILL.md`: No-CHANGELOG fallback reframed as exempting only
  non-Aki repos (every Aki repo must have one). Added "commit unit is one closed problem" rule —
  a problem's commit includes its code AND its CHANGELOG.md/releases.json entries, never batched
  into a separate catch-all commit.
- `payload/index.md`: Updated `RULE-stack-akiNuxtCf.md` and `RULE-release.md` manifest
  descriptions to reflect the above.

## 2026-07-05

### Added
- `RULE-db-design.md`: New optional/contextual rule file — four generalized database design
  principles (Immutability & Event Sourcing, First Normal Form, Bounded Context/DDD, flat-query
  discipline). Loads only when designing schema/migrations/DB refactors, not on every task.

### Changed
- `RULE-stack-akiNuxtCf.md`: Added "Build & TypeScript" section (strict TS, `<script setup>`
  only, relative server imports, clean build logs, duplicate-Vite sourcemap-warning guidance).
  Added "Canonical component names" section (fixed names for footer/topnav/sidebar/rail-dock/
  breadcrumb/auth-util roles). Added "State" section (useState-first, Pinia only when needed,
  localStorage sync in `onMounted`). Added onUnmounted cleanup requirement for multi-layout admin
  sites. Added favicon/manifest UI guidance with a link to the AkiTao Favicon Generator tool.
  Added i18n co-located page-text guidance.
- `payload/index.md`: Added manifest row for `RULE-db-design.md`; expanded
  `RULE-stack-akiNuxtCf.md` description to mention canonical names, state, and build/TS.
- `claude/skills/akirule/SKILL.md` (source): Added Tier 2 signal block for `RULE-db-design.md`.

---

## 2026-06-28

### Changed
- `RULE-release.md`: Expanded "Identify the current version before bumping" — now requires running three commands (`git log`, `grep package.json`, `grep CHANGELOG.md`) before touching any version. Defines three states: **Pre-bump** (package.json == git → bump once), **Mid-release** (package.json > git → accumulate, do not bump again), **Mismatch** (warn, do not auto-fix). Added bump-level guard: same session features+fixes → minor; unsure → smaller level; no version skipping; do not bump until at least one user-visible change exists.
- `RULE-release.md`: Added **"GitHub Release output"** section — after CHANGELOG update and version bump, automatically output a copy-ready GitHub Release block without waiting for the user to ask. Title: `v{version} — {2–5 word specific impact}`, no generic words. Body mirrors CHANGELOG but one short sentence per bullet, no file paths, no jargon.
- `install.sh`: Replaced machine-local block extraction with a clean two-file model. `CLAUDE.md` is fully managed by installer; machine-local config lives in `~/.claude/CLAUDE.local.md` (never overwritten after first creation). Installer appends `@~/.claude/CLAUDE.local.md` import + machine-local source-path block to `CLAUDE.md` on every run. Creates `CLAUDE.local.md` from template on first install only.
- `README.md`: Updated "What the installer does" and "Install target" to document the `CLAUDE.local.md` pattern. Added "Machine-local configuration" section.

---

## 2026-06-27 (4)

### Changed
- `RULE-release.md`: Added two new sections. **"No version gaps in releases.json"** — every CHANGELOG version must appear in releases.json; internal/technical versions must not be skipped but instead summarized with a brief user-friendly entry (patterns provided for `improved`/`fixed` types). **"Sync check"** — mandatory grep before closing any task touching CHANGELOG or releases.json, confirms no gap and correct newest-first order in both files.

---

## 2026-06-27 (3)

### Added
- `RULE-stack-akiNuxtCf.md`: New "Layout chrome — breadcrumb · back-to-home · scroll-to-top" section codifying the unified layout-chrome standard for every akinuxtstack site, so future work cannot drift it back out of consistency. Locks the invariants learned during the breadcrumb rollout: exactly one layout-level `<Breadcrumb>` owning the VISUAL trail only; dynamic leaf via `useBreadcrumb()` + `<ClientOnly>` SSR fallback (hydration-safe); `BreadcrumbList` JSON-LD owned by the page, exactly once (never the layout, never duplicated when a SEO composable already emits it); crumb links only to real prerendered routes (dead intermediate segments render as plain text to avoid Nitro `no-error-response` 404s); translated-slug link reconstruction (`/en${acc}/`) instead of `localePath()`; a single `<ScrollToTop>` with back-to-home served by the Home crumb. Distilled from vstshop, akinet, akitao, kinhdich (incl. removing kinhdich's `SELF_MANAGED` exception so it fully rejoins the standard).

### Changed
- `payload/index.md`: Extended the `RULE-stack-akiNuxtCf.md` manifest description to mention layout chrome (breadcrumb/scroll-to-top).
- `akirule/SKILL.md` (source): Added Tier 2 keywords to the stack-rule signal block (`breadcrumb`, `scroll-to-top`, `back-to-home`, `layout chrome`, `useBreadcrumb`).

---

## 2026-06-27 (2)

### Added
- `RULE-release.md`: New Contextual rule for Aki projects that ship versioned releases (repo with `CHANGELOG.md` + `CLAUDE.md`, Nuxt or Tauri v2). Defines the two-channel split — `CHANGELOG.md` (technical, English, Keep a Changelog) vs `app/data/releases.json` (public, user-friendly, bilingual EN+VI when the site is multilingual, default EN). Specifies the bilingual `releases.json` schema, semver bump discipline (`major.minor.patch`, one release = one version, no stray bumps), how to identify the current version before bumping (changelog top entry / git tag / session context), and content discipline (no em/en dash, stable terminology). Distilled from the release-notes campaign across vstshop, akinet, akitao, kinhdich.
- `payload/index.md`: Added `RULE-release.md` to the file manifest.
- `akirule/SKILL.md` (source): Added Tier 2 signal block for `RULE-release.md` (keywords release/changelog/version/semver/bump + paths `CHANGELOG.md`, `releases.json`, `pages/releases/**`).

---

## 2026-06-27

### Changed
- `claude/skills/akigitcommit/SKILL.md`: Thêm mode detection — tự check `CHANGELOG.md` trước khi group. Khi có CHANGELOG: dùng domain-grouped mode (group theo object/feature, tối đa 3–5 commits). Khi không có CHANGELOG: giữ nguyên type-grouped mode cũ (feat/fix/refactor). Cập nhật description trong frontmatter.
- `RULE-seo.md`: Sửa hướng dẫn title format — bỏ `| [Brand]` khỏi source title vì `@nuxtjs/seo` tự append qua `titleTemplate`. Thêm section `@nuxtjs/seo — titleTemplate behavior (CRITICAL)` với ví dụ ✅/❌ rõ ràng để tránh double-suffix. Sửa giới hạn `< 60` → `≤ 60`, thêm exception 80-char cho article/post/knowledge slug pages. Cập nhật post-build validation checklist: `>` thay `>=`, decode HTML entities trước khi đo độ dài, skip redirect stubs.
- `RULE-stack-akiNuxtCf.md`: Thêm rule `trailingSlash: true` bắt buộc trong i18n block — không chỉ `router.options` và `site`. Thiếu config này khiến `localePath()` strip trailing slash, gây canonical mismatch warning hàng loạt khi build.
- `claude/CLAUDE.md`: Thêm rule "Editing shared rules — luôn sửa từ source AkiClaudeDoc project rồi chạy install, không sửa trực tiếp vào bản đã install" để AI agent không sửa nhầm deployed copy.

---

## 2026-06-26 (2)

### Added
- `RULE-seo.md`: New Contextual rule covering all SEO concerns — `usePageSeo` API contract, meta title/description limits and formatting, schema.org page-type matrix, Organization required fields, trailing slash, robots/sitemap exclusion, OG image convention, AI/LLM visibility (FAQ structure, DefinedTerm, alternateName), ecosystem entity linking (sameAs, parentOrganization), Vietnamese unaccented keyword handling, post-build validation checklist. Distilled from real patterns across akitao.com, vstshop.com, akinet.me, kinhdich.akinet.me.

### Changed
- `RULE-stack-akiNuxtCf.md`: Removed inline SEO bullet list, replaced with single-line reference to `RULE-seo.md`.
- `payload/index.md`: Added `RULE-seo.md` to file manifest, updated stack rule description.
- `akirule/SKILL.md` (source): Added Tier 2 signal block for `RULE-seo.md`; removed `SEO` from `RULE-stack-akiNuxtCf.md` signals to avoid double-loading now that the stack rule defers to `RULE-seo.md`.
- `install.sh`: UX overhaul — added `print_summary()` with colored post-install table (rules by tier, skills deployed, timestamp + git commit hash); copies `CHANGELOG.md` to `$INSTALL_ROOT/CHANGELOG.md` so any machine can inspect installed version; writes `$INSTALL_ROOT/.version` (installed date, commit, branch); added `prune_backups()` keeping only the 2 most recent backups per file (was accumulating unbounded).

---

## 2026-06-26

### Changed
- `RULE-coding.md`: Added `## Result pattern for external calls` section under Error handling — defines the `Result<T>` type pattern (`{ ok: true; data: T } | { ok: false; error: string }`) with code examples. Establishes the standard for all fallible I/O at system boundaries: composable/service catches once, callers check `.ok` without try/catch.
- `RULE-stack-akiNuxtCf.md`: Added `## External integrations` section — composable-as-boundary rule (pages never import provider SDK directly), domain-based module organization (`useAuth`, `useUser`, `useProjects` instead of god-file), cross-reference to Result pattern.

---

## 2026-06-24

### Changed
- Standardized and improved `GEMINI.md` with professional English phrasing and structured bootstrap directives to align Gemini and Antigravity agents with the `CLAUDE.md` source of truth.

---

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
