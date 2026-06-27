# Changelog

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
