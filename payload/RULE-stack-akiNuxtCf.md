# Stack Rule — Nuxt 4 + Cloudflare

## Stack
Nuxt 4 · Vue 3 · Tailwind v4 · @nuxtjs/i18n · @nuxtjs/seo · SweetAlert2 · FontAwesome 7.2 · aki-info-detect

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
- Use `aki-info-detect` to separate bot and real-browser behavior when needed
- For `aki-info-detect`: Import manually only where needed. Absolutely DO NOT integrate into Nuxt plugins. WARNING: Do not auto-run the `getIP` feature unless explicitly requested.

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

## i18n
- Follow the current project's existing locale key convention before introducing a new one
- For new locale keys, prefer one short, stable convention and keep it consistent within the same project
- Repeated/shared UI strings: i18n keys
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
