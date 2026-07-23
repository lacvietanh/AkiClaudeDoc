---
name: akihelp
description: Introduce the whole Aki Claude Code system — installed skills, the akirule passive rule router (3 tiers), and the deep-think passive/active split — by reading live installed state, never a hardcoded inventory. Use when the user asks what Aki tools/rules/skills are available or how the system works.
---

# akihelp — live introduction to the Aki system

Invoke with `/akihelp`, or when the user asks what's available in this setup ("what can this do", "hệ thống Aki có gì", "how do I use this", "what skills do I have"). Goal: give the user a clear, accurate picture of the whole Aki Claude Code system so they can fully exploit it.

**This skill must never go stale.** Do not hardcode a skill/rule inventory in this file — read live state every time it runs, so the output is always correct even after `install.sh` adds, renames, or removes something.

## Steps

1. Read `~/.aki/claudedoc/index.md` — the file manifest with tiers and purposes.
2. List `~/.claude/skills/` and read the frontmatter (`name` + `description`) of each skill whose directory is prefixed `aki` — these are the installed Aki skills.
3. Render a compact overview with these sections:

   - **Skills (active, user-invoked)** — one row per aki-skill: its `/name`, its one-line description (from frontmatter), and when to reach for it.
   - **Passive system (akirule)** — explain the 3 tiers: Core rules always loaded every turn; Contextual/Analytical rules auto-loaded on signal match; full load via an explicit phrase ("nạp full", "load all rules"). Note that `akirule` itself is hidden from the `/` menu by design (`user-invocable: false`) — it runs passively, not as a command.
   - **One brain, two modes** — `METHOD-deep-think.md` is read passively by akirule inside normal tasks (brief, inline, at most one clarifying question) and actively by `/akithink` (full 5-phase interactive session for big/hard-to-reverse/goal-ambiguous decisions). Short version of the comparison, not the full METHOD text.
   - **Editing rules** — this whole system is generated from a source repo (AkiClaudeDoc); the installed copies under `~/.aki/claudedoc` and `~/.claude` are deployed output, never edited directly. Changes go through the source repo + `install.sh`.

4. Keep the output scannable: a compact table or short bulleted sections, not an essay. Respond in the user's language.
