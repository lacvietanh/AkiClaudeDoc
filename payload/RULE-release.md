# Release & Versioning Rule

## Scope — when this applies
Aki projects that ship versioned releases: a repo with both `CHANGELOG.md` and `CLAUDE.md`, built on the Aki stack (Nuxt — see `RULE-stack-akiNuxtCf.md`) or a Tauri v2 app. If a change is user-visible or dev-relevant, the release artifacts below must move with the code in the same task — never edit code and leave them stale.

## Two separate channels — do not merge them
| File | Audience | Language | Tone |
|------|----------|----------|------|
| `CHANGELOG.md` | developer / technical | English only | Precise, may name files/symbols. Keep a Changelog format (`Added` / `Changed` / `Fixed` / `Removed`) |
| `app/data/releases.json` | public / end user | Bilingual EN + VI if the site is multilingual (default EN); EN-only if single-language | Popular, user-friendly, benefit-first. No jargon, no file paths |

The changelog explains *what changed and why* for maintainers. The release note tells users *what they get*. Write them separately; do not paste changelog lines into the release note.

## releases.json schema
- Single-language site: `{ version, date, title, changes: [{ type, text }] }`
- Multilingual site: localize the human text — `title: { en, vi }`, `changes: [{ type, text: { en, vi } }]`. Keep `version`, `date`, `type` locale-neutral. Default/fallback language is English.
- `type` is one of `new` | `improved` | `fixed` (stable badge keys).

## Versioning — semver `major.minor.patch`
- **patch** — bug fixes, internal-only changes
- **minor** — new backward-compatible features
- **major** — breaking changes
- One release = one version; bundle the session's changes under it. Bump deliberately — do not bump on every tiny edit, and do not skip a bump when something shipped.

## Identify the current version before bumping

Run these three commands first — do not guess:

```bash
git log --oneline -3
grep '"version"' package.json
grep -m1 '^\### \[' CHANGELOG.md
```

Then determine the current state:

| State | Condition | Action |
|-------|-----------|--------|
| **Pre-bump** | `package.json` == last git commit version | Decide bump level, bump exactly once |
| **Mid-release** | `package.json` > last git commit version | Already bumped — accumulate into current version, do NOT bump again |
| **Mismatch** | CHANGELOG top entry ≠ `package.json` | Warn the user, do not auto-fix |

Bump level discipline:
- Same session has both features and fixes → minor, not major
- Unsure between two levels → choose the smaller, state the reason
- New version = current version + exactly one step at the chosen level — no skipping (e.g. `1.4.2 → 1.6.0` is invalid without explicit justification)
- Do not bump until there is at least one user-visible or dev-relevant change to record

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
