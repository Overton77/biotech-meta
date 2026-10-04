
// ---- 7. Stored-value normalization (MR-10, INV-106 companions; see validation/fixtures-final/99-normalize-live-ids.cypher) ----
// Only the two shared-graph classes are respelled. Any other value (e.g. a private-store class that leaked in) is left as is so
// that V-115/V-116/V-521 and V-W23-09 keep reporting it (CH-P-12; W00 D5: reported, never rewritten).
MATCH (n) WHERE toLower(n.privacyClass) IN ['public','internal'] AND n.privacyClass <> toUpper(n.privacyClass) SET n.privacyClass = toUpper(n.privacyClass);
// Stored id = opaque uid segment (INV-106) on every archetype; the four W20 types whose GraphQL id is aliased keep their own id
// property (documentId, documentTextVersionId, segmentationId, chunkId) and never receive a stray `id` (CH-K-18c).
MATCH (n) WHERE n.uid IS NOT NULL AND n.id IS NULL AND NOT (n:Document OR n:DocumentTextVersion OR n:Segmentation OR n:Chunk)
  AND any(l IN labels(n) WHERE l IN ['Entity','VersionedState','Occurrence','InformationArtifact','Assertion','EvidenceAssessment'])
SET n.id = split(n.uid, ':')[-1];
MATCH (n:Document) WHERE n.uid IS NOT NULL AND n.documentId IS NULL SET n.documentId = split(n.uid, ':')[-1];
MATCH (n:DocumentTextVersion) WHERE n.uid IS NOT NULL AND n.documentTextVersionId IS NULL SET n.documentTextVersionId = split(n.uid, ':')[-1];
MATCH (n:Segmentation) WHERE n.uid IS NOT NULL AND n.segmentationId IS NULL SET n.segmentationId = split(n.uid, ':')[-1];
MATCH (n:Chunk) WHERE n.uid IS NOT NULL AND n.chunkId IS NULL SET n.chunkId = split(n.uid, ':')[-1];
// Timestamps: never a sentinel. A node first seen by this migration gets the migration instant (honest), else its own later clock.
MATCH (n) WHERE n.uid IS NOT NULL AND n.createdAt IS NULL SET n.createdAt = coalesce(n.updatedAt, n.recordedAt, n.retrievedAt, datetime());
MATCH (n) WHERE n.uid IS NOT NULL AND n.updatedAt IS NULL SET n.updatedAt = n.createdAt;

// V-503r backfill (W00-R-37; M-07): an asserted edge inherits validity basis and precision from its authorizing assertion; an edge with
// no bound carries basis UNKNOWN; a bounded edge with no stated basis anywhere is recorded as STATED_BY_SOURCE at DAY precision (the
// fixture literal's precision), which V-503r accepts and the audit trail (notes) records.
MATCH (x)-[r]->(y) WHERE r.assertionUid IS NOT NULL OR r.relationshipUid IS NOT NULL
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
SET r.validFromBasis = coalesce(r.validFromBasis, a.validFromBasis, CASE WHEN r.validFrom IS NULL THEN 'UNKNOWN' ELSE 'STATED_BY_SOURCE' END),
    r.validToBasis   = coalesce(r.validToBasis,   a.validToBasis,   CASE WHEN r.validTo   IS NULL THEN 'UNKNOWN' ELSE 'STATED_BY_SOURCE' END),
    r.validFromPrecision = CASE WHEN r.validFrom IS NULL THEN r.validFromPrecision ELSE coalesce(r.validFromPrecision, a.validFromPrecision, 'DAY') END,
    r.validToPrecision   = CASE WHEN r.validTo   IS NULL THEN r.validToPrecision   ELSE coalesce(r.validToPrecision,   a.validToPrecision,   'DAY') END;

// ---- 8. Capability matrix (what each statement group needs; verified at Wave 6 on the pinned stack) ----
// group | Community 5.26.31 (embedded, verified) | Enterprise 5.26 (companion file, unverified)
// 1–2 node uniqueness (uid, id)            | applied            | applied
// 3 relationship uniqueness (relationshipUid) | applied (5.7+)   | applied
// 3 relationship range index (recordedFrom)   | applied          | applied
// 4 fulltext indexes                           | applied          | applied
// 5 vector indexes (provider-less, D-014)      | applied; dimensions are a deployment parameter | applied
// 6–7 migration and normalization              | applied (no-op on fresh) | applied
// existence / property-type constraints        | REJECTED (edition) → service-enforced, see enterprise companion | companion file
// APOC Core 5.26.x                             | required for DateTime reads through @neo4j/graphql 7.6.3 (MR-12) | same
// Statements that depend on data (sections 6–7) are safe to re-run; DDL statements use IF NOT EXISTS.

// ---- 9. Query parameters used by the proposal's query shapes and validators (validation/validation-params.json) ----
// $asOf           DateTime   as-of instant for bitemporal reads (validFrom <= $asOf < validTo, recordedFrom <= $asOf < recordedTo)
// $recordedAsOf   DateTime   record-time cut for audit replays (QS-2b)
// $privacyClasses [String]   allowed stored privacyClass values for a reader (default ['PUBLIC'])
// $exclusivePredicates, $implicationPairs  predicate registry inputs for V-003 family checks
// $catalogV020CutoverAt      DateTime   migration cut for LEGACY_UNDATED edges
// $personUid, $sourceUid     subjects of the kernel competency queries (validation/kernel-cq-queries.cypher)
// Vector dimensions (section 5) and similarity function are set per deployment before the file is run.
