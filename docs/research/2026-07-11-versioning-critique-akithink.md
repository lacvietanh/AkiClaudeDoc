# Decision Record: Versioning Rule Rewrite & Robustness Hardening

- **Status:** Approved / Converged
- **Date:** 2026-07-11
- **Participants:** Antigravity (AI) & Aki (Owner)
- **Topic:** Improving versioning and release rule robustness in `RULE-release.md` to prevent skipped versions.
- **Reference Proposal:** [versioning-principle-rewrite.md](file:///Volumes/DEV/AkiClaudeDoc/docs/plan/versioning-principle-rewrite.md)

---

## Phase 1 — Problem Restatement

The current release rule set in [RULE-release.md](file:///Volumes/DEV/AkiClaudeDoc/payload/RULE-release.md) suffers from three core weaknesses:
1. **Cold-Start Fragility:** Capping the git log scan at `git log --oneline -3` causes agents to miss accumulated changes if the release process is spread over multiple days or sessions.
2. **Incorrect Definition of "Skips":** The rule defines "skipping" by the step-increment of the version number (e.g. forbidding `1.4.2 -> 2.0.0` or `1.4.2 -> 1.5.0` directly without justification), rather than by content severity or real gaps in the historical record (missing entries for tags or published releases).
3. **Lack of Legacy Support:** No transition/audit path exists for applying these rules to pre-existing projects with messy historical changelogs.

---

## Phase 2 — Goal Excavation

* **Immediate Goal:** Prevent incorrect or skipped version numbers during code releases.
* **Intermediate Goal:** Create a self-recovering, state-driven versioning protocol that does not rely on developer session memory, can run on any repository stack (web, CLI, desktop), and adapts easily to existing codebases.
* **Ultimate Goal:** Establish a trusted, accurate, and monotonic historical record of project changes (CHANGELOG/Git tags/releases.json) that both users and downstream automated systems can consume without friction or manual auditing.

---

## Phase 3 — First Principles Analysis

### Facts
* Git commit messages, `package.json`, and `CHANGELOG.md` are the only universal local sources of truth in any project.
* A version number is a semantic label representing the cumulative severity of changes since the *last* published version, not the number of commits or sessions.

### Constraints
* The solution must not require external network connections (e.g. checking production URLs) because some projects (CLI, Tauri apps) do not have public endpoints.
* Git log queries must not be completely unbounded (e.g. scanning the entire repository history from scratch) because this causes massive token bloat and slow response times in large repositories.

### Assumptions
* We assume we can find the commit corresponding to the last version in order to run a range log (`git log <last-version-commit>..HEAD`). If we cannot find it, we need a safe fallback.

---

## Phase 4 — Critique (Adversarial Pass)

### 1. Steelman the Opposing Option (Keeping the current `git log -3` cap and strict step-count constraint)
* **Why keep `git log -3`?** It is simple, deterministic, fast, and uses negligible tokens. It works well if releases are strictly linear and made after every single task.
* **Why restrict large jumps?** Forbidding jumps like `1.4.2 -> 1.6.0` prevents agents from accidentally skipping a minor version. (For example, jumping over `1.5.0` to `1.6.0` when no `1.5.0` ever existed is a violation of semver). The constraint was meant to prevent double-bumping.

### 2. Attack the Proposed Rewrite (from [versioning-principle-rewrite.md](file:///Volumes/DEV/AkiClaudeDoc/docs/plan/versioning-principle-rewrite.md))
* **Vulnerability in finding the "Last Version's Commit":** The proposal assumes we can magically find "the commit tied to the last CHANGELOG version". But if there is no matching git tag, and the commit message is messy (e.g. no `release: v1.4.2` message), how does the agent find the start commit?
* **Unbounded git log risk:** If the start commit cannot be found, and we do not cap the search, the agent will scan the entire history of the repository, hitting token limits in large projects.
* **Over-complication:** Running a multi-step audit on every single minor change is slow and wastes tokens.

### 3. Inversion (How to guarantee this fails)
To guarantee the new rule fails:
* Assume a git tag always exists and is formatted exactly as `vX.Y.Z`.
* If a tag or matching commit is missing, let the agent crash or loop infinitely trying to find the boundary commit.
* Fail to specify how to handle fresh repositories (with no commits or no initial version).

### 4. Second-Order Effects
* Changing the shared rule affects all downstream Aki projects. If the new git query is slow or error-prone, it will degrade the developer experience across all active workspaces.
* Therefore, the version lookup algorithm must be extremely robust and have bulletproof fallbacks.

---

## Phase 5 — Convergence & Hardened Recommendations

We accept the proposal but harden it with **concrete, robust fallback mechanisms** to find the last version's commit.

### Hardened Version Lookup Protocol
To find the commit of the last version (`<last-version>`):
1. **Search Git Log by Message:** Run a grep in git log for version tags in messages:
   `git log --grep="<last-version>" --grep="v<last-version>" -n 1 --format="%H"`
2. **Search Git Tags:** If step 1 returns empty, search tags:
   `git rev-parse "v<last-version>" || git rev-parse "<last-version>"`
3. **Graceful Fallback:** If both fail (e.g. no tag, no clear release commit message), **do not scan the entire history**. Fall back to checking the last 20 commits:
   `git log --oneline -20`
   Analyze the recent commits manually and ask the user to confirm the boundary if there is any ambiguity.
4. **Fresh Repo Case:** If the repository has fewer than 5 commits or no versions recorded yet, treat the entire history as the current accumulation.

---

## Proposed Changes to the Rule Files

### [MODIFY] [RULE-release.md](file:///Volumes/DEV/AkiClaudeDoc/payload/RULE-release.md)

Replace lines 29–53 in [RULE-release.md](file:///Volumes/DEV/AkiClaudeDoc/payload/RULE-release.md) with:

```markdown
## Identify the current version — cold-start, not session-memory

Never rely on remembering a prior session. Every time this step runs — 5 minutes
or 5 months since the last run — it must re-derive the correct state from the
repo alone. Run these checks to reconstruct history:

1. Read `package.json` (or equivalent) for the recorded version.
2. Read `CHANGELOG.md` to identify the last documented version (e.g., `<last-version>`).
3. Find the Git commit corresponding to `<last-version>` using this sequence:
   a. Check git log for a release message:
      `git log --grep="<last-version>" --grep="v<last-version>" -n 1 --format="%H"`
   b. Check git tags:
      `git rev-parse "v<last-version>"` or `git rev-parse "<last-version>"`
   c. Fall back to the last 20 commits if the boundary commit cannot be found:
      `git log --oneline -20`
4. Run `git log <boundary-commit>..HEAD --oneline` (or `git log --oneline -20` if using the fallback) to get the complete, unbounded list of accumulated changes since the last release.

## Bump level — driven by content severity, not by step-count

Classify every accumulated change found in the git log:
- breaking / not backward-compatible → major
- new capability, backward-compatible → minor
- fix / internal-only → patch

**New version = last recorded version + exactly one step at the HIGHEST severity found across the full accumulation.** Do not add steps per session or per commit.

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
```

### [MODIFY] [index.md](file:///Volumes/DEV/AkiClaudeDoc/payload/index.md)

Update the description of `RULE-release.md` to:
`Release & Versioning | Contextual | Cold-start version reconstruction, severity-driven bump, audit mode for legacy changelogs.`
