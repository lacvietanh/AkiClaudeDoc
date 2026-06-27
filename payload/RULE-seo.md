# SEO Rule — Nuxt + Cloudflare Stack

## Scope
Cross-project rules for all Nuxt 4 + Cloudflare Pages sites.
For project-specific keyword strategy and schema values, see the project's own `docs/ref/seo.md` or equivalent.

---

## usePageSeo — standard API

Every public page must call `usePageSeo()`. Canonical URL is derived automatically from `route.path` inside the composable — do not pass it manually unless the composable API requires it.

```ts
usePageSeo({
  title: 'Page Topic',               // Max 60 chars total — NO brand suffix (see @nuxtjs/seo note below)
  description: 'Action-oriented…',   // Max 155 chars, unique per page
  ogImage: 'https://domain.com/ogimage/slug.jpg',  // optional
  ogImageAlt: 'Description of image',              // optional
  noindex: true,                      // optional, for admin/private pages
})
```

---

## @nuxtjs/seo — titleTemplate behavior (CRITICAL)

`@nuxtjs/seo` automatically appends ` | site.name` to every title via `titleTemplate`.

**Rule: source title must NOT include the brand/site name.**

```ts
// ✅ Correct — module adds " | AkiTao" automatically
usePageSeo({ title: 'Knowledge Base' })
// → <title>Knowledge Base | AkiTao</title>

// ❌ Wrong — results in double suffix
usePageSeo({ title: 'Knowledge Base | AkiTao' })
// → <title>Knowledge Base | AkiTao | AkiTao</title>
```

This applies to `usePageSeo()`, `useHead({ title })`, and `useSeoMeta({ title })` — all go through `titleTemplate`.

---

## Meta title & description

- **Title**: ≤ 60 chars total (including the ` | site.name` appended by `@nuxtjs/seo`). Source string must stay short enough to fit within the limit after the suffix is added. Exception: article/post/knowledge slug pages may use ≤ 80 chars when the title is inherently long.
- **Description**: ≤ 155 chars. Start with an action verb + keyword + benefit
- **No em/en dashes** (`—` or `–`) inside title or description — causes encoding issues in some SERPs. Use `|` or `-` instead
- **Single source of truth**: define `const title = '...'` once, pass to `usePageSeo`, OG, Twitter card, and JSON-LD — never repeat the string literal

---

## Schema.org — page type matrix

| Page type | Required schemas | Optional |
|-----------|-----------------|----------|
| Homepage | `Organization` + `WebSite` + `WebPage` | `FAQPage` |
| Service / feature page | `Service` + `Organization` | `FAQPage` |
| Blog post / article | `BlogPosting` + `Person` + `Organization` + `BreadcrumbList` | `FAQPage` |
| Knowledge / glossary | `Article` + `DefinedTerm` + `DefinedTermSet` | `FAQPage` |
| Collection / listing | `CollectionPage` + `ItemList` | `BreadcrumbList` |
| Product | `Product` + `Offer` + `BreadcrumbList` | |
| About | `AboutPage` + `Organization` + `Person` | |
| Contact | `ContactPage` + `Organization` | |

### Organization — required fields across all projects
```ts
defineOrganization({
  name: 'BrandName',
  alternateName: ['Brand Name', 'brandname', 'BRANDNAME', 'brandname.com'],
  url: 'https://domain.com',
  logo: 'https://domain.com/favicon/icon-192.png',
  sameAs: [/* social profiles, parent org, ecosystem siblings */],
  knowsAbout: [/* domain topics this brand covers */],
})
```

---

## Trailing slash — SEO-critical for Cloudflare Pages

All internal links, canonical tags, `og:url`, sitemap entries, and JSON-LD `url` fields **must end with `/`**.
Configured in `nuxt.config.ts`:
```ts
site: { trailingSlash: true }
```
See `RULE-stack-akiNuxtCf.md` for full config context.

---

## Robots & sitemap

```ts
// nuxt.config.ts
routeRules: {
  '/admin/**': { robots: false, prerender: false, sitemap: false }
}
sitemap: {
  exclude: ['/admin', '/admin/**']
}
```

- `/login` is **public and indexable** in current Aki project policy
- Private/admin routes: `robots: false` + excluded from sitemap
- Public pages: `index, follow, max-image-preview:large, max-snippet:-1` (set in `usePageSeo` if the composable supports it)

---

## OG image

- Manual approach — no `nuxt-og-image` (too heavy for static projects)
- **Size**: 1200×630px
- **Location**: `public/ogimage/[slug].jpg` or `.png`
- **Fallback**: if page-level image is absent, the composable falls back to the site-wide default OG image
- Never reference an OG image path that doesn't exist in `public/`

---

## AI / LLM visibility

These rules help content appear in AI-generated answers (Perplexity, ChatGPT, Gemini AI Overviews):

- **FAQ first sentence**: answer directly (subject + verb + predicate). No "Đây là...", "According to...", "In this article..." preambles
- **FAQ length**: < 150 words per answer — short enough for AI to extract verbatim
- **DefinedTerm**: use for specialized domain terminology pages (glossary, knowledge bases)
- **alternateName in Organization/WebSite schema**: include all brand spelling variants (accented + unaccented + lowercase + domain form) so AI can resolve them to a single entity
- **knowsAbout**: list the topics the brand covers — helps AI cite the site as a relevant source

---

## Entity & ecosystem linking

For sites in the Aki ecosystem:
- `parentOrganization`: link subsidiary sites back to `AkiNet` (`https://akinet.me`)
- `sameAs` in `Organization`: include parent org, sibling products, social profiles, and knowledge graph anchors (Wikidata, LinkedIn, etc.)
- Footer cross-links to ecosystem siblings (`akinet.me`, `akitao.com`, `vstshop.com`, etc.) reinforce entity co-occurrence for crawlers
- `Person` (Founder): link `worksFor` and `sameAs` to founder profiles and project pages

---

## Vietnamese keyword handling (vi locale)

Google treats accented and unaccented Vietnamese as different queries (`vst là gì` ≠ `vst la gi`). To cover both without degrading UX:

- **Embed the unaccented form in parentheses** in the first mention of a term in body copy or FAQ: *"...VST (vst la gi)..."*
- **Or include it in** `keywords` meta or `alternateName` in schema
- **Never** put unaccented forms in H1, H2, visible headings, or the FAQ question text — it looks unprofessional
- **Meta title and description**: use correctly accented Vietnamese; unaccented coverage comes from schema + body copy

---

## Post-build validation checklist

Run `scripts/validate-seo.js` (or equivalent) after every build. At minimum it should verify:

- [ ] All page titles ≤ 60 chars (article/post/knowledge slug pages: ≤ 80 chars)
- [ ] All descriptions ≤ 155 chars
- [ ] No em dash (`—`) or en dash (`–`) in title or description
- [ ] All canonical URLs end with `/`
- [ ] Homepage `Organization` schema has `alternateName` and `sameAs`
- [ ] `/admin/**` pages absent from sitemap output
- [ ] Skip redirect stub files (`http-equiv="refresh"`) — they have no SEO content to validate

**Validator implementation notes:**
- Use `>` not `>=` for length checks — exactly 60/155 chars is valid
- Decode HTML entities before measuring length (`&amp;` = 1 char, not 5)
- Use `isArticlePage(relPath)` to apply the 80-char limit on article/post/knowledge slug pages

If the project doesn't have this script yet, copy from `akitao.com/scripts/validate-seo.js` as a baseline.

---

## Prerendering & SSR

- SEO-critical content must be in the HTML at crawl time — not injected by client-side JS
- Public pages: prerender/SSG preferred
- Dynamic SEO content (live prices, user-specific data): SSR, never defer to client
- `zeroRuntime: true` in sitemap config for static deployments
