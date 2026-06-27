# AkiClaudeDoc — Improvement Plan (Jun 24)

Status: pending  
Scope: `claude/skills/akirule/SKILL.md`

---

## Context

Session analysis identified two categories of issues in SKILL.md's Tier 2 signal keyword lists:

1. **Overly broad keywords** — common programming terms that trigger false positives constantly
2. **Missing precision** — keyword covers the right domain but not tight enough to avoid noise

The changes below are keyword-level only. File structure, architecture, and Tier 1/3 logic are already updated and deployed (session Jun 24).

---

## Pending keyword changes

### RULE-docs.md

| Old | Action | New | Reason |
|-----|--------|-----|--------|
| `feat/` | Replace | `docs/feat/` | `feat/` is a git branch prefix — ambiguous without the `docs/` prefix |
| `index.md` | Remove | — | Already covered by `docs/**` path pattern; bare `index.md` is too broad |

---

### RULE-content-write.md

| Old | Action | New | Reason |
|-----|--------|-----|--------|
| `copy` | Remove | — | "copy file", "copy-paste", "clipboard copy" cause constant false positives. Already covered by `UI copy` (kept) |
| `semantic` | Replace | `semantic stability` | "semantic HTML", "semantic versioning", "semantic search" are unrelated. `semantic stability` maps exactly to the rule's intent |
| `văn bản` | Remove | — | Extremely broad in Vietnamese ("văn bản pháp lý", "văn bản này"). Coverage remains via `thông báo lỗi`, `nhãn`, and new `nội dung UI` |
| `nội dung` | Replace | `nội dung UI`, `nội dung giao diện` | Bare `nội dung` matches "nội dung file", "nội dung code". Both replacements narrow to UI content context |

---

### RULE-stack-akiNuxtCf.md

| Old | Action | New | Reason |
|-----|--------|-----|--------|
| `pages` | Remove | — | "pagination", "web pages" cause false positives. Already covered by `pages/**` path pattern |
| `workers` | Replace | `cloudflare workers`, `cf workers` | "web workers", "service workers", "background workers" are unrelated. Both replacements are unambiguous |
| `plugin` | Remove | — | "VSCode plugin", "webpack plugin", "ESLint plugin" cause false positives. Already covered by `plugins/**` path pattern. If needed: `nuxt plugin` |
| `layout` | Remove | — | "CSS layout", "grid layout", "flex layout" cause false positives. Already covered by `layouts/**` path pattern |
| Default ON condition | Clarify | See note | "any Aki project context" is ambiguous — model cannot self-determine project type from SKILL.md alone |

**Default ON note:** Replace current text with:
> Default ON when the project CLAUDE.md references the Aki stack or the akirule skill. Skip only when the task is provably stack-independent (plain markdown, isolated script, config unrelated to the Aki frontend stack).

---

### METHOD-flow-audit.md

| Old | Action | New | Reason |
|-----|--------|-----|--------|
| `flow` | Replace | `user flow`, `luồng xử lý` | "workflow", "git flow", "cash flow", "data flow" are unrelated. `user flow` and `luồng xử lý` narrow to execution/product flow audit contexts. `state machine` and `async chain` already in list cover the rest |
| `conditional` | Replace | `nested conditional`, `điều kiện lồng nhau` | Appears in every `if/else` — constant false positive. `nested conditional` targets the accumulated-conditionals smell that flow-audit addresses. `over-guarded` already in list |
| `timing` | Replace | `timing issue`, `race condition` | "deployment timing", "timing analysis" are unrelated. `race condition` is precise. `timing issue` catches async coordination bugs |

---

### METHOD-techbiz-optimizer.md

| Old | Action | New | Reason |
|-----|--------|-----|--------|
| `value` | Remove | — | Appears in every line of code ("return value", "prop value", "key-value"). Already covered by `effort/value` (kept). Optionally add `business value` |
| `scope` | Replace | `scope creep`, `mở rộng scope` | "variable scope", "CSS scope", "function scope" are unrelated. `scope creep` is unambiguous. `mở rộng scope` covers the Vietnamese equivalent |

---

## Secondary issues (lower priority)

These were noted but not critical — handle after keyword changes are stable:

1. **Load confirmation duplication** — Tier 3 protocol (step 3) and the Load confirmation section both define the `[akirule:full]` output format. Consolidate to one place.

2. **"Skip if already loaded"** — No instruction prevents re-reading a file already loaded earlier in the same conversation. Add: *"Skip if already loaded earlier in this conversation."*

3. **Full load false trigger risk** — `nạp full` could match "nạp full bộ dữ liệu" (load full dataset). Low risk in practice but worth noting. Could require `nạp full rule` or `nạp full akirule` as the canonical form if false triggers appear in practice.
