// Run run-2026-10-04-fable51-01, worker W01 (Opus 5.5). Generated 2026-10-04 by the W01 fixture generator (scratchpad).
// Rules: statements separated by ';'; every statement binds its own nodes by uid (no variable crosses ';');
// nodes carry the primary label and the archetype label; uids use registered tokens (org, person, brand, facility,
// source, snapshot, locator, assertion, adjudication, activity, rel, identifier, product) plus the tokens requested in
// W01-SR-01 (org-snapshot, cohort-participant). Snapshots of real pages hash the stored excerpt text
// (contentHashBasis STORED_EXCERPT_TEXT: NFC-WS1 over the TEXT_QUOTE exact strings of the snapshot joined by one space);
// synthetic sources use SYNTHETIC_FIXTURE. Status ACCEPTED means capture fidelity only (a CAPTURE_FIDELITY
// adjudication is attached), never truth. Executed on embedded Neo4j 5.26.31 Community (see 06-fixtures-and-queries.md).
// FIXTURE w01-02-advises-not-endorses: an ADVISES_ORGANIZATION assertion and edge with NO ENDORSES_PRODUCT edge
// (forbidden implication [ADVISES_ORGANIZATION, ENDORSES_PRODUCT]; V-007, V-112, V-422), the investor-versus-equity
// code split (I without E), a brand juxtaposition kept PROPOSED, and the minimal-pair positive: a SYNTHETIC explicit
// endorsement assertion that does project ENDORSES_PRODUCT. Load after w01-01 (reuses its sources).


// Shared lineage record for W01 manual curation
MERGE (n:Activity:Occurrence {uid: 'hu:activity:w01-curation-2026-10-04'})
SET n += {id: 'w01-curation-2026-10-04', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', occurrenceType: 'Activity', activityKind: 'EXTRACTION', methodVersion: 'w01-manual-curation-v0', startedAt: datetime('2026-10-04T00:52:00Z'), endedAt: datetime('2026-10-04T01:00:00Z')};
MERGE (n:LegalEntity:Organization:Entity {uid: 'hu:org:segterra'})
SET n += {id: 'segterra', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'LegalEntity', name: 'Segterra'};
MERGE (n:Person:Entity {uid: 'hu:person:david-a-sinclair'})
SET n += {id: 'david-a-sinclair', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Person', name: 'David A. Sinclair'};
MERGE (n:ConsumerBrand:Entity {uid: 'hu:brand:insidetracker'})
SET n += {id: 'insidetracker', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'ConsumerBrand', name: 'InsideTracker'};
MERGE (n:Source:Entity {uid: 'hu:source:sinclair-lab-affiliations'})
SET n += {id: 'sinclair-lab-affiliations', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Source', canonicalUri: 'https://sinclair.hms.harvard.edu/david-sinclairs-affiliations', sourceKind: 'SELF_DISCLOSURE_PAGE', title: 'David A. Sinclair\'s Affiliations (The Sinclair Lab)'};
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w01-sinclair-affiliations-2026-10-03-replica'})
SET n += {id: 'w01-sinclair-affiliations-2026-10-03-replica', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceSnapshot', retrievedAt: datetime('2026-10-03T11:00:00Z'), observedAt: datetime('2026-10-03T11:00:00Z'), captureCompleteness: 'PARTIAL_EXCERPT', contentHashBasis: 'STORED_EXCERPT_TEXT', contentHash: 'sha256:3c83cc11e3b775b5e923f377634cfb41f319b868973792d7feee4f13d7a8aec7'};
MATCH (s:Source {uid: 'hu:source:sinclair-lab-affiliations'}), (sn:SourceSnapshot {uid: 'hu:snapshot:w01-sinclair-affiliations-2026-10-03-replica'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w01-sinclair-affiliations-2026-10-04'})
SET n += {id: 'w01-sinclair-affiliations-2026-10-04', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceSnapshot', retrievedAt: datetime('2026-10-04T00:58:00Z'), observedAt: datetime('2026-10-04T00:58:00Z'), captureCompleteness: 'PARTIAL_EXCERPT', contentHashBasis: 'STORED_EXCERPT_TEXT', contentHash: 'sha256:3c83cc11e3b775b5e923f377634cfb41f319b868973792d7feee4f13d7a8aec7'};
MATCH (s:Source {uid: 'hu:source:sinclair-lab-affiliations'}), (sn:SourceSnapshot {uid: 'hu:snapshot:w01-sinclair-affiliations-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:sinclair-affiliations-2026-10-03-insidetracker-line'})
SET n += {id: 'sinclair-affiliations-2026-10-03-insidetracker-line', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'InsideTracker (Segterra), Cambridge, MA B (2011-2017) I,A,IP (2011-present)', quoteHash: 'sha256:1994dc81bbae7b429ed8275104570117247c25516901dff418f3deb679102ecd', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:w01-sinclair-affiliations-2026-10-03-replica'}), (l:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-03-insidetracker-line'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:sinclair-affiliations-2026-10-04-insidetracker-line'})
SET n += {id: 'sinclair-affiliations-2026-10-04-insidetracker-line', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'InsideTracker (Segterra), Cambridge, MA B (2011-2017) I,A,IP (2011-present)', quoteHash: 'sha256:1994dc81bbae7b429ed8275104570117247c25516901dff418f3deb679102ecd', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:w01-sinclair-affiliations-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-04-insidetracker-line'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:sinclair-affiliations-2026-10-04-legend'})
SET n += {id: 'sinclair-affiliations-2026-10-04-legend', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'F=Founder; I=Investor; E=Equity; A=Advisor/Consultant; B=Board of Directors; IP=Inventor on licensed patents; L=Funding for laboratory', quoteHash: 'sha256:e95a85b7bed49bb35677e657d428478a4a694f4153ac6285d8d497e7c759609d', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:w01-sinclair-affiliations-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-04-legend'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MATCH (n:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-04-insidetracker-line'}), (o:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-03-insidetracker-line'})
MERGE (n)-[r:REANCHORS]->(o)
SET r.anchorMatch = 'EXACT', r.activityUid = 'hu:activity:w01-curation-2026-10-04';

// Code A (2011-present): advisor/consultant. Object resolved to the company (Segterra), never to the brand: a brand has no advisors.
MERGE (a:Assertion {uid: 'hu:assertion:w01-sinclair-advises-segterra-2011-open'})
SET a += {id: 'w01-sinclair-advises-segterra-2011-open', predicate: 'ADVISES_ORGANIZATION', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'PERSONAL_EXPERIENCE', validFrom: datetime('2011-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'A', statedTense: 'PRESENT', contentHash: 'sha256:c83ab3e71993f28edc06f47ed057e8b5c3d4fc75a0a2ce664bbef27df6626204'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-sinclair-advises-segterra-2011-open'}), (s {uid: 'hu:person:david-a-sinclair'}), (o {uid: 'hu:org:segterra'}), (w {uid: 'hu:person:david-a-sinclair'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-04-insidetracker-line'}), (l1:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-04-legend'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0)
MERGE (a)-[:SUPPORTED_BY]->(l1);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w01-sinclair-advises-segterra-2011-open-capture'})
SET n += {id: 'w01-sinclair-advises-segterra-2011-open-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:w01-sinclair-advises-segterra-2011-open-capture'}), (a:Assertion {uid: 'hu:assertion:w01-sinclair-advises-segterra-2011-open'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:Person {uid: 'hu:person:david-a-sinclair'}), (y:Organization {uid: 'hu:org:segterra'})
MERGE (x)-[r:ADVISES_ORGANIZATION {relationshipUid: 'hu:rel:w01-sinclair-advises-segterra'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-sinclair-advises-segterra', assertionUid: 'hu:assertion:w01-sinclair-advises-segterra-2011-open', validFrom: datetime('2011-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), roleType: 'ADVISOR', seniorityLevel: 'ADVISOR', roleTitleVerbatim: 'A'};

// Code I without E: INVESTED_IN only; no HOLDS_EQUITY_IN is written (forbidden implication [INVESTED_IN, HOLDS_EQUITY_IN])
MERGE (a:Assertion {uid: 'hu:assertion:w01-sinclair-invested-in-segterra-2011-open'})
SET a += {id: 'w01-sinclair-invested-in-segterra-2011-open', predicate: 'INVESTED_IN', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'PERSONAL_EXPERIENCE', validFrom: datetime('2011-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'I', statedTense: 'PRESENT', contentHash: 'sha256:8b4f83c5468afcc099ca6e6728a24d6726762b5a9a28205e6071baa519ff5b44'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-sinclair-invested-in-segterra-2011-open'}), (s {uid: 'hu:person:david-a-sinclair'}), (o {uid: 'hu:org:segterra'}), (w {uid: 'hu:person:david-a-sinclair'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-04-insidetracker-line'}), (l1:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-04-legend'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0)
MERGE (a)-[:SUPPORTED_BY]->(l1);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w01-sinclair-invested-in-segterra-2011-open-capture'})
SET n += {id: 'w01-sinclair-invested-in-segterra-2011-open-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:w01-sinclair-invested-in-segterra-2011-open-capture'}), (a:Assertion {uid: 'hu:assertion:w01-sinclair-invested-in-segterra-2011-open'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:Person {uid: 'hu:person:david-a-sinclair'}), (y:Organization {uid: 'hu:org:segterra'})
MERGE (x)-[r:INVESTED_IN {relationshipUid: 'hu:rel:w01-sinclair-invested-segterra'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-sinclair-invested-segterra', assertionUid: 'hu:assertion:w01-sinclair-invested-in-segterra-2011-open', validFrom: datetime('2011-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'I'};

// "InsideTracker (Segterra)" only juxtaposes a brand and a legal name: OWNS_BRAND stays PROPOSED and is NOT projected
MERGE (a:Assertion {uid: 'hu:assertion:w01-segterra-owns-insidetracker-brand-proposed'})
SET a += {id: 'w01-segterra-owns-insidetracker-brand-proposed', predicate: 'OWNS_BRAND', status: 'PROPOSED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'InsideTracker (Segterra)', contentHash: 'sha256:2ebcc0ad1cae12fd06bbd64a4bf289be40c67b4a582dec30238b03dd841cdd58'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-segterra-owns-insidetracker-brand-proposed'}), (s {uid: 'hu:org:segterra'}), (o {uid: 'hu:brand:insidetracker'}), (w {uid: 'hu:person:david-a-sinclair'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-04-insidetracker-line'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);

// Minimal-pair positive (SYNTHETIC): an explicit endorsement statement by a synthetic person projects ENDORSES_PRODUCT
MERGE (n:Person:Entity {uid: 'hu:person:w01-synthetic-endorser'})
SET n += {id: 'w01-synthetic-endorser', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Person', name: 'Synthetic Endorser (fixture only)', fixtureProvenance: 'SYNTHETIC'};
MERGE (n:Product:Entity {uid: 'hu:product:w01-synthetic-blood-test-plan'})
SET n += {id: 'w01-synthetic-blood-test-plan', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Product', name: 'Synthetic blood-testing plan (fixture only)', fixtureProvenance: 'SYNTHETIC'};
MERGE (n:Source:Entity {uid: 'hu:source:w01-synthetic-testimonial-page'})
SET n += {id: 'w01-synthetic-testimonial-page', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Source', canonicalUri: 'urn:synthetic:w01:testimonial-page', sourceKind: 'MARKETING_PAGE', title: 'Synthetic testimonial page (fixture)'};
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w01-synthetic-testimonial-page'})
SET n += {id: 'w01-synthetic-testimonial-page', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceSnapshot', retrievedAt: datetime('2026-10-04T00:59:00Z'), observedAt: datetime('2026-10-04T00:59:00Z'), captureCompleteness: 'COMPLETE', contentHashBasis: 'SYNTHETIC_FIXTURE', contentHash: 'sha256:31fdb267cd210f3749fc52ec080c1fa143b1555d526e7621acbf35466033828e', fixtureProvenance: 'SYNTHETIC'};
MATCH (s:Source {uid: 'hu:source:w01-synthetic-testimonial-page'}), (sn:SourceSnapshot {uid: 'hu:snapshot:w01-synthetic-testimonial-page'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:w01-synthetic-testimonial-quote'})
SET n += {id: 'w01-synthetic-testimonial-quote', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'I personally use and recommend the Synthetic blood-testing plan.', quoteHash: 'sha256:4c7cef6f599a10bc33433c627a478270375bc7a84a7b54787312fd80cc686914', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:w01-synthetic-testimonial-page'}), (l:SourceLocator {uid: 'hu:locator:w01-synthetic-testimonial-quote'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (a:Assertion {uid: 'hu:assertion:w01-synthetic-endorser-endorses-plan'})
SET a += {id: 'w01-synthetic-endorser-endorses-plan', predicate: 'ENDORSES_PRODUCT', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'RECOMMENDS', assertionBasis: 'PERSONAL_EXPERIENCE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), fixtureProvenance: 'SYNTHETIC', contentHash: 'sha256:88e08e93d3f52afab4033d6efa9357fcdac0c7daabc0b9cfdae7f52b04799a5d'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-synthetic-endorser-endorses-plan'}), (s {uid: 'hu:person:w01-synthetic-endorser'}), (o {uid: 'hu:product:w01-synthetic-blood-test-plan'}), (w {uid: 'hu:person:w01-synthetic-endorser'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:w01-synthetic-testimonial-quote'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w01-synthetic-endorser-endorses-plan-capture'})
SET n += {id: 'w01-synthetic-endorser-endorses-plan-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:w01-synthetic-endorser-endorses-plan-capture'}), (a:Assertion {uid: 'hu:assertion:w01-synthetic-endorser-endorses-plan'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:Person {uid: 'hu:person:w01-synthetic-endorser'}), (y:Product {uid: 'hu:product:w01-synthetic-blood-test-plan'})
MERGE (x)-[r:ENDORSES_PRODUCT {relationshipUid: 'hu:rel:w01-synthetic-endorser-endorses-plan'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-synthetic-endorser-endorses-plan', assertionUid: 'hu:assertion:w01-synthetic-endorser-endorses-plan', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z')};
