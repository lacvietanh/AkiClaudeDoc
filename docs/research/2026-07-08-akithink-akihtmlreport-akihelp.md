# Spec — akithink / akihtmlreport / akihelp expansion

Status: approved by Aki, ready to execute.
Date: 2026-07-08.
Executor: subagent (full task, end to end).

## Context

This repo (AkiClaudeDoc) is the source of truth for Aki's shared Claude Code rules
and skills, installed via `install.sh` to `~/.aki/claudedoc` (payload) and
`~/.claude` (skills, global CLAUDE.md, hooks). **Edit only source files in this
repo; never edit the installed copies directly.** After edits, run
`bash install.sh` to propagate.

This spec adds a structured deep-thinking system (one METHOD "brain", two
consumption modes), renames the `akiadvise` skill to `akihtmlreport` with
refinements, and adds an `akihelp` skill that introduces the whole Aki system.

All decisions below were made explicitly by Aki in conversation — do not
re-litigate them. Where wording is quoted, use it (or a faithful equivalent).

---

## Task A — rewrite + rename `payload/METHOD-techbiz-optimizer.md` → `payload/METHOD-deep-think.md`

Delete the old file (git mv). The new file is the **single analytical brain**
for deep thinking, consumed in two modes (see architecture note below, which
must appear near the top of the file):

> **One brain, two modes.** This METHOD is consumed two ways:
> - **Passive (this file, via akirule):** akirule auto-loads it when a normal
>   task hits a matching signal. Apply the lenses inline, briefly, inside the
>   current answer. Ask at most ONE clarifying question. Never turn a routine
>   task into an interrogation session.
> - **Active (`/akithink` skill):** the user explicitly opens a full structured
>   thinking session. That skill runs a 5-phase interactive protocol and uses
>   this METHOD as its toolbox at maximum depth.
> Content-wise the active mode is a superset of the passive one; mechanically,
> only `/akithink` runs the interactive protocol.

Structure the body as **4 modules**:

1. **Module 1 — Goal excavation.** Climb the goal hierarchy ("this is for
   what?" repeatedly, 5-whys upward) until reaching the ultimate goal. Output
   an explicit goal chain. Must call out goals that conflict with each other.
2. **Module 2 — First principles.** Decompose the problem into: facts
   (observed, verifiable), real constraints, and assumptions. Every claimed
   constraint must face the question: "is this a real constraint or just a
   habit?" Reuse/adapt the strong material from the old file's sections
   "Problem truth", "Assumptions", "Flow" (the old file content is good — keep
   its voice and its concrete question lists).
3. **Module 3 — Critique.** Mandatory adversarial pass: steelman the opposing
   option; attack the currently-favored option (state at least one way it could
   be wrong); inversion ("how would we guarantee failure?"); pre-mortem ("six
   months later this decision failed — why?"); second-order effects. Explicit
   anti-sycophancy rule: no "great idea!"-style agreement without critique.
4. **Module 4 — Techbiz lens (conditional).** The old file's value/effort/
   scope/cost/alternatives/validation content lives here (sections "Value",
   "Simplification", "Cost", "Alternatives", "Validation", "Decision test",
   "Red flags"). **Apply only when the problem has business/product context.**
   Personal tools, art projects, pure research → skip this module explicitly.

Plus a closing **radar rule** (passive-mode duty):

> When applying this METHOD passively and the decision turns out to be
> one-way-door (hard to reverse), large in scope, or the goal itself is
> unclear, do NOT settle for a shallow inline analysis. Say explicitly:
> "this deserves a dedicated `/akithink` session" and offer to start one.

Also carry over the old file's one-line reminder and distinguish one-way-door
vs two-way-door decisions (analysis depth should scale with irreversibility).

## Task B — new skill `claude/skills/akithink/SKILL.md`

Frontmatter: `name: akithink`, user-invocable (default; do NOT set
`user-invocable: false`). Description must be comprehensive — it's what shows
in the `/` menu and how the model decides relevance. English, faithful to:

> Structured deep-thinking session between agent and human for important
> decisions: restate the problem, excavate the goal chain to the ultimate goal,
> first-principles decomposition (facts/constraints/assumptions), mandatory
> critique (steelman, inversion, pre-mortem), then converge into a decision
> record. For big / hard-to-reverse / goal-ambiguous problems — small inline
> questions are already covered passively by akirule + METHOD-deep-think.
> Recommends running on a top-tier model (Opus/Fable).

Body — the interactive protocol:

- **Phase 0 — model check.** If currently running on Haiku or Sonnet, print a
  recommendation: deep sessions are best on Opus/Fable — suggest `/model` then
  re-invoke `/akithink`. Recommendation only, never block; user may continue.
- **Phase 1 — restate.** Agent restates the problem in its own words; user
  confirms or corrects. Do not proceed on an unconfirmed restatement.
- **Phase 2 — goal excavation** (METHOD module 1).
- **Phase 3 — first principles** (METHOD module 2; module 4 techbiz lens when
  business context exists).
- **Phase 4 — critique** (METHOD module 3). Mandatory, even if user and agent
  already agree.
- **Phase 5 — convergence.** Ends with: decision + rationale + rejected
  alternatives with reasons + assumptions to monitor. Then:
  1. Always propose writing a **decision record** under `docs/` following the
     `RULE-docs.md` conventions (read `payload/RULE-docs.md` to align the exact
     path/lifecycle wording).
  2. If the converged material is large/complex (many decision points, rejected
     options, interlocking tradeoffs), additionally suggest `/akihtmlreport` to
     visualize it. The docs file is the durable source of truth; the HTML is a
     view, not a replacement.

Interaction rules (must be explicit in the skill):

- Pacing: ask 1–2 highest-value questions per turn (AskUserQuestion is fine for
  discrete choices); never dump a questionnaire.
- Escape hatch: the user can say "chốt" (or equivalent) at any time to jump
  straight to Phase 5.
- Anti-sycophancy: same rule as METHOD module 3, restated.
- Anti-overuse guard: state when NOT to use this skill — small, reversible,
  low-cost-of-error decisions should just be decided; passive mode handles
  casual "should we…?" questions inline.
- The skill loads `~/.aki/claudedoc/METHOD-deep-think.md` as its toolbox
  (Read it at session start).
- Explicit-invoke only: no akirule auto-trigger for the skill itself (the
  METHOD has the signals; the skill does not).

## Task C — rename `claude/skills/akiadvise/` → `claude/skills/akihtmlreport/`

`git mv` the directory; update frontmatter `name: akihtmlreport`. Keep the
existing file's discipline (it is well written) with these changes:

1. Output filename: `ADVISE.html` → **`REPORT.html`** everywhere, including the
   single-file rule, collision-check rule, and the `.gitignore` guidance
   (ignore entry becomes `REPORT.html`).
2. Invocation wording: `/akiadvise` → `/akihtmlreport`.
3. Sharpen the description to state its single purpose plainly: visualize a
   complex report that already exists in the conversation as one self-contained
   HTML file — nothing else, no new analysis.
4. **Auto-open after writing:** replace the "do not attempt to launch a
   browser" instruction in "After writing" with: after writing the file, open
   it locally — `open REPORT.html` on macOS, `xdg-open` fallback on Linux; if
   opening fails, just tell the user the path. Keep the rule about never
   publishing/hosting (Artifact is a separate request).
5. Mention it pairs naturally with `/akithink` Phase 5 output (one sentence).

## Task D — new skill `claude/skills/akihelp/SKILL.md`

Purpose: when invoked (`/akihelp`), present a clear introduction to the entire
Aki system so the user can grasp and fully exploit it. Design it to **never go
stale**: instead of hardcoding the inventory, the skill instructs the agent to
read live state and render a summary:

1. Read `~/.aki/claudedoc/index.md` (file manifest + tiers).
2. List `~/.claude/skills/` (installed Aki skills; identify by `aki` prefix).
3. Render a compact overview:
   - **Skills (active, user-invoked):** each aki-skill with its one-line
     description from frontmatter and when to reach for it.
   - **Passive system (akirule):** explain the 3 tiers — core rules always
     loaded, contextual rules auto-loaded by signal, full load via explicit
     phrase ("nạp full", "load all rules"); note `akirule` itself is hidden
     from the `/` menu by design (`user-invocable: false`).
   - **One brain, two modes:** the METHOD-deep-think passive/active split and
     when each fires (short version of the comparison table).
   - **Editing rules:** source repo → `install.sh`; never edit installed
     copies.
4. Keep the whole output scannable — a compact table or short sections, not an
   essay. Respond in the user's language.

The skill file itself should be short; the durable knowledge lives in
`index.md` and the skill frontmatters it reads at runtime.

## Task E — consistency updates (required by repo CLAUDE.md conventions)

- `payload/index.md`: manifest row `METHOD-techbiz-optimizer.md` →
  `METHOD-deep-think.md`, new purpose text ("Deep-think brain: goal excavation,
  first principles, critique, conditional techbiz lens; passive via akirule,
  active via /akithink").
- `claude/skills/akirule/SKILL.md`: rename the Tier 2 section
  `METHOD-techbiz-optimizer.md` → `METHOD-deep-think.md`; keep all existing
  signals and add thinking-session signals (e.g. `first principles`,
  `tư duy nguyên bản`, `phản biện`, `mục tiêu tối thượng`, `one-way door`,
  `quyết định lớn`, `decision record`, `pre-mortem`).
- `README.md`: update repo-layout tree (skills list: akirule, akithink,
  akihtmlreport, akihelp, akigitcommit if present), install-target list, and
  any prose mentioning akiadvise or techbiz-optimizer. Add a short section
  describing the passive/active thinking architecture.
- `install.sh`:
  - The skills loop copies `claude/skills/*/` generically — verify new skills
    are picked up automatically.
  - Add `akiadvise` to the old-skill cleanup list (`rm -rf` loop) so renamed
    installs don't leave a stale skill.
  - **Verify stale payload files:** if the payload copy step does not delete
    removed files, ensure `~/.aki/claudedoc/METHOD-techbiz-optimizer.md` is
    removed on install (add an explicit cleanup similar to the old-skill list).
- `claude/CLAUDE.md` (packaged global guidance): check whether it names any
  renamed file; update if so.
- `CHANGELOG.md`: add a `## 2026-07-08 (2)` entry (repo uses `(n)` suffixes for
  same-day entries) covering all of the above under Added/Changed.

## Task F — install + verify

1. Run `bash /Volumes/DEV/AkiClaudeDoc/install.sh`.
2. Verify: `~/.claude/skills/` contains akithink, akihtmlreport, akihelp (and
   no akiadvise); `~/.aki/claudedoc/` contains METHOD-deep-think.md and NOT
   METHOD-techbiz-optimizer.md; installer summary lists the new skills.

## Task G — commit

Follow the akigitcommit discipline (read
`/Users/aki/.claude/skills/akigitcommit/SKILL.md`): domain-grouped commits
(CHANGELOG present), stage by explicit path, Conventional Commits, **no
Co-Authored-By or model-credit trailers**. Suggested grouping (3 commits):

1. `feat(rules): replace METHOD-techbiz-optimizer with METHOD-deep-think` —
   METHOD file + index.md + akirule SKILL.md signal updates.
2. `feat(skills): add akithink deep-thinking session skill` — akithink +
   related README section.
3. `feat(skills): rename akiadvise to akihtmlreport; add akihelp` — the rename,
   akihelp, install.sh cleanup, remaining README updates.

CHANGELOG.md rides with whichever commit closes the release entry (or split the
entry lines across the commits they describe — keep each commit self-coherent).

**Do NOT push.** Commit only; Aki pushes manually.

## Style notes

- All new files in English, matching the existing corpus voice (short,
  imperative, information-dense; see existing SKILL.md files as models).
- Keep frontmatter descriptions rich — they are the routing surface.
- Do not touch `ref-ECC/`, hooks, or anything not listed above.
