// =====================================================================================================================
// W03 projection job: derivation rule mx-proj/v1 (regenerable; the derived edges are never the only history).
// Inputs: Assertions with predicateClass MECHANISM, basisKind DIRECT_MEASUREMENT, status ACCEPTED, polarity POSITIVE,
// recordedTo null, exactly one OBSERVED_IN_CONTEXT. Grouping key: (subject or object endpoints, edge type, predicate).
// Rule-mode edges carry derivationRule + derivedFromAssertionUids (never projectionOfAssertionUid, because the input
// predicate differs from the edge type and V-112 would report CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE).
// Idempotent: step 0 deletes every mx-proj/v1 edge, steps 1-5 rebuild them. Run inside one write transaction per
// affected subgraph in production (see 07-operations.md); here each statement is its own transaction.
// =====================================================================================================================

// Step 0: drop previous rule-mode projections (regeneration).
// status: run
MATCH ()-[r:AFFECTS_MECHANISM|MODULATES|APPLIES_TO_SPECIES|INFLUENCES_OUTCOME|ACTS_IN]->()
WHERE r.derivationRule = 'mx-proj/v1'
DELETE r;

// Step 1: AFFECTS_MECHANISM (IngredientMaterial | ChemicalForm | ChemicalSubstance | Lifestyle -> Mechanism).
// Lifestyle as subject accepted for W05-SR-05 (W03 ruling, 05-decision-seam-ledger.md D-W03-09).
// status: run
MATCH (a:Assertion)-[:HAS_OBJECT]->(m:Mechanism)
WHERE a.predicateClass = 'MECHANISM' AND a.basisKind = 'DIRECT_MEASUREMENT' AND a.status = 'ACCEPTED'
  AND a.polarity = 'POSITIVE' AND a.recordedTo IS NULL
  AND a.predicate IN ['INDUCES_PROCESS', 'INHIBITS_PROCESS', 'IMPROVES', 'IMPAIRS', 'EXTENDS']
  AND COUNT { (a)-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext) } = 1
MATCH (a)-[:HAS_SUBJECT]->(x)
WHERE x:IngredientMaterial OR x:ChemicalForm OR x:ChemicalSubstance OR x:Lifestyle
MATCH (a)-[:OBSERVED_IN_CONTEXT]->(c:MechanismEvidenceContext)
OPTIONAL MATCH (c)-[:IN_SPECIES]->(sp:Species)
OPTIONAL MATCH (c)-[:MEASURED_IN]->(site:AnatomicalContext)
WITH x, m, a.predicate AS pred, collect(DISTINCT a.uid) AS uids, collect(DISTINCT sp.uid) AS sps,
     collect(DISTINCT c.setting) AS settings, collect(DISTINCT site.uid) AS sites
CREATE (x)-[r:AFFECTS_MECHANISM]->(m)
SET r.derivationRule = 'mx-proj/v1', r.derivedFromAssertionUids = uids, r.projectedPredicate = pred,
    r.projectedPolarity = 'POSITIVE', r.speciesUids = sps, r.settings = settings, r.anatomicalContextUids = sites,
    r.derivedAt = datetime();

// Step 2: MODULATES (ChemicalSubstance | IngredientMaterial -> MolecularEntity).
// status: run
MATCH (a:Assertion)-[:HAS_OBJECT]->(me:MolecularEntity)
WHERE a.predicateClass = 'MECHANISM' AND a.basisKind = 'DIRECT_MEASUREMENT' AND a.status = 'ACCEPTED'
  AND a.polarity = 'POSITIVE' AND a.recordedTo IS NULL
  AND a.predicate IN ['INCREASES_ACTIVITY_OF', 'DECREASES_ACTIVITY_OF', 'BINDS']
  AND COUNT { (a)-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext) } = 1
MATCH (a)-[:HAS_SUBJECT]->(x)
WHERE x:IngredientMaterial OR x:ChemicalSubstance
MATCH (a)-[:OBSERVED_IN_CONTEXT]->(c:MechanismEvidenceContext)
OPTIONAL MATCH (c)-[:IN_SPECIES]->(sp:Species)
OPTIONAL MATCH (c)-[:MEASURED_IN]->(site:AnatomicalContext)
WITH x, me, a.predicate AS pred, collect(DISTINCT a.uid) AS uids, collect(DISTINCT sp.uid) AS sps,
     collect(DISTINCT c.setting) AS settings, collect(DISTINCT site.uid) AS sites
CREATE (x)-[r:MODULATES]->(me)
SET r.derivationRule = 'mx-proj/v1', r.derivedFromAssertionUids = uids, r.projectedPredicate = pred,
    r.projectedPolarity = 'POSITIVE', r.speciesUids = sps, r.settings = settings, r.anatomicalContextUids = sites,
    r.derivedAt = datetime();

// Step 3: APPLIES_TO_SPECIES (Mechanism -> Species): only species of contexts of qualifying assertions (V-234r).
// status: run
MATCH (a:Assertion)-[:HAS_OBJECT|HAS_SUBJECT]->(m:Mechanism)
WHERE a.predicateClass = 'MECHANISM' AND a.basisKind = 'DIRECT_MEASUREMENT' AND a.status = 'ACCEPTED'
  AND a.polarity = 'POSITIVE' AND a.recordedTo IS NULL
  AND COUNT { (a)-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext) } = 1
MATCH (a)-[:OBSERVED_IN_CONTEXT]->(c:MechanismEvidenceContext)-[:IN_SPECIES]->(sp:Species)
OPTIONAL MATCH (c)-[:MEASURED_IN]->(site:AnatomicalContext)
WITH m, sp, collect(DISTINCT a.uid) AS uids, collect(DISTINCT c.setting) AS settings, collect(DISTINCT site.uid) AS sites
CREATE (m)-[r:APPLIES_TO_SPECIES]->(sp)
SET r.derivationRule = 'mx-proj/v1', r.derivedFromAssertionUids = uids, r.projectedPolarity = 'POSITIVE',
    r.speciesUids = [sp.uid], r.settings = settings, r.anatomicalContextUids = sites, r.derivedAt = datetime();

// Step 4: ACTS_IN (Mechanism -> AnatomicalContext, Organ included through its AnatomicalContext label).
// status: run
MATCH (a:Assertion)-[:HAS_OBJECT|HAS_SUBJECT]->(m:Mechanism)
WHERE a.predicateClass = 'MECHANISM' AND a.basisKind = 'DIRECT_MEASUREMENT' AND a.status = 'ACCEPTED'
  AND a.polarity = 'POSITIVE' AND a.recordedTo IS NULL
  AND COUNT { (a)-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext) } = 1
MATCH (a)-[:OBSERVED_IN_CONTEXT]->(c:MechanismEvidenceContext)-[:MEASURED_IN]->(site:AnatomicalContext)
OPTIONAL MATCH (c)-[:IN_SPECIES]->(sp:Species)
WITH m, site, collect(DISTINCT a.uid) AS uids, collect(DISTINCT sp.uid) AS sps, collect(DISTINCT c.setting) AS settings
CREATE (m)-[r:ACTS_IN]->(site)
SET r.derivationRule = 'mx-proj/v1', r.derivedFromAssertionUids = uids, r.projectedPolarity = 'POSITIVE',
    r.speciesUids = sps, r.settings = settings, r.anatomicalContextUids = [site.uid], r.derivedAt = datetime();

// Step 5: INFLUENCES_OUTCOME (Mechanism -> Outcome): subject is the Mechanism, object the Outcome.
// status: run (no qualifying input in the fixture; expected 0 edges)
MATCH (a:Assertion)-[:HAS_SUBJECT]->(m:Mechanism), (a)-[:HAS_OBJECT]->(o:Outcome)
WHERE a.predicateClass = 'MECHANISM' AND a.basisKind = 'DIRECT_MEASUREMENT' AND a.status = 'ACCEPTED'
  AND a.polarity = 'POSITIVE' AND a.recordedTo IS NULL
  AND a.predicate IN ['IMPROVES', 'IMPAIRS', 'EXTENDS', 'INDUCES_PROCESS', 'INHIBITS_PROCESS']
  AND COUNT { (a)-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext) } = 1
MATCH (a)-[:OBSERVED_IN_CONTEXT]->(c:MechanismEvidenceContext)
OPTIONAL MATCH (c)-[:IN_SPECIES]->(sp:Species)
WITH m, o, a.predicate AS pred, collect(DISTINCT a.uid) AS uids, collect(DISTINCT sp.uid) AS sps, collect(DISTINCT c.setting) AS settings
CREATE (m)-[r:INFLUENCES_OUTCOME]->(o)
SET r.derivationRule = 'mx-proj/v1', r.derivedFromAssertionUids = uids, r.projectedPredicate = pred,
    r.projectedPolarity = 'POSITIVE', r.speciesUids = sps, r.settings = settings, r.derivedAt = datetime();

// One-to-one projections (INCREASES_RISK_FOR, MEDIATES_RISK_THROUGH, ASSOCIATED_WITH_CONDITION, ASSOCIATED_WITH_OUTCOME):
// projectionOfAssertionUid of an ACCEPTED DIRECT_MEASUREMENT POSITIVE assertion whose predicate equals the edge type.
// status: run (no qualifying input in the fixture; expected 0 edges)
MATCH (a:Assertion)-[:HAS_SUBJECT]->(x), (a)-[:HAS_OBJECT]->(y)
WHERE a.predicate IN ['INCREASES_RISK_FOR', 'MEDIATES_RISK_THROUGH', 'ASSOCIATED_WITH_CONDITION', 'ASSOCIATED_WITH_OUTCOME']
  AND a.basisKind = 'DIRECT_MEASUREMENT' AND a.status = 'ACCEPTED' AND a.polarity = 'POSITIVE' AND a.recordedTo IS NULL
  AND COUNT { (a)-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext) } = 1
  AND NOT EXISTS { MATCH (x)-[r]->(y) WHERE type(r) = a.predicate AND r.projectionOfAssertionUid = a.uid }
WITH a, x, y
CALL (a, x, y) {
  WITH a, x, y WHERE a.predicate = 'INCREASES_RISK_FOR' CREATE (x)-[r:INCREASES_RISK_FOR]->(y) SET r.projectionOfAssertionUid = a.uid, r.projectedPolarity = 'POSITIVE', r.derivedAt = datetime()
  UNION
  WITH a, x, y WHERE a.predicate = 'MEDIATES_RISK_THROUGH' CREATE (x)-[r:MEDIATES_RISK_THROUGH]->(y) SET r.projectionOfAssertionUid = a.uid, r.projectedPolarity = 'POSITIVE', r.derivedAt = datetime()
  UNION
  WITH a, x, y WHERE a.predicate = 'ASSOCIATED_WITH_CONDITION' CREATE (x)-[r:ASSOCIATED_WITH_CONDITION]->(y) SET r.projectionOfAssertionUid = a.uid, r.projectedPolarity = 'POSITIVE', r.derivedAt = datetime()
  UNION
  WITH a, x, y WHERE a.predicate = 'ASSOCIATED_WITH_OUTCOME' CREATE (x)-[r:ASSOCIATED_WITH_OUTCOME]->(y) SET r.projectionOfAssertionUid = a.uid, r.projectedPolarity = 'POSITIVE', r.derivedAt = datetime()
}
RETURN count(*) AS oneToOneProjectionsCreated;
