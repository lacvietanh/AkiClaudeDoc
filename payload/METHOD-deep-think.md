# Aki Method — Deep Think

## Purpose
This is the single analytical brain for structured deep thinking: goal excavation, first-principles decomposition, mandatory critique, and (when relevant) business/product optimization. It replaces the old first-principle/techbiz-only optimizer with a fuller reasoning toolbox.

Technology exists to serve real outcomes. Do not optimize technical elegance in isolation. The goal is not deeper analysis for its own sake — it is a better decision and a smaller, stronger next step, held to scrutiny proportional to how hard the decision is to reverse.

---

## One brain, two modes

This METHOD is consumed two ways:

- **Passive (this file, via akirule):** akirule auto-loads it when a normal task hits a matching signal. Apply the lenses inline, briefly, inside the current answer. Ask at most ONE clarifying question. Never turn a routine task into an interrogation session.
- **Active (`/akithink` skill):** the user explicitly opens a full structured thinking session. That skill runs a 5-phase interactive protocol and uses this METHOD as its toolbox at maximum depth.

Content-wise the active mode is a superset of the passive one; mechanically, only `/akithink` runs the interactive protocol.

---

## One-way-door vs two-way-door

Not every decision deserves the same depth. Before applying any module, size the decision:

- **Two-way-door (reversible, cheap to undo):** a config flag, a copy change, a small refactor behind a feature branch. Decide fast; do not over-apply this METHOD.
- **One-way-door (hard/expensive to reverse):** a schema choice, a public API shape, a pricing model, deleting data, an architecture that many things will depend on. Depth of analysis should scale with irreversibility — go through every module deliberately, and prefer `/akithink` over a shallow inline pass.

---

## Module 1 — Goal excavation

Climb the goal hierarchy. For any stated goal, keep asking "this is for what?" upward (5-whys upward, not downward into implementation) until you reach the goal that no longer has a "so that…" behind it — the ultimate goal.

Questions:
- What is the real goal, stated in one sentence?
- If this works, what concrete result changes in the world?
- Who or what must benefit for this to be worth doing?
- "This is for what?" — repeat until further "why" produces no new information.

Output an **explicit goal chain**: immediate goal → intermediate goal(s) → ultimate goal. Call out any goals in the chain that conflict with each other (e.g. "ship fast" vs "keep it flexible for future X") — do not silently pick one and hide the tension.

---

## Module 2 — First principles

Decompose the problem into three separate buckets and do not let them blur together:

- **Facts** — observed, verifiable. What is definitely real, not interpretation.
- **Real constraints** — things that are actually fixed for this decision.
- **Assumptions** — things being treated as fixed that are not actually verified.

Every claimed constraint must face the question: **"is this a real constraint, or just a habit?"**

### Problem truth
- What problem is definitely real?
- What is observed fact, and what is interpretation?
- Is this a root problem, or only a visible symptom?

### Assumptions
- What assumptions are being treated as fixed?
- Which assumptions came from habit, legacy, fear, or convenience?
- If the current implementation disappeared, what would still be necessary?

### Flow
- What is the natural end-to-end flow?
- Where does the flow break, fork, stall, or require manual coordination?
- Which checks, guards, patches, or workarounds exist only because the flow is poorly shaped?
- What design would make the correct behavior automatic instead of repeatedly enforced?

---

## Module 3 — Critique (mandatory adversarial pass)

This module is not optional and does not depend on business context. Even a personal-tool or research decision gets this pass. Run all five lenses:

1. **Steelman the opposing option.** State the strongest possible case for the option currently being rejected — not a weak strawman.
2. **Attack the favored option.** State at least one concrete way the currently-favored option could be wrong, and how you would know.
3. **Inversion.** "If we wanted to guarantee this fails, what would we do?" — then check whether any of those failure modes are already present.
4. **Pre-mortem.** "Six months from now, this decision turned out to be wrong — why?" Write the plausible failure story, not a vague hedge.
5. **Second-order effects.** What does this change ripple into — other teams, other flows, future maintainers, incentives — beyond the immediate first-order result?

**Anti-sycophancy rule:** no "great idea!"-style agreement without critique. Every option on the table, including the user's preferred one and the agent's own recommendation, gets at least one honest attack before being accepted.

---

## Module 4 — Techbiz lens (conditional)

Apply this module only when the problem has business/product context — value delivered to users/customers, cost/effort tradeoffs, or market-facing decisions. **Personal tools, art projects, and pure research skip this module explicitly** (say so rather than silently forcing a business frame onto a non-business problem).

### Value
- What creates actual value here?
- What is merely nice, familiar, impressive, or technically satisfying?
- If only 20% of the work could remain, which part carries most of the value?

### Simplification
- What is the smallest solution that still solves the real problem?
- What can be deleted, skipped, merged, delayed, or made manual?
- Does this require a system, or only a one-time action?

### Cost
- What does this cost to build and maintain?
- What future complexity does this introduce?
- What hidden burden will this create for debugging, onboarding, operations, or content updates?

### Alternatives
- What are 3 meaningfully different ways to solve this?
- Which option is simplest?
- Which option is easiest to validate and reverse?

### Validation
- What is the fastest credible way to test whether this idea is right?
- What result would prove this direction is worth expanding?
- What result would tell us to stop?

### Decision test
Before recommending a solution, check:

- Can the real goal be stated in 1 sentence?
- Does the solution solve the root problem, not just the symptom?
- Does it make the desired flow more natural?
- Can one layer, dependency, guard, check, or abstraction be removed?
- Is the first version smaller than the imagined final version?
- Is there evidence for the complexity being added?
- Is the next step easy to validate and reverse?

If the answer is unclear, reduce the solution before expanding it.

### Red flags
Stop and rethink when you see these patterns:

- "We might need this later"
- "This is cleaner architecturally"
- "Let us make it flexible now"
- "We should automate everything"
- "This feels more scalable"
- "This avoids future rewrites"
- "Just add a guard/check/fallback"
- "Patch this edge case for now"

These may be correct, but they are not proof. Each one requires evidence, not taste.

---

## Radar rule (passive-mode duty)

When applying this METHOD passively and the decision turns out to be one-way-door (hard to reverse), large in scope, or the goal itself is unclear, do NOT settle for a shallow inline analysis. Say explicitly: "this deserves a dedicated `/akithink` session" and offer to start one.

---

## One-line reminder
Do not optimize the current shape of the solution until you are sure the shape itself is justified.
