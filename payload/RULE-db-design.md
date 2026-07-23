# Database Design Rules

<!-- Address map: db.A1-4 · db.B1 -->

**Tier: Contextual** — load when designing a schema, writing a migration, or refactoring a database layer. Do not load by default on every task.

## A. Nguyên tắc dữ liệu

### A1. Immutability & Event Sourcing
For business domains with transactions or mutable-looking state (wallets/credits, transaction history, audit logs): never mutate state directly — only append action records (append-only log). Current balance/state is a materialized view derived by replaying/summing the log. On error, replay the log instead of patching state by hand.

Exempt: read-only, display-only, or purely static data — this pattern is for domains that track change over time, not for content that doesn't have meaningful history.

### A2. First Normal Form (atomicity)
A column holds one atomic value. Do not stuff a JSON blob into a column as a "black box" — it breaks indexing and costs CPU/RAM to parse on every read. JSON in a column is acceptable only for data that is genuinely unstructured and never queried/filtered by its internal content.

### A3. Bounded Context (DDD)
Split databases/tables along independent business boundaries. Different modules/domains link to each other only through a stable ID — never reach into another domain's internal data directly.

### A4. Flat queries, merge in the application layer
Prefer flat, non-correlated queries over nested CTEs or per-row correlated subqueries; push merge/aggregation logic into plain application code when data volume makes that cheap and clearer. Apply this everywhere, not just to already-identified hot paths — see RULE-coding.md (Performance section) for the general principle.

## B. Unicode

### B1. The DB is not your Unicode safety net
SQLite/D1 stores UTF-8 natively and has no `utf8` vs `utf8mb4` trap, so it is easy to assume "D1 → no Unicode bugs". False: the DB faithfully stores whatever bytes it is handed, including already-corrupt ones. Text corruption (mojibake, un-normalized duplicates) happens one layer up, in the application code that decodes/compares the string before the `INSERT` — fix it there, per RULE-coding.md (Unicode / UTF-8 safety), not in the schema. The one schema-level Unicode concern is on MySQL/MariaDB: use `utf8mb4`, never the 3-byte `utf8`, or emoji and some CJK truncate.
