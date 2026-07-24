# Changelog

## 2026-07-24

### Added
- `payload/GEMINI.md` Rule 12: Enforced mandatory pre-action scope verification checklist inside the hidden `<thought>` block to counter Gemini's RLHF helpfulness bias without polluting user chat UX.
- `docs/research/gemini-helpfulness-bias-enforcement.md`: Created research doc detailing root cause analysis, prompt-engineering solution, and empirical verification results (100% pass across 3 isolated `agy -p` test cases).

## 2026-07-23

### Added — External-action completeness (migration-execution gap)
- `payload/RULE-coding.md` B3: generalized the verification principle to cover changes that require a **separate action against an external system** to take effect (migrations, remote config, env vars, cache purges, cron/schedule registration) — writing the file describing the action is not the same event as the target system reflecting it, and neither git diff nor a green build detects the gap.
- `payload/RULE-release.md` new B5 (renumbered old B5 Content discipline → B6): a CHANGELOG/`releases.json` entry describing a DB schema or infra-dependent change is not truthful until (1) the migration/infra action actually succeeded against the real (remote/production) target with its postconditions checked, and (2) the script is moved to its done location (`scripts/done/` or the project's equivalent marker) — a file still in the pending location is itself evidence step 1 hasn't happened. A plan/release/deploy cannot be reported complete with either condition outstanding.
- `payload/RULE-stack-akiNuxtCf.md` C8: appended the concrete D1 execution checklist — a green Cloudflare build proves nothing about the database; run `wrangler d1 execute <db> --remote --file=...`, verify postconditions against remote, then move the file to `scripts/done/`.
- `payload/index.md` Cross-cutting lens: added "External-action completeness" row (root `coding.B3`, domain applications `release.B5` and `stack.C8`).
- Root cause: a real production incident (kinhdich.akinet.me, 2026-07-23) — a D1 migration script was written and shipped in CHANGELOG v2.10.1 as "Added", but never executed against production. The database stayed on the old schema while deployed code queried the new columns, causing a live 500 on an admin endpoint for a full day before caught. No existing rule checked for this: `coding.B3` only covered runtime-behavior verification, `stack.C8` only checked Cloudflare build status — neither touches whether a required external-system action actually ran.

### Fixed
- `claude/skills/akigitcommit/SKILL.md`, `akihelp/SKILL.md`, `akihtmlreport/SKILL.md`, `akithink/SKILL.md`: YAML frontmatter had been silently collapsed onto one line (`name: x description: y` instead of separate `name:`/`description:` keys) by an earlier line-unwrap pass that didn't distinguish wrapped prose from structurally atomic content. This is invalid frontmatter — `description` and (for `akirule`) `user-invocable` stopped existing as their own keys. Restored to multi-line.
- `claude/skills/akirule/SKILL.md`: same frontmatter collapse, plus its three `@~/.aki/claudedoc/...` Tier-1 import lines had been merged onto a single line. Restored to one import per line.

### Fixed — RULE-release.md Drifted guard false-positive on normal in-progress state
- `payload/RULE-release.md` A5 Pre-Bump Guard + B1 `Drifted` row: the guard fired `STOP AND BLOCK THE BUMP` on a **normal** working state of a distributed-artifact app (Tauri/CLI). Root cause: `Drifted`'s condition was `manifest > last tag`, but for a packaged app the manifest is bumped when a version's work *starts* and the tag is cut only at *build* — so `manifest > last tag` is true for the entire development of the current version, not just real drift. Compounded by three B1 rows (`Unreleased open`, `Pre-bump`, `Drifted`) matching at once with no disambiguation, so an agent picked the loudest. Minimal fix at the two broken spots only: `Drifted` now requires **≥2** unshipped version entries above the last tag (the pileup A5 actually targets); one untagged version matching the manifest is explicitly the normal *Pre-bump*/in-progress state. The guard is reworded to protect *minting the next version*, never *completing the current one*. No general precedence law added (single occurrence — Rule of Three).

### Added
- `payload/RULE-stack-tauri.md` B6: a Tauri project's `CLAUDE.md` must surface the few decision-shaping target facts up front (first among them the ship platform(s), which drive shortcut glyphs ⌘/Ctrl, path shapes, packaging, and the A2 PATH-candidate list) so the agent grasps target context without inferring — the load-bearing few, not an inventory; ask when a platform-specific string is needed and the target is undeclared. Root-cause fix for an agent waffling between ⌘ and Ctrl on a macOS-only app whose CLAUDE.md never stated the platform.
- `payload/RULE-agent-behavior.md` A4 + `payload/RULE-coding.md` B3: two rules generalized from a machine-local file into the shared corpus (apply to Claude and Antigravity). A4 (report for fast re-orientation): length follows content with a per-line information test, conclusion-first structure, and never citing a path/symbol/doc bare without a plain-language gloss. B3 (verification, refined): verify by the narrowest tool that settles the doubt; starting a dev server / live network calls / full build / headless screenshot is a **user-triggered** action, not self-authorized (propose and stop), and a full build is never a stand-in for a typecheck. **Red-team applied:** an initial draft ("a presentational edit has nothing to run") was dropped as a false assumption (CSS can break at runtime — z-index click-through, hydration mismatch, purged dynamic classes), and the missing intermediate state was added — when a change's real risk lives only at runtime and cannot be settled statically, the agent may **not** claim "Done"; it halts and reports **"unverified — needs a runtime check"**, proposes the command, and hands off. This closes the hole where "Done means verified" degraded into "Done means I compiled it, you verify it".
- `payload/RULE-agent-behavior.md` A3 + `payload/GEMINI.md` rule 8: a **communication-vs-task** discriminator — a question/discussion/explanation ("can we / should we / why / what if") is not a request. Claude's shared version (A3) answers questions read-only, executes tasks in-scope, and calibrates autonomy by *reversibility* rather than asking-always (over-asking on safe reversible work is named as a failure, symmetric to acting unasked). The Gemini override (rule 8) is deliberately stricter: COMMUNICATION is **absolute read-only** — no file edits or state-changing commands to "answer" a question, no obvious-fix exception, propose-and-stop only — because the overeager-action failure mode is most acute there.
- `payload/RULE-agent-behavior.md` C3: two additions found while auditing the regression above. (1) Comments/docstrings/string literals should not be hard-wrapped mid-line either — same training-data habit as prose auto-wrap, now made explicit for code. (2) The reverse direction, which is what actually broke the SKILL.md files: never collapse multiple physical lines into one to "clean up" wrapping without first checking whether each line is wrapped prose (safe to rejoin) or a structurally atomic unit consumed by a parser — YAML/TOML frontmatter fields and `@import`/include directives named as the concrete tells, with a general test ("does something parse this line individually?").

### Added — CHANGELOG backfill (content already in the working tree, previously undocumented)
- `payload/RULE-seo.md`: `FAQPage` schema flagged as inert for AI visibility as of 2026 (Google retired FAQ rich results; no other consumer confirmed) — keep existing markup, stop treating it as a deliverable; question-shaped `<h2>`s in rendered HTML are what actually earns AI citations. `llms.txt` flagged the same way (97% of files got zero requests across a 137k-domain study; no vendor commitment to read it). B4 (prerendering/SSR) expanded with the evidence that ~69% of AI crawlers do not execute JavaScript, making this the single highest-leverage rule in the file.
- `payload/RULE-docs.md` B1 (renamed "Plan lifecycle & Filename Rules"): no date prefixes in doc filenames (record dates in metadata instead); prioritize creating a `docs/plan/` entry for any code/architectural change, naming it with the target version increment when execution can't wait for the plan.
- `payload/RULE-release.md`: new tag-gating bullet — skip tag creation entirely if the project has never tagged (`git tag -l` empty), leave CHANGELOG/releases.json/GitHub Release as the sole authority. B1's boundary-commit step 4b rewritten from "git tags" to a stack-specific **production baseline verification** (App: remote tags + GitHub Releases; Web/AkiNuxtCf: remote `releases.json` / remote tags) — reflects that local tags can't be trusted alone. A5 marked `<!-- A5 under review -->`, pointing at new `docs/plan/release-a5-review.md` (its content is not summarized here — the review is still open).
- `payload/RULE-ui-pattern.md` new §A4 "Framework-native scale first": check the framework's own default scale (`text-sm`, `rounded-lg`, …) before minting a custom design token; never duplicate a framework scale "for consistency" — that is itself a Law 1 (SSoT) violation. When cleaning up scattered ad-hoc values, snap each to the nearest existing step by midpoint rather than minting one token per raw value found in the wild, and treat a repeated drift pattern across multiple pages as one systemic token-layer gap rather than N one-off fixes.

### Fixed — `install.sh` Antigravity skill delivery
- `install.sh`: Antigravity skill delivery was broken — `skills.json` used `~/.aki/claudedoc/agskills` (tilde path) which AG's JSON parser does not expand. Skills were invisible to all three AG surfaces despite being on disk.
- `install.sh`: `skills.json` now registers both the absolute path (`/home/<user>/.aki/claudedoc/agskills`) and the tilde path as fallback.
- `install.sh`: Added primary skill delivery via direct rsync to `~/.gemini/config/skills/` (Standard Global Customizations Root), bypassing `skills.json` entirely for native auto-discovery. Belt-and-suspenders: native root for guaranteed discovery, `skills.json` as secondary.

### Changed
- `install.sh`: `trigger: glob` rules (`stack-tauri`, `stack-akiNuxtCf`) confirmed working correctly — they are intentionally absent from the initial context dump (token budget optimization) and only injected when the user interacts with files matching the glob pattern (`.rs`, `.vue`, `tauri.conf.json`, etc.).

### Verified
- Cross-platform verification of full AkiClaudeDoc install across 4 surfaces: AG IDE (Mac), AGY CLI (Linux), Claude Code (Mac), Claude Code (Linux). All 5 custom skills (akigitcommit, akihelp, akihtmlreport, akirule, akithink) confirmed loaded. All 13 rules confirmed deployed with correct trigger types (1 always_on, 10 model_decision, 2 glob).

### Note
- The 2026-07-22 entry below had mislabeled a `payload/GEMINI.md` directive number (said `11`, file has `10`) — corrected in place. The 2026-07-21 (2) entry's claim that directives `7`/`8` are the no-trailer rule / named-local-corpora is now stale (later directive insertions shifted numbering; the standalone no-trailer directive no longer exists as its own item, only as a mention inside the `10` audit checklist) — flagged inline rather than silently rewritten, since it's unclear whether dropping the standalone directive was intentional.

## 2026-07-22

### Added
- `install.sh`: the rule corpus is now installed to `~/.gemini/config/rules/akirule-*.md` as **native Antigravity rules**, read by all three surfaces (AG desktop, AG IDE, AGY CLI). Verified by canary before implementing, and verified after: `agy` launched from an unrelated empty directory quotes the marker, confirms the no-trailer rule, and lists the on-demand rules by name. `RULE-agent-behavior` gets `trigger: always_on`; the rest get `trigger: model_decision` with a generated description — Antigravity silently truncates customizations past an internal budget, so unconditional loading is spent on behavior rules only. Frontmatter is generated at install time so `payload/` stays agent-neutral (Claude Code has no equivalent concept). Files are namespaced `akirule-*` and pruned before each install so renamed or dropped rules do not linger.
- `payload/GEMINI.md`: `0. PRIME DIRECTIVE` (stay inside the requested scope), restated as `3` and `4`. The repetition is deliberate and documented as such at the top of the file — acting outside the requested scope is the most expensive observed failure mode, so the prohibition is placed first and re-asserted rather than stated once. Also `10` — at every high-stakes milestone (long plan finished, release, deploy) the agent must end with a prominent warning block handing the user a ready-to-paste prompt for an independent final audit covering rule compliance, gaps/edge cases, and code quality (clean code, SOLID, DRY, native logic flow), explicitly requiring both under- and over-engineering to be reported. (Corrected 2026-07-23: this was mislabeled `11` — the file has 11 directives numbered `0`–`10`, not 12.)
- `docs/plan/antigravity-rule-delivery.md`: the full plan for serving rules to Antigravity — three surfaces, the two discovery systems, the trigger enum, the silent truncation budget, hooks, the `skills.json` inheritance approach, and an AG-specific writing style derived from the vendor's own built-in skills.

### Fixed
- `docs/arch/rule-delivery-architecture.md`: the Gemini side was described as an `@import` in both the prose and the mermaid diagram, and carried an "open verification: does the Antigravity IDE honor imports?" risk. The installer has always concatenated `GEMINI.local.md` verbatim, so the risk never existed. Corrected in both places.
- `docs/research/antigravity-rule-discovery-architecture.md`: added a verification-status banner separating what is empirically confirmed (`~/.gemini/GEMINI.md` is loaded by all three surfaces) from what is not (the claimed `GEMINI.md`-over-`AGENTS.md` precedence, which the vendor's bundled spec contradicts by treating both as the same customization type). Also removed a hardcoded machine path from a public doc.

## 2026-07-21 (2)

### Added
- `payload/RULE-agent-behavior.md`: new `B4` — **no model-credit trailers in git artifacts (ABSOLUTE)**. Promoted from a single bullet buried in `B1` (scope discipline) to its own addressed item, because it kept being violated in practice. Root cause: several agent harnesses inject a *standing system-level instruction* to append `Co-Authored-By:` / session-URL / "Generated with …" lines to every commit and PR body; a lone bullet in a rule file loses to a system prompt. `B4` therefore states explicitly that it **overrides the harness default**, enumerates every forbidden variant, gives the accountability rationale (commit history records which human approved the change; a model trailer corrupts `git blame`/`shortlog` attribution and leaks conversation URLs into public repos, unremovable without rewriting history), and — instead of relying on memory — prescribes a procedure: strip before `git commit`, verify after with `git log -1 --format=%B`, amend if it slipped through.
- `payload/GEMINI.md`: directives `7` (same no-model-credit-trailer rule, AG wording) and `8` (named local corpora resolve via the machine-local section appended at the end of the file). (Note as of 2026-07-23: later directive insertions shifted numbering and the file no longer carries a standalone no-trailer directive — only a passing mention inside the `10` audit checklist. Flagged for review; not corrected here since it's unclear whether the standalone directive's removal was intentional.)
- `install.sh`: injects a `## 9. Shared rule source` block into `~/.gemini/GEMINI.md` with this machine's real `.source-repo` / `install.sh` paths — the AG-side mirror of the block already injected into `~/.claude/CLAUDE.md`. AG has no reliable soft import, so the paths are written in literally.

### Changed
- `claude/CLAUDE.md`: "editing shared rules" no longer says the source location "varies per machine — ask the user". `install.sh` has always recorded the absolute path in `~/.aki/claudedoc/.source-repo`; the guidance now points at that file (ask only if the recorded path is gone) and adds an explicit step to **read `<source-repo>/CLAUDE.md` before editing** — it lists the files that must be updated together, and it is *not* auto-loaded when the request arrives from another project's working directory. New "Named local corpora" section: corpora referred to by short name resolve via `~/.claude/CLAUDE.local.md` (machine-specific, deliberately not in this shared file).
- `payload/GEMINI.md`: header note corrected — `GEMINI.local.md` is **appended verbatim** by the installer, not soft-imported. (The earlier `@import` wording described a mechanism that was never used, and whose support in the Antigravity IDE was unverified.)
- `GEMINI.md` (per-project bootstrap template): the recovery instruction no longer tells the agent to auto-execute a hardcoded `~/.aki/claudedoc/install.sh` — **that path never existed**, the installer is not deployed there, so the instruction always fell through to its "clone from GitHub and run it" branch. Rewritten around the actual root cause of the ask/don't-ask gate: running an *already-present local* `install.sh` (path from `.source-repo`) is reversible and backed up, so the agent proceeds without asking; *cloning and executing unreviewed remote code* is a different class of action and stays the user's call.
- `payload/RULE-design-core.md`: `A7` now declares itself the **root rule for naming** and enumerates its domain applications (`agent.C1`, `ui.A`, `stack.C1`, `release.A3`, `content.A3`), which must stay in their own files.
- `payload/RULE-coding.md`: `B1`'s "use clear, descriptive names" removed — it was an empty restatement of `design.A7`; replaced by a pointer.
- `payload/index.md`: new **Cross-cutting lens** section — an address map (addresses only, never rule text) for subjects that legitimately span several files, seeded with `Naming`. Rejected the alternative of extracting a new `RULE-naming.md`: the scattered naming items are *domain applications*, not duplicates, so a new file would have removed nothing and made naming live in six places instead of five, plus one more router signal that can fail to fire.

## 2026-07-21

### Added
- `payload/GEMINI.md`: new managed source file for Antigravity/Gemini global behavior overrides, installed to `~/.gemini/GEMINI.md` (not synced into the rule corpus). Six hard-loaded directives patch Antigravity's known weak spots — unrequested `implementation_plan.md`/`task.md`/`walkthrough.md` artifacts, over-engineering, hallucination, verbosity, plus command transparency and an ambiguity/safety gate. Rationale: Claude Code loads the rule corpus via harness-guaranteed `@`-imports (0 soft hops); Antigravity has no such loader, so behavior rules must sit in the one file it *does* hard-load globally, rather than depending on a chain of "please read" pointers the model can skip. Line 1 carries a version marker `[AKIRULE-AG-OVERRIDES-<version>]` so a per-project bootstrap can detect whether the overrides are present. The file ends with `@~/.gemini/GEMINI.local.md` for machine-local facts.
- `install.sh`: new block installs `payload/GEMINI.md` to `~/.gemini/GEMINI.md`, stamping the version marker (`V<date>[-<git-hash>]`) in the same pass. Mirrors the existing CLAUDE.md/CLAUDE.local.md pattern: timestamped backup + pruning, and a sibling `~/.gemini/GEMINI.local.md` that is created only if missing and never overwritten. An existing unmanaged `GEMINI.md` (no marker) is backed up and replaced; the installer does **not** parse its contents — there is no universal way to know where an arbitrary user's machine-local section begins, so it never guesses by heading name. Because this install is usually driven by an AI agent (which *can* judge content semantically), it instead prints a strong, explicit directive telling the running agent to read the backup and the managed file and append **only the non-duplicate** machine-local lines into `GEMINI.local.md` (append-only, backup preserved — safe to do without a confirmation round-trip). `GEMINI.md` is excluded from the payload rsync so it never lands in the installed rule corpus.

### Docs
- `docs/arch/rule-delivery-architecture.md`: new architecture doc (with mermaid flowcharts) covering the Claude-Code-vs-Gemini loading asymmetry, the managed/`.local.md` split, the two install scenarios, the agent-driven de-duplication directive, and the version marker.
- `README.md`: repository layout, "What the installer does" (step 7 + a "Gemini / Antigravity model" note), and uninstall updated for the new `~/.gemini/GEMINI.md` target.

## 2026-07-19 (2)

### Added
- `payload/RULE-release.md`: new `A5` — a version number is minted at the **release event** (production deploy / published tag / distributed build), never when a piece of work is finished. Between releases the accumulation lives under `## [Unreleased]` with no version number and no manifest bump; the release task renames that heading and bumps once. Closes a real gap: `B1` only guaranteed *one bump per cycle*, so several sessions of local improvement each bumped legitimately and the local version drifted far ahead of what was actually shipped — production on `0.1.0` while local sat at `0.3.4`, then a deploy dumped a stack of thin versions on users at once. Adds a materiality test (don't mint a version for one or two trivial internal lines) and a recovery path: versions never published are **not** covered by `B3`'s "never renumber public versions", so they can be squashed back and re-minted as one. `B1`'s state table gains an `Unreleased open` row (normal working state) and a `Drifted` row (manifest ahead of last deployed version → run the A5 recovery first).
- `payload/index.md`: `RULE-release.md` manifest description extended to mention the release-event minting rule.

## 2026-07-19

### Changed
- All 13 `payload/RULE-*.md` / `METHOD-*.md` files: restructured into internal groups `A`/`B`/`C` with numbered items `1`/`2`/`3…` (no content added or removed, no file renamed). Gives every rule a stable, recallable address (`topic.A1`, e.g. `coding.B2`, `stack.C1`) for a user juggling many projects at once. `payload/index.md` gains a Topic/Loại column and the full group map; `claude/skills/akirule/SKILL.md` documents the addressing scheme (routing logic itself is unchanged); `README.md` documents the scheme for public readers.
- `RULE-seo.md`, `RULE-release.md`, `RULE-stack-akiNuxtCf.md`: the content specific to Aki's own AkiNuxtCf ecosystem (rather than universal for any project) is now isolated into each file's last group, logically flagged `⟨Aki⟩` (`seo.C`, `release.C`, `stack.C`). This repo predates `AkiNuxtCf/UNIDOC` (Aki's private ecosystem-standards repo) and had accumulated ecosystem-specific content without a clear boundary from universal rules. Decision: keep everything in this repo with auto-load rather than relocating to UNIDOC or gating behind an explicit trigger — Aki is this repo's heaviest user and the convenience of automatic reminders outweighs a physically clean public/private split. The `⟨Aki⟩` flag is documentation-only for now (marks what a future stripped public export would drop); no automatic filtering mechanism yet. Full decision record: `docs/research/public-private-abc-restructure.md`.

## 2026-07-18

### Changed
- `payload/RULE-stack-akiNuxtCf.md`: public/private boundary cleanup + restructure (no rule content added or removed):
  - Removed private-corpus leaks unusable by public readers: the `UNIDOC STANDARD.md §2.4` citation and lock date on the build-date-stamp rule (technique kept, now described generically), the undefined `[DESIGN-LOCK]` tag, the project-specific `que`↔`iching` slug example (replaced with a neutral `bai-viet`↔`articles` pair), and the unexplained "akinuxtstack" name (now "this stack").
  - Deduplicated `trailingSlash: true` from three in-file statements down to one canonical spot (the i18n section's config block); the Cloudflare-constraints bullet now points there.
  - Moved the six admin-related bullets (English-only + `i18n.pages` routing, `localePath()` undefined-href trap, layout isolation, feature-area routing, listener cleanup) out of "Rendering" into their own "Admin UI" section; merged the two `aki-info-detect` bullets into a "Client detection" section with a link to the public npm package.
  - Merged the three adjacent layout sections (canonical component names, layout chrome, layout width) into one "Layout" section with subsections; merged the two SSR-guard bullets; shortened the favicon-generator recommendation to its essentials.
- `payload/RULE-agent-behavior.md`: new "File formatting" section — do not auto-wrap a line just because it is long; keep one logical bullet/sentence per physical line, and only break lines for genuinely intentional structure (tables, code blocks, nested sub-bullets). Match the existing file's own wrapping convention when editing it. Added after a rule-cleanup pass introduced unintended mid-sentence line wraps that the user then had to flag and have reverted.
- `install.sh`, `claude/hooks/aki-update-check.py`: translated all Vietnamese console output (status checks, install summary, confirmation prompt, update-check banner) to English — this repo is public, so its runtime output should not assume a Vietnamese-reading operator. Colors/emoji/logic unchanged.

### Added
- `payload/RULE-stack-akiNuxtCf.md`: added a rule to pin `packageManager` and `engines.node` in `package.json` to match the Cloudflare Pages build image, and to regenerate lockfiles via `npx npm@<pinned_version> install` before committing to avoid version drift with optional peer dependencies.
- `payload/RULE-agent-behavior.md`: new "Memory discipline" section — never write, update, or delete a persistent memory (any memory file or the `MEMORY.md` index) on your own initiative; always ask the user first. Only persist when the user explicitly asks, or after proposing a specific memory and getting approval. Recalling/reading existing memory needs no permission — the gate is on writing. Originated from a memory-cleanup pass across the Aki projects where the user found that self-initiated memory writes had accumulated a large amount of redundant/stale notes (facts already covered by AkiClaudeDoc / UNIDOC / project `CLAUDE.md`).

## 2026-07-16

### Added
- `payload/RULE-stack-akiNuxtCf.md`: new "Layout width — single source of truth" section — the layout's outer content wrapper (e.g. `max-w-7xl mx-auto px-4 sm:px-6 lg:px-8`) is the only place page/content width is decided; pages and app/tool pages must never put their own `max-w-*`/custom `max-width` on their outermost element, and any that already do must be deleted so they inherit the layout's width instead. Carves out the standard exception for inner reading-measure/widget elements (intro paragraph, search box, article prose column), which is typography sizing, not page layout. Traced to a real incident in `app.akinet.me`: articles hub/detail, the releases page, `me.vue`, and all 10 mini-apps had each independently picked a `max-w-*` value (`max-w-3xl` through `max-w-7xl`, plus one page with a scoped-CSS width fully disconnected from the layout) nested inside the layout's own wrapper, silently narrowing/drifting per route with no functional reason.
- `payload/index.md`: extended the `RULE-stack-akiNuxtCf.md` manifest description to mention layout width (single source of truth in the layout, pages/apps never redeclare `max-w`).

## 2026-07-13

### Changed
- `payload/RULE-coding.md`: replaced the single "read enough surrounding context" bullet with a "Changing existing code" section giving a before/after procedure for editing code you didn't just write — read referenced docs and code before changing (Chesterton's Fence), then confirm untouched intents/flows still hold after the change (a fix scoped to problem X must not silently break unrelated property Y).

## 2026-07-12

### Changed
- `payload/RULE-docs.md`: added `docs/biz/` as a standard, MANDATORY top-level doc topic — the business backbone (identity, USP, positioning, monetization) for any project with a business dimension. Added a "Business backbone" section making it the spine that all `arch/`/`feat/`/`plan/` product/money docs must reference, and the tie-breaker when code intent and a `biz/` doc disagree (the `biz/` doc wins). Originated from the vstshop.com repositioning work, where business strategy became the declared backbone.
- `payload/index.md`: updated the `RULE-docs.md` manifest description to note the mandatory `docs/biz/` backbone.
- `payload/RULE-stack-akiNuxtCf.md`: documented a new gotcha under the admin-SPA / `i18n.pages[x] = false` guidance — once a route is removed from i18n routing, links to it must use a plain string `to="/..."`, never `localePath()`/`switchLocalePath()`. `localePath()` silently returns `undefined` for such a route (no error, no console warning), so `<NuxtLink :to="undefined">` renders an `<a>` with no `href` at all — a link that looks correct in code review but never navigates. Traced to a real incident in `app.akinet.me` (sidebar `/me` link copied from `kinhdich.akinet.me`, where `/me` keeps normal i18n routing — but `app.akinet.me` disables it via `i18n.pages.me = false`, so the copied `localePath('/me')` call broke silently).
- `CLAUDE.md` (repo root, not `payload/`): added an explicit operating rule — any change to `payload/*` or `claude/skills/*` that adds/removes a topic or changes install behavior must also update `README.md` where it goes stale; `akihelp` reads live installed state so it's exempt from manual content updates; `CHANGELOG.md` must be updated for every `payload/`/`claude/` change. Closes the gap where the `docs/biz/` rule change above shipped without a README/CHANGELOG pass until the user asked for it.

## 2026-07-11

### Added
- `docs/research/versioning-critique-akithink.md`: structured decision record (/akithink) analyzing and refining the versioning rewrite proposal.

### Changed
- `payload/RULE-release.md`: rewrote the versioning rules to use cold-start version reconstruction (unbounded git log checks with robust boundary commit fallbacks), severity-driven bump logic, and a legacy audit mode. Hardened the rewrite: restored the Pre-bump/Mid-release/Mismatch state table (double-bump guard), made the CHANGELOG-diff pickaxe (`git log -S`) the primary boundary-commit anchor with fixed-string message grep demoted, added user confirmation on ambiguous fallback, a fresh-repo case, the smaller-level tie-breaker, and an audit-mode rule against inventing unknown historical content.
- `payload/index.md`: updated manifest description for `RULE-release.md` to reflect cold-start versioning and audit mode.
- `payload/RULE-stack-akiNuxtCf.md`: documented the `__BUILD_DATE__` (footer build stamp) standard, specifying build-time JS computation via `vite.define` and client-side rendering within `<ClientOnly>` to avoid hydration mismatches.

## 2026-07-10

### Added
- `payload/RULE-design-core.md`: new Contextual (high-sensitivity) rule — the universal, stack-agnostic pattern-design philosophy (SSoT, Rule of Three, SRP "and"-test, OCP, composition over duplication, module boundaries, name-by-role, anti-patch). Sharpens `RULE-coding.md` without restating it and defers UI-specific enforcement to `RULE-ui-pattern.md`. Registered in `index.md`, the akirule Tier 2 signal block, and `README.md`.
- `payload/RULE-ui-pattern.md`: new Contextual rule — the frontend enforcement of `RULE-design-core.md` (4-tier class taxonomy, design tokens as the single source for visual values, arbitrary-value policy, atomic component structure, variant API, and a UI audit/refactor playbook). Registered in `index.md`, the akirule Tier 2 signal block, and `README.md`.

### Changed
- Tier vocabulary normalized to exactly three canonical labels — **Core / Contextual / Analytical** — across `payload/index.md`, `README.md`, `claude/skills/akirule/SKILL.md`, and the rule headers. Dropped the drift-prone variants "Core-adjacent" (`RULE-design-core.md` is Contextual high-sensitivity) and "Optional/Contextual" (`RULE-db-design.md` is Contextual), so every label now matches the actual routing mechanism. `RULE-design-core.md` is Contextual, not Core, on purpose: embedding it in Tier 1 would tax every conversation for every user; its near-universal reach is served by broad signals instead.
- `README.md`: added `RULE-design-core.md` and `RULE-ui-pattern.md` to both the tier list and the repository-layout tree (they were missing); rewrote the routing section so its "three tiers" match `akirule/SKILL.md` exactly — Tier 1 Core (embed), Tier 2 Contextual (contextual rules plus the signal-loaded analytical methods), Tier 3 Full-load on explicit command — instead of mislabeling the analytical methods as "Tier 3".
- `install.sh`: the post-install "Rules deployed" summary parser now accepts multi-word tier cells (regex `(\w+)` → `([^|]+?)`, plus a tolerant color lookup), so rows like `RULE-design-core.md` and `RULE-db-design.md` are no longer silently dropped from the printed manifest.
- `claude/skills/akihtmlreport/SKILL.md`: never `Read` an existing `REPORT.html` (it is large, dense HTML and the skill always regenerates it wholesale) — inspect metadata only; a stale file (older than ~12 h) is deleted without reading, a recent one still prompts. The generation timestamp is computed in UTC and rendered in the viewer's local time via inline JS; a compact table of contents with per-section `id` anchors is required at the top; a short final-summary section is now mandatory at the end. Evaluation reports (refactor/code-review/strategy/idea assessments) must also surface each item's side effects and edge cases as a first-class element, keep the MVP recommendation as the headline, and split autonomous-decidable from needs-user-decision. Added an optional glossary/notes appendix as the very last section for reports leaning on jargon or abbreviations.
- `.gitignore`: ignore the disposable `REPORT.html` visual export.
- `payload/RULE-coding.md`: expanded the lone `atob()` note into a **Unicode / UTF-8 safety** subsection — base64/JWT decoding via `TextDecoder`, NFC normalization before compare/store/dedupe/ keys, byte (not `str.length`) measurement for size and length limits, and codepoint-safe truncation.
- `payload/RULE-stack-akiNuxtCf.md`: expanded the Cloudflare/Workers Unicode note — decode Firebase/JWT payloads via `TextDecoder` (with an explicit "corruption is an app-layer bug, D1 stores the bad bytes faithfully" clarification), percent-encode non-ASCII header/cookie values, count response size / `Content-Length` in bytes, and feed `crypto.subtle` encoded bytes.
- `payload/RULE-db-design.md`: added section 5 "The DB is not your Unicode safety net" — SQLite/D1 stores UTF-8 faithfully but does not prevent mojibake (fixed at the decode/compare layer per `RULE-coding.md`); the one schema-level concern is using `utf8mb4`, never 3-byte `utf8`, on MySQL/MariaDB.
- `payload/METHOD-deep-think.md`: added Module 5 "MVP focus, side-effects & edge-cases weighed by severity" — an evaluation discipline (not business-gated, unlike Module 4). The MVP keeps the focus of effort, but SFX/EC are weighed by severity, not sequence: it is a feedback loop, not a one-way pipeline, so a material side-effect/edge-case can reshape or reopen the MVP itself. Scoped to the four cases of *discussing or evaluating* (not executing) a refactor, a code review, a strategy/plan, or an idea; trivial risks named out-of-scope, severe ones promoted immediately. On promotion, the agent resolves what first-principles/critical-thinking can settle (decide + report) and escalates to the owner only for genuine owner-calls (irreversible / cross-boundary / unverifiable) per `RULE-agent-behavior` Decision boundaries — not for what basic reasoning settles.
- `claude/skills/akirule/SKILL.md`: `METHOD-deep-think` now auto-loads on evaluation/discussion signals (`evaluate`, `assess`, `worth refactoring`, `side effect`, `edge case`, `đánh giá`, `bàn luận`, `đánh giá ý tưởng`, `đánh giá chiến lược`, …) so Module 5 fires on the four cases.

## 2026-07-08 (2)

### Added
- `payload/METHOD-deep-think.md`: replaces `METHOD-techbiz-optimizer.md` as the single analytical brain for deep thinking, consumed two ways — **passive** (akirule auto-loads it inline on matching signals) and **active** (`/akithink`). Restructured into 4 modules: Module 1 goal excavation (climb the goal hierarchy to the ultimate goal, flag conflicting goals), Module 2 first principles (facts / real constraints / assumptions, reusing the old file's "Problem truth" / "Assumptions" / "Flow" material), Module 3 critique (mandatory adversarial pass — steelman, attack-the-favored-option, inversion, pre-mortem, second-order effects, anti-sycophancy rule), Module 4 techbiz lens (conditional — the old file's value/effort/scope/cost/alternatives/ validation/decision-test/red-flags content, applied only when business/product context exists). Adds a one-way-door vs two-way-door framing and a closing radar rule: passive mode must say "this deserves a dedicated `/akithink` session" rather than settle for a shallow pass on irreversible or goal-ambiguous decisions.
- New skill `akithink` (`claude/skills/akithink/SKILL.md`): structured 5-phase deep-thinking session (model check → restate → goal excavation → first principles → mandatory critique → convergence) for big, hard-to-reverse, or goal-ambiguous decisions. Explicit-invoke only, reads `METHOD-deep-think.md` as its toolbox, recommends a top-tier model (Opus/Fable) without blocking, supports a "chốt" escape hatch to jump to convergence, and always proposes a `docs/` decision record on close (plus `/akihtmlreport` when the material is large/complex).
- New skill `akihelp` (`claude/skills/akihelp/SKILL.md`): `/akihelp` renders a live introduction to the whole Aki system (installed skills, the akirule 3-tier router, the deep-think passive/active split, editing-rules discipline) by reading `index.md` and installed skill frontmatters at runtime — never a hardcoded inventory, so it cannot go stale.

### Changed
- Renamed skill `akiadvise` → `akihtmlreport` (`claude/skills/akihtmlreport/SKILL.md`). Output filename `ADVISE.html` → `REPORT.html` everywhere (single-file rule, collision check, `.gitignore` guidance); invocation `/akiadvise` → `/akihtmlreport`; description sharpened to state the single purpose plainly (visualize existing conversation content, no new analysis); "After writing" now opens the file locally (`open REPORT.html` on macOS, `xdg-open` fallback on Linux, falls back to just printing the path) instead of refusing to launch a browser; notes it pairs naturally with `/akithink` Phase 5 output.
- `payload/index.md`: manifest row `METHOD-techbiz-optimizer.md` → `METHOD-deep-think.md` with updated purpose text.
- `claude/skills/akirule/SKILL.md`: Tier 2 signal block renamed `METHOD-techbiz-optimizer.md` → `METHOD-deep-think.md`; added thinking-session signals (`first principles`, `tư duy nguyên bản`, `phản biện`, `mục tiêu tối thượng`, `one-way door`, `quyết định lớn`, `decision record`, `pre-mortem`).
- `install.sh`: added `akiadvise` to the old-skill directory cleanup loop so renamed installs don't leave a stale skill; added an explicit `rm -f` for `~/.aki/claudedoc/METHOD-techbiz-optimizer.md` as a safety net alongside the `rsync --delete` payload sync.
- `README.md`: repo-layout tree, install-target file list, and prose updated for the `akithink`/`akihtmlreport`/`akihelp` skills and `METHOD-deep-think.md`; added a "One brain, two modes" section explaining the passive/active thinking architecture.
- `README.md`: full rewrite for concision — install command leads, skills presented as a table, installer behavior condensed to one numbered list, duplicate install-target section merged into the layout tree. Fixed the layout tree and akirule Tier 2 description, which were missing `RULE-seo.md`, `RULE-release.md`, and `RULE-db-design.md`; uninstall section now covers all five skills and the update-check hook.

## 2026-07-08

### Added
- Notify-only update-check hook (`claude/hooks/aki-update-check.py`), installed to `~/.claude/hooks/` and registered as a Claude Code `SessionStart` hook (`startup|resume`). On session start it compares the installed `CHANGELOG.md` top entry against the public repo copy (`raw.githubusercontent.com/lacvietanh/AkiClaudeDoc/master/CHANGELOG.md`); when the remote is newer it prints a user-visible `systemMessage` with the "what's new" delta, the update command, and the changelog link, and passes the same delta to Claude via `additionalContext`. Fail-silent (any error/offline → exit 0, no output), throttled to once per 24h, and never auto-updates — it only points at `git pull && bash install.sh`. Uses the CHANGELOG top header as the version marker, so there is no separate version file to bump. Does not nag machines whose local changelog is ahead of the remote (dev checkouts).

### Changed
- `install.sh`: copies the update-check hook into `~/.claude/hooks/`, writes `~/.aki/claudedoc/.source-repo` (this machine's source repo path, so the hook can print the correct update command), and registers the `SessionStart` hook in `settings.json` idempotently (drops any prior `aki-update-check` entry before adding the current one). Post-install summary now lists deployed hooks.
- `README.md`: documented the update-check hook in "What the installer does", the repo layout, and the install-target file list.

### Fixed
- `README.md`: one-line install command pointed at the non-existent `main` branch (`raw.githubusercontent.com/lacvietanh/AkiClaudeDoc/main/install.sh` → 404); corrected to `master`, the repo's actual default branch.

## 2026-07-07 (3)

### Added
- New skill `akiadvise` (`claude/skills/akiadvise/SKILL.md`): distills a complex analysis/report already discussed in conversation into a single-file, ultra-wide, visually dense HTML report (`ADVISE.html`, default at project root). Enforces a single-file discipline (one `ADVISE.html` per project at a time — never `ADVISE-2.html`/versioned variants; asks before overwriting an existing one) and only applies to genuinely dense/complex content, never proactively.

## 2026-07-07 (2)

### Added
- `RULE-stack-akiNuxtCf.md`: Admin layout isolation rules in Rendering — the admin layout owns its own chrome (`AdminSidebar.vue`, added to the canonical component names table) and never imports public chrome components; each admin feature area gets its own route under `/admin/**` instead of tab-state inside one page.
- `RULE-stack-akiNuxtCf.md`: New "Dev workflow scripts (package.json)" section — `killport` + `dev` chaining with a pinned per-site dev port; `db.init.local`/`db.push` patterns for projects with a D1 database.

### Changed
- Generalized ecosystem-specific wording so every rule stands alone for public readers: `RULE-stack-akiNuxtCf.md` deploy verification no longer names internal projects; `RULE-seo.md` entity-linking section now describes the parent/sibling pattern generically (concrete domain lists belong in each project's own docs), `/login` indexability is a default rather than a named-org policy, and the validate-seo baseline pointer no longer references an internal repo path. (Intentional exception kept: the AkiTao Favicon Generator tool link.)
- `payload/index.md`: Expanded `RULE-stack-akiNuxtCf.md` manifest description (admin layout isolation, dev workflow scripts).

## 2026-07-07

### Added
- `RULE-stack-akiNuxtCf.md`: New "Deploy verification — push is not done" section — a push only *requests* a Cloudflare build, task isn't closed until the newest build reaches a terminal state. Clarifies that most AkiNet projects deploy via **Cloudflare Pages**, not Workers — the `cloudflare-builds` MCP only covers the Workers Builds API and shows zero builds for a Pages project (confirmed against `kinhdich-akinet` 2026-07-07). Points to `wrangler pages deployment list` or the general-purpose `cloudflare` MCP (`https://mcp.cloudflare.com/mcp`) for Pages projects instead.
- `RULE-release.md`: "Release vs deploy — two different events" section separating release (CHANGELOG/releases.json/GitHub Release, all stacks) from deploy (web build going live, web-only, owned by `RULE-stack-akiNuxtCf.md`).

### Changed
- `RULE-release.md`: Scope widened from "projects with CHANGELOG.md" to **every Aki project, any stack** — `CHANGELOG.md` is mandatory from project creation, a repo without one is broken not exempt. Clarified `releases.json` is web-only (exists only where a public release-notes page renders it); Tauri/CLI/non-web projects keep `CHANGELOG.md` only. "Identify the current version before bumping" now runs per closed problem, not once per session.
- `claude/skills/akigitcommit/SKILL.md`: No-CHANGELOG fallback reframed as exempting only non-Aki repos (every Aki repo must have one). Added "commit unit is one closed problem" rule — a problem's commit includes its code AND its CHANGELOG.md/releases.json entries, never batched into a separate catch-all commit.
- `payload/index.md`: Updated `RULE-stack-akiNuxtCf.md` and `RULE-release.md` manifest descriptions to reflect the above.

## 2026-07-05

### Added
- `RULE-db-design.md`: New optional/contextual rule file — four generalized database design principles (Immutability & Event Sourcing, First Normal Form, Bounded Context/DDD, flat-query discipline). Loads only when designing schema/migrations/DB refactors, not on every task.

### Changed
- `RULE-stack-akiNuxtCf.md`: Added "Build & TypeScript" section (strict TS, `<script setup>` only, relative server imports, clean build logs, duplicate-Vite sourcemap-warning guidance). Added "Canonical component names" section (fixed names for footer/topnav/sidebar/rail-dock/ breadcrumb/auth-util roles). Added "State" section (useState-first, Pinia only when needed, localStorage sync in `onMounted`). Added onUnmounted cleanup requirement for multi-layout admin sites. Added favicon/manifest UI guidance with a link to the AkiTao Favicon Generator tool. Added i18n co-located page-text guidance. Added `aki-info-detect` loading discipline: use only named local-only exports, never default-import or plugin-load the whole library because it starts network lookup; require explicit requests for network features and verify IP-service URLs are absent from the built chunk.
- `payload/index.md`: Added manifest row for `RULE-db-design.md`; expanded `RULE-stack-akiNuxtCf.md` description to mention canonical names, state, and build/TS.
- `claude/skills/akirule/SKILL.md` (source): Added Tier 2 signal block for `RULE-db-design.md`.

---

## 2026-06-28

### Changed
- `RULE-release.md`: Expanded "Identify the current version before bumping" — now requires running three commands (`git log`, `grep package.json`, `grep CHANGELOG.md`) before touching any version. Defines three states: **Pre-bump** (package.json == git → bump once), **Mid-release** (package.json > git → accumulate, do not bump again), **Mismatch** (warn, do not auto-fix). Added bump-level guard: same session features+fixes → minor; unsure → smaller level; no version skipping; do not bump until at least one user-visible change exists.
- `RULE-release.md`: Added **"GitHub Release output"** section — after CHANGELOG update and version bump, automatically output a copy-ready GitHub Release block without waiting for the user to ask. Title: `v{version} — {2–5 word specific impact}`, no generic words. Body mirrors CHANGELOG but one short sentence per bullet, no file paths, no jargon.
- `install.sh`: Replaced machine-local block extraction with a clean two-file model. `CLAUDE.md` is fully managed by installer; machine-local config lives in `~/.claude/CLAUDE.local.md` (never overwritten after first creation). Installer appends `@~/.claude/CLAUDE.local.md` import + machine-local source-path block to `CLAUDE.md` on every run. Creates `CLAUDE.local.md` from template on first install only.
- `README.md`: Updated "What the installer does" and "Install target" to document the `CLAUDE.local.md` pattern. Added "Machine-local configuration" section.

---

## 2026-06-27 (4)

### Changed
- `RULE-release.md`: Added two new sections. **"No version gaps in releases.json"** — every CHANGELOG version must appear in releases.json; internal/technical versions must not be skipped but instead summarized with a brief user-friendly entry (patterns provided for `improved`/`fixed` types). **"Sync check"** — mandatory grep before closing any task touching CHANGELOG or releases.json, confirms no gap and correct newest-first order in both files.

---

## 2026-06-27 (3)

### Added
- `RULE-stack-akiNuxtCf.md`: New "Layout chrome — breadcrumb · back-to-home · scroll-to-top" section codifying the unified layout-chrome standard for every akinuxtstack site, so future work cannot drift it back out of consistency. Locks the invariants learned during the breadcrumb rollout: exactly one layout-level `<Breadcrumb>` owning the VISUAL trail only; dynamic leaf via `useBreadcrumb()` + `<ClientOnly>` SSR fallback (hydration-safe); `BreadcrumbList` JSON-LD owned by the page, exactly once (never the layout, never duplicated when a SEO composable already emits it); crumb links only to real prerendered routes (dead intermediate segments render as plain text to avoid Nitro `no-error-response` 404s); translated-slug link reconstruction (`/en${acc}/`) instead of `localePath()`; a single `<ScrollToTop>` with back-to-home served by the Home crumb. Distilled from vstshop, akinet, akitao, kinhdich (incl. removing kinhdich's `SELF_MANAGED` exception so it fully rejoins the standard).

### Changed
- `payload/index.md`: Extended the `RULE-stack-akiNuxtCf.md` manifest description to mention layout chrome (breadcrumb/scroll-to-top).
- `akirule/SKILL.md` (source): Added Tier 2 keywords to the stack-rule signal block (`breadcrumb`, `scroll-to-top`, `back-to-home`, `layout chrome`, `useBreadcrumb`).

---

## 2026-06-27 (2)

### Added
- `RULE-release.md`: New Contextual rule for Aki projects that ship versioned releases (repo with `CHANGELOG.md` + `CLAUDE.md`, Nuxt or Tauri v2). Defines the two-channel split — `CHANGELOG.md` (technical, English, Keep a Changelog) vs `app/data/releases.json` (public, user-friendly, bilingual EN+VI when the site is multilingual, default EN). Specifies the bilingual `releases.json` schema, semver bump discipline (`major.minor.patch`, one release = one version, no stray bumps), how to identify the current version before bumping (changelog top entry / git tag / session context), and content discipline (no em/en dash, stable terminology). Distilled from the release-notes campaign across vstshop, akinet, akitao, kinhdich.
- `payload/index.md`: Added `RULE-release.md` to the file manifest.
- `akirule/SKILL.md` (source): Added Tier 2 signal block for `RULE-release.md` (keywords release/changelog/version/semver/bump + paths `CHANGELOG.md`, `releases.json`, `pages/releases/**`).

---

## 2026-06-27

### Changed
- `claude/skills/akigitcommit/SKILL.md`: Thêm mode detection — tự check `CHANGELOG.md` trước khi group. Khi có CHANGELOG: dùng domain-grouped mode (group theo object/feature, tối đa 3–5 commits). Khi không có CHANGELOG: giữ nguyên type-grouped mode cũ (feat/fix/refactor). Cập nhật description trong frontmatter.
- `RULE-seo.md`: Sửa hướng dẫn title format — bỏ `| [Brand]` khỏi source title vì `@nuxtjs/seo` tự append qua `titleTemplate`. Thêm section `@nuxtjs/seo — titleTemplate behavior (CRITICAL)` với ví dụ ✅/❌ rõ ràng để tránh double-suffix. Sửa giới hạn `< 60` → `≤ 60`, thêm exception 80-char cho article/post/knowledge slug pages. Cập nhật post-build validation checklist: `>` thay `>=`, decode HTML entities trước khi đo độ dài, skip redirect stubs.
- `RULE-stack-akiNuxtCf.md`: Thêm rule `trailingSlash: true` bắt buộc trong i18n block — không chỉ `router.options` và `site`. Thiếu config này khiến `localePath()` strip trailing slash, gây canonical mismatch warning hàng loạt khi build.
- `claude/CLAUDE.md`: Thêm rule "Editing shared rules — luôn sửa từ source AkiClaudeDoc project rồi chạy install, không sửa trực tiếp vào bản đã install" để AI agent không sửa nhầm deployed copy.

---

## 2026-06-26 (2)

### Added
- `RULE-seo.md`: New Contextual rule covering all SEO concerns — `usePageSeo` API contract, meta title/description limits and formatting, schema.org page-type matrix, Organization required fields, trailing slash, robots/sitemap exclusion, OG image convention, AI/LLM visibility (FAQ structure, DefinedTerm, alternateName), ecosystem entity linking (sameAs, parentOrganization), Vietnamese unaccented keyword handling, post-build validation checklist. Distilled from real patterns across akitao.com, vstshop.com, akinet.me, kinhdich.akinet.me.

### Changed
- `RULE-stack-akiNuxtCf.md`: Removed inline SEO bullet list, replaced with single-line reference to `RULE-seo.md`.
- `payload/index.md`: Added `RULE-seo.md` to file manifest, updated stack rule description.
- `akirule/SKILL.md` (source): Added Tier 2 signal block for `RULE-seo.md`; removed `SEO` from `RULE-stack-akiNuxtCf.md` signals to avoid double-loading now that the stack rule defers to `RULE-seo.md`.
- `install.sh`: UX overhaul — added `print_summary()` with colored post-install table (rules by tier, skills deployed, timestamp + git commit hash); copies `CHANGELOG.md` to `$INSTALL_ROOT/CHANGELOG.md` so any machine can inspect installed version; writes `$INSTALL_ROOT/.version` (installed date, commit, branch); added `prune_backups()` keeping only the 2 most recent backups per file (was accumulating unbounded).

---

## 2026-06-26

### Changed
- `RULE-coding.md`: Added `## Result pattern for external calls` section under Error handling — defines the `Result<T>` type pattern (`{ ok: true; data: T } | { ok: false; error: string }`) with code examples. Establishes the standard for all fallible I/O at system boundaries: composable/service catches once, callers check `.ok` without try/catch.
- `RULE-stack-akiNuxtCf.md`: Added `## External integrations` section — composable-as-boundary rule (pages never import provider SDK directly), domain-based module organization (`useAuth`, `useUser`, `useProjects` instead of god-file), cross-reference to Result pattern.

---

## 2026-06-24

### Changed
- Standardized and improved `GEMINI.md` with professional English phrasing and structured bootstrap directives to align Gemini and Antigravity agents with the `CLAUDE.md` source of truth.

---

## 2026-06-19

### Changed
- Replaced three separate skills (`akidoc-rules`, `akidoc-flow-audit`, `akidoc-techbiz-optimizer`) with a single unified smart-router skill `akirule`.
- `akirule` uses a 3-tier loading strategy: core rules always embedded, additional rules and methods read on demand when task signals match.
- Renamed `SKILL-flow-audit.md` and `SKILL-techbiz-optimizer.md` to `METHOD-flow-audit.md` and `METHOD-techbiz-optimizer.md` to accurately reflect their role as reference frameworks, not skill definitions.
- `install.sh` now removes old skill directories and stale `skillOverrides` entries on upgrade.
- Hardened `install.sh` settings.json writer: `isinstance` guards on all dict/list fields, fixed idempotent read-permission logic.
- Updated global `~/.claude/CLAUDE.md` guidance to reflect `akirule` and the new file naming convention.
- `README.md` expanded to cover architecture, 3-tier router mechanism, file naming conventions, and how Claude Code skills work in this context.
- `CLAUDE.md` (repo root) documents the `RULE-*` / `METHOD-*` naming convention and consistency requirements.

### Added
- Pre-flight inspection in `install.sh` reports old skills that will be deleted and stale `skillOverrides` that will be removed.
- `payload/index.md` documents the Core / On-signal / Method file groupings.

### Removed
- `PLAN.md` removed after completion.
- Empty `scripts/` directory removed.

---

## 2026-05-22

Initial public release.

### Added
- `payload/` rule corpus: `RULE-agent-behavior.md`, `RULE-coding.md`, `RULE-content-write.md`, `RULE-docs.md`, `RULE-stack-akiNuxtCf.md`, `SKILL-flow-audit.md`, `SKILL-techbiz-optimizer.md`.
- Three Claude Code skills: `akidoc-rules`, `akidoc-flow-audit`, `akidoc-techbiz-optimizer`.
- `install.sh` with pre-flight inspection, confirmation prompt, timestamped backups, and `settings.json` management.
- Global `~/.claude/CLAUDE.md` guidance block.
