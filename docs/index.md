# Docs index — AkiClaudeDoc

Master index for this repo's documentation. AkiClaudeDoc is the source of truth for Aki's reusable Claude Code / Antigravity rule and skill baseline; these docs record its architecture, active plans, and decision history.

Topic folders follow `RULE-docs.A1`. Only the folders that currently hold content are listed.

## `arch/` — architecture & technical design

| Doc | Purpose |
|-----|---------|
| [rule-delivery-architecture.md](arch/rule-delivery-architecture.md) | How one rule source is installed onto a machine and consumed by the two agent families (Claude Code vs Gemini/Antigravity). |

## `plan/` — active plans

| Doc | Status | Purpose |
|-----|--------|---------|
| [improve-jun24.md](plan/improve-jun24.md) | ⏳ pending | Keyword-level precision fixes for `akirule/SKILL.md` Tier 2 signal lists. Not yet applied; references the pre-rename `METHOD-techbiz-optimizer.md` and needs revalidation before execution. |

## `plan/done/` — completed plans

| Doc | Purpose |
|-----|---------|
| [antigravity-rule-delivery.md](plan/done/antigravity-rule-delivery.md) | Delivering rules + skills to the Antigravity surfaces (AG Desktop, AG IDE, AGY CLI); replaced the hooks approach. |
| [release-a5-review.md](plan/done/release-a5-review.md) | `RULE-release.md` §A5 — atomic bump+tag+build for Tauri/artifact apps + pre-bump guard. |
| [versioning-principle-rewrite.md](plan/done/versioning-principle-rewrite.md) | Versioning rewrite applied to `RULE-release.md` A4/B1–B3: cold-start reconstruction, severity-driven bump, anti-skip invariant, audit mode. |
| [naming-rule-consolidation.md](plan/done/naming-rule-consolidation.md) | Consolidated naming rules into one callable address (`design.A7` root + domain applications). |

## `research/` — decision records & exploratory findings

| Doc | Purpose |
|-----|---------|
| [antigravity-rule-discovery-architecture.md](research/antigravity-rule-discovery-architecture.md) | How Antigravity/Gemini natively discovers rule files across its three surfaces; verification-status banner separating confirmed from unconfirmed behavior. |
| [public-private-abc-restructure.md](research/public-private-abc-restructure.md) | Decision record for the public/private split and the A/B/C group restructure of `payload/`; full item-level breakdown. |
| [versioning-critique-akithink.md](research/versioning-critique-akithink.md) | `/akithink` decision record that critiqued and hardened the versioning rewrite before it was applied. |
| [akithink-akihtmlreport-akihelp.md](research/akithink-akihtmlreport-akihelp.md) | Spec for the akithink / akihtmlreport / akihelp skill expansion. |
