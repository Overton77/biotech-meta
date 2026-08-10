---
id: SPEC-BP-INDEX
title: Workflow blueprint authority index
status: canonical
version: 2
governed_by: [ADR-0003]
---

# Workflow blueprint authority index

BellLabs currently accepts exactly two top-level blueprint families:

- [SPEC-BP-STAGEGRAPH](stagegraph.md) — active `CON-BP-STAGEGRAPH-V2`.
- [SPEC-BP-GOAL-DIRECTED](goal-directed.md)

Both execute inside [SPEC-CP-DURABLE-EXECUTION](../control-plane-foundations/03-temporal-run-operation-continuity-and-linked-runs.md), consume exact bindings from [SPEC-CP-DEFINITIONS](../control-plane-foundations/01-versioned-definitions-and-effective-run-configuration.md), and rely on [SPEC-CP-RUN-CONTROL](../control-plane-foundations/02-transactional-admission-lifecycle-budgets-and-events.md) for authority. Neither is a LangGraph or Deep Agents graph contract. Their pure interpreters own semantic decisions; Temporal durably applies accepted decisions.

A third family requires a new accepted ADR, a canonical specification, compiler support, interpreter semantics, and replay/qualification evidence.
