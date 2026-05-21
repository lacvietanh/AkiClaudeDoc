# Core Docs Rules

## Goals
Docs should be readable for both humans and LLMs.

## Topic structure
Use these short, stable topic folders:

- `docs/feat/` — features, systems, behaviors
- `docs/arch/` — architecture, structure, technical design
- `docs/plan/` — plans and execution notes
- `docs/ref/` — stable references, setup notes, lookup docs
- `docs/research/` — exploratory, comparative, or time-bound findings

Do not create new top-level doc topics unless the existing set clearly fails.

## Index
- `docs/index.md` is the master index
- Update it when docs or code changes affect discoverability
- Index entries should be short and descriptive

## Plan lifecycle
- Active plans live in `docs/plan/`
- Completed plans move to `docs/plan/done/`
- Use `done`, not `archived`, for completed plans

## Documentation behavior
- Keep docs synchronized with code
- Prefer one clear canonical doc over multiple overlapping docs
- Use Markdown
- Default: no Mermaid
- Use Mermaid only for flows, architecture, state transitions, or pipelines that are harder to understand in plain text
- README should stay focused on setup and entry-level usage unless the project explicitly wants more
