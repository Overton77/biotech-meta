// W11 fixture 05 -- negative mutations, each applied in isolation on top of fixtures 01-04 and removed again by the
// generic cleanup statement at the end of this file. Every mutation tags what it creates with negativeFixture = 'Nk'.
// The runner (../07-operations.md, "How the fixtures were run") executes: mutation Nk; every query of
// w11-validation.cypher plus baseline V-324/V-325; cleanup. Expected rows per mutation are in ../06-fixtures-and-queries.md.

// N1 (forbidden PROMOTES_CAPABILITY -> OPERATES_CAPABILITY; INV-305): attach the promoted OPERATING state.
// expect: V-324 1 row, V-324r 1 row
MATCH (f:Facility {uid: 'hu:facility:nai-carlsbad-powder-facility'}), (c:ManufacturingCapability {uid: 'hu:capability:nai-carlsbad-as-promoted'})
MERGE (f)-[h:HAS_CAPABILITY_STATE {relationshipUid: 'hu:rel:negative-n1-promoted-attached'}]->(c)
SET h.assertionUid = 'hu:assertion:nai-online-promotes-carlsbad-capability', h.validFromBasis = 'UNKNOWN', h.validToBasis = 'UNKNOWN',
    h.recordedFrom = datetime('2026-10-04T01:50:00Z'), h.negativeFixture = 'N1';

// N2 (forbidden PLANNED_CAPABILITY -> OPERATING_CAPABILITY): an OPERATING state carrying the planned target date and
// authorized by the PLANNED assertion. expect: V-W11-01 1 row (OBJECT_MISMATCH, VALID_TIME_DIFFERS), V-W11-03 1 row
MERGE (c:ManufacturingCapability:VersionedState {uid: 'hu:capability:negative-n2-operating-from-plan'})
SET c.stateType = 'MANUFACTURING_CAPABILITY', c.stage = 'OPERATING', c.capacityBasis = 'NOT_REPORTED',
    c.targetOperationalDate = datetime('2021-08-20T00:00:00Z'), c.targetOperationalDatePrecision = 'DAY',
    c.payloadHash = 'sha256:a854bbc3070bc0e36e7d85cecbdd8b2b7eca0d030ef532458431011569b3cc7d', c.createdAt = datetime('2026-10-04T01:50:00Z'), c.negativeFixture = 'N2'
WITH c
MATCH (f:Facility {uid: 'hu:facility:nai-carlsbad-powder-facility'}), (p:ManufacturingProcess {uid: 'hu:process:nai-carlsbad-powder-blending-and-packaging'})
MERGE (c)-[:CAPABILITY_FOR_PROCESS]->(p)
MERGE (f)-[h:HAS_CAPABILITY_STATE {relationshipUid: 'hu:rel:negative-n2-operating-from-plan'}]->(c)
SET h.assertionUid = 'hu:assertion:nai-carlsbad-planned-2021-bounded', h.validFrom = datetime('2021-08-20T00:00:00Z'),
    h.validFromPrecision = 'DAY', h.validFromBasis = 'STATED_BY_SOURCE', h.validToBasis = 'UNKNOWN',
    h.recordedFrom = datetime('2026-10-04T01:50:00Z'), h.negativeFixture = 'N2';

// N3 (forbidden CLAIMS_CGMP_COMPLIANCE -> CGMP_COMPLIANT): the cGMP claim projected as certification scope coverage.
// expect: V-W11-06 1 row
MERGE (sc:CertificationScope:VersionedState {uid: 'hu:certification-scope:negative-n3-from-cgmp-claim'})
SET sc.stateType = 'CERTIFICATION_SCOPE', sc.scopeText = 'cGMP (from company claim)', sc.payloadHash = 'sha256:ee66e092eced46c6ab6494e39587c883653027a72585b148b186667043d13293',
    sc.createdAt = datetime('2026-10-04T01:50:00Z'), sc.negativeFixture = 'N3'
WITH sc
MATCH (f:Facility {uid: 'hu:facility:nai-carlsbad-powder-facility'})
MERGE (sc)-[r:COVERS {relationshipUid: 'hu:rel:negative-n3-covers'}]->(f)
SET r.assertionUid = 'hu:assertion:nai-online-claims-cgmp', r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN',
    r.recordedFrom = datetime('2026-10-04T01:50:00Z'), r.negativeFixture = 'N3';

// N4 (EXCLUSIVE GOVERNED_BY_SPECIFICATION): two versions of one specification definitely govern one material at once.
// expect: V-W11-07 1 row; V-W11-01 2 rows (the edges cite no assertion: CITED_ASSERTION_MISSING)
MATCH (m:IngredientMaterial {uid: 'hu:material:niagen-nrc'}),
      (v1:SpecificationVersion {uid: 'hu:specification-version:niagen-spec-as-stated-grn-000635-2015'}),
      (v2:SpecificationVersion {uid: 'hu:specification-version:niagen-spec-as-proposed-efsa-2019'})
MERGE (m)-[g1:GOVERNED_BY_SPECIFICATION {relationshipUid: 'hu:rel:negative-n4-a'}]->(v1)
SET g1.assertionUid = 'hu:assertion:negative-n4-a', g1.validFrom = datetime('2019-01-01T00:00:00Z'), g1.validFromPrecision = 'MONTH',
    g1.validFromBasis = 'STATED_BY_SOURCE', g1.validTo = datetime('2020-01-01T00:00:00Z'), g1.validToPrecision = 'MONTH',
    g1.validToBasis = 'STATED_BY_SOURCE', g1.recordedFrom = datetime('2026-10-04T01:50:00Z'), g1.negativeFixture = 'N4'
MERGE (m)-[g2:GOVERNED_BY_SPECIFICATION {relationshipUid: 'hu:rel:negative-n4-b'}]->(v2)
SET g2.assertionUid = 'hu:assertion:negative-n4-b', g2.validFrom = datetime('2019-06-01T00:00:00Z'), g2.validFromPrecision = 'MONTH',
    g2.validFromBasis = 'STATED_BY_SOURCE', g2.validTo = datetime('2021-01-01T00:00:00Z'), g2.validToPrecision = 'MONTH',
    g2.validToBasis = 'STATED_BY_SOURCE', g2.recordedFrom = datetime('2026-10-04T01:50:00Z'), g2.negativeFixture = 'N4';

// N5 (forbidden SPECIFICATION_VERSION_CHANGE -> MATERIAL_IDENTITY_CHANGE): the 2019 version spawns a second material uid.
// expect: V-W11-11 1 row (informational review queue)
MERGE (m:IngredientMaterial:Entity {uid: 'hu:material:negative-n5-niagen-nrc-efsa-2019'})
SET m.name = 'Niagen NRC (EFSA 2019 specification)', m.entityType = 'INGREDIENT_MATERIAL', m.createdAt = datetime('2026-10-04T01:50:00Z'),
    m.negativeFixture = 'N5'
WITH m
MATCH (v:SpecificationVersion {uid: 'hu:specification-version:niagen-spec-as-proposed-efsa-2019'})
MERGE (a:Assertion {uid: 'hu:assertion:negative-n5-governed'})
SET a.predicate = 'GOVERNED_BY_SPECIFICATION', a.status = 'PROPOSED', a.recordedAt = datetime('2026-10-04T01:50:00Z'), a.negativeFixture = 'N5'
MERGE (a)-[:HAS_SUBJECT]->(m)
MERGE (a)-[:HAS_OBJECT]->(v)
MERGE (m)-[g:GOVERNED_BY_SPECIFICATION {relationshipUid: 'hu:rel:negative-n5-governed'}]->(v)
SET g.assertionUid = a.uid, g.validFromBasis = 'UNKNOWN', g.validToBasis = 'UNKNOWN', g.recordedFrom = datetime('2026-10-04T01:50:00Z'),
    g.negativeFixture = 'N5';

// N6 (D-008/CL-005): a live Material node used as a process input. expect: V-W11-12 2 rows (IO_ENDPOINT, LIVE_MATERIAL_NOT_MIGRATED)
MERGE (x:Material {id: 'negative-n6-methanol'})
SET x.name = 'Methanol (live Material)', x.negativeFixture = 'N6'
WITH x
MATCH (st:ManufacturingStep {uid: 'hu:process-step:nrc-grn-635-step-2'})
MERGE (st)-[r:INPUTS {relationshipUid: 'hu:rel:negative-n6'}]->(x)
SET r.assertionUid = 'hu:assertion:inputs-nrc-grn-635-step-2-methanol', r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN',
    r.recordedFrom = datetime('2026-10-04T01:50:00Z'), r.negativeFixture = 'N6';

// N7 (capacity coherence): a utilization percentage recorded as NAMEPLATE and above 100. expect: V-W11-05 1 row
MERGE (c:ManufacturingCapability:VersionedState {uid: 'hu:capability:negative-n7-percent-nameplate'})
SET c.stateType = 'MANUFACTURING_CAPABILITY', c.stage = 'OPERATING', c.capacityValue = 120.0, c.capacityUnitCode = '%',
    c.capacityBasis = 'NAMEPLATE', c.payloadHash = 'sha256:ed0703e77286a58ee979e3261c9ead587c35f2d3c7a1dbfb7dec6ee50030b7f4', c.createdAt = datetime('2026-10-04T01:50:00Z'), c.negativeFixture = 'N7';

// N8 (D-004): HAS_STEP used for a protocol. expect: V-W11-10 1 row (HAS_STEP_OUTSIDE_MANUFACTURING)
MERGE (pe:ProtocolEdition:VersionedState {uid: 'hu:protocol-edition:negative-n8'})
SET pe.stateType = 'PROTOCOL_EDITION', pe.payloadHash = 'sha256:234e38738c51d6a888e7d13b6d63df33afd48d974a8636f6761b706f031940f8', pe.createdAt = datetime('2026-10-04T01:50:00Z'), pe.negativeFixture = 'N8'
MERGE (ps:ProtocolStep:Entity {uid: 'hu:protocol-step:negative-n8'})
SET ps.entityType = 'PROTOCOL_STEP', ps.createdAt = datetime('2026-10-04T01:50:00Z'), ps.negativeFixture = 'N8'
MERGE (pe)-[r:HAS_STEP]->(ps)
SET r.negativeFixture = 'N8';

// N9 (VersionedState immutability): a criterion added in place to the 2015 version after commit.
// expect: V-W11-09 1 row (stated 4, attached 5)
MATCH (v:SpecificationVersion {uid: 'hu:specification-version:niagen-spec-as-stated-grn-000635-2015'})
MERGE (c:SpecificationCriterion:VersionedState {uid: 'hu:specification-criterion:negative-n9-added-in-place'})
SET c.stateType = 'SPECIFICATION_CRITERION', c.analyte = 'acetonitrile', c.comparator = 'NOT_DETECTED', c.payloadHash = 'sha256:e498750b14481e0eb0f4e725db00cdf20c4aa1fc8516678f92e83278a97fb009',
    c.createdAt = datetime('2026-10-04T01:50:00Z'), c.negativeFixture = 'N9'
MERGE (c)-[r:CRITERION_OF_SPECIFICATION]->(v)
SET r.negativeFixture = 'N9';

// N10 (EXCLUSIVE HAS_CAPABILITY_STATE per line): an OPERATING episode inside the reported closure (October 2023 to May 2024).
// expect: V-W11-02 1 row; V-W11-01 1 row (CITED_ASSERTION_MISSING)
MERGE (c:ManufacturingCapability:VersionedState {uid: 'hu:capability:negative-n10-operating-during-closure'})
SET c.stateType = 'MANUFACTURING_CAPABILITY', c.stage = 'OPERATING', c.capacityBasis = 'UTILIZED', c.capacityValue = 40.0,
    c.capacityUnitCode = '%', c.payloadHash = 'sha256:e45579e14a6500e0cb2926fe35917be751670fd3b3bad73907a7152322192a6b', c.createdAt = datetime('2026-10-04T01:50:00Z'), c.negativeFixture = 'N10'
WITH c
MATCH (f:Facility {uid: 'hu:facility:nai-carlsbad-powder-facility'}), (p:ManufacturingProcess {uid: 'hu:process:nai-carlsbad-powder-blending-and-packaging'})
MERGE (c)-[:CAPABILITY_FOR_PROCESS]->(p)
MERGE (f)-[h:HAS_CAPABILITY_STATE {relationshipUid: 'hu:rel:negative-n10'}]->(c)
SET h.assertionUid = 'hu:assertion:negative-n10', h.validFrom = datetime('2023-11-01T00:00:00Z'), h.validFromPrecision = 'MONTH',
    h.validFromBasis = 'STATED_BY_SOURCE', h.validTo = datetime('2024-02-01T00:00:00Z'), h.validToPrecision = 'MONTH',
    h.validToBasis = 'STATED_BY_SOURCE', h.recordedFrom = datetime('2026-10-04T01:50:00Z'), h.negativeFixture = 'N10';

// CLEANUP (run after each mutation)
MATCH ()-[r]->() WHERE r.negativeFixture IS NOT NULL DELETE r;

// CLEANUP-NODES
MATCH (n) WHERE n.negativeFixture IS NOT NULL DETACH DELETE n;
