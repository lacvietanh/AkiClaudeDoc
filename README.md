# AkiClaudeDoc

AkiClaudeDoc packages Aki's Claude Code rules and skills into a small reusable project. It is just Markdown instructions plus Claude Code skill definitions, arranged so the same setup can be installed on another machine.

The goal is simple: keep the source of truth in Git, publish the explanation and quickstart on `dev.akitao.com`, and let users install the same Claude Code rule/skill baseline into their own `~/.claude` environment.

## What this is

AkiClaudeDoc contains:

- shared rule files for Claude behavior, coding, docs, content, and Aki Nuxt/Cloudflare work;
- Claude Code skills that load or apply those rules;
- a small global Claude instruction block;
- a simple install script.

It is not an auto-updater, daemon, package manager, or control plane.

## Source of truth

The Git repository is the source of truth. If a rule or skill changes, edit it in Git and deploy/install from the repo again.

`dev.akitao.com` is the production presentation layer: landing page, article, quickstart, install command, and explanation. The website should explain and promote the project, but the canonical files should live in this repository.

## Repository layout

```text
payload/
  index.md
  RULE-agent-behavior.md
  RULE-coding.md
  RULE-content-write.md
  RULE-docs.md
  RULE-stack-akiNuxtCf.md
  SKILL-flow-audit.md
  SKILL-techbiz-optimizer.md

claude/
  CLAUDE.md
  skills/akidoc-rules/SKILL.md
  skills/akidoc-flow-audit/SKILL.md
  skills/akidoc-techbiz-optimizer/SKILL.md
  fragments/settings.akidoc.fragment.json

install.sh
```

`payload/` contains the Markdown resources that are deployed to the user's machine. These are the packaged rule/method resources, not the active `~/.claude` runtime location.

## Install target

The installer deploys Markdown resources to:

```text
~/.aki/claudedoc
```

Claude Code assets are installed into:

```text
~/.claude/skills/akidoc-rules/SKILL.md
~/.claude/skills/akidoc-flow-audit/SKILL.md
~/.claude/skills/akidoc-techbiz-optimizer/SKILL.md
~/.claude/CLAUDE.md
~/.claude/settings.json
```

The installed skill files refer directly to:

```text
~/.aki/claudedoc
```


## Install from local checkout

If you already cloned or copied the repo locally:

```bash
bash install.sh
```

This is the same install path used by development. There is no need to push to remote and download again just to deploy locally.

## One-line install

```bash
curl -fsSL https://raw.githubusercontent.com/lacvietanh/AkiClaudeDoc/main/install.sh | bash
```

or via the docs-site wrapper:

```bash
curl -fsSL https://dev.akitao.com/claudedoc/install.sh | bash
```

The script is intentionally simple so users can inspect it before running.

## What the installer does

1. Copies `payload/*` into `~/.aki/claudedoc`.
2. Copies the three AkiClaudeDoc skills into `~/.claude/skills`.
3. Replaces `~/.claude/CLAUDE.md` with the packaged AkiClaudeDoc global guidance.
4. Adds the AkiClaudeDoc skill overrides and read permission to `~/.claude/settings.json`.
5. Creates timestamped backups before replacing mutable Claude files.

Running the installer again updates the same managed files.

## What is excluded

`ref-ECC/` is intentionally excluded. It is a large reference corpus and is not needed for the default AkiClaudeDoc install.

This repo also does not package:

- Anthropic API keys;
- model router tokens;
- localhost project permissions;
- unrelated personal Claude settings;
- auto-update logic.

## Why `~/.aki/claudedoc`

AkiClaudeDoc installs into `~/.aki/claudedoc` because it is simple, user-local, and easy to understand.

- no sudo;
- user-local;
- easy to inspect;
- easy to delete;
- consistent with the Aki ecosystem namespace.

## Uninstall

Remove installed resources and skills:

```bash
rm -rf ~/.aki/claudedoc
rm -rf ~/.claude/skills/akidoc-rules ~/.claude/skills/akidoc-flow-audit ~/.claude/skills/akidoc-techbiz-optimizer
```

Then remove the marked AkiClaudeDoc block from `~/.claude/CLAUDE.md` and remove the AkiClaudeDoc entries from `~/.claude/settings.json` if desired.

## Content for dev.akitao.com

This README is written as the source material for a public article or docs page. The web page should explain:

- why shared Claude Code rules matter;
- what gets installed;
- why Git is the source of truth;
- how to install from local checkout or one-line command;
- why the default path is `~/.aki/claudedoc`;
- what files are changed in `~/.claude`.
