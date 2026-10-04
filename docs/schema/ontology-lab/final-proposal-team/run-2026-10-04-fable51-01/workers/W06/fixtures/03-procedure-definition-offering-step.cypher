// =====================================================================================================================
// W06 fixture 03: procedure DEFINITION versus an organization OFFERING it versus a protocol STEP EMPLOYING it versus a
// study intervention INSTANTIATING it; plus a classification-code identity collision.
//   Procedure  hu:procedure:therapeutic-plasma-exchange   definition                                         [W06]
//   OFFERS_PROCEDURE Next Health -> TPE (asserted from the Next Health page; offerer's own statement)       [W06 rel]
//   MerchantListing / Offer / PriceObservation ($10,000 single session; bundle pages are W15's)           [W15]
//   ProtocolStep (SYNTHETIC public practice protocol) -[:EMPLOYS]-> TPE (requested W16 range extension)    [W16]
//   StudyIntervention HORIZON "Plasmapheresis" -[:INSTANTIATES_PROCEDURE]-> TPE (fixture 02)               [W09]
//   Procedure  hu:procedure:plasma-donation-plasmapheresis  a DIFFERENT definition sharing ICD-10-PCS 6A550Z3/6A551Z3
//   Circulate Health: offer statement captured only as a search extract -> Assertion status EXTRACTED, no edge.
//   GeekWire "more than 1,000 treatments": a literal about Circulate; no performance occurrences are created.
//   The page's benefit wording ("remove particles that are known contributors to disease and accelerated aging") is
//   a claim (W21) and produces NO TARGETS_CONDITION edge.
// Rule: every statement binds its own nodes by uid; no variable crosses a ';'.
// =====================================================================================================================

MERGE (p:Procedure:Entity {uid: 'hu:procedure:therapeutic-plasma-exchange'})
SET p.id = 'therapeutic-plasma-exchange', p.entityType = 'Procedure', p.name = 'therapeutic plasma exchange (TPE; plasmapheresis with plasma replacement)',
    p.procedureType = 'apheresis', p.setting = null, p.invasiveness = null, p.durationSummary = null,
    p.privacyClass = 'PUBLIC', p.maturity = 'PROVISIONAL', p.createdAt = datetime('2026-10-04T02:00:00Z'), p.updatedAt = datetime('2026-10-04T02:00:00Z');

MERGE (p:Procedure:Entity {uid: 'hu:procedure:plasma-donation-plasmapheresis'})
SET p.id = 'plasma-donation-plasmapheresis', p.entityType = 'Procedure', p.name = 'plasma donation by plasmapheresis (plasma collected, not exchanged)',
    p.procedureType = 'apheresis', p.privacyClass = 'PUBLIC', p.maturity = 'PROVISIONAL',
    p.createdAt = datetime('2026-10-04T02:00:00Z'), p.updatedAt = datetime('2026-10-04T02:00:00Z');

UNWIND ['6A550Z3', '6A551Z3'] AS code
MERGE (n:Identifier:Entity {uid: 'hu:identifier:icd10pcs-' + toLower(code)})
SET n.entityType = 'Identifier', n.scheme = 'ICD-10-PCS', n.value = code, n.codeSetVersion = 'FY2027',
    n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z');

UNWIND [
  {proc: 'therapeutic-plasma-exchange', code: '6A550Z3'}, {proc: 'therapeutic-plasma-exchange', code: '6A551Z3'},
  {proc: 'plasma-donation-plasmapheresis', code: '6A550Z3'}, {proc: 'plasma-donation-plasmapheresis', code: '6A551Z3'}
] AS x
MATCH (p:Procedure {uid: 'hu:procedure:' + x.proc}), (n:Identifier {uid: 'hu:identifier:icd10pcs-' + toLower(x.code)}), (l:SourceLocator {uid: 'hu:locator:icd10pcs-6A55'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-' + x.proc + '-icd10pcs-' + toLower(x.code)})
SET a.predicate = 'HAS_IDENTIFIER', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'IDENTITY', a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(p)
MERGE (a)-[:HAS_OBJECT]->(n)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (p)-[r:HAS_IDENTIFIER {relationshipUid: 'hu:rel:w06-' + x.proc + '-' + toLower(x.code)}]->(n)
SET r.assertionUid = a.uid, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN',
    r.recordedFrom = datetime('2026-10-04T02:00:00Z'), r.isPrimary = false;

// ---- OFFERS_PROCEDURE: the offerer's own page; offering is not performing, not approval, not recommendation ----
MATCH (o:Organization {uid: 'hu:org:next-health'}), (p:Procedure {uid: 'hu:procedure:therapeutic-plasma-exchange'}), (l:SourceLocator {uid: 'hu:locator:next-health-tpe-definition'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-next-health-offers-tpe'})
SET a.predicate = 'OFFERS_PROCEDURE', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'COMMERCIAL', a.speechAct = 'STATES', a.assertionBasis = 'MANUFACTURER_CLAIM',
    a.validFrom = datetime('2026-10-04T00:00:00Z'), a.validFromPrecision = 'DAY', a.validFromBasis = 'OBSERVATION_ONLY',
    a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(o)
MERGE (a)-[:HAS_OBJECT]->(p)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(o)
MERGE (o)-[r:OFFERS_PROCEDURE {relationshipUid: 'hu:rel:w06-next-health-offers-tpe'}]->(p)
SET r.assertionUid = a.uid, r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN',
    r.recordedFrom = datetime('2026-10-04T02:00:00Z');

// ---- W15 commerce records from the same page (referenced shapes; W15 owns them) ----
MERGE (ml:MerchantListing:Entity {uid: 'hu:listing:next-health-tpe'})
SET ml.entityType = 'MerchantListing', ml.title = 'Therapeutic Plasma Exchange | Next Health',
    ml.canonicalUrl = 'https://www.next-health.com/product/therapeutic-plasma-exchange', ml.privacyClass = 'PUBLIC', ml.createdAt = datetime('2026-10-04T02:00:00Z');

MERGE (of:Offer:VersionedState {uid: 'hu:offer:next-health-tpe-single-session'})
SET of.stateType = 'Offer', of.offerKind = 'ONE_TIME', of.currency = 'USD',
    of.termsText = 'single session; includes a Baseline Test and a Total Tox Burden Test before each session',
    of.payloadHash = 'sha256:' + 'synthetic-hu:offer:next-health-tpe-single-session', of.privacyClass = 'PUBLIC', of.createdAt = datetime('2026-10-04T02:00:00Z');

MERGE (po:PriceObservation:Occurrence {uid: 'hu:price-obs:next-health-tpe-single-20261004'})
SET po.occurrenceType = 'PriceObservation', po.amount = 10000.0, po.currency = 'USD', po.priceKind = 'ONE_TIME',
    po.observedAt = datetime('2026-10-04T01:02:00Z'), po.privacyClass = 'PUBLIC', po.createdAt = datetime('2026-10-04T02:00:00Z');

MATCH (ml:MerchantListing {uid: 'hu:listing:next-health-tpe'}), (of:Offer {uid: 'hu:offer:next-health-tpe-single-session'})
MERGE (ml)-[:HAS_OFFER]->(of);

MATCH (of:Offer {uid: 'hu:offer:next-health-tpe-single-session'}), (po:PriceObservation {uid: 'hu:price-obs:next-health-tpe-single-20261004'})
MERGE (of)-[:HAS_PRICE_OBSERVATION]->(po);

MATCH (ml:MerchantListing {uid: 'hu:listing:next-health-tpe'}), (p:Procedure {uid: 'hu:procedure:therapeutic-plasma-exchange'}), (l:SourceLocator {uid: 'hu:locator:next-health-tpe-price'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-next-health-listing-lists-tpe'})
SET a.predicate = 'LISTS_PROCEDURE', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'COMMERCIAL', a.speechAct = 'STATES', a.assertionBasis = 'MANUFACTURER_CLAIM',
    a.validFromBasis = 'OBSERVATION_ONLY', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(ml)
MERGE (a)-[:HAS_OBJECT]->(p)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (ml)-[r:LISTS_PROCEDURE {relationshipUid: 'hu:rel:w06-next-health-listing-lists-tpe'}]->(p)
SET r.assertionUid = a.uid, r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

// ---- W16 public practice protocol (SYNTHETIC) whose step employs the procedure definition ----
MERGE (pr:Protocol:Entity {uid: 'hu:protocol:synthetic-tpe-practice'})
SET pr.entityType = 'Protocol', pr.name = 'SYNTHETIC public practice protocol with periodic TPE', pr.privacyClass = 'PUBLIC', pr.createdAt = datetime('2026-10-04T02:00:00Z');

MERGE (e:ProtocolEdition:VersionedState {uid: 'hu:protocol-edition:synthetic-tpe-practice-e1'})
SET e.stateType = 'ProtocolEdition', e.editionLabel = 'e1', e.payloadHash = 'sha256:' + 'synthetic-hu:protocol-edition:synthetic-tpe-practice-e1',
    e.privacyClass = 'PUBLIC', e.createdAt = datetime('2026-10-04T02:00:00Z');

MERGE (st:ProtocolStep:Entity {uid: 'hu:protocol-step:synthetic-tpe-practice-e1-step3'})
SET st.entityType = 'ProtocolStep', st.stepKey = 'step3-tpe', st.requirementLevel = 'OPTIONAL', st.requirementBasis = 'STATED_BY_SOURCE',
    st.scheduleText = 'one TPE session every 6 months (SYNTHETIC)', st.payloadHash = 'sha256:' + 'synthetic-step3-tpe',
    st.privacyClass = 'PUBLIC', st.createdAt = datetime('2026-10-04T02:00:00Z');

MATCH (pr:Protocol {uid: 'hu:protocol:synthetic-tpe-practice'}), (e:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-tpe-practice-e1'})
MERGE (pr)-[r:HAS_PROTOCOL_EDITION {relationshipUid: 'hu:rel:w06-synthetic-tpe-practice-e1'}]->(e)
SET r.assertionUid = 'hu:assertion:w06-synthetic-tpe-practice-has-e1', r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

MATCH (pr:Protocol {uid: 'hu:protocol:synthetic-tpe-practice'}), (e:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-tpe-practice-e1'}), (l:SourceLocator {uid: 'hu:locator:synthetic-practice-protocol-step'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-synthetic-tpe-practice-has-e1'})
SET a.predicate = 'HAS_PROTOCOL_EDITION', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'OTHER', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(pr)
MERGE (a)-[:HAS_OBJECT]->(e)
MERGE (a)-[:SUPPORTED_BY]->(l);

MATCH (e:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-tpe-practice-e1'}), (st:ProtocolStep {uid: 'hu:protocol-step:synthetic-tpe-practice-e1-step3'})
MERGE (e)-[r:HAS_PROTOCOL_STEP]->(st)
SET r.orderIndex = 3;

// EMPLOYS -> Procedure is the requested W16 range extension (W06-SR-04); structural part of the immutable step payload.
MATCH (st:ProtocolStep {uid: 'hu:protocol-step:synthetic-tpe-practice-e1-step3'}), (p:Procedure {uid: 'hu:procedure:therapeutic-plasma-exchange'})
MERGE (st)-[r:EMPLOYS]->(p)
SET r.orderIndex = 1, r.notes = 'step employs the procedure definition; a person performing it is private and out of the graph';

// ---- Circulate: B2B service statement known only from a search snippet -> EXTRACTED, not projected ----
MATCH (o:Organization {uid: 'hu:org:circulate-health'}), (p:Procedure {uid: 'hu:procedure:therapeutic-plasma-exchange'}), (l:SourceLocator {uid: 'hu:locator:circulate-search-snippet'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-circulate-offers-tpe-to-partner-clinics'})
SET a.predicate = 'OFFERS_PROCEDURE', a.status = 'EXTRACTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'COMMERCIAL', a.speechAct = 'STATES', a.assertionBasis = 'MANUFACTURER_CLAIM',
    a.valueString = null, a.offeringRoleText = 'partners with clinics to deliver therapeutic plasma exchange as a turnkey, fully supported clinical service',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(o)
MERGE (a)-[:HAS_OBJECT]->(p)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(o);

// ---- Performance volume: a literal about the organization, reported by trade press; no occurrence nodes ----
MATCH (o:Organization {uid: 'hu:org:circulate-health'}), (g:Organization {uid: 'hu:org:geekwire'}), (l:SourceLocator {uid: 'hu:locator:geekwire-search-snippet'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-geekwire-circulate-treatment-volume'})
SET a.predicate = 'REPORTS_PROCEDURE_VOLUME', a.status = 'EXTRACTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.valueNumber = 1000.0, a.valueString = 'more than 1,000 treatments (TPE) since May 2024', a.resultQualifier = 'GREATER_THAN',
    a.polarity = 'POSITIVE', a.predicateClass = 'QUANTITY', a.speechAct = 'REPORTS_PRACTICE', a.assertionBasis = 'THIRD_PARTY_ANECDOTE',
    a.validFrom = datetime('2024-05-01T00:00:00Z'), a.validFromPrecision = 'MONTH', a.validFromBasis = 'STATED_BY_SOURCE',
    a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(g);
