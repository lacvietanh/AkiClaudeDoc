# Database Design Rules

**Tier: Optional/Contextual** — load when designing a schema, writing a migration, or refactoring
a database layer. Do not load by default on every task.

## 1. Immutability & Event Sourcing
For business domains with transactions or mutable-looking state (wallets/credits, transaction
history, audit logs): never mutate state directly — only append action records (append-only log).
Current balance/state is a materialized view derived by replaying/summing the log. On error,
replay the log instead of patching state by hand.

Exempt: read-only, display-only, or purely static data — this pattern is for domains that track
change over time, not for content that doesn't have meaningful history.

## 2. First Normal Form (atomicity)
A column holds one atomic value. Do not stuff a JSON blob into a column as a "black box" —
it breaks indexing and costs CPU/RAM to parse on every read. JSON in a column is acceptable only
for data that is genuinely unstructured and never queried/filtered by its internal content.

## 3. Bounded Context (DDD)
Split databases/tables along independent business boundaries. Different modules/domains link to
each other only through a stable ID — never reach into another domain's internal data directly.

## 4. Flat queries, merge in the application layer
Prefer flat, non-correlated queries over nested CTEs or per-row correlated subqueries; push
merge/aggregation logic into plain application code when data volume makes that cheap and
clearer. Apply this everywhere, not just to already-identified hot paths — see RULE-coding.md
(Performance section) for the general principle.
