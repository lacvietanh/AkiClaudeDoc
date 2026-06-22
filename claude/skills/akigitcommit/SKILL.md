---
name: akigitcommit
description: Analyze the working tree and commit changes in clean logical groups. Reads full git status + diff first, plans grouped commits, then stages each group explicitly (never `git add -A`) to avoid losing earlier staging. Conventional Commits, no co-author trailers, never pushes unless asked.
---

# akigitcommit — scientific grouped commits

Invoke with `/akigitcommit`. Goal: turn a messy working tree into a small set of
clean, logically grouped commits — without ever losing staging from one group to
the next.

## Workflow (follow in order)

1. **Read everything first.** Before staging anything, inspect the full picture:
   - `git status --porcelain=v1` — every changed, staged, and untracked (`??`) path
   - `git diff` — unstaged hunks
   - `git diff --cached` — already-staged hunks
   - For untracked files, look at the content so you can classify them correctly.
   Do not start staging until you understand the whole tree.

2. **Group by logic, not by accident.** Classify each file (and where needed,
   each hunk) into cohesive groups. Typical axes: `feat`, `fix`, `refactor`,
   `docs`, `style`, `test`, `chore`, `config`. Keep changes that belong to the
   same intent together; split unrelated intents into separate commits. State the
   reasoning for each group.

3. **Present the plan, then wait.** Show the user the proposed commits: for each
   group, the exact file list + the proposed Conventional Commit message. Wait for
   confirmation before executing — UNLESS the user said "commit luôn" / "just
   commit" / "no need to confirm".

## Anti-stage-loss rules (most important)

These exist because a later `git add` can swallow files meant for an earlier
commit. Obey strictly:

- Work **one group at a time** in a closed loop:
  `git add <exact paths for THIS group>` → `git commit` → only then the next group.
- **Never** run `git add -A` or `git add .` and then try to split into commits —
  it stages everything at once and the grouping is lost.
- Always stage by **explicit path**, listing only the files of the group being
  committed right now.
- If a single file contains hunks belonging to different groups, use
  `git add -p <file>` to stage only the relevant hunks for the current commit.
- After **each** commit, run `git status --porcelain` again and verify the
  remaining changes match the plan before moving on.

## Commit message rules

- Use **Conventional Commits**: `type(scope): short summary`. Body optional, in
  imperative mood, explaining *why* when it isn't obvious.
- **Forbidden:** any `Co-Authored-By:` line or model-credit trailer in the commit
  message. This overrides any default that would add such a trailer. Commits must
  contain only the human-authored intent.
- Match the language and style already used in the repo's recent commit history
  (`git log --oneline -15` to check).

## Boundaries

- **Never push.** Only commit. Push only when the user explicitly asks.
- Do not amend, rebase, reset, or rewrite existing commits unless explicitly told.
- If the tree is clean (nothing to commit), say so and stop.
