---
name: akirule
description: Aki's unified rule router. Loads core rules on every task; signal-triggered loading with high sensitivity for contextual rules; full load on explicit command.
user-invocable: false
---

## Tier 1 — Core (harness-guaranteed)

@~/.aki/claudedoc/index.md
@~/.aki/claudedoc/RULE-agent-behavior.md
@~/.aki/claudedoc/RULE-coding.md

---

## Tier 2 — Contextual loading

**Sensitivity bias: when in doubt, load. A false positive (loading an unused file) costs a few tokens. A false negative (missing a rule) causes wrong behavior.**

Before responding, scan the user message and any file paths mentioned. For each rule below: if ANY single signal matches → Read that file immediately, before generating a response.

### RULE-docs.md
Load if message or file path contains any of:
- **Keywords:** `docs`, `CLAUDE.md`, `README`, `PLAN`, `plan/`, `diagram`, `mermaid`, `architecture`, `arch/`, `doc sync`, `documentation`, `index.md`, `feat/`, `plan lifecycle`, `tài liệu`, `sơ đồ`, `kiến trúc`
- **Paths:** `docs/**`, `PLAN.md`, `CLAUDE.md`, `README.md`, `docs/feat/*`, `docs/arch/*`, `docs/plan/*`
- **Actions:** creating, editing, moving, or completing any plan or doc file

### RULE-content-write.md
Load if message or file path contains any of:
- **Keywords:** `button`, `label`, `heading`, `error message`, `tooltip`, `empty state`, `i18n`, `locale`, `translation`, `t(`, `$t(`, `meta title`, `meta description`, `og:`, `JSON-LD`, `FAQ`, `landing page`, `copy`, `UI text`, `nội dung`, `văn bản`, `nhãn`, `thông báo lỗi`, `semantic`
- **Paths:** `locales/**`, `i18n/**`, `*.i18n.*`, `public/content/**`
- **Actions:** renaming a concept or term used across the product

### RULE-stack-akiNuxtCf.md
**Default ON for any Aki project context.** Skip only when the task is provably stack-independent (plain markdown, isolated script, config unrelated to the Aki frontend stack).
Load if message or file path contains any of:
- **Keywords:** `nuxt`, `vue`, `cloudflare`, `workers`, `pages`, `wrangler`, `tailwind`, `composable`, `middleware`, `layout`, `plugin`, `component`, `useRoute`, `useFetch`, `definePageMeta`, `nitro`, `vite`
- **Paths:** `components/**`, `pages/**`, `composables/**`, `layouts/**`, `middleware/**`, `wrangler.toml`, `nuxt.config.*`, `tailwind.config.*`, `app.vue`

### RULE-seo.md
Load if message or file path contains any of:
- **Keywords:** `seo`, `schema`, `sitemap`, `robots`, `canonical`, `usePageSeo`, `useSchemaOrg`, `JSON-LD`, `structured data`, `og:`, `ogImage`, `hreflang`, `alternateName`, `sameAs`, `knowsAbout`, `LLM visibility`, `AI visibility`, `AI Overview`, `entity`, `schema.org`, `DefinedTerm`, `validate-seo`, `meta title`, `meta description`, `OG image`, `trailing slash`
- **Paths:** `docs/seo/**`, `docs/ref/seo*`, `scripts/validate-seo*`, `composables/usePageSeo*`, `composables/useSeoSchemas*`
- **Actions:** creating a new page, adding schema, configuring sitemap or robots

### METHOD-flow-audit.md
Load if message contains any of:
- **Keywords:** `refactor`, `restructure`, `simplify`, `fragile`, `complicated`, `flow`, `state machine`, `async chain`, `tại sao phức tạp`, `luồng`, `tracing`, `cause and effect`, `over-guarded`, `conditional`, `timing`, `tái cấu trúc`, `đơn giản hóa`
- **Context:** fixing a bug spanning multiple files, tracing cause and effect across a chain

### METHOD-techbiz-optimizer.md
Load if message contains any of:
- **Keywords:** `new feature`, `tính năng mới`, `should we`, `có nên`, `simplest way`, `đơn giản nhất`, `is this worth`, `có đáng`, `tradeoff`, `scope`, `effort`, `value`, `premature`, `complexity`, `abstraction`, `tooling`
- **Context:** architectural or tooling decision, scope or effort/value discussion

---

## Tier 3 — Full load

**Trigger** — match any of the following (case-insensitive):
`nạp full`, `load full`, `full load`, `nạp tất cả rule`, `load all rules`, `full akirule`, `nạp hết rule`

**Protocol — execute in order:**
1. Run `ls ~/.aki/claudedoc/RULE-*.md ~/.aki/claudedoc/METHOD-*.md` to discover the actual file list
2. Read each file returned (skip anything under `ref-ECC/`)
3. Output confirmation: `[akirule:full] Loaded: <comma-separated filenames>`

---

## Load confirmation

After any Tier 2 or Tier 3 loading, output one line at the start of the response:
- Tier 2: `[akirule] +RULE-docs.md +METHOD-flow-audit.md` (list files actually loaded this turn)
- Tier 3: `[akirule:full] Loaded: <all filenames>`
- Tier 1 only: no output needed
