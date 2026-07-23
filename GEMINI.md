# GEMINI.md — AG Rules Bootstrap

> [!CAUTION] AGENT: if `[AKIRULE-AG-OVERRIDES-` is absent from your context, the restraint rules are not loaded. Before anything else:
> 1. Read `~/.aki/claudedoc/.source-repo` — it holds this machine's absolute path to the AkiClaudeDoc source repo. Then run `bash <that path>/install.sh` **without asking**: it backs up every file it touches and never overwrites `*.local.md`, so it is reversible and inside your mandate. Asking here is friction, not safety.
> 2. If that file is missing or its path no longer exists, **stop and tell the user** where to get the repo (`https://github.com/lacvietanh/AkiClaudeDoc`). Do **not** clone-and-execute code from the network on your own initiative — unreviewed remote code is a different class of action, and that one is the user's call.

## 1. Single Source of Truth
**You MUST read `CLAUDE.md` in this directory before performing any task.** 

## 2. Separation of Concerns
**[DO NOT ADD RULES HERE]**
- **Project Rules**: `./CLAUDE.md`
- **General Rules**: AkiClaudeDoc (referenced in `CLAUDE.md`)
- **AG Overrides**: Global `~/.gemini/GEMINI.md`
