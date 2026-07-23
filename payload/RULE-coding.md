# Core Coding Rules

<!-- Address map: coding.A1-3 · coding.B1-3 · coding.C1-5 -->

## A. Triết lý & nguồn sự thật

### A1. Language
- Code and comments: English only
- Commit messages: English, imperative style

### A2. Philosophy
- Single-developer friendly
- MVP-first
- DRY, but no abstraction for its own sake
- YAGNI
- Default to simple, direct solutions

### A3. Source of truth
Priority order:
1. Local source code, type definitions, runtime output, and build output
2. Official documentation
3. Live observed results

Project docs and memory are useful context, not final truth.

## B. Chất lượng & sửa code

### B1. Code quality
- Naming: `design.A7` is the root rule — not restated here
- Prefer one clear responsibility per function/module
- Modularize only when it improves clarity, reuse, or testability
- Prefer existing code and patterns over re-implementation

### B2. Changing existing code
A principle with the procedure that guarantees it — apply to any edit of code you did not just write:
- **Before:** grasp the flow and intent of the code before you change it — read the docs it references first (code often points to `docs/...`), then the code, and the git history only when the logic is complex or has been reworked many times (Chesterton's Fence: know why a piece is there before you remove it).
- **After:** confirm the intents and flows you did NOT set out to touch still hold — a fix scoped to problem X must not silently break an unrelated property Y.

### B3. Verification
- Done means verified — never claim success from intention alone.
- Verify by the **narrowest tool that actually settles the doubt**: static reading and type/lint/unit checks first. Never spin up a full build or dev server just to catch a typo a typecheck would catch.
- **Running the app is not a default verification step — but not running it does not let you claim "Done".** Starting a dev server, making live network calls, or driving a full build/headless screenshot is **user-triggered**, not self-authorized (cost and side effects are the user's call). When a change's real risk lives **only at runtime** — hydration, layout/z-index, route/auth flow, a dynamically-built class a build step may purge — and you cannot settle it statically, you may **not** report "Done": halt and report the state as **"unverified — needs a runtime check"**, propose the exact command, and hand it to the user (see [[RULE-agent-behavior]] A3). "Done" for logic you only compiled is not done.

## C. An toàn runtime

### C1. Error handling
- Validate at system boundaries: user input, external APIs, filesystem, network, persistence
- Do not add defensive guards for impossible internal states
- Fail loudly in development when it helps reveal broken assumptions
- Keep production failures safe and user-appropriate
- **Never fabricate mock/fixture data as a runtime fallback for a missing dependency** (DB, API, service binding). Throw/return a real error instead. If a local dev environment genuinely lacks that dependency, fix the environment itself (real local instance, proper binding/proxy) — don't paper over it with fake data. Verify the dependency is actually unavailable by reading how the runtime/framework wires it in dev before assuming a fallback is needed at all.

### C2. Result pattern for external calls
When calling external APIs, Firebase, or any fallible I/O at a system boundary, return a Result type instead of throwing:

```ts
type Result<T> = { ok: true; data: T } | { ok: false; error: string }
```

- The function that owns the boundary (composable, service module) does the try/catch once and returns Result
- Callers check `.ok` before using `.data` — no try/catch spread across UI or business logic
- TypeScript narrows the type correctly after the `.ok` check — no `data!` assertions needed
- For batch calls: each item returns its own Result; one failure does not crash the batch

```ts
// ✅ boundary function — catches once
async function fetchUser(uid: string): Promise<Result<User>> {
  try {
    const doc = await getDoc(ref('users', uid))
    return { ok: true, data: doc.data() as User }
  } catch (e: any) {
    return { ok: false, error: e.code ?? 'unknown' }
  }
}

// ✅ caller — no try/catch needed
const result = await fetchUser(uid)
if (!result.ok) return showError(result.error)
doSomethingWith(result.data) // TypeScript knows this is User
```

### C3. Performance
- Minimize query/call count and CPU cost **incrementally, everywhere** — not just identified hot paths
- Prefer flat, non-correlated queries over nested CTEs or per-row correlated subqueries; push merge/aggregation logic to plain application code when data volume makes that cheap and clearer
- Before shipping a nested/correlated query, ask: could two flat queries + an application-layer merge replace this more simply and just as fast?

### C4. Security
- Sanitize external input
- Never expose secrets in client code
- Avoid command injection, XSS, SQL injection, unsafe redirects, and token leakage
- Treat generated files, external data, and user-provided content as untrusted until validated

### C5. Unicode / UTF-8 safety
A string and its byte representation are different things; nearly every Unicode bug comes from conflating them. Applies to every runtime, and bites hardest where there is no Node `Buffer` to hide it (e.g. Cloudflare Workers).
- **base64 / JWT / cookie payloads:** `atob()`/`btoa()` are Latin1-only, not UTF-8 codecs — `JSON.parse(atob(jwt))` silently mojibakes non-ASCII text (accented names, emoji) and `btoa()` throws on codepoints > U+00FF. Decode via `new TextDecoder().decode(bytes)`, encode via `new TextEncoder().encode(str)` before base64.
- **Compare / store / dedupe / keys:** normalize first with `str.normalize('NFC')`. The same visible text (e.g. "Nguyễn") can be two different byte sequences, so an un-normalized equality check, unique key, or dedupe treats identical-looking values as different.
- **Length limits & sizes:** measure bytes, not `str.length` (which counts UTF-16 units) — use `new TextEncoder().encode(str).length` for body size, storage/field limits, and `Content-Length`.
- **Truncating text:** never slice by index into the middle of a character — `slice`/`substring` split accented characters and emoji into `�`. Iterate codepoints (`[...str]`) when cutting previews or slugs.
