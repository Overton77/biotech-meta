// W00 fixture 11 — atomic write guards (exactly-one-archetype, exactly-one-subject, at-most-one asserter, literal-xor-object,
// ClaimOccurrence container, no backdating, exclusive definite overlap, immutable content). Load 00-common-base.cypher first.
// Run with 11-write-guard-harness.mjs: each "// BUNDLE" block is ONE explicit transaction: (1) lock the subject node,
// (2) MERGE ... ON CREATE the records, (3) run the trailing "// AUDIT" statement inside the same transaction;
// rows from the audit => rollback (nothing of the bundle persists); zero rows => commit.
// Expected: G1 COMMIT; G2..G6 ROLLBACK with the violation named in each header; afterwards only G1's records exist.
// Recorded time is datetime.transaction() (service clock) except where a bundle deliberately backdates (G5).

// BUNDLE G0 (setup, commits): the variant every attachment bundle locks.
MERGE (n:ProductVariant:Entity {uid: 'hu:product-variant:w00-guard-variant'})
ON CREATE SET n.id = 'w00-guard-variant', n.entityType = 'ProductVariant', n.name = 'Synthetic guard variant', n.privacyClass = 'PUBLIC',
  n.createdAt = datetime('2026-01-01T00:00:00Z'), n.updatedAt = datetime('2026-01-01T00:00:00Z');
// AUDIT
MATCH (n:ProductVariant {uid: 'hu:product-variant:w00-guard-variant'}) WHERE n.id IS NULL RETURN n.uid AS item, ['SETUP_FAILED'] AS violations;

// BUNDLE G1 (valid): a formulation attachment for a variant, validity 2026-01-01 .. 2027-01-01 stated.
MATCH (v:ProductVariant {uid: 'hu:product-variant:w00-guard-variant'}) SET v.lockToken = randomUUID() REMOVE v.lockToken;
MERGE (fv:FormulationVersion:VersionedState {uid: 'hu:formulation:w00-guard-fv1'})
ON CREATE SET fv.id = 'w00-guard-fv1', fv.stateType = 'FormulationVersion', fv.jurisdiction = 'US', fv.payloadHash = 'sha256:synthetic-payload-w00-guard-fv1',
  fv.privacyClass = 'PUBLIC', fv.createdAt = datetime.transaction(), fv.updatedAt = datetime.transaction();
MATCH (v:ProductVariant {uid: 'hu:product-variant:w00-guard-variant'}), (fv:FormulationVersion {uid: 'hu:formulation:w00-guard-fv1'}), (l:SourceLocator {uid: 'hu:locator:w00-neg-quote'})
MERGE (a:Assertion {uid: 'hu:assertion:w00-guard-g1'})
ON CREATE SET a.id = 'w00-guard-g1', a.predicate = 'HAS_FORMULATION_VERSION', a.status = 'EXTRACTED', a.polarity = 'POSITIVE',
  a.validFrom = datetime('2026-01-01T00:00:00Z'), a.validFromPrecision = 'DAY', a.validFromBasis = 'STATED_BY_SOURCE',
  a.validTo = datetime('2027-01-01T00:00:00Z'), a.validToPrecision = 'DAY', a.validToBasis = 'STATED_BY_SOURCE', a.jurisdiction = 'US',
  a.contentHash = 'sha256:g1-content', a.recordedAt = datetime.transaction(), a.privacyClass = 'PUBLIC', a.createdAt = datetime.transaction(), a.updatedAt = datetime.transaction()
MERGE (a)-[:HAS_SUBJECT]->(v)
MERGE (a)-[:HAS_OBJECT]->(fv)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (v)-[h:HAS_FORMULATION_VERSION {relationshipUid: 'hu:rel:w00-guard-g1'}]->(fv)
ON CREATE SET h.assertionUid = a.uid, h.validFrom = a.validFrom, h.validFromPrecision = 'DAY', h.validFromBasis = 'STATED_BY_SOURCE',
  h.validTo = a.validTo, h.validToPrecision = 'DAY', h.validToBasis = 'STATED_BY_SOURCE', h.recordedFrom = a.recordedAt;
// AUDIT
UNWIND [['hu:assertion:w00-guard-g1', 'sha256:g1-content']] AS p
MATCH (a:Assertion {uid: p[0]})
CALL { WITH a OPTIONAL MATCH (a)-[:ASSERTED_BY]->(x) RETURN count(DISTINCT x) AS asserters }
CALL { WITH a OPTIONAL MATCH (a)-[:HAS_SUBJECT]->(s) RETURN count(s) AS subjects }
CALL { WITH a OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o) RETURN count(o) AS objects }
CALL { WITH a OPTIONAL MATCH (a)-[:OCCURS_IN]->(c) RETURN count(DISTINCT c) AS containers }
CALL { WITH a OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot) RETURN max(sn.retrievedAt) AS lastRetrieval }
CALL { WITH a
  OPTIONAL MATCH (sub)-[r]->(t) WHERE r.assertionUid = a.uid AND type(r) IN ['HAS_FORMULATION_VERSION','HAS_REGISTRATION_VERSION','HAS_PROTOCOL_EDITION']
  OPTIONAL MATCH (sub)-[r2]->(t2)
  WHERE r IS NOT NULL AND type(r2) = type(r) AND r2 <> r AND t2 <> t AND coalesce(t2.jurisdiction,'-') = coalesce(t.jurisdiction,'-') AND r2.recordedTo IS NULL
    AND r.validTo IS NOT NULL AND r2.validTo IS NOT NULL AND r.validFrom IS NOT NULL AND r2.validFrom IS NOT NULL
    AND (CASE WHEN r.validFrom > r2.validFrom THEN r.validFrom ELSE r2.validFrom END) + duration('P1D') < (CASE WHEN r.validTo < r2.validTo THEN r.validTo ELSE r2.validTo END)
  RETURN count(r2) AS definiteOverlaps }
WITH a, p, asserters, subjects, objects, containers, lastRetrieval, definiteOverlaps,
  [v IN [
    CASE WHEN size([x IN labels(a) WHERE x IN ['Entity','VersionedState','Occurrence','InformationArtifact','Assertion','EvidenceAssessment']]) <> 1 THEN 'ARCHETYPE_COUNT' END,
    CASE WHEN subjects <> 1 THEN 'SUBJECT_COUNT' END,
    CASE WHEN asserters > 1 OR (a:ClaimOccurrence AND asserters <> 1) THEN 'ASSERTER_COUNT' END,
    CASE WHEN objects + size([x IN [a.valueString, a.valueNumber, a.valueBoolean] WHERE x IS NOT NULL]) <> 1 THEN 'LITERAL_XOR_OBJECT' END,
    CASE WHEN a:ClaimOccurrence AND containers <> 1 THEN 'CLAIM_OCCURRENCE_CONTAINER' END,
    CASE WHEN lastRetrieval IS NOT NULL AND a.recordedAt < lastRetrieval THEN 'BACKDATED_RECORDED_AT' END,
    CASE WHEN definiteOverlaps > 0 THEN 'EXCLUSIVE_DEFINITE_OVERLAP' END,
    CASE WHEN a.contentHash <> p[1] THEN 'IMMUTABLE_CONTENT_CONFLICT' END
  ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN a.uid AS assertion, violations;

// BUNDLE G2 (must roll back: ASSERTER_COUNT): one assertion attributed to two co-hosts.
MATCH (subj:ChemicalSubstance {uid: 'hu:substance:w00-nmn'}), (p1:Person {uid: 'hu:person:w00-cohost-1'}), (p2:Person {uid: 'hu:person:w00-cohost-2'}), (l:SourceLocator {uid: 'hu:locator:w00-neg-quote'})
MERGE (a:Assertion {uid: 'hu:assertion:w00-guard-g2'})
ON CREATE SET a.id = 'w00-guard-g2', a.predicate = 'SELF_REPORTED_DAILY_INTAKE', a.status = 'EXTRACTED', a.valueNumber = 1.0, a.unitCode = 'g',
  a.contentHash = 'sha256:g2-content', a.recordedAt = datetime.transaction(), a.privacyClass = 'PUBLIC', a.createdAt = datetime.transaction(), a.updatedAt = datetime.transaction()
MERGE (a)-[:HAS_SUBJECT]->(subj) MERGE (a)-[:ASSERTED_BY]->(p1) MERGE (a)-[:ASSERTED_BY]->(p2) MERGE (a)-[:SUPPORTED_BY]->(l);
// AUDIT
UNWIND [['hu:assertion:w00-guard-g2', 'sha256:g2-content']] AS p
MATCH (a:Assertion {uid: p[0]})
CALL { WITH a OPTIONAL MATCH (a)-[:ASSERTED_BY]->(x) RETURN count(DISTINCT x) AS asserters }
CALL { WITH a OPTIONAL MATCH (a)-[:HAS_SUBJECT]->(s) RETURN count(s) AS subjects }
CALL { WITH a OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o) RETURN count(o) AS objects }
WITH a, p, asserters, subjects, objects,
  [v IN [CASE WHEN subjects <> 1 THEN 'SUBJECT_COUNT' END, CASE WHEN asserters > 1 THEN 'ASSERTER_COUNT' END,
         CASE WHEN objects + size([x IN [a.valueString, a.valueNumber, a.valueBoolean] WHERE x IS NOT NULL]) <> 1 THEN 'LITERAL_XOR_OBJECT' END,
         CASE WHEN a.contentHash <> p[1] THEN 'IMMUTABLE_CONTENT_CONFLICT' END] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN a.uid AS assertion, violations;

// BUNDLE G3 (must roll back: LITERAL_XOR_OBJECT): an object AND a literal on one assertion.
MATCH (subj:ChemicalSubstance {uid: 'hu:substance:w00-nmn'}), (p1:Person {uid: 'hu:person:w00-cohost-1'}), (l:SourceLocator {uid: 'hu:locator:w00-neg-quote'})
MERGE (a:Assertion {uid: 'hu:assertion:w00-guard-g3'})
ON CREATE SET a.id = 'w00-guard-g3', a.predicate = 'SELF_REPORTED_DAILY_INTAKE', a.status = 'EXTRACTED', a.valueNumber = 1.0, a.unitCode = 'g',
  a.contentHash = 'sha256:g3-content', a.recordedAt = datetime.transaction(), a.privacyClass = 'PUBLIC', a.createdAt = datetime.transaction(), a.updatedAt = datetime.transaction()
MERGE (a)-[:HAS_SUBJECT]->(subj) MERGE (a)-[:HAS_OBJECT]->(p1) MERGE (a)-[:ASSERTED_BY]->(p1) MERGE (a)-[:SUPPORTED_BY]->(l);
// AUDIT
UNWIND [['hu:assertion:w00-guard-g3', 'sha256:g3-content']] AS p
MATCH (a:Assertion {uid: p[0]})
CALL { WITH a OPTIONAL MATCH (a)-[:ASSERTED_BY]->(x) RETURN count(DISTINCT x) AS asserters }
CALL { WITH a OPTIONAL MATCH (a)-[:HAS_SUBJECT]->(s) RETURN count(s) AS subjects }
CALL { WITH a OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o) RETURN count(o) AS objects }
WITH a, p, asserters, subjects, objects,
  [v IN [CASE WHEN subjects <> 1 THEN 'SUBJECT_COUNT' END, CASE WHEN asserters > 1 THEN 'ASSERTER_COUNT' END,
         CASE WHEN objects + size([x IN [a.valueString, a.valueNumber, a.valueBoolean] WHERE x IS NOT NULL]) <> 1 THEN 'LITERAL_XOR_OBJECT' END,
         CASE WHEN a.contentHash <> p[1] THEN 'IMMUTABLE_CONTENT_CONFLICT' END] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN a.uid AS assertion, violations;

// BUNDLE G4 (must roll back: EXCLUSIVE_DEFINITE_OVERLAP): a second formulation for the same variant and jurisdiction,
// valid 2026-06-01 .. 2027-06-01, while G1's episode (2026-01-01 .. 2027-01-01) is currently recorded. The subject lock
// (first statement) serializes concurrent attachment writers so the check cannot race.
MATCH (v:ProductVariant {uid: 'hu:product-variant:w00-guard-variant'}) SET v.lockToken = randomUUID() REMOVE v.lockToken;
MERGE (fv:FormulationVersion:VersionedState {uid: 'hu:formulation:w00-guard-fv2'})
ON CREATE SET fv.id = 'w00-guard-fv2', fv.stateType = 'FormulationVersion', fv.jurisdiction = 'US', fv.payloadHash = 'sha256:synthetic-payload-w00-guard-fv2',
  fv.privacyClass = 'PUBLIC', fv.createdAt = datetime.transaction(), fv.updatedAt = datetime.transaction();
MATCH (v:ProductVariant {uid: 'hu:product-variant:w00-guard-variant'}), (fv:FormulationVersion {uid: 'hu:formulation:w00-guard-fv2'}), (l:SourceLocator {uid: 'hu:locator:w00-neg-quote'})
MERGE (a:Assertion {uid: 'hu:assertion:w00-guard-g4'})
ON CREATE SET a.id = 'w00-guard-g4', a.predicate = 'HAS_FORMULATION_VERSION', a.status = 'EXTRACTED', a.polarity = 'POSITIVE',
  a.validFrom = datetime('2026-06-01T00:00:00Z'), a.validFromPrecision = 'DAY', a.validFromBasis = 'STATED_BY_SOURCE',
  a.validTo = datetime('2027-06-01T00:00:00Z'), a.validToPrecision = 'DAY', a.validToBasis = 'STATED_BY_SOURCE', a.jurisdiction = 'US',
  a.contentHash = 'sha256:g4-content', a.recordedAt = datetime.transaction(), a.privacyClass = 'PUBLIC', a.createdAt = datetime.transaction(), a.updatedAt = datetime.transaction()
MERGE (a)-[:HAS_SUBJECT]->(v) MERGE (a)-[:HAS_OBJECT]->(fv) MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (v)-[h:HAS_FORMULATION_VERSION {relationshipUid: 'hu:rel:w00-guard-g4'}]->(fv)
ON CREATE SET h.assertionUid = a.uid, h.validFrom = a.validFrom, h.validFromPrecision = 'DAY', h.validFromBasis = 'STATED_BY_SOURCE',
  h.validTo = a.validTo, h.validToPrecision = 'DAY', h.validToBasis = 'STATED_BY_SOURCE', h.recordedFrom = a.recordedAt;
// AUDIT
UNWIND [['hu:assertion:w00-guard-g4', 'sha256:g4-content']] AS p
MATCH (a:Assertion {uid: p[0]})
CALL { WITH a
  OPTIONAL MATCH (sub)-[r]->(t) WHERE r.assertionUid = a.uid AND type(r) IN ['HAS_FORMULATION_VERSION','HAS_REGISTRATION_VERSION','HAS_PROTOCOL_EDITION']
  OPTIONAL MATCH (sub)-[r2]->(t2)
  WHERE r IS NOT NULL AND type(r2) = type(r) AND r2 <> r AND t2 <> t AND coalesce(t2.jurisdiction,'-') = coalesce(t.jurisdiction,'-') AND r2.recordedTo IS NULL
    AND r.validTo IS NOT NULL AND r2.validTo IS NOT NULL AND r.validFrom IS NOT NULL AND r2.validFrom IS NOT NULL
    AND (CASE WHEN r.validFrom > r2.validFrom THEN r.validFrom ELSE r2.validFrom END) + duration('P1D') < (CASE WHEN r.validTo < r2.validTo THEN r.validTo ELSE r2.validTo END)
  RETURN count(r2) AS definiteOverlaps }
WITH a, definiteOverlaps WHERE definiteOverlaps > 0
RETURN a.uid AS assertion, ['EXCLUSIVE_DEFINITE_OVERLAP'] AS violations;

// BUNDLE G5 (must roll back: BACKDATED_RECORDED_AT): a client-supplied recordedAt earlier than the snapshot's retrievedAt.
MATCH (subj:ChemicalSubstance {uid: 'hu:substance:w00-nmn'}), (p1:Person {uid: 'hu:person:w00-cohost-1'}), (l:SourceLocator {uid: 'hu:locator:w00-neg-quote'})
MERGE (a:Assertion {uid: 'hu:assertion:w00-guard-g5'})
ON CREATE SET a.id = 'w00-guard-g5', a.predicate = 'SELF_REPORTED_DAILY_INTAKE', a.status = 'EXTRACTED', a.valueNumber = 1.0, a.unitCode = 'g',
  a.contentHash = 'sha256:g5-content', a.recordedAt = datetime('2025-06-01T00:00:00Z'), a.privacyClass = 'PUBLIC', a.createdAt = datetime.transaction(), a.updatedAt = datetime.transaction()
MERGE (a)-[:HAS_SUBJECT]->(subj) MERGE (a)-[:ASSERTED_BY]->(p1) MERGE (a)-[:SUPPORTED_BY]->(l);
// AUDIT
MATCH (a:Assertion {uid: 'hu:assertion:w00-guard-g5'})
CALL { WITH a OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot) RETURN max(sn.retrievedAt) AS lastRetrieval }
WITH a, lastRetrieval WHERE a.recordedAt < lastRetrieval OR a.recordedAt < datetime.transaction() - duration('PT5M')
RETURN a.uid AS assertion, ['BACKDATED_RECORDED_AT'] AS violations;

// BUNDLE G6 (must be refused: IMMUTABLE_CONTENT_CONFLICT): a re-ingestion of G1's uid with different content (validFrom moved).
// MERGE ... ON CREATE does nothing because the node exists; the audit compares the stored contentHash with the proposed one.
MATCH (v:ProductVariant {uid: 'hu:product-variant:w00-guard-variant'}), (fv:FormulationVersion {uid: 'hu:formulation:w00-guard-fv1'})
MERGE (a:Assertion {uid: 'hu:assertion:w00-guard-g1'})
ON CREATE SET a.id = 'w00-guard-g1', a.predicate = 'HAS_FORMULATION_VERSION', a.status = 'EXTRACTED', a.validFrom = datetime('2025-09-01T00:00:00Z'),
  a.contentHash = 'sha256:g1-content-moved-validFrom', a.recordedAt = datetime.transaction();
// AUDIT
UNWIND [['hu:assertion:w00-guard-g1', 'sha256:g1-content-moved-validFrom']] AS p
MATCH (a:Assertion {uid: p[0]})
WITH a, p WHERE a.contentHash <> p[1]
RETURN a.uid AS assertion, ['IMMUTABLE_CONTENT_CONFLICT'] AS violations;
