// W14 fixture 3/4: NEGATIVE cases. Each statement block writes a record that a W14 validator must flag. Run after
// fixtures 1 and 2. Expected: V-W14-01 (1 row), V-W14-02 (1), V-W14-05 (1), V-W14-07 (1), V-W14-08 (1), V-W14-09 (1), V-W14-12 (1).

MERGE (n:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
SET n:Occurrence, n += {occurrenceType: 'Activity', activityKind: 'EXTRACTION', startedAt: datetime('2026-10-04T00:57:00Z'), endedAt: datetime('2026-10-04T01:30:00Z'), methodVersion: 'w14-manual-curation/v1', externalRunSystem: 'claude-code', externalRunId: 'run-2026-10-04-fable51-01/W14', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Agent {uid: 'hu:agent:w14-opus-5-5'})
SET n:Entity, n += {entityType: 'Agent', name: 'W14 worker (Opus 5.5)', agentKind: 'MANUAL_VALIDATION_OF_AUTOMATED_AGENT', model: 'claude-opus-5-5', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Activity {uid: 'hu:activity:w14-curation-2026-10-04'}), (b:Agent {uid: 'hu:agent:w14-opus-5-5'})
MERGE (a)-[r:WAS_ASSOCIATED_WITH]->(b);
MERGE (n:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'})
SET n:EvidenceAssessment, n += {assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', reviewedAt: datetime('2026-10-04T02:00:00Z'), recordedAt: datetime('2026-10-04T02:00:00Z'), methodVersion: 'w14-capture-check/v1', status: 'ACCEPTED', createdAt: datetime('2026-10-04T02:00:00Z'), rationale: 'Each evaluated assertion was compared with the stored excerpt of its locator.', privacyClass: 'PUBLIC'};
MERGE (n:Study {uid: 'hu:study:nct02712593'})
SET n:Entity, n += {entityType: 'Study', title: 'Niagen dose-response study registered as NCT02712593 (identity stub; owner W09)', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
// N-1 [LICENSES_PATENT, OWNS_STUDY]: a derived OWNS_STUDY edge whose only input is the license assertion.
MATCH (o:LegalEntity {uid: 'hu:org:chromadex-inc'}), (s:Study {uid: 'hu:study:nct02712593'})
MERGE (o)-[r:OWNS_STUDY]->(s)
SET r.derivationRule = 'BAD: licensee of NR patent owns NR studies', r.derivedFromAssertionUids = ['hu:assertion:w14-licensee-l2014-chromadex-inc'], r.derivedAt = datetime('2026-10-04T01:40:00Z');
// N-2 [PATENT_CLAIMS, PROVES_EFFICACY]: a CALCULATED efficacy assertion derived from the claim-1 functional limitation.
MERGE (n:Assertion {uid: 'hu:assertion:w14-neg-proves-efficacy'})
SET n += {predicate: 'PROVES_EFFICACY', status: 'PROPOSED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:3c71f820620fae154e8c219a46cd9ec615595c9024aa19de18beafc78a4212ee', polarity: 'POSITIVE', predicateClass: 'OTHER', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', valueString: 'increases NAD+ biosynthesis', basisKind: 'CALCULATED', derivationRule: 'BAD: claim says increases NAD+ biosynthesis upon oral administration', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-proves-efficacy'}), (b:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-proves-efficacy'}), (b:Agent {uid: 'hu:agent:w14-opus-5-5'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-proves-efficacy'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-proves-efficacy'}), (b:Assertion {uid: 'hu:assertion:w14-patent-claims-us8197807-c1-nr-curator'})
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(b);
// N-3 family membership read as license coverage: LICENSE_COVERS L2014 -> EP application, citing an assertion with another predicate.
MATCH (l:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2014-05-16'}), (p:PatentApplication {uid: 'hu:patent-application:ep-05722944'})
MERGE (l)-[r:LICENSE_COVERS {relationshipUid: 'hu:rel:w14-neg-family-coverage'}]->(p)
SET r.assertionUid = 'hu:assertion:w14-licensee-l2014-chromadex-inc', r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T01:40:00Z');
// N-4 claim validity read from patent-level status: CLAIM_CONFIRMED derived from the aggregator GRANTED_IN_FORCE assertion.
MERGE (n:IpRightStatus {uid: 'hu:ip-status:neg-us8197807-c1-confirmed'})
SET n:VersionedState, n += {stateType: 'IpRightStatus', payloadHash: 'sha256:e34c861b87a6adad6f465a4e68b8b2737a3a22b625a2972c252cce2636048d92', statusKind: 'CLAIM_CONFIRMED', jurisdiction: 'US', effectiveFrom: datetime('2012-06-12T00:00:00Z'), privacyClass: 'PUBLIC', maturity: 'CANDIDATE', createdAt: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-neg-c1-confirmed-from-active'})
SET n += {predicate: 'IP_STATUS_OF', status: 'PROPOSED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:b0d3c091c979e29d490a5ace71dd2a56338733a23beedcf6c4dadd3a6ebdec28', polarity: 'POSITIVE', predicateClass: 'REGULATORY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2012-06-12T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'INFERRED', validToBasis: 'UNKNOWN', jurisdiction: 'US', basisKind: 'CALCULATED', derivationRule: 'BAD: patent Active implies claims valid', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-c1-confirmed-from-active'}), (b:IpRightStatus {uid: 'hu:ip-status:neg-us8197807-c1-confirmed'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-c1-confirmed-from-active'}), (b:PatentClaim {uid: 'hu:patent-claim:us-8197807-c1'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-c1-confirmed-from-active'}), (b:Agent {uid: 'hu:agent:w14-opus-5-5'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-c1-confirmed-from-active'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:IpRightStatus {uid: 'hu:ip-status:neg-us8197807-c1-confirmed'}), (b:PatentClaim {uid: 'hu:patent-claim:us-8197807-c1'})
MERGE (a)-[r:IP_STATUS_OF {relationshipUid: 'hu:rel:w14-neg-c1-confirmed-from-active'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-neg-c1-confirmed-from-active', validFrom: datetime('2012-06-12T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'INFERRED', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-c1-confirmed-from-active'}), (b:Assertion {uid: 'hu:assertion:w14-status-us8197807-in-force-gp'})
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(b);
// N-5 identity collision: the Madrid IR number (listed as a related property on the US record) attached to the US right.
MERGE (n:Assertion {uid: 'hu:assertion:w14-neg-ir-on-us-right'})
SET n += {predicate: 'HAS_IDENTIFIER', status: 'PROPOSED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:fb62a91cb1c65d23bed00f5717d5f3ce890cf76d323a8a7f5b9b54b1ff83b655', polarity: 'POSITIVE', predicateClass: 'IDENTITY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-ir-on-us-right'}), (b:Trademark {uid: 'hu:trademark:us-sn85932490-niagen'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-ir-on-us-right'}), (b:Identifier {uid: 'hu:identifier:wipo-madrid-ir-1336169'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-ir-on-us-right'}), (b:Organization {uid: 'hu:org:uspto'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-ir-on-us-right'}), (b:SourceLocator {uid: 'hu:locator:tsdr-85932490-related-ir'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-ir-on-us-right'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Trademark {uid: 'hu:trademark:us-sn85932490-niagen'}), (b:Identifier {uid: 'hu:identifier:wipo-madrid-ir-1336169'})
MERGE (a)-[r:HAS_IDENTIFIER {relationshipUid: 'hu:rel:w14-neg-ir-on-us-right'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-neg-ir-on-us-right', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
// N-6 legacy status property written on an IP artifact instead of an IpRightStatus episode.
MATCH (g:GrantedPatent {uid: 'hu:granted-patent:us-8197807'}) SET g.status = 'Active';
// N-7 [OWNS_TRADEMARK, MARKETS/SUPPLIES]: supplier role derived from mark ownership.
MERGE (n:Assertion {uid: 'hu:assertion:w14-neg-supplies-from-mark'})
SET n += {predicate: 'SUPPLIES_INGREDIENT_MATERIAL', status: 'PROPOSED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:322e1e6dee226f285d543c3f6bc0c9d909ee5bf5adba35225e2335a3d21c613e', polarity: 'POSITIVE', predicateClass: 'OTHER', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', basisKind: 'CALCULATED', derivationRule: 'BAD: mark owner supplies the marked material', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-supplies-from-mark'}), (b:LegalEntity {uid: 'hu:org:chromadex-inc'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-supplies-from-mark'}), (b:BrandedIngredientMaterial {uid: 'hu:material:niagen'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-supplies-from-mark'}), (b:Agent {uid: 'hu:agent:w14-opus-5-5'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-supplies-from-mark'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-supplies-from-mark'}), (b:Assertion {uid: 'hu:assertion:w14-owns-tm-niagen-chromadex-inc'})
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(b);
