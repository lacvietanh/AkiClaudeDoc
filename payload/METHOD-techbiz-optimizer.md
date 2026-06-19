# Aki Skill — First Principle Thinking Optimizer

## Purpose
Use this skill when a task looks bigger, slower, more expensive, or more complex than it should be.

This skill questions assumptions, reduces unnecessary scope, and finds the smallest strong next step that creates real-world value.

Technology exists to serve real outcomes. Do not optimize technical elegance in isolation.

The goal is not deeper analysis for its own sake. The goal is a better decision and a smaller, stronger next step.

---

## When to use
Use this skill when any trigger appears:

- Value is unclear
- Scope keeps expanding
- Complexity grows faster than benefit
- Architecture appears before evidence
- Automation appears before proven need
- Performance work starts before the bottleneck is proven
- A workflow has too many steps, layers, guards, checks, or patches
- The current solution feels hard to explain without long justification

---

## Core mindset
Do not start from the current solution.
Start from the real goal, then derive the simplest flow that naturally serves it.

A strong design makes the right path native.
It should reduce patches, redundant guards, manual coordination, and accidental complexity.

Do not ask first:
- "How do we improve this implementation?"

Ask first:
- "What problem must actually be solved?"
- "What outcome matters in reality?"
- "What flow would make the correct behavior natural?"
- "What assumptions are we accidentally treating as fixed?"

---

## First-principles questions

### 1. Goal
- What is the real goal?
- If this works, what concrete result changes?
- Who or what must benefit for this to be worth doing?

### 2. Problem truth
- What problem is definitely real?
- What is observed fact, and what is interpretation?
- Is this a root problem, or only a visible symptom?

### 3. Assumptions
- What assumptions are being treated as fixed?
- Which assumptions came from habit, legacy, fear, or convenience?
- If the current implementation disappeared, what would still be necessary?

### 4. Flow
- What is the natural end-to-end flow?
- Where does the flow break, fork, stall, or require manual coordination?
- Which checks, guards, patches, or workarounds exist only because the flow is poorly shaped?
- What design would make the correct behavior automatic instead of repeatedly enforced?

### 5. Value
- What creates actual value here?
- What is merely nice, familiar, impressive, or technically satisfying?
- If only 20% of the work could remain, which part carries most of the value?

### 6. Simplification
- What is the smallest solution that still solves the real problem?
- What can be deleted, skipped, merged, delayed, or made manual?
- Does this require a system, or only a one-time action?

### 7. Cost
- What does this cost to build and maintain?
- What future complexity does this introduce?
- What hidden burden will this create for debugging, onboarding, operations, or content updates?

### 8. Alternatives
- What are 3 meaningfully different ways to solve this?
- Which option is simplest?
- Which option is easiest to validate and reverse?

### 9. Validation
- What is the fastest credible way to test whether this idea is right?
- What result would prove this direction is worth expanding?
- What result would tell us to stop?

---

## Decision test
Before recommending a solution, check:

- Can the real goal be stated in 1 sentence?
- Does the solution solve the root problem, not just the symptom?
- Does it make the desired flow more natural?
- Can one layer, dependency, guard, check, or abstraction be removed?
- Is the first version smaller than the imagined final version?
- Is there evidence for the complexity being added?
- Is the next step easy to validate and reverse?

If the answer is unclear, reduce the solution before expanding it.

---

## Red flags
Stop and rethink when you see these patterns:

- "We might need this later"
- "This is cleaner architecturally"
- "Let us make it flexible now"
- "We should automate everything"
- "This feels more scalable"
- "This avoids future rewrites"
- "Just add a guard/check/fallback"
- "Patch this edge case for now"

These may be correct, but they are not proof.
Each one requires evidence, not taste.

---

## Output format
When using this skill, produce output in this structure:

### 1. Real goal
One short paragraph.

### 2. Confirmed problem
Facts only.

### 3. Flow diagnosis
Where the current flow breaks, stalls, forks, or needs patches.

### 4. Assumptions to challenge
Bullets.

### 5. Simplest viable path
One recommended direction, including why this path wins.

### 6. What to avoid
Bullets.

### 7. Fastest validation
The smallest credible next step.

---

## Next step
If the result is actionable, move to execution, architecture, or implementation planning with the reduced problem statement — not the original inflated framing.

---

## One-line reminder
Do not optimize the current shape of the solution until you are sure the shape itself is justified.
