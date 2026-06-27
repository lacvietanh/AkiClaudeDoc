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
Cross-check, don't guess:
1. Top entry of `CHANGELOG.md` / `releases.json`
2. `git tag` / the previous commit's version
3. The running session context (what was just built)
Then choose the correct bump level. When unsure between two levels, prefer the smaller and say so.

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

## Sync check — required before closing a task
After editing `CHANGELOG.md` or `releases.json`, run:

```
grep '"version"' app/data/releases.json
grep -E '^## \[' CHANGELOG.md
```

Confirm every CHANGELOG version has a matching entry in releases.json and the order (newest-first in releases.json, newest-first in CHANGELOG) is consistent. Fix any gap before the task is done.
