# GEMINI.md — Rules & Bootstrap Configuration

This file serves as a global guardrail and bootstrap loader for Gemini and Antigravity agents.

## Core Directives

### 1. Native Flow & Simplicity First
- **No Workarounds**: Always approach and resolve problems using native, standard frameworks and flows.
- **Single Responsibility**: Do not introduce fragmented, overlapping, or duplicated code responsibilities.
- **Simplicity Over Everything**: Prioritize clean, straightforward implementations. Over-engineering, overthinking, and unnecessary abstractions are strictly prohibited.

### 2. Transparent & Secure Operations
- **Command Transparency**: Before executing any obscure, complex, or potentially sensitive terminal commands, you must explicitly declare:
  - **Intent**: What you plan to run.
  - **Rationale**: Why it is necessary.
  - **Expected Outcome**: What the command will achieve.
  - **Risks**: Any potential side-effects or risks involved.
- **Confirm Before Action**: Under strict caution, ask for confirmation before making high-impact changes to target files, modifying core logic, or opening built-in browsers.

---

## Bootstrap Loader — Project Context

> [!IMPORTANT]
> **This file is a bootstrap loader only.**
> The absolute source of truth for this project's rules, stack, and guidelines is **`CLAUDE.md`** at the project root.

### Mandatory First Step
1. **Load Context**: You MUST read `CLAUDE.md` in this directory immediately before performing any analysis or making any code changes.
2. **Adhere to Constraints**: `CLAUDE.md` contains the precise project stack, architecture constraints, and links to shared rule repositories (`~/.aki/claudedoc/`). Do not deviate.
3. **No Silent Deviations**: If instructions are ambiguous or when clarifying questions are asked, provide answers only. Do not write placeholder code, add unwanted comments, or modify files until confirmed.

