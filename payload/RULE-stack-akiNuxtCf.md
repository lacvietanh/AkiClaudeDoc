# Stack Rule — Nuxt 4 + Cloudflare

## Stack
Nuxt 4 · Vue 3 · Tailwind v4 · @nuxtjs/i18n · @nuxtjs/seo · SweetAlert2 · FontAwesome 7.2 · aki-info-detect

## Build & TypeScript
- TypeScript `strict` mode
- Vue 3 `<script setup>` + Composition API only — Options API is forbidden
- Inside `server/`: use relative imports, never `~/server/...`
- Keep build logs clean — every remaining warning must be either traced to its root cause or
  filtered on purpose (`nitro.rollupConfig.onwarn`); never let warnings drift unexamined
- If the build spews sourcemap warnings, two Vite copies are likely loaded — pin one version via
  package.json `overrides` + clean reinstall

## Cloudflare constraints
- No `fs`, `child_process`, or `path` in Worker runtime
- Use `fetch()` for outbound requests
- Use `crypto.subtle`, not Node native crypto
- Do not enable `nodejs_compat` in `wrangler.toml` unless upstream issues are confirmed fixed
- Must strictly use `trailingSlash: true` consistently for Cloudflare Pages (applies to routing, canonical, og:url, sitemap, schema.org)

## Preset and output
- Use `cloudflare_pages`, not `cloudflare_module`
- Output directory is `dist/`
- `wrangler.toml` must keep `pages_build_output_dir = "dist"`

## Rendering
- Public pages: prerender/SSG when suitable
- Dynamic content: SSR
- Private admin routes: SPA/no-index when suitable
- NEVER index `/admin` or `/admin/**` in robots/sitemap
- **Admin UI is always English-only** — it is an internal SPA tool, not user-facing content, so it
  does NOT need i18n routing at all. With `@nuxtjs/i18n` `customRoutes: 'config'`, disable each
  admin page from locale routing via `i18n.pages['admin/xxx'] = false` (not a `{ vi, en }` mapping)
  — this prevents Nuxt from ever generating a `/en/admin/**` variant, so there is only one
  canonical admin URL. Admin UI copy is hardcoded in English directly, never duplicated via
  `isVI ? '...' : '...'` ternaries — that pattern is presentation clutter with no real audience
  (admin has no locale switcher, and the project's default/public locale is irrelevant here).
  Domain-specific terms may stay in their original language when no English equivalent is
  precise — see the project's own domain-terminology exception if it has one.
- On multi-layout sites (default ↔ admin), any listener/timer/subscription registered while in
  the admin layout must be cleaned up in `onUnmounted` so it does not leak across a layout switch
- Use `aki-info-detect` to separate bot and real-browser behavior when needed
- For `aki-info-detect`: import only the specific **named exports** you need — **never** the default `akiInfoDetect()`, which auto-fires `getNetworkInfo()` (ipinfo/ipwhois/ipify) in the background. Do NOT plugin-load the **default/whole** library. Tree-shaken **named local-only** exports (`parseUserAgent`/`getHighEntropyValues`/`getScreen`/`detectGPU`/`getBattery`) MAY run early via a `.client.ts` plugin in an isolated dynamic-import chunk — but verify the network functions (`getIP`/`getISP`/`getCountry`/`getLocation`/`getNetworkInfo`) are absent from the built chunk (`grep` the bundle for the IP URLs). Never auto-run `getIP`/network features unless explicitly requested.

## Vue/Nuxt patterns
- Use SSR guards only at entry points
- Avoid redundant client guards inside already client-only flows
- Prefer framework composables and runtime APIs over manual plumbing
- `v-for` must use stable `:key`
- `v-if` for conditional rendering; `v-show` for frequent toggles
- Internal links: `NuxtLink`
- External links: `<a target="_blank" rel="noopener noreferrer">`
- Dialogs: ONLY use `useSwal()`. Strictly forbidden to use `window.alert()` or `window.confirm()`.

## Template attribute order
`id` → `v-for :key` → `v-if/show` → `v-model` → `@events` → `:bindings` → `class/static`

## State
- Prefer Nuxt `useState` first; reach for Pinia only when the state's shape genuinely needs it
  (cross-page store with actions/getters, not just shared reactive data)
- Sync any `localStorage`-backed persistence inside `onMounted`, never at setup-time top level —
  avoids SSR/hydration mismatch

## i18n
- Follow the current project's existing locale key convention before introducing a new one
- For new locale keys, prefer one short, stable convention and keep it consistent within the same project
- Repeated/shared UI strings: i18n keys
- Page-specific text belongs co-located with the page — in the `.vue` file's own `<i18n>` block,
  or in a `.ts` file next to the page. The site-wide `en.json`/`vi.json` files hold ONLY strings
  shared across the whole site — never stuff page-specific copy into them.
- Strategy: `prefix_except_default`
- **`trailingSlash: true` must be set inside the `i18n` block** in addition to `router.options` and `site`. Without it, `localePath()` strips trailing slash from generated URLs, causing canonical mismatch warnings on every page:
  ```ts
  i18n: {
    strategy: 'prefix_except_default',
    trailingSlash: true,   // ← required; prevents localePath() from stripping slash
    // ...
  }
  ```

## UI
- Desktop-first, but responsive across narrow to wide screens
- Scale spacing by breakpoint instead of hardcoding large values
- UI rules: Use a scientific z-index system (`--z-index` variables) and standard border-radius dimensions (`radius-sm`, `md`, `lg`, `xl`, `pill`)
- Use FontAwesome Free. DO NOT write anything for FontAwesome in `.npmrc` (the free version does not need config).
- Add `aria-label` to icon-only controls
- Use focus trap for modals when needed
- Favicon: keep `favicon.ico` at the project's `public/` root
- Web manifest: full `name`/`short_name`/`icons` (192 + 512 maskable)/`apple-touch-icon`/
  `theme_color`, linked via `<link rel="manifest">` in `<head>`
- Recommended tool: [AkiTao Favicon Generator](https://akitao.com/t/favicon-generator/) — Rust/WASM
  tool built around "minimal files, maximum compatibility": sharp Lanczos3 resizing even at
  16×16, and it emits the full standard set (favicon.ico + icon-48/96/192 + icon-512-maskable +
  apple-touch-icon + manifest.json) in one pass

## Canonical component names
Fixed names for these roles — do not invent new names for them. Each site assembles from this
set as needed (top nav is the minimum required; sidebar/rail/dock added when the site needs
them). Rename on drift whenever you touch one of these files.

| Role | Canonical name |
|---|---|
| Footer | `AppFooter.vue` |
| Top nav | `AppTopNav.vue` |
| Sidebar (one side) | `AppSidebar.vue` |
| Sidebar (two sides) | `AppSidebarLeft.vue` / `AppSidebarRight.vue` |
| Rail / dock (optional) | `AppRail.vue` / `AppDock.vue` |
| Breadcrumb | `Breadcrumb.vue` |
| Auth boundary util | `server/utils/auth.ts` |

## Layout chrome — breadcrumb · back-to-home · scroll-to-top
ONE mechanism for every akinuxtstack site. Do not reinvent it per page; any drift here breaks cross-project consistency.

**Breadcrumb — single source of truth**
- Exactly ONE `<Breadcrumb>`, rendered in `default.vue` inside `<main>` before `<slot/>`. No page renders its own breadcrumb nav.
- It owns the VISUAL trail only. Derive the trail from `route.path`: strip the non-default locale prefix, map known segments to i18n labels via a lookup table, humanize the rest. Hide it on home (`crumbs.length <= 1`).
- Dynamic leaf: a detail page supplies the real last-crumb label via `useBreadcrumb(() => label)` (path-keyed `useState`). Render the leaf through `<ClientOnly>` with the humanized segment as the SSR fallback. NEVER read the page-set leaf during the layout's synchronous SSR render — it is not set yet (hydration-mismatch trap).
- Crumb links point ONLY to real prerendered routes. An intermediate segment with no page of its own renders as plain text, never a link — a dead link makes the Nitro `no-error-response` prerender check fail with a 404.
- Translated-slug sites (e.g. `que`↔`iching`): build links by reconstructing the real path and re-applying the locale prefix (`/en${acc}/`), NOT `localePath(acc)` — `localePath` cannot round-trip an already-localized slug. Keep `trailingSlash`.

**BreadcrumbList JSON-LD — owned by the page, never the layout**
- The `<Breadcrumb>` component emits NO structured data. The `BreadcrumbList` JSON-LD is the page's responsibility (in-page `useHead` / `useSeoSchemas().breadcrumb`, or a page-scoped SEO composable).
- Exactly ONE `BreadcrumbList` per page. If a SEO composable already emits it, do not add a second copy in the page.

**Pre-footer chrome**
- One `<ScrollToTop>` in the layout. No per-page back-to-top. Back-to-home is the Home crumb — no separate back-to-home button.

## External integrations (Firebase, third-party APIs)
- **Composable is the only boundary** — page components and layouts never import the provider SDK directly (no `import { getFirestore } from 'firebase/firestore'` in a `.vue` file)
- All provider-specific code lives in composables or utility modules; pages only call composable functions
- This means swapping a provider (Firebase → Supabase → D1) only touches the composable layer, not any page
- **Organize by domain, not by provider** — split into one file per data concern, not one god-file:
  ```
  utils/firebase/core.ts      ← init app, getDb(), getAuth() only
  composables/useAuth.ts      ← login, logout, session state
  composables/useUser.ts      ← user profile CRUD
  composables/useProjects.ts  ← project data
  ```
- Apply the Result pattern (see RULE-coding.md) at the composable boundary — composables return `Result<T>`, pages check `.ok`

## SEO
See `RULE-seo.md` for all SEO rules (meta limits, schema matrix, robots, sitemap, OG image, AI visibility, entity linking).
