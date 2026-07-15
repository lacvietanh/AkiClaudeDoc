# Release & Versioning Rule

## Scope — when this applies
Every Aki project, any stack (Nuxt web — see `RULE-stack-akiNuxtCf.md` — Tauri v2, CLI, …). `CHANGELOG.md` is **mandatory from project creation**: the commit workflow and versioning discipline both anchor to it, so a repo without one is broken, not exempt — create it as the first fix. If a change is user-visible or dev-relevant, the release artifacts below must move with the code in the same task — never edit code and leave them stale.

**Release vs deploy — two different events.** A *release* defines a version of the app (CHANGELOG, releases.json, GitHub Release) and applies to every project type. A *deploy* puts a web build live and is web-only — see `RULE-stack-akiNuxtCf.md` § Deploy verification. This rule owns releases only.

## Two separate channels — do not merge them
| File | Audience | Language | Tone |
|------|----------|----------|------|
| `CHANGELOG.md` | developer / technical | English only | Precise, may name files/symbols. Keep a Changelog format (`Added` / `Changed` / `Fixed` / `Removed`) |
| `app/data/releases.json` | public / end user | Bilingual EN + VI if the site is multilingual (default EN); EN-only if single-language | Popular, user-friendly, benefit-first. No jargon, no file paths |

The changelog explains *what changed and why* for maintainers. The release note tells users *what they get*. Write them separately; do not paste changelog lines into the release note.

`releases.json` exists **only where a public web page renders it** (the Nuxt stack's release-notes page). Tauri, CLI, and other non-web projects keep `CHANGELOG.md` only — a release-notes file nothing renders is dead data; do not create one. Where `releases.json` does not exist, every rule below that mentions it simply does not apply.

## releases.json schema
- Single-language site: `{ version, date, title, changes: [{ type, text }] }`
- Multilingual site: localize the human text — `title: { en, vi }`, `changes: [{ type, text: { en, vi } }]`. Keep `version`, `date`, `type` locale-neutral. Default/fallback language is English.
- `type` is one of `new` | `improved` | `fixed` (stable badge keys).

## Versioning — semver `major.minor.patch`
- **patch** — bug fixes, internal-only changes
- **minor** — new backward-compatible features
- **major** — breaking changes
- One release = one version; bundle the session's changes under it. Bump deliberately — do not bump on every tiny edit, and do not skip a bump when something shipped.

## Version string format (ABSOLUTE — never violate)
The version *attribute itself* is always bare semver, **never prefixed with `v`**: `package.json`/`Cargo.toml`/equivalent manifest `"version"` field, and every git tag, are `1.10.1` — not `v1.10.1`. This is a real bug class, not a style nit: an inconsistent prefix across tags silently breaks semver comparisons and diffing tools (`git describe`, `hasUpdate()`-style JS comparisons against a fetched tag name), and produces doubled-up UI text when display code does `` `v${version}` `` against a value that already contains `v` (rendered as `vv1.10.1`).
- Create tags bare: `git tag 1.10.1`, never `git tag v1.10.1`.
- Before cutting any release, check the existing tag convention with `git tag -l | sort -V | tail -5` — if a project's history has drifted to `v`-prefixed tags partway through, treat that drift as the bug being corrected (go back to bare), not as the precedent to keep following.
- Human-facing display **may** prepend `v` at render time only — a GitHub Release title (`v{version} — …`, see below), a UI badge ("Update Available — v1.10.1"). That is a presentation concern, separate from and does not violate this rule. The forbidden thing is `v` baked into the stored/compared value itself.
- When resolving the last release's boundary commit, prefer the bare-tag form: `git rev-parse "<last-version>"`, falling back to `git rev-parse "v<last-version>"` only to read a legacy/already-existing `v`-prefixed tag — never as the form to create going forward.

## Identify the current version — cold-start, not session-memory

Run this check **each time a problem is closed and about to be recorded** — not
once at the end of a session. It answers "does this entry go into a new version
or the one already open?" Never rely on remembering a prior session: every time
this step runs — 5 minutes or 5 months since the last run — it must re-derive
the correct state from the repo alone.

1. Read `package.json` (or equivalent) for the recorded version.
2. Read `CHANGELOG.md` to identify the last documented version (`<last-version>`).
3. Determine the release state **before** deciding any bump:

| State | Condition | Action |
|-------|-----------|--------|
| **Pre-bump** | `package.json` == CHANGELOG top version | Reconstruct the accumulation (steps 4–5), then bump exactly once |
| **Mid-release** | `package.json` > CHANGELOG top version | Already bumped, version still open — append to it, do NOT bump again |
| **Mismatch** | any other disagreement | Warn the user, do not auto-fix |

4. Find the boundary commit for `<last-version>` using this sequence:
   a. The commit that wrote the CHANGELOG entry — the strongest anchor, since the
      entry itself marks the release boundary:
      `git log -1 --format=%H -S "[<last-version>]" -- CHANGELOG.md`
   b. Git tags: `git rev-parse "v<last-version>"` or `git rev-parse "<last-version>"`
   c. A release commit message — use fixed strings (`.` is a regex wildcard):
      `git log --fixed-strings --grep="<last-version>" -n 1 --format="%H"`
      A later commit that merely *mentions* the version (e.g. "fix regression
      from 1.4.2") is NOT the boundary — inspect the hit before trusting it.
   d. If no boundary is found, **do not scan the entire history**. Fall back to
      `git log --oneline -20`, analyze manually, and ask the user to confirm the
      boundary if there is any ambiguity.
5. Run `git log <boundary-commit>..HEAD --oneline` to get the complete, unbounded
   list of accumulated changes since the last release.
6. Fresh repo: fewer than ~5 commits, or no version recorded anywhere yet →
   treat the entire history as the current accumulation.

## Bump level — driven by content severity, not by step-count

Classify every accumulated change found in the git log:
- breaking / not backward-compatible → major
- new capability, backward-compatible → minor
- fix / internal-only → patch

**New version = the last version recorded in CHANGELOG (the Pre-bump baseline from the state table above) + exactly one step at the HIGHEST severity found across the full accumulation.** Do not add steps per session or per commit.

Unsure between two levels → choose the smaller, state the reason.

A jump like `1.4.2 → 2.0.0` is a correct single major step if the accumulation contains a breaking change. A jump like `1.4.2 → 1.6.0` remains invalid because it skips the minor version `1.5.0` (minor must only increment by 1).

## The real anti-skip invariant

A version jump is only actually wrong when there is evidence that a release boundary was already completed and left unrecorded. Concretely:
- Every git tag matching a version pattern (if tags are used) MUST have exactly one matching CHANGELOG entry.
- Every entry in `app/data/releases.json` (web stacks) MUST have exactly one matching CHANGELOG entry, and vice versa.
- CHANGELOG versions must increase monotonically with no gaps or duplicates.

If a tag or milestone exists without a matching entry, write the missing entry retroactively. Do not just warn and move on.

## Audit mode — for legacy or imported projects

Run once when `CHANGELOG.md` was not produced under this rule from project inception:
1. Verify monotonic order of all versions in `CHANGELOG.md`.
2. Cross-check against all version-pattern git tags.
3. Cross-check against `app/data/releases.json` (if it exists).
4. Report mismatches and propose retroactive entries for any gaps. Never renumber or delete public versions.
5. If a gap's historical content cannot be determined (a tag exists but nobody knows what it contained), the retroactive entry must say so explicitly ("historical content unknown") — never invent or infer changes that cannot be verified.

## Content discipline
- Release note copy: no em/en dash (`—` `–`); short user-facing sentences, benefit first. See [[RULE-content-write]].
- Keep terminology stable across versions (e.g. always "Release Notes", not mixed synonyms). See [[RULE-content-write]] semantic stability.
- Doc/version moves are part of the change, not an afterthought. See [[RULE-docs]].

## No version gaps in releases.json
Every version that appears in `CHANGELOG.md` MUST also appear in `releases.json`. Skipping a version because it is "internal" or "technical" is not allowed — it creates visible number jumps that users notice and distrust.

**If a version contains only internal/technical changes** (scripts, refactors, build tooling), write a brief user-friendly summary instead of omitting it entirely. Use one of these patterns:
- `"type": "improved"` — "Under-the-hood improvements for stability and performance"
- `"type": "fixed"` — "URL or display fixes" (describe the symptom a user would notice, not the cause)
- `"type": "improved"` — "Build and SEO tooling updates (no visible change for users)"

Never leave a gap like `1.0.5 → 1.0.7` or `0.1.0 → 0.1.3` in releases.json. A one-line entry is better than a missing version.

## GitHub Release output — copy-ready summary

After updating CHANGELOG and version bump, automatically output a copy-ready GitHub Release block without waiting for the user to ask:

**Title:** `v{version} — {2–5 word specific impact}` — no generic words ("patch fixes", "bug fixes", "improvements")
- Good: `v1.5.1 — fix production icons blank, caret, grid gap`
- Bad: `v1.5.1 — patch fixes`, `v1.5.1 — various improvements`

**Body:** same `#### Fixed` / `#### Changed` / `#### Added` sections as CHANGELOG, but each bullet trimmed to one short sentence — symptom first, no file paths, no internal jargon.

## Sync check — required before closing a task
After editing `CHANGELOG.md` or `releases.json`, run:

```
grep '"version"' app/data/releases.json
grep -E '^## \[' CHANGELOG.md
```

Confirm every CHANGELOG version has a matching entry in releases.json and the order (newest-first in releases.json, newest-first in CHANGELOG) is consistent. Fix any gap before the task is done.
