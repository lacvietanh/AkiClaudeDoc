---
name: akihtmlreport
description: Visualize a complex report that already exists in the conversation as one self-contained HTML file — nothing else, no new analysis. Distills a dense analysis/report already discussed into a single-file, ultra-wide, visually dense HTML report (REPORT.html) at the project root, for content too dense to stay legible as chat text.
---

# akihtmlreport — single-file visual report extraction

Invoke with `/akihtmlreport`, or when the user asks in their own words to extract the discussion
into a visual file ("trích xuất ra html", "xuất báo cáo trực quan", "làm file report", "export
this to html"). Its purpose is single and narrow: turn a complex analysis or report that already
exists in this conversation into one self-contained HTML file for dense, at-a-glance reading —
**nothing else, no new analysis**. Not a replacement for chat responses, and not something to
reach for by default.

## When this skill actually applies

This is for content that has already gotten too dense to stay legible as chat text: a multi-part
investigation report, a root-cause writeup with several code/log excerpts, a checklist spanning many
items each with its own status, a comparison across several options, a Mac/manual test plan with many
steps and expected results. The content must already exist in the conversation — this skill distills
and formats, it does not originate new analysis.

**Do not use this skill for:**
- a short answer, a single fix explanation, or anything that already reads fine as chat text
- routine status updates or one-off command output
- anything the user hasn't actually asked to have extracted — only trigger on an explicit request,
  never proactively just because a response got long

If invoked on content that turns out not to be dense/complex enough to justify a visual file, say so
and ask whether the user still wants one, instead of silently producing a thin HTML wrapper around a
two-line answer.

## Target file — default path and the single-file rule

- Default output: **project root**, filename **`REPORT.html`** (uppercase, no variant names, no
  topic/version suffix).
- **Exactly one `REPORT.html` exists per project at a time.** This is deliberate: the point is to
  keep attention on ONE complex task at a time, not to accumulate a pile of past reports. Never
  create `REPORT-2.html`, `REPORT-v2.html`, `REPORT-<topic>.html`, and never move a prior one aside
  automatically to make room for a new one.
- **Before writing, check whether `REPORT.html` already exists at the target path:**
  - Does not exist → write directly, no confirmation needed.
  - Already exists → **stop and ask the user** what to do (overwrite, or skip). Never silently
    overwrite, and never auto-rename to dodge the collision — that defeats the single-file rule.
    If the user wants to keep the old report, that's their call to make (e.g. rename/move it
    themselves first) — this skill does not decide that on their behalf.
- If the user explicitly names a different path or filename in their request, honor that instead —
  the default only applies when they haven't specified one.
- **Git-ignore it.** `REPORT.html` is a disposable visual export, not a doc source of truth (that's
  `docs/arch`/`docs/plan`) — it gets fully overwritten every time this skill runs, so tracking it in
  git only produces noise diffs unrelated to real code changes. If the target project is a git repo
  and its `.gitignore` doesn't already exclude `REPORT.html`, add an entry for it (with a one-line
  comment explaining why) the first time this skill writes the file there.

## Layout requirements — ultra-wide, narrow (dense)

- **Ultra-wide**: use the full viewport width, no centered narrow reading column. Use CSS grid/flex
  for multi-column layout wherever the content has parallel structure (comparison tables, side-by-side
  before/after, a checklist next to its rationale).
- **Narrow means dense, not cramped**: small, disciplined padding/margins and a compact type scale —
  mirrors Aki's "Extreme Narrow" UI philosophy. Every section should show as much signal as possible
  without unnecessary scrolling. No hero banners, no decorative whitespace, no filler — this is a
  working document, not a landing page.
- **Single file**: all CSS and JS inline in one `<head>`/`<body>`, zero external requests (fonts,
  CDNs, images, analytics) — must render correctly opened straight from disk via `file://`, no
  network required.
- **Theme-aware**: support both light and dark via `prefers-color-scheme` — the user may open this in
  any browser/OS setting, not necessarily a dark-themed one.
- Wide tables and code/log blocks get their own `overflow-x: auto` container — never let them force
  the page itself to scroll horizontally.
- Use real semantic structure — `<table>`, `<details>`, headers, color-coded status chips/badges for
  states like done/pending/confirmed/open/blocked or severity levels. The goal is scanability, not a
  prose wall reformatted with a few `<h2>` tags.

## Content — distill, don't just reformat

- Short header: what this report is, and when it was produced.
- Sections matching the natural structure of the analysis already discussed — one section per
  investigation area, one table per checklist, one card per open question/decision point.
- Status/severity color-coding wherever the content has state — this is the main value-add over
  plain chat text, so don't skip it even under time pressure.
- Code/log excerpts go in `<pre>`/`<code>` blocks with their own scroll container, never inlined into
  prose paragraphs.
- **Preserve every concrete fact, file path, line reference, and command from the original
  discussion** — this is an extraction, not a re-summary. Do not drop detail to make it shorter; the
  whole point of a wide/dense layout is that it can hold more, not less.

## Pairs naturally with `/akithink`

A `/akithink` Phase 5 convergence (decision + rationale + rejected alternatives + assumptions to
monitor) is a common source of exactly the kind of dense, multi-part material this skill exists to
visualize — the docs file stays the source of truth, `/akihtmlreport` just gives it a scannable view.

## After writing

After writing the file, open it locally: `open REPORT.html` on macOS, falling back to `xdg-open` on
Linux. If opening fails (headless environment, no `xdg-open`, etc.), just tell the user the file's
path instead of failing the skill. Never publish or host it anywhere — if the user separately asks
for a hosted, shareable version, that is a different request (the `Artifact` tool), not part of this
skill.
