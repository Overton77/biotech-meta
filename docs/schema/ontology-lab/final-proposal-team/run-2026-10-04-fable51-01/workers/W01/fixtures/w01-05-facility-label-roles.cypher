// Run run-2026-10-04-fable51-01, worker W01 (Opus 5.5). Generated 2026-10-04 by the W01 fixture generator (scratchpad).
// Rules: statements separated by ';'; every statement binds its own nodes by uid (no variable crosses ';');
// nodes carry the primary label and the archetype label; uids use registered tokens (org, person, brand, facility,
// source, snapshot, locator, assertion, adjudication, activity, rel, identifier, product) plus the tokens requested in
// W01-SR-01 (org-snapshot, cohort-participant). Snapshots of real pages hash the stored excerpt text
// (contentHashBasis STORED_EXCERPT_TEXT: NFC-WS1 over the TEXT_QUOTE exact strings of the snapshot joined by one space);
// synthetic sources use SYNTHETIC_FIXTURE. Status ACCEPTED means capture fidelity only (a CAPTURE_FIDELITY
// adjudication is attached), never truth. Executed on embedded Neo4j 5.26.31 Community (see 06-fixtures-and-queries.md).
// FIXTURE w01-05-facility-label-roles (SYNTHETIC): label 'Distributed by' versus manufacturer, label place of business
// versus manufacturing Facility (21 CFR 101.5(b),(c),(e)), brand owned by a legal entity (projected OWNS_BRAND),
// contract manufacturer operating a plant (CQ-MF-01). Every node and source here is synthetic.


// Shared lineage record for W01 manual curation
MERGE (n:Activity:Occurrence {uid: 'hu:activity:w01-curation-2026-10-04'})
SET n += {id: 'w01-curation-2026-10-04', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', occurrenceType: 'Activity', activityKind: 'EXTRACTION', methodVersion: 'w01-manual-curation-v0', startedAt: datetime('2026-10-04T00:52:00Z'), endedAt: datetime('2026-10-04T01:00:00Z')};
MERGE (n:LegalEntity:Organization:Entity {uid: 'hu:org:w01-synthetic-brand-owner-llc'})
SET n += {id: 'w01-synthetic-brand-owner-llc', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'LegalEntity', name: 'Synthetic Brand Owner LLC', legalName: 'Synthetic Brand Owner LLC', fixtureProvenance: 'SYNTHETIC'};
MERGE (n:LegalEntity:Organization:Entity {uid: 'hu:org:w01-synthetic-cmo-inc'})
SET n += {id: 'w01-synthetic-cmo-inc', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'LegalEntity', name: 'Synthetic Contract Manufacturing Inc.', legalName: 'Synthetic Contract Manufacturing Inc.', organizationType: 'CONTRACT_DEVELOPMENT_AND_MANUFACTURING_ORGANIZATION', fixtureProvenance: 'SYNTHETIC'};
MERGE (n:ConsumerBrand:Entity {uid: 'hu:brand:w01-synthetic-sleepwell'})
SET n += {id: 'w01-synthetic-sleepwell', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'ConsumerBrand', name: 'SleepWell (synthetic)', fixtureProvenance: 'SYNTHETIC'};
MERGE (n:Product:Entity {uid: 'hu:product:w01-synthetic-sleepwell-capsules'})
SET n += {id: 'w01-synthetic-sleepwell-capsules', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Product', name: 'SleepWell capsules (synthetic)', fixtureProvenance: 'SYNTHETIC'};
MERGE (n:Facility:Entity {uid: 'hu:facility:w01-synthetic-brand-owner-office'})
SET n += {id: 'w01-synthetic-brand-owner-office', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Facility', name: 'Synthetic Brand Owner office', facilityKind: 'CORPORATE_OFFICE', addressText: '100 Example Ave', city: 'Austin', region: 'TX', country: 'US', postalCode: '78701', fixtureProvenance: 'SYNTHETIC'};
MERGE (n:Facility:Entity {uid: 'hu:facility:w01-synthetic-cmo-plant'})
SET n += {id: 'w01-synthetic-cmo-plant', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Facility', name: 'Synthetic CMO capsule plant', facilityKind: 'MANUFACTURING_SITE', addressText: '1 Synthetic Way', city: 'Ogden', region: 'UT', country: 'US', fixtureProvenance: 'SYNTHETIC'};
MERGE (n:Source:Entity {uid: 'hu:source:w01-synthetic-sleepwell-label'})
SET n += {id: 'w01-synthetic-sleepwell-label', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Source', canonicalUri: 'urn:synthetic:w01:sleepwell-label', sourceKind: 'MANUFACTURER_LABEL_PAGE', title: 'Synthetic SleepWell label'};
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w01-synthetic-sleepwell-label'})
SET n += {id: 'w01-synthetic-sleepwell-label', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceSnapshot', retrievedAt: datetime('2026-10-04T00:59:00Z'), observedAt: datetime('2026-10-04T00:59:00Z'), captureCompleteness: 'COMPLETE', contentHashBasis: 'SYNTHETIC_FIXTURE', contentHash: 'sha256:f1474765b8c3ef4fc11f92ac88cc21ebb7fed86aa50391a880e7de88f1fb78a5', fixtureProvenance: 'SYNTHETIC'};
MATCH (s:Source {uid: 'hu:source:w01-synthetic-sleepwell-label'}), (sn:SourceSnapshot {uid: 'hu:snapshot:w01-synthetic-sleepwell-label'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:w01-synthetic-label-distributed-by'})
SET n += {id: 'w01-synthetic-label-distributed-by', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'Distributed by: Synthetic Brand Owner LLC, 100 Example Ave, Austin, TX 78701', quoteHash: 'sha256:231a75305d6a5b7d03e34df13e986e026505a6ed43a2feafa8eb947d17a24b77', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:w01-synthetic-sleepwell-label'}), (l:SourceLocator {uid: 'hu:locator:w01-synthetic-label-distributed-by'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:w01-synthetic-label-brand-mark'})
SET n += {id: 'w01-synthetic-label-brand-mark', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'SleepWell™ is a trademark of Synthetic Brand Owner LLC.', quoteHash: 'sha256:35502a52154488a93d5e9a9c62795e7f2580ebbc2f8cbdcc13195b014f6b9b27', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:w01-synthetic-sleepwell-label'}), (l:SourceLocator {uid: 'hu:locator:w01-synthetic-label-brand-mark'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:Source:Entity {uid: 'hu:source:w01-synthetic-cmo-site-page'})
SET n += {id: 'w01-synthetic-cmo-site-page', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Source', canonicalUri: 'urn:synthetic:w01:cmo-site', sourceKind: 'ORGANIZATION_WEBPAGE', title: 'Synthetic CMO facility page'};
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w01-synthetic-cmo-site-page'})
SET n += {id: 'w01-synthetic-cmo-site-page', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceSnapshot', retrievedAt: datetime('2026-10-04T00:59:00Z'), observedAt: datetime('2026-10-04T00:59:00Z'), captureCompleteness: 'COMPLETE', contentHashBasis: 'SYNTHETIC_FIXTURE', contentHash: 'sha256:3f2f7f0ba7082c1d5beb106adbdcef4fa5bc48d39eb8d15a6ba8ccb7806531f6', fixtureProvenance: 'SYNTHETIC'};
MATCH (s:Source {uid: 'hu:source:w01-synthetic-cmo-site-page'}), (sn:SourceSnapshot {uid: 'hu:snapshot:w01-synthetic-cmo-site-page'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:w01-synthetic-cmo-encapsulates-sleepwell'})
SET n += {id: 'w01-synthetic-cmo-encapsulates-sleepwell', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'At our Ogden, Utah plant we encapsulate SleepWell capsules for Synthetic Brand Owner LLC under contract since March 2024.', quoteHash: 'sha256:92e6bf37ea624c0427362b3f09ba5a4ed634243d3e8d041b62dd48c511e39f03', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:w01-synthetic-cmo-site-page'}), (l:SourceLocator {uid: 'hu:locator:w01-synthetic-cmo-encapsulates-sleepwell'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (a:Assertion {uid: 'hu:assertion:w01-synth-bo-distributes-sleepwell'})
SET a += {id: 'w01-synth-bo-distributes-sleepwell', predicate: 'DISTRIBUTES_PRODUCT', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'Distributed by', fixtureProvenance: 'SYNTHETIC', contentHash: 'sha256:fca50a160b8034947f7edc95d85eafe2f6c647e9fd88d825d1224e5a8a14eaf2'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-synth-bo-distributes-sleepwell'}), (s {uid: 'hu:org:w01-synthetic-brand-owner-llc'}), (o {uid: 'hu:product:w01-synthetic-sleepwell-capsules'}), (w {uid: 'hu:org:w01-synthetic-brand-owner-llc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:w01-synthetic-label-distributed-by'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w01-synth-bo-distributes-sleepwell-capture'})
SET n += {id: 'w01-synth-bo-distributes-sleepwell-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:w01-synth-bo-distributes-sleepwell-capture'}), (a:Assertion {uid: 'hu:assertion:w01-synth-bo-distributes-sleepwell'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:Organization {uid: 'hu:org:w01-synthetic-brand-owner-llc'}), (y:Product {uid: 'hu:product:w01-synthetic-sleepwell-capsules'})
MERGE (x)-[r:DISTRIBUTES_PRODUCT {relationshipUid: 'hu:rel:w01-synth-bo-distributes-sleepwell'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-synth-bo-distributes-sleepwell', assertionUid: 'hu:assertion:w01-synth-bo-distributes-sleepwell', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), roleType: 'DISTRIBUTOR', roleTitleVerbatim: 'Distributed by'};
MERGE (a:Assertion {uid: 'hu:assertion:w01-synth-bo-owns-sleepwell-brand'})
SET a += {id: 'w01-synth-bo-owns-sleepwell-brand', predicate: 'OWNS_BRAND', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'is a trademark of', fixtureProvenance: 'SYNTHETIC', contentHash: 'sha256:bdf556e47c47caf789cde812c1d592b6818abdc220dae5b99f030d0a3a040573'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-synth-bo-owns-sleepwell-brand'}), (s {uid: 'hu:org:w01-synthetic-brand-owner-llc'}), (o {uid: 'hu:brand:w01-synthetic-sleepwell'}), (w {uid: 'hu:org:w01-synthetic-brand-owner-llc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:w01-synthetic-label-brand-mark'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w01-synth-bo-owns-sleepwell-brand-capture'})
SET n += {id: 'w01-synth-bo-owns-sleepwell-brand-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:w01-synth-bo-owns-sleepwell-brand-capture'}), (a:Assertion {uid: 'hu:assertion:w01-synth-bo-owns-sleepwell-brand'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:Organization {uid: 'hu:org:w01-synthetic-brand-owner-llc'}), (y:ConsumerBrand {uid: 'hu:brand:w01-synthetic-sleepwell'})
MERGE (x)-[r:OWNS_BRAND {relationshipUid: 'hu:rel:w01-synth-bo-owns-sleepwell-brand'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-synth-bo-owns-sleepwell-brand', assertionUid: 'hu:assertion:w01-synth-bo-owns-sleepwell-brand', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z')};
MERGE (a:Assertion {uid: 'hu:assertion:w01-synth-bo-place-of-business'})
SET a += {id: 'w01-synth-bo-place-of-business', predicate: 'OPERATES_FACILITY', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'label place of business', fixtureProvenance: 'SYNTHETIC', contentHash: 'sha256:477bc0a481ff501f69d3b077c660f06bc66cf083fb3623e29f21e9d538bf226e'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-synth-bo-place-of-business'}), (s {uid: 'hu:org:w01-synthetic-brand-owner-llc'}), (o {uid: 'hu:facility:w01-synthetic-brand-owner-office'}), (w {uid: 'hu:org:w01-synthetic-brand-owner-llc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:w01-synthetic-label-distributed-by'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w01-synth-bo-place-of-business-capture'})
SET n += {id: 'w01-synth-bo-place-of-business-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:w01-synth-bo-place-of-business-capture'}), (a:Assertion {uid: 'hu:assertion:w01-synth-bo-place-of-business'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:Organization {uid: 'hu:org:w01-synthetic-brand-owner-llc'}), (y:Facility {uid: 'hu:facility:w01-synthetic-brand-owner-office'})
MERGE (x)-[r:OPERATES_FACILITY {relationshipUid: 'hu:rel:w01-synth-bo-operates-office'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-synth-bo-operates-office', assertionUid: 'hu:assertion:w01-synth-bo-place-of-business', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'label place of business'};
MERGE (a:Assertion {uid: 'hu:assertion:w01-synth-cmo-manufactures-sleepwell'})
SET a += {id: 'w01-synth-cmo-manufactures-sleepwell', predicate: 'MANUFACTURES_PRODUCT', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFrom: datetime('2024-03-01T00:00:00Z'), validFromPrecision: 'MONTH', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'we encapsulate', fixtureProvenance: 'SYNTHETIC', contentHash: 'sha256:4cd4545211caef752f441b85f9a1db5624f72755c5ce5ad8a76bf88d75d65f70'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-synth-cmo-manufactures-sleepwell'}), (s {uid: 'hu:org:w01-synthetic-cmo-inc'}), (o {uid: 'hu:product:w01-synthetic-sleepwell-capsules'}), (w {uid: 'hu:org:w01-synthetic-cmo-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:w01-synthetic-cmo-encapsulates-sleepwell'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w01-synth-cmo-manufactures-sleepwell-capture'})
SET n += {id: 'w01-synth-cmo-manufactures-sleepwell-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:w01-synth-cmo-manufactures-sleepwell-capture'}), (a:Assertion {uid: 'hu:assertion:w01-synth-cmo-manufactures-sleepwell'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:Organization {uid: 'hu:org:w01-synthetic-cmo-inc'}), (y:Product {uid: 'hu:product:w01-synthetic-sleepwell-capsules'})
MERGE (x)-[r:MANUFACTURES_PRODUCT {relationshipUid: 'hu:rel:w01-synth-cmo-manufactures-sleepwell'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-synth-cmo-manufactures-sleepwell', assertionUid: 'hu:assertion:w01-synth-cmo-manufactures-sleepwell', validFrom: datetime('2024-03-01T00:00:00Z'), validFromPrecision: 'MONTH', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), roleType: 'MANUFACTURER', roleTitleVerbatim: 'we encapsulate'};
MERGE (a:Assertion {uid: 'hu:assertion:w01-synth-cmo-contract-manufactures-for-bo'})
SET a += {id: 'w01-synth-cmo-contract-manufactures-for-bo', predicate: 'CONTRACT_MANUFACTURES_FOR', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFrom: datetime('2024-03-01T00:00:00Z'), validFromPrecision: 'MONTH', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'under contract', fixtureProvenance: 'SYNTHETIC', contentHash: 'sha256:e24346ec0d26ed55af01b1a4a9daa64b4ff7d2dff662381a314e9077e2cc10fb'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-synth-cmo-contract-manufactures-for-bo'}), (s {uid: 'hu:org:w01-synthetic-cmo-inc'}), (o {uid: 'hu:org:w01-synthetic-brand-owner-llc'}), (w {uid: 'hu:org:w01-synthetic-cmo-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:w01-synthetic-cmo-encapsulates-sleepwell'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w01-synth-cmo-contract-manufactures-for-bo-capture'})
SET n += {id: 'w01-synth-cmo-contract-manufactures-for-bo-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:w01-synth-cmo-contract-manufactures-for-bo-capture'}), (a:Assertion {uid: 'hu:assertion:w01-synth-cmo-contract-manufactures-for-bo'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:Organization {uid: 'hu:org:w01-synthetic-cmo-inc'}), (y:Organization {uid: 'hu:org:w01-synthetic-brand-owner-llc'})
MERGE (x)-[r:CONTRACT_MANUFACTURES_FOR {relationshipUid: 'hu:rel:w01-synth-cmo-for-bo'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-synth-cmo-for-bo', assertionUid: 'hu:assertion:w01-synth-cmo-contract-manufactures-for-bo', validFrom: datetime('2024-03-01T00:00:00Z'), validFromPrecision: 'MONTH', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'under contract'};
MERGE (a:Assertion {uid: 'hu:assertion:w01-synth-cmo-operates-ogden-plant'})
SET a += {id: 'w01-synth-cmo-operates-ogden-plant', predicate: 'OPERATES_FACILITY', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'our Ogden, Utah plant', fixtureProvenance: 'SYNTHETIC', contentHash: 'sha256:aa31a9ffed01e1467a44d87911bee66d0d6b42e3eba010ce3af70bd930f0f321'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-synth-cmo-operates-ogden-plant'}), (s {uid: 'hu:org:w01-synthetic-cmo-inc'}), (o {uid: 'hu:facility:w01-synthetic-cmo-plant'}), (w {uid: 'hu:org:w01-synthetic-cmo-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:w01-synthetic-cmo-encapsulates-sleepwell'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w01-synth-cmo-operates-ogden-plant-capture'})
SET n += {id: 'w01-synth-cmo-operates-ogden-plant-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:w01-synth-cmo-operates-ogden-plant-capture'}), (a:Assertion {uid: 'hu:assertion:w01-synth-cmo-operates-ogden-plant'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:Organization {uid: 'hu:org:w01-synthetic-cmo-inc'}), (y:Facility {uid: 'hu:facility:w01-synthetic-cmo-plant'})
MERGE (x)-[r:OPERATES_FACILITY {relationshipUid: 'hu:rel:w01-synth-cmo-operates-plant'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-synth-cmo-operates-plant', assertionUid: 'hu:assertion:w01-synth-cmo-operates-ogden-plant', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), facilityRole: 'MANUFACTURING_SITE', roleTitleVerbatim: 'our Ogden, Utah plant'};
