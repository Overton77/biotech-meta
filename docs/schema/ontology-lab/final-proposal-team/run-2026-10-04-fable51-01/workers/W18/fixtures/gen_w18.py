"""Generate the W18 fixtures. Run: python3 gen_w18.py  (writes w18-0*.cypher and w18-90-negatives.cypher here).
Real quotes come from the retrievals listed in ../03-source-manifest.md (NEW_RETRIEVAL or INHERITED); snapshot hashes are
SYNTHETIC_FIXTURE (sha256 over the snapshot uid) because no raw bytes were hashed."""
import os
from w18lib import Fx, DT, known, shash

HERE = os.path.dirname(os.path.abspath(__file__))
RET = "2026-10-04T02:00:00Z"          # retrieval time of the research captures
R_PR = "2026-10-04T03:00:00Z"         # recorded: company releases, filings, PubMed, registry
R_RET = "2026-10-04T04:00:00Z"        # recorded: the causal retelling
R_ADJ = "2026-10-04T04:10:00Z"        # capture-fidelity review of the retelling
R_CONF = "2026-10-04T05:00:00Z"       # recorded: conference material
R_EMA = "2026-10-04T06:00:00Z"        # recorded: EMA record (late arrival relative to the viewpoint R1 = 04:30Z)

def occ_props(fx, ev, a_uid):
    pass

# =====================================================================================================
# Fixture 01: Rezdiffra milestone timeline, three clocks (company releases vs regulator records)
# =====================================================================================================
f = Fx("""// W18 fixture 01 -- Rezdiffra (resmetirom) milestone timeline: happened vs announced vs effective vs recorded.
// Real public records (see 03-source-manifest.md W18-S01..S09); snapshot hashes SYNTHETIC_FIXTURE. Load first.
// Every statement binds its own nodes by uid; no variable crosses ';'.""")

# actors and subjects
MDGL = f.node(["Organization", "Entity"], "hu:org:madrigal-pharmaceuticals", entityType="Organization", name="Madrigal Pharmaceuticals, Inc.")
FDA = f.node(["RegulatoryAgency", "Organization", "Entity"], "hu:org:us-fda", entityType="RegulatoryAgency", name="U.S. Food and Drug Administration")
EC = f.node(["RegulatoryAgency", "Organization", "Entity"], "hu:org:european-commission", entityType="RegulatoryAgency", name="European Commission")
EMA = f.node(["RegulatoryAgency", "Organization", "Entity"], "hu:org:ema", entityType="RegulatoryAgency", name="European Medicines Agency")
NLM = f.node(["Organization", "Entity"], "hu:org:us-nlm", entityType="Organization", name="U.S. National Library of Medicine (PubMed)")
PROD = f.node(["Product", "Entity"], "hu:product:rezdiffra", entityType="Product", name="REZDIFFRA (resmetirom) tablets")
SUB = f.node(["ChemicalSubstance", "Entity"], "hu:substance:resmetirom", entityType="ChemicalSubstance", name="resmetirom (MGL-3196)")
STUDY = f.node(["Study", "Entity"], "hu:study:maestro-nash", entityType="Study", name="MAESTRO-NASH (NCT03900429)")
PUB = f.node(["Publication", "InformationArtifact"], "hu:publication:pmid-38324483", artifactType="Publication",
             name="A Phase 3, Randomized, Controlled Trial of Resmetirom in NASH with Liver Fibrosis (N Engl J Med 2024)",
             publishedAt=DT("2024-02-08T00:00:00Z"))
RESP = f.node(["RegulatoryResponse", "InformationArtifact"], "hu:reg-response:us-fda-nda-217785-orig-1-approval",
              artifactType="REGULATORY_RESPONSE", responseKind="APPROVED", decisionTextVerbatim="Approval",
              issuedAt=DT("2024-03-14T00:00:00Z"), jurisdiction="US", name="NDA 217785 ORIG-1 approval (W13 record, stub)")
AG = f.node(["Agent", "Entity"], "hu:agent:w18-event-curator", entityType="Agent", name="W18 event curation agent (synthetic)", agentKind="AUTOMATED_AGENT", privacyClass="INTERNAL")

# sources -> snapshots -> locators
def chain(key, uri, title, kind, publishedAt, prec, quotes, completeness="PARTIAL_EXCERPT", section=None):
    s = f.source(f"hu:source:{key}", uri, title, kind)
    sn = f.snapshot(f"hu:snapshot:{key}-2026-10-04", s, uri, RET, publishedAt, prec, completeness=completeness)
    locs = []
    for i, q in enumerate(quotes):
        locs.append(f.locator(f"hu:locator:{key}-q{i+1}", sn, exact=q, uri=uri))
    if section:
        locs.append(f.locator(f"hu:locator:{key}-sec", sn, section=section, uri=uri))
    return locs

L_RD = chain("mdgl-pr-2022-12-19-maestro-nash-topline",
             "https://ir.madrigalpharma.com/news-releases/news-release-details/madrigal-announces-positive-topline-results-pivotal-phase-3",
             "Madrigal Announces Positive Topline Results from the Pivotal Phase 3 MAESTRO-NASH Clinical Trial", "PRESS_RELEASE",
             "2022-12-19T12:00:00Z", "INSTANT",
             ["Madrigal Pharmaceuticals, Inc. (NASDAQ:MDGL), a clinical-stage biopharmaceutical company pursuing novel therapeutics for nonalcoholic steatohepatitis (NASH), today announced positive topline results from the pivotal Phase 3 MAESTRO-NASH biopsy clinical trial of resmetirom"])
L_AP = chain("mdgl-pr-2024-03-14-fda-approval",
             "https://ir.madrigalpharma.com/news-releases/news-release-details/madrigal-pharmaceuticals-announces-fda-approval-rezdiffratm",
             "Madrigal Pharmaceuticals Announces FDA Approval of Rezdiffra (resmetirom)", "PRESS_RELEASE",
             "2024-03-14T00:00:00Z", "DAY",
             ["today announced that the U.S. Food and Drug Administration (FDA) has granted accelerated approval for Rezdiffra (resmetirom)",
              "Rezdiffra is expected to be available to patients in the U.S. in April and will be distributed through a limited specialty pharmacy network.",
              "Accelerated approval was based on Phase 3 data"])
L_DAF = chain("fda-drugsatfda-nda-217785",
              "https://www.accessdata.fda.gov/scripts/cder/daf/index.cfm?event=overview.process&ApplNo=217785",
              "Drugs@FDA NDA 217785", "REGULATORY_RECORD", None, None, [],
              section="Products on NDA 217785: REZDIFFRA (RESMETIROM) 60MG, 80MG, 100MG TABLET;ORAL; Original Approvals: 03/14/2024 ORIG-1 Approval, Type 1 - New Molecular Entity, PRIORITY")
L_8K = chain("mdgl-8k-2024-05-07-q1",
             "https://ir.madrigalpharma.com/static-files/a75d4502-858d-4188-a422-1d33abe68d55",
             "Form 8-K (Ex. 99.1) Madrigal first-quarter 2024 results", "SECURITIES_FILING",
             "2024-05-07T00:00:00Z", "DAY",
             ["In April 2024, product shipped and first patients received Rezdiffra"])
L_EC = chain("mdgl-pr-2025-08-19-ec-approval",
             "https://ir.madrigalpharma.com/news-releases/news-release-details/madrigal-receives-european-commission-approval-rezdiffratm",
             "Madrigal Receives European Commission Approval for Rezdiffra (resmetirom)", "PRESS_RELEASE",
             "2025-08-19T00:00:00Z", "DAY",
             ["today announced that the European Commission (EC) has granted conditional marketing authorization for Rezdiffra (resmetirom)",
              "Rezdiffra received conditional marketing authorization from the European Commission (EC) in August 2025."])
L_EMA = chain("ema-epar-rezdiffra", "https://www.ema.europa.eu/en/medicines/human/EPAR/rezdiffra",
              "Rezdiffra | European Medicines Agency (EMA)", "REGULATORY_RECORD", None, None,
              ["Rezdiffra received a conditional marketing authorisation valid throughout the EU on 18 August 2025."])
L_Q3 = chain("mdgl-pr-2025-11-04-q3",
             "https://ir.madrigalpharma.com/news-releases/news-release-details/madrigal-pharmaceuticals-reports-third-quarter-2025-financial",
             "Madrigal Pharmaceuticals Reports Third-Quarter 2025 Financial Results", "PRESS_RELEASE",
             "2025-11-04T00:00:00Z", "DAY",
             ["Following European Commission (EC) conditional marketing authorization in August, Madrigal launched Rezdiffra in Germany in September."])
L_PM = chain("pubmed-38324483", "https://pubmed.ncbi.nlm.nih.gov/38324483/",
             "PubMed 38324483", "TERMINOLOGY_RECORD", None, None, [],
             section="publication_date: 2024-02-08; journal: N Engl J Med; doi: 10.1056/NEJMoa2309000")
L_CT = chain("ctgov-nct03900429", "https://clinicaltrials.gov/study/NCT03900429",
             "ClinicalTrials.gov NCT03900429 (via ClinicalTrials.gov MCP, API v2)", "REGULATORY_RECORD", None, None, [],
             section="start_date: 2019-03-28; primary_completion_date: 2028-01; completion_date: 2028-01; has_results: false")

# events
def event(uid, name, cat, etype, **p):
    return f.node(["Event", "Occurrence"], uid, occurrenceType="Event", name=name, eventCategory=cat, eventType=etype, **p)

E1 = event("hu:event:maestro-nash-topline-2022-12-19", "MAESTRO-NASH positive topline results disclosed", "DATA_READOUT_EVENT", "TOPLINE_READOUT",
           startedAt=DT("2022-12-19T12:00:00Z"), startedAtPrecision="INSTANT", startedAtBasis="STATED_BY_SOURCE",
           timeAssertionUid="hu:assertion:w18-e1-occurred-mdgl", announcedAt=DT("2022-12-19T12:00:00Z"), announcedAtPrecision="INSTANT",
           announcementAssertionUid="hu:assertion:w18-e1-occurred-mdgl", eventStatus="COMPLETED", localTimeZone="America/New_York",
           summaryText="Public disclosure of Week-52 topline results; the database-lock date is not stated (unknown).")
E6 = event("hu:event:maestro-nash-nejm-publication", "MAESTRO-NASH primary report published (NEJM)", "RESEARCH_EVENT", "PUBLICATION",
           startedAt=DT("2024-02-08T00:00:00Z"), startedAtPrecision="DAY", startedAtBasis="STATED_BY_SOURCE",
           timeAssertionUid="hu:assertion:w18-e6-occurred-pubmed", eventStatus="COMPLETED")
E2 = event("hu:event:rezdiffra-us-accelerated-approval", "FDA accelerated approval of Rezdiffra (NDA 217785)", "REGULATORY_EVENT", "APPROVAL",
           jurisdiction="US", startedAt=DT("2024-03-14T00:00:00Z"), startedAtPrecision="DAY", startedAtBasis="STATED_BY_SOURCE",
           timeAssertionUid="hu:assertion:w18-e2-occurred-fda", announcedAt=DT("2024-03-14T00:00:00Z"), announcedAtPrecision="DAY",
           announcementAssertionUid="hu:assertion:w18-e2-occurred-mdgl", effectiveFrom=DT("2024-03-14T00:00:00Z"), effectiveFromPrecision="DAY",
           effectiveFromBasis="STATED_BY_SOURCE", effectiveAssertionUid="hu:assertion:w18-e2-effective-fda", eventStatus="COMPLETED")
E3 = event("hu:event:rezdiffra-us-launch", "Rezdiffra first shipments and first patients (US)", "PRODUCT_EVENT", "LAUNCH",
           jurisdiction="US", startedAt=DT("2024-04-01T00:00:00Z"), startedAtPrecision="MONTH", startedAtBasis="STATED_BY_SOURCE",
           timeAssertionUid="hu:assertion:w18-e3-occurred-8k", announcedAt=DT("2024-05-07T00:00:00Z"), announcedAtPrecision="DAY",
           announcementAssertionUid="hu:assertion:w18-e3-occurred-8k", eventStatus="COMPLETED")
E4 = event("hu:event:rezdiffra-eu-conditional-authorisation", "EU conditional marketing authorisation of Rezdiffra", "REGULATORY_EVENT", "CONDITIONAL_APPROVAL",
           jurisdiction="EU", startedAt=DT("2025-08-18T00:00:00Z"), startedAtPrecision="DAY", startedAtBasis="STATED_BY_SOURCE",
           timeAssertionUid="hu:assertion:w18-e4-occurred-ema", announcedAt=DT("2025-08-19T00:00:00Z"), announcedAtPrecision="DAY",
           announcementAssertionUid="hu:assertion:w18-e4-occurred-mdgl", effectiveFrom=DT("2025-08-18T00:00:00Z"), effectiveFromPrecision="DAY",
           effectiveFromBasis="STATED_BY_SOURCE", effectiveAssertionUid="hu:assertion:w18-e4-effective-ema", eventStatus="COMPLETED")
E5 = event("hu:event:rezdiffra-germany-launch", "Rezdiffra launch in Germany", "PRODUCT_EVENT", "LAUNCH",
           jurisdiction="DE", startedAt=DT("2025-09-01T00:00:00Z"), startedAtPrecision="MONTH", startedAtBasis="STATED_BY_SOURCE",
           timeAssertionUid="hu:assertion:w18-e5-occurred-mdgl", announcedAt=DT("2025-11-04T00:00:00Z"), announcedAtPrecision="DAY",
           announcementAssertionUid="hu:assertion:w18-e5-occurred-mdgl", eventStatus="COMPLETED")

# time assertions (EVENT_OCCURRED / EVENT_SCHEDULED / EVENT_EFFECTIVE)
def tA(uid, pred, ev, asserter, locs, rec, vf, prec, basis="STATED_BY_SOURCE", tense="PAST", **p):
    return f.assertion(uid, pred, ev, asserter=asserter, locators=locs, recordedAt=rec, validFrom=DT(vf) if vf else None,
                       validFromPrecision=prec if vf else None, validFromBasis=basis if vf else None,
                       predicateClass="OTHER", polarity="POSITIVE", speechAct="STATES", statedTense=tense, **p)

tA("hu:assertion:w18-e1-occurred-mdgl", "EVENT_OCCURRED", E1, MDGL, L_RD, R_PR, "2022-12-19T12:00:00Z", "INSTANT", tense="PRESENT", assertionBasis="MANUFACTURER_CLAIM")
tA("hu:assertion:w18-e6-occurred-pubmed", "EVENT_OCCURRED", E6, NLM, L_PM, R_PR, "2024-02-08T00:00:00Z", "DAY")
tA("hu:assertion:w18-e2-occurred-fda", "EVENT_OCCURRED", E2, FDA, L_DAF, R_PR, "2024-03-14T00:00:00Z", "DAY")
tA("hu:assertion:w18-e2-occurred-mdgl", "EVENT_OCCURRED", E2, MDGL, L_AP[:1], R_PR, "2024-03-14T00:00:00Z", "DAY", basis="PUBLICATION_PROXY", tense="PRESENT", assertionBasis="MANUFACTURER_CLAIM")
tA("hu:assertion:w18-e2-effective-fda", "EVENT_EFFECTIVE", E2, FDA, L_DAF, R_PR, "2024-03-14T00:00:00Z", "DAY")
tA("hu:assertion:w18-e3-scheduled-mdgl", "EVENT_SCHEDULED", E3, MDGL, [L_AP[1]], R_PR, "2024-04-01T00:00:00Z", "MONTH", tense="FUTURE", assertionBasis="MANUFACTURER_CLAIM")
tA("hu:assertion:w18-e3-occurred-8k", "EVENT_OCCURRED", E3, MDGL, L_8K, R_PR, "2024-04-01T00:00:00Z", "MONTH", assertionBasis="MANUFACTURER_CLAIM")
tA("hu:assertion:w18-e4-occurred-mdgl", "EVENT_OCCURRED", E4, MDGL, L_EC, R_PR, "2025-08-01T00:00:00Z", "MONTH", tense="PAST", assertionBasis="MANUFACTURER_CLAIM")
tA("hu:assertion:w18-e4-occurred-ema", "EVENT_OCCURRED", E4, EMA, L_EMA, R_EMA, "2025-08-18T00:00:00Z", "DAY")
tA("hu:assertion:w18-e4-effective-ema", "EVENT_EFFECTIVE", E4, EMA, L_EMA, R_EMA, "2025-08-18T00:00:00Z", "DAY")
tA("hu:assertion:w18-e5-occurred-mdgl", "EVENT_OCCURRED", E5, MDGL, L_Q3, R_PR, "2025-09-01T00:00:00Z", "MONTH", assertionBasis="MANUFACTURER_CLAIM")

# EVENT_ABOUT, INVOLVES, DOCUMENTED_BY_RECORD as projections of one assertion each
n = [0]
def proj(pred, ev, obj, asserter, locs, rec, edge_type=None, **edge_extra):
    n[0] += 1
    a = f.assertion(f"hu:assertion:w18-{pred.lower().replace('_','-')}-{n[0]:02d}", pred, ev, obj=obj, asserter=asserter,
                    locators=locs, recordedAt=rec, predicateClass="OTHER", polarity="POSITIVE", speechAct="STATES")
    f.asserted_edge(ev, edge_type or pred, obj, a, rec, f"hu:rel:w18-{pred.lower().replace('_','-')}-{n[0]:02d}", **edge_extra)
    return a

proj("EVENT_ABOUT", E1, STUDY, MDGL, L_RD, R_PR)
proj("EVENT_ABOUT", E1, SUB, MDGL, L_RD, R_PR)
proj("INVOLVES", E1, MDGL, MDGL, L_RD, R_PR, participantRole="ANNOUNCER")
proj("EVENT_ABOUT", E6, STUDY, NLM, L_PM, R_PR)
proj("EVENT_ABOUT", E2, PROD, MDGL, L_AP[:1], R_PR)
proj("INVOLVES", E2, FDA, MDGL, L_AP[:1], R_PR, participantRole="DECISION_MAKER")
proj("INVOLVES", E2, MDGL, MDGL, L_AP[:1], R_PR, participantRole="APPLICANT")
proj("EVENT_ABOUT", E3, PROD, MDGL, L_8K, R_PR)
proj("EVENT_ABOUT", E4, PROD, MDGL, L_EC[:1], R_PR)
proj("INVOLVES", E4, EC, MDGL, L_EC[:1], R_PR, participantRole="DECISION_MAKER", roleTitleVerbatim="European Commission (EC)")
proj("EVENT_ABOUT", E5, PROD, MDGL, L_Q3, R_PR)

# DOCUMENTED_BY_RECORD: BellLabs resolution (CALCULATED from the record assertion)
for ev, rec_uid, inp, k in [(E2, RESP, "hu:assertion:w18-e2-occurred-fda", "e2"), (E6, PUB, "hu:assertion:w18-e6-occurred-pubmed", "e6")]:
    a = f.assertion(f"hu:assertion:w18-{k}-documented-by-record", "DOCUMENTED_BY_RECORD", ev, obj=rec_uid, asserter=AG,
                    recordedAt=R_PR, predicateClass="OTHER", polarity="POSITIVE", speechAct="STATES", basisKind="CALCULATED",
                    derivationRule="event-record-match-v1 (same subject, same jurisdiction, same day, record kind APPROVED/ARTICLE)")
    f.edge(a, "DERIVED_FROM_ASSERTION", inp)
    f.asserted_edge(ev, "DOCUMENTED_BY_RECORD", rec_uid, a, R_PR, f"hu:rel:w18-{k}-documented-by-record")

# FOLLOWED_BY derived by rule valid-time-order-v1 from the two time assertions
def fol(a, b, ta, tb, k):
    f.edge(a, "FOLLOWED_BY", b, derivationRule="valid-time-order-v1", derivedFromAssertionUids=[ta, tb], derivedAt=DT(R_EMA))
fol(E1, E6, "hu:assertion:w18-e1-occurred-mdgl", "hu:assertion:w18-e6-occurred-pubmed", 1)
fol(E6, E2, "hu:assertion:w18-e6-occurred-pubmed", "hu:assertion:w18-e2-occurred-fda", 2)
fol(E2, E3, "hu:assertion:w18-e2-occurred-fda", "hu:assertion:w18-e3-occurred-8k", 3)
fol(E3, E4, "hu:assertion:w18-e3-occurred-8k", "hu:assertion:w18-e4-occurred-ema", 4)
fol(E4, E5, "hu:assertion:w18-e4-occurred-ema", "hu:assertion:w18-e5-occurred-mdgl", 5)

# REPORTED_IN derived from the locator support of the time assertions (one per event/source)
def rep(ev, src, a_uid, loc):
    f.edge(ev, "REPORTED_IN", src, derivationRule="reported-in-via-locator-v1", derivedFromAssertionUids=[a_uid], locatorUid=loc, derivedAt=DT(R_EMA))
rep(E1, "hu:source:mdgl-pr-2022-12-19-maestro-nash-topline", "hu:assertion:w18-e1-occurred-mdgl", L_RD[0])
rep(E2, "hu:source:fda-drugsatfda-nda-217785", "hu:assertion:w18-e2-occurred-fda", L_DAF[0])
rep(E2, "hu:source:mdgl-pr-2024-03-14-fda-approval", "hu:assertion:w18-e2-occurred-mdgl", L_AP[0])
rep(E3, "hu:source:mdgl-8k-2024-05-07-q1", "hu:assertion:w18-e3-occurred-8k", L_8K[0])
rep(E4, "hu:source:ema-epar-rezdiffra", "hu:assertion:w18-e4-occurred-ema", L_EMA[0])
rep(E4, "hu:source:mdgl-pr-2025-08-19-ec-approval", "hu:assertion:w18-e4-occurred-mdgl", L_EC[1])
n01 = f.write(os.path.join(HERE, "w18-01-rezdiffra-milestone-clocks.cypher"))
F1_LABELS = dict(f.labels)

# =====================================================================================================
# Fixture 02: a data readout whose later retelling asserts causation (and contradicts itself)
# =====================================================================================================
g = Fx("""// W18 fixture 02 -- MAESTRO-NASH readout retold by a syndicated market article (Entrepreneur.com, originally MarketBeat)
// that asserts three causal links and one temporal order. Load after fixture 01. Snapshot hash SYNTHETIC_FIXTURE.""")
known(g, F1_LABELS)
VKTX = g.node(["Organization", "Entity"], "hu:org:viking-therapeutics", entityType="Organization", name="Viking Therapeutics, Inc.")
MB = g.node(["Organization", "Entity"], "hu:org:marketbeat", entityType="Organization", name="MarketBeat (publisher of record per the syndication note)")
URI = "https://www.entrepreneur.com/finance/why-did-viking-therapeutics-stock-skyrocket/441593"
s = g.source("hu:source:entrepreneur-441593", URI, "Why Did Viking Therapeutics Stock Skyrocket", "NEWSLETTER")
sn = g.snapshot("hu:snapshot:entrepreneur-441593-2026-10-04", s, URI, RET, None, None)
Q = {
 "c1": "Madrigal’s remarkable NASH results sent their stock soaring (up more than 231% at the time of this writing).",
 "c2": "Recently, their stock soared for a somewhat unique reason: the success of a peer.",
 "c3": "This time, Viking’s successful NASH trial led to Madrigal share value also taking a big step forward in the following days.",
 "o1": "In the middle of December, Viking Therapeutics saw its stock jump after Madrigal Pharmaceuticals released its successful Phase 3 MAESTRO-NASH biopsy trial of Resmetirom.",
 "m1": "Overall, MDGL leaped up by about 268.07% while VKTX jumped 74%.",
 "v1": "At one point, the stock peaked at $8.25 (on December 19, 2022) before settling back to its current value, which is $6.05.",
}
L = {k: g.locator(f"hu:locator:entrepreneur-441593-{k}", sn, exact=v, uri=URI) for k, v in Q.items()}
E7 = g.node(["Event", "Occurrence"], "hu:event:mdgl-share-rise-2022-12", occurrenceType="Event", name="MDGL share price rise (December 2022)",
            eventCategory="MARKET_EVENT", eventType="SHARE_PRICE_MOVE", startedAt=DT("2022-12-01T00:00:00Z"), startedAtPrecision="MONTH",
            startedAtBasis="INFERRED", timeAssertionUid="hu:assertion:w18-e7-occurred-mb", eventStatus="COMPLETED")
E8 = g.node(["Event", "Occurrence"], "hu:event:vktx-share-rise-2022-12", occurrenceType="Event", name="VKTX share price jump (mid-December 2022)",
            eventCategory="MARKET_EVENT", eventType="SHARE_PRICE_MOVE", startedAt=DT("2022-12-19T00:00:00Z"), startedAtPrecision="DAY",
            startedAtBasis="STATED_BY_SOURCE", timeAssertionUid="hu:assertion:w18-e8-occurred-mb", eventStatus="COMPLETED")
E9 = g.node(["Event", "Occurrence"], "hu:event:viking-nash-trial-result-unspecified", occurrenceType="Event",
            name="Viking 'successful NASH trial' (unspecified in the retelling)", eventCategory="DATA_READOUT_EVENT", eventType="TOPLINE_READOUT",
            startedAtBasis="UNKNOWN", timeAssertionUid="hu:assertion:w18-e9-occurred-mb", eventStatus="UNKNOWN",
            summaryText="Which trial and when are not stated; time unknown (null), not inferred.")
def gA(uid, pred, subj, obj, loc, status="ACCEPTED", **p):
    return g.assertion(uid, pred, subj, obj=obj, asserter=MB, locators=[loc], recordedAt=R_RET, status=status,
                       predicateClass="OTHER", polarity="POSITIVE", **p)
gA("hu:assertion:w18-e7-occurred-mb", "EVENT_OCCURRED", E7, None, L["m1"], speechAct="STATES",
   validFrom=DT("2022-12-01T00:00:00Z"), validFromPrecision="MONTH", validFromBasis="INFERRED")
gA("hu:assertion:w18-e8-occurred-mb", "EVENT_OCCURRED", E8, None, L["v1"], speechAct="STATES",
   validFrom=DT("2022-12-19T00:00:00Z"), validFromPrecision="DAY", validFromBasis="STATED_BY_SOURCE")
gA("hu:assertion:w18-e9-occurred-mb", "EVENT_OCCURRED", E9, None, L["c3"], speechAct="STATES")
C1 = gA("hu:assertion:w18-c1-mdgl-rise-caused-by-readout", "CAUSED_BY", E7, "hu:event:maestro-nash-topline-2022-12-19", L["c1"],
        speechAct="STATES", basisKind="INFERRED_FROM_MEASUREMENT", assertionBasis="UNSTATED")
C2 = gA("hu:assertion:w18-c2-vktx-rise-caused-by-readout", "CAUSED_BY", E8, "hu:event:maestro-nash-topline-2022-12-19", L["c2"],
        speechAct="STATES", basisKind="INFERRED_FROM_MEASUREMENT", assertionBasis="UNSTATED")
C3 = gA("hu:assertion:w18-c3-mdgl-rise-caused-by-viking-trial", "CAUSED_BY", E7, E9, L["c3"],
        speechAct="SPECULATES", basisKind="HYPOTHESIS", assertionBasis="UNSTATED")
O1 = gA("hu:assertion:w18-o1-readout-followed-by-vktx-rise", "FOLLOWED_BY", "hu:event:maestro-nash-topline-2022-12-19", E8, L["o1"], speechAct="STATES")
for a_uid, eff, cause, k, bk, sa in [(C1, E7, "hu:event:maestro-nash-topline-2022-12-19", "c1", "INFERRED_FROM_MEASUREMENT", "STATES"),
                                     (C2, E8, "hu:event:maestro-nash-topline-2022-12-19", "c2", "INFERRED_FROM_MEASUREMENT", "STATES"),
                                     (C3, E7, E9, "c3", "HYPOTHESIS", "SPECULATES")]:
    g.asserted_edge(eff, "CAUSED_BY", cause, a_uid, R_RET, f"hu:rel:w18-caused-by-{k}", basisKind=bk, assertionBasis="UNSTATED", speechAct=sa)
g.edge("hu:event:maestro-nash-topline-2022-12-19", "FOLLOWED_BY", E8, projectionOfAssertionUid=O1, derivedAt=DT(R_RET))
g.node(["Adjudication", "EvidenceAssessment"], "hu:adjudication:w18-retelling-capture", assessmentType="Adjudication",
       methodVersion="capture-review-v1", status="ACCEPTED", recordedAt=DT(R_ADJ), adjudicationKind="CAPTURE_FIDELITY",
       verdict="SUPPORTED", reviewerType="HUMAN", reviewedAt=DT(R_ADJ), rationale="Quotes match the captured article text; no SUPPORT review of the causal propositions.", privacyClass="INTERNAL")
for a_uid in ["hu:assertion:w18-e7-occurred-mb", "hu:assertion:w18-e8-occurred-mb", "hu:assertion:w18-e9-occurred-mb", C1, C2, C3, O1]:
    g.edge("hu:adjudication:w18-retelling-capture", "EVALUATES", a_uid)
# two method-versioned impact judgments of the same readout for different subjects (synthetic judgments)
ACT = g.node(["Activity", "Occurrence"], "hu:activity:w18-impact-assessment-1", occurrenceType="Activity", activityKind="ADJUDICATION",
             methodVersion="event-impact-market-v0", startedAt=DT("2026-10-04T04:20:00Z"), privacyClass="INTERNAL")
for k, subj, lvl, loc in [("mdgl", MDGL_ := "hu:org:madrigal-pharmaceuticals", "HIGH", L["m1"]), ("vktx", VKTX, "MODERATE", L["m1"])]:
    ia = g.node(["EventImpactAssessment", "EvidenceAssessment"], f"hu:event-impact:w18-readout-{k}", assessmentType="EVENT_IMPACT",
                methodVersion="event-impact-market-v0", status="PROPOSED", recordedAt=DT("2026-10-04T04:20:00Z"), impactLevel=lvl,
                impactDomain="MARKET", summary=f"Synthetic judgment for the fixture: market impact of the readout for {k.upper()}; cites the retelling's reported move, not its causal claim.")
    g.edge(ia, "ASSESSES_EVENT", "hu:event:maestro-nash-topline-2022-12-19")
    g.edge(ia, "IMPACT_ON", subj)
    g.edge(ia, "SUPPORTED_BY", loc)
    g.edge(ia, "WAS_GENERATED_BY", ACT)
n02 = g.write(os.path.join(HERE, "w18-02-readout-causal-retelling.cypher"))
F2_LABELS = dict(g.labels)

# =====================================================================================================
# Fixture 03: conference editions, sessions, recordings, decks, sponsorship vs endorsement
# =====================================================================================================
h = Fx("""// W18 fixture 03 -- JPM Healthcare Conference 2026 sessions (Madrigal: recording + deck; Merck: recording no longer available,
// transcript + deck, speakers) and AASLD The Liver Meeting 2026 (host, Madrigal-supported award = SPONSORS_CONTENT, no
// endorsement). Load after fixture 01. Merck quotes are INHERITED from workers/W21/excerpts.""")
known(h, F1_LABELS)
MERCK = h.node(["Organization", "Entity"], "hu:org:merck-and-co", entityType="Organization", name="Merck & Co., Inc.")
AASLD = h.node(["Organization", "Entity"], "hu:org:aasld", entityType="Organization", name="American Association for the Study of Liver Diseases (AASLD)")
BBS = h.node(["Organization", "Entity"], "hu:org:bass-berry-sims", entityType="Organization", name="Bass, Berry & Sims PLC")
DAVIS = h.node(["Person", "Entity"], "hu:person:robert-davis-merck", entityType="Person", name="Robert Davis")
SCHOTT = h.node(["Person", "Entity"], "hu:person:christopher-schott-jpm", entityType="Person", name="Christopher Schott")
JPM = h.node(["Conference", "Entity"], "hu:conference:jpm-healthcare-2026", entityType="Conference", name="44th Annual J.P. Morgan Healthcare Conference",
             conferenceType="INVESTOR_CONFERENCE", seriesName="J.P. Morgan Healthcare Conference", editionLabel="44th Annual",
             timeZone="America/Los_Angeles", location="San Francisco, Westin St. Francis Hotel (third-party listing)", attendanceMode="IN_PERSON")
h.stmt("MATCH (c:Conference {uid: 'hu:conference:jpm-healthcare-2026'}) SET c.startDate = date('2026-01-12'), c.endDate = date('2026-01-15')")
TLM = h.node(["Conference", "Entity"], "hu:conference:aasld-tlm-2026", entityType="Conference", name="The Liver Meeting 2026",
             conferenceType="SCIENTIFIC_CONGRESS", seriesName="The Liver Meeting", editionLabel="TLM 2026", timeZone="America/Denver",
             location="Denver, CO (Colorado Convention Center)", attendanceMode="IN_PERSON", websiteUrl="https://www.aasld.org/tlm-26/home")
h.stmt("MATCH (c:Conference {uid: 'hu:conference:aasld-tlm-2026'}) SET c.startDate = date('2026-11-05'), c.endDate = date('2026-11-09')")
GUIDE = h.node(["Publication", "InformationArtifact"], "hu:publication:pmid-39422487", artifactType="Publication",
               name="Resmetirom therapy for MASLD: October 2024 updates to AASLD Practice Guidance (Hepatology 2025;81:312-320)",
               publishedAt=DT("2024-10-18T00:00:00Z"))

def chain2(key, uri, title, kind, publishedAt, prec, quotes, labels=("Source", "Entity")):
    s = h.source(f"hu:source:{key}", uri, title, kind, labels=labels)
    sn = h.snapshot(f"hu:snapshot:{key}-2026-10-04", s, uri, RET, publishedAt, prec)
    return [h.locator(f"hu:locator:{key}-q{i+1}", sn, exact=q, uri=uri) for i, q in enumerate(quotes)]

L_JPMPR = chain2("mdgl-pr-2025-12-15-jpm", "https://ir.madrigalpharma.com/news-releases/news-release-details/madrigal-pharmaceuticals-present-44th-annual-jp-morgan",
                 "Madrigal Pharmaceuticals to Present at the 44th Annual J.P. Morgan Healthcare Conference", "PRESS_RELEASE", "2025-12-15T00:00:00Z", "DAY",
                 ["today announced that the company will participate in the J.P. Morgan Annual Healthcare Conference on Monday, January 12, 2026 at 1:30pm PST."])
L_IR = chain2("mdgl-ir-events", "https://ir.madrigalpharma.com/events-and-presentations", "Events and Presentations | Madrigal Pharmaceuticals, Inc.",
              "ORGANIZATION_WEBPAGE", None, None, ["Jan 12, 2026 4:30 PM EST\n44th Annual J.P. Morgan Healthcare Conference\nListen to webcast 19.8 MB\nPresentation 1.2 MB"])
L_BBS = chain2("bassberry-jpm-2026", "https://bassberry.com/events/bbs-connect-at-44th-annual-j-p-morgan-healthcare-conference", "BBS Connect at 44th Annual J.P. Morgan Healthcare Conference",
               "THIRD_PARTY_DIRECTORY", None, None, ["The J.P. Morgan Healthcare Conference will be held January 12-15, 2026, at the Westin St. Francis Hotel in San Francisco, California."])
L_MEV = chain2("merck-jpm-2026-event-page", "https://www.merck.com/investor-relations/events-and-presentations/ (W21 excerpt merck-event-page-2026-10-04.txt)",
               "Merck event page: 44th Annual J.P. Morgan Healthcare Conference", "ORGANIZATION_WEBPAGE", None, None,
               ["44th Annual J.P. Morgan Healthcare Conference\nJanuary 12, 2026 4:30 pm PST",
                "Presentation https://s21.q4cdn.com/488056881/files/doc_events/2026/Jan/12/MRK-2026-JP-Morgan-Presentation.pdf",
                "Webcast https://jpmorgan.metameetings.net/events/healthcare26/sessions/317179-merck-co-inc/webcast?gpu_only=true&kiosk=true"])
L_MTR = chain2("merck-jpm-2026-transcript", "https://s21.q4cdn.com/488056881/files/doc_events/2026/Jan/12/MRK-USQ_Transcript_2026-01-12.pdf",
               "Merck JPM 2026 transcript (PDF)", "PODCAST_TRANSCRIPT_PAGE", None, None,
               ["Robert Davis Merck & Co Inc - Chairman of the Board, President, Chief Executive Officer",
                "Christopher Schott - JPMorgan Chase & Co - Analyst Good afternoon, everybody. I'm Chris Schott at JPMorgan. It's my pleasure to be introducing Merck today."])
L_MWC = chain2("merck-jpm-2026-webcast", "https://jpmorgan.metameetings.net/events/healthcare26/sessions/317179-merck-co-inc/webcast?gpu_only=true&kiosk=true",
               "JPM 2026 webcast page, Merck & Co., Inc.", "VIDEO_RENDITION", None, None, ["The recording of this session is not available any more."])
L_AAS = chain2("aasld-pald-award-2026-07-13", "https://www.aasld.org/aasld-unveils-new-people-affected-liver-disease-travel-award-program-liver-meetingr-2026-denver",
               "AASLD Unveils New People Affected by Liver Disease Travel Award for The Liver Meeting 2026, Denver", "PRESS_RELEASE", "2026-07-13T00:00:00Z", "DAY",
               ["The American Association for the Study of Liver Diseases (AASLD) proudly announces the new People Affected by Liver Disease (PALD) Travel Award for The Liver Meeting® (TLM), Nov. 5-9, 2026 in Denver, CO, made possible through the support of Madrigal Pharmaceuticals.",
                "The People Affected by Liver Disease Travel Award at TLM 2026 will remove financial barriers that prevent people from attending AASLD’s premier global conference in hepatology"])
# documents (decks) and episodes (recordings, W21 works)
DECK_M = h.node(["Document", "Source", "Entity"], "hu:document:madrigal-jpm-2026-deck", entityType="Source", documentId="madrigal-jpm-2026-deck",
                title="Madrigal 44th Annual J.P. Morgan Healthcare Conference presentation (1.2 MB)", type="INVESTOR_PRESENTATION",
                canonicalUri="https://ir.madrigalpharma.com/events-and-presentations#jpm-2026-presentation", sourceKind="ORGANIZATION_WEBPAGE")
DECK_K = h.node(["Document", "Source", "Entity"], "hu:document:merck-jpm-2026-deck", entityType="Source", documentId="merck-jpm-2026-deck",
                title="MRK-2026-JP-Morgan-Presentation.pdf", type="INVESTOR_PRESENTATION",
                canonicalUri="https://s21.q4cdn.com/488056881/files/doc_events/2026/Jan/12/MRK-2026-JP-Morgan-Presentation.pdf", sourceKind="ORGANIZATION_WEBPAGE")
EP_M = h.node(["Episode", "Entity"], "hu:episode:madrigal-jpm-2026-webcast", entityType="Episode", episodeType="CONFERENCE_TALK", name="Madrigal at the 44th Annual J.P. Morgan Healthcare Conference (webcast)")
EP_K = h.node(["Episode", "Entity"], "hu:episode:merck-jpm-2026-webcast", entityType="Episode", episodeType="CONFERENCE_TALK", name="Merck at the 44th Annual J.P. Morgan Healthcare Conference (webcast)")
h.edge("hu:source:merck-jpm-2026-webcast", "RENDITION_OF", EP_K)
h.edge("hu:source:merck-jpm-2026-transcript", "RENDITION_OF", EP_K)
# sessions
E10 = h.node(["Event", "Occurrence"], "hu:event:madrigal-jpm-2026-presentation", occurrenceType="Event", name="Madrigal presentation, 44th Annual J.P. Morgan Healthcare Conference",
             eventCategory="CONFERENCE_EVENT", eventType="PRESENTATION", startedAt=DT("2026-01-12T21:30:00Z"), startedAtPrecision="INSTANT", startedAtBasis="STATED_BY_SOURCE",
             timeAssertionUid="hu:assertion:w18-e10-occurred-ir", announcedAt=DT("2025-12-15T00:00:00Z"), announcedAtPrecision="DAY",
             announcementAssertionUid="hu:assertion:w18-e10-scheduled-pr", localTimeZone="America/Los_Angeles", eventStatus="COMPLETED")
E11 = h.node(["Event", "Occurrence"], "hu:event:merck-jpm-2026-presentation", occurrenceType="Event", name="Merck presentation, 44th Annual J.P. Morgan Healthcare Conference",
             eventCategory="CONFERENCE_EVENT", eventType="PRESENTATION", startedAt=DT("2026-01-13T00:30:00Z"), startedAtPrecision="INSTANT", startedAtBasis="STATED_BY_SOURCE",
             timeAssertionUid="hu:assertion:w18-e11-occurred-merck", localTimeZone="America/Los_Angeles", eventStatus="COMPLETED")
h.edge(JPM, "HAS_EVENT", E10, orderIndex=1)
h.edge(JPM, "HAS_EVENT", E11, orderIndex=2)
def hA(uid, pred, subj, obj, asserter, locs, rec=R_CONF, **p):
    return h.assertion(uid, pred, subj, obj=obj, asserter=asserter, locators=locs, recordedAt=rec, predicateClass="OTHER", polarity="POSITIVE", speechAct="STATES", **p)
hA("hu:assertion:w18-e10-scheduled-pr", "EVENT_SCHEDULED", E10, None, MDGL, L_JPMPR, validFrom=DT("2026-01-12T21:30:00Z"), validFromPrecision="INSTANT", validFromBasis="STATED_BY_SOURCE", statedTense="FUTURE")
hA("hu:assertion:w18-e10-occurred-ir", "EVENT_OCCURRED", E10, None, MDGL, L_IR, validFrom=DT("2026-01-12T21:30:00Z"), validFromPrecision="INSTANT", validFromBasis="STATED_BY_SOURCE", statedTense="PAST")
hA("hu:assertion:w18-e11-occurred-merck", "EVENT_OCCURRED", E11, None, MERCK, L_MEV[:1], validFrom=DT("2026-01-13T00:30:00Z"), validFromPrecision="INSTANT", validFromBasis="STATED_BY_SOURCE")
k = [0]
def hP(pred, a, b, asserter, locs, typ=None, **edge):
    k[0] += 1
    au = hA(f"hu:assertion:w18-f03-{pred.lower().replace('_','-')}-{k[0]:02d}", pred, a, b, asserter, locs,
            roleTitleVerbatim=edge.get("roleTitleVerbatim"))
    h.asserted_edge(a, typ or pred, b, au, R_CONF, f"hu:rel:w18-f03-{pred.lower().replace('_','-')}-{k[0]:02d}", **edge)
    return au
hP("INVOLVES", E10, MDGL, MDGL, L_JPMPR, participantRole="PRESENTER")
hP("RECORDING_OF", EP_M, E10, MDGL, L_IR, recordingCoverage="UNKNOWN")
hP("PRESENTED_AT", DECK_M, E10, MDGL, L_IR)
hP("INVOLVES", E11, MERCK, MERCK, L_MEV[:1], participantRole="PRESENTER")
hP("SPEAKS_AT", DAVIS, E11, MERCK, L_MTR[:1], participantRole="PRESENTER", roleTitleVerbatim="Chairman of the Board, President, Chief Executive Officer")
hP("SPEAKS_AT", SCHOTT, E11, MERCK, L_MTR[1:], participantRole="MODERATOR", roleTitleVerbatim="Analyst")
hP("RECORDING_OF", EP_K, E11, MERCK, L_MEV[2:], recordingCoverage="UNKNOWN")
hP("PRESENTED_AT", DECK_K, E11, MERCK, L_MEV[1:2])
hP("HOSTS_EVENT", AASLD, TLM, AASLD, L_AAS[1:])
SP = hP("SPONSORS_CONTENT", MDGL, TLM, AASLD, L_AAS[:1], roleTitleVerbatim="made possible through the support of")
# synthetic: exhibitor, public attendee, community-hosted webinar (shape only)
XO = h.node(["Organization", "Entity"], "hu:org:w18-synthetic-exhibitor", entityType="Organization", name="Synthetic Diagnostics Exhibitor Inc.")
XP = h.node(["Person", "Entity"], "hu:person:w18-synthetic-public-analyst", entityType="Person", name="Synthetic public analyst")
COMM = h.node(["Community", "Entity"], "hu:community:w18-synthetic-mash-forum", entityType="Community", name="Synthetic MASH patient forum", communityType="PATIENT_COMMUNITY")
L_SYN = chain2("w18-synthetic-listing", "https://w18-synthetic.example.invalid/listing", "Synthetic exhibitor/attendee/webinar listing", "ORGANIZATION_WEBPAGE", "2026-09-01T00:00:00Z", "DAY",
               ["Synthetic Diagnostics Exhibitor Inc. will exhibit at The Liver Meeting 2026, booth 999.",
                "Synthetic public analyst confirmed attendance at the 44th Annual J.P. Morgan Healthcare Conference.",
                "The Synthetic MASH patient forum hosts a webinar on 2026-09-15."])
E12 = h.node(["Event", "Occurrence"], "hu:event:w18-synthetic-community-webinar", occurrenceType="Event", name="Synthetic community webinar", eventCategory="MEDIA_EVENT",
             eventType="PRESENTATION", startedAt=DT("2026-09-15T00:00:00Z"), startedAtPrecision="DAY", startedAtBasis="STATED_BY_SOURCE",
             timeAssertionUid="hu:assertion:w18-e12-scheduled", eventStatus="PLANNED")
hA("hu:assertion:w18-e12-scheduled", "EVENT_SCHEDULED", E12, None, None, L_SYN[2:], validFrom=DT("2026-09-15T00:00:00Z"), validFromPrecision="DAY", validFromBasis="STATED_BY_SOURCE", statedTense="FUTURE")
hP("EXHIBITS_AT", XO, TLM, XO, L_SYN[:1], participantRole="EXHIBITOR", roleTitleVerbatim="booth 999")
hP("ATTENDS", XP, JPM, XP, L_SYN[1:2], participantRole="ATTENDEE")
hP("HOSTS_EVENT", COMM, E12, None, L_SYN[2:])
n03 = h.write(os.path.join(HERE, "w18-03-conference-sessions-sponsorship.cypher"))
F3_LABELS = dict(h.labels)

# =====================================================================================================
# Fixture 04: narrative arc (interpretation; cites events; is never a source) with a superseding revision
# =====================================================================================================
a = Fx("""// W18 fixture 04 -- NarrativeArc as an EvidenceAssessment: v1 selected at recorded viewpoint 04:30Z (before the EMA record
// arrived), v2 at 06:30Z adds the EU events and SUPERSEDES v1. Neither is SUPPORTED_BY anything nor cited by anything.
// Load after fixtures 01 and 02.""")
known(a, F1_LABELS); known(a, F2_LABELS)
CUR = a.node(["Agent", "Entity"], "hu:agent:w18-arc-curator", entityType="Agent", name="W18 arc curator (synthetic)", agentKind="MANUAL_AGENT", privacyClass="INTERNAL")
for v, rec, asof, rto, status, evs, pend, pendp in [
    (1, "2026-10-04T04:45:00Z", "2026-10-04T04:30:00Z", "2026-10-04T07:00:00Z", "SUPERSEDED",
     ["hu:event:maestro-nash-topline-2022-12-19", "hu:event:maestro-nash-nejm-publication", "hu:event:rezdiffra-us-accelerated-approval", "hu:event:rezdiffra-us-launch"],
     "2024-04-01T00:00:00Z", "MONTH"),
    (2, "2026-10-04T07:00:00Z", "2026-10-04T06:30:00Z", None, "ACCEPTED",
     ["hu:event:maestro-nash-topline-2022-12-19", "hu:event:maestro-nash-nejm-publication", "hu:event:rezdiffra-us-accelerated-approval",
      "hu:event:rezdiffra-us-launch", "hu:event:rezdiffra-eu-conditional-authorisation", "hu:event:rezdiffra-germany-launch"],
     "2025-09-01T00:00:00Z", "MONTH")]:
    act = a.node(["Activity", "Occurrence"], f"hu:activity:w18-arc-curation-v{v}", occurrenceType="Activity", activityKind="CURATION",
                 methodVersion="arc-curation-v0.1", startedAt=DT(rec), privacyClass="INTERNAL")
    a.edge(act, "WAS_ASSOCIATED_WITH", CUR)
    arc = a.node(["NarrativeArc", "EvidenceAssessment"], f"hu:narrative-arc:rezdiffra-path-v{v}", assessmentType="NARRATIVE_ARC",
                 methodVersion="arc-curation-v0.1", status=status, recordedAt=DT(rec), recordedTo=DT(rto) if rto else None,
                 eventsRecordedAsOf=DT(asof), arcType="COMPANY_MILESTONE_PATH", name="Resmetirom: from topline readout to first approved MASH therapy",
                 themeSummary="Curated sequence; order is narrative, not causal.", periodStart=DT("2022-12-19T12:00:00Z"), periodStartPrecision="INSTANT",
                 periodEnd=DT(pend), periodEndPrecision=pendp, privacyClass="PUBLIC")
    a.edge(arc, "WAS_GENERATED_BY", act)
    a.edge(arc, "ARC_ABOUT", "hu:product:rezdiffra")
    for i, e in enumerate(evs):
        a.edge(arc, "ARC_INCLUDES_EVENT", e, orderIndex=i + 1)
a.edge("hu:narrative-arc:rezdiffra-path-v2", "SUPERSEDES", "hu:narrative-arc:rezdiffra-path-v1", supersessionKind="RE_REVIEW", recordedAt=DT("2026-10-04T07:00:00Z"))
n04 = a.write(os.path.join(HERE, "w18-04-narrative-arc.cypher"))

# =====================================================================================================
# Fixture 90: negatives (load after 01-04; each must be reported by the named check)
# =====================================================================================================
x = Fx("""// W18 fixture 90 -- negative cases. Load after 01..04. Expected violations are listed per case in 06-fixtures-and-queries.md.""")
known(x, F1_LABELS); known(x, F2_LABELS); known(x, F3_LABELS)
known(x, {"hu:narrative-arc:rezdiffra-path-v2": "NarrativeArc"})
RD = "hu:event:maestro-nash-topline-2022-12-19"
# N1 CAUSED_BY from bare temporal order: no assertion, derivation rule only
x.edge("hu:event:rezdiffra-germany-launch", "CAUSED_BY", "hu:event:rezdiffra-eu-conditional-authorisation",
       relationshipUid="hu:rel:w18-n1", derivationRule="temporal-order-v1", recordedFrom=DT("2026-10-04T08:00:00Z"), validFromBasis="UNKNOWN", validToBasis="UNKNOWN", basisKind="CALCULATED")
# N2 CAUSED_BY citing the source-stated FOLLOWED_BY assertion (order used as cause premise)
x.edge("hu:event:vktx-share-rise-2022-12", "CAUSED_BY", RD, relationshipUid="hu:rel:w18-n2", assertionUid="hu:assertion:w18-o1-readout-followed-by-vktx-rise",
       recordedFrom=DT("2026-10-04T08:00:00Z"), validFromBasis="UNKNOWN", validToBasis="UNKNOWN", basisKind="INFERRED_FROM_MEASUREMENT")
# N3 CAUSED_BY citing a CAUSED_BY assertion that has no basisKind
x.assertion("hu:assertion:w18-n3-caused-by-no-basis", "CAUSED_BY", "hu:event:rezdiffra-us-launch", obj="hu:event:rezdiffra-us-accelerated-approval",
            asserter="hu:org:madrigal-pharmaceuticals", locators=["hu:locator:mdgl-8k-2024-05-07-q1-q1"], recordedAt="2026-10-04T08:00:00Z", predicateClass="OTHER", polarity="POSITIVE", speechAct="STATES")
x.edge("hu:event:rezdiffra-us-launch", "CAUSED_BY", "hu:event:rezdiffra-us-accelerated-approval", relationshipUid="hu:rel:w18-n3", assertionUid="hu:assertion:w18-n3-caused-by-no-basis",
       recordedFrom=DT("2026-10-04T08:00:00Z"), validFromBasis="UNKNOWN", validToBasis="UNKNOWN")
# N4 approval "based on Phase 3 data" captured as a regulatory-basis statement, then misused as CAUSED_BY between events
x.assertion("hu:assertion:w18-n4-approval-based-on", "APPROVAL_BASED_ON", "hu:event:rezdiffra-us-accelerated-approval", obj="hu:study:maestro-nash",
            asserter="hu:org:madrigal-pharmaceuticals", locators=["hu:locator:mdgl-pr-2024-03-14-fda-approval-q3"], recordedAt="2026-10-04T08:00:00Z", predicateClass="REGULATORY", polarity="POSITIVE", speechAct="STATES", basisKind="CITED_FROM_PRIOR_WORK")
x.edge("hu:event:rezdiffra-us-accelerated-approval", "CAUSED_BY", RD, relationshipUid="hu:rel:w18-n4", assertionUid="hu:assertion:w18-n4-approval-based-on",
       recordedFrom=DT("2026-10-04T08:00:00Z"), validFromBasis="UNKNOWN", validToBasis="UNKNOWN", basisKind="CITED_FROM_PRIOR_WORK")
# N5 endorsement derived from conference sponsorship + hosting
x.edge("hu:org:aasld", "ENDORSES_PRODUCT", "hu:product:rezdiffra", derivationRule="sponsor-of-hosted-conference-v0",
       derivedFromAssertionUids=["hu:assertion:w18-f03-sponsors-content-10", "hu:assertion:w18-f03-hosts-event-09"], derivedAt=DT("2026-10-04T08:00:00Z"))
# N6 narrative arc used as support / warrant / derivation input
x.node(["Assertion"], "hu:assertion:w18-n6-claim-citing-arc", predicate="EVENT_OCCURRED", status="EXTRACTED", recordedAt=DT("2026-10-04T08:00:00Z"), contentHash=shash("n6"))
x.edge("hu:assertion:w18-n6-claim-citing-arc", "HAS_SUBJECT", "hu:event:rezdiffra-germany-launch")
x.edge("hu:assertion:w18-n6-claim-citing-arc", "SUPPORTED_BY", "hu:narrative-arc:rezdiffra-path-v2")
x.node(["Adjudication", "EvidenceAssessment"], "hu:adjudication:w18-n6-support-from-arc", assessmentType="Adjudication", methodVersion="support-review-v1",
       status="ACCEPTED", recordedAt=DT("2026-10-04T08:00:00Z"), adjudicationKind="SUPPORT", verdict="SUPPORTED", reviewerType="AGENT", privacyClass="INTERNAL")
x.edge("hu:adjudication:w18-n6-support-from-arc", "EVALUATES", "hu:assertion:w18-c1-mdgl-rise-caused-by-readout")
x.edge("hu:adjudication:w18-n6-support-from-arc", "CONSIDERS_ASSESSMENT", "hu:narrative-arc:rezdiffra-path-v2")
x.edge("hu:event:rezdiffra-us-launch", "REPORTED_IN", "hu:source:mdgl-8k-2024-05-07-q1", derivationRule="arc-membership-v0",
       derivedFromAssertionUids=["hu:assertion:w18-e3-occurred-8k"], derivedFromAssessmentUids=["hu:narrative-arc:rezdiffra-path-v2"], locatorUid="hu:locator:mdgl-8k-2024-05-07-q1-q1")
# N7 arc carrying a score
x.node(["NarrativeArc", "EvidenceAssessment"], "hu:narrative-arc:w18-n7-scored", assessmentType="NARRATIVE_ARC", methodVersion="arc-curation-v0.1",
       status="PROPOSED", recordedAt=DT("2026-10-04T08:00:00Z"), eventsRecordedAsOf=DT("2026-10-04T08:00:00Z"), overallScore=0.8, name="Scored arc (invalid)")
x.edge("hu:narrative-arc:w18-n7-scored", "ARC_INCLUDES_EVENT", RD, orderIndex=1)
# N8 event time bound without precision/basis; N9 effectiveFrom proxied from announcedAt; N12 stored eventPhase/impactLevel
x.node(["Event", "Occurrence"], "hu:event:w18-n8-no-precision", occurrenceType="Event", name="Event with bare date", eventCategory="CORPORATE_EVENT",
       startedAt=DT("2025-01-01T00:00:00Z"), eventStatus="COMPLETED", eventPhase="POST_EVENT", impactLevel="HIGH")
x.node(["Event", "Occurrence"], "hu:event:w18-n9-effective-proxy", occurrenceType="Event", name="Event whose effective date copies the announcement", eventCategory="REGULATORY_EVENT",
       jurisdiction="US", announcedAt=DT("2025-02-01T00:00:00Z"), announcedAtPrecision="DAY", effectiveFrom=DT("2025-02-01T00:00:00Z"), effectiveFromPrecision="DAY",
       effectiveFromBasis="PUBLICATION_PROXY", eventStatus="COMPLETED")
# N10 FOLLOWED_BY derived across overlapping precision (readout DAY 2022-12-19 vs MDGL rise MONTH 2022-12)
x.edge(RD, "FOLLOWED_BY", "hu:event:mdgl-share-rise-2022-12", derivationRule="valid-time-order-v1",
       derivedFromAssertionUids=["hu:assertion:w18-e1-occurred-mdgl", "hu:assertion:w18-e7-occurred-mb"], derivedAt=DT("2026-10-04T08:00:00Z"))
# N11 ATTENDS from a private person record (leak-check device: :PrivateRecord label + hu:private- uid)
x.stmt("MERGE (p:Person:Entity:PrivateRecord {uid: 'hu:private-person:w18-n11'}) SET p += {id: 'w18-n11', entityType: 'Person', privacyClass: 'INTERNAL', createdAt: datetime('2026-10-04T08:00:00Z'), updatedAt: datetime('2026-10-04T08:00:00Z')}")
x.stmt("MATCH (p:PrivateRecord {uid: 'hu:private-person:w18-n11'}), (c:Conference {uid: 'hu:conference:aasld-tlm-2026'}) MERGE (p)-[r:ATTENDS {relationshipUid: 'hu:rel:w18-n11'}]->(c) SET r += {assertionUid: 'hu:assertion:w18-n11-missing', recordedFrom: datetime('2026-10-04T08:00:00Z'), validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', participantRole: 'ATTENDEE'}")
# N13 impact assessment without methodVersion
x.node(["EventImpactAssessment", "EvidenceAssessment"], "hu:event-impact:w18-n13-no-method", assessmentType="EVENT_IMPACT", status="PROPOSED",
       recordedAt=DT("2026-10-04T08:00:00Z"), impactLevel="CRITICAL", impactDomain="MARKET")
x.edge("hu:event-impact:w18-n13-no-method", "ASSESSES_EVENT", RD)
# N14 arc using the conference HAS_EVENT type
x.edge("hu:narrative-arc:rezdiffra-path-v2", "HAS_EVENT", RD, orderIndex=99)
# N15 deck declared a rendition of the talk recording (CL-003 R4 laundering)
x.edge("hu:document:madrigal-jpm-2026-deck", "RENDITION_OF", "hu:episode:madrigal-jpm-2026-webcast")
# N16 PLANNED read as COMPLETED: status COMPLETED with only a scheduling assertion
x.node(["Event", "Occurrence"], "hu:event:w18-n16-planned-as-completed", occurrenceType="Event", name="Planned event marked completed", eventCategory="PRODUCT_EVENT",
       eventType="LAUNCH", startedAt=DT("2024-04-01T00:00:00Z"), startedAtPrecision="MONTH", startedAtBasis="STATED_BY_SOURCE",
       timeAssertionUid="hu:assertion:w18-n16-scheduled", eventStatus="COMPLETED")
x.assertion("hu:assertion:w18-n16-scheduled", "EVENT_SCHEDULED", "hu:event:w18-n16-planned-as-completed", asserter="hu:org:madrigal-pharmaceuticals",
            locators=["hu:locator:mdgl-pr-2024-03-14-fda-approval-q2"], recordedAt="2026-10-04T08:00:00Z", validFrom=DT("2024-04-01T00:00:00Z"),
            validFromPrecision="MONTH", validFromBasis="STATED_BY_SOURCE", statedTense="FUTURE", predicateClass="OTHER", polarity="POSITIVE", speechAct="STATES")
# N17 materialized time not licensed by its named assertion (startedAt drifted from the assertion's validFrom)
x.node(["Event", "Occurrence"], "hu:event:w18-n17-drifted-time", occurrenceType="Event", name="Event with drifted time", eventCategory="REGULATORY_EVENT",
       jurisdiction="EU", startedAt=DT("2025-08-19T00:00:00Z"), startedAtPrecision="DAY", startedAtBasis="STATED_BY_SOURCE",
       timeAssertionUid="hu:assertion:w18-e4-occurred-ema", eventStatus="COMPLETED")
n90 = x.write(os.path.join(HERE, "w18-90-negatives.cypher"))
print({"01": n01, "02": n02, "03": n03, "04": n04, "90": n90})
