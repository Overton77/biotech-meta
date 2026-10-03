// Filing versus capability fixture (Round 0005: filing-versus-capability)
// Neo4j 5 Cypher. Illustrative fixture, not a production import. Never executed here.
//
// What it encodes (public sources unless marked synthetic):
//   1. A filing disclosure assertion: Niagen Bioscience FY2025 Form 10-K says it relies on a single supplier,
//      W.R. Grace, for nicotinamide riboside chloride (NRC).
//   2. A promoted capability assertion: the company home page says "Every ingredient we make ...".
//   3. A BellLabs adjudication: INSUFFICIENT for an operating NRC manufacturing capability, supported by the 10-K.
//   4. A 10-K characterization "authorized by the FDA for compounding by 503B outsourcing facilities",
//      adjudicated PARTIALLY_SUPPORTED against FDA's interim category 1 enforcement policy page.
//   5. GRAS notice GRN 000635 with FDA response "no questions" (verbatim conditions of use and disclaimer),
//      plus the company's restatement ("GRAS no objection ... Dose: 180 mg/day") as a separate assertion.
//   6. NDI notification 882 (company-reported; FDA letter not fetched).
//   7. A synthetic facility with an FDA food facility registration status (status of the facility only).
//   8. An Amazon listing where Amazon hosts and fulfills, and the displayed seller of record is "TRU NIAGEN".
//
// Intentionally absent (see Section 8):
//   - (org)-[:HAS_CAPABILITY_STATE]->(capability) for the promoted OPERATING capability
//   - any RegulatoryStatus with statusKind 'APPROVAL' for NRC, or Product.status = 'APPROVED'
//   - a registration status attached to a product
//   - (amazon)-[:SELLER_OF_RECORD_FOR]->(offer) and (amazon)-[:SELLS_PRODUCT]->(variant)
//
// Binding rule: every statement that creates a relationship MATCHes its endpoints by uid in the
// same statement. No variable is reused across a ';' boundary.

// ---------------------------------------------------------------------------
// Section 1: sources, snapshots, locators
// ---------------------------------------------------------------------------

// status: statically-checked
MERGE (s:Entity:Source {uid: 'hu:source:sec-nage-10k-fy2025'})
SET s.canonicalUri = 'https://www.sec.gov/Archives/edgar/data/1386570/000138657026000013/cdxc-20251231.htm', s.title = 'Niagen Bioscience, Inc. Form 10-K for fiscal year ended 2025-12-31', s.sourceKind = 'SECURITIES_FILING', s.createdAt = datetime();

// status: statically-checked
MERGE (s:Entity:Source {uid: 'hu:source:niagen-bioscience-home'})
SET s.canonicalUri = 'https://www.niagenbioscience.com', s.title = 'Niagen Bioscience home page', s.sourceKind = 'MARKETING_PAGE', s.createdAt = datetime();

// status: statically-checked
MERGE (s:Entity:Source {uid: 'hu:source:fda-grn-000635-response'})
SET s.canonicalUri = 'https://www.fda.gov/food/gras-notice-inventory/agency-response-letter-gras-notice-no-grn-000635', s.title = 'Agency Response Letter GRAS Notice No. GRN 000635', s.sourceKind = 'REGULATORY_RECORD', s.createdAt = datetime();

// status: statically-checked
MERGE (s:Entity:Source {uid: 'hu:source:truniagen-regulatory'})
SET s.canonicalUri = 'https://pages.truniagen.com/regulatory', s.title = 'Tru Niagen regulatory page', s.sourceKind = 'MARKETING_PAGE', s.createdAt = datetime();

// status: statically-checked
MERGE (s:Entity:Source {uid: 'hu:source:fda-503b-bulks'})
SET s.canonicalUri = 'https://www.fda.gov/drugs/human-drug-compounding/bulk-drug-substances-used-compounding-under-section-503b-fdc-act', s.title = 'Bulk Drug Substances Used in Compounding Under Section 503B', s.sourceKind = 'REGULATORY_GUIDANCE', s.createdAt = datetime();

// status: statically-checked
MERGE (s:Entity:Source {uid: 'hu:source:amazon-b0fs82b35k'})
SET s.canonicalUri = 'https://www.amazon.com/dp/B0FS82B35K', s.title = 'Amazon detail page B0FS82B35K', s.sourceKind = 'MARKETPLACE_LISTING', s.createdAt = datetime();

// status: statically-checked
MERGE (s:Entity:Source {uid: 'hu:source:synthetic-fda-ffr-record'})
SET s.canonicalUri = 'urn:synthetic:fda-food-facility-registration', s.title = 'Synthetic food facility registration confirmation', s.sourceKind = 'REGULATORY_RECORD', s.createdAt = datetime();

// status: statically-checked
MERGE (sn:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:sec-nage-10k-fy2025-2026-10-03'})
SET sn.canonicalUri = 'https://www.sec.gov/Archives/edgar/data/1386570/000138657026000013/cdxc-20251231.htm', sn.retrievedAt = datetime('2026-10-03T00:00:00Z'), sn.createdAt = datetime();

// status: statically-checked
MERGE (sn:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:niagen-bioscience-home-2026-10-03'})
SET sn.canonicalUri = 'https://www.niagenbioscience.com', sn.retrievedAt = datetime('2026-10-03T00:00:00Z'), sn.createdAt = datetime();

// status: statically-checked
MERGE (sn:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:fda-grn-000635-response-2026-10-03'})
SET sn.canonicalUri = 'https://www.fda.gov/food/gras-notice-inventory/agency-response-letter-gras-notice-no-grn-000635', sn.retrievedAt = datetime('2026-10-03T00:00:00Z'), sn.createdAt = datetime();

// status: statically-checked
MERGE (sn:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:truniagen-regulatory-2026-10-03'})
SET sn.canonicalUri = 'https://pages.truniagen.com/regulatory', sn.retrievedAt = datetime('2026-10-03T00:00:00Z'), sn.createdAt = datetime();

// status: statically-checked
MERGE (sn:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:fda-503b-bulks-2026-10-03'})
SET sn.canonicalUri = 'https://www.fda.gov/drugs/human-drug-compounding/bulk-drug-substances-used-compounding-under-section-503b-fdc-act', sn.retrievedAt = datetime('2026-10-03T00:00:00Z'), sn.createdAt = datetime();

// status: statically-checked
MERGE (sn:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-03'})
SET sn.canonicalUri = 'https://www.amazon.com/dp/B0FS82B35K', sn.observedAt = datetime('2026-10-03T00:00:00Z'), sn.retrievedAt = datetime('2026-10-03T00:00:00Z'), sn.createdAt = datetime();

// status: statically-checked
MERGE (sn:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:synthetic-fda-ffr-record'})
SET sn.canonicalUri = 'urn:synthetic:fda-food-facility-registration', sn.retrievedAt = datetime('2026-10-03T00:00:00Z'), sn.createdAt = datetime();

// status: statically-checked
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:nage-10k-fy2025-risk-single-supplier-grace'})
SET l.uri = 'https://www.sec.gov/Archives/edgar/data/1386570/000138657026000013/cdxc-20251231.htm', l.section = 'Item 1A Risk Factors: We rely on a single supplier, W.R. Grace, for NRC', l.createdAt = datetime();

// status: statically-checked
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:nage-10k-fy2025-503b-authorized'})
SET l.uri = 'https://www.sec.gov/Archives/edgar/data/1386570/000138657026000013/cdxc-20251231.htm', l.section = 'Pharmaceutical-grade Niagen is authorized by the FDA for compounding by 503B outsourcing facilities', l.createdAt = datetime();

// status: statically-checked
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:niagen-home-every-ingredient-we-make'})
SET l.uri = 'https://www.niagenbioscience.com', l.section = 'Unmatched quality and innovation: Every ingredient we make is clinically researched', l.createdAt = datetime();

// status: statically-checked
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:fda-grn-000635-response-body'})
SET l.uri = 'https://www.fda.gov/food/gras-notice-inventory/agency-response-letter-gras-notice-no-grn-000635', l.section = 'response letter body', l.createdAt = datetime();

// status: statically-checked
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:truniagen-regulatory-gras-line'})
SET l.uri = 'https://pages.truniagen.com/regulatory', l.section = 'FDA GRAS no objection for Niagen ... August 05, 2016; Dose: 180 mg/day', l.createdAt = datetime();

// status: statically-checked
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:truniagen-regulatory-ndi-882-line'})
SET l.uri = 'https://pages.truniagen.com/regulatory', l.section = 'FDA NDIN no objection ... November 03, 2015; Dose: 180 mg/day; NDI 882', l.createdAt = datetime();

// status: statically-checked
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:fda-503b-category-1-policy'})
SET l.uri = 'https://www.fda.gov/drugs/human-drug-compounding/bulk-drug-substances-used-compounding-under-section-503b-fdc-act', l.section = 'category 1 interim enforcement policy', l.createdAt = datetime();

// status: statically-checked
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-buybox'})
SET l.uri = 'https://www.amazon.com/dp/B0FS82B35K', l.section = 'One-time purchase $49.00; Ships from: Amazon; Sold by: TRU NIAGEN', l.createdAt = datetime();

// status: statically-checked
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:synthetic-ffr-confirmation'})
SET l.uri = 'urn:synthetic:fda-food-facility-registration', l.section = 'registration confirmation', l.createdAt = datetime();

// status: statically-checked
MATCH (s:Source {uid: 'hu:source:sec-nage-10k-fy2025'}), (sn:SourceSnapshot {uid: 'hu:snapshot:sec-nage-10k-fy2025-2026-10-03'}), (l1:SourceLocator {uid: 'hu:locator:nage-10k-fy2025-risk-single-supplier-grace'}), (l2:SourceLocator {uid: 'hu:locator:nage-10k-fy2025-503b-authorized'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l1)
MERGE (sn)-[:HAS_LOCATOR]->(l2);

// status: statically-checked
MATCH (s:Source {uid: 'hu:source:niagen-bioscience-home'}), (sn:SourceSnapshot {uid: 'hu:snapshot:niagen-bioscience-home-2026-10-03'}), (l:SourceLocator {uid: 'hu:locator:niagen-home-every-ingredient-we-make'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

// status: statically-checked
MATCH (s:Source {uid: 'hu:source:fda-grn-000635-response'}), (sn:SourceSnapshot {uid: 'hu:snapshot:fda-grn-000635-response-2026-10-03'}), (l:SourceLocator {uid: 'hu:locator:fda-grn-000635-response-body'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

// status: statically-checked
MATCH (s:Source {uid: 'hu:source:truniagen-regulatory'}), (sn:SourceSnapshot {uid: 'hu:snapshot:truniagen-regulatory-2026-10-03'}), (l1:SourceLocator {uid: 'hu:locator:truniagen-regulatory-gras-line'}), (l2:SourceLocator {uid: 'hu:locator:truniagen-regulatory-ndi-882-line'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l1)
MERGE (sn)-[:HAS_LOCATOR]->(l2);

// status: statically-checked
MATCH (s:Source {uid: 'hu:source:fda-503b-bulks'}), (sn:SourceSnapshot {uid: 'hu:snapshot:fda-503b-bulks-2026-10-03'}), (l:SourceLocator {uid: 'hu:locator:fda-503b-category-1-policy'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

// status: statically-checked
MATCH (s:Source {uid: 'hu:source:amazon-b0fs82b35k'}), (sn:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-03'}), (l:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-buybox'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

// status: statically-checked
MATCH (s:Source {uid: 'hu:source:synthetic-fda-ffr-record'}), (sn:SourceSnapshot {uid: 'hu:snapshot:synthetic-fda-ffr-record'}), (l:SourceLocator {uid: 'hu:locator:synthetic-ffr-confirmation'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

// ---------------------------------------------------------------------------
// Section 2: organizations, materials, products, facility, pathways
// ---------------------------------------------------------------------------

// status: statically-checked
MERGE (o:Entity:Organization:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
SET o.name = 'Niagen Bioscience', o.legalName = 'Niagen Bioscience, Inc.', o.organizationKind = 'COMPANY', o.createdAt = datetime();

// status: statically-checked
MERGE (o:Entity:Organization:LegalEntity {uid: 'hu:org:w-r-grace-and-co-conn'})
SET o.name = 'W.R. Grace', o.legalName = 'W.R. Grace & Co.-Conn.', o.organizationKind = 'COMPANY', o.createdAt = datetime();

// status: statically-checked
MERGE (o:Entity:Organization:RegulatoryAgency {uid: 'hu:org:us-fda'})
SET o.name = 'U.S. Food and Drug Administration', o.agencyCode = 'FDA', o.jurisdiction = 'US', o.organizationKind = 'REGULATORY_AGENCY', o.createdAt = datetime();

// status: statically-checked
MERGE (o:Entity:Organization {uid: 'hu:org:amazon-marketplace-us'})
SET o.name = 'Amazon (US marketplace operator)', o.organizationKind = 'MARKETPLACE_OPERATOR', o.createdAt = datetime();

// status: statically-checked
MERGE (o:Entity:Organization {uid: 'hu:org:seller-account-amazon-tru-niagen'})
SET o.name = 'TRU NIAGEN (Amazon seller display name)', o.organizationKind = 'SELLER_ACCOUNT', o.createdAt = datetime();

// status: statically-checked
MERGE (m:Entity:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
SET m.name = 'Niagen nicotinamide riboside chloride (food and supplement grade)', m.materialKind = 'CHEMICALLY_DEFINED_MATERIAL', m.createdAt = datetime();

// status: statically-checked
MERGE (m:Entity:IngredientMaterial {uid: 'hu:material:niagen-nrc-pharmaceutical-grade'})
SET m.name = 'Pharmaceutical-grade Niagen (NRC)', m.materialKind = 'CHEMICALLY_DEFINED_MATERIAL', m.createdAt = datetime();

// status: statically-checked
MERGE (p:Entity:Product {uid: 'hu:product:tru-niagen-beauty'})
SET p.name = 'TRU NIAGEN Beauty', p.productKind = 'DIETARY_SUPPLEMENT', p.createdAt = datetime();

// status: statically-checked
MERGE (v:Entity:ProductVariant {uid: 'hu:product-variant:tru-niagen-beauty-us-30ct'})
SET v.name = 'TRU NIAGEN Beauty, 30-count, US', v.jurisdiction = 'US', v.createdAt = datetime();

// status: statically-checked
MERGE (f:Entity:Facility {uid: 'hu:facility:synthetic-supplement-plant'})
SET f.name = 'Synthetic dietary supplement plant', f.facilityKind = 'MANUFACTURING_SITE', f.createdAt = datetime();

// status: statically-checked
MERGE (pw:Entity:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-gras-notice'})
SET pw.name = 'FDA GRAS notification program', pw.pathwayKind = 'GRAS_NOTICE', pw.jurisdiction = 'US', pw.legalBasisCitation = '21 CFR Part 170 Subpart E', pw.createdAt = datetime();

// status: statically-checked
MERGE (pw:Entity:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-ndi-notification'})
SET pw.name = 'FDA new dietary ingredient notification', pw.pathwayKind = 'NDI_NOTIFICATION', pw.jurisdiction = 'US', pw.legalBasisCitation = 'FD&C Act section 413; 21 CFR 190.6', pw.createdAt = datetime();

// status: statically-checked
MERGE (pw:Entity:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-food-facility-registration'})
SET pw.name = 'FDA food facility registration', pw.pathwayKind = 'FOOD_FACILITY_REGISTRATION', pw.jurisdiction = 'US', pw.legalBasisCitation = '21 CFR Part 1 Subpart H', pw.createdAt = datetime();

// status: statically-checked
MATCH (p:Product {uid: 'hu:product:tru-niagen-beauty'}), (v:ProductVariant {uid: 'hu:product-variant:tru-niagen-beauty-us-30ct'})
MERGE (p)-[:HAS_VARIANT]->(v);

// ---------------------------------------------------------------------------
// Section 3: filing disclosure versus promoted capability, and the BellLabs adjudication
// ---------------------------------------------------------------------------

// Filing disclosure (company statement in a securities filing).
// status: statically-checked
MATCH (grace:Organization {uid: 'hu:org:w-r-grace-and-co-conn'}), (nrc:IngredientMaterial {uid: 'hu:material:niagen-nrc'}), (niagen:Organization {uid: 'hu:org:niagen-bioscience-inc'}), (l:SourceLocator {uid: 'hu:locator:nage-10k-fy2025-risk-single-supplier-grace'})
MERGE (a:Assertion {uid: 'hu:assertion:nage-10k-grace-supplies-nrc'})
SET a.predicate = 'SUPPLIES_INGREDIENT_MATERIAL', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-03T00:00:00Z'), a.validFrom = datetime('2025-04-01T00:00:00Z'), a.valueString = null
MERGE (a)-[:HAS_SUBJECT]->(grace)
MERGE (a)-[:HAS_OBJECT]->(nrc)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(niagen)
MERGE (grace)-[r:SUPPLIES_INGREDIENT_MATERIAL]->(nrc)
SET r.validFrom = datetime('2025-04-01T00:00:00Z'), r.validTo = null, r.recordedFrom = datetime('2026-10-03T00:00:00Z'), r.recordedTo = null, r.assertionUid = 'hu:assertion:nage-10k-grace-supplies-nrc';

// Promoted capability (company statement on a marketing page). The capability node exists as the assertion's
// object so the claim is preserved; it is NOT attached to the company by HAS_CAPABILITY_STATE.
// status: statically-checked
MERGE (c:VersionedState:ManufacturingCapability {uid: 'hu:capability:niagen-nrc-manufacturing-as-promoted'})
SET c.stage = 'OPERATING', c.capacityBasis = 'NOT_REPORTED', c.stateType = 'MANUFACTURING_CAPABILITY', c.createdAt = datetime();

// status: statically-checked
MATCH (c:ManufacturingCapability {uid: 'hu:capability:niagen-nrc-manufacturing-as-promoted'}), (nrc:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
MERGE (c)-[:CAPABILITY_FOR_MATERIAL]->(nrc);

// status: statically-checked
MATCH (niagen:Organization {uid: 'hu:org:niagen-bioscience-inc'}), (c:ManufacturingCapability {uid: 'hu:capability:niagen-nrc-manufacturing-as-promoted'}), (l:SourceLocator {uid: 'hu:locator:niagen-home-every-ingredient-we-make'})
MERGE (a:Assertion {uid: 'hu:assertion:niagen-home-promotes-ingredient-manufacturing'})
SET a.predicate = 'HAS_CAPABILITY_STATE', a.status = 'EXTRACTED', a.recordedAt = datetime('2026-10-03T00:00:00Z'), a.extractionMethod = 'MANUAL_LANE3'
MERGE (a)-[:HAS_SUBJECT]->(niagen)
MERGE (a)-[:HAS_OBJECT]->(c)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(niagen);

// BellLabs adjudication of the promoted capability.
// status: statically-checked
MATCH (a:Assertion {uid: 'hu:assertion:niagen-home-promotes-ingredient-manufacturing'}), (l:SourceLocator {uid: 'hu:locator:nage-10k-fy2025-risk-single-supplier-grace'})
MERGE (j:EvidenceAssessment:Adjudication {uid: 'hu:adjudication:niagen-nrc-operating-capability-2026-10-03'})
SET j.assessmentType = 'ADJUDICATION', j.methodVersion = 'lane3-adjudication-v0', j.status = 'ACCEPTED', j.verdict = 'INSUFFICIENT', j.reviewerType = 'AGENT_PROPOSED_HUMAN_REVIEW_PENDING', j.reviewedAt = datetime('2026-10-03T00:00:00Z'), j.rationale = 'The FY2025 10-K discloses reliance on W.R. Grace as single supplier of NRC and on contract manufacturers; it discloses no company-operated NRC manufacturing. The 10-K limits Grace exclusivity to certain forms of NRCL, so the promotion is not contradicted outright; it is not established.', j.createdAt = datetime()
MERGE (j)-[:EVALUATES]->(a)
MERGE (j)-[:SUPPORTED_BY]->(l);

// 10-K characterization of agency position, adjudicated against the agency page.
// status: statically-checked
MATCH (pg:IngredientMaterial {uid: 'hu:material:niagen-nrc-pharmaceutical-grade'}), (niagen:Organization {uid: 'hu:org:niagen-bioscience-inc'}), (l:SourceLocator {uid: 'hu:locator:nage-10k-fy2025-503b-authorized'})
MERGE (a:Assertion {uid: 'hu:assertion:nage-10k-pharma-grade-niagen-authorized-503b'})
SET a.predicate = 'CHARACTERIZES_REGULATORY_STATUS', a.status = 'DISPUTED', a.recordedAt = datetime('2026-10-03T00:00:00Z'), a.valueString = 'authorized by the FDA for compounding by 503B outsourcing facilities', a.jurisdiction = 'US'
MERGE (a)-[:HAS_SUBJECT]->(pg)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(niagen);

// status: statically-checked
MATCH (a:Assertion {uid: 'hu:assertion:nage-10k-pharma-grade-niagen-authorized-503b'}), (l:SourceLocator {uid: 'hu:locator:fda-503b-category-1-policy'})
MERGE (j:EvidenceAssessment:Adjudication {uid: 'hu:adjudication:nage-503b-authorized-characterization'})
SET j.assessmentType = 'ADJUDICATION', j.methodVersion = 'lane3-adjudication-v0', j.status = 'ACCEPTED', j.verdict = 'PARTIALLY_SUPPORTED', j.reviewerType = 'AGENT_PROPOSED_HUMAN_REVIEW_PENDING', j.reviewedAt = datetime('2026-10-03T00:00:00Z'), j.rationale = 'FDA describes category 1 substances as within an interim enforcement policy pending a decision on the 503B bulks list; that is enforcement discretion, not an authorization. Whether NRC is in category 1 was not verified.', j.createdAt = datetime()
MERGE (j)-[:EVALUATES]->(a)
MERGE (j)-[:SUPPORTED_BY]->(l);

// ---------------------------------------------------------------------------
// Section 4: GRAS notice, NDI notification, responses, resulting status, company restatement
// ---------------------------------------------------------------------------

// status: statically-checked
MERGE (sub:InformationArtifact:RegulatorySubmission {uid: 'hu:reg-submission:us-fda-grn-000635'})
SET sub.submissionKind = 'GRAS_NOTICE', sub.identifier = 'GRN 000635', sub.jurisdiction = 'US', sub.submittedAt = datetime('2016-03-08T00:00:00Z'), sub.artifactType = 'REGULATORY_SUBMISSION', sub.createdAt = datetime();

// status: statically-checked
MERGE (resp:InformationArtifact:RegulatoryResponse {uid: 'hu:reg-response:us-fda-grn-000635'})
SET resp.responseKind = 'GRAS_NO_QUESTIONS', resp.jurisdiction = 'US', resp.issuedAt = null, resp.conditionsOfUseText = 'as a source of vitamin B3 in vitamin waters, protein shakes, nutrition bars, gum, chews, and powdered beverages at a maximum level of 0.0057% by weight as consumed', resp.agencyDisclaimerText = 'The agency has not, however, made its own determination regarding the GRAS status of the subject use of NR.', resp.artifactType = 'REGULATORY_RESPONSE', resp.createdAt = datetime();

// status: statically-checked
MERGE (st:VersionedState:RegulatoryStatus {uid: 'hu:reg-status:us-nrc-gras-notice-on-file'})
SET st.statusKind = 'NOTIFICATION_ON_FILE', st.jurisdiction = 'US', st.scopeText = 'GRAS notice GRN 000635, FDA no questions, intended food uses only', st.effectiveFrom = null, st.effectiveTo = null, st.stateType = 'REGULATORY_STATUS', st.createdAt = datetime();

// status: statically-checked
MERGE (ndi:InformationArtifact:RegulatorySubmission {uid: 'hu:reg-submission:us-fda-ndi-882'})
SET ndi.submissionKind = 'NDI_NOTIFICATION', ndi.identifier = 'NDI 882', ndi.jurisdiction = 'US', ndi.artifactType = 'REGULATORY_SUBMISSION', ndi.createdAt = datetime();

// status: statically-checked
MERGE (ndir:InformationArtifact:RegulatoryResponse {uid: 'hu:reg-response:us-fda-ndi-882'})
SET ndir.responseKind = 'NDI_ACKNOWLEDGED_WITHOUT_OBJECTION', ndir.jurisdiction = 'US', ndir.issuedAt = null, ndir.conditionsOfUseText = null, ndir.artifactType = 'REGULATORY_RESPONSE', ndir.createdAt = datetime();

// status: statically-checked
MATCH (sub:RegulatorySubmission {uid: 'hu:reg-submission:us-fda-grn-000635'}), (resp:RegulatoryResponse {uid: 'hu:reg-response:us-fda-grn-000635'}), (st:RegulatoryStatus {uid: 'hu:reg-status:us-nrc-gras-notice-on-file'}), (pw:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-gras-notice'}), (fda:RegulatoryAgency {uid: 'hu:org:us-fda'}), (nrc:IngredientMaterial {uid: 'hu:material:niagen-nrc'}), (niagen:Organization {uid: 'hu:org:niagen-bioscience-inc'}), (l:SourceLocator {uid: 'hu:locator:fda-grn-000635-response-body'})
MERGE (sub)-[:UNDER_PATHWAY]->(pw)
MERGE (sub)-[:SUBMISSION_HAS_RESPONSE]->(resp)
MERGE (resp)-[:ISSUED_BY]->(fda)
MERGE (st)-[:RESULTS_FROM_RESPONSE]->(resp)
MERGE (st)-[:UNDER_LEGAL_BASIS]->(pw)
MERGE (st)-[:ISSUED_BY]->(fda)
MERGE (a1:Assertion {uid: 'hu:assertion:grn-000635-submitted-by-chromadex'})
SET a1.predicate = 'SUBMITTED_BY', a1.status = 'ACCEPTED', a1.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (a1)-[:HAS_SUBJECT]->(sub)
MERGE (a1)-[:HAS_OBJECT]->(niagen)
MERGE (a1)-[:SUPPORTED_BY]->(l)
MERGE (sub)-[r1:SUBMITTED_BY]->(niagen)
SET r1.assertionUid = 'hu:assertion:grn-000635-submitted-by-chromadex'
MERGE (a2:Assertion {uid: 'hu:assertion:grn-000635-about-nrc'})
SET a2.predicate = 'SUBMISSION_ABOUT', a2.status = 'ACCEPTED', a2.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (a2)-[:HAS_SUBJECT]->(sub)
MERGE (a2)-[:HAS_OBJECT]->(nrc)
MERGE (a2)-[:SUPPORTED_BY]->(l)
MERGE (sub)-[r2:SUBMISSION_ABOUT]->(nrc)
SET r2.assertionUid = 'hu:assertion:grn-000635-about-nrc'
MERGE (a3:Assertion {uid: 'hu:assertion:nrc-gras-notice-on-file-status'})
SET a3.predicate = 'STATUS_OF', a3.status = 'ACCEPTED', a3.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (a3)-[:HAS_SUBJECT]->(st)
MERGE (a3)-[:HAS_OBJECT]->(nrc)
MERGE (a3)-[:SUPPORTED_BY]->(l)
MERGE (st)-[r3:STATUS_OF]->(nrc)
SET r3.assertionUid = 'hu:assertion:nrc-gras-notice-on-file-status';

// Company restatement of the GRAS response, kept separate from the agency record.
// status: statically-checked
MATCH (resp:RegulatoryResponse {uid: 'hu:reg-response:us-fda-grn-000635'}), (niagen:Organization {uid: 'hu:org:niagen-bioscience-inc'}), (l:SourceLocator {uid: 'hu:locator:truniagen-regulatory-gras-line'}), (lf:SourceLocator {uid: 'hu:locator:fda-grn-000635-response-body'})
MERGE (a:Assertion {uid: 'hu:assertion:truniagen-characterizes-grn-000635'})
SET a.predicate = 'CHARACTERIZES_REGULATORY_RESPONSE', a.status = 'DISPUTED', a.recordedAt = datetime('2026-10-03T00:00:00Z'), a.valueString = 'FDA GRAS no objection for Niagen (nicotinamide riboside chloride) on August 05, 2016; Dose: 180 mg/day'
MERGE (a)-[:HAS_SUBJECT]->(resp)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(niagen)
MERGE (j:EvidenceAssessment:Adjudication {uid: 'hu:adjudication:truniagen-grn-000635-characterization'})
SET j.assessmentType = 'ADJUDICATION', j.methodVersion = 'lane3-adjudication-v0', j.status = 'ACCEPTED', j.verdict = 'PARTIALLY_SUPPORTED', j.reviewerType = 'AGENT_PROPOSED_HUMAN_REVIEW_PENDING', j.reviewedAt = datetime('2026-10-03T00:00:00Z'), j.rationale = 'FDA response is "no questions" for listed food uses at 0.0057% by weight; it is not phrased as a dose in mg/day and FDA states it made no GRAS determination of its own. The 180 mg/day figure is not in the captured FDA text.', j.createdAt = datetime()
MERGE (j)-[:EVALUATES]->(a)
MERGE (j)-[:SUPPORTED_BY]->(lf);

// NDI 882: company-reported only; the FDA letter was not fetched, so the response assertion stays PROPOSED.
// status: statically-checked
MATCH (ndi:RegulatorySubmission {uid: 'hu:reg-submission:us-fda-ndi-882'}), (ndir:RegulatoryResponse {uid: 'hu:reg-response:us-fda-ndi-882'}), (pw:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-ndi-notification'}), (fda:RegulatoryAgency {uid: 'hu:org:us-fda'}), (niagen:Organization {uid: 'hu:org:niagen-bioscience-inc'}), (l:SourceLocator {uid: 'hu:locator:truniagen-regulatory-ndi-882-line'})
MERGE (ndi)-[:UNDER_PATHWAY]->(pw)
MERGE (ndi)-[:SUBMISSION_HAS_RESPONSE]->(ndir)
MERGE (ndir)-[:ISSUED_BY]->(fda)
MERGE (a:Assertion {uid: 'hu:assertion:truniagen-reports-ndi-882-acknowledged'})
SET a.predicate = 'CHARACTERIZES_REGULATORY_RESPONSE', a.status = 'PROPOSED', a.recordedAt = datetime('2026-10-03T00:00:00Z'), a.valueString = 'FDA NDIN no objection for Niagen on November 03, 2015; Dose: 180 mg/day; NDI 882'
MERGE (a)-[:HAS_SUBJECT]->(ndir)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(niagen);

// ---------------------------------------------------------------------------
// Section 5: facility registration (synthetic facility), a status of the facility only
// ---------------------------------------------------------------------------

// status: statically-checked
MERGE (st:VersionedState:RegulatoryStatus {uid: 'hu:reg-status:synthetic-plant-ffr-active'})
SET st.statusKind = 'ESTABLISHMENT_REGISTRATION', st.jurisdiction = 'US', st.scopeText = 'food facility registration (synthetic)', st.effectiveFrom = datetime('2024-11-01T00:00:00Z'), st.effectiveTo = null, st.stateType = 'REGULATORY_STATUS', st.createdAt = datetime();

// status: statically-checked
MATCH (st:RegulatoryStatus {uid: 'hu:reg-status:synthetic-plant-ffr-active'}), (f:Facility {uid: 'hu:facility:synthetic-supplement-plant'}), (pw:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-food-facility-registration'}), (fda:RegulatoryAgency {uid: 'hu:org:us-fda'}), (l:SourceLocator {uid: 'hu:locator:synthetic-ffr-confirmation'})
MERGE (st)-[:UNDER_LEGAL_BASIS]->(pw)
MERGE (st)-[:ISSUED_BY]->(fda)
MERGE (a:Assertion {uid: 'hu:assertion:synthetic-plant-ffr-status'})
SET a.predicate = 'STATUS_OF', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-03T00:00:00Z'), a.validFrom = datetime('2024-11-01T00:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(st)
MERGE (a)-[:HAS_OBJECT]->(f)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (st)-[r:STATUS_OF]->(f)
SET r.assertionUid = 'hu:assertion:synthetic-plant-ffr-status';

// ---------------------------------------------------------------------------
// Section 6: marketplace listing, offer roles, price observation
// ---------------------------------------------------------------------------

// status: statically-checked
MERGE (ml:Entity:MerchantListing:Listing {uid: 'hu:listing:amazon-us-b0fs82b35k'})
SET ml.merchantListingId = 'B0FS82B35K', ml.title = 'TRU NIAGEN Beauty NAD+ Supplement, Hair, Skin & Nails, Biotin, 30-Count', ml.canonicalUrl = 'https://www.amazon.com/dp/B0FS82B35K', ml.createdAt = datetime();

// status: statically-checked
MERGE (i:Entity:TradeItemIdentifier {uid: 'hu:trade-id:asin-b0fs82b35k'})
SET i.scheme = 'ASIN', i.value = 'B0FS82B35K', i.issuer = 'Amazon', i.jurisdiction = 'US', i.createdAt = datetime();

// status: statically-checked
MERGE (off:VersionedState:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-new-one-time-2026-10-03'})
SET off.offerKind = 'NEW_ONE_TIME', off.currency = 'USD', off.availability = 'IN_STOCK_AS_DISPLAYED', off.observedAt = datetime('2026-10-03T00:00:00Z'), off.stateType = 'OFFER', off.createdAt = datetime();

// status: statically-checked
MERGE (po:Occurrence:PriceObservation {uid: 'hu:price-obs:amazon-us-b0fs82b35k-2026-10-03-one-time'})
SET po.amount = 49.00, po.currency = 'USD', po.observedAt = datetime('2026-10-03T00:00:00Z'), po.priceKind = 'ONE_TIME', po.availabilityObserved = 'DELIVERY_DATE_DISPLAYED', po.occurrenceType = 'PRICE_OBSERVATION', po.createdAt = datetime();

// status: statically-checked
MATCH (ml:MerchantListing {uid: 'hu:listing:amazon-us-b0fs82b35k'}), (i:TradeItemIdentifier {uid: 'hu:trade-id:asin-b0fs82b35k'}), (off:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-new-one-time-2026-10-03'}), (po:PriceObservation {uid: 'hu:price-obs:amazon-us-b0fs82b35k-2026-10-03-one-time'}), (v:ProductVariant {uid: 'hu:product-variant:tru-niagen-beauty-us-30ct'}), (l:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-buybox'})
MERGE (ml)-[:IDENTIFIED_BY]->(i)
MERGE (ml)-[:HAS_OFFER]->(off)
MERGE (off)-[:HAS_PRICE_OBSERVATION]->(po)
MERGE (a:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-listing-for-variant'})
SET a.predicate = 'LISTING_FOR', a.status = 'PROPOSED', a.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(ml)
MERGE (a)-[:HAS_OBJECT]->(v)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (ml)-[r:LISTING_FOR]->(v)
SET r.assertionUid = 'hu:assertion:amazon-b0fs82b35k-listing-for-variant';

// Marketplace hosts and fulfills; the displayed seller of record is a seller account.
// status: statically-checked
MATCH (amz:Organization {uid: 'hu:org:amazon-marketplace-us'}), (seller:Organization {uid: 'hu:org:seller-account-amazon-tru-niagen'}), (ml:MerchantListing {uid: 'hu:listing:amazon-us-b0fs82b35k'}), (off:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-new-one-time-2026-10-03'}), (l:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-buybox'})
MERGE (a1:Assertion {uid: 'hu:assertion:amazon-hosts-listing-b0fs82b35k'})
SET a1.predicate = 'HOSTS_LISTING', a1.status = 'ACCEPTED', a1.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (a1)-[:HAS_SUBJECT]->(amz)
MERGE (a1)-[:HAS_OBJECT]->(ml)
MERGE (a1)-[:SUPPORTED_BY]->(l)
MERGE (amz)-[r1:HOSTS_LISTING]->(ml)
SET r1.assertionUid = 'hu:assertion:amazon-hosts-listing-b0fs82b35k'
MERGE (a2:Assertion {uid: 'hu:assertion:amazon-fulfills-offer-b0fs82b35k-2026-10-03'})
SET a2.predicate = 'FULFILLS_OFFER', a2.status = 'ACCEPTED', a2.recordedAt = datetime('2026-10-03T00:00:00Z'), a2.validFrom = null
MERGE (a2)-[:HAS_SUBJECT]->(amz)
MERGE (a2)-[:HAS_OBJECT]->(off)
MERGE (a2)-[:SUPPORTED_BY]->(l)
MERGE (amz)-[r2:FULFILLS_OFFER]->(off)
SET r2.assertionUid = 'hu:assertion:amazon-fulfills-offer-b0fs82b35k-2026-10-03', r2.recordedFrom = datetime('2026-10-03T00:00:00Z')
MERGE (a3:Assertion {uid: 'hu:assertion:tru-niagen-seller-of-record-b0fs82b35k-2026-10-03'})
SET a3.predicate = 'SELLER_OF_RECORD_FOR', a3.status = 'ACCEPTED', a3.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (a3)-[:HAS_SUBJECT]->(seller)
MERGE (a3)-[:HAS_OBJECT]->(off)
MERGE (a3)-[:SUPPORTED_BY]->(l)
MERGE (seller)-[r3:SELLER_OF_RECORD_FOR]->(off)
SET r3.assertionUid = 'hu:assertion:tru-niagen-seller-of-record-b0fs82b35k-2026-10-03', r3.recordedFrom = datetime('2026-10-03T00:00:00Z');

// Seller display name is not a legal entity: resolution hypothesis only.
// status: statically-checked
MATCH (seller:Organization {uid: 'hu:org:seller-account-amazon-tru-niagen'}), (niagen:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (h:EvidenceAssessment:ResolutionHypothesis {uid: 'hu:resolution:amazon-seller-tru-niagen-is-niagen-bioscience'})
SET h.assessmentType = 'RESOLUTION', h.methodVersion = 'lane3-manual-v0', h.status = 'PROPOSED', h.resolutionType = 'SELLER_ACCOUNT_OPERATED_BY_LEGAL_ENTITY', h.score = 0.7, h.resolutionStatus = 'UNRESOLVED', h.rationale = 'Seller display name matches the brand; Amazon seller id and business address not captured.', h.createdAt = datetime()
MERGE (h)-[:PROPOSES_MATCH]->(seller)
MERGE (h)-[:PROPOSES_MATCH]->(niagen);

// ---------------------------------------------------------------------------
// Section 7: (reserved) declared-amount referent is exercised in validation V-330 only;
// no Tru Niagen label snapshot was captured, so no QuantityDeclaration is created here.
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Section 8: intentionally absent edges and forbidden projections
// Uncommenting any block below must make at least one validation query return rows.
// ---------------------------------------------------------------------------

// ABSENT 1 (V-324): the promoted capability attached as an operating state of the company
// MATCH (niagen:Organization {uid: 'hu:org:niagen-bioscience-inc'}), (c:ManufacturingCapability {uid: 'hu:capability:niagen-nrc-manufacturing-as-promoted'})
// MERGE (niagen)-[h:HAS_CAPABILITY_STATE {relationshipUid: 'hu:rel:niagen-nrc-capability-forbidden'}]->(c)
// SET h.assertionUid = 'hu:assertion:niagen-home-promotes-ingredient-manufacturing', h.recordedFrom = datetime();

// ABSENT 2 (V-320): GRAS "no questions" projected as approval
// MATCH (resp:RegulatoryResponse {uid: 'hu:reg-response:us-fda-grn-000635'}), (nrc:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
// MERGE (bad:VersionedState:RegulatoryStatus {uid: 'hu:reg-status:forbidden-nrc-approval'})
// SET bad.statusKind = 'APPROVAL', bad.jurisdiction = 'US'
// MERGE (bad)-[:RESULTS_FROM_RESPONSE]->(resp)
// MERGE (bad)-[:STATUS_OF]->(nrc);

// ABSENT 3 (V-323): facility registration attached to a product ("made in an FDA-registered facility")
// MATCH (st:RegulatoryStatus {uid: 'hu:reg-status:synthetic-plant-ffr-active'}), (p:Product {uid: 'hu:product:tru-niagen-beauty'})
// MERGE (st)-[:STATUS_OF]->(p);

// ABSENT 4 (V-322): live projection Product.status = 'APPROVED' with no approval status behind it
// MATCH (p:Product {uid: 'hu:product:tru-niagen-beauty'})
// SET p.status = 'APPROVED';

// ABSENT 5 (V-326a, V-326b): marketplace treated as seller
// MATCH (amz:Organization {uid: 'hu:org:amazon-marketplace-us'}), (v:ProductVariant {uid: 'hu:product-variant:tru-niagen-beauty-us-30ct'}), (off:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-new-one-time-2026-10-03'})
// MERGE (amz)-[:SELLS_PRODUCT]->(v)
// MERGE (amz)-[:SELLER_OF_RECORD_FOR]->(off);

// ---------------------------------------------------------------------------
// Section 9: validation queries (zero rows = valid). Subset of lane 3 V-3xx.
// ---------------------------------------------------------------------------

// V-320a: an approval status may not result from a notification, notice, registration, clearance, De Novo, or designation response.
// status: statically-checked
MATCH (s:RegulatoryStatus)-[:RESULTS_FROM_RESPONSE]->(resp:RegulatoryResponse)
WHERE s.statusKind = 'APPROVAL'
  AND resp.responseKind IN ['NDI_ACKNOWLEDGED_WITHOUT_OBJECTION', 'NDI_INCOMPLETE', 'NDI_OBJECTION', 'NDI_OTHER_REGULATORY_ISSUE',
                            'GRAS_NO_QUESTIONS', 'GRAS_NO_BASIS', 'GRAS_CEASED_AT_NOTIFIER_REQUEST',
                            'REGISTRATION_ACTIVE', 'REGISTRATION_CANCELLED', 'SUBSTANTIALLY_EQUIVALENT', 'DE_NOVO_GRANTED',
                            'ORPHAN_DESIGNATION_GRANTED']
RETURN s.uid AS statusUid, resp.uid AS responseUid, resp.responseKind AS responseKind;

// V-320b: an approval status may not sit under a non-approval legal basis.
// status: statically-checked
MATCH (s:RegulatoryStatus)-[:UNDER_LEGAL_BASIS]->(pw:RegulatoryPathway)
WHERE s.statusKind = 'APPROVAL'
  AND pw.pathwayKind IN ['NDI_NOTIFICATION', 'GRAS_NOTICE', 'FOOD_FACILITY_REGISTRATION', 'DEVICE_ESTABLISHMENT_REGISTRATION',
                         'PREMARKET_NOTIFICATION_510K', 'DE_NOVO', 'ORPHAN_DESIGNATION', 'COMPOUNDING_503B_BULKS_POLICY', 'LDT_POLICY']
RETURN s.uid AS statusUid, pw.pathwayKind AS pathwayKind;

// V-322: live projection Product.status = 'APPROVED' requires an APPROVAL status of that product.
// status: statically-checked
MATCH (p:Product)
WHERE p.status = 'APPROVED'
  AND NOT EXISTS {
    MATCH (s:RegulatoryStatus)-[:STATUS_OF]->(p)
    WHERE s.statusKind = 'APPROVAL'
  }
RETURN coalesce(p.uid, p.id) AS productWithUnbackedApproval;

// V-323: establishment or facility registration is a status of a Facility only.
// status: statically-checked
MATCH (s:RegulatoryStatus)-[:STATUS_OF]->(x)
WHERE s.statusKind = 'ESTABLISHMENT_REGISTRATION' AND NOT x:Facility
RETURN s.uid AS statusUid, labels(x) AS attachedTo, x.uid AS attachedUid;

// V-324: an OPERATING capability state needs a non-marketing source or a SUPPORTED adjudication.
// status: statically-checked
MATCH (holder)-[h:HAS_CAPABILITY_STATE]->(c:ManufacturingCapability)
WHERE c.stage = 'OPERATING'
OPTIONAL MATCH (a:Assertion {uid: h.assertionUid})
OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
WITH holder, h, c, a, collect(DISTINCT src.sourceKind) AS kinds
WHERE a IS NULL
   OR (all(k IN kinds WHERE k IN ['MARKETING_PAGE', 'THIRD_PARTY_DIRECTORY', 'PRESS_RELEASE'])
       AND NOT EXISTS {
         MATCH (j:Adjudication)-[:EVALUATES]->(a)
         WHERE j.verdict = 'SUPPORTED'
       })
RETURN holder.uid AS holderUid, c.uid AS capabilityUid, kinds AS supportingSourceKinds;

// V-325: capability state edges are bitemporal and assertion-backed.
// status: statically-checked
MATCH (holder)-[h:HAS_CAPABILITY_STATE]->(c:ManufacturingCapability)
WHERE h.assertionUid IS NULL OR h.recordedFrom IS NULL
RETURN holder.uid AS holderUid, c.uid AS capabilityUid;

// V-326a: SELLS_PRODUCT is derived only from seller-of-record assertions.
// status: statically-checked
MATCH (o:Organization)-[s:SELLS_PRODUCT]->(p)
WHERE s.projectionOfAssertionUid IS NULL AND s.derivationRule IS NULL
RETURN o.uid AS organizationUid, p.uid AS productUid;

// V-326b: seller-of-record edges must be assertion-backed (hosting or fulfilling never implies it).
// status: statically-checked
MATCH (o:Organization)-[s:SELLER_OF_RECORD_FOR]->(off:Offer)
WHERE s.assertionUid IS NULL
RETURN o.uid AS organizationUid, off.uid AS offerUid,
       EXISTS { MATCH (o)-[:HOSTS_LISTING]->(:MerchantListing)-[:HAS_OFFER]->(off) } AS orgHostsTheListing,
       EXISTS { MATCH (o)-[:FULFILLS_OFFER]->(off) } AS orgFulfillsTheOffer;

// V-328: price observations carry amount, currency, observation time, and price kind.
// status: statically-checked
MATCH (po:PriceObservation)
WHERE po.amount IS NULL OR po.currency IS NULL OR po.observedAt IS NULL
   OR po.priceKind IS NULL OR NOT po.priceKind IN ['LIST', 'ONE_TIME', 'SUBSCRIPTION', 'COUPON_ADJUSTED', 'PER_UNIT']
RETURN po.uid AS priceObservationUid;

// V-330: label declarations never carry calculated referents (active moiety, nutrient equivalent).
// status: statically-checked
MATCH (q:QuantityDeclaration)
WHERE q.amountReferent IS NOT NULL
  AND NOT q.amountReferent IN ['NUTRIENT_AS_NUTRIENT', 'LISTED_INGREDIENT_AS_LISTED', 'PROPRIETARY_BLEND_TOTAL', 'EXTRACT_TOTAL', 'MARKER_CONSTITUENT', 'NOT_STATED']
RETURN q.uid AS declarationUid, q.amountReferent AS amountReferent;

// V-335: an accepted company characterization of an agency action requires a BellLabs adjudication.
// status: statically-checked
MATCH (a:Assertion)
WHERE a.predicate IN ['CHARACTERIZES_REGULATORY_RESPONSE', 'CHARACTERIZES_REGULATORY_STATUS']
  AND a.status = 'ACCEPTED'
  AND NOT EXISTS { MATCH (:Adjudication)-[:EVALUATES]->(a) }
RETURN a.uid AS unadjudicatedCharacterization;

// Expected result of this fixture as written: zero rows from every query above.
