# Core Docs Rules

## Goals
Docs should be readable for both humans and LLMs.

## Topic structure
Use these short, stable topic folders:

- `docs/biz/` — business backbone: identity, USP, positioning, monetization (MANDATORY for any project with a business dimension)
- `docs/feat/` — features, systems, behaviors
- `docs/arch/` — architecture, structure, technical design
- `docs/plan/` — plans and execution notes
- `docs/ref/` — stable references, setup notes, lookup docs
- `docs/research/` — exploratory, comparative, or time-bound findings

Do not create new top-level doc topics unless the existing set clearly fails.

## Business backbone — `docs/biz/`
- For any project with a business dimension, `docs/biz/` is REQUIRED and is the spine.
- All `arch/`, `feat/`, and `plan/` docs that touch product direction or money must reference it.
- When code intent and a `biz/` doc disagree, the `biz/` doc wins — reconcile or escalate.

## Index
- `docs/index.md` is the master index
- Update it when docs or code changes affect discoverability
- Index entries should be short and descriptive

## Plan lifecycle
- Active plans live in `docs/plan/`
- Completed plans move to `docs/plan/done/`
- Use `done`, not `archived`, for completed plans

## Documentation behavior
- Keep docs synchronized with code. Code does not auto-generate docs unless complex/requested; when editing code derived from `feat|arch` docs, proactively sync the doc or comment the reference path.
- Prefer one clear canonical doc over multiple overlapping docs
- Use Markdown
- Default: no Mermaid
- Use Mermaid only for flows, architecture, state transitions, or pipelines that are harder to understand in plain text
- README should stay focused on setup and entry-level usage unless the project explicitly wants more
