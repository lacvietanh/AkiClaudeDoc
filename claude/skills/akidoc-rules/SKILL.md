---
name: akidoc-rules
description: Load Aki's shared core agent, coding, documentation, and content rules, with stack-rule pointers when relevant. Use when working in Aki projects, creating or editing project instructions, writing code/docs/content, or when the user asks to follow Aki rules.
when_to_use: Trigger on requests mentioning Aki rules, global rules, coding standards, docs standards, content standards, project CLAUDE.md, or durable project files with no project-specific rule already loaded. If the task involves Nuxt or Cloudflare, also load the Aki Nuxt/Cloudflare stack rule.
user-invocable: false
---

Use these shared rules as guidance after current user instructions and current project files.

By default, load only the core shared rule files below.
Load stack-specific rules only when the task clearly involves that stack.
Do not scan or bulk-load `~/.aki/claudedoc/ref-ECC` unless the user explicitly asks for it or a task has a narrow, intentional need for that corpus.

## Rule index
@~/.aki/claudedoc/index.md

## Core rules loaded by this skill
@~/.aki/claudedoc/RULE-agent-behavior.md
@~/.aki/claudedoc/RULE-coding.md
@~/.aki/claudedoc/RULE-docs.md
@~/.aki/claudedoc/RULE-content-write.md

## Stack rules loaded only when relevant
If the task involves Nuxt, Cloudflare, or the Aki Nuxt/Cloudflare stack, also load:
- `@~/.aki/claudedoc/RULE-stack-akiNuxtCf.md`
