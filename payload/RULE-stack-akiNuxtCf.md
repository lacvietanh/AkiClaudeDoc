# Stack Rule — Nuxt 4 + Cloudflare

## Stack
Nuxt 4 · Vue 3 · Tailwind v4 · @nuxtjs/i18n · @nuxtjs/seo · SweetAlert2 · FontAwesome 7.2 · aki-info-detect

## Cloudflare constraints
- No `fs`, `child_process`, or `path` in Worker runtime
- Use `fetch()` for outbound requests
- Use `crypto.subtle`, not Node native crypto
- Do not enable `nodejs_compat` in `wrangler.toml` unless upstream issues are confirmed fixed

## Preset and output
- Use `cloudflare_pages`, not `cloudflare_module`
- Output directory is `dist/`
- `wrangler.toml` must keep `pages_build_output_dir = "dist"`

## Rendering
- Public pages: prerender/SSG when suitable
- Dynamic content: SSR
- Private admin routes: SPA/no-index when suitable
- Use `aki-info-detect` to separate bot and real-browser behavior when needed

## Vue/Nuxt patterns
- Use SSR guards only at entry points
- Avoid redundant client guards inside already client-only flows
- Prefer framework composables and runtime APIs over manual plumbing
- `v-for` must use stable `:key`
- `v-if` for conditional rendering; `v-show` for frequent toggles
- Internal links: `NuxtLink`
- External links: `<a target="_blank" rel="noopener noreferrer">`

## Template attribute order
`id` → `v-for :key` → `v-if/show` → `v-model` → `@events` → `:bindings` → `class/static`

## i18n
- Follow the current project's existing locale key convention before introducing a new one
- For new locale keys, prefer one short, stable convention and keep it consistent within the same project
- Repeated/shared UI strings: i18n keys
- Strategy: `prefix_except_default`

## UI
- Desktop-first, but responsive across narrow to wide screens
- Scale spacing by breakpoint instead of hardcoding large values
- Use FontAwesome Free
- Add `aria-label` to icon-only controls
- Use focus trap for modals when needed

## SEO
- Every page should use the project SEO helpers and schema setup
- Prefer SSR/prerendered critical content
- Keep OG images and metadata explicit
