#!/usr/bin/env python3
"""W10 fixture generator (run-2026-10-04-fable51-01). Emits w10-01..w10-05 and w10-90 Cypher files.

Rules applied to every emitted statement:
- statements are separated by ';' and each binds its own nodes by uid (no variable crosses a ';');
- every node carries its primary label AND its archetype label (D-001); `id` = opaque uid segment (INV-106);
- snapshots use contentHashBasis SYNTHETIC_FIXTURE (raw bytes were not hashed); TEXT_QUOTE locators carry
  normalizationVersion NFC-WS1 and a quoteHash computed by quote_hashes.py over the stored `exact` text;
- recordedAt / createdAt are pinned instants (never datetime()), never earlier than the cited snapshots' retrievedAt.
Files 01-03 build on the inherited fixture docs/schema/examples/study-vs-product-mismatch.cypher (load it first);
files 04, 05 and 90 are standalone.
"""
import json, os
from quote_hashes import QUOTES, nfcws1
import hashlib

HERE = os.path.dirname(os.path.abspath(__file__))
T0 = "2026-10-04T02:00:00Z"   # W10 fixture commit instant (after all 2026-10-04 retrievals)
RET = "2026-10-04T01:20:00Z"  # retrieval instant of the 2026-10-04 captures (connector calls in this session)

def q(s):
    return "'" + str(s).replace("\\", "\\\\").replace("'", "\\'") + "'"

def lit(v):
    if v is None: return "null"
    if isinstance(v, bool): return "true" if v else "false"
    if isinstance(v, (int, float)): return repr(float(v)) if isinstance(v, float) else str(v)
    if isinstance(v, list): return "[" + ", ".join(lit(x) for x in v) + "]"
    return q(v)

def qh(key):
    return "sha256:" + hashlib.sha256(nfcws1(QUOTES[key]).encode("utf-8")).hexdigest()

def oid(uid): return uid.split(":", 2)[2]

def stmt(body, status="run"):
    return f"// status: {status}\n{body.strip()};\n"

# ------------------------------------------------------------------------------------------------ provenance
def capture(src, uri, kind, snap, locs, completeness="PARTIAL_EXCERPT", retrieved=RET, published=None, title=None):
    """locs: list of (locUid, selectorKind, section, quoteKey|None)."""
    lines = [f"MERGE (src:Source {{uid: {q(src)}}})",
             f"  ON CREATE SET src.id = {q(oid(src))}, src.entityType = 'Source', src.canonicalUri = {q(uri)}, src.sourceKind = {q(kind)},"
             f" src.title = {lit(title)}, src.createdAt = datetime({q(T0)}), src.privacyClass = 'PUBLIC'",
             "SET src:Entity",
             f"MERGE (snap:SourceSnapshot {{uid: {q(snap)}}})",
             f"  ON CREATE SET snap.id = {q(oid(snap))}, snap.artifactType = 'SourceSnapshot', snap.canonicalUri = {q(uri)},",
             f"    snap.retrievedAt = datetime({q(retrieved)}), snap.observedAt = datetime({q(retrieved)}), snap.publishedAt = {('datetime(' + q(published + 'T00:00:00Z') + ')') if published else 'null'},",
             f"    snap.contentHash = {q('synthetic:' + snap)}, snap.contentHashBasis = 'SYNTHETIC_FIXTURE', snap.captureCompleteness = {q(completeness)},",
             f"    snap.createdAt = datetime({q(T0)}), snap.privacyClass = 'PUBLIC'",
             "SET snap:InformationArtifact",
             "MERGE (src)-[:HAS_SNAPSHOT]->(snap)"]
    for i, (lu, sk, section, key) in enumerate(locs):
        v = f"l{i}"
        exact = QUOTES[key] if key else None
        lines += [f"MERGE ({v}:SourceLocator {{uid: {q(lu)}}})",
                  f"  ON CREATE SET {v}.id = {q(oid(lu))}, {v}.artifactType = 'SourceLocator', {v}.uri = {q(uri)}, {v}.selectorKind = {q(sk)},"
                  f" {v}.section = {lit(section)}, {v}.exact = {lit(exact)}, {v}.quoteHash = {lit(qh(key) if key else None)},"
                  f" {v}.normalizationVersion = {lit('NFC-WS1' if key else None)}, {v}.createdAt = datetime({q(T0)}), {v}.privacyClass = 'PUBLIC'",
                  f"SET {v}:InformationArtifact",
                  f"MERGE (snap)-[:HAS_LOCATOR]->({v})"]
    return stmt("\n".join(lines))

def assessment_props(var, uid, atype, method, status="PROPOSED", recorded=T0, extra=None):
    props = {"id": oid(uid), "assessmentType": atype, "methodVersion": method, "status": status, "privacyClass": "PUBLIC"}
    props.update(extra or {})
    s = ", ".join(f"{var}.{k} = {lit(v)}" for k, v in props.items())
    return s + f", {var}.recordedAt = datetime({q(recorded)}), {var}.createdAt = datetime({q(recorded)})"

def assertion(uid, predicate, subj, obj=None, literal=None, locs=(), recorded=T0, extra=None):
    """Literal: (field, value). Returns a statement."""
    lines = [f"MATCH (s {{uid: {q(subj)}}})"]
    if obj: lines.append(f"MATCH (o {{uid: {q(obj)}}})")
    props = {"id": oid(uid), "predicate": predicate, "status": "ACCEPTED", "polarity": "POSITIVE",
             "validFromBasis": "UNKNOWN", "validToBasis": "UNKNOWN", "privacyClass": "PUBLIC",
             "contentHash": "sha256:" + hashlib.sha256(uid.encode()).hexdigest()}
    if literal: props[literal[0]] = literal[1]
    props.update(extra or {})
    ps = ", ".join(f"a.{k} = {lit(v)}" for k, v in props.items())
    lines += [f"MERGE (a:Assertion {{uid: {q(uid)}}})",
              f"  ON CREATE SET {ps}, a.recordedAt = datetime({q(recorded)}), a.createdAt = datetime({q(recorded)})",
              "MERGE (a)-[:HAS_SUBJECT]->(s)"]
    if obj: lines.append("MERGE (a)-[:HAS_OBJECT]->(o)")
    lines.append("WITH a")
    lines.append(f"UNWIND {lit(list(locs))} AS lu")
    lines.append("MATCH (l:SourceLocator {uid: lu})")
    lines.append("MERGE (a)-[:SUPPORTED_BY]->(l)")
    return stmt("\n".join(lines))

def capture_policy(adj_uid, assertion_uids, reviewed=T0):
    return stmt(f"""
UNWIND {lit(assertion_uids)} AS au
MATCH (a:Assertion {{uid: au}})
MERGE (j:Adjudication {{uid: {q(adj_uid)}}})
  ON CREATE SET j.id = {q(oid(adj_uid))}, j.assessmentType = 'Adjudication', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
    j.reviewerType = 'POLICY', j.methodVersion = 'w10-fixture-capture-policy-1', j.status = 'ACCEPTED', j.privacyClass = 'INTERNAL',
    j.rationale = 'Fixture capture policy: recorded propositions match the cited quotes; says nothing about truth.',
    j.reviewedAt = datetime({q(reviewed)}), j.recordedAt = datetime({q(reviewed)}), j.createdAt = datetime({q(reviewed)})
SET j:EvidenceAssessment
MERGE (j)-[:EVALUATES]->(a)""")

# ------------------------------------------------------------------------------------------------ applicability
DIM_CLASS = {"MATERIAL_IDENTITY": "CATEGORICAL", "ACTIVE_COMPOSITION": "CATEGORICAL", "DOSAGE_FORM": "CATEGORICAL", "ROUTE": "CATEGORICAL",
             "POPULATION": "CATEGORICAL", "COMPARATOR": "CATEGORICAL", "OUTCOME_RELEVANCE": "CATEGORICAL", "STUDY_DESIGN_AND_QUALITY": "CATEGORICAL",
             "DOSE": "CONTINUOUS", "SCHEDULE": "CONTINUOUS", "DURATION": "CONTINUOUS", "EXPOSURE": "CONTINUOUS",
             "BACKGROUND_CONTEXT": "EXPLANATION_ONLY", "RECENCY_AND_CORRECTIONS": "EXPLANATION_ONLY"}
DIM_FIELDS = ["identityLevel", "evidenceCategory", "targetCategory", "evidenceValue", "targetValue", "unitCode",
              "evidenceQuantityBasis", "targetQuantityBasis", "evidenceMassBasis", "targetMassBasis", "ratio", "missingFacts", "rationale"]

def dim_uid(ea_uid, dim):
    return "hu:applicability-dimension:" + oid(ea_uid) + "-" + dim.lower().replace("_", "-")

def applicability(ea_uid, method, summary, evidence_target, use_target, use_profile=None, based_on=(), recorded=T0,
                  supersedes=None, overall=None, status="PROPOSED"):
    out = []
    lines = [f"MATCH (et {{uid: {q(evidence_target)}}})", f"MATCH (ut {{uid: {q(use_target)}}})"]
    lines += [f"MERGE (ea:EvidenceApplicability {{uid: {q(ea_uid)}}})",
              f"  ON CREATE SET {assessment_props('ea', ea_uid, 'EvidenceApplicability', method, status, recorded, {'summary': summary, 'overallScore': overall})}",
              "SET ea:EvidenceAssessment",
              "MERGE (ea)-[:HAS_EVIDENCE_TARGET]->(et)",
              "MERGE (ea)-[:ASSESSES_APPLICABILITY_TO]->(ut)"]
    out.append(stmt("\n".join(lines)))
    if use_profile:
        out.append(stmt(f"MATCH (ea:EvidenceApplicability {{uid: {q(ea_uid)}}}), (p:UseContextProfile {{uid: {q(use_profile)}}})\nMERGE (ea)-[:FOR_USE_CONTEXT]->(p)"))
    if based_on:
        out.append(stmt(f"MATCH (ea:EvidenceApplicability {{uid: {q(ea_uid)}}})\nUNWIND {lit(list(based_on))} AS bu\nMATCH (b {{uid: bu}})\nMERGE (ea)-[:BASED_ON_EVIDENCE]->(b)"))
    if supersedes:
        out.append(stmt(f"""
MATCH (newer:EvidenceApplicability {{uid: {q(ea_uid)}}}), (older:EvidenceApplicability {{uid: {q(supersedes)}}})
MERGE (newer)-[s:SUPERSEDES]->(older)
  ON CREATE SET s.supersessionKind = 'RE_REVIEW', s.recordedAt = newer.recordedAt
SET older.recordedTo = coalesce(older.recordedTo, newer.recordedAt)"""))
    return out

def dimensions(ea_uid, rows, recorded=T0):
    """rows: dicts with dim, verdict, fields..., locs, considers, considersAssessments."""
    out = []
    payload = []
    for r in rows:
        d = {"uid": dim_uid(ea_uid, r["dim"]), "id": oid(dim_uid(ea_uid, r["dim"])), "dimension": r["dim"],
             "dimensionClass": r.get("cls", DIM_CLASS[r["dim"]]), "verdict": r["verdict"]}
        for f in DIM_FIELDS:
            d[f] = r.get(f, [] if f == "missingFacts" else None)
        payload.append(d)
    sets = ", ".join(f"d.{k} = row.{k}" for k in ["id", "dimension", "dimensionClass", "verdict"] + DIM_FIELDS)
    out.append(stmt(f"""
MATCH (ea:EvidenceApplicability {{uid: {q(ea_uid)}}})
UNWIND {json_rows(payload)} AS row
MERGE (d:ApplicabilityDimension {{uid: row.uid}})
  ON CREATE SET {sets}, d.assessmentType = 'ApplicabilityDimension', d.methodVersion = ea.methodVersion, d.status = ea.status,
    d.privacyClass = 'PUBLIC', d.recordedAt = datetime({q(recorded)}), d.createdAt = datetime({q(recorded)})
SET d:EvidenceAssessment
MERGE (ea)-[:HAS_DIMENSION]->(d)"""))
    links = []
    for r in rows:
        du = dim_uid(ea_uid, r["dim"])
        for lu in r.get("locs", []): links.append({"d": du, "t": lu, "rel": "SUPPORTED_BY"})
        for au in r.get("considers", []): links.append({"d": du, "t": au, "rel": "CONSIDERS"})
        for xu in r.get("considersAssessments", []): links.append({"d": du, "t": xu, "rel": "CONSIDERS_ASSESSMENT"})
    for rel in ["SUPPORTED_BY", "CONSIDERS", "CONSIDERS_ASSESSMENT"]:
        rl = [{"d": x["d"], "t": x["t"]} for x in links if x["rel"] == rel]
        if rl:
            out.append(stmt(f"UNWIND {json_rows(rl)} AS row\nMATCH (d:ApplicabilityDimension {{uid: row.d}}), (t {{uid: row.t}})\nMERGE (d)-[:{rel}]->(t)"))
    return out

def flat_projection(ea_uid):
    """Derived read-only flat fields (catalog derivedProperties), regenerated from the dimension nodes."""
    pairs = [("identityMatch", "MATERIAL_IDENTITY"), ("doseMatch", "DOSE"), ("routeMatch", "ROUTE"), ("scheduleMatch", "SCHEDULE"),
             ("durationMatch", "DURATION"), ("populationMatch", "POPULATION"), ("outcomeMatch", "OUTCOME_RELEVANCE")]
    sets = ",\n    ".join(f"ea.{f} = head([d IN dims WHERE d.dimension = '{k}' | d.verdict])" for f, k in pairs)
    return stmt(f"""
MATCH (ea:EvidenceApplicability {{uid: {q(ea_uid)}}})-[:HAS_DIMENSION]->(d:ApplicabilityDimension)
WITH ea, collect(d) AS dims
SET {sets}""")

def json_rows(rows):
    # Cypher map-list literal
    def m(d): return "{" + ", ".join(f"{k}: {lit(v)}" for k, v in d.items()) + "}"
    return "[\n  " + ",\n  ".join(m(r) for r in rows) + "\n]"

def write(name, header, statements):
    path = os.path.join(HERE, name)
    with open(path, "w", encoding="utf-8") as f:
        f.write(header.strip() + "\n\n")
        for s in statements:
            f.write(s + "\n")
    print("wrote", path, len(statements), "statements")

# ================================================================================================= FILE 01
INH = {  # uids from docs/schema/examples/study-vs-product-mismatch.cypher (inherited fixture)
 "si1x": "hu:study-intervention:nct02678611-nrpt-1x", "basisForm": "hu:formulation:basis-us-current-2026-07-10",
 "nad1x": "hu:study-result:nct02678611-nad-1x-d30", "pubDell": "hu:publication:pmid-29184669", "ea1x": "hu:applicability:nct02678611-1x-to-basis-current",
 "h1": "hu:resolution:nct02678611-nr-is-chromadex-niagen", "h2": "hu:resolution:nct02678611-nr-is-elysium-nr-e",
 "aSup": "hu:assertion:chromadex-says-supplied-elysium-nr-until-mid-2016", "aProv1": "hu:assertion:elysium-provides-nct02678611-nrpt-1x",
 "ecNad": "hu:endpoint-classification:nct02678611-nad-whole-blood", "corrLoc": "hu:locator:pmid30155270-intervention-source",
 "cenLoc": "hu:locator:cen-2018-supply-until-mid-2016", "eligLoc": "hu:locator:ctgov-nct02678611-eligibility",
 "si300": "hu:study-intervention:nct02712593-niagen-300", "tnForm": "hu:formulation:tru-niagen-300mg-observed-2026-10-03",
 "nad300": "hu:study-result:nct02712593-nad-300", "eaTn": "hu:applicability:nct02712593-300-to-tru-niagen-300",
 "absConze": "hu:locator:pmid31278280-abstract", "eligConze": "hu:locator:ctgov-nct02712593-eligibility", "armsConze": "hu:locator:ctgov-nct02712593-arms",
 "pubConze": "hu:publication:pmid-31278280", "nadOutcome": "hu:outcome:nct02678611-nad-whole-blood",
 "ldlBm": "hu:biomarker:ldl-c-serum", "ldlOutcome": "hu:outcome:nct02678611-ldl-c", "ecLdl": "hu:endpoint-classification:nct02678611-ldl-c",
 "ecFdaHyper": "hu:endpoint-classification:ldl-c-fda-hypercholesterolemia-lipid-lowering", "lipidsLoc": "hu:locator:pmid29184669-results-lipids",
}
L = {  # new W10 locators
 "basisDir": "hu:locator:elysium-basis-label-directions-2026-10-04", "basisAmt": "hu:locator:elysium-basis-label-amount-2026-10-04",
 "basisOther": "hu:locator:elysium-basis-label-other-ingredients-2026-10-04",
 "dellCap": "hu:locator:pmc5701244-methods-intervention-capsule-2026-10-04", "dellFour": "hu:locator:pmc5701244-methods-four-capsules-2026-10-04",
 "dellObj": "hu:locator:pmc5701244-methods-primary-objective-2026-10-04",
 "conzeCap": "hu:locator:pmc6611812-methods-study-product-2026-10-04", "conzeDose": "hu:locator:pmc6611812-methods-dosing-2026-10-04",
 "tnAmt": "hu:locator:truniagen-300mg-serving-size-2026-10-04", "tn300": "hu:locator:truniagen-300mg-niagen-amount-2026-10-04",
 "tnDir": "hu:locator:truniagen-300mg-directions-2026-10-04",
}
UP_BASIS = "hu:use-profile:basis-us-label-directions-one-serving-daily"
UP_TN = "hu:use-profile:tru-niagen-300mg-one-capsule-daily"
EA_BASIS_V2 = "hu:applicability:w10-nct02678611-1x-to-basis-current-v2"
EA_TN_V2 = "hu:applicability:w10-nct02712593-300-to-tru-niagen-300-v2"
ACT = "hu:activity:w10-applicability-review-2026-10-04"

def file01():
    s = []
    s.append(capture("hu:source:elysium-basis-supplement-facts", "https://www.elysiumhealth.com/pages/basis-supplement-facts", "MANUFACTURER_LABEL_PAGE",
                     "hu:snapshot:elysium-basis-supplement-facts-2026-10-04",
                     [(L["basisDir"], "TEXT_QUOTE", "Supplement Facts: Suggested Use", "basis-label-directions"),
                      (L["basisAmt"], "TEXT_QUOTE", "Supplement Facts", "basis-label-amount"),
                      (L["basisOther"], "TEXT_QUOTE", "Supplement Facts: Other Ingredients", "basis-label-other")]))
    s.append(capture("hu:source:doi-10.1038-s41514-017-0016-9", "https://doi.org/10.1038/s41514-017-0016-9", "PEER_REVIEWED_PUBLICATION",
                     "hu:snapshot:pmc5701244-2026-10-04",
                     [(L["dellCap"], "TEXT_QUOTE", "Methods: Intervention", "dellinger-capsule"),
                      (L["dellFour"], "TEXT_QUOTE", "Methods: Intervention", "dellinger-four-caps"),
                      (L["dellObj"], "TEXT_QUOTE", "Methods: Clinical trial", "dellinger-primary-objective")], published="2017-11-24"))
    s.append(stmt(f"""
MERGE (p:UseContextProfile {{uid: {q(UP_BASIS)}}})
  ON CREATE SET p.id = {q(oid(UP_BASIS))}, p.entityType = 'UseContextProfile', p.name = 'Basis US label directions: one serving (2 capsules) every morning',
    p.populationDescriptor = 'healthy adults (label: intended for healthy adults; not pregnant or nursing)',
    p.doseDescriptor = 'label directions: take two capsules (one serving) every morning with or without food',
    p.durationDescriptor = 'open-ended daily use (no duration on label)', p.servingsPerDay = 1.0, p.intendedDurationIso = null,
    p.createdAt = datetime({q(T0)}), p.privacyClass = 'PUBLIC'
SET p:Entity"""))
    s.append(stmt(f"""
MERGE (act:Activity {{uid: {q(ACT)}}})
  ON CREATE SET act.id = {q(oid(ACT))}, act.occurrenceType = 'Activity', act.activityKind = 'ADJUDICATION', act.methodVersion = 'applicability-v0.2-candidate',
    act.startedAt = datetime('2026-10-04T01:50:00Z'), act.endedAt = datetime({q(T0)}), act.createdAt = datetime({q(T0)}), act.privacyClass = 'INTERNAL'
SET act:Occurrence"""))
    s += applicability(EA_BASIS_V2, "applicability-v0.2-candidate",
        "Re-assessment after reading the current label directions: schedule now matches (one serving per day); dose stays PARTIAL because the trial does not state salt vs cation mass; trial NR material still unresolved (weakest); design and quality not assessed.",
        INH["si1x"], INH["basisForm"], UP_BASIS, [INH["nad1x"], INH["pubDell"]], supersedes=INH["ea1x"])
    rows = [
     dict(dim="MATERIAL_IDENTITY", verdict="UNKNOWN", identityLevel="SAME_SUBSTANCE_MATERIAL_UNRESOLVED",
          missingFacts=["supplier and specification of the NR administered in NCT02678611 (Jan-Jul 2016)", "pterostilbene material administered in NCT02678611",
                        "whether Elysium NR-E existed in 2016 and matches the trial NR"],
          rationale="Two competing ResolutionHypothesis records (ChromaDex NIAGEN; Elysium NR-E). The correction says only that Elysium provided the investigational product; ChromaDex says it supplied Elysium NR until mid-2016.",
          locs=[INH["corrLoc"], INH["cenLoc"], L["basisAmt"]], considers=[INH["aSup"], INH["aProv1"]], considersAssessments=[INH["h1"], INH["h2"]]),
     dict(dim="ACTIVE_COMPOSITION", verdict="MATCH", evidenceCategory="SAME_ACTIVES", targetCategory="SAME_ACTIVES",
          rationale="Trial capsule: NR + pterostilbene; label: Elysium NR + PT.", locs=[L["dellCap"], L["basisAmt"]]),
     dict(dim="DOSE", verdict="PARTIAL", evidenceValue=250.0, targetValue=250.0, unitCode="mg/d", evidenceQuantityBasis="PER_DAY", targetQuantityBasis="PER_DAY",
          evidenceMassBasis="UNSPECIFIED", targetMassBasis="SALT_FORM", ratio=None,
          missingFacts=['mass basis of "125 mg of NR" per capsule in PMID 29184669 Methods (NR chloride salt or NR cation not stated)'],
          rationale="Quantity bases now match (label 250 mg per serving x 1 serving/day from the use profile = 250 mg/d). Mass bases do not: the paper says '125 mg of NR' per capsule without naming the salt; the label declares nicotinamide riboside chloride. Ratio withheld (INV-203); verdict at most PARTIAL.",
          locs=[L["dellCap"], L["dellFour"], L["basisAmt"], L["basisDir"]]),
     dict(dim="DOSAGE_FORM", verdict="PARTIAL", evidenceCategory="CAPSULE", targetCategory="CAPSULE",
          rationale="Both oral capsules. Trial: gelatin capsules with MCC, silicon dioxide, magnesium stearate; current label: hypromellose (vegetarian) capsules with MCC, vegetable magnesium stearate, silica. Shell material differs.",
          locs=[L["dellCap"], L["basisOther"]]),
     dict(dim="ROUTE", verdict="MATCH", evidenceCategory="ORAL", targetCategory="ORAL", rationale="Oral in both.", locs=[L["dellFour"], L["basisDir"]]),
     dict(dim="SCHEDULE", verdict="MATCH", evidenceValue=1.0, targetValue=1.0, unitCode="/d", evidenceQuantityBasis="PER_DAY", targetQuantityBasis="PER_DAY", ratio=1.0,
          evidenceCategory="ONCE_DAILY_WITH_BREAKFAST", targetCategory="ONCE_DAILY_MORNING_WITH_OR_WITHOUT_FOOD",
          rationale="One administration per day on both sides (identity ratio 1.0; no band applied). Food timing differs (with breakfast vs with or without food).",
          locs=[L["dellFour"], L["basisDir"]]),
     dict(dim="DURATION", verdict="PARTIAL", evidenceValue=56.0, targetValue=None, unitCode="d", targetCategory="OPEN_ENDED",
          rationale="Studied 8 weeks (+30-day follow-up); the label implies open-ended daily use. Extrapolation beyond 56 days.", locs=["hu:locator:pmid29184669-results-trial-overview", L["basisDir"]]),
     dict(dim="POPULATION", verdict="PARTIAL", evidenceCategory="OVERLAPS", targetCategory="HEALTHY_ADULTS",
          rationale="Trial: healthy adults 60-80, BMI 18-35, no lipid-lowering drugs or B3 supplements; label: healthy adults.", locs=[INH["eligLoc"], L["basisDir"]]),
     dict(dim="COMPARATOR", verdict="MATCH", evidenceCategory="PLACEBO", targetCategory="NO_TREATMENT", rationale="Placebo comparator answers a take-or-not decision.", locs=[L["dellFour"]]),
     dict(dim="OUTCOME_RELEVANCE", verdict="PARTIAL", evidenceCategory="BIOMARKER_NOT_SURROGATE",
          rationale="The favorable finding is whole-blood NAD+, a pharmacodynamic biomarker with no established surrogate context; the registered primary objective was safety.",
          locs=[L["dellObj"], "hu:locator:pmid29184669-results-nad"], considersAssessments=[INH["ecNad"]]),
     dict(dim="STUDY_DESIGN_AND_QUALITY", verdict="NOT_ASSESSED"),
     dict(dim="BACKGROUND_CONTEXT", verdict="NOT_SCORED", rationale="Participants avoided vitamin B3 supplements and multivitamins and excluded lipid-lowering drug users; consumers may not."),
     dict(dim="RECENCY_AND_CORRECTIONS", verdict="NOT_SCORED", rationale="Author Correction (2018) added that Elysium provided the investigational product; the registry lists one site, the paper three; the registry shows no posted results while a results article exists."),
    ]
    s += dimensions(EA_BASIS_V2, rows)
    s.append(flat_projection(EA_BASIS_V2))
    s.append(stmt(f"""
MATCH (act:Activity {{uid: {q(ACT)}}}), (ea:EvidenceApplicability {{uid: {q(EA_BASIS_V2)}}})
MERGE (ea)-[:WAS_GENERATED_BY]->(act)"""))
    write("w10-01-applicability-basis-13dim.cypher", """
// =====================================================================================================================
// W10 fixture 01: 13-dimension EvidenceApplicability re-assessment (NRPT 1X arm of NCT02678611 -> current US Basis
// formulation) built on the shapes of docs/schema/examples/study-vs-product-mismatch.cypher (LOAD THAT FILE FIRST).
// New, retrieved 2026-10-04: Basis Supplement Facts page (Tavily extract) and PMC5701244 Methods (PubMed connector).
// What it shows: one evidence target, one use target, one FOR_USE_CONTEXT profile, 13 dimension nodes (11 required + 2
// explanation-only) with NOT_ASSESSED explicit; SCHEDULE resolved by the label directions; DOSE ratio blocked by mass
// basis (UNSPECIFIED vs SALT_FORM) with ratio null and verdict PARTIAL; MATERIAL_IDENTITY UNKNOWN citing the two competing
// ResolutionHypothesis records; re-assessment SUPERSEDES {RE_REVIEW} the inherited v1 (recordedTo written once).
// Expected: V-201..V-209 zero rows; QS-3a weakest = [MATERIAL_IDENTITY (UNKNOWN), STUDY_DESIGN_AND_QUALITY (NOT_ASSESSED)].
// Generated by gen_w10.py; do not edit by hand.
// =====================================================================================================================""", s)

# ================================================================================================= FILE 02
def file02():
    s = []
    s.append(capture("hu:source:doi-10.1038-s41598-019-46120-z", "https://doi.org/10.1038/s41598-019-46120-z", "PEER_REVIEWED_PUBLICATION",
                     "hu:snapshot:pmc6611812-2026-10-04",
                     [(L["conzeCap"], "TEXT_QUOTE", "Methods: Study product", "conze-capsule"),
                      (L["conzeDose"], "TEXT_QUOTE", "Methods: Study product", "conze-dosing")], published="2019-07-05"))
    s.append(capture("hu:source:truniagen-300mg-product-page", "https://www.truniagen.com/products/tru-niagen-300mg", "MANUFACTURER_LABEL_PAGE",
                     "hu:snapshot:truniagen-300mg-2026-10-04",
                     [(L["tnAmt"], "TEXT_QUOTE", "Supplement Facts", "truniagen-amount"),
                      (L["tn300"], "TEXT_QUOTE", "Supplement Facts", "truniagen-niagen-300"),
                      (L["tnDir"], "TEXT_QUOTE", "Directions", "truniagen-directions")]))
    s.append(stmt(f"""
MERGE (p:UseContextProfile {{uid: {q(UP_TN)}}})
  ON CREATE SET p.id = {q(oid(UP_TN))}, p.entityType = 'UseContextProfile', p.name = 'Tru Niagen 300 mg: one capsule once daily (lowest label direction)',
    p.populationDescriptor = 'adults 18 and over (label: not intended for use by children under 18)',
    p.doseDescriptor = 'one capsule (one serving) once daily; label allows 1-3 times daily', p.durationDescriptor = 'open-ended daily use',
    p.servingsPerDay = 1.0, p.intendedDurationIso = null, p.createdAt = datetime({q(T0)}), p.privacyClass = 'PUBLIC'
SET p:Entity"""))
    ecc = "hu:endpoint-classification:w10-nct02712593-nad-whole-blood"
    ps = assessment_props("ec", ecc, "EndpointClassification", "endpoint-class-v0.1", extra=dict(endpointClass="BIOMARKER_NOT_SURROGATE",
        biomarkerCategory="PHARMACODYNAMIC_RESPONSE", surrogateValidationLevel="NOT_ESTABLISHED", contextMatch="NONE",
        rationale="Whole-blood NAD+ in the NIAGEN trial measures exposure/response to the NAD+ precursor; no surrogate context found."))
    s.append(stmt(f"""
MATCH (od:OutcomeDefinition {{uid: 'hu:outcome:nct02712593-nad-whole-blood'}}), (l:SourceLocator {{uid: {q(INH['absConze'])}}})
MERGE (ec:EndpointClassification {{uid: {q(ecc)}}})
  ON CREATE SET {ps}
SET ec:EvidenceAssessment
MERGE (ec)-[:CLASSIFIES_OUTCOME]->(od)
MERGE (ec)-[:SUPPORTED_BY]->(l)"""))
    s += applicability(EA_TN_V2, "applicability-v0.2-candidate",
        "Re-assessment after reading Conze Methods: trial doses are NR chloride mass (SALT_FORM) like the label, so with the one-capsule-daily profile the dose ratio is computable (1.0). Branded material same (NIAGEN), spec version at trial time unresolved.",
        INH["si300"], INH["tnForm"], UP_TN, [INH["nad300"], INH["pubConze"]], supersedes=INH["eaTn"])
    rows = [
     dict(dim="MATERIAL_IDENTITY", verdict="PARTIAL", identityLevel="SAME_BRANDED_MATERIAL_SPEC_UNRESOLVED",
          missingFacts=["NIAGEN specification version governing the 2016-2017 trial lots"],
          rationale="Trial component and label component use the same IngredientMaterial node (NIAGEN); the specification version at trial time is not recorded.",
          locs=[INH["absConze"], L["tn300"]]),
     dict(dim="ACTIVE_COMPOSITION", verdict="MATCH", evidenceCategory="SAME_ACTIVES", targetCategory="SAME_ACTIVES", rationale="NR chloride is the only active in both.", locs=[L["conzeCap"], L["tn300"]]),
     dict(dim="DOSE", verdict="MATCH", evidenceValue=300.0, targetValue=300.0, unitCode="mg/d", evidenceQuantityBasis="PER_DAY", targetQuantityBasis="PER_DAY",
          evidenceMassBasis="SALT_FORM", targetMassBasis="SALT_FORM", ratio=1.0,
          rationale="Trial 300 mg/day as three 100 mg NR chloride capsules (Methods); label 300 mg NR chloride per capsule x 1 capsule/day (profile). Bases match; identity ratio 1.0. No ratio band is applied: any ratio other than 1.0 would stay PARTIAL until calibration (W10-V04).",
          locs=[L["conzeCap"], L["conzeDose"], L["tn300"], L["tnAmt"], L["tnDir"]]),
     dict(dim="DOSAGE_FORM", verdict="MATCH", evidenceCategory="CAPSULE", targetCategory="CAPSULE",
          rationale="Both vegetarian capsules with microcrystalline cellulose; the label adds vegetable magnesium stearate (excipient difference recorded, not scored).", locs=[L["conzeCap"], L["tnAmt"]]),
     dict(dim="ROUTE", verdict="MATCH", evidenceCategory="ORAL", targetCategory="ORAL", rationale="Oral.", locs=[L["conzeDose"], L["tnDir"]]),
     dict(dim="SCHEDULE", verdict="MATCH", evidenceValue=1.0, targetValue=1.0, unitCode="/d", evidenceQuantityBasis="PER_DAY", targetQuantityBasis="PER_DAY", ratio=1.0,
          evidenceCategory="ONCE_DAILY_AFTER_BREAKFAST", targetCategory="ONCE_DAILY",
          rationale="Trial: all four capsules once daily after breakfast; profile: one capsule once daily.", locs=[L["conzeDose"], L["tnDir"]]),
     dict(dim="DURATION", verdict="PARTIAL", evidenceValue=56.0, targetValue=None, unitCode="d", targetCategory="OPEN_ENDED", rationale="8-week intervention; open-ended use.", locs=[L["conzeDose"]]),
     dict(dim="POPULATION", verdict="PARTIAL", evidenceCategory="OVERLAPS", targetCategory="ADULTS_18_PLUS", rationale="Trial: healthy overweight adults 40-60 (BMI 25-30); label: adults.", locs=[INH["eligConze"]]),
     dict(dim="COMPARATOR", verdict="MATCH", evidenceCategory="PLACEBO", targetCategory="NO_TREATMENT", rationale="Placebo.", locs=[INH["armsConze"]]),
     dict(dim="OUTCOME_RELEVANCE", verdict="PARTIAL", evidenceCategory="BIOMARKER_NOT_SURROGATE", rationale="Whole-blood NAD+ and urinary metabolites (pharmacodynamic biomarkers).", locs=[INH["absConze"]],
          considersAssessments=["hu:endpoint-classification:w10-nct02712593-nad-whole-blood"]),
     dict(dim="STUDY_DESIGN_AND_QUALITY", verdict="NOT_ASSESSED"),
    ]
    s += dimensions(EA_TN_V2, rows)
    s.append(flat_projection(EA_TN_V2))
    s.append(stmt(f"""
MATCH (act:Activity {{uid: {q(ACT)}}}), (ea:EvidenceApplicability {{uid: {q(EA_TN_V2)}}})
MERGE (ea)-[:WAS_GENERATED_BY]->(act)"""))
    write("w10-02-dose-ratio-minimal-pair.cypher", """
// =====================================================================================================================
// W10 fixture 02: DOSE ratio minimal pair (load the inherited study-vs-product-mismatch.cypher and w10-01 first).
//   blocked: NRPT 1X -> Basis (w10-01): 250 mg/d UNSPECIFIED vs 250 mg/d SALT_FORM -> ratio null, verdict PARTIAL.
//   allowed: NIAGEN 300 arm (NCT02712593) -> Tru Niagen 300 mg with a one-capsule-daily UseContextProfile:
//            300 mg/d SALT_FORM vs 300 mg/d SALT_FORM -> ratio 1.0 (identity; no band), verdict MATCH.
// Real facts retrieved 2026-10-04: Conze et al. Methods "100 mg or 250 mg of NR chloride" capsules (PubMed connector,
// PMC6611812); Tru Niagen 300mg Supplement Facts and directions (Tavily extract). The re-assessment resolves the
// inherited v1 missing fact 'mass basis of "300 mg NR" in the paper' and SUPERSEDES that v1 {RE_REVIEW}.
// Generated by gen_w10.py.
// =====================================================================================================================""", s)

# ================================================================================================= FILE 03
EC = {
 "hyperV2": "hu:endpoint-classification:w10-ldl-c-fda-hypercholesterolemia-lipid-lowering-v2",
 "lal": "hu:endpoint-classification:w10-ldl-c-fda-lal-deficiency-enzyme",
 "pdrp": "hu:endpoint-classification:w10-nadpark-pdrp-fdg-pet",
 "updrs": "hu:endpoint-classification:w10-nadpark-mds-updrs",
}
def file03():
    s = []
    s.append(capture("hu:source:fda-surrogate-endpoint-table", "https://www.fda.gov/drugs/development-resources/table-surrogate-endpoints-were-basis-drug-approval-or-licensure",
                     "REGULATORY_GUIDANCE", "hu:snapshot:fda-surrogate-table-2026-10-04",
                     [("hu:locator:fda-surrogate-table-2026-10-04-hypercholesterolemia-row", "TEXT_QUOTE", "Table 1. Adult Surrogate Endpoints - Non-Cancer Related", "fda-row-hypercholesterolemia"),
                      ("hu:locator:fda-surrogate-table-2026-10-04-lal-row", "TEXT_QUOTE", "Table 1. Adult Surrogate Endpoints - Non-Cancer Related", "fda-row-lal"),
                      ("hu:locator:fda-surrogate-table-2026-10-04-context-dependent", "TEXT_QUOTE", "What are the key considerations of the surrogate endpoint table?", "fda-context-dependent")],
                     published="2026-04-29"))
    s.append(capture("hu:source:fda-about-biomarkers-and-qualification", "https://www.fda.gov/drugs/biomarker-qualification-program/about-biomarkers-and-qualification",
                     "REGULATORY_GUIDANCE", "hu:snapshot:fda-about-biomarkers-2026-10-04",
                     [("hu:locator:fda-about-biomarkers-2026-10-04-best-categories", "TEXT_QUOTE", "Biomarker Categories: BEST Glossary", "fda-best-categories")]))
    s.append(capture("hu:source:ctgov-nct03816020", "https://clinicaltrials.gov/study/NCT03816020", "REGULATORY_RECORD", "hu:snapshot:ctgov-nct03816020-2026-10-04",
                     [("hu:locator:ctgov-nct03816020-2026-10-04-primary-outcome", "TEXT_QUOTE", "Primary Outcome Measures", "nadpark-primary"),
                      ("hu:locator:ctgov-nct03816020-2026-10-04-secondary-outcome", "TEXT_QUOTE", "Secondary Outcome Measures", "nadpark-secondary")]))
    s.append(capture("hu:source:doi-10.1016-j.cmet.2022.02.001", "https://doi.org/10.1016/j.cmet.2022.02.001", "PEER_REVIEWED_PUBLICATION", "hu:snapshot:pmid35235774-abstract-2026-10-04",
                     [("hu:locator:pmid35235774-abstract-responders", "TEXT_QUOTE", "Abstract", "nadpark-abstract-responders")], published="2022-03-01"))
    # NADPARK study shapes (W09 types; fixture content only)
    s.append(stmt(f"""
MERGE (st:Study {{uid: 'hu:study:nct03816020-nadpark'}})
  ON CREATE SET st.id = 'nct03816020-nadpark', st.entityType = 'Study', st.name = 'NADPARK: nicotinamide riboside in drug-naive Parkinson disease',
    st.studyKind = 'INTERVENTIONAL_RANDOMIZED', st.createdAt = datetime({q(T0)}), st.privacyClass = 'PUBLIC'
SET st:Entity
WITH st
UNWIND [
  {{uid: 'hu:outcome:nadpark-pdrp-fdg-pet', name: 'Between-group difference in Parkinson disease related pattern (PDRP), FDG-PET, baseline to 3-4 weeks', mk: 'BIOMARKER', tp: '4 weeks'}},
  {{uid: 'hu:outcome:nadpark-mds-updrs', name: 'Motor symptom change measured by MDS-UPDRS', mk: 'CLINICIAN_REPORTED_OUTCOME', tp: '4 weeks'}}
] AS r
MERGE (od:OutcomeDefinition {{uid: r.uid}})
  ON CREATE SET od.id = split(r.uid, ':')[2], od.stateType = 'OutcomeDefinition', od.payloadHash = 'sha256:' + split(r.uid, ':')[2],
    od.name = r.name, od.measureKind = r.mk, od.timepoint = r.tp, od.createdAt = datetime({q(T0)}), od.privacyClass = 'PUBLIC'
SET od:VersionedState
MERGE (st)-[:DEFINES_OUTCOME]->(od)"""))
    a_pr = "hu:assertion:w10-nadpark-pdrp-priority-registry"; a_se = "hu:assertion:w10-nadpark-updrs-priority-registry"
    s.append(assertion(a_pr, "DECLARES_OUTCOME_PRIORITY", "hu:outcome:nadpark-pdrp-fdg-pet", literal=("valueString", "PRIMARY"), locs=["hu:locator:ctgov-nct03816020-2026-10-04-primary-outcome"]))
    s.append(assertion(a_se, "DECLARES_OUTCOME_PRIORITY", "hu:outcome:nadpark-mds-updrs", literal=("valueString", "SECONDARY"), locs=["hu:locator:ctgov-nct03816020-2026-10-04-secondary-outcome"]))
    s.append(capture_policy("hu:adjudication:w10-fixture-03-capture-policy", [a_pr, a_se]))
    # FDA general contexts (CLASSIFIES_BIOMARKER). v2 of the inherited hypercholesterolemia context re-anchored to a TEXT_QUOTE row.
    def ec_stmt(uid, props, rels):
        ps = assessment_props("ec", uid, "EndpointClassification", "endpoint-class-v0.1", extra=props)
        lines = [f"MERGE (ec:EndpointClassification {{uid: {q(uid)}}})", f"  ON CREATE SET {ps}", "SET ec:EvidenceAssessment", "WITH ec"]
        for i, (rel, target) in enumerate(rels):
            lines += [f"MATCH (t{i} {{uid: {q(target)}}})", f"MERGE (ec)-[:{rel}]->(t{i})", f"WITH ec"]
        lines = lines[:-1]
        return stmt("\n".join(lines))
    s.append(ec_stmt(EC["hyperV2"], dict(endpointClass="SURROGATE_ENDPOINT", biomarkerCategory=None, surrogateValidationLevel="VALIDATED",
        contextDiseaseOrUse="Hypercholesterolemia", contextPopulation="Patients with heterozygous familial and nonfamilial hypercholesterolemia",
        contextInterventionMechanism="Lipid-lowering", contextApprovalType="TRADITIONAL", contextMatch=None,
        rationale="FDA surrogate endpoint table row (2026-04-29 revision): serum LDL cholesterol, traditional approval, lipid-lowering mechanism. FD&C Act 507(e)(9): traditional = known to predict clinical benefit."),
        [("CLASSIFIES_BIOMARKER", INH["ldlBm"]), ("SUPPORTED_BY", "hu:locator:fda-surrogate-table-2026-10-04-hypercholesterolemia-row"),
         ("SUPPORTED_BY", "hu:locator:fda-surrogate-table-2026-10-04-context-dependent")]))
    s.append(stmt(f"""
MATCH (newer:EndpointClassification {{uid: {q(EC['hyperV2'])}}}), (older:EndpointClassification {{uid: {q(INH['ecFdaHyper'])}}})
MERGE (newer)-[r:SUPERSEDES]->(older)
  ON CREATE SET r.supersessionKind = 'RE_REVIEW', r.recordedAt = newer.recordedAt
SET older.recordedTo = coalesce(older.recordedTo, newer.recordedAt)"""))
    s.append(ec_stmt(EC["lal"], dict(endpointClass="SURROGATE_ENDPOINT", biomarkerCategory=None, surrogateValidationLevel="VALIDATED",
        contextDiseaseOrUse="Lysosomal Acid Lipase (LAL) deficiency", contextPopulation="Patients with LAL deficiency",
        contextInterventionMechanism="Hydrolytic lysosomal cholesteryl ester and triacylglycerol-specific enzyme", contextApprovalType="TRADITIONAL", contextMatch=None,
        rationale="Same analyte (serum LDL-C), different disease and mechanism: a second, separate context of use."),
        [("CLASSIFIES_BIOMARKER", INH["ldlBm"]), ("SUPPORTED_BY", "hu:locator:fda-surrogate-table-2026-10-04-lal-row")]))
    s.append(ec_stmt(EC["pdrp"], dict(endpointClass="BIOMARKER_NOT_SURROGATE", biomarkerCategory="PHARMACODYNAMIC_RESPONSE", surrogateValidationLevel="NOT_ESTABLISHED",
        contextDiseaseOrUse="Parkinson disease (drug-naive, newly diagnosed)", contextPopulation="Newly diagnosed drug-naive PD patients", contextInterventionMechanism="NAD+ precursor (nicotinamide riboside)",
        contextApprovalType=None, contextMatch="NONE",
        rationale="Imaging pattern used as the registered primary outcome to detect a response to NR; no Parkinson disease row exists in the retrieved FDA table (absence in one table is not proof that no context exists anywhere)."),
        [("CLASSIFIES_OUTCOME", "hu:outcome:nadpark-pdrp-fdg-pet"), ("SUPPORTED_BY", "hu:locator:ctgov-nct03816020-2026-10-04-primary-outcome"),
         ("SUPPORTED_BY", "hu:locator:fda-about-biomarkers-2026-10-04-best-categories")]))
    s.append(ec_stmt(EC["updrs"], dict(endpointClass="CLINICAL_OUTCOME", biomarkerCategory=None, surrogateValidationLevel=None,
        contextDiseaseOrUse="Parkinson disease", contextPopulation="Newly diagnosed drug-naive PD patients", contextInterventionMechanism=None, contextApprovalType=None, contextMatch=None,
        rationale="MDS-UPDRS is a clinician-reported clinical outcome assessment of motor function (how a patient functions); registered as secondary. A biomarker primary with a clinical secondary: the secondary is the patient-important outcome."),
        [("CLASSIFIES_OUTCOME", "hu:outcome:nadpark-mds-updrs"), ("SUPPORTED_BY", "hu:locator:ctgov-nct03816020-2026-10-04-secondary-outcome")]))
    write("w10-03-surrogate-context.cypher", """
// =====================================================================================================================
// W10 fixture 03: surrogate status is bound to a context of use and does not transfer (INV-205). Load the inherited
// study-vs-product-mismatch.cypher first (it holds the NRPT LDL-C outcome classified BIOMARKER_NOT_SURROGATE / SAFETY with
// contextMatch PARTIAL against the FDA hypercholesterolemia context).
// Adds: the FDA table rows as TEXT_QUOTE locators (Firecrawl scrape 2026-10-04, page revision 2026-04-29) - LDL-C appears
// in TWO contexts (hypercholesterolemia / lipid-lowering; LAL deficiency / enzyme replacement), each its own
// EndpointClassification; a v2 of the inherited hypercholesterolemia context SUPERSEDES {RE_REVIEW} v1 to cite the row
// span instead of a SECTION locator; NADPARK (NCT03816020): registered biomarker primary (FDG-PET PDRP ->
// BIOMARKER_NOT_SURROGATE, PHARMACODYNAMIC_RESPONSE, NOT_ESTABLISHED) and clinical secondary (MDS-UPDRS -> CLINICAL_OUTCOME).
// Expected: V-214, V-214b, W10-V08 zero rows. Generated by gen_w10.py.
// =====================================================================================================================""", s)

# ================================================================================================= FILE 04
ATL = {
 "src_reg": "hu:source:ctgov-nct03464500", "src_pmc": "hu:source:pmc9133463",
 "loc_out": "hu:locator:ctgov-nct03464500-2026-10-04-outcomes", "loc_null": "hu:locator:pmc9133463-abstract-primary-null",
 "loc_ham": "hu:locator:pmc9133463-results-hamstring", "loc_cm": "hu:locator:pmc9133463-abstract-clinically-meaningful",
 "study": "hu:study:nct03464500-atlas", "od_pow": "hu:outcome:atlas-power-output-d120", "od_str": "hu:outcome:atlas-isokinetic-strength-d120", "od_6mwt": "hu:outcome:atlas-6mwt-d120",
 "r_pow": "hu:study-result:atlas-power-ua-vs-placebo-d120", "r_ham": "hu:study-result:atlas-hamstring-ua500-vs-placebo",
 "r_ham_wa": "hu:study-result:atlas-hamstring-ua500-within-arm", "r_6mwt": "hu:study-result:atlas-6mwt-ua-vs-placebo",
 "r_sub": "hu:study-result:atlas-synthetic-subgroup-low-vo2max", "a_cm": "hu:assertion:atlas-6mwt-clinically-meaningful-authors",
}
ATL_EXACT = {
 "loc_null": "do not notice a significant improvement on peak power output (primary endpoint)",
 "loc_ham": "Average peak torque in the hamstring skeletal muscle was significantly increased in both UA 500 mg (+12%, p = 0.027 compared with placebo)",
 "loc_cm": "We observe clinically meaningful improvements with Urolithin A on aerobic endurance (peak oxygen oxygen consumption [VO2]) and physical performance (6 min walk test)",
}
ATL_HASH = {"loc_null": "sha256:15185dddbee081a05c11051274191ba86fd35b8ad6a4245c45b688a546221e61",
            "loc_ham": "sha256:2b7331f868baaaf7a53b8191dd4fbca6bd358e00c5d7e52edc00cdded41cb536",
            "loc_cm": "sha256:35b5cbe6f58f8b50224f79b5a9fd0bc3cbb5c38fb1c690149adb137f98de8e93"}
SYN_UA = "hu:synthesis:w10-ua-muscle-function-middle-aged-v1"
CLAIM_UA = "hu:claim:w10-ua-improves-muscle-function-middle-aged"
RI_POW = "hu:assessment:w10-ri-atlas-power-primary"
RI_6MWT = "hu:assessment:w10-ri-atlas-6mwt"

def file04():
    s = []
    # Locators inherited from W09 fixture 02 (same uids, same exact text and hashes); MERGE so either file may load first.
    for key in ["loc_null", "loc_ham", "loc_cm"]:
        h = hashlib.sha256(nfcws1(ATL_EXACT[key]).encode()).hexdigest()
        assert "sha256:" + h == ATL_HASH[key], key
    s.append(stmt(f"""
MERGE (src:Source {{uid: {q(ATL['src_pmc'])}}})
  ON CREATE SET src.id = 'pmc9133463', src.entityType = 'Source', src.canonicalUri = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC9133463/', src.sourceKind = 'PEER_REVIEWED_PUBLICATION',
    src.createdAt = datetime({q(T0)}), src.privacyClass = 'PUBLIC'
SET src:Entity
MERGE (snap:SourceSnapshot {{uid: 'hu:snapshot:pmc9133463-2026-10-04'}})
  ON CREATE SET snap.id = 'pmc9133463-2026-10-04', snap.artifactType = 'SourceSnapshot', snap.canonicalUri = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC9133463/',
    snap.retrievedAt = datetime('2026-10-04T00:58:00Z'), snap.observedAt = datetime('2026-10-04T00:58:00Z'), snap.contentHash = 'synthetic:hu:snapshot:pmc9133463-2026-10-04',
    snap.contentHashBasis = 'SYNTHETIC_FIXTURE', snap.captureCompleteness = 'PARTIAL_EXCERPT', snap.createdAt = datetime({q(T0)}), snap.privacyClass = 'PUBLIC'
SET snap:InformationArtifact
MERGE (src)-[:HAS_SNAPSHOT]->(snap)
WITH snap
UNWIND [
  {{uid: {q(ATL['loc_null'])}, section: 'Summary', exact: {q(ATL_EXACT['loc_null'])}, h: {q(ATL_HASH['loc_null'])}}},
  {{uid: {q(ATL['loc_ham'])}, section: 'Results: muscle strength', exact: {q(ATL_EXACT['loc_ham'])}, h: {q(ATL_HASH['loc_ham'])}}},
  {{uid: {q(ATL['loc_cm'])}, section: 'Summary', exact: {q(ATL_EXACT['loc_cm'])}, h: {q(ATL_HASH['loc_cm'])}}}
] AS r
MERGE (l:SourceLocator {{uid: r.uid}})
  ON CREATE SET l.id = split(r.uid, ':')[2], l.artifactType = 'SourceLocator', l.uri = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC9133463/', l.selectorKind = 'TEXT_QUOTE',
    l.section = r.section, l.exact = r.exact, l.quoteHash = r.h, l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime({q(T0)}), l.privacyClass = 'PUBLIC'
SET l:InformationArtifact
MERGE (snap)-[:HAS_LOCATOR]->(l)"""))
    s.append(stmt(f"""
MERGE (st:Study {{uid: {q(ATL['study'])}}})
  ON CREATE SET st.id = 'nct03464500-atlas', st.entityType = 'Study', st.name = 'ATLAS: urolithin A (Mitopure) in middle-aged overweight adults',
    st.studyKind = 'INTERVENTIONAL_RANDOMIZED', st.createdAt = datetime({q(T0)}), st.privacyClass = 'PUBLIC'
SET st:Entity
WITH st
UNWIND [
  {{uid: {q(ATL['od_pow'])}, name: 'Change in power output on cycle ergometer, baseline to day 120', mk: 'PERFORMANCE_OUTCOME'}},
  {{uid: {q(ATL['od_str'])}, name: 'Change in isokinetic lower body muscle strength, baseline to day 120', mk: 'PERFORMANCE_OUTCOME'}},
  {{uid: {q(ATL['od_6mwt'])}, name: 'Change in 6-minute walk distance, baseline to day 120', mk: 'PERFORMANCE_OUTCOME'}}
] AS r
MERGE (od:OutcomeDefinition {{uid: r.uid}})
  ON CREATE SET od.id = split(r.uid, ':')[2], od.stateType = 'OutcomeDefinition', od.payloadHash = 'sha256:synthetic-' + split(r.uid, ':')[2],
    od.name = r.name, od.measureKind = r.mk, od.timepoint = '4 months', od.createdAt = datetime({q(T0)}), od.privacyClass = 'PUBLIC'
SET od:VersionedState
MERGE (st)-[:DEFINES_OUTCOME]->(od)"""))
    s.append(stmt(f"""
UNWIND [
  {{uid: {q(ATL['r_pow'])}, od: {q(ATL['od_pow'])}, ak: 'PRIMARY_PRESPECIFIED', ck: 'BETWEEN_ARM', sc: 'NOT_SIGNIFICANT', loc: {q(ATL['loc_null'])}, name: null}},
  {{uid: {q(ATL['r_ham'])}, od: {q(ATL['od_str'])}, ak: 'SECONDARY_PRESPECIFIED', ck: 'BETWEEN_ARM', sc: 'SIGNIFICANT_FAVORABLE', loc: {q(ATL['loc_ham'])}, name: null}},
  {{uid: {q(ATL['r_ham_wa'])}, od: {q(ATL['od_str'])}, ak: 'SECONDARY_PRESPECIFIED', ck: 'WITHIN_ARM_CHANGE', sc: 'NOT_REPORTED', loc: {q(ATL['loc_ham'])}, name: null}},
  {{uid: {q(ATL['r_6mwt'])}, od: {q(ATL['od_6mwt'])}, ak: 'SECONDARY_PRESPECIFIED', ck: 'BETWEEN_ARM', sc: 'NOT_REPORTED', loc: {q(ATL['loc_cm'])}, name: null}},
  {{uid: {q(ATL['r_sub'])}, od: {q(ATL['od_pow'])}, ak: 'SUBGROUP_POST_HOC', ck: 'BETWEEN_ARM', sc: 'SIGNIFICANT_FAVORABLE', loc: null, name: 'SYNTHETIC subgroup (not from any source; W09 fixture 02 device)'}}
] AS r
MATCH (od:OutcomeDefinition {{uid: r.od}})
MERGE (res:StudyResult {{uid: r.uid}})
  ON CREATE SET res.id = split(r.uid, ':')[2], res.artifactType = 'StudyResult', res.name = r.name, res.analysisKind = r.ak, res.comparisonKind = r.ck,
    res.statisticalConclusion = r.sc, res.createdAt = datetime({q(T0)}), res.privacyClass = 'PUBLIC'
SET res:InformationArtifact
MERGE (res)-[:RESULT_FOR]->(od)
WITH res, r
MATCH (l:SourceLocator {{uid: coalesce(r.loc, 'none')}})
MERGE (res)-[:SUPPORTED_BY]->(l)"""))
    s.append(assertion(ATL["a_cm"], "RESULT_CLINICALLY_MEANINGFUL", ATL["r_6mwt"], literal=("valueBoolean", True), locs=[ATL["loc_cm"]],
                       extra={"assertionBasis": "STUDY_RESULT", "speechAct": "STATES"}))
    s.append(capture_policy("hu:adjudication:w10-fixture-04-capture-policy", [ATL["a_cm"]]))
    # ResultInterpretations
    for uid, res, interp, mv, summ in [
        (RI_POW, ATL["r_pow"], "INCONCLUSIVE", "UNDETERMINED", "Primary peak power output not significant; no equivalence margin or MCID source in the packet, so not EVIDENCE_OF_NO_MEANINGFUL_EFFECT."),
        (RI_6MWT, ATL["r_6mwt"], "INCONCLUSIVE", "UNDETERMINED", "Authors call the 6MWT change clinically meaningful (Assertion); the quoted span gives no between-arm test and no MCID source is linked, so BellLabs meaningfulness is UNDETERMINED.")]:
        ps = assessment_props("ri", uid, "ResultInterpretation", "result-interpretation-v0.1",
                              extra={"interpretation": interp, "meaningfulnessVerdict": mv, "thresholdValue": None, "thresholdUnit": None, "rationale": summ})
        s.append(stmt(f"""
MATCH (res:StudyResult {{uid: {q(res)}}})
MERGE (ri:ResultInterpretation {{uid: {q(uid)}}})
  ON CREATE SET {ps}
SET ri:EvidenceAssessment
MERGE (ri)-[:INTERPRETS_RESULT_OF]->(res)"""))
    s.append(stmt(f"""
MERGE (c:Claim {{uid: {q(CLAIM_UA)}}})
  ON CREATE SET c.id = {q(oid(CLAIM_UA))}, c.entityType = 'Claim', c.claimText = 'Urolithin A 500-1000 mg/day for 4 months improves muscle function in middle-aged adults',
    c.createdAt = datetime({q(T0)}), c.privacyClass = 'PUBLIC'
SET c:Entity"""))
    ps = assessment_props("syn", SYN_UA, "EvidenceSynthesis", "synthesis-v0.1",
        extra={"claimText": "Urolithin A 500-1000 mg/day for 4 months improves muscle function in middle-aged adults", "verdict": "INSUFFICIENT",
               "rationale": "Null primary (peak power output) is the confirmatory input; a favorable secondary between-arm strength result is supportive only; a post hoc subgroup is hypothesis-generating only (INV-206). The within-arm +12% is not an input."})
    s.append(stmt(f"""
MATCH (c:Claim {{uid: {q(CLAIM_UA)}}})
MERGE (syn:EvidenceSynthesis {{uid: {q(SYN_UA)}}})
  ON CREATE SET {ps}, syn.evidenceCutoff = date('2022-05-31')
SET syn:EvidenceAssessment
MERGE (syn)-[:ASSESSES_CLAIM]->(c)"""))
    s.append(stmt(f"""
MATCH (syn:EvidenceSynthesis {{uid: {q(SYN_UA)}}})
UNWIND [
  {{r: {q(ATL['r_pow'])}, role: 'CONFIRMATORY'}},
  {{r: {q(ATL['r_ham'])}, role: 'SUPPORTIVE'}},
  {{r: {q(ATL['r_sub'])}, role: 'HYPOTHESIS_GENERATING'}}
] AS x
MATCH (res:StudyResult {{uid: x.r}})
MERGE (syn)-[i:INCLUDES_RESULT]->(res)
  ON CREATE SET i.inputRole = x.role"""))
    write("w10-04-null-primary-synthesis.cypher", """
// =====================================================================================================================
// W10 fixture 04: null primary with a favorable secondary and a favorable post hoc subgroup (INV-206) and the
// clinically-meaningful minimal pair (CQ-ST-10). Standalone; MERGEs the ATLAS shapes with the same uids as
// W09 fixtures/02-null-primary-favorable-secondary.cypher (quotes and hashes copied from that file: INHERITED, retrieved by
// W09 2026-10-04). The subgroup result is SYNTHETIC (W09's device; no subgroup was retrieved).
// Expected: V-215, V-216 zero rows; W10-V09, W10-V10, W10-V11, W10-V11b zero rows. Generated by gen_w10.py.
// =====================================================================================================================""", s)

# ================================================================================================= FILE 05
VD = {
 "claim": "hu:claim:w10-vitamin-d-prevents-acute-respiratory-infection",
 "p17": "hu:publication:pmid-28202713", "p21": "hu:publication:pmid-33798465", "p25": "hu:publication:pmid-39993397",
 "a17": "hu:assertion:w10-pmid28202713-pooled-or-any-ari", "a21": "hu:assertion:w10-pmid33798465-pooled-or-any-ari",
 "a25": "hu:assertion:w10-pmid39993397-pooled-or-any-ari", "a25s": "hu:assertion:w10-pmid39993397-subgroup-age-1-15-or",
 "v1": "hu:synthesis:w10-vitamin-d-ari-prevention-v1", "v2": "hu:synthesis:w10-vitamin-d-ari-prevention-v2", "v3": "hu:synthesis:w10-vitamin-d-ari-prevention-v3",
 "es1": "hu:assessment:w10-strength-vitamin-d-ari-v1-grade-as-reported", "es3": "hu:assessment:w10-strength-vitamin-d-ari-v3-grade-as-reported",
}
def file05():
    s = []
    caps = [("hu:source:doi-10.1136-bmj.i6583", "https://doi.org/10.1136/bmj.i6583", "hu:snapshot:pmid28202713-abstract-2026-10-04", "2017-02-15",
             [("hu:locator:pmid28202713-abstract-pooled-or", "TEXT_QUOTE", "Abstract: Results", "martineau-2017-or"),
              ("hu:locator:pmid28202713-abstract-quality", "TEXT_QUOTE", "Abstract: Results", "martineau-2017-quality")]),
            ("hu:source:doi-10.1016-s2213-8587-21-00051-6", "https://doi.org/10.1016/S2213-8587(21)00051-6", "hu:snapshot:pmid33798465-abstract-2026-10-04", "2021-03-30",
             [("hu:locator:pmid33798465-abstract-pooled-or", "TEXT_QUOTE", "Abstract: Findings", "jolliffe-2021-or")]),
            ("hu:source:doi-10.1016-s2213-8587-24-00348-6", "https://doi.org/10.1016/S2213-8587(24)00348-6", "hu:snapshot:pmc12056739-2026-10-04", "2025-02-21",
             [("hu:locator:pmc12056739-findings-pooled-or", "TEXT_QUOTE", "Summary: Findings", "jolliffe-2025-or"),
              ("hu:locator:pmc12056739-results-subgroup-age-1-15", "TEXT_QUOTE", "Results", "jolliffe-2025-subgroup"),
              ("hu:locator:pmc12056739-results-grade-moderate", "TEXT_QUOTE", "Results", "jolliffe-2025-grade"),
              ("hu:locator:pmc12056739-interpretation", "TEXT_QUOTE", "Summary: Interpretation", "jolliffe-2025-interpretation")])]
    for src, uri, snap, pub, locs in caps:
        s.append(capture(src, uri, "PEER_REVIEWED_PUBLICATION", snap, locs, published=pub))
    s.append(stmt(f"""
UNWIND [
  {{uid: {q(VD['p17'])}, pmid: '28202713', doi: '10.1136/bmj.i6583', at: '2017-02-15', name: 'Vitamin D supplementation to prevent acute respiratory tract infections: systematic review and meta-analysis of individual participant data'}},
  {{uid: {q(VD['p21'])}, pmid: '33798465', doi: '10.1016/S2213-8587(21)00051-6', at: '2021-03-30', name: 'Vitamin D supplementation to prevent acute respiratory infections: a systematic review and meta-analysis of aggregate data from randomised controlled trials'}},
  {{uid: {q(VD['p25'])}, pmid: '39993397', doi: '10.1016/S2213-8587(24)00348-6', at: '2025-02-21', name: 'Vitamin D supplementation to prevent acute respiratory infections: systematic review and meta-analysis of stratified aggregate data'}}
] AS r
MERGE (p:Publication {{uid: r.uid}})
  ON CREATE SET p.id = split(r.uid, ':')[2], p.artifactType = 'Publication', p.publicationKind = 'ARTICLE', p.name = r.name, p.pmid = r.pmid, p.doi = r.doi,
    p.publishedAt = datetime(r.at + 'T00:00:00Z'), p.publishedAtPrecision = 'DAY', p.createdAt = datetime({q(T0)}), p.privacyClass = 'PUBLIC'
SET p:InformationArtifact"""))
    s.append(stmt(f"""
MERGE (c:Claim {{uid: {q(VD['claim'])}}})
  ON CREATE SET c.id = {q(oid(VD['claim']))}, c.entityType = 'Claim', c.claimText = 'Vitamin D supplementation reduces the risk of acute respiratory infection',
    c.createdAt = datetime({q(T0)}), c.privacyClass = 'PUBLIC'
SET c:Entity"""))
    pred = "REPORTS_POOLED_ESTIMATE"  # CANDIDATE predicate (W10-SR-07): a review's pooled effect estimate, literal OR
    s.append(assertion(VD["a17"], pred, VD["p17"], literal=("valueNumber", 0.88), locs=["hu:locator:pmid28202713-abstract-pooled-or"], extra={"unitCode": "1", "valueString": None}))
    s.append(assertion(VD["a21"], pred, VD["p21"], literal=("valueNumber", 0.92), locs=["hu:locator:pmid33798465-abstract-pooled-or"], extra={"unitCode": "1"}))
    s.append(assertion(VD["a25"], pred, VD["p25"], literal=("valueNumber", 0.94), locs=["hu:locator:pmc12056739-findings-pooled-or"], extra={"unitCode": "1"}))
    s.append(assertion(VD["a25s"], pred, VD["p25"], literal=("valueNumber", 0.74), locs=["hu:locator:pmc12056739-results-subgroup-age-1-15"], extra={"unitCode": "1"}))
    s.append(capture_policy("hu:adjudication:w10-fixture-05-capture-policy", [VD["a17"], VD["a21"], VD["a25"], VD["a25s"]], reviewed="2026-10-04T02:13:00Z"))
    versions = [
        (VD["v1"], "2026-10-04T02:10:00Z", "SUPPORTED", "2017-02-15",
         "2017 IPD meta-analysis of 25 RCTs: adjusted OR 0.88 (0.81-0.96); high-quality evidence per the authors."),
        (VD["v2"], "2026-10-04T02:11:00Z", "SUPPORTED", "2021-03-30",
         "2021 update, 46 RCTs: OR 0.92 (0.86-0.99), p=0.018; still protective, smaller effect, more heterogeneity."),
        (VD["v3"], "2026-10-04T02:12:00Z", "INSUFFICIENT", "2025-02-21",
         "2025 update, 40 studies in the primary comparison: OR 0.94 (0.88-1.00), p=0.057; the CI now includes 1. Age 1-15 subgroup is hypothesis-generating only."),
    ]
    for uid, rec, verdict, cutoff, rat in versions:
        ps = assessment_props("syn", uid, "EvidenceSynthesis", "synthesis-v0.1", status="ACCEPTED", recorded=rec,
                              extra={"claimText": "Vitamin D supplementation reduces the risk of acute respiratory infection", "verdict": verdict, "rationale": rat})
        s.append(stmt(f"""
MATCH (c:Claim {{uid: {q(VD['claim'])}}})
MERGE (syn:EvidenceSynthesis {{uid: {q(uid)}}})
  ON CREATE SET {ps}, syn.evidenceCutoff = date({q(cutoff)})
SET syn:EvidenceAssessment
MERGE (syn)-[:ASSESSES_CLAIM]->(c)"""))
    s.append(stmt(f"""
UNWIND [
  {{syn: {q(VD['v1'])}, a: {q(VD['a17'])}, role: 'CONFIRMATORY'}},
  {{syn: {q(VD['v2'])}, a: {q(VD['a21'])}, role: 'CONFIRMATORY'}},
  {{syn: {q(VD['v3'])}, a: {q(VD['a25'])}, role: 'CONFIRMATORY'}},
  {{syn: {q(VD['v3'])}, a: {q(VD['a25s'])}, role: 'HYPOTHESIS_GENERATING'}}
] AS x
MATCH (syn:EvidenceSynthesis {{uid: x.syn}}), (a:Assertion {{uid: x.a}})
MERGE (syn)-[i:INCLUDES_RESULT]->(a)
  ON CREATE SET i.inputRole = x.role"""))
    s.append(stmt(f"""
UNWIND [
  {{newer: {q(VD['v2'])}, older: {q(VD['v1'])}, pub: {q(VD['p21'])}, crit: 'SYSTEMATIC_REVIEW_UPDATE', eff: 'WEAKENED', at: '2021-03-30'}},
  {{newer: {q(VD['v3'])}, older: {q(VD['v2'])}, pub: {q(VD['p25'])}, crit: 'POOLED_ESTIMATE_CI_INCLUDES_NULL', eff: 'WEAKENED', at: '2025-02-21'}}
] AS x
MATCH (n:EvidenceSynthesis {{uid: x.newer}}), (o:EvidenceSynthesis {{uid: x.older}}), (p:Publication {{uid: x.pub}})
MERGE (n)-[s:SUPERSEDES]->(o)
  ON CREATE SET s.supersessionKind = 'RE_REVIEW', s.recordedAt = n.recordedAt
SET o.recordedTo = coalesce(o.recordedTo, n.recordedAt), o.status = 'SUPERSEDED'
MERGE (n)-[t:TRIGGERED_BY]->(p)
  ON CREATE SET t.criterionCode = x.crit, t.effectOnVerdict = x.eff, t.evidencePublishedAt = date(x.at)"""))
    s.append(stmt(f"""
UNWIND [
  {{syn: {q(VD['v1'])}, locs: ['hu:locator:pmid28202713-abstract-pooled-or']}},
  {{syn: {q(VD['v2'])}, locs: ['hu:locator:pmid33798465-abstract-pooled-or']}},
  {{syn: {q(VD['v3'])}, locs: ['hu:locator:pmc12056739-findings-pooled-or', 'hu:locator:pmc12056739-interpretation']}}
] AS x
MATCH (syn:EvidenceSynthesis {{uid: x.syn}})
UNWIND x.locs AS lu
MATCH (l:SourceLocator {{uid: lu}})
MERGE (syn)-[:SUPPORTED_BY]->(l)"""))
    for uid, syn, level, crit, loc, rec in [
        (VD["es1"], VD["v1"], "high", [], "hu:locator:pmid28202713-abstract-quality", "2026-10-04T02:10:00Z"),
        (VD["es3"], VD["v3"], "moderate", ["publication bias suspected: funnel plot left-sided asymmetry (Egger p=0.0020)"], "hu:locator:pmc12056739-results-grade-moderate", "2026-10-04T02:12:00Z")]:
        ps = assessment_props("es", uid, "EvidenceStrengthAssessment", "grade-as-reported-by-review-v0", status="ACCEPTED", recorded=rec,
                              extra={"scheme": "GRADE", "level": level, "criteria": crit,
                                     "rationale": "Level copied from the review authors' own GRADE statement (not recomputed by BellLabs); method names the copy rule."})
        s.append(stmt(f"""
MATCH (syn:EvidenceSynthesis {{uid: {q(syn)}}}), (l:SourceLocator {{uid: {q(loc)}}})
MERGE (es:EvidenceStrengthAssessment {{uid: {q(uid)}}})
  ON CREATE SET {ps}
SET es:EvidenceAssessment
MERGE (es)-[:ASSESSES_STRENGTH_OF]->(syn)
MERGE (es)-[:SUPPORTED_BY]->(l)"""))
    write("w10-05-synthesis-versioning.cypher", """
// =====================================================================================================================
// W10 fixture 05: a claim-level synthesis re-versioned by new results (CQ-ST-09, KCR-2a). Real record: the vitamin D /
// acute respiratory infection meta-analysis by Martineau, Jolliffe et al., versioned three times by its authors
// (BMJ 2017 PMID 28202713: OR 0.88; Lancet D&E 2021 PMID 33798465: OR 0.92; Lancet D&E 2025 PMID 39993397: OR 0.94, CI
// 0.88-1.00, "no statistically significant protection"; PubMed connector 2026-10-04). BellLabs' synthesis v1 -> v2 -> v3
// SUPERSEDES each predecessor and is TRIGGERED_BY the update publication {criterionCode, effectOnVerdict, evidencePublishedAt}.
// All three versions are RECORDED on 2026-10-04 (recorded time is never backdated, INV-502); the domain chronology lives on
// evidencePublishedAt / evidenceCutoff. The 2025 age 1-15 subgroup enters v3 only as HYPOTHESIS_GENERATING.
// Pooled estimates are Assertions with the CANDIDATE predicate REPORTS_POOLED_ESTIMATE (W10-SR-07).
// Expected: V-219, V-219b, V-219c zero rows; W10-V12, W10-V13 zero rows. Generated by gen_w10.py.
// =====================================================================================================================""", s)

# ================================================================================================= FILE 90 negatives
def file90():
    s = []
    N = lambda n, t, o: f"hu:{t}:w10-n{n:02d}-{o}"
    base_si = N(0, "study-intervention", "si"); base_fv = N(0, "formulation", "fv"); base_st = N(0, "study", "st")
    s.append(stmt(f"""
MERGE (si:StudyIntervention {{uid: {q(base_si)}}}) ON CREATE SET si.id = {q(oid(base_si))}, si.stateType = 'StudyIntervention', si.payloadHash = 'sha256:n00-si', si.name = 'N00 synthetic intervention', si.createdAt = datetime({q(T0)}), si.privacyClass = 'PUBLIC'
SET si:VersionedState
MERGE (fv:FormulationVersion {{uid: {q(base_fv)}}}) ON CREATE SET fv.id = {q(oid(base_fv))}, fv.stateType = 'FormulationVersion', fv.payloadHash = 'sha256:n00-fv', fv.createdAt = datetime({q(T0)}), fv.privacyClass = 'PUBLIC'
SET fv:VersionedState
MERGE (st:Study {{uid: {q(base_st)}}}) ON CREATE SET st.id = {q(oid(base_st))}, st.entityType = 'Study', st.createdAt = datetime({q(T0)}), st.privacyClass = 'PUBLIC'
SET st:Entity"""))
    REQ = ["MATERIAL_IDENTITY", "ACTIVE_COMPOSITION", "DOSE", "DOSAGE_FORM", "ROUTE", "SCHEDULE", "DURATION", "POPULATION", "COMPARATOR", "OUTCOME_RELEVANCE", "STUDY_DESIGN_AND_QUALITY"]
    def full_ea(n, use_target=base_fv, overrides=None, drop=(), overall=None, method="applicability-v0.2-candidate", label=""):
        ea = N(n, "applicability", "ea" + label)
        out = applicability(ea, method, f"N{n:02d} negative case", base_si, use_target, overall=overall)
        rows = []
        for d in REQ:
            if d in drop: continue
            r = dict(dim=d, verdict="NOT_ASSESSED")
            r.update((overrides or {}).get(d, {}))
            rows.append(r)
        out += dimensions(ea, rows)
        return ea, out
    # N01 private-looking UserContext (fixture-device label PrivateRecord) as use target -> V-113, V-524
    s.append(stmt(f"""
MERGE (u:UserContext:PrivateRecord {{uid: 'hu:private-user-context:w10-n01'}})
  ON CREATE SET u.privacyClass = 'private-personal', u.createdAt = datetime({q(T0)})"""))
    ea, out = full_ea(1, use_target="hu:private-user-context:w10-n01"); s += out
    # N02 unlabelled leak: UserContext without the fixture label, private uid prefix -> V-520, V-521, V-524, V-113
    s.append(stmt(f"""
MERGE (u:UserContext {{uid: 'hu:private-user-context:w10-n02'}})
  ON CREATE SET u.privacyClass = 'private-personal', u.createdAt = datetime({q(T0)})"""))
    ea, out = full_ea(2, use_target="hu:private-user-context:w10-n02"); s += out
    # N03 composite score without methodVersion (raw Cypher bypassing the GraphQL non-null) -> V-207b, W10-V05
    ea, out = full_ea(3, overall=0.72); s += out
    s.append(stmt(f"MATCH (ea:EvidenceApplicability {{uid: {q(N(3, 'applicability', 'ea'))}}})\nREMOVE ea.methodVersion"))
    # N04 composite with method but a required dimension missing -> V-204, W10-V05
    ea, out = full_ea(4, overall=0.81, drop=("POPULATION",)); s += out
    # N05 ratio across mismatched mass basis -> V-206, W10-V03 no (arith ok)
    ea, out = full_ea(5, overrides={"DOSE": dict(verdict="PARTIAL", evidenceValue=250.0, targetValue=250.0, unitCode="mg/d", evidenceQuantityBasis="PER_DAY",
        targetQuantityBasis="PER_DAY", evidenceMassBasis="UNSPECIFIED", targetMassBasis="SALT_FORM", ratio=1.0, rationale="N05: ratio computed across UNSPECIFIED vs SALT_FORM")}); s += out
    # N06 DOSE MATCH with ratio null -> V-206
    ea, out = full_ea(6, overrides={"DOSE": dict(verdict="MATCH", evidenceValue=300.0, targetValue=300.0, unitCode="mg", evidenceQuantityBasis="PER_DAY",
        targetQuantityBasis="PER_SERVING", evidenceMassBasis="SALT_FORM", targetMassBasis="SALT_FORM", ratio=None, rationale="N06: nominal amounts equal, bases differ")}); s += out
    # N07 explanation-only dimension scored -> V-207
    ea7 = N(7, "applicability", "ea")
    ea, out = full_ea(7); s += out
    s += dimensions(ea7, [dict(dim="BACKGROUND_CONTEXT", verdict="PARTIAL", rationale="N07: explanation-only dimension given a score")])
    # N08 surrogate transfer: study-specific classification copies VALIDATED from a non-matching context -> W10-V08
    ec_ctx = N(8, "endpoint-classification", "ctx"); ec_bad = N(8, "endpoint-classification", "transferred"); od8 = N(8, "outcome", "ldl")
    s.append(stmt(f"""
MERGE (od:OutcomeDefinition {{uid: {q(od8)}}}) ON CREATE SET od.id = {q(oid(od8))}, od.stateType = 'OutcomeDefinition', od.payloadHash = 'sha256:n08', od.measureKind = 'BIOMARKER', od.createdAt = datetime({q(T0)}), od.privacyClass = 'PUBLIC'
SET od:VersionedState
MERGE (ctx:EndpointClassification {{uid: {q(ec_ctx)}}})
  ON CREATE SET {assessment_props('ctx', ec_ctx, 'EndpointClassification', 'endpoint-class-v0.1', extra=dict(endpointClass='SURROGATE_ENDPOINT', surrogateValidationLevel='VALIDATED', contextDiseaseOrUse='Hypercholesterolemia', contextInterventionMechanism='Lipid-lowering', contextApprovalType='TRADITIONAL'))}
SET ctx:EvidenceAssessment
MERGE (bad:EndpointClassification {{uid: {q(ec_bad)}}})
  ON CREATE SET {assessment_props('bad', ec_bad, 'EndpointClassification', 'endpoint-class-v0.1', extra=dict(endpointClass='SURROGATE_ENDPOINT', surrogateValidationLevel='VALIDATED', contextDiseaseOrUse='Healthy older adults (NAD+ precursor trial)', contextInterventionMechanism='NAD+ precursor', contextMatch='PARTIAL'))}
SET bad:EvidenceAssessment
MERGE (bad)-[:CLASSIFIES_OUTCOME]->(od)
MERGE (bad)-[:COMPARED_WITH_CONTEXT]->(ctx)"""))
    # N09 surrogate status on a Biomarker -> V-214b
    bm9 = N(9, "biomarker", "ldl")
    s.append(stmt(f"""
MERGE (b:Biomarker {{uid: {q(bm9)}}}) ON CREATE SET b.id = {q(oid(bm9))}, b.entityType = 'Biomarker', b.surrogateValidationLevel = 'VALIDATED', b.createdAt = datetime({q(T0)}), b.privacyClass = 'PUBLIC'
SET b:Entity"""))
    # N10 subgroup CONFIRMATORY after null primary -> V-215, W10-V11 ; N11 post hoc subgroup SUPPORTIVE -> W10-V11b
    for n, role in [(10, "CONFIRMATORY"), (11, "SUPPORTIVE")]:
        st = N(n, "study", "st"); od = N(n, "outcome", "od"); rp = N(n, "study-result", "primary"); rs = N(n, "study-result", "subgroup"); syn = N(n, "synthesis", "syn")
        ps = assessment_props("syn", syn, "EvidenceSynthesis", "synthesis-v0.1", extra=dict(verdict="SUPPORTED", claimText=f"N{n:02d} claim"))
        s.append(stmt(f"""
MERGE (st:Study {{uid: {q(st)}}}) ON CREATE SET st.id = {q(oid(st))}, st.entityType = 'Study', st.createdAt = datetime({q(T0)}), st.privacyClass = 'PUBLIC'
SET st:Entity
MERGE (od:OutcomeDefinition {{uid: {q(od)}}}) ON CREATE SET od.id = {q(oid(od))}, od.stateType = 'OutcomeDefinition', od.payloadHash = 'sha256:{n}', od.createdAt = datetime({q(T0)}), od.privacyClass = 'PUBLIC'
SET od:VersionedState
MERGE (st)-[:DEFINES_OUTCOME]->(od)
MERGE (p:StudyResult {{uid: {q(rp)}}}) ON CREATE SET p.id = {q(oid(rp))}, p.artifactType = 'StudyResult', p.analysisKind = 'PRIMARY_PRESPECIFIED', p.comparisonKind = 'BETWEEN_ARM', p.statisticalConclusion = 'NOT_SIGNIFICANT', p.createdAt = datetime({q(T0)}), p.privacyClass = 'PUBLIC'
SET p:InformationArtifact
MERGE (g:StudyResult {{uid: {q(rs)}}}) ON CREATE SET g.id = {q(oid(rs))}, g.artifactType = 'StudyResult', g.analysisKind = 'SUBGROUP_POST_HOC', g.comparisonKind = 'BETWEEN_ARM', g.statisticalConclusion = 'SIGNIFICANT_FAVORABLE', g.createdAt = datetime({q(T0)}), g.privacyClass = 'PUBLIC'
SET g:InformationArtifact
MERGE (p)-[:RESULT_FOR]->(od)
MERGE (g)-[:RESULT_FOR]->(od)
MERGE (syn:EvidenceSynthesis {{uid: {q(syn)}}}) ON CREATE SET {ps}
SET syn:EvidenceAssessment
MERGE (syn)-[i1:INCLUDES_RESULT]->(p) ON CREATE SET i1.inputRole = 'CONFIRMATORY'
MERGE (syn)-[i2:INCLUDES_RESULT]->(g) ON CREATE SET i2.inputRole = {q(role)}"""))
    # N12 TRIGGERED_BY without effectOnVerdict and without a predecessor -> V-219b, V-219c
    syn12 = N(12, "synthesis", "syn"); pub12 = N(12, "publication", "pub")
    ps = assessment_props("syn", syn12, "EvidenceSynthesis", "synthesis-v0.1", extra=dict(verdict="INSUFFICIENT", claimText="N12 claim"))
    s.append(stmt(f"""
MERGE (p:Publication {{uid: {q(pub12)}}}) ON CREATE SET p.id = {q(oid(pub12))}, p.artifactType = 'Publication', p.createdAt = datetime({q(T0)}), p.privacyClass = 'PUBLIC'
SET p:InformationArtifact
MERGE (syn:EvidenceSynthesis {{uid: {q(syn12)}}}) ON CREATE SET {ps}
SET syn:EvidenceAssessment
MERGE (syn)-[t:TRIGGERED_BY]->(p) ON CREATE SET t.criterionCode = 'NEW_RANDOMIZED_PRIMARY_RESULT'"""))
    # N13 direct Study -> Product shortcut -> V-201
    pr13 = N(13, "product", "p")
    s.append(stmt(f"""
MATCH (st:Study {{uid: {q(base_st)}}})
MERGE (p:Product {{uid: {q(pr13)}}}) ON CREATE SET p.id = {q(oid(pr13))}, p.entityType = 'Product', p.createdAt = datetime({q(T0)}), p.privacyClass = 'PUBLIC'
SET p:Entity
MERGE (st)-[:EVALUATES]->(p)"""))
    # N14 two use targets -> V-203
    ea14, out = full_ea(14); s += out
    s.append(stmt(f"MATCH (ea:EvidenceApplicability {{uid: {q(ea14)}}}), (p:Product {{uid: {q(pr13)}}})\nMERGE (ea)-[:ASSESSES_APPLICABILITY_TO]->(p)"))
    # N15 UNKNOWN without missing facts or provenance -> V-209
    ea, out = full_ea(15, overrides={"ROUTE": dict(verdict="UNKNOWN", rationale="N15: unknown with nothing listed")}); s += out
    # N16 mechanism-assertion target with EXPOSURE PARTIAL but no BASED_ON_EVIDENCE StudyResult -> V-237
    a16 = N(16, "assertion", "mech"); ea16 = N(16, "applicability", "ea")
    s.append(stmt(f"""
MERGE (a:Assertion {{uid: {q(a16)}}}) ON CREATE SET a.id = {q(oid(a16))}, a.predicate = 'INCREASES_LEVEL_OF', a.predicateClass = 'MECHANISM', a.basisKind = 'DIRECT_MEASUREMENT',
  a.status = 'PROPOSED', a.polarity = 'POSITIVE', a.recordedAt = datetime({q(T0)}), a.createdAt = datetime({q(T0)}), a.privacyClass = 'PUBLIC'"""))
    s += applicability(ea16, "applicability-v0.2-candidate", "N16 mechanism target", a16, base_fv)
    s += dimensions(ea16, [dict(dim=d, verdict="NOT_ASSESSED") for d in ["MATERIAL_IDENTITY", "ROUTE", "DURATION", "POPULATION", "OUTCOME_RELEVANCE", "STUDY_DESIGN_AND_QUALITY"]]
                    + [dict(dim="EXPOSURE", verdict="PARTIAL", missingFacts=["human exposure result for the target material"], rationale="N16: no human exposure evidence linked")])
    # N17 EVIDENCE_OF_NO_MEANINGFUL_EFFECT without threshold or source -> W10-V09 ; N17b NOT_SIGNIFICANT read as EFFECT_DETECTED -> W10-V10
    r17 = N(17, "study-result", "null"); ri17 = N(17, "assessment", "ri"); ri17b = N(17, "assessment", "rib")
    s.append(stmt(f"""
MERGE (r:StudyResult {{uid: {q(r17)}}}) ON CREATE SET r.id = {q(oid(r17))}, r.artifactType = 'StudyResult', r.analysisKind = 'PRIMARY_PRESPECIFIED', r.comparisonKind = 'BETWEEN_ARM', r.statisticalConclusion = 'NOT_SIGNIFICANT', r.createdAt = datetime({q(T0)}), r.privacyClass = 'PUBLIC'
SET r:InformationArtifact
MERGE (ri:ResultInterpretation {{uid: {q(ri17)}}}) ON CREATE SET {assessment_props('ri', ri17, 'ResultInterpretation', 'result-interpretation-v0.1', extra=dict(interpretation='EVIDENCE_OF_NO_MEANINGFUL_EFFECT', meaningfulnessVerdict='NOT_MEANINGFUL'))}
SET ri:EvidenceAssessment
MERGE (ri)-[:INTERPRETS_RESULT_OF]->(r)
MERGE (rib:ResultInterpretation {{uid: {q(ri17b)}}}) ON CREATE SET {assessment_props('rib', ri17b, 'ResultInterpretation', 'result-interpretation-v0.1', extra=dict(interpretation='EFFECT_DETECTED'))}
SET rib:EvidenceAssessment
MERGE (rib)-[:INTERPRETS_RESULT_OF]->(r)"""))
    # N18 DOSE recorded as CATEGORICAL -> W10-V02
    ea, out = full_ea(18, overrides={"DOSE": dict(cls="CATEGORICAL", verdict="NOT_ASSESSED")}); s += out
    # N19 ratio arithmetic wrong (bases match) -> W10-V03
    ea, out = full_ea(19, overrides={"DOSE": dict(verdict="PARTIAL", evidenceValue=500.0, targetValue=250.0, unitCode="mg/d", evidenceQuantityBasis="PER_DAY",
        targetQuantityBasis="PER_DAY", evidenceMassBasis="SALT_FORM", targetMassBasis="SALT_FORM", ratio=2.0, rationale="N19: inverted ratio")}); s += out
    # N20 invented band: DOSE MATCH at ratio 0.8 -> W10-V04
    ea, out = full_ea(20, overrides={"DOSE": dict(verdict="MATCH", evidenceValue=300.0, targetValue=240.0, unitCode="mg/d", evidenceQuantityBasis="PER_DAY",
        targetQuantityBasis="PER_DAY", evidenceMassBasis="SALT_FORM", targetMassBasis="SALT_FORM", ratio=0.8, rationale="N20: 'within 20%' band invented")}); s += out
    # N21 UseContextProfile carrying person-level fields -> W10-V14 (and V-521 for the private uid value)
    up21 = N(21, "use-profile", "up")
    s.append(stmt(f"""
MERGE (p:UseContextProfile {{uid: {q(up21)}}})
  ON CREATE SET p.id = {q(oid(up21))}, p.entityType = 'UseContextProfile', p.birthDate = date('1961-05-02'), p.userContextUid = 'hu:private-user-context:w10-n21',
    p.createdAt = datetime({q(T0)}), p.privacyClass = 'PUBLIC'
SET p:Entity"""))
    # N22 assessment recorded before the snapshot it cites was retrieved (backdated) -> W10-V16b
    ea22, out = full_ea(22); s += out
    loc22 = "hu:locator:w10-n22-loc"; snap22 = "hu:snapshot:w10-n22-snap"
    s.append(stmt(f"""
MERGE (snap:SourceSnapshot {{uid: {q(snap22)}}}) ON CREATE SET snap.id = {q(oid(snap22))}, snap.artifactType = 'SourceSnapshot', snap.retrievedAt = datetime('2026-10-05T00:00:00Z'),
  snap.contentHash = 'synthetic:n22', snap.contentHashBasis = 'SYNTHETIC_FIXTURE', snap.createdAt = datetime('2026-10-05T00:00:00Z'), snap.privacyClass = 'PUBLIC'
SET snap:InformationArtifact
MERGE (l:SourceLocator {{uid: {q(loc22)}}}) ON CREATE SET l.id = {q(oid(loc22))}, l.artifactType = 'SourceLocator', l.selectorKind = 'WHOLE_SNAPSHOT', l.createdAt = datetime('2026-10-05T00:00:00Z'), l.privacyClass = 'PUBLIC'
SET l:InformationArtifact
MERGE (snap)-[:HAS_LOCATOR]->(l)
WITH l
MATCH (ea:EvidenceApplicability {{uid: {q(ea22)}}})
MERGE (ea)-[:SUPPORTED_BY]->(l)"""))
    write("w10-90-negatives.cypher", """
// =====================================================================================================================
// W10 fixture 90: negative cases. Standalone (own uids hu:*:w10-nNN-*); load on a scratch instance AFTER the positives
// so positive zero-row checks are taken first. Each case names the check that must report it; see
// 06-fixtures-and-queries.md for expected rows. N01/N02 write private-looking UserContext nodes ON PURPOSE (leak checks):
// N01 uses the catalog's fixture-only :PrivateRecord label, N02 does not. Never load this file into a shared database.
// N03 removes methodVersion with raw Cypher: the GraphQL API cannot express it (methodVersion: String!), which is the point.
// Generated by gen_w10.py.
// =====================================================================================================================""", s)

if __name__ == "__main__":
    file01(); file02(); file03(); file04(); file05(); file90()
