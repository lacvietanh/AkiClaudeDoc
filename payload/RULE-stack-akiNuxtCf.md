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
