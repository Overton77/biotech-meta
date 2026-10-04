#!/usr/bin/env python3
"""W17 fixture generator. Emits ../0x-*.cypher. Every statement binds its own nodes by uid (no variable crosses ';').
Quote hashes: sha256 over NFC-normalized, whitespace-collapsed `exact` text (normalizationVersion NFC-WS1, as W09).
Assertion contentHash: sha256 over a canonical JSON of the immutable assertion content (computed here).
Snapshot contentHash: SYNTHETIC_FIXTURE (no raw bytes were hashed in this run)."""
import hashlib, json, os, unicodedata, re
OUT = os.path.join(os.path.dirname(__file__), "..")
class DT(str): pass
def dt(s): return DT(s)
def lit(v):
    if v is None: return "null"
    if isinstance(v, DT): return f"datetime('{v}')"
    if isinstance(v, bool): return "true" if v else "false"
    if isinstance(v, (int, float)): return repr(v)
    if isinstance(v, list): return "[" + ", ".join(lit(x) for x in v) + "]"
    return "'" + str(v).replace("\\", "\\\\").replace("'", "\\'") + "'"
def props(d): return "{" + ", ".join(f"{k}: {lit(v)}" for k, v in d.items() if v is not None) + "}"
def setp(var, d): return ", ".join(f"{var}.{k} = {lit(v)}" for k, v in d.items() if v is not None)
def sha(s): return "sha256:" + hashlib.sha256(s.encode("utf-8")).hexdigest()
def qhash(t): return sha(re.sub(r"\s+", " ", unicodedata.normalize("NFC", t)).strip())
def oid(uid): return uid.split(":", 2)[2]
T0 = "2026-10-04T01:40:00Z"   # retrieval time of this run's captures
TR = "2026-10-04T02:00:00Z"   # ingestion (recorded) time of this run's assertions
TC = "2026-10-04T02:00:00Z"
RUN = "w17-fixture-run-2026-10-04"

def node(uid, labels, p):
    base = {"id": oid(uid), "createdAt": dt(TC), "privacyClass": "PUBLIC", "mongoResearchRunId": RUN}
    base.update(p)
    lab = ":".join(labels)
    return f"MERGE (n:{lab} {{uid: {lit(uid)}}})\n  ON CREATE SET {setp('n', base)};"
def edge(a, alab, typ, b, blab, p=None):
    s = f"MATCH (a:{alab} {{uid: {lit(a)}}}), (b:{blab} {{uid: {lit(b)}}})\nMERGE (a)-[r:{typ}]->(b)"
    if p: s += f"\n  ON CREATE SET {setp('r', p)}"
    return s + ";"

# ---------------------------------------------------------------------------------------------------------------
# Sources, snapshots, locators (real, retrieved 2026-10-04 by W17 unless marked SYNTHETIC)
SOURCES = {
 "zocor": dict(src="hu:source:dailymed-zocor-8f55d5de", uri="https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8f55d5de-5a4f-4a39-8c84-c53976dd6af9",
               kind="MANUFACTURER_LABEL_PAGE", doc="PRODUCT_LABEL", title="DailyMed - ZOCOR- simvastatin tablet, film coated", pub=None),
 "dsc": dict(src="hu:source:fda-dsc-statins-pregnancy-2021", uri="https://www.fda.gov/drugs/drug-safety-and-availability/fda-requests-removal-strongest-warning-against-using-cholesterol-lowering-statins-during-pregnancy",
               kind="REGULATORY_RECORD", doc="SAFETY_COMMUNICATION", title="FDA requests removal of strongest warning against using cholesterol-lowering statins during pregnancy; still advises most pregnant patients should stop taking statins", pub="2021-07-20T00:00:00Z"),
 "aems": dict(src="hu:source:fda-aems-2024q3", uri="https://www.fda.gov/drugs/fda-adverse-event-monitoring-system-aems/july-september-2024-new-safety-information-or-potential-signals-serious-risks-identified-fda-adverse",
               kind="REGULATORY_RECORD", doc="SAFETY_COMMUNICATION", title="July - September 2024 | New Safety Information or Potential Signals of Serious Risks Identified from the FDA Adverse Event Monitoring System (AEMS)", pub=None),
 "afp": dict(src="hu:source:aafp-afp-2017-0715-p101", uri="https://www.aafp.org/pubs/afp/issues/2017/0715/p101.html",
               kind="PEER_REVIEWED_PUBLICATION", doc="REVIEW_ARTICLE", title="Common Herbal Dietary Supplement-Drug Interactions (Am Fam Physician 2017;96(2):101-107; PMID 28762712)", pub="2017-07-15T00:00:00Z"),
 "ods": dict(src="hu:source:ods-vitamin-k-hp", uri="https://ods.od.nih.gov/factsheets/VitaminK-HealthProfessional/",
               kind="ORGANIZATION_WEBPAGE", doc="WEBPAGE", title="Office of Dietary Supplements - Vitamin K (Health Professional fact sheet)", pub=None),
 "pmc": dict(src="hu:source:pmc5701244", uri="https://pmc.ncbi.nlm.nih.gov/articles/PMC5701244/",
               kind="PEER_REVIEWED_PUBLICATION", doc="SCIENTIFIC_ARTICLE", title="Repeat dose NRPT increases NAD+ levels in humans safely and sustainably (PMID 29184669)", pub="2017-11-24T00:00:00Z"),
 "synlabel": dict(src="hu:source:synthetic-w17-statin-class-labeling-2020", uri="https://example.invalid/synthetic/w17/statin-class-labeling-2020",
               kind="REGULATORY_RECORD", doc="PRODUCT_LABEL", title="SYNTHETIC: pre-2021 statin class labeling capture (not retrieved; stands in for the contraindication the 2021 FDA DSC says it removes)", pub=None),
}
SNAP = {k: v["src"].replace("hu:source:", "hu:snapshot:") + ("-2020-05-30" if k == "synlabel" else "-2026-10-04") for k, v in SOURCES.items()}
SNAP["pmc"] = "hu:snapshot:pmc5701244-2026-10-04"
LOCS = [
 # key, source, uid, section, exact
 ("z-ci-gem", "zocor", "hu:locator:zocor-4-gemfibrozil", "4 CONTRAINDICATIONS (highlights)", "Concomitant use of cyclosporine, danazol or gemfibrozil"),
 ("z-ci-alf", "zocor", "hu:locator:zocor-4-liver", "4 CONTRAINDICATIONS (highlights)", "Acute liver failure or decompensated cirrhosis"),
 ("z-dose-verap", "zocor", "hu:locator:zocor-2-5-verapamil", "2.5 Dosage modifications (highlights)", "Patients taking Verapamil, Diltiazem, or Dronedarone Do not exceed ZOCOR 10 mg once daily."),
 ("z-7-ccb", "zocor", "hu:locator:zocor-7-ccb-intervention", "7.1 Drug Interactions: Amiodarone, Dronedarone, Ranolazine, or Calcium Channel Blockers", "For patients taking verapamil, diltiazem, or dronedarone, do not exceed ZOCOR 10 mg daily."),
 ("z-7-niacin-impact", "zocor", "hu:locator:zocor-7-niacin-impact", "7.1 Drug Interactions: Niacin (Clinical Impact)", "Cases of myopathy and rhabdomyolysis have been observed with concomitant use of lipid modifying dosages of niacin-containing products (≥1 gram/day niacin) with ZOCOR. The risk of myopathy is greater in Chinese patients."),
 ("z-7-niacin-int", "zocor", "hu:locator:zocor-7-niacin-intervention", "7.1 Drug Interactions: Niacin (Intervention)", "Concomitant use of ZOCOR with lipid-modifying dosages of niacin is not recommended in Chinese patients [see Use in Specific Populations (8.8)]. For non-Chinese patients, consider if the benefit of using lipid-modifying doses of niacin concomitantly with ZOCOR outweighs the increased risk of myopathy and rhabdomyolysis."),
 ("z-7-gfj", "zocor", "hu:locator:zocor-7-grapefruit", "7.1 Drug Interactions: Grapefruit Juice", "Grapefruit juice can raise the plasma levels of simvastatin and may increase the risk of myopathy and rhabdomyolysis. Avoid grapefruit juice when taking ZOCOR."),
 ("z-rev", "zocor", "hu:locator:zocor-revised", "Highlights: revision date", "Revised: 8/2023"),
 ("d-remove", "dsc", "hu:locator:fda-dsc-2021-remove-contraindication", "What is FDA doing?", "These changes include removing the contraindication against using these medicines in all pregnant patients."),
 ("d-exception", "dsc", "hu:locator:fda-dsc-2021-high-risk-exception", "What is FDA doing?", "Because the benefits of statins may include prevention of serious or potentially fatal events in a small group of very high-risk pregnant patients, contraindicating these drugs in all pregnant women is not appropriate."),
 ("d-stop", "dsc", "hu:locator:fda-dsc-2021-stop-when-pregnant", "What safety information is FDA announcing", "Despite the change, most patients should stop statins once they learn they are pregnant."),
 ("d-breastfeed", "dsc", "hu:locator:fda-dsc-2021-breastfeeding", "What safety information is FDA announcing", "Patients should not breastfeed when taking a statin because the medicine may pass into breast milk and pose a risk to the baby."),
 ("a-lenva", "aems", "hu:locator:fda-aems-2024q3-lenvatinib-row", "Table row: Lenvima (lenvatinib) capsules / Nexavar (sorafenib) tablets", "Tumor lysis syndrome | Updated FDA determined that no action was necessary at the time based on available information."),
 ("a-dapto", "aems", "hu:locator:fda-aems-2024q3-daptomycin-row", "Table row: Cubicin (daptomycin for injection)", "Hyperkalemia | Updated The “Adverse Reactions” section of the labeling was updated in April and May 2025 to include information about hyperkalemia."),
 ("a-asof", "aems", "hu:locator:fda-aems-2024q3-asof", "Table header", "Additional Information (as of October 24, 2025)"),
 ("p-kava", "afp", "hu:locator:afp-2017-kava", "Kava kava", "Additionally, the results of two in vitro studies suggest the potential to inhibit CYP2C9 and CYP2C19, which are involved in the metabolism of many nonsteroidal anti-inflammatory drugs, angiotensin receptor blockers, glipizide (Glucotrol), glyburide, rosiglitazone (Avandia), valproic acid (Depakene), warfarin, proton pump inhibitors, phenytoin (Dilantin), and clopidogrel (Plavix). Patients taking medications metabolized by CYP2C9 or CYP2C19 should be closely monitored for clinical adverse effects and laboratory abnormalities (e.g., glucose level, A1C level, INR) or instructed not to use kava-containing supplements."),
 ("p-gte", "afp", "hu:locator:afp-2017-green-tea", "Green tea", "However, green tea extract has been shown to increase simvastatin (Zocor) concentrations, which may be due to P-gp inhibition."),
 ("p-sjw", "afp", "hu:locator:afp-2017-st-johns-wort", "St. John's wort", "Clinical studies have shown reductions in cyclosporine (Sandimmune), tacrolimus, warfarin, protease inhibitors, irinotecan (Camptosar), theophylline, digoxin, venlafaxine, and oral contraceptives. It is strongly recommended to avoid concurrent use of St. John's wort with over-the-counter and prescription medications."),
 ("p-sort", "afp", "hu:locator:afp-2017-sort-goldenseal-sjw", "SORT: Key recommendations for practice", "Drug interactions with goldenseal and St. John's wort are highly likely, and clinicians should counsel patients to avoid concurrent use with over-the-counter or prescription medications. | C"),
 ("p-amgin", "afp", "hu:locator:afp-2017-american-ginseng", "American ginseng", "Two human trials have demonstrated no effect of American ginseng on the human immunodeficiency virus (HIV) agents indinavir (Crixivan) and zidovudine (Retrovir)."),
 ("o-vitk", "ods", "hu:locator:ods-vitk-warfarin", "Interactions with Medications: Warfarin (Coumadin) and similar anticoagulants", "People taking warfarin and similar anticoagulants need to maintain a consistent intake of vitamin K from food and supplements because sudden changes in vitamin K intakes can increase or decrease the anticoagulant effect"),
 ("m-related", "pmc", "hu:locator:pmc5701244-results-related-aes", "Results: Adverse events", "There was one AE mild in intensity assessed as possibly related to the placebo product (pruritus), one AE mild in intensity assessed as possibly related to NRPT 1X (nausea), and five AEs (moderate fatigue, mild headache, moderate dyspepsia, moderate abdominal discomfort and diarrhea) reported by five participants in the NRPT 2X group (Table). Four of these AEs were assessed as possibly related to NRPT 2X, while one AE (diarrhea) was assessed as probably related to NRPT 2X."),
 ("m-selfrep", "pmc", "hu:locator:pmc5701244-methods-safety-parameters", "Methods: Clinical trial", "Safety parameters measured included a standard clinical checkup, self-reported AEs"),
 ("m-sae", "pmc", "hu:locator:pmc5701244-results-adverse-events", "Results: Adverse events", "All participants reporting AEs recovered and there were no serious AEs reported during this clinical study."),
 ("m-excl", "pmc", "hu:locator:pmc5701244-methods-exclusion-lipid-lowering", "Methods: Participants", "currently taking lipid lowering drugs"),
 ("s-ci", "synlabel", "hu:locator:synthetic-w17-statin-pregnancy-contraindication-2020", "SYNTHETIC: 4 CONTRAINDICATIONS", "SYNTHETIC stand-in: Pregnancy (statins contraindicated in all pregnant patients before the 2021 class change)"),
]
LOC = {k: u for k, _, u, _, _ in LOCS}

def base_cypher():
    out = ["// W17 fixture 00: shared base (sources, snapshots, locators, actors, reference concepts). Run first.",
           "// Real records retrieved by W17 on 2026-10-04 (03-source-manifest.md S1..S7); SYNTHETIC rows are named so.",
           "// Snapshots: contentHashBasis SYNTHETIC_FIXTURE (raw bytes not hashed); locator quoteHash = sha256 over NFC-WS1 text.", ""]
    for k, s in SOURCES.items():
        doc = s["doc"]
        out.append(node(s["src"], ["Document", "Source", "Entity"], {"documentId": oid(s["src"]), "entityType": "Source", "canonicalUri": s["uri"], "url": s["uri"],
                    "title": s["title"], "name": s["title"], "type": doc, "sourceKind": s["kind"], "publishedAt": dt(s["pub"]) if s["pub"] else None}))
        ret = "2020-05-30T00:00:00Z" if k == "synlabel" else T0
        out.append(node(SNAP[k], ["SourceSnapshot", "InformationArtifact"], {"artifactType": "SourceSnapshot", "canonicalUri": s["uri"], "retrievedAt": dt(ret), "observedAt": dt(ret),
                    "publishedAt": dt(s["pub"]) if s["pub"] else None, "contentHash": sha("SYNTHETIC_FIXTURE:" + SNAP[k]), "contentHashBasis": "SYNTHETIC_FIXTURE",
                    "captureCompleteness": "PARTIAL_EXCERPT" if k != "synlabel" else "UNKNOWN"}))
        out.append(edge(s["src"], "Source", "HAS_SNAPSHOT", SNAP[k], "SourceSnapshot"))
    for key, sk, uid, sec, exact in LOCS:
        out.append(node(uid, ["SourceLocator", "InformationArtifact"], {"artifactType": "SourceLocator", "uri": SOURCES[sk]["uri"], "selectorKind": "TEXT_QUOTE",
                    "section": sec, "exact": exact, "quoteHash": qhash(exact), "normalizationVersion": "NFC-WS1"}))
        out.append(edge(SNAP[sk], "SourceSnapshot", "HAS_LOCATOR", uid, "SourceLocator"))
    # actors
    for uid, lab, name, kind in [("hu:org:us-fda", ["Organization", "Entity"], "U.S. Food and Drug Administration", "REGULATORY_AGENCY"),
                                 ("hu:org:nih-ods", ["Organization", "Entity"], "NIH Office of Dietary Supplements", "GOVERNMENT_OFFICE")]:
        out.append(node(uid, lab, {"entityType": "Organization", "name": name, "organizationKind": kind}))
    out.append(node("hu:person:gary-n-asher", ["Person", "Entity"], {"entityType": "Person", "name": "Gary N. Asher"}))
    out.append(node("hu:agent:w17-safety-assessor", ["Agent", "Entity"], {"entityType": "Agent", "name": "BellLabs safety signal assessor (synthetic method)", "agentKind": "DATA_ANALYSIS_PIPELINE"}))
    out.append(node("hu:agent:w17-extractor", ["Agent", "Entity"], {"entityType": "Agent", "name": "W17 manual extraction (Opus 5.5 worker)", "agentKind": "MANUAL_VALIDATION_OF_AUTOMATED_AGENT"}))
    for uid, kind, mv, st in [("hu:activity:w17-extract-2026-10-04", "EXTRACTION", "w17-manual-extract/0.1", "2026-10-04T01:45:00Z"),
                              ("hu:activity:w17-signal-run-001", "EXTRACTION", "bl-safety-signal/0.1", "2026-10-04T02:25:00Z"),
                              ("hu:activity:w17-signal-run-002", "EXTRACTION", "bl-safety-signal/0.2", "2026-10-04T02:35:00Z")]:
        out.append(node(uid, ["Activity", "Occurrence"], {"occurrenceType": "Activity", "activityKind": kind, "methodVersion": mv, "startedAt": dt(st), "externalRunSystem": "w17-fixture", "externalRunId": oid(uid)}))
    out.append(edge("hu:activity:w17-extract-2026-10-04", "Activity", "WAS_ASSOCIATED_WITH", "hu:agent:w17-extractor", "Agent"))
    out.append(edge("hu:activity:w17-signal-run-001", "Activity", "WAS_ASSOCIATED_WITH", "hu:agent:w17-safety-assessor", "Agent"))
    out.append(edge("hu:activity:w17-signal-run-002", "Activity", "WAS_ASSOCIATED_WITH", "hu:agent:w17-safety-assessor", "Agent"))
    # reference concepts (other owners' types, minimal shared-graph rows)
    for uid, name in [("hu:substance:simvastatin", "simvastatin"), ("hu:substance:verapamil", "verapamil"), ("hu:substance:gemfibrozil", "gemfibrozil"),
                      ("hu:substance:nicotinic-acid", "nicotinic acid (niacin)"), ("hu:substance:nicotinamide-riboside", "nicotinamide riboside"),
                      ("hu:substance:warfarin", "warfarin"), ("hu:substance:indinavir", "indinavir"), ("hu:substance:lenvatinib", "lenvatinib"),
                      ("hu:substance:daptomycin", "daptomycin"), ("hu:substance:vitamin-k", "vitamin K (substance family as named by the source)")]:
        out.append(node(uid, ["ChemicalSubstance", "Entity"], {"entityType": "ChemicalSubstance", "name": name}))
    for uid, labs, name in [("hu:material:kava-preparation-unspecified", ["BotanicalPreparation", "IngredientMaterial", "Entity"], "kava (Piper methysticum) preparation, unspecified"),
                            ("hu:material:green-tea-extract-unspecified", ["BotanicalPreparation", "IngredientMaterial", "Entity"], "green tea (Camellia sinensis) extract, unspecified"),
                            ("hu:material:st-johns-wort-preparation-unspecified", ["BotanicalPreparation", "IngredientMaterial", "Entity"], "St. John's wort (Hypericum perforatum) preparation, unspecified"),
                            ("hu:material:american-ginseng-preparation-unspecified", ["BotanicalPreparation", "IngredientMaterial", "Entity"], "American ginseng preparation, unspecified"),
                            ("hu:material:grapefruit-juice", ["FoodItem", "IngredientMaterial", "Entity"], "grapefruit juice"),
                            ("hu:material:nct02678611-nrpt-as-supplied", ["MaterialMixture", "IngredientMaterial", "Entity"], "NRPT capsule material as supplied in NCT02678611 (125 mg NR + 25 mg PT per capsule)")]:
        out.append(node(uid, labs, {"entityType": "IngredientMaterial", "name": name}))
    out.append(node("hu:treatment:statin-therapy", ["Treatment", "Entity"], {"entityType": "Treatment", "name": "HMG-CoA reductase inhibitor (statin) therapy", "modality": "SMALL_MOLECULE"}))
    out.append(node("hu:condition:acute-liver-failure", ["Condition", "Entity"], {"entityType": "Condition", "name": "acute liver failure"}))
    out.append(node("hu:condition:rhabdomyolysis", ["Condition", "Entity"], {"entityType": "Condition", "name": "rhabdomyolysis"}))
    for uid, name, pop in [("hu:use-profile:patients-of-chinese-descent", "Patients of Chinese descent (label wording 'Chinese patients')", "Chinese patients"),
                           ("hu:use-profile:non-chinese-patients", "Non-Chinese patients (label wording)", "non-Chinese patients"),
                           ("hu:use-profile:pregnant-patients", "Pregnant patients", "pregnant patients"),
                           ("hu:use-profile:breastfeeding-patients", "Breastfeeding patients", "patients who breastfeed")]:
        out.append(node(uid, ["UseContextProfile", "Entity"], {"entityType": "UseContextProfile", "name": name, "populationDescriptor": pop}))
    out.append(node("hu:anatomical-context:skeletal-muscle", ["Organ", "AnatomicalContext", "Entity"], {"entityType": "AnatomicalContext", "name": "skeletal muscle", "contextKind": "TISSUE", "uberonId": "UBERON:0001134"}))
    for uid, name, cat in [("hu:adverse-effect:myopathy", "myopathy", "DIAGNOSIS"), ("hu:adverse-effect:rhabdomyolysis", "rhabdomyolysis", "DIAGNOSIS"),
                           ("hu:adverse-effect:gastrointestinal-intolerance", "gastrointestinal intolerance (nausea, dyspepsia, abdominal discomfort, diarrhea)", "SYMPTOM"),
                           ("hu:adverse-effect:tumor-lysis-syndrome", "tumor lysis syndrome", "DIAGNOSIS"), ("hu:adverse-effect:hyperkalemia", "hyperkalemia", "LAB_ABNORMALITY"),
                           ("hu:adverse-effect:anticoagulant-effect-altered", "anticoagulant effect altered (INR change)", "LAB_ABNORMALITY"),
                           ("hu:adverse-effect:embryofetal-toxicity", "embryofetal toxicity", "DIAGNOSIS")]:
        out.append(node(uid, ["AdverseEffect", "Entity"], {"entityType": "ADVERSE_EFFECT", "name": name, "effectCategory": cat}))
    out.append(edge("hu:adverse-effect:myopathy", "AdverseEffect", "AFFECTS_ORGAN", "hu:anatomical-context:skeletal-muscle", "Organ", {"notes": "curated reference involvement"}))
    out.append(edge("hu:adverse-effect:rhabdomyolysis", "AdverseEffect", "AFFECTS_ORGAN", "hu:anatomical-context:skeletal-muscle", "Organ", {"notes": "curated reference involvement"}))
    return out

# ---------------------------------------------------------------------------------------------------------------
# Assertions
def assertion(uid, labels, a, subj, slab, obj, olab, locs, asserter=None, alab=None, effects=(), gen="hu:activity:w17-extract-2026-10-04"):
    content = {k: a.get(k) for k in sorted(a)}
    content.update({"subject": subj, "object": obj})
    p = {"predicate": a["predicate"], "status": a.get("status", "EXTRACTED"), "recordedAt": dt(a.get("recordedAt", TR)), "contentHash": sha(json.dumps(content, sort_keys=True))}
    p.update({k: (dt(v) if k in ("validFrom", "validTo", "recordedTo") and v else v) for k, v in a.items() if k not in ("predicate", "status", "recordedAt")})
    s = [node(uid, labels, p)]
    s.append(edge(uid, labels[0], "HAS_SUBJECT", subj, slab))
    s.append(edge(uid, labels[0], "HAS_OBJECT", obj, olab))
    if asserter: s.append(edge(uid, labels[0], "ASSERTED_BY", asserter, alab))
    for l in locs: s.append(edge(uid, labels[0], "SUPPORTED_BY", LOC[l], "SourceLocator"))
    for e in effects: s.append(edge(uid, labels[0], "RELATES_TO_EFFECT", e, "AdverseEffect"))
    if gen: s.append(edge(uid, labels[0], "WAS_GENERATED_BY", gen, "Activity"))
    return s
CA = ["ContraindicationAssertion", "Assertion"]; IA = ["InteractionAssertion", "Assertion"]
US = dict(jurisdiction="US")
def bnd(vf=None, vfp=None, vfb="UNKNOWN", vt=None, vtp=None, vtb="UNKNOWN"):
    return dict(validFrom=vf, validFromPrecision=vfp, validFromBasis=vfb, validTo=vt, validToPrecision=vtp, validToBasis=vtb)

def use_constraint(uid, name, subj, slab, scope, dose=None, jur=None):
    # scope: list of (memberUid, memberLabel, role, doseDict|None)
    key = {"subject": subj, "dose": dose, "route": None, "jurisdiction": jur,
           "scope": sorted([[m, r, d] for m, _, r, d in scope], key=lambda x: (x[1], x[0]))}
    p = {"entityType": "USE_CONSTRAINT", "name": name, "identityKeyHash": sha(json.dumps(key, sort_keys=True)), "identityKeyVersion": "uc-key/v1", "jurisdiction": jur}
    if dose: p.update(dose)
    s = [node(uid, ["UseConstraint", "Entity"], p), edge(uid, "UseConstraint", "CONSTRAINS_USE_OF", subj, slab)]
    for i, (m, ml, r, d) in enumerate(scope):
        ep = {"scopeRole": r, "orderIndex": i}
        if d: ep.update(d)
        s.append(edge(uid, "UseConstraint", "CONSTRAINT_SCOPE", m, ml, ep))
    return s
def resolves(a_uid, a_lab, uc):
    return edge(a_uid, a_lab, "RESOLVES_TO_CONSTRAINT", uc, "UseConstraint", {"derivationRule": "uc-match/v1", "derivedFromAssertionUids": [a_uid], "derivedAt": dt("2026-10-04T02:20:00Z")})

GT10 = dict(doseComparator="GT", doseValue=10.0, doseUnitCode="mg", doseQuantityBasis="PER_DAY", doseMassBasis="UNSPECIFIED")
NIACIN1G = dict(doseComparator="GTE", doseValue=1.0, doseUnitCode="g", doseQuantityBasis="PER_DAY", doseMassBasis="UNSPECIFIED")

def constraints_cypher():
    o = ["// W17 fixture 03: ZOCOR (simvastatin) label directives and interactions -> UseConstraints. Block vs lower is a",
         "// private-policy outcome; the shared graph keeps levels, scopes and dose bands distinct (CQ-RC-06). Run after 00.", ""]
    Z = "hu:substance:simvastatin"
    rows = [
     ("hu:assertion:w17-zocor-ci-gemfibrozil", dict(predicate="USE_CONSTRAINED_WITH", polarity="POSITIVE", speechAct="CAUTIONS", assertionBasis="MANUFACTURER_CLAIM", constraintLevel="CONTRAINDICATED",
        levelVerbatim="Concomitant use of cyclosporine, danazol or gemfibrozil (CONTRAINDICATIONS)", **US, **bnd()), "hu:substance:gemfibrozil", "ChemicalSubstance", ["z-ci-gem"], [], "hu:use-constraint:simvastatin-with-gemfibrozil"),
     ("hu:assertion:w17-zocor-ci-acute-liver-failure", dict(predicate="USE_CONSTRAINED_IN", polarity="POSITIVE", speechAct="CAUTIONS", assertionBasis="MANUFACTURER_CLAIM", constraintLevel="CONTRAINDICATED",
        levelVerbatim="Acute liver failure or decompensated cirrhosis (CONTRAINDICATIONS)", **US, **bnd()), "hu:condition:acute-liver-failure", "Condition", ["z-ci-alf"], [], "hu:use-constraint:simvastatin-in-acute-liver-failure"),
     ("hu:assertion:w17-zocor-dose-verapamil", dict(predicate="USE_CONSTRAINED_WITH", polarity="POSITIVE", speechAct="CAUTIONS", assertionBasis="MANUFACTURER_CLAIM", constraintLevel="DO_NOT_EXCEED_DOSE",
        levelVerbatim="Do not exceed ZOCOR 10 mg once daily.", **GT10, **US, **bnd()), "hu:substance:verapamil", "ChemicalSubstance", ["z-dose-verap", "z-7-ccb"], ["hu:adverse-effect:myopathy", "hu:adverse-effect:rhabdomyolysis"], "hu:use-constraint:simvastatin-above-10mg-with-verapamil"),
     ("hu:assertion:w17-zocor-niacin-chinese", dict(predicate="USE_CONSTRAINED_WITH", polarity="POSITIVE", speechAct="CAUTIONS", assertionBasis="MANUFACTURER_CLAIM", constraintLevel="NOT_RECOMMENDED",
        levelVerbatim="is not recommended in Chinese patients", populationScopeText="Chinese patients", coExposureDoseText="lipid-modifying dosages of niacin (≥1 gram/day niacin)", **US, **bnd()),
        "hu:substance:nicotinic-acid", "ChemicalSubstance", ["z-7-niacin-int"], ["hu:adverse-effect:myopathy"], "hu:use-constraint:simvastatin-with-niacin-1g-chinese"),
     ("hu:assertion:w17-zocor-niacin-non-chinese", dict(predicate="USE_CONSTRAINED_WITH", polarity="POSITIVE", speechAct="CAUTIONS", assertionBasis="MANUFACTURER_CLAIM", constraintLevel="USE_WITH_CAUTION",
        levelVerbatim="consider if the benefit of using lipid-modifying doses of niacin concomitantly with ZOCOR outweighs the increased risk of myopathy and rhabdomyolysis", populationScopeText="non-Chinese patients",
        coExposureDoseText="lipid-modifying doses of niacin", **US, **bnd()), "hu:substance:nicotinic-acid", "ChemicalSubstance", ["z-7-niacin-int"], ["hu:adverse-effect:myopathy", "hu:adverse-effect:rhabdomyolysis"], "hu:use-constraint:simvastatin-with-niacin-1g-non-chinese"),
     ("hu:assertion:w17-zocor-avoid-grapefruit", dict(predicate="USE_CONSTRAINED_WITH", polarity="POSITIVE", speechAct="CAUTIONS", assertionBasis="MANUFACTURER_CLAIM", constraintLevel="AVOID",
        levelVerbatim="Avoid grapefruit juice when taking ZOCOR.", **US, **bnd()), "hu:material:grapefruit-juice", "IngredientMaterial", ["z-7-gfj"], ["hu:adverse-effect:myopathy", "hu:adverse-effect:rhabdomyolysis"], "hu:use-constraint:simvastatin-with-grapefruit-juice"),
    ]
    ucs = [
     ("hu:use-constraint:simvastatin-with-gemfibrozil", "simvastatin with gemfibrozil", [("hu:substance:gemfibrozil", "ChemicalSubstance", "CO_EXPOSURE", None)], None),
     ("hu:use-constraint:simvastatin-in-acute-liver-failure", "simvastatin in acute liver failure", [("hu:condition:acute-liver-failure", "Condition", "CONDITION_PRESENT", None)], None),
     ("hu:use-constraint:simvastatin-above-10mg-with-verapamil", "simvastatin above 10 mg/day with verapamil", [("hu:substance:verapamil", "ChemicalSubstance", "CO_EXPOSURE", None)], GT10),
     ("hu:use-constraint:simvastatin-with-niacin-1g", "simvastatin with niacin at >= 1 g/day", [("hu:substance:nicotinic-acid", "ChemicalSubstance", "CO_EXPOSURE", NIACIN1G)], None),
     ("hu:use-constraint:simvastatin-with-niacin-1g-chinese", "simvastatin with niacin at >= 1 g/day in patients of Chinese descent",
        [("hu:substance:nicotinic-acid", "ChemicalSubstance", "CO_EXPOSURE", NIACIN1G), ("hu:use-profile:patients-of-chinese-descent", "UseContextProfile", "POPULATION", None)], None),
     ("hu:use-constraint:simvastatin-with-niacin-1g-non-chinese", "simvastatin with niacin at >= 1 g/day in non-Chinese patients",
        [("hu:substance:nicotinic-acid", "ChemicalSubstance", "CO_EXPOSURE", NIACIN1G), ("hu:use-profile:non-chinese-patients", "UseContextProfile", "POPULATION", None)], None),
     ("hu:use-constraint:simvastatin-with-grapefruit-juice", "simvastatin with grapefruit juice", [("hu:material:grapefruit-juice", "IngredientMaterial", "CO_EXPOSURE", None)], None),
    ]
    for uid, name, scope, dose in ucs:
        o += use_constraint(uid, name, Z, "ChemicalSubstance", scope, dose, "US")
    for uid, a, obj, olab, locs, eff, uc in rows:
        o += assertion(uid, CA, a, Z, "ChemicalSubstance", obj, olab, locs, effects=eff)
        o.append(resolves(uid, "ContraindicationAssertion", uc))
    ias = [
     ("hu:assertion:w17-zocor-ia-grapefruit", dict(predicate="INTERACTS_WITH", polarity="POSITIVE", speechAct="STATES", basisKind="CITED_FROM_PRIOR_WORK", assertionBasis="MANUFACTURER_CLAIM",
        interactionMechanism="NOT_STATED", interactionEffect="INCREASES_OBJECT_EXPOSURE", exposureChangeText="can raise the plasma levels of simvastatin", **US, **bnd()),
        "hu:material:grapefruit-juice", "IngredientMaterial", Z, "ChemicalSubstance", ["z-7-gfj"], ["hu:adverse-effect:myopathy", "hu:adverse-effect:rhabdomyolysis"], "hu:use-constraint:simvastatin-with-grapefruit-juice"),
     ("hu:assertion:w17-zocor-ia-niacin", dict(predicate="INTERACTS_WITH", polarity="POSITIVE", speechAct="STATES", basisKind="CITED_FROM_PRIOR_WORK", assertionBasis="MANUFACTURER_CLAIM",
        interactionMechanism="PHARMACODYNAMIC_ADDITIVE", interactionEffect="INCREASES_ADVERSE_EFFECT_RISK", subjectDoseText="lipid modifying dosages of niacin-containing products (≥1 gram/day niacin)",
        populationScopeText="The risk of myopathy is greater in Chinese patients.", **US, **bnd()),
        "hu:substance:nicotinic-acid", "ChemicalSubstance", Z, "ChemicalSubstance", ["z-7-niacin-impact"], ["hu:adverse-effect:myopathy", "hu:adverse-effect:rhabdomyolysis"], "hu:use-constraint:simvastatin-with-niacin-1g"),
    ]
    for uid, a, s_, sl, ob, ol, locs, eff, uc in ias:
        o += assertion(uid, IA, a, s_, sl, ob, ol, locs, effects=eff)
        o.append(resolves(uid, "InteractionAssertion", uc))
    return o

def interactions_cypher():
    o = ["// W17 fixture 04: supplement-drug interactions with evidence levels; UNKNOWN interaction that must still block;",
         "// measured absence (NEGATIVE) vs no record (QS-7). Sources: AFP 2017 review (Asher et al.), NIH ODS vitamin K. Run after 00.", ""]
    A = ("hu:person:gary-n-asher", "Person")
    items = [
     # uid, labels, a, subj, slab, obj, olab, locs, asserter, effects, uc
     ("hu:assertion:w17-afp-kava-warfarin-interaction", IA, dict(predicate="INTERACTS_WITH", polarity="UNKNOWN", speechAct="STATES", basisKind="CITED_FROM_PRIOR_WORK", assertionBasis="STUDY_RESULT",
        interactionMechanism="CYP2C9_INHIBITION", interactionEffect="NOT_STATED", description="two in vitro studies suggest the potential to inhibit CYP2C9 (in vitro setting not specified; not confirmed in humans); warfarin is named in the source's list of CYP2C9 substrates", **bnd()),
        "hu:material:kava-preparation-unspecified", "IngredientMaterial", "hu:substance:warfarin", "ChemicalSubstance", ["p-kava"], A, ["hu:adverse-effect:anticoagulant-effect-altered"], "hu:use-constraint:kava-with-warfarin"),
     ("hu:assertion:w17-afp-kava-warfarin-monitor", CA, dict(predicate="USE_CONSTRAINED_WITH", polarity="POSITIVE", speechAct="CAUTIONS", assertionBasis="EXPERT_OPINION", constraintLevel="MONITOR",
        levelVerbatim="should be closely monitored for clinical adverse effects and laboratory abnormalities (e.g., glucose level, A1C level, INR) or instructed not to use kava-containing supplements", **bnd()),
        "hu:material:kava-preparation-unspecified", "IngredientMaterial", "hu:substance:warfarin", "ChemicalSubstance", ["p-kava"], A, ["hu:adverse-effect:anticoagulant-effect-altered"], "hu:use-constraint:kava-with-warfarin"),
     ("hu:assertion:w17-afp-green-tea-simvastatin", IA, dict(predicate="INTERACTS_WITH", polarity="POSITIVE", speechAct="STATES", basisKind="CITED_FROM_PRIOR_WORK", assertionBasis="STUDY_RESULT",
        interactionMechanism="NOT_STATED", interactionEffect="INCREASES_OBJECT_EXPOSURE", exposureChangeText="has been shown to increase simvastatin (Zocor) concentrations", description="mechanism hedged by the source ('may be due to P-gp inhibition')", **bnd()),
        "hu:material:green-tea-extract-unspecified", "IngredientMaterial", "hu:substance:simvastatin", "ChemicalSubstance", ["p-gte"], A, [], "hu:use-constraint:green-tea-extract-with-simvastatin"),
     ("hu:assertion:w17-afp-sjw-warfarin-interaction", IA, dict(predicate="INTERACTS_WITH", polarity="POSITIVE", speechAct="STATES", basisKind="DIRECT_MEASUREMENT", assertionBasis="STUDY_RESULT",
        evidenceSetting="HUMAN_INTERVENTIONAL", interactionMechanism="CYP3A4_INDUCTION", interactionEffect="DECREASES_OBJECT_EXPOSURE", exposureChangeText="Clinical studies have shown reductions in ... warfarin",
        reportedEvidenceGrade="C", reportedEvidenceGradeScheme="SORT (AFP): C = consensus, disease-oriented evidence, usual practice, expert opinion, or case series", **bnd()),
        "hu:material:st-johns-wort-preparation-unspecified", "IngredientMaterial", "hu:substance:warfarin", "ChemicalSubstance", ["p-sjw", "p-sort"], A, ["hu:adverse-effect:anticoagulant-effect-altered"], "hu:use-constraint:st-johns-wort-with-warfarin"),
     ("hu:assertion:w17-afp-sjw-warfarin-avoid", CA, dict(predicate="USE_CONSTRAINED_WITH", polarity="POSITIVE", speechAct="RECOMMENDS", assertionBasis="EXPERT_OPINION", constraintLevel="AVOID",
        levelVerbatim="It is strongly recommended to avoid concurrent use of St. John's wort with over-the-counter and prescription medications.", **bnd()),
        "hu:material:st-johns-wort-preparation-unspecified", "IngredientMaterial", "hu:substance:warfarin", "ChemicalSubstance", ["p-sjw"], A, [], "hu:use-constraint:st-johns-wort-with-warfarin"),
     ("hu:assertion:w17-afp-american-ginseng-indinavir", IA, dict(predicate="INTERACTS_WITH", polarity="NEGATIVE", speechAct="STATES", basisKind="DIRECT_MEASUREMENT", assertionBasis="STUDY_RESULT",
        evidenceSetting="HUMAN_INTERVENTIONAL", interactionMechanism="NOT_STATED", interactionEffect="NOT_STATED", description="Two human trials demonstrated no effect (a measured absence within those trials)", **bnd()),
        "hu:material:american-ginseng-preparation-unspecified", "IngredientMaterial", "hu:substance:indinavir", "ChemicalSubstance", ["p-amgin"], A, [], "hu:use-constraint:american-ginseng-with-indinavir"),
     ("hu:assertion:w17-ods-vitk-warfarin-interaction", IA, dict(predicate="INTERACTS_WITH", polarity="POSITIVE", speechAct="STATES", basisKind="CITED_FROM_PRIOR_WORK", assertionBasis="EXPERT_OPINION",
        interactionMechanism="VITAMIN_K_ANTAGONISM", interactionEffect="ALTERS_OBJECT_EFFECT", exposureChangeText="sudden changes in vitamin K intakes can increase or decrease the anticoagulant effect", **bnd()),
        "hu:substance:vitamin-k", "ChemicalSubstance", "hu:substance:warfarin", "ChemicalSubstance", ["o-vitk"], ("hu:org:nih-ods", "Organization"), ["hu:adverse-effect:anticoagulant-effect-altered"], "hu:use-constraint:vitamin-k-with-warfarin"),
     ("hu:assertion:w17-ods-vitk-warfarin-consistent", CA, dict(predicate="USE_CONSTRAINED_WITH", polarity="POSITIVE", speechAct="RECOMMENDS", assertionBasis="EXPERT_OPINION", constraintLevel="MAINTAIN_CONSISTENT_INTAKE",
        levelVerbatim="need to maintain a consistent intake of vitamin K from food and supplements", **bnd()),
        "hu:substance:vitamin-k", "ChemicalSubstance", "hu:substance:warfarin", "ChemicalSubstance", ["o-vitk"], ("hu:org:nih-ods", "Organization"), [], "hu:use-constraint:vitamin-k-with-warfarin"),
    ]
    ucs = [("hu:use-constraint:kava-with-warfarin", "kava preparation with warfarin", "hu:material:kava-preparation-unspecified", "IngredientMaterial", "hu:substance:warfarin", "ChemicalSubstance"),
           ("hu:use-constraint:green-tea-extract-with-simvastatin", "green tea extract with simvastatin", "hu:material:green-tea-extract-unspecified", "IngredientMaterial", "hu:substance:simvastatin", "ChemicalSubstance"),
           ("hu:use-constraint:st-johns-wort-with-warfarin", "St. John's wort with warfarin", "hu:material:st-johns-wort-preparation-unspecified", "IngredientMaterial", "hu:substance:warfarin", "ChemicalSubstance"),
           ("hu:use-constraint:american-ginseng-with-indinavir", "American ginseng with indinavir", "hu:material:american-ginseng-preparation-unspecified", "IngredientMaterial", "hu:substance:indinavir", "ChemicalSubstance"),
           ("hu:use-constraint:vitamin-k-with-warfarin", "vitamin K intake with warfarin", "hu:substance:vitamin-k", "ChemicalSubstance", "hu:substance:warfarin", "ChemicalSubstance")]
    for uid, name, s_, sl, m, ml in ucs:
        o += use_constraint(uid, name, s_, sl, [(m, ml, "CO_EXPOSURE", None)])
    for uid, labs, a, s_, sl, ob, ol, locs, asr, eff, uc in items:
        o += assertion(uid, labs, a, s_, sl, ob, ol, locs, asserter=asr[0], alab=asr[1], effects=eff)
        o.append(resolves(uid, labs[0], uc))
    return o

def temporal_cypher():
    o = ["// W17 fixture 05: statin pregnancy contraindication removed by the FDA (DSC 2021-07-20). Correction vs validity-bounded:",
         "// the earlier contraindication was not wrong when stated; it ENDED (SUPERSEDES {VALIDITY_BOUNDED}). Late arrival: W17 ingests",
         "// the 2021 change on 2026-10-04. The pre-2021 assertion is SYNTHETIC (its label capture was not retrieved). Run after 00.", ""]
    T = "hu:treatment:statin-therapy"; F = ("hu:org:us-fda", "Organization"); P = "hu:use-profile:pregnant-patients"
    UC = "hu:use-constraint:statin-therapy-in-pregnancy"
    o += use_constraint(UC, "statin therapy in pregnant patients", T, "Treatment", [(P, "UseContextProfile", "POPULATION", None)], None, "US")
    o += use_constraint("hu:use-constraint:statin-therapy-while-breastfeeding", "statin therapy while breastfeeding", T, "Treatment", [("hu:use-profile:breastfeeding-patients", "UseContextProfile", "POPULATION", None)], None, "US")
    old = "hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020"
    o += assertion(old, CA, dict(predicate="USE_CONSTRAINED_IN", polarity="POSITIVE", speechAct="CAUTIONS", assertionBasis="UNSTATED", constraintLevel="CONTRAINDICATED",
                   levelVerbatim="SYNTHETIC: contraindicated in pregnancy", populationScopeText="all pregnant patients", recordedAt="2020-06-01T00:00:00Z", **US, **bnd(),
                   description="SYNTHETIC stand-in for the class contraindication the 2021 DSC removes"), T, "Treatment", P, "UseContextProfile", ["s-ci"], asserter=F[0], alab=F[1],
                   effects=["hu:adverse-effect:embryofetal-toxicity"], gen=None)
    o.append(resolves(old, "ContraindicationAssertion", UC))
    bounded = "hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020-bounded"
    o += assertion(bounded, CA, dict(predicate="USE_CONSTRAINED_IN", polarity="POSITIVE", speechAct="CAUTIONS", assertionBasis="UNSTATED", constraintLevel="CONTRAINDICATED",
                   levelVerbatim="SYNTHETIC: contraindicated in pregnancy", populationScopeText="all pregnant patients", recordedAt="2026-10-04T02:10:00Z", **US,
                   **bnd(vt="2021-07-20T00:00:00Z", vtp="DAY", vtb="STATED_BY_SOURCE"), description="same proposition with its validity bounded by the FDA DSC of 2021-07-20 (late-arriving end)"),
                   T, "Treatment", P, "UseContextProfile", ["s-ci", "d-remove"], asserter=F[0], alab=F[1], effects=["hu:adverse-effect:embryofetal-toxicity"])
    o.append(edge(bounded, "ContraindicationAssertion", "SUPERSEDES", old, "ContraindicationAssertion", {"supersessionKind": "VALIDITY_BOUNDED", "recordedAt": dt("2026-10-04T02:10:00Z")}))
    o.append(f"MATCH (a:ContraindicationAssertion {{uid: {lit(old)}}})\nSET a.recordedTo = datetime('2026-10-04T02:10:00Z'), a.status = 'SUPERSEDED';")
    o.append(resolves(bounded, "ContraindicationAssertion", UC))
    rows = [
     ("hu:assertion:w17-fda-dsc-2021-pregnancy-contraindication-removed", dict(predicate="USE_CONSTRAINED_IN", polarity="NEGATIVE", speechAct="STATES", assertionBasis="EXPERT_OPINION", constraintLevel="CONTRAINDICATED",
        levelVerbatim="removing the contraindication against using these medicines in all pregnant patients", populationScopeText="all pregnant patients",
        scopeExceptionText="a small group of very high-risk pregnant patients", **US, **bnd(vf="2021-07-20T00:00:00Z", vfp="DAY", vfb="STATED_BY_SOURCE")), P, ["d-remove", "d-exception"], UC),
     ("hu:assertion:w17-fda-dsc-2021-pregnancy-stop", dict(predicate="USE_CONSTRAINED_IN", polarity="POSITIVE", speechAct="RECOMMENDS", assertionBasis="EXPERT_OPINION", constraintLevel="AVOID",
        levelVerbatim="most patients should stop statins once they learn they are pregnant", populationScopeText="most pregnant patients", **US, **bnd(vf="2021-07-20T00:00:00Z", vfp="DAY", vfb="STATED_BY_SOURCE")), P, ["d-stop"], UC),
     ("hu:assertion:w17-fda-dsc-2021-breastfeeding-avoid", dict(predicate="USE_CONSTRAINED_IN", polarity="POSITIVE", speechAct="RECOMMENDS", assertionBasis="EXPERT_OPINION", constraintLevel="AVOID",
        levelVerbatim="Patients should not breastfeed when taking a statin", **US, **bnd(vf="2021-07-20T00:00:00Z", vfp="DAY", vfb="STATED_BY_SOURCE")), "hu:use-profile:breastfeeding-patients", ["d-breastfeed"], "hu:use-constraint:statin-therapy-while-breastfeeding"),
    ]
    for uid, a, obj, locs, uc in rows:
        o += assertion(uid, CA, a, T, "Treatment", obj, "UseContextProfile", locs, asserter=F[0], alab=F[1])
        o.append(resolves(uid, "ContraindicationAssertion", uc))
    return o

def ae_cypher():
    o = ["// W17 fixture 01: reported zero with collection method vs no AE report (notReported) vs systematically collected zero",
         "// (measured absence within one study). Basis/NRPT rows reuse W09 uids (MERGE-compatible with W09 fixture 05). Run after 00.", ""]
    st = "hu:study:nct02678611-basis-nrpt"
    o.append(node(st, ["Study", "Entity"], {"entityType": "Study", "name": "NCT02678611 Basis/NRPT safety study", "studyKind": "INTERVENTIONAL_RANDOMIZED"}))
    for k, name, typ, itt in [("placebo", "Placebo", "PLACEBO_COMPARATOR", 40), ("nrpt-1x", "NRPT 1X", "EXPERIMENTAL", 40), ("nrpt-2x", "NRPT 2X", "EXPERIMENTAL", 38)]:
        au = "hu:arm:nct02678611-" + k
        o.append(node(au, ["StudyArm", "VersionedState"], {"stateType": "StudyArm", "payloadHash": sha("arm:" + au), "name": name, "armType": typ}))
        o.append(edge(st, "Study", "HAS_ARM", au, "StudyArm"))
    def ae(uid, arm, term, ser, aff, ev, atrisk, method, mtext, locs, rel="NOT_REPORTED"):
        s = [node(uid, ["AdverseEventResult", "StudyResult", "InformationArtifact"], {"artifactType": "AdverseEventResult", "resultKind": "ADVERSE_EVENT_COUNT", "analysisKind": "SAFETY",
              "comparisonKind": "ARM_DESCRIPTIVE", "statisticalConclusion": "NOT_TESTED", "eventTerm": term, "seriousness": ser, "participantsAffected": aff, "eventCount": ev,
              "participantsAtRisk": atrisk, "collectionMethod": method, "collectionMethodText": mtext, "relatednessAssessor": rel, "timeFrameText": "8 weeks"})]
        s.append(edge(uid, "AdverseEventResult", "RESULT_FOR_ARM", arm, "StudyArm", {"armRole": "INTERVENTION"}))
        for l in locs: s.append(edge(uid, "AdverseEventResult", "SUPPORTED_BY", LOC[l], "SourceLocator"))
        return s
    # serious-AE zero (reported zero, collection method NOT_DESCRIBED; wording 'self-reported AEs')
    o += ae("hu:study-result:nct02678611-ae-serious-nrpt-2x", "hu:arm:nct02678611-nrpt-2x", "Serious adverse event", "SERIOUS", 0, 0, 38, "NOT_DESCRIBED", "self-reported AEs", ["m-sae", "m-selfrep"])
    # related AEs per arm (possibly or probably related, as assessed; assessor not stated)
    for k, aff, ev, n in [("placebo", 1, 1, 40), ("nrpt-1x", 1, 1, 40), ("nrpt-2x", 5, 5, 38)]:
        o += ae(f"hu:study-result:nct02678611-ae-related-{k}", f"hu:arm:nct02678611-{k}", "Adverse event assessed as possibly or probably related to the product", "ANY", aff, ev, n, "NOT_DESCRIBED", "self-reported AEs", ["m-related", "m-selfrep"])
    # SYNTHETIC systematic zero (measured absence within the study)
    sst = "hu:study:synthetic-w17-systematic-checklist"
    o.append(node(sst, ["Study", "Entity"], {"entityType": "Study", "name": "SYNTHETIC: NR 1 g/day 12-week trial with a structured GI symptom checklist at every visit", "studyKind": "INTERVENTIONAL_RANDOMIZED"}))
    o.append(node("hu:arm:synthetic-w17-systematic-active", ["StudyArm", "VersionedState"], {"stateType": "StudyArm", "payloadHash": sha("arm:synthetic-w17-systematic-active"), "name": "Active", "armType": "EXPERIMENTAL"}))
    o.append(edge(sst, "Study", "HAS_ARM", "hu:arm:synthetic-w17-systematic-active", "StudyArm"))
    o += ae("hu:study-result:synthetic-w17-systematic-gi-zero", "hu:arm:synthetic-w17-systematic-active", "Gastrointestinal adverse event", "ANY", 0, 0, 30, "SYSTEMATIC",
            "SYNTHETIC: structured GI symptom checklist administered at every scheduled visit", [], rel="INVESTIGATOR")
    # SYNTHETIC study whose only publication has no AE section: NO AdverseEventResult is written (notReported, never zero)
    o.append(node("hu:study:synthetic-w17-no-ae-report", ["Study", "Entity"], {"entityType": "Study", "name": "SYNTHETIC: NR open-label study whose publication has no adverse-event section", "studyKind": "INTERVENTIONAL_SINGLE_ARM"}))
    return o

def signals_cypher():
    o = ["// W17 fixture 02: SafetySignal as an EvidenceAssessment. v1 cites two AdverseEventResults (+ a NOT_REPORTED study);",
         "// v2 re-evaluates with a new method version and supersedes v1; two FDA AEMS imports (closed-no-action vs confirmed);",
         "// one migrated live row whose evidenceStrength 'HIGH' stays a hint (NOT_EVALUATED). Run after 00 and 01.", ""]
    def sig(uid, p, subjects, effect, inputs, gen=None, locs=(), conds=()):
        base = {"assessmentType": "SafetySignal", "status": "PROPOSED", "recordedAt": dt(p.pop("recordedAt"))}
        base.update(p)
        s = [node(uid, ["SafetySignal", "EvidenceAssessment"], base)]
        for i, (su, sl, role, ep) in enumerate(subjects):
            q = {"relationshipUid": f"hu:rel:{oid(uid)}-subject-{i}", "subjectRole": role, "orderIndex": i}; q.update(ep or {})
            s.append(edge(su, sl, "HAS_SAFETY_SIGNAL", uid, "SafetySignal", q))
        if effect: s.append(edge(uid, "SafetySignal", "RELATES_TO_EFFECT", effect, "AdverseEffect"))
        for c in conds: s.append(edge(uid, "SafetySignal", "RELATES_TO_CONDITION", c, "Condition"))
        for i, (iu, il, st_, role) in enumerate(inputs):
            s.append(edge(uid, "SafetySignal", "SIGNAL_BASED_ON", iu, il, {"aeReportedStatus": st_, "inputRole": role, "orderIndex": i}))
        if gen: s.append(edge(uid, "SafetySignal", "WAS_GENERATED_BY", gen, "Activity"))
        for l in locs: s.append(edge(uid, "SafetySignal", "SUPPORTED_BY", LOC[l], "SourceLocator"))
        return s
    NRPT = ("hu:material:nct02678611-nrpt-as-supplied", "IngredientMaterial")
    v1 = "hu:safety-signal:w17-nrpt-gi-tolerability-v1"
    o += sig(v1, dict(methodVersion="bl-safety-signal/0.1", recordedAt="2026-10-04T02:30:00Z", signalStatus="POTENTIAL", signalType="DOSE_RELATED_TOLERABILITY", severity="MODERATE",
                      evidenceCutoff=dt("2026-10-04T02:25:00Z"), name="NRPT 2X related GI/tolerability AEs (v1)",
                      summary="5 possibly/probably related AEs in 5/38 NRPT 2X participants vs 1/40 placebo; self-reported, collection method not described; one NR study considered had no AE report (not counted as zero)."),
             [(NRPT[0], NRPT[1], "PRIMARY", {"doseText": "NRPT 2X: 500 mg NR + 100 mg PT daily (4 capsules)", "route": "oral", "frequency": "daily, 8 weeks", "populationSubset": "healthy adults 60-80 years"})],
             "hu:adverse-effect:gastrointestinal-intolerance",
             [("hu:study-result:nct02678611-ae-related-nrpt-2x", "StudyResult", "REPORTED", "INDEX_ARM"),
              ("hu:study-result:nct02678611-ae-related-placebo", "StudyResult", "REPORTED", "COMPARATOR_ARM"),
              ("hu:study:synthetic-w17-no-ae-report", "Study", "NOT_REPORTED", "NOT_REPORTED_STUDY")], gen="hu:activity:w17-signal-run-001")
    v2 = "hu:safety-signal:w17-nrpt-gi-tolerability-v2"
    o += sig(v2, dict(methodVersion="bl-safety-signal/0.2", recordedAt="2026-10-04T02:40:00Z", signalStatus="INSUFFICIENT_DATA", signalType="DOSE_RELATED_TOLERABILITY", severity="MODERATE",
                      evidenceCutoff=dt("2026-10-04T02:35:00Z"), name="NRPT related GI/tolerability AEs (v2)",
                      summary="v0.2 adds the 1X arm and a systematically collected zero from another NR trial; counts are too small and collection differs; INSUFFICIENT_DATA."),
             [(NRPT[0], NRPT[1], "PRIMARY", {"doseText": "NRPT 1X and 2X: 250-500 mg NR + 50-100 mg PT daily", "route": "oral"})],
             "hu:adverse-effect:gastrointestinal-intolerance",
             [("hu:study-result:nct02678611-ae-related-nrpt-2x", "StudyResult", "REPORTED", "INDEX_ARM"),
              ("hu:study-result:nct02678611-ae-related-nrpt-1x", "StudyResult", "REPORTED", "INDEX_ARM"),
              ("hu:study-result:nct02678611-ae-related-placebo", "StudyResult", "REPORTED", "COMPARATOR_ARM"),
              ("hu:study-result:synthetic-w17-systematic-gi-zero", "StudyResult", "REPORTED", "INDEX_ARM"),
              ("hu:study:synthetic-w17-no-ae-report", "Study", "NOT_REPORTED", "NOT_REPORTED_STUDY")], gen="hu:activity:w17-signal-run-002")
    o.append(edge(v2, "SafetySignal", "SUPERSEDES", v1, "SafetySignal", {"supersessionKind": "RE_REVIEW", "recordedAt": dt("2026-10-04T02:40:00Z")}))
    o.append(f"MATCH (s:SafetySignal {{uid: {lit(v1)}}})\nSET s.recordedTo = datetime('2026-10-04T02:40:00Z'), s.status = 'SUPERSEDED';")
    # derived Study -> SafetySignal (live REPORTS_SAFETY_SIGNAL), rule ss-study/v1 over the AE inputs
    o.append(edge("hu:study:nct02678611-basis-nrpt", "Study", "REPORTS_SAFETY_SIGNAL", v2, "SafetySignal", {"derivationRule": "ss-study/v1", "derivedFromAssessmentUids": [v2], "derivedAt": dt("2026-10-04T02:41:00Z")}))
    # FDA AEMS listings as FDA assertions, imported by agency-signal-import/0.1
    for key, sub, eff, loc in [("lenvatinib-tls", "hu:substance:lenvatinib", "hu:adverse-effect:tumor-lysis-syndrome", "a-lenva"), ("daptomycin-hyperkalemia", "hu:substance:daptomycin", "hu:adverse-effect:hyperkalemia", "a-dapto")]:
        au = f"hu:assertion:w17-fda-aems-2024q3-{key}"
        o += assertion(au, ["Assertion"], dict(predicate="IDENTIFIES_POTENTIAL_SAFETY_SIGNAL", polarity="POSITIVE", speechAct="STATES", assertionBasis="UNSTATED", **US,
                       **bnd(vf="2024-07-01T00:00:00Z", vfp="QUARTER", vfb="STATED_BY_SOURCE"), description="FDA lists a potential signal; FDA states this does not mean it has concluded the drug has the risk"),
                       sub, "ChemicalSubstance", eff, "AdverseEffect", [loc], asserter="hu:org:us-fda", alab="Organization")
    o += sig("hu:safety-signal:w17-fda-aems-lenvatinib-tls", dict(methodVersion="agency-signal-import/0.1", recordedAt="2026-10-04T02:45:00Z", signalStatus="CLOSED_NO_ACTION", signalType="NEW_EFFECT",
                      name="Lenvatinib - tumor lysis syndrome (FDA AEMS Jul-Sep 2024)", summary="FDA: 'no action was necessary at the time based on available information' (as of 2025-10-24). Not 'no risk'."),
             [("hu:substance:lenvatinib", "ChemicalSubstance", "PRIMARY", None)], "hu:adverse-effect:tumor-lysis-syndrome",
             [("hu:assertion:w17-fda-aems-2024q3-lenvatinib-tls", "Assertion", "REPORTED", "AGENCY_LISTING")], locs=["a-lenva", "a-asof"])
    o += sig("hu:safety-signal:w17-fda-aems-daptomycin-hyperkalemia", dict(methodVersion="agency-signal-import/0.1", recordedAt="2026-10-04T02:45:00Z", signalStatus="CONFIRMED_ASSOCIATION", signalType="NEW_EFFECT",
                      name="Daptomycin - hyperkalemia (FDA AEMS Jul-Sep 2024)", summary="FDA: Adverse Reactions labeling updated April and May 2025 to include hyperkalemia (as of 2025-10-24)."),
             [("hu:substance:daptomycin", "ChemicalSubstance", "PRIMARY", None)], "hu:adverse-effect:hyperkalemia",
             [("hu:assertion:w17-fda-aems-2024q3-daptomycin-hyperkalemia", "Assertion", "REPORTED", "AGENCY_LISTING")], locs=["a-dapto", "a-asof"])
    # migrated live SafetySignal row: evidenceStrength HIGH kept as a hint; NOT_EVALUATED; no inputs
    o += sig("hu:safety-signal:w17-legacy-live-row-0001", dict(methodVersion="live-migration/0", recordedAt="2026-10-04T02:50:00Z", signalStatus="NOT_EVALUATED", signalType="hepatotoxicity",
                      legacyEvidenceStrengthHint="HIGH", name="Liver toxicity (migrated live SafetySignal row)", interactionSummary="may interact with alcohol (legacy free text)",
                      summary="Migrated from live SafetySignal with SafetyMetadata.evidenceStrength=HIGH and no method or inputs."),
             [("hu:substance:nicotinic-acid", "ChemicalSubstance", "PRIMARY", {"doseText": "high dose (legacy text)", "notes": "migrated SafetyMetadata; evidenceStrength and confidence dropped to the hint"})],
             "hu:adverse-effect:myopathy", [])
    return o

def negative_cypher():
    o = ["// W17 fixture 90: MUST-FAIL cases. Each block names the validator that must report it (06-fixtures-and-queries.md).",
         "// Load into a database that already holds fixtures 00-05; every uid is prefixed 'neg-'.", ""]
    # N1 hint promoted to verdict, no inputs
    o.append(node("hu:safety-signal:neg-w17-n1-hint-as-verdict", ["SafetySignal", "EvidenceAssessment"], {"assessmentType": "SafetySignal", "methodVersion": "live-migration/0", "status": "ACCEPTED",
                  "recordedAt": dt("2026-10-04T03:00:00Z"), "signalStatus": "CONFIRMED_ASSOCIATION", "legacyEvidenceStrengthHint": "HIGH", "name": "N1 legacy hint read as confirmed"}))
    o.append(edge("hu:substance:nicotinic-acid", "ChemicalSubstance", "HAS_SAFETY_SIGNAL", "hu:safety-signal:neg-w17-n1-hint-as-verdict", "SafetySignal", {"relationshipUid": "hu:rel:neg-w17-n1-s", "subjectRole": "PRIMARY"}))
    o.append(edge("hu:safety-signal:neg-w17-n1-hint-as-verdict", "SafetySignal", "RELATES_TO_EFFECT", "hu:adverse-effect:myopathy", "AdverseEffect"))
    # N2 zero AE without collection method
    o.append(node("hu:study-result:neg-w17-n2-zero-no-method", ["AdverseEventResult", "StudyResult", "InformationArtifact"], {"artifactType": "AdverseEventResult", "analysisKind": "SAFETY", "comparisonKind": "ARM_DESCRIPTIVE",
                  "statisticalConclusion": "NOT_TESTED", "eventTerm": "Serious adverse event", "seriousness": "SERIOUS", "participantsAffected": 0, "eventCount": 0}))
    o.append(edge("hu:study-result:neg-w17-n2-zero-no-method", "AdverseEventResult", "RESULT_FOR_ARM", "hu:arm:synthetic-w17-systematic-active", "StudyArm", {"armRole": "INTERVENTION"}))
    # N3 fabricated zero for a study whose publication has no AE report (and is used as NOT_REPORTED input)
    o.append(node("hu:arm:neg-w17-n3-arm", ["StudyArm", "VersionedState"], {"stateType": "StudyArm", "payloadHash": sha("neg-n3"), "name": "N3 arm"}))
    o.append(edge("hu:study:synthetic-w17-no-ae-report", "Study", "HAS_ARM", "hu:arm:neg-w17-n3-arm", "StudyArm"))
    o.append(node("hu:study-result:neg-w17-n3-fabricated-zero", ["AdverseEventResult", "StudyResult", "InformationArtifact"], {"artifactType": "AdverseEventResult", "analysisKind": "SAFETY", "comparisonKind": "ARM_DESCRIPTIVE",
                  "statisticalConclusion": "NOT_TESTED", "eventTerm": "Any adverse event", "seriousness": "ANY", "participantsAffected": 0, "eventCount": 0, "collectionMethod": "NOT_DESCRIBED",
                  "collectionMethodText": "no AE section in the publication (fabricated zero)"}))
    o.append(edge("hu:study-result:neg-w17-n3-fabricated-zero", "AdverseEventResult", "RESULT_FOR_ARM", "hu:arm:neg-w17-n3-arm", "StudyArm", {"armRole": "INTERVENTION"}))
    # N4 HAS_SAFETY_SIGNAL written as an asserted edge citing an interaction assertion
    o.append(edge("hu:material:grapefruit-juice", "IngredientMaterial", "HAS_SAFETY_SIGNAL", "hu:safety-signal:w17-nrpt-gi-tolerability-v2", "SafetySignal",
                  {"relationshipUid": "hu:rel:neg-w17-n4", "subjectRole": "CO_EXPOSURE", "assertionUid": "hu:assertion:w17-zocor-ia-grapefruit", "recordedFrom": dt("2026-10-04T03:00:00Z")}))
    # N5 niacin directive resolved to a constraint on nicotinamide riboside (shared B3 family is not the same substance)
    o += use_constraint("hu:use-constraint:neg-w17-n5-nr-with-simvastatin", "N5 NR with simvastatin (wrong transfer)", "hu:substance:nicotinamide-riboside", "ChemicalSubstance",
                        [("hu:substance:simvastatin", "ChemicalSubstance", "CO_EXPOSURE", None)])
    o.append(edge("hu:assertion:w17-zocor-ia-niacin", "InteractionAssertion", "RESOLVES_TO_CONSTRAINT", "hu:use-constraint:neg-w17-n5-nr-with-simvastatin", "UseConstraint",
                  {"derivationRule": "uc-match/v1", "derivedFromAssertionUids": ["hu:assertion:w17-zocor-ia-niacin"]}))
    # N6 'no interaction' inferred from no record
    o += assertion("hu:assertion:neg-w17-n6-no-record-as-negative", IA, dict(predicate="INTERACTS_WITH", polarity="NEGATIVE", speechAct="STATES", basisKind="HYPOTHESIS", **bnd(),
                   description="N6: written because no interaction record was found"), "hu:substance:nicotinamide-riboside", "ChemicalSubstance", "hu:substance:simvastatin", "ChemicalSubstance", [], gen=None)
    # N7 dose-limit directive without a dose band
    o += assertion("hu:assertion:neg-w17-n7-dose-limit-without-dose", CA, dict(predicate="USE_CONSTRAINED_WITH", polarity="POSITIVE", speechAct="CAUTIONS", constraintLevel="DO_NOT_EXCEED_DOSE", **bnd(),
                   levelVerbatim="Do not exceed ZOCOR 20 mg once daily."), "hu:substance:simvastatin", "ChemicalSubstance", "hu:substance:verapamil", "ChemicalSubstance", ["z-dose-verap"], gen=None)
    # N8 signal with two PRIMARY subjects and no effect
    o.append(node("hu:safety-signal:neg-w17-n8-two-primaries", ["SafetySignal", "EvidenceAssessment"], {"assessmentType": "SafetySignal", "methodVersion": "bl-safety-signal/0.1", "status": "PROPOSED",
                  "recordedAt": dt("2026-10-04T03:00:00Z"), "signalStatus": "POTENTIAL"}))
    for i, s_ in enumerate(["hu:substance:simvastatin", "hu:substance:verapamil"]):
        o.append(edge(s_, "ChemicalSubstance", "HAS_SAFETY_SIGNAL", "hu:safety-signal:neg-w17-n8-two-primaries", "SafetySignal", {"relationshipUid": f"hu:rel:neg-w17-n8-{i}", "subjectRole": "PRIMARY"}))
    o.append(edge("hu:safety-signal:neg-w17-n8-two-primaries", "SafetySignal", "SIGNAL_BASED_ON", "hu:study-result:nct02678611-ae-related-nrpt-2x", "StudyResult", {"aeReportedStatus": "REPORTED"}))
    # N9 legacy SafetyMetadata shape (evidenceStrength + confidence on the edge, no assessmentUid)
    o.append(edge("hu:substance:gemfibrozil", "ChemicalSubstance", "HAS_SAFETY_SIGNAL", "hu:safety-signal:w17-legacy-live-row-0001", "SafetySignal",
                  {"relationshipUid": "hu:rel:neg-w17-n9", "subjectRole": "CO_EXPOSURE", "evidenceStrength": "HIGH", "confidence": 0.9}))
    # N10 private uid leaking into a shared UseConstraint
    o.append(node("hu:use-constraint:neg-w17-n10-personal", ["UseConstraint", "Entity"], {"entityType": "USE_CONSTRAINT", "identityKeyHash": sha("neg-n10"), "identityKeyVersion": "uc-key/v1",
                  "name": "N10 constraint created for one person's declared medication", "declaredByContextUid": "hu:private-user-context-version:neg-0001"}))
    o.append(edge("hu:use-constraint:neg-w17-n10-personal", "UseConstraint", "CONSTRAINS_USE_OF", "hu:material:kava-preparation-unspecified", "IngredientMaterial"))
    # N11 new assessment writing legacy SERIOUS severity
    o.append(node("hu:safety-signal:neg-w17-n11-serious-severity", ["SafetySignal", "EvidenceAssessment"], {"assessmentType": "SafetySignal", "methodVersion": "bl-safety-signal/0.2", "status": "PROPOSED",
                  "recordedAt": dt("2026-10-04T03:00:00Z"), "signalStatus": "POTENTIAL", "severity": "SERIOUS"}))
    o.append(edge("hu:substance:simvastatin", "ChemicalSubstance", "HAS_SAFETY_SIGNAL", "hu:safety-signal:neg-w17-n11-serious-severity", "SafetySignal", {"relationshipUid": "hu:rel:neg-w17-n11", "subjectRole": "PRIMARY"}))
    o.append(edge("hu:safety-signal:neg-w17-n11-serious-severity", "SafetySignal", "RELATES_TO_EFFECT", "hu:adverse-effect:rhabdomyolysis", "AdverseEffect"))
    o.append(edge("hu:safety-signal:neg-w17-n11-serious-severity", "SafetySignal", "SIGNAL_BASED_ON", "hu:assertion:w17-zocor-ia-grapefruit", "Assertion", {"aeReportedStatus": "NOT_APPLICABLE"}))
    # N12 live shape: SafetySignal -AFFECTS_ORGAN-> Organ
    o.append(edge("hu:safety-signal:w17-legacy-live-row-0001", "SafetySignal", "AFFECTS_ORGAN", "hu:anatomical-context:skeletal-muscle", "Organ"))
    # N13 AdverseEffect merged with a Condition by name (one node carrying both labels)
    o.append(node("hu:adverse-effect:neg-w17-n13-rhabdo-merged", ["AdverseEffect", "Condition", "Entity"], {"entityType": "ADVERSE_EFFECT", "name": "rhabdomyolysis"}))
    return o

def write(name, lines):
    with open(os.path.join(OUT, name), "w") as f:
        f.write("\n".join(lines) + "\n")
write("00-w17-base.cypher", base_cypher())
write("01-ae-zero-vs-not-reported.cypher", ae_cypher())
write("02-safety-signal-assessments.cypher", signals_cypher())
write("03-constraints-block-vs-lower.cypher", constraints_cypher())
write("04-interactions-unknown-blocks.cypher", interactions_cypher())
write("05-statin-pregnancy-validity-bounded.cypher", temporal_cypher())
write("90-negative-must-fail.cypher", negative_cypher())
print("ok")
