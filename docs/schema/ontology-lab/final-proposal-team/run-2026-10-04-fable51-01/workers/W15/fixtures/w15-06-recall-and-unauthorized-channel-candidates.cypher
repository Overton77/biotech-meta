// W15 fixture 06 -- recalled-lot and unauthorized-channel CANDIDATES (OPEN-QUESTIONS quality/commerce 5; CQ-CM-C03).
// PUBLIC record, NEW_RETRIEVAL 2026-10-04T01:23:28Z: FDA company announcement "Ambrosia Brands, LLC Recalls Rosabella Moringa Capsules
// Because of Possible Health Risk" (2026-02-13): lots incl. "5040273 | 05/2027"; "None of the impacted lots were sold by us on Amazon.com,
// however, while we do not have any authorized resellers on Amazon.com, we urge you to check your lot numbers for any Rosabella Moringa
// capsules purchased on the site." SYNTHETIC: an Amazon listing/offer by a third-party seller and one unit bought off the shelf by a public
// testing organization with printed lot 5040273. Both findings stay PROPOSED CommerceMatch candidates supported by the FDA locator; no
// property such as recalled/grayMarket/counterfeit exists on the offer, listing, unit or variant.
// Binding rule: every statement MATCHes or MERGEs its nodes by uid; no variable crosses a ";". Load after w15-00-common.cypher.

MERGE (n:Source:Entity {uid: 'hu:source:fda-recall-ambrosia-rosabella-2026-02-13'})
ON CREATE SET n.id = 'fda-recall-ambrosia-rosabella-2026-02-13', n.canonicalUri = 'https://www.fda.gov/safety/recalls-market-withdrawals-safety-alerts/ambrosia-brands-llc-recalls-rosabella-moringa-capsules-because-possible-health-risk', n.title = 'Ambrosia Brands, LLC Recalls Rosabella Moringa Capsules Because of Possible Health Risk', n.sourceKind = 'REGULATORY_RECORD', n.entityType = 'Source', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:fda-recall-ambrosia-rosabella-2026-10-04t0123'})
ON CREATE SET n.id = 'fda-recall-ambrosia-rosabella-2026-10-04t0123', n.retrievedAt = datetime('2026-10-04T01:23:28Z'), n.observedAt = datetime('2026-10-04T01:23:28Z'), n.publishedAt = datetime('2026-02-13T00:00:00Z'), n.contentHash = 'sha256:d9346b3f1eef766f85fd59d66893434717034355cc3df03c892eaae76a47fd89', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'PARTIAL_EXCERPT', n.artifactType = 'SourceSnapshot', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Source {uid: 'hu:source:fda-recall-ambrosia-rosabella-2026-02-13'}), (b:SourceSnapshot {uid: 'hu:snapshot:fda-recall-ambrosia-rosabella-2026-10-04t0123'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:fda-recall-ambrosia-rosabella-2026-10-04t0123'})<-[:HAS_SNAPSHOT]-(src:Source) SET s.canonicalUri = src.canonicalUri;
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:fda-recall-ambrosia-rosabella-amazon-resellers'})
ON CREATE SET n.id = 'fda-recall-ambrosia-rosabella-amazon-resellers', n.selectorKind = 'TEXT_QUOTE', n.exact = 'None of the impacted lots were sold by us on Amazon.com, however, while we do not have any authorized resellers on Amazon.com, we urge you to check your lot numbers for any Rosabella Moringa capsules purchased on the site.', n.quoteHash = 'sha256:6c0667c0872a6051bee32e06d167807d673f4e8348faf4eb7ffb4bb9b84a6211', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fda-recall-ambrosia-rosabella-2026-10-04t0123'}), (b:SourceLocator {uid: 'hu:locator:fda-recall-ambrosia-rosabella-amazon-resellers'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:fda-recall-ambrosia-rosabella-lot-5040273'})
ON CREATE SET n.id = 'fda-recall-ambrosia-rosabella-lot-5040273', n.selectorKind = 'TEXT_QUOTE', n.exact = '| 5040273 | 05/2027 |', n.quoteHash = 'sha256:81d6162fdce02c9e1f525dca6fa95fcf62c2023e3f6b335fe9ec6301803e1fba', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fda-recall-ambrosia-rosabella-2026-10-04t0123'}), (b:SourceLocator {uid: 'hu:locator:fda-recall-ambrosia-rosabella-lot-5040273'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:fda-recall-ambrosia-rosabella-lot-format'})
ON CREATE SET n.id = 'fda-recall-ambrosia-rosabella-lot-format', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Lots impacted (all start with 1356 as the sku number, and end in a -1 or -2 after the lot code):', n.quoteHash = 'sha256:cece33171371256daa6606e2af809e6f6d08e2e8c3f73daf0e4d9da4abdbf5cd', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fda-recall-ambrosia-rosabella-2026-10-04t0123'}), (b:SourceLocator {uid: 'hu:locator:fda-recall-ambrosia-rosabella-lot-format'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:Source:Entity {uid: 'hu:source:w15-syn-amazon-rosabella-listing'})
ON CREATE SET n.id = 'w15-syn-amazon-rosabella-listing', n.canonicalUri = 'urn:synthetic:w15:amazon-rosabella-moringa-listing', n.title = 'SYNTHETIC Amazon listing for Rosabella Moringa Capsules 60 count', n.sourceKind = 'MARKETPLACE_LISTING', n.entityType = 'Source', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w15-syn-amazon-rosabella-2026-09-20'})
ON CREATE SET n.id = 'w15-syn-amazon-rosabella-2026-09-20', n.retrievedAt = datetime('2026-09-20T12:00:00Z'), n.observedAt = datetime('2026-09-20T12:00:00Z'), n.contentHash = 'sha256:38aea6a0cecd592971b1703ea176ea2b659509d725cc29331ed89718efdf7681', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'PARTIAL_EXCERPT', n.artifactType = 'SourceSnapshot', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Source {uid: 'hu:source:w15-syn-amazon-rosabella-listing'}), (b:SourceSnapshot {uid: 'hu:snapshot:w15-syn-amazon-rosabella-2026-09-20'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:w15-syn-amazon-rosabella-2026-09-20'})<-[:HAS_SNAPSHOT]-(src:Source) SET s.canonicalUri = src.canonicalUri;
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:w15-syn-amazon-rosabella-roles'})
ON CREATE SET n.id = 'w15-syn-amazon-rosabella-roles', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Ships from: W15 Synthetic Reseller Sold by: W15 Synthetic Reseller (SYNTHETIC)', n.quoteHash = 'sha256:b26a97ec9fba373284a1c5012f4f8c3475448fded6ba998651ad605a695148bb', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:w15-syn-amazon-rosabella-2026-09-20'}), (b:SourceLocator {uid: 'hu:locator:w15-syn-amazon-rosabella-roles'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:MerchantListing:Entity {uid: 'hu:listing:w15-syn-amazon-rosabella-moringa-60ct'})
ON CREATE SET n.id = 'w15-syn-amazon-rosabella-moringa-60ct', n.merchantListingId = 'W15SYNASIN1', n.marketplace = 'amazon.com', n.marketplaceRegion = 'US', n.title = 'Rosabella Moringa Capsules 60 Count (SYNTHETIC listing)', n.canonicalUrl = 'urn:synthetic:w15:amazon-rosabella-moringa-listing', n.entityType = 'MerchantListing', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Offer:VersionedState {uid: 'hu:offer:w15-syn-amazon-rosabella-moringa-60ct-reseller'})
ON CREATE SET n.id = 'w15-syn-amazon-rosabella-moringa-60ct-reseller', n.offerKind = 'PURCHASE', n.currency = 'USD', n.itemCondition = 'NEW', n.observedAt = datetime('2026-09-20T12:00:00Z'), n.payloadHash = 'sha256:c33616ea913b06b72a2a31d781299b4bf004ce2f5bbe3f28488efe5de0af526e', n.stateType = 'Offer', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:MerchantListing {uid: 'hu:listing:w15-syn-amazon-rosabella-moringa-60ct'}), (b:Offer {uid: 'hu:offer:w15-syn-amazon-rosabella-moringa-60ct-reseller'})
MERGE (a)-[r:HAS_OFFER]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:w15-syn-reseller-seller-of-record-rosabella'})
ON CREATE SET n.id = 'w15-syn-reseller-seller-of-record-rosabella', n.predicate = 'SELLER_OF_RECORD_FOR', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:98410da7653df40218be386339359c402ec174105a7a11062582642223b4f1af', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:w15-syn-reseller-seller-of-record-rosabella'}), (b:Organization {uid: 'hu:org:w15-syn-amazon-seller-moringa'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w15-syn-reseller-seller-of-record-rosabella'}), (b:Offer {uid: 'hu:offer:w15-syn-amazon-rosabella-moringa-60ct-reseller'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w15-syn-reseller-seller-of-record-rosabella'}), (b:SourceLocator {uid: 'hu:locator:w15-syn-amazon-rosabella-roles'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w15-syn-reseller-seller-of-record-rosabella-cf'})
ON CREATE SET n.id = 'w15-syn-reseller-seller-of-record-rosabella-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:w15-syn-reseller-seller-of-record-rosabella-cf'}), (b:Assertion {uid: 'hu:assertion:w15-syn-reseller-seller-of-record-rosabella'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:w15-syn-amazon-seller-moringa'}), (b:Offer {uid: 'hu:offer:w15-syn-amazon-rosabella-moringa-60ct-reseller'})
MERGE (a)-[r:SELLER_OF_RECORD_FOR {relationshipUid: 'hu:rel:w15-syn-reseller-seller-of-record-rosabella'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:w15-syn-reseller-seller-of-record-rosabella', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:w15-syn-amazon-hosts-rosabella'})
ON CREATE SET n.id = 'w15-syn-amazon-hosts-rosabella', n.predicate = 'HOSTS_LISTING', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:300003cf6b0bf803300d66f366b0bacf558f1922d2ffceec7788292735a04e67', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:w15-syn-amazon-hosts-rosabella'}), (b:Organization {uid: 'hu:org:amazon-marketplace-us'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w15-syn-amazon-hosts-rosabella'}), (b:MerchantListing {uid: 'hu:listing:w15-syn-amazon-rosabella-moringa-60ct'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w15-syn-amazon-hosts-rosabella'}), (b:SourceLocator {uid: 'hu:locator:w15-syn-amazon-rosabella-roles'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w15-syn-amazon-hosts-rosabella-cf'})
ON CREATE SET n.id = 'w15-syn-amazon-hosts-rosabella-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:w15-syn-amazon-hosts-rosabella-cf'}), (b:Assertion {uid: 'hu:assertion:w15-syn-amazon-hosts-rosabella'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:amazon-marketplace-us'}), (b:MerchantListing {uid: 'hu:listing:w15-syn-amazon-rosabella-moringa-60ct'})
MERGE (a)-[r:HOSTS_LISTING {relationshipUid: 'hu:rel:w15-syn-amazon-hosts-rosabella'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:w15-syn-amazon-hosts-rosabella', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:w15-syn-rosabella-listing-for-60ct'})
ON CREATE SET n.id = 'w15-syn-rosabella-listing-for-60ct', n.predicate = 'LISTING_FOR', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:781a283663264172c18b01f9b94418ba9cc40188cfe88aeb18bd7e515b51fda2', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:w15-syn-rosabella-listing-for-60ct'}), (b:MerchantListing {uid: 'hu:listing:w15-syn-amazon-rosabella-moringa-60ct'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w15-syn-rosabella-listing-for-60ct'}), (b:PackageConfiguration {uid: 'hu:package-configuration:rosabella-moringa-60ct'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w15-syn-rosabella-listing-for-60ct'}), (b:SourceLocator {uid: 'hu:locator:w15-syn-amazon-rosabella-roles'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w15-syn-rosabella-listing-for-60ct-cf'})
ON CREATE SET n.id = 'w15-syn-rosabella-listing-for-60ct-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:w15-syn-rosabella-listing-for-60ct-cf'}), (b:Assertion {uid: 'hu:assertion:w15-syn-rosabella-listing-for-60ct'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:MerchantListing {uid: 'hu:listing:w15-syn-amazon-rosabella-moringa-60ct'}), (b:PackageConfiguration {uid: 'hu:package-configuration:rosabella-moringa-60ct'})
MERGE (a)-[r:LISTING_FOR {relationshipUid: 'hu:rel:w15-syn-rosabella-listing-for-60ct'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:w15-syn-rosabella-listing-for-60ct', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:w15-syn-amazon-rosabella-2026-09-20-one-time'})
ON CREATE SET n.id = 'w15-syn-amazon-rosabella-2026-09-20-one-time', n.amount = 24.99, n.currency = 'USD', n.observedAt = datetime('2026-09-20T12:00:00Z'), n.startedAt = datetime('2026-09-20T12:00:00Z'), n.priceKind = 'ONE_TIME', n.availabilityObserved = 'IN_STOCK', n.sourceLocatorUid = 'hu:locator:w15-syn-amazon-rosabella-roles', n.captureMethod = 'MANUAL_TRANSCRIPTION', n.priceTextVerbatim = '$24.99 (SYNTHETIC)', n.observationRegion = 'US', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:w15-syn-amazon-rosabella-moringa-60ct-reseller'}), (b:PriceObservation {uid: 'hu:price-obs:w15-syn-amazon-rosabella-2026-09-20-one-time'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
MERGE (n:CommerceMatch:EvidenceAssessment {uid: 'hu:commerce-match:w15-syn-rosabella-offer-authorized-channel'})
ON CREATE SET n.id = 'w15-syn-rosabella-offer-authorized-channel', n.assessmentType = 'CommerceMatch', n.methodVersion = 'w15-authorized-channel/v0', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.matchKind = 'AUTHORIZED_CHANNEL', n.matchOutcome = 'NO_AUTHORIZATION_FOUND', n.score = 0.7, n.rationale = 'Brand statement of 2026-02-13 (FDA-published company announcement): no authorized resellers on Amazon.com. The offer was observed 2026-09-20; the statement\'s validity after 2026-02-13 is not established. Unauthorized-channel CANDIDATE, not a counterfeit finding.', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:w15-syn-rosabella-offer-authorized-channel'}), (b:Offer {uid: 'hu:offer:w15-syn-amazon-rosabella-moringa-60ct-reseller'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:w15-syn-rosabella-offer-authorized-channel'}), (b:Organization {uid: 'hu:org:w15-syn-amazon-seller-moringa'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:w15-syn-rosabella-offer-authorized-channel'}), (b:Organization {uid: 'hu:org:ambrosia-brands-llc'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:w15-syn-rosabella-offer-authorized-channel'}), (b:SourceLocator {uid: 'hu:locator:fda-recall-ambrosia-rosabella-amazon-resellers'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
// SYNTHETIC public testing purchase: one unit, lot code as printed; UNIT_FROM_LOT is PROPOSED (printed code parsed by rule).
MERGE (n:Source:Entity {uid: 'hu:source:w15-syn-lab-purchase-record'})
ON CREATE SET n.id = 'w15-syn-lab-purchase-record', n.canonicalUri = 'urn:synthetic:w15:lab-purchase-record', n.title = 'SYNTHETIC public test report purchase record', n.sourceKind = 'AUDIT_REPORT', n.entityType = 'Source', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w15-syn-lab-purchase-record-2026-09-25'})
ON CREATE SET n.id = 'w15-syn-lab-purchase-record-2026-09-25', n.retrievedAt = datetime('2026-09-25T12:00:00Z'), n.observedAt = datetime('2026-09-25T12:00:00Z'), n.contentHash = 'sha256:2b9e8d9160314c587c2bf87bc70031da61ce26015f7cf23c0615dc94d8857049', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'PARTIAL_EXCERPT', n.artifactType = 'SourceSnapshot', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Source {uid: 'hu:source:w15-syn-lab-purchase-record'}), (b:SourceSnapshot {uid: 'hu:snapshot:w15-syn-lab-purchase-record-2026-09-25'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:w15-syn-lab-purchase-record-2026-09-25'})<-[:HAS_SNAPSHOT]-(src:Source) SET s.canonicalUri = src.canonicalUri;
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:w15-syn-lab-purchase-lot'})
ON CREATE SET n.id = 'w15-syn-lab-purchase-lot', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Lot 13565040273-1 EXP 05/2027, purchased 2026-09-22 from the Amazon offer (SYNTHETIC)', n.quoteHash = 'sha256:d436a06916594a0e210b9dc7e36a359c8e1fb08bada86fbafdb7ab0c2b69ea91', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:w15-syn-lab-purchase-record-2026-09-25'}), (b:SourceLocator {uid: 'hu:locator:w15-syn-lab-purchase-lot'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:IndividualUnit:Entity {uid: 'hu:individual-unit:w15-syn-rosabella-unit-0001'})
ON CREATE SET n.id = 'w15-syn-rosabella-unit-0001', n.lotCodeAsPrinted = '13565040273-1', n.expiryTextAsPrinted = 'EXP 05/2027', n.acquiredFromOfferUid = 'hu:offer:w15-syn-amazon-rosabella-moringa-60ct-reseller', n.acquisitionContext = 'PUBLIC_TESTING_PURCHASE', n.entityType = 'IndividualUnit', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:w15-syn-unit-from-lot-5040273'})
ON CREATE SET n.id = 'w15-syn-unit-from-lot-5040273', n.predicate = 'UNIT_FROM_LOT', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.basisKind = 'HYPOTHESIS', n.derivationRule = 'rosabella-printed-code: strip leading 1356 sku and trailing -1/-2', n.contentHash = 'sha256:7db00fb50b08f214651d43e580c14e79a5e60a17b2ad7a12c93ba0b4ff96c2c3', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:w15-syn-unit-from-lot-5040273'}), (b:IndividualUnit {uid: 'hu:individual-unit:w15-syn-rosabella-unit-0001'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w15-syn-unit-from-lot-5040273'}), (b:ProductLot {uid: 'hu:lot:rosabella-moringa-5040273'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w15-syn-unit-from-lot-5040273'}), (b:SourceLocator {uid: 'hu:locator:w15-syn-lab-purchase-lot'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:IndividualUnit {uid: 'hu:individual-unit:w15-syn-rosabella-unit-0001'}), (b:ProductLot {uid: 'hu:lot:rosabella-moringa-5040273'})
MERGE (a)-[r:UNIT_FROM_LOT {relationshipUid: 'hu:rel:w15-syn-unit-from-lot-5040273'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:w15-syn-unit-from-lot-5040273', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:CommerceMatch:EvidenceAssessment {uid: 'hu:commerce-match:w15-syn-rosabella-unit-recall-scope'})
ON CREATE SET n.id = 'w15-syn-rosabella-unit-recall-scope', n.assessmentType = 'CommerceMatch', n.methodVersion = 'w15-recall-scope/v0', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.matchKind = 'RECALL_SCOPE', n.matchOutcome = 'IN_SCOPE', n.score = 0.9, n.rationale = 'Printed code 1356 + 5040273 + -1 matches the notice\'s lot format and lists lot 5040273 (exp 05/2027). Recall exposure CANDIDATE pending review; the recall event itself is W13\'s record.', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:w15-syn-rosabella-unit-recall-scope'}), (b:IndividualUnit {uid: 'hu:individual-unit:w15-syn-rosabella-unit-0001'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:w15-syn-rosabella-unit-recall-scope'}), (b:ProductLot {uid: 'hu:lot:rosabella-moringa-5040273'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:w15-syn-rosabella-unit-recall-scope'}), (b:Offer {uid: 'hu:offer:w15-syn-amazon-rosabella-moringa-60ct-reseller'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:w15-syn-rosabella-unit-recall-scope'}), (b:SourceLocator {uid: 'hu:locator:fda-recall-ambrosia-rosabella-lot-5040273'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:w15-syn-rosabella-unit-recall-scope'}), (b:SourceLocator {uid: 'hu:locator:fda-recall-ambrosia-rosabella-lot-format'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:w15-syn-rosabella-unit-recall-scope'}), (b:SourceLocator {uid: 'hu:locator:w15-syn-lab-purchase-lot'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
// SYNTHETIC inventory record of the reseller (merchant SKU) tied to the package; recall exposure of the inventory is also only a candidate.
MERGE (n:InventoryItem:Entity {uid: 'hu:inventory-item:w15-syn-reseller-sku-rbm60'})
ON CREATE SET n.id = 'w15-syn-reseller-sku-rbm60', n.merchantInventoryId = 'RBM-60-SYN', n.merchantOrganizationUid = 'hu:org:w15-syn-amazon-seller-moringa', n.entityType = 'InventoryItem', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:w15-syn-inventory-instance-of-rosabella-60ct'})
ON CREATE SET n.id = 'w15-syn-inventory-instance-of-rosabella-60ct', n.predicate = 'INVENTORY_INSTANCE_OF', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:1b9568dddbab6ea5b071a7e8d1ae98c09aff7cf969f467d1d1a2b9822b2d6008', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:w15-syn-inventory-instance-of-rosabella-60ct'}), (b:InventoryItem {uid: 'hu:inventory-item:w15-syn-reseller-sku-rbm60'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w15-syn-inventory-instance-of-rosabella-60ct'}), (b:PackageConfiguration {uid: 'hu:package-configuration:rosabella-moringa-60ct'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w15-syn-inventory-instance-of-rosabella-60ct'}), (b:SourceLocator {uid: 'hu:locator:w15-syn-amazon-rosabella-roles'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:InventoryItem {uid: 'hu:inventory-item:w15-syn-reseller-sku-rbm60'}), (b:PackageConfiguration {uid: 'hu:package-configuration:rosabella-moringa-60ct'})
MERGE (a)-[r:INVENTORY_INSTANCE_OF {relationshipUid: 'hu:rel:w15-syn-inventory-instance-of-rosabella-60ct'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:w15-syn-inventory-instance-of-rosabella-60ct', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
