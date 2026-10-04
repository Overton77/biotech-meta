// W11 fixture 04 -- a cGMP claim that must not read as certification, inspection or registration (CQ-MF-06).
// Run: run-2026-10-04-fable51-01, W11. NEW_RETRIEVAL 2026-10-04 (../03-source-manifest.md W11-S11..S14).
// Four different records, four different representations:
//   1. Company page (nai-online.com Certifications & Associations): "NAI maintains current Good Manufacturing Practices
//      (cGMP) as established by the United States Food and Drug Administration." -> Assertion CLAIMS_CGMP_COMPLIANCE,
//      asserted by NAI, organization-level, no facility, no period, no auditor. The same page says the company holds
//      certifications "including the Good Manufacturing Practices (GMP) standard set forth by the US Food and Drug
//      Administration": FDA issues no GMP certificate for dietary supplements -> SUPPORT adjudication INSUFFICIENT.
//   2. Issuer filing (FY2025 10-K): the Carlsbad facility "is now also third-party GMP certified through the
//      above-mentioned NSF and NSF for Sport programs as of November 2024" -> still the company's statement about a
//      certification (facility-scoped, dated); NOT a CertificationListing (that needs the certifier's listing, not captured).
//      Predicate CLAIMS_THIRD_PARTY_CERTIFICATION is a W11 candidate (W11-SR-09); status PROPOSED until registered.
//   3. FDA registration record (public 503B outsourcing-facility list, updated 9/30/2026): "Navinta III Inc., Boca Raton,
//      FL | 2/6/2026 | 2/6/2026 | Not yet inspected" -> RegulatoryStatus{ESTABLISHMENT_REGISTRATION} STATUS_OF the Facility
//      (W13 types). FDA's own Q&A: registration "does not mean it is in compliance with ... (CGMP) requirements".
//      Food (dietary supplement) facility registrations are NOT public (21 CFR 1.243(a)); for NAI no agency registration
//      record can be retrieved, so no registration status is created for NAI (unknown, not absent).
//   4. Inspection: no inspection record captured for either firm. "Not yet inspected" is preserved verbatim on a
//      locator; the inspection Occurrence type is W13's candidate RegulatoryInspection (W11-SR-10).
// Queries in ../06-fixtures-and-queries.md (Q-MF06-a..d) must return the claim only as a claim.

// status: run
UNWIND [
  {s: 'hu:source:nai-online-certifications', uri: 'https://www.nai-online.com/our-approaches/certifications-associations', title: 'Certifications & Associations - Natural Alternatives International', kind: 'MARKETING_PAGE', ch: 'sha256:c5a7384920f7ed6da67c43bc85a5619a993274d9596ed29958897d31c46cb48c', cc: 'COMPLETE'},
  {s: 'hu:source:sec-naii-10k-fy2025', uri: 'https://www.sec.gov/Archives/edgar/data/787253/000143774925029731/naii20250630_10k.htm', title: 'Natural Alternatives International, Inc. Form 10-K for fiscal year ended 2025-06-30', kind: 'SECURITIES_FILING', ch: 'sha256:5aa19c8d3eeb83941770da8662c7e8a7f13f11ceeba9c431a37475df722514e9', cc: 'PARTIAL_EXCERPT'},
  {s: 'hu:source:fda-registered-outsourcing-facilities', uri: 'https://www.fda.gov/drugs/human-drug-compounding/registered-outsourcing-facilities', title: 'FDA: Registered Outsourcing Facilities (updated as of 9/30/2026)', kind: 'REGULATORY_RECORD', ch: 'sha256:2d8d66cb953fc1fd1eeee448897a35bc618452fc79b4c3f3ecd834bc47eab25d', cc: 'PARTIAL_EXCERPT'},
  {s: 'hu:source:fda-qa-outsourcing-facility-registration', uri: 'https://www.fda.gov/drugs/human-drug-compounding/questions-and-answers-outsourcing-facility-registration', title: 'FDA: Questions and Answers: Outsourcing Facility Registration', kind: 'REGULATORY_GUIDANCE', ch: 'sha256:6f9f0dcf74f4c03b5631efcd33801058d33fe62a22ece1af79f9468d87bb90e8', cc: 'PARTIAL_EXCERPT'}
] AS row
MERGE (s:Source:Entity {uid: row.s})
SET s.privacyClass = coalesce(s.privacyClass, 'PUBLIC'), s.canonicalUri = row.uri, s.title = row.title, s.sourceKind = row.kind, s.entityType = 'SOURCE', s.createdAt = datetime('2026-10-04T01:05:00Z')
MERGE (sn:SourceSnapshot:InformationArtifact {uid: replace(row.s, 'hu:source:', 'hu:snapshot:') + '-2026-10-04'})
SET sn.privacyClass = coalesce(sn.privacyClass, 'PUBLIC'), sn.artifactType = 'SOURCE_SNAPSHOT', sn.canonicalUri = row.uri, sn.retrievedAt = datetime('2026-10-04T00:58:00Z'),
    sn.observedAt = datetime('2026-10-04T00:58:00Z'), sn.contentHash = row.ch, sn.contentHashBasis = 'SYNTHETIC_FIXTURE',
    sn.captureCompleteness = row.cc, sn.createdAt = datetime('2026-10-04T01:05:00Z')
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

// status: run
UNWIND [
  {l: 'hu:locator:nai-online-cgmp-maintains', sn: 'hu:snapshot:nai-online-certifications-2026-10-04',
   exact: 'NAI maintains current Good Manufacturing Practices (cGMP) as established by the United States Food and Drug Administration.',
   qh: 'sha256:5a31732dd511bccfc25f076fa71c7b648d0d24457e33a3a3ee080899479ed126'},
  {l: 'hu:locator:nai-online-certifications-fda-gmp', sn: 'hu:snapshot:nai-online-certifications-2026-10-04',
   exact: 'we hold an extensive list of certifications from standard-bearing governing bodies in the industry, including the Good Manufacturing Practices (GMP) standard set forth by the US Food and Drug Administration.',
   qh: 'sha256:592e488299cf0a848d3adf72ebbe309a2262520156fa3d499e3604346e7ea614'},
  {l: 'hu:locator:naii-10k-fy2025-carlsbad-nsf-gmp-nov-2024', sn: 'hu:snapshot:sec-naii-10k-fy2025-2026-10-04',
   exact: 'This facility is now also third-party GMP certified through the above-mentioned NSF and NSF for Sport programs as of November 2024 and the SSCI program as of April 2025.',
   qh: 'sha256:c3dcb349b2de6d9fb3034773977366c80bc89da316e88a86bdc499a55e40bbb1'},
  {l: 'hu:locator:fda-503b-list-navinta-iii-row', sn: 'hu:snapshot:fda-registered-outsourcing-facilities-2026-10-04',
   exact: 'Navinta III Inc., Boca Raton, FL | Mahendra Patel 1-561-997-6595 | 2/6/2026 | 2/6/2026 | Not yet inspected | N/A | N/A | N/A | Yes',
   qh: 'sha256:669ff276a2599ff925a80d62317996817c9150a639787279a5c5dcc164111b16'},
  {l: 'hu:locator:fda-qa-503b-registration-not-cgmp', sn: 'hu:snapshot:fda-qa-outsourcing-facility-registration-2026-10-04',
   exact: 'Registration means only that FDA has received the information required to register the facility.',
   qh: 'sha256:ee5aaff509e1fdaef1b7ec15b93004cd0ce52f946a8344529d1adb66294d9e4d'}
] AS row
MATCH (sn:SourceSnapshot {uid: row.sn})
MERGE (l:SourceLocator:InformationArtifact {uid: row.l})
SET l.privacyClass = coalesce(l.privacyClass, 'PUBLIC'), l.artifactType = 'SOURCE_LOCATOR', l.selectorKind = 'TEXT_QUOTE', l.exact = row.exact, l.quoteHash = row.qh,
    l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T01:05:00Z')
MERGE (sn)-[:HAS_LOCATOR]->(l);

// status: run
MERGE (o:Organization:LegalEntity:Entity {uid: 'hu:org:natural-alternatives-international-inc'})
ON CREATE SET o.privacyClass = coalesce(o.privacyClass, 'PUBLIC'), o.name = 'Natural Alternatives International', o.createdAt = datetime('2026-10-04T01:05:00Z')
SET o.entityType = 'ORGANIZATION';

// status: run
MERGE (f:Facility:Entity {uid: 'hu:facility:nai-carlsbad-powder-facility'})
ON CREATE SET f.privacyClass = coalesce(f.privacyClass, 'PUBLIC'), f.name = 'NAI Carlsbad, CA powder filling, packaging, distribution and storage facility', f.createdAt = datetime('2026-10-04T01:05:00Z')
SET f.entityType = 'FACILITY';

// status: run
UNWIND [
  ['hu:org:navinta-iii-inc', 'Navinta III Inc.', 'Organization'],
  ['hu:org:us-fda', 'U.S. Food and Drug Administration', 'RegulatoryAgency']
] AS p
MERGE (o:Organization:Entity {uid: p[0]})
ON CREATE SET o.privacyClass = coalesce(o.privacyClass, 'PUBLIC'), o.name = p[1], o.createdAt = datetime('2026-10-04T01:05:00Z')
SET o.entityType = 'ORGANIZATION'
FOREACH (_ IN CASE WHEN p[2] = 'RegulatoryAgency' THEN [1] ELSE [] END | SET o:RegulatoryAgency);

// status: run
MERGE (f:Facility:Entity {uid: 'hu:facility:navinta-iii-boca-raton-503b'})
SET f.privacyClass = coalesce(f.privacyClass, 'PUBLIC'), f.name = 'Navinta III Inc., Boca Raton, FL (503B outsourcing facility)', f.entityType = 'FACILITY', f.city = 'Boca Raton',
    f.region = 'FL', f.country = 'US', f.createdAt = datetime('2026-10-04T01:05:00Z');

// 1. The cGMP claim: literal-valued assertion (subject the organization; no object), predicate registered in catalog
//    organizations.assertedPredicates. It projects to NO edge and NO status.
// status: run
UNWIND [
  {a: 'hu:assertion:nai-online-claims-cgmp', ch: 'sha256:73c7e1d43e176666b1bb8458faffbc710feb8efed25c55a18db9b759a755b9a0', l: 'hu:locator:nai-online-cgmp-maintains',
   v: 'NAI maintains current Good Manufacturing Practices (cGMP) as established by the United States Food and Drug Administration.'},
  {a: 'hu:assertion:nai-online-claims-fda-gmp-certification', ch: 'sha256:7a8396ea20cb3cd6023788a72565431730f061045aff4657173aa13e22bdb0fd', l: 'hu:locator:nai-online-certifications-fda-gmp',
   v: 'certifications ... including the Good Manufacturing Practices (GMP) standard set forth by the US Food and Drug Administration'}
] AS row
MATCH (o:Organization {uid: 'hu:org:natural-alternatives-international-inc'}), (l:SourceLocator {uid: row.l})
MERGE (a:Assertion {uid: row.a})
SET a.privacyClass = coalesce(a.privacyClass, 'PUBLIC'), a.predicate = 'CLAIMS_CGMP_COMPLIANCE', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T01:10:00Z'),
    a.valueString = row.v, a.jurisdiction = 'US', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN',
    a.polarity = 'POSITIVE', a.speechAct = 'STATES', a.assertionBasis = 'MANUFACTURER_CLAIM', a.predicateClass = 'CLAIM',
    a.contentHash = row.ch, a.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (a)-[:HAS_SUBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l);

// SUPPORT adjudication on the "FDA GMP certification" wording: INSUFFICIENT (FDA registration does not denote CGMP
// compliance and no FDA certificate exists for this; the claim is neither confirmed nor refuted by an inspection record).
// status: run
MATCH (a:Assertion {uid: 'hu:assertion:nai-online-claims-fda-gmp-certification'}), (l:SourceLocator {uid: 'hu:locator:fda-qa-503b-registration-not-cgmp'})
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:nai-fda-gmp-certification-wording-2026-10-04'})
SET j.privacyClass = coalesce(j.privacyClass, 'PUBLIC'), j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'SUPPORT', j.verdict = 'INSUFFICIENT', j.reviewerType = 'AGENT',
    j.methodVersion = 'w11-cgmp-adjudication-v0', j.status = 'ACCEPTED', j.reviewedAt = datetime('2026-10-04T01:30:00Z'),
    j.recordedAt = datetime('2026-10-04T01:30:00Z'),
    j.rationale = 'No FDA record of a GMP certification exists to cite; FDA registration language states registration is not a CGMP determination; no inspection record captured. The claim stays a company claim.',
    j.createdAt = datetime('2026-10-04T01:30:00Z')
MERGE (j)-[:EVALUATES]->(a)
MERGE (j)-[:SUPPORTED_BY]->(l);

// 2. Facility-scoped, dated certification statement in an issuer filing (candidate predicate; PROPOSED).
// status: run
MATCH (f:Facility {uid: 'hu:facility:nai-carlsbad-powder-facility'}), (o:Organization {uid: 'hu:org:natural-alternatives-international-inc'}),
      (l:SourceLocator {uid: 'hu:locator:naii-10k-fy2025-carlsbad-nsf-gmp-nov-2024'})
MERGE (a:Assertion {uid: 'hu:assertion:naii-10k-fy2025-carlsbad-nsf-gmp-certified'})
SET a.privacyClass = coalesce(a.privacyClass, 'PUBLIC'), a.predicate = 'CLAIMS_THIRD_PARTY_CERTIFICATION', a.status = 'PROPOSED', a.recordedAt = datetime('2026-10-04T01:10:00Z'),
    a.valueString = 'third-party GMP certified through the NSF and NSF for Sport programs', a.validFrom = datetime('2024-11-01T00:00:00Z'),
    a.validFromPrecision = 'MONTH', a.validFromBasis = 'STATED_BY_SOURCE', a.validToBasis = 'UNKNOWN', a.polarity = 'POSITIVE',
    a.speechAct = 'STATES', a.assertionBasis = 'MANUFACTURER_CLAIM', a.predicateClass = 'CLAIM',
    a.contentHash = 'sha256:7379205595e3ad1b19d6dfa84b8c53a3915a940276578f277383e29699a83573', a.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (a)-[:HAS_SUBJECT]->(f)
MERGE (a)-[:ASSERTED_BY]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l);

// 3. Public agency registration record -> registration status of the Facility only (W13 shapes).
// status: run
MERGE (st:RegulatoryStatus:VersionedState {uid: 'hu:regulatory-status:navinta-iii-503b-registration-2026'})
SET st.privacyClass = coalesce(st.privacyClass, 'PUBLIC'), st.stateType = 'REGULATORY_STATUS', st.statusKind = 'ESTABLISHMENT_REGISTRATION', st.jurisdiction = 'US',
    st.scopeText = 'Human drug compounding outsourcing facility registration under FD&C Act section 503B; initial and most recent registration 2/6/2026',
    st.effectiveFrom = datetime('2026-02-06T00:00:00Z'), st.payloadHash = 'sha256:09e793249d20f71d3915a0fb08e7fe8e4240088127ab31bfad650d8b8c1dcc73',
    st.createdAt = datetime('2026-10-04T01:10:00Z');

// status: run
MATCH (st:RegulatoryStatus {uid: 'hu:regulatory-status:navinta-iii-503b-registration-2026'}), (f:Facility {uid: 'hu:facility:navinta-iii-boca-raton-503b'}),
      (fda:Organization {uid: 'hu:org:us-fda'}), (l:SourceLocator {uid: 'hu:locator:fda-503b-list-navinta-iii-row'})
MERGE (a:Assertion {uid: 'hu:assertion:fda-503b-list-navinta-iii-registration-status'})
SET a.privacyClass = coalesce(a.privacyClass, 'PUBLIC'), a.predicate = 'STATUS_OF', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T01:10:00Z'),
    a.validFrom = datetime('2026-02-06T00:00:00Z'), a.validFromPrecision = 'DAY', a.validFromBasis = 'STATED_BY_SOURCE',
    a.validToBasis = 'UNKNOWN', a.polarity = 'POSITIVE', a.predicateClass = 'REGULATORY', a.jurisdiction = 'US',
    a.contentHash = 'sha256:e1a298d2b9705d0e94a2a851e34c5f9bb1f91717e1885055c2a1bd08586fb55f', a.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (a)-[:HAS_SUBJECT]->(st)
MERGE (a)-[:HAS_OBJECT]->(f)
MERGE (a)-[:ASSERTED_BY]->(fda)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (st)-[r:STATUS_OF {relationshipUid: 'hu:rel:navinta-iii-503b-registration-status'}]->(f)
SET r.assertionUid = a.uid, r.validFrom = a.validFrom, r.validFromPrecision = 'DAY', r.validFromBasis = 'STATED_BY_SOURCE',
    r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T01:10:00Z')
MERGE (st)-[:ISSUED_BY]->(fda);

// status: run
MATCH (a:Assertion)
WHERE a.uid IN ['hu:assertion:nai-online-claims-cgmp', 'hu:assertion:nai-online-claims-fda-gmp-certification', 'hu:assertion:fda-503b-list-navinta-iii-registration-status']
  AND NOT EXISTS { MATCH (:Adjudication {adjudicationKind: 'CAPTURE_FIDELITY'})-[:EVALUATES]->(a) }
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w11-f04-capture-fidelity-policy'})
ON CREATE SET j.privacyClass = coalesce(j.privacyClass, 'PUBLIC'), j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
    j.reviewerType = 'POLICY', j.methodVersion = 'w11-fixture-capture-policy-1', j.status = 'ACCEPTED',
    j.reviewedAt = datetime('2026-10-04T01:40:00Z'), j.recordedAt = datetime('2026-10-04T01:40:00Z'),
    j.rationale = 'Fixture capture policy: propositions match the cited spans as read by W11.', j.privacyClass = 'INTERNAL',
    j.createdAt = datetime('2026-10-04T01:40:00Z')
MERGE (j)-[:EVALUATES]->(a);
