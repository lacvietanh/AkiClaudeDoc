# Release & Versioning Rule

<!-- Address map: release.A1-5 · release.B1-5 · release.C1-4 (⟨Aki⟩) -->

## A. Versioning core

### A1. Scope — when this applies, CHANGELOG mandatory
Every Aki project, any stack (Nuxt web — see `RULE-stack-akiNuxtCf.md` — Tauri v2, CLI, …). `CHANGELOG.md` is **mandatory from project creation**: the commit workflow and versioning discipline both anchor to it, so a repo without one is broken, not exempt — create it as the first fix. If a change is user-visible or dev-relevant, the release artifacts below must move with the code in the same task — never edit code and leave them stale.

**Release vs deploy — two different events.** A *release* defines a version of the app (CHANGELOG, releases.json, GitHub Release) and applies to every project type. A *deploy* puts a web build live and is web-only — see `RULE-stack-akiNuxtCf.md` § Deploy verification. This rule owns releases only.

### A2. Versioning — semver `major.minor.patch`
- **patch** — bug fixes, internal-only changes
- **minor** — new backward-compatible features
- **major** — breaking changes
- One release = one version; bundle the session's changes under it. Bump deliberately — do not bump on every tiny edit, and do not skip a bump when something shipped.

### A3. Version string format (ABSOLUTE — never violate)
The version *attribute itself* is always bare semver, **never prefixed with `v`**: `package.json`/`Cargo.toml`/equivalent manifest `"version"` field, and every git tag, are `1.10.1` — not `v1.10.1`. This is a real bug class, not a style nit: an inconsistent prefix across tags silently breaks semver comparisons and diffing tools (`git describe`, `hasUpdate()`-style JS comparisons against a fetched tag name), and produces doubled-up UI text when display code does `` `v${version}` `` against a value that already contains `v` (rendered as `vv1.10.1`).
- Tag only if the project already tags: `git tag -l` empty → skip tag creation; CHANGELOG/releases.json/GitHub Release stay authoritative.
- Create tags bare: `git tag 1.10.1`, never `git tag v1.10.1`.
- Before cutting any release, check the existing tag convention with `git tag -l | sort -V | tail -5` — if a project's history has drifted to `v`-prefixed tags partway through, treat that drift as the bug being corrected (go back to bare), not as the precedent to keep following.
- Human-facing display **may** prepend `v` at render time only — a GitHub Release title (`v{version} — …`, see below), a UI badge ("Update Available — v1.10.1"). That is a presentation concern, separate from and does not violate this rule. The forbidden thing is `v` baked into the stored/compared value itself.
- When resolving the last release's boundary commit, prefer the bare-tag form: `git rev-parse "<last-version>"`, falling back to `git rev-parse "v<last-version>"` only to read a legacy/already-existing `v`-prefixed tag — never as the form to create going forward.

### A4. Bump level — driven by content severity, not by step-count
Classify every accumulated change found in the git log:
- breaking / not backward-compatible → major
- new capability, backward-compatible → minor
- fix / internal-only → patch

**New version = the last version recorded in CHANGELOG (the Pre-bump baseline from the state table in B1) + exactly one step at the HIGHEST severity found across the full accumulation.** Do not add steps per session or per commit.

Unsure between two levels → choose the smaller, state the reason.

A jump like `1.4.2 → 2.0.0` is a correct single major step if the accumulation contains a breaking change. A jump like `1.4.2 → 1.6.0` remains invalid because it skips the minor version `1.5.0` (minor must only increment by 1).

### A5. A version is minted at the release event, never at work-completion (ABSOLUTE)

Finishing a piece of work does not earn a version number. Only shipping does — a production deploy, a published tag, a distributed build.

- **Continuously-deployed Web / Service Apps**: Between releases, the accumulation lives under `## [Unreleased]` at the top of `CHANGELOG.md` with **no version number and no manifest bump**. When the release actually happens, rename that `[Unreleased]` heading to the new version and bump the manifest once. Local version == production version at all times.
- **Distributed Artifact Apps (Tauri Desktop App, CLI Binaries, compiled packages)**:
  - Atomic bump + tag + build in the same release task is **PERMITTED** (because the version string is baked into the compiled binary artifact at build time).
  - **Mandatory Pre-Bump Guard (ABSOLUTE)**: This guards minting the **next** version — it does **not** block finishing the current one. Being at a manifest version with no tag yet is the *normal* mid-release state here: the manifest is bumped when work on the version starts, and the tag is cut only at build. The guard fires only when you would stack a **second** unshipped version on top of the first. Before advancing the manifest to a new, higher number, verify the current manifest version already has a matching tag/release build (`git tag -l "<current_manifest_version>"`). If it does not, **finish the current version (cut its tag/build) first** — do not open another version on top of an unshipped one (state: **Drifted**, see B1). Completing the current version (tag + build at its own number) is never blocked.

- **Never bump the manifest `version` field in the same task as a routine code change (Web apps)**. The bump belongs to the release task alone. A task that ends with "bumped to 0.2.0" but nothing deployed is the bug for web apps.
- **Many sessions collapse into one version, not one version per session.** Three or four rounds of local improvement on top of a `0.1.0` production release ship as `0.2.0` (or `0.1.1`, or `1.0.0` — whatever A4's severity rule gives), **never** as `0.3.4`.
- **Materiality test before minting.** A version the user sees must be worth seeing. If the whole accumulation is one or two trivial internal lines, do not mint it — leave it in the bucket and let it ride with the next real change. A release with three versions of two bullets each is the symptom this rule exists to prevent; those should have been one version.
- **Recovery when drift already happened.** Versions that were never published to production/tagged are not public, so they are **not protected by B3's "never renumber public versions"**. Squash them: collapse every unpublished version's entries into one `[Unreleased]` section, reset the manifest to the last *actually released* version, then mint one version. Only versions with a real deploy/tag/build behind them are frozen. If it is unclear whether a version ever shipped, treat it as shipped and ask the user.

## B. Xác định & audit

### B1. Identify the current version — cold-start, not session-memory

Run this check **each time a problem is closed and about to be recorded** — not once at the end of a session. It answers "does this entry go into a new version or the one already open?" Never rely on remembering a prior session: every time this step runs — 5 minutes or 5 months since the last run — it must re-derive the correct state from the repo alone.

1. Read `package.json` (or equivalent) for the recorded version.
2. Read `CHANGELOG.md` to identify the last documented version (`<last-version>`).
3. Determine the release state **before** deciding any bump:

| State | Condition | Action |
|-------|-----------|--------|
| **Unreleased open** | `CHANGELOG.md` has an `## [Unreleased]` section on top | Normal working state (A5) — append the entry there, do NOT bump anything |
| **Pre-bump** | `package.json` == CHANGELOG top version | Nothing pending. Recording a change → open a new `## [Unreleased]`; releasing now → reconstruct the accumulation (steps 4–5) and mint exactly once |
| **Mid-release** | `package.json` > CHANGELOG top version | Already bumped, version still open — append to it, do NOT bump again |
| **Drifted** | **two or more** unshipped versions have piled up — i.e. ≥2 recorded CHANGELOG version entries sit above the last deployed/tagged version | Unpublished versions accumulated — apply A5's recovery (squash back, mint once) before doing anything else. **One** untagged version whose number matches the manifest is not drift — it is the normal in-progress state of a distributed-artifact app (see A5); resolve via *Unreleased open* / *Pre-bump* above, do not block |
| **Mismatch** | any other disagreement | Warn the user, do not auto-fix |

4. Find the boundary commit for `<last-version>` using this sequence:
   a. The commit that wrote the CHANGELOG entry — the strongest anchor, since the entry itself marks the release boundary: `git log -1 --format=%H -S "[<last-version>]" -- CHANGELOG.md`
   b. Production baseline verification (stack-specific, strictly remote):
      - **App (Tauri/Desktop/CLI):** Check remote git tags (`git ls-remote --tags origin`) and GitHub Releases.
      - **Web (Nuxt Cloudflare / AkiNuxtCf):** Check remote GitHub state (published `app/data/releases.json` / remote GitHub tags).
   c. A release commit message — use fixed strings (`.` is a regex wildcard): `git log --fixed-strings --grep="<last-version>" -n 1 --format="%H"` (A later commit that merely *mentions* the version, e.g. "fix regression from 1.4.2", is NOT the boundary — inspect the hit before trusting it.)
   d. If no boundary is found, **do not scan the entire history**. Fall back to `git log --oneline -20`, analyze manually, and ask the user to confirm the boundary if there is any ambiguity.
5. Run `git log <boundary-commit>..HEAD --oneline` to get the complete, unbounded list of accumulated changes since the last release.
6. Fresh repo: fewer than ~5 commits, or no version recorded anywhere yet → treat the entire history as the current accumulation.

### B2. The real anti-skip invariant

A version jump is only actually wrong when there is evidence that a release boundary was already completed and left unrecorded. Concretely:
- Every git tag matching a version pattern (if tags are used) MUST have exactly one matching CHANGELOG entry.
- Every entry in `app/data/releases.json` (web stacks) MUST have exactly one matching CHANGELOG entry, and vice versa.
- CHANGELOG versions must increase monotonically with no gaps or duplicates.

If a tag or milestone exists without a matching entry, write the missing entry retroactively. Do not just warn and move on.

### B3. Audit mode — for legacy or imported projects

Run once when `CHANGELOG.md` was not produced under this rule from project inception:
1. Verify monotonic order of all versions in `CHANGELOG.md`.
2. Cross-check against all version-pattern git tags.
3. Cross-check against `app/data/releases.json` (if it exists).
4. Report mismatches and propose retroactive entries for any gaps. Never renumber or delete public versions.
5. If a gap's historical content cannot be determined (a tag exists but nobody knows what it contained), the retroactive entry must say so explicitly ("historical content unknown") — never invent or infer changes that cannot be verified.

### B4. GitHub Release output — copy-ready summary

After updating CHANGELOG and version bump, automatically output a copy-ready GitHub Release block without waiting for the user to ask:

**Title:** `v{version} — {2–5 word specific impact}` — no generic words ("patch fixes", "bug fixes", "improvements")
- Good: `v1.5.1 — fix production icons blank, caret, grid gap`
- Bad: `v1.5.1 — patch fixes`, `v1.5.1 — various improvements`

**Body:** same `#### Fixed` / `#### Changed` / `#### Added` sections as CHANGELOG, but each bullet trimmed to one short sentence — symptom first, no file paths, no internal jargon.

### B5. Content discipline
- Release note copy: no em/en dash (`—` `–`); short user-facing sentences, benefit first. See [[RULE-content-write]].
- Keep terminology stable across versions (e.g. always "Release Notes", not mixed synonyms). See [[RULE-content-write]] semantic stability.
- Doc/version moves are part of the change, not an afterthought. See [[RULE-docs]].

## C. ⟨Aki⟩ Web release artifacts

### C1. Two separate channels — do not merge them
| File | Audience | Language | Tone |
|------|----------|----------|------|
| `CHANGELOG.md` | developer / technical | English only | Precise, may name files/symbols. Keep a Changelog format (`Added` / `Changed` / `Fixed` / `Removed`) |
| `app/data/releases.json` | public / end user | Bilingual EN + VI if the site is multilingual (default EN); EN-only if single-language | Popular, user-friendly, benefit-first. No jargon, no file paths |

The changelog explains *what changed and why* for maintainers. The release note tells users *what they get*. Write them separately; do not paste changelog lines into the release note.

`releases.json` exists **only where a public web page renders it** (the Nuxt stack's release-notes page). Tauri, CLI, and other non-web projects keep `CHANGELOG.md` only — a release-notes file nothing renders is dead data; do not create one. Where `releases.json` does not exist, every rule below that mentions it simply does not apply.

### C2. releases.json schema
- Single-language site: `{ version, date, title, changes: [{ type, text }] }`
- Multilingual site: localize the human text — `title: { en, vi }`, `changes: [{ type, text: { en, vi } }]`. Keep `version`, `date`, `type` locale-neutral. Default/fallback language is English.
- `type` is one of `new` | `improved` | `fixed` (stable badge keys).

### C3. No version gaps in releases.json
Every version that appears in `CHANGELOG.md` MUST also appear in `releases.json`. Skipping a version because it is "internal" or "technical" is not allowed — it creates visible number jumps that users notice and distrust.

**If a version contains only internal/technical changes** (scripts, refactors, build tooling), write a brief user-friendly summary instead of omitting it entirely. Use one of these patterns:
- `"type": "improved"` — "Under-the-hood improvements for stability and performance"
- `"type": "fixed"` — "URL or display fixes" (describe the symptom a user would notice, not the cause)
- `"type": "improved"` — "Build and SEO tooling updates (no visible change for users)"

Never leave a gap like `1.0.5 → 1.0.7` or `0.1.0 → 0.1.3` in releases.json. A one-line entry is better than a missing version.

### C4. Sync check — required before closing a task
After editing `CHANGELOG.md` or `releases.json`, run:

```
grep '"version"' app/data/releases.json
grep -E '^## \[' CHANGELOG.md
```

Confirm every CHANGELOG version has a matching entry in releases.json and the order (newest-first in releases.json, newest-first in CHANGELOG) is consistent. Fix any gap before the task is done.
