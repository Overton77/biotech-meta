# Wave 5 adversarial review brief (Challenger roles)

Handoff section 4 wave 5: workers rotate Challenger roles across adjacent packages; no extra domain owner is created by review. Each Challenger attacks the **assembled** artifacts, not its own packet:

- `docs/schema/final_biotech_schema_proposal.graphql` (assembled by Fable), `docs/schema/neo4j/final_biotech_schema_operations.cypher` and its Enterprise companion, the run's `validation/fixtures-final/` set and the compiled validation suite.

| Challenger | Attack surface | Must produce |
|---|---|---|
| W00 (kernel) | time, provenance, identity: backdating, correction vs ending, sentinel dates, two asserters, locator without snapshot, derived edge without citation, archetype double-labels, uid/id drift, union overlap | at least 8 concrete counterexamples as Cypher mutations against the loaded fixtures, each with the validator or constraint that must catch it and the observed result (caught / not caught) |
| W23 (privacy/access) | private leakage through unions, interface queries, fulltext/vector indexes, AnswerRecord, PolicyVersion exposure in PUBLIC_ANSWER, uid prefix in list properties | same, plus one GraphQL query per access tier showing what is reachable |
| W09 + W10 (study transfer) | Study→Product shortcuts, applicability without dimensions, surrogate transfer, null-primary promotion, dataset non-independence, legacy EVALUATES writes | same |
| W21 + W22 (media) | source/asset confusion: asset as evidence without locator path, rendition timecodes reused across renditions, retelling counted as independent, rights UNKNOWN read as permission, generated image EVIDENCES | same |
| W16 (protocols) | adherence inferred from adoption, dependency loops as repetition, midpoint cadence, third-party report minted as edition, private execution in Observation | same |

Rules: a Challenger offers a concrete failing case (Cypher or GraphQL), never a preference; every objection maps to a source, CQ or failure; Fable records resolution or justified deferral per objection in `reports/03-decision-report.md` section F; a failing shared-contract or privacy case blocks final admission until fixed.
