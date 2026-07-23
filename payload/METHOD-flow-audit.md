# Aki Skill — Flow Audit

<!-- Address map: flow.A1-2 · flow.B1-8 · flow.C1-3 -->

## Purpose
Use this skill to inspect a system, feature, user journey, or internal process through the lens of flow integrity.

This skill finds where a flow is naturally strong, where it breaks, and where the current design depends on patches, guards, repetitive checks, manual coordination, or accidental complexity.

The goal is not to add more controls around a weak flow. The goal is to redesign the flow so the correct path becomes the natural path.

---

## A. Tư duy flow

### A1. Core mindset
A good flow does not depend on constant enforcement. A good flow makes the correct behavior natural.

Do not ask first:
- "What guard should we add?"
- "What extra check should we add?"
- "What fallback should we add?"

Ask first:
- "Why does this flow need so much enforcement?"
- "Where is the shape of the flow wrong?"
- "What redesign would make the desired path self-aligning?"

A patch may be necessary sometimes. But repeated patches usually mean the flow itself is not well-formed.

### A2. When to use
Use this skill when any trigger appears:

- A feature works, but feels fragile
- Many guards, checks, fallbacks, or exceptions keep being added
- A user journey has friction, repetition, or too many steps
- A workflow relies on people remembering what should happen next
- Different parts of the system disagree about state, ownership, or timing
- A process stalls, forks unexpectedly, or needs repeated recovery logic
- Bugs keep appearing around the same transition points
- The architecture looks organized, but the real flow still feels awkward

---

## B. 8 câu hỏi first-principles

### B1. Define the flow
- What is the exact start point?
- What is the exact end point?
- What are the major transitions in between?
- Who or what owns each transition?

### B2. Trace the real path
- What actually happens step by step?
- Which steps are automatic, and which depend on human memory or coordination?
- Where do retries, forks, waits, or handoffs occur?
- Where does the real flow differ from the intended flow?

### B3. Find pressure points
- Where does the flow break?
- Where does it stall?
- Where does it branch in ways that are hard to reason about?
- Which steps create confusion about ownership, timing, or state?

### B4. Identify artificial enforcement
- Which guards exist only to protect against a badly shaped upstream step?
- Which checks are repeated because the system cannot trust its own state?
- Which fallbacks exist because the happy path is not truly reliable?
- Which manual steps exist because the system flow is incomplete?

### B5. Diagnose root shape problems
- Is the sequence wrong?
- Is ownership unclear?
- Is state duplicated or drifting?
- Is validation happening too late?
- Is one component making decisions that belong elsewhere?
- Is the system trying to support too many modes in one path?

### B6. Design the native flow
- What would the simplest end-to-end path look like?
- What should become automatic instead of manually enforced?
- What should become impossible instead of repeatedly checked?
- What should happen earlier so later guards become unnecessary?
- What can be removed if the flow shape is corrected?

### B7. Evaluate leverage
- Which change removes the most downstream complexity?
- Which redesign removes the most recurring friction?
- Which fix improves the flow instead of only hiding symptoms?
- What is the smallest structural change with the biggest effect?

### B8. Validate
- What is the fastest way to prove the improved flow works?
- What observable signal would show the flow is now healthier?
- Which old checks or patches should become unnecessary if the redesign is correct?

---

## C. Chốt & output

### C1. Decision test
Before recommending fixes, check:

- Does the recommendation improve the flow itself, not just add protection around it?
- Does it reduce repeated guards, checks, or manual coordination?
- Does it make state, ownership, or timing clearer?
- Does it remove downstream complexity instead of relocating it?
- Is the new path easier to explain end-to-end?
- Can the redesign be validated with a small test or slice?

If not, the recommendation may still be patching symptoms.

### C2. Red flags
Stop and rethink when you see these patterns:

- "Just add another guard"
- "Add a fallback in case that fails"
- "Document the manual step more clearly"
- "Teach the team to remember this"
- "Retry until it works"
- "Handle this in another layer too"
- "Check it again later just to be safe"
- "Keep both paths for now"

These may sometimes be necessary, but if they accumulate, they usually signal a flow problem.

### C3. Output format
When using this skill, produce output in this structure:

1. **Flow target** — what flow is being audited.
2. **Intended flow** — the ideal or claimed path.
3. **Actual flow** — the real observed path.
4. **Breakpoints** — where the flow breaks, stalls, forks, drifts, or needs coordination.
5. **Artificial enforcement** — guards, checks, fallbacks, retries, or manual steps that exist because the flow is weak.
6. **Root shape problems** — what is structurally wrong in sequence, ownership, state, validation, or control.
7. **Native-flow redesign** — the simplest better shape that makes the correct path more automatic.
8. **Fastest validation** — the smallest credible way to prove the redesigned flow is better.

---

## Next step
If the flow problem is local, move to implementation planning. If the flow problem is architectural, move to a broader design pass before patching symptoms.

---

## One-line reminder
Do not keep strengthening the fence around a broken path when you could reshape the path itself.
