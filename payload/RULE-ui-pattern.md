# UI Pattern — Frontend Enforcement (Nuxt / Vue / Tailwind)

**Tier: Contextual.** Load on any UI authoring/refactor signal, or on an audit signal (see the
Audit section). This file is the **UI-specific enforcement** of the universal laws in
`RULE-design-core.md` — it does not redefine them. Nuxt/Cloudflare stack mechanics (rendering,
i18n, layout chrome, deploy) live in `RULE-stack-akiNuxtCf.md`; this file owns the design-system
layer: tokens, class taxonomy, variant API, and UI audit.

## Map to RULE-design-core (which universal law each rule enforces)

- **SSoT (Law 1)** → design tokens are the single source for every visual value.
- **Evidence-based abstraction (Law 2)** → Rule of Three before a pattern class or base component.
- **Composition over duplication (Law 5)** → slots / dynamic components / `v-for`, never hand-copied
  markup.
- **OCP (Law 4)** → extend a component via props / variant / slot, never fork a copy.
- **Name by role (Law 7)** → semantic tokens and variants, never value-names.
- **Documentation** → every global pattern is recorded (below), so the next agent reuses instead of
  rewriting.

---

## 1. Four-tier class taxonomy

Every style belongs to exactly one tier — there is no fifth tier.

| Tier | Name | Definition | Lives in | Example |
|---|---|---|---|---|
| 0 | Design Token | Atomic value of the visual system | `tailwind.config` + CSS vars at `:root` | `--color-primary`, `theme.spacing` |
| 1 | Utility | Single-property atomic class, used inline | Tailwind core | `flex`, `gap-4`, `text-sm` |
| 2 | Pattern class | Utilities repeated ≥3× merged via `@apply`, semantic name | `@layer components` in `assets/css/*` | `.c-card`, `.c-btn` |
| 3 | Variant (modifier) | Variation of a pattern — prefer a Vue prop + computed class-map; BEM modifier only where Vue can't control markup | SFC `computed()` or `.c-btn--sm` | `variant="primary"` |
| 4 | Component | Markup + variant logic packaged as a reusable SFC | `components/base/*.vue` | `<BaseButton variant="danger" />` |

Rules between tiers:
- Tier 1 is the default first reach for any styling need.
- Climb to tier 2 only when Rule of Three (Law 2) fires — never pre-extract a pattern class.
- Tier 3 in Vue is **always prop-driven** (a computed class-map). Loose CSS modifiers are only for
  markup Vue does not render — Markdown/CMS output, static email templates.
- Tier 4 is the destination: once a pattern has variants, package it as a base component so callers
  never hand-assemble class strings.

**Mandatory order:** Utility → Pattern class → Component variant → hand-written CSS. Hand-written CSS
is the last resort, never the first reflex.

## 2. Design tokens = the single visual source (Law 1)

- Every visual value — color, spacing, radius, shadow, font, breakpoint, z-index, easing, duration —
  exists **once**: a token in `tailwind.config` + a CSS variable. Never rewrite a hex / px / ms
  value anywhere else.
- Name tokens by **role**, not by hue/value: `primary`, `surface`, `danger`, `on-surface` — never
  `bg-blue-500` sprinkled across code. Rebrand = edit one place, not hundreds.
- Reuse the scientific scales required by `RULE-stack-akiNuxtCf.md`: z-index via `--z-index`
  variables, radius via `radius-sm | md | lg | xl | pill`.

## 3. Arbitrary-value policy (Law 1 + Law 7)

`w-[123px]`, `text-[#3b82f6]`, `top-[13px]` are forbidden unless **all three** hold:
(a) no existing token in the scale fits, (b) the value provably appears exactly once system-wide,
(c) an inline comment explains why it is a one-off. A value likely to repeat → add a token first,
use the token second.

## 4. Atomic component structure (Law 3 + Law 6)

```
components/
  base/       # Atom — pure presentation, no fetch, no business logic
  composite/  # Molecule — ≥2 base components into one meaningful unit
  sections/   # Organism — page blocks; may use composables for data
  layout/     # Layout singletons (app.vue / layouts/)
composables/  # All data + business logic lives here — never duplicated in components
```

- Data and side effects live in composables (the boundary — see `RULE-stack-akiNuxtCf.md`
  External integrations), never duplicated across components.
- For the fixed layout roles (footer, top nav, sidebar, breadcrumb, admin sidebar…), reuse the
  **canonical component names** defined in `RULE-stack-akiNuxtCf.md`. Do not invent new names for
  those roles.

## 5. Variant API (CVA-style) (Law 4)

A base component exposes a **finite enum** of variants/sizes; a `computed` class-map resolves
`prop → classes`. A new visual need is a **new entry in the same map**, never a forked
`BaseButtonRed.vue`. Props / slots / emits are a stable contract — extend it, do not mutate it for
one caller.

## 6. Composition, not hand-copied markup (Law 5)

Never duplicate a markup + logic block across components "for speed." Use slots, dynamic
components (`<component :is>`), a composable, or `v-for` over data instead of writing N near-identical
templates by hand.

## 7. Documentation duty (Law 1 for knowledge)

A new **global** pattern class or variant must be recorded in the project's pattern library the
moment it is created. An undocumented pattern does not exist — the next person or agent will rewrite
it and the duplication returns.

---

## AUDIT & REFACTOR — cleaning existing code

**Triggers for this section:** `dọn dẹp`, `class trùng`, `duplicate class/CSS`, `trùng lặp`,
`audit CSS`, `refactor CSS/UI`, `arbitrary value`, `quét class`. Pair with `METHOD-flow-audit.md`
for the flow-level mindset; this section is the concrete UI grep layer. Run the steps in order — do
not skip.

### Step 1 — Inventory by scan (quantify before refactoring by feel)

Duplicate long class strings (pattern-class candidates — Law 2):
```bash
grep -rhoE 'class="[^"]{20,}"' --include="*.vue" . | sort | uniq -c | sort -rn | awk '$1>=3'
```
Un-tokenized arbitrary values (Law 8 / §3):
```bash
grep -rnoE 'class="[^"]*\[[^]]+\][^"]*"' --include="*.vue" .
```
Hardcoded hex/rgb outside tokens (Law 1 / §2):
```bash
grep -rnoE '#[0-9a-fA-F]{3,6}\b|rgb\([^)]+\)' --include="*.vue" --include="*.css" --include="*.ts" . | grep -v tokens.css
```
Hand-written `px`/`ms` in `<style>` or inline `style=` — same treatment.

### Step 2 — Classify severity

SSoT breach (hardcoded value that should be a token) **>** duplicated business/logic **>** duplicated
presentation style. Fix in that order of danger.

### Step 3 — Priority matrix (impact × effort)

Plot each finding on impact × effort. Do high-impact / low-effort first. Do not start a large
refactor by feel before this matrix exists.

### Step 4 — Safe refactor loop

One pattern at a time: extract the token / pattern class / variant → replace every call site →
verify build + type + visual → commit. Follow `RULE-release.md` for CHANGELOG/version; never push
unasked (`RULE-agent-behavior.md`).

### Step 5 — Compliance scorecard

Score the codebase against `RULE-design-core.md` Definition of Done and the four-tier taxonomy: any
tier-0 breach (hardcoded value), any un-evidenced abstraction, any forked component, any
value-named token is a fail to record.

### Report template

```
UI Pattern Audit — <project> — <date>
1. Inventory counts: dup class strings / arbitrary values / hardcoded colors / hand px-ms
2. Top violations by severity (SSoT > logic > style)
3. Priority matrix: quick wins vs large refactors
4. Recommended extractions (token / pattern class / base component) with call-site counts
5. Score against Definition of Done
```

## One-line reminder

Diversity of UI comes from a controlled variant system, not from ad-hoc class strings — one source
per value, one pattern per repeated problem.
