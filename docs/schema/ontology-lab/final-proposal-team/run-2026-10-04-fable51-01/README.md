# Final proposal team run `run-2026-10-04-fable51-01`

Status: **complete** (Wave 6 executed; a corrected rerun with remapped negative expectations and per-packet normalization is recorded as `validation/wave6-final-v2.json` when present). Start at `reports/00-final-proposal-summary.md`. Synthesizer: Fable 5.1 (`claude-fable-5-1`, identity verified through the session API at run start: configured model and last served model both `claude-fable-5-1`). Workers: Opus 5.5 subagents, one per package W00–W23, coordinated by Fable 5.1 as final implementer.

This directory is the immutable run record demanded by `../../domain-discovery-and-cursor-team-handoff.md` section 6 and 7. Nothing here replaces the catalog or the live schema; the final deliverables are written outside this directory only at Wave 6:

- `docs/schema/final_biotech_schema_proposal.graphql` (standalone executable `@neo4j/graphql` proposal)
- `docs/schema/neo4j/final_biotech_schema_operations.cypher` plus edition companions
- reports linked from `reports/00-final-proposal-summary.md`

| File | Purpose |
|---|---|
| `00-baseline.md` | HEAD, digests, discrepancies, tool inventory, runtime pins, baseline replay |
| `01-shared-contract.md` | Frozen shared contract every worker imports (kernel, time, provenance, privacy, SDL conventions, naming rulings) |
| `02-ownership-registry.md` | One sole file writer per node, relationship-property type, enum, union; canonical module; consumers |
| `03-conflict-ledger.md` | Seam requests and conflict records with resolver and status |
| `04-worker-brief.md` | Standard eight-part output contract, file names, research and fixture rules |
| `workers/Wxx/` | Worker packets (each worker writes only its own directory) |
| `validation/` | Harness scripts, pinned versions, execution logs and results |
| `reports/` | Fable's integration reports (coverage, ownership, decisions, sources, migration, validation, summary) |
