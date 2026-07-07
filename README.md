# AkiClaudeDoc

AkiClaudeDoc packages Aki's Claude Code rules and skills into a small reusable project. It is Markdown instructions plus a Claude Code skill definition, arranged so the same setup can be installed on another machine.

The goal: keep the source of truth in Git, publish the explanation and quickstart on `dev.akitao.com`, and let users install the same Claude Code rule/skill baseline into their own `~/.claude` environment.

## What this is

AkiClaudeDoc contains:

- shared rule files (`RULE-*`) and analytical method files (`METHOD-*`) for Claude behavior, coding, docs, content, and Aki Nuxt/Cloudflare work;
- Claude Code skills: `akirule`, a smart router that always loads core rules and reads additional files on demand, and `akiadvise`, which distills a dense conversation into a single self-contained HTML report;
- a small global Claude instruction block (`CLAUDE.md`);
- a simple install script.

It is not an auto-updater, daemon, package manager, or control plane.

## File naming conventions

Files in `payload/` follow a strict naming convention:

- `RULE-*.md` — constraint rules: behavior limits, coding standards, content standards, stack requirements. These define *what* Claude must or must not do.
- `METHOD-*.md` — analytical frameworks: structured methods Claude reads and applies when a task requires flow auditing or first-principles optimization. These define *how* to reason through a specific type of problem.
- `index.md` — rule index, precedence order, and project binding policy.

This separation matters: `RULE-*` files are always-relevant constraints; `METHOD-*` files are heavy analytical frameworks that only add value when the task is genuinely analytical.

## How `akirule` works

`akirule` is a single Claude Code skill installed at `~/.claude/skills/akirule/SKILL.md`. It is set to `"on"` in `skillOverrides`, so Claude Code injects it into every conversation automatically.

The skill operates in three tiers:

**Tier 1 — Core (always embedded via `@` syntax):**
- `index.md` — rule precedence and project binding
- `RULE-agent-behavior.md` — response discipline, scope, verification
- `RULE-coding.md` — coding philosophy, source-of-truth, security

These three files are hard-embedded into the skill prompt on every conversation. They are small (≈130 lines total) and universally relevant.

**Tier 2 — On-signal rules (Claude reads the file when task signals match):**
- `RULE-docs.md` — triggered when editing docs, CLAUDE.md, plan files, or complex code with a docs reference
- `RULE-content-write.md` — triggered when writing UI text, i18n keys, meta content, or product-facing prose
- `RULE-stack-akiNuxtCf.md` — triggered for any Nuxt, Vue, or Cloudflare work; default-load in Aki project contexts

**Tier 3 — On-signal methods (Claude reads the file when task has analytical depth):**
- `METHOD-flow-audit.md` — triggered for refactors, multi-file bugs, fragile flows, user journey audits
- `METHOD-techbiz-optimizer.md` — triggered for scope decisions, architecture tradeoffs, effort/value questions

The skill prompt uses imperative trigger language ("Read this file NOW if…") with high sensitivity — Claude errs toward loading rather than skipping. A `[load full]` or `[nạp full]` keyword in a message forces all `RULE-*` and `METHOD-*` files to load immediately.

## How `akiadvise` works

`akiadvise` is a Claude Code skill installed at `~/.claude/skills/akiadvise/SKILL.md`. It only triggers on an explicit request (`/akiadvise`, or "xuất báo cáo trực quan" / "export this to html") — never proactively just because a response got long.

It distills an analysis or report that already exists in the conversation into one ultra-wide, dense, self-contained `ADVISE.html` file at the project root — no re-summarizing, no dropped detail, theme-aware, zero external requests. Exactly one `ADVISE.html` exists per project at a time; if one already exists, the skill asks before overwriting rather than creating versioned copies.

## How Claude Code skills work in this context

Claude Code skills are Markdown files read by the harness at conversation start. The `@path` syntax in a skill file hard-embeds that file's content directly. For dynamic files (Tier 2 and 3), the skill prompt instructs Claude to use its Read tool to fetch the file when the task matches — no harness magic, just Claude following the trigger instructions.

The `~/.aki/claudedoc/` directory is added to `permissions.allow` and `additionalDirectories` in `settings.json` so Claude can read those files without a permission prompt.

## Source of truth

The Git repository is the source of truth. If a rule or skill changes, edit it in Git and run `install.sh` again.

`dev.akitao.com` is the production presentation layer. The website explains and promotes the project; the canonical files live in this repository.

## Repository layout

```text
payload/
  index.md
  RULE-agent-behavior.md
  RULE-coding.md
  RULE-content-write.md
  RULE-docs.md
  RULE-stack-akiNuxtCf.md
  METHOD-flow-audit.md
  METHOD-techbiz-optimizer.md

claude/
  CLAUDE.md
  skills/akirule/SKILL.md
  skills/akiadvise/SKILL.md
  hooks/aki-update-check.py
  fragments/settings.akidoc.fragment.json

install.sh
```

`payload/` is what gets deployed to `~/.aki/claudedoc`. `claude/` contains the Claude Code runtime assets installed into `~/.claude`. `fragments/settings.akidoc.fragment.json` is an illustrative reference of the settings shape — do not apply it manually. The installer generates the exact expanded paths for each machine.

## Install target

The installer deploys payload resources to:

```text
~/.aki/claudedoc/
```

Claude Code assets are installed into:

```text
~/.claude/skills/akirule/SKILL.md
~/.claude/skills/akiadvise/SKILL.md
~/.claude/hooks/aki-update-check.py   ← SessionStart update-check hook (notify-only)
~/.claude/CLAUDE.md            ← managed by installer, never edit directly
~/.claude/CLAUDE.local.md      ← machine-local, never touched after first install
~/.claude/settings.json        (read permission + skillOverrides + SessionStart hook added)
```

The `akirule` skill reads `RULE-*` and `METHOD-*` files directly from `~/.aki/claudedoc/` at conversation time, on demand.

## Install from local checkout

```bash
bash install.sh
```

## One-line install

```bash
curl -fsSL https://raw.githubusercontent.com/lacvietanh/AkiClaudeDoc/master/install.sh | bash
```

or via the docs-site wrapper:

```bash
curl -fsSL https://dev.akitao.com/claudedoc/install.sh | bash
```

The script is intentionally simple so users can inspect it before running.

## What the installer does

1. Copies `payload/*` into `~/.aki/claudedoc` (rsync, excludes `ref-ECC/`).
2. Copies the `akirule` skill into `~/.claude/skills/akirule/` and removes any old AkiClaudeDoc skill directories (`akidoc-rules`, `akidoc-flow-audit`, `akidoc-techbiz-optimizer`).
3. Replaces `~/.claude/CLAUDE.md` with the packaged global guidance (timestamped backup created first), then appends a machine-local section with the correct source repo path for this machine and an `@~/.claude/CLAUDE.local.md` import line.
4. Creates `~/.claude/CLAUDE.local.md` with a template comment **only if it does not already exist** — never overwrites it after that.
5. Writes `~/.claude/settings.json`: adds read permission for `~/.aki/claudedoc/**`, sets `skillOverrides.akirule = "on"`, registers the `SessionStart` update-check hook, removes old skill overrides (timestamped backup created first).
6. Installs the notify-only update-check hook into `~/.claude/hooks/aki-update-check.py` and records this machine's source repo path in `~/.aki/claudedoc/.source-repo`.

Running the installer again updates the same managed files cleanly. `CLAUDE.local.md` is always preserved.

## Update notifications

Once installed, a Claude Code `SessionStart` hook checks (at most once per 24h, fail-silent, never blocking) whether the public repo `CHANGELOG.md` has entries newer than the installed copy. If so, it prints a short notice with the new changelog entries, the update command (`git pull && bash install.sh`), and a link. It is notify-only — it never downloads or installs anything on its own. Existing installs start receiving notices only after they re-run `install.sh` once to pick up the hook.

## Machine-local configuration

`~/.claude/CLAUDE.local.md` is the right place for per-machine rules that must not be shared (e.g. build constraints, remote-only flags, IDE paths). The installer imports it automatically via the `@` syntax at the end of `CLAUDE.md`. Add any machine-specific instructions there; they survive every reinstall.

## What is excluded

`ref-ECC/` is intentionally excluded from the default install. It is a large reference corpus not needed for standard rule/skill operation.

This repo also does not package:

- Anthropic API keys;
- model router tokens;
- localhost project permissions;
- unrelated personal Claude settings;
- automatic download/install logic (the update-check hook is notify-only — it never fetches or applies updates itself).

## Why `~/.aki/claudedoc`

- no sudo;
- user-local;
- easy to inspect and delete;
- consistent with the Aki ecosystem namespace.

## Uninstall

```bash
rm -rf ~/.aki/claudedoc
rm -rf ~/.claude/skills/akirule
```

Then remove the AkiClaudeDoc block from `~/.claude/CLAUDE.md` and the AkiClaudeDoc entries from `~/.claude/settings.json` if desired.

## Content for dev.akitao.com

This README is the source material for a public article or docs page. The web page should explain:

- why shared Claude Code rules matter;
- the RULE-* / METHOD-* naming convention and what each type does;
- how the `akirule` smart router works (3 tiers, on-demand file reads);
- what gets installed and where;
- why Git is the source of truth;
- how to install from local checkout or one-line command;
- why the default path is `~/.aki/claudedoc`;
- what files are changed in `~/.claude`.
