// W00 fixture 12 — NEGATIVE for direct Cypher ingestion: node shapes copied from the 0.2.0 repository fixtures that the final
// GraphQL schema cannot read. Each is legal Cypher and passes the catalog validators, but a non-null GraphQL field has no stored
// value or an enum field holds a spelling the GraphQL enum rejects. Expected: V-W00-08 rows for the missing fields, V-W00-09 rows for
// the spellings, and GraphQL field errors in 06-fixtures-and-queries.md §4 (T4). Load 00-common-base.cypher first.

// (a) examples/claim-retelling-provenance.cypher pattern: no id, no updatedAt, lowercase privacyClass, quantityBasis 'UNSPECIFIED'.
MATCH (subj:ChemicalSubstance {uid: 'hu:substance:w00-nmn'}), (l:SourceLocator {uid: 'hu:locator:w00-neg-quote'})
MERGE (a:Assertion {uid: 'hu:assertion:w00-legacy-shape'})
ON CREATE SET a.predicate = 'SELF_REPORTED_DAILY_INTAKE', a.status = 'PROPOSED', a.polarity = 'POSITIVE', a.valueNumber = 1.0, a.unitCode = 'g',
  a.quantityBasis = 'UNSPECIFIED', a.recordedAt = datetime('2026-01-01T05:00:00Z'), a.privacyClass = 'public', a.createdAt = datetime('2026-01-01T05:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(subj)
MERGE (a)-[:SUPPORTED_BY]->(l);

// (b) examples/recommendation-snapshot.cypher pattern: Adjudication status 'FINAL' (not an AssessmentStatus value), lowercase privacyClass.
MATCH (a:Assertion {uid: 'hu:assertion:w00-legacy-shape'})
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w00-legacy-final'})
ON CREATE SET j.id = 'w00-legacy-final', j.assessmentType = 'ADJUDICATION', j.methodVersion = 'label-policy-1', j.status = 'FINAL',
  j.adjudicationKind = 'SUPPORT', j.verdict = 'INSUFFICIENT', j.reviewerType = 'POLICY', j.recordedAt = datetime('2026-01-01T06:00:00Z'),
  j.privacyClass = 'internal', j.createdAt = datetime('2026-01-01T06:00:00Z'), j.updatedAt = datetime('2026-01-01T06:00:00Z')
MERGE (j)-[:EVALUATES]->(a);

// (c) recommendation-snapshot pattern: a SECTION locator without artifactType, id or updatedAt.
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:w00-neg-2026-01-01'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:w00-legacy-section'})
ON CREATE SET l.selectorKind = 'SECTION', l.section = 'Supplement Facts', l.privacyClass = 'public', l.createdAt = s.createdAt
MERGE (s)-[:HAS_LOCATOR]->(l);

// (d) live Document pattern (D-005 labels): stored documentId and title only; read through the Source type it has no `id`.
MERGE (d:Document:Source:Entity {uid: 'hu:document:w00-legacy-doc-1'})
ON CREATE SET d.documentId = 'w00-legacy-doc-1', d.title = 'Legacy document', d.url = 'https://legacy.example.invalid/doc-1', d.entityType = 'Document',
  d.canonicalUri = 'https://legacy.example.invalid/doc-1', d.createdAt = datetime('2026-01-01T00:00:00Z'), d.updatedAt = datetime('2026-01-01T00:00:00Z');
