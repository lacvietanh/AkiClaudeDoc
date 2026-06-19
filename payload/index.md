# Aki-RULE

Shared source-of-truth rules for Aki projects.

## Purpose
Aki-RULE provides reusable rules for agent behavior, coding, content, docs, and stack-specific work.
Project `CLAUDE.md` files bind these shared rules to a specific project.

## Rule sets
Core rule sets (always loaded):
1. `RULE-agent-behavior.md`
2. `RULE-coding.md`

On-signal rule sets (loaded by the `akirule` smart router when task signals match):
3. `RULE-content-write.md`
4. `RULE-docs.md`
5. `RULE-stack-akiNuxtCf.md`

Method files (loaded by the `akirule` smart router for analytical tasks):
- `METHOD-flow-audit.md` — flow integrity audit method
- `METHOD-techbiz-optimizer.md` — first-principles scope and value optimizer

Keep the number of files small. Split only when a rule group has a different lifecycle or applies to a different set of projects.

## Precedence
When rules conflict, use this order:
1. Current local source code, runtime output, and build output
2. User's explicit instruction in the current conversation
3. Project `CLAUDE.md`
4. Aki-RULE shared files
5. Older docs, memory, or prior conversation context

Project `CLAUDE.md` may add project facts and stricter constraints.
It should not silently weaken core safety, verification, or source-of-truth rules.

## Project binding
Each project should keep a root `CLAUDE.md`.
That file should:
- list applicable Aki-RULE files
- define project-specific facts and overrides
- stay short
- avoid duplicating shared rules unless the rule must be visible without opening global files

## Change policy
Aki-RULE changes affect many projects.
Before changing these files, first clarify the intended rule, scope, and tradeoff unless the user explicitly requests the exact change.
