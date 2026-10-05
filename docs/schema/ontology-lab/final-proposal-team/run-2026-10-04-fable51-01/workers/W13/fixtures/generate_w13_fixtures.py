#!/usr/bin/env python3
"""Generator for W13 fixtures. Every statement binds its own nodes by uid; no variable crosses ';'.
Output files go to the W13 fixtures directory."""
import hashlib, json, os, unicodedata, re

OUT = "/home/user/biotech-meta/docs/schema/ontology-lab/final-proposal-team/run-2026-10-04-fable51-01/workers/W13/fixtures"
REC = "2026-10-04T02:00:00Z"   # fixture commit time (recorded time) for today's ingestion
RET = "2026-10-04T01:00:00Z"   # retrieval time of this session's captures


def nfc_ws1(s):
    s = unicodedata.normalize("NFC", s)
    return re.sub(r"\s+", " ", s).strip()


def sha(s):
    return "sha256:" + hashlib.sha256(nfc_ws1(s).encode("utf-8")).hexdigest()


def lit(v):
    if v is None:
        return "null"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, list):
        return "[" + ", ".join(lit(x) for x in v) + "]"
    if isinstance(v, str) and v.startswith("dt:"):
        return "datetime('%s')" % v[3:]
    s = str(v).replace("\\", "\\\\").replace("'", "\\'")
    return "'" + s + "'"


def m(props):
    return "{" + ", ".join("%s: %s" % (k, lit(v)) for k, v in props.items()) + "}"


ARCH = {
    "Entity": lambda p: {"entityType": p},
    "VersionedState": lambda p: {"stateType": p},
    "InformationArtifact": lambda p: {"artifactType": p},
    "Occurrence": lambda p: {"occurrenceType": p},
}

LABELS = {  # primary -> label list (primary first, archetype last)
    "RegulatoryAgency": ["RegulatoryAgency", "Organization", "Entity"],
    "Organization": ["Organization", "Entity"],
    "Facility": ["Facility", "Entity"],
    "Product": ["Product", "Entity"],
    "IngredientMaterial": ["IngredientMaterial", "Entity"],
    "MaterialMixture": ["MaterialMixture", "Entity"],
    "AssayVersion": ["AssayVersion", "VersionedState"],
    "RegulatoryPathway": ["RegulatoryPathway", "Entity"],
    "RegulatoryPathwayVersion": ["RegulatoryPathwayVersion", "VersionedState"],
    "RegulatoryStep": ["RegulatoryStep", "Entity"],
    "RegulatorySubmission": ["RegulatorySubmission", "InformationArtifact"],
    "RegulatoryResponse": ["RegulatoryResponse", "InformationArtifact"],
    "RegulatoryStatus": ["RegulatoryStatus", "VersionedState"],
    "OrphanDesignation": ["OrphanDesignation", "RegulatoryStatus", "VersionedState"],
    "DrugApproval": ["DrugApproval", "RegulatoryStatus", "VersionedState"],
    "RegulatoryInspection": ["RegulatoryInspection", "Occurrence"],
    "Source": ["Source", "Entity"],
    "SourceSnapshot": ["SourceSnapshot", "InformationArtifact"],
    "SourceLocator": ["SourceLocator", "InformationArtifact"],
    "Assertion": ["Assertion"],
    "Adjudication": ["Adjudication", "EvidenceAssessment"],
    "Identifier": ["Identifier", "Entity"],
}
ARCHTYPE = {"Entity": "Entity", "VersionedState": "VersionedState", "InformationArtifact": "InformationArtifact",
            "Occurrence": "Occurrence"}


class F:
    def __init__(self, name, header):
        self.name = name
        self.lines = [header.rstrip() + "\n"]
        self.label_of = {}

    def c(self, text):
        self.lines.append("\n// " + text.replace("\n", "\n// ") + "\n")

    def stmt(self, s, comment=None):
        if comment:
            self.lines.append("// " + comment + "\n")
        self.lines.append(s.rstrip() + ";\n")

    def node(self, primary, uid, props, kind=None, comment=None):
        labels = LABELS[primary]
        self.label_of[uid] = primary
        arch = labels[-1]
        p = {"id": uid.split(":", 2)[2]}
        if arch in ARCH:
            p.update(ARCH[arch](kind or primary.upper()))
        p.update(props)
        if arch == "VersionedState" and "payloadHash" not in p:
            payload = {k: v for k, v in sorted(p.items()) if k not in ("id", "createdAt", "name", "description")}
            p["payloadHash"] = sha(json.dumps(payload, sort_keys=True))
        p.setdefault("createdAt", "dt:" + REC)
        p.setdefault("privacyClass", "PUBLIC")
        lab = ":".join(labels)
        self.stmt("MERGE (n:%s {uid: %s})\nSET n += %s" % (lab, lit(uid), m(p)), comment)

    def lab(self, uid):
        return self.label_of[uid]

    def edge(self, rtype, a, b, props=None, comment=None, la=None, lb=None):
        la = la or self.lab(a)
        lb = lb or self.lab(b)
        props = props or {}
        key = {}
        if "relationshipUid" in props:
            key = {"relationshipUid": props["relationshipUid"]}
        rest = {k: v for k, v in props.items() if k not in key}
        s = "MATCH (a:%s {uid: %s}), (b:%s {uid: %s})\nMERGE (a)-[r:%s%s]->(b)" % (
            la, lit(a), lb, lit(b), rtype, (" " + m(key)) if key else "")
        if rest:
            s += "\nSET r += %s" % m(rest)
        self.stmt(s, comment)

    def source(self, key, uri, kind, title, snap_ret=RET, completeness="PARTIAL_EXCERPT", published=None,
               observed=None):
        self.node("Source", "hu:source:" + key, {"canonicalUri": uri, "sourceKind": kind, "name": title})
        sp = {"canonicalUri": uri, "retrievedAt": "dt:" + snap_ret, "observedAt": "dt:" + (observed or snap_ret),
              "captureCompleteness": completeness, "contentHashBasis": "SYNTHETIC_FIXTURE",
              "contentHash": sha("synthetic snapshot " + key + snap_ret)}
        if published:
            sp["publishedAt"] = "dt:" + published
        snap = "hu:snapshot:%s-%s" % (key, snap_ret[:10])
        self.node("SourceSnapshot", snap, sp, kind="SOURCE_SNAPSHOT")
        self.edge("HAS_SNAPSHOT", "hu:source:" + key, snap)
        return snap

    def locator(self, snap, key, exact=None, section=None):
        uid = "hu:locator:" + key
        p = {}
        if exact:
            p.update({"selectorKind": "TEXT_QUOTE", "exact": exact, "quoteHash": sha(exact),
                      "normalizationVersion": "NFC-WS1"})
        else:
            p.update({"selectorKind": "SECTION", "section": section})
        self.node("SourceLocator", uid, p, kind="SOURCE_LOCATOR")
        self.edge("HAS_LOCATOR", snap, uid)
        return uid

    def assertion(self, key, predicate, subj, obj=None, value=None, loc=None, asserter=None, status="ACCEPTED",
                  rec=REC, extra=None, comment=None):
        uid = "hu:assertion:" + key
        p = {"predicate": predicate, "status": status, "recordedAt": "dt:" + rec,
             "predicateClass": "REGULATORY"}
        if value is not None:
            p["valueString"] = value
        if extra:
            p.update(extra)
        p["contentHash"] = sha(json.dumps({k: str(v) for k, v in sorted(p.items())}, sort_keys=True) + subj + str(obj))
        self.node("Assertion", uid, p, comment=comment)
        self.edge("HAS_SUBJECT", uid, subj)
        if obj:
            self.edge("HAS_OBJECT", uid, obj)
        if loc:
            for l in (loc if isinstance(loc, list) else [loc]):
                self.edge("SUPPORTED_BY", uid, l)
        if asserter:
            self.edge("ASSERTED_BY", uid, asserter)
        return uid

    def asserted_edge(self, rtype, a, b, akey, rel, loc, asserter, valid=None, rec=REC, comment=None,
                      status="ACCEPTED", rto=None):
        """Assertion + asserted edge with the asserted_edge profile; valid = dict of validFrom.. on both."""
        valid = valid or {}
        vprops = {"validFromBasis": "UNKNOWN", "validToBasis": "UNKNOWN"}
        vprops.update(valid)
        auid = "hu:assertion:" + akey
        if auid not in self.label_of:
            self.assertion(akey, rtype, a, b, loc=loc, asserter=asserter, rec=rec, extra=valid, status=status,
                           comment=comment)
        ep = {"relationshipUid": "hu:rel:" + rel, "assertionUid": auid, "recordedFrom": "dt:" + rec}
        ep.update(vprops)
        if rto:
            ep["recordedTo"] = "dt:" + rto
        self.edge(rtype, a, b, ep)
        return auid

    def write(self):
        with open(os.path.join(OUT, self.name), "w") as fh:
            fh.write("".join(self.lines))


def day(d):
    return "dt:%sT00:00:00Z" % d


# =====================================================================================================================
# Shared base (sources, agencies, pathways, versions, subjects) -- reused by every fixture file via base(f)
# =====================================================================================================================

def base(f):
    f.c("Section B1: agencies (Organization specialization; uid token org, W13-SR-02)")
    f.node("RegulatoryAgency", "hu:org:us-fda", {"name": "U.S. Food and Drug Administration", "agencyCode": "FDA",
                                                   "jurisdiction": "US", "organizationKind": "REGULATORY_AGENCY"},
           kind="REGULATORY_AGENCY")
    f.node("RegulatoryAgency", "hu:org:european-commission", {"name": "European Commission", "agencyCode": "EC",
                                                                "jurisdiction": "EU",
                                                                "organizationKind": "REGULATORY_AGENCY"},
           kind="REGULATORY_AGENCY")
    f.node("RegulatoryAgency", "hu:org:uk-food-standards-agency", {"name": "Food Standards Agency",
                                                                     "agencyCode": "FSA", "jurisdiction": "GB",
                                                                     "organizationKind": "REGULATORY_AGENCY"},
           kind="REGULATORY_AGENCY")

    f.c("Section B2: sources consulted in this session (NEW_RETRIEVAL, partial excerpts; hashes are synthetic)")
    s_grn = f.source("fda-grn-000635-response", "https://www.fda.gov/food/gras-notice-inventory/agency-response-letter-gras-notice-no-grn-000635",
                     "REGULATORY_RECORD", "Agency Response Letter GRAS Notice No. GRN 000635", published="2016-08-03T00:00:00Z")
    s_inv = f.source("fda-gras-inventory-grn-635", "https://www.hfpappexternal.fda.gov/scripts/fdcc/index.cfm?set=GRASNotices&id=635",
                     "REGULATORY_RECORD", "GRAS Notices inventory entry GRN No. 635")
    s_tru = f.source("truniagen-regulatory", "https://pages.truniagen.com/regulatory", "MARKETING_PAGE",
                     "Tru Niagen regulatory page (search extract)")
    s_510k = f.source("fda-510k-k234070", "https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfpmn/pmn.cfm?ID=K234070",
                      "REGULATORY_RECORD", "510(k) Premarket Notification K234070")
    s_den = f.source("fda-denovo-den200080", "https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfpmn/denovo.cfm?id=DEN200080",
                     "REGULATORY_RECORD", "De Novo DEN200080")
    s_oopd = f.source("fda-oopd-628218", "https://www.accessdata.fda.gov/scripts/opdlisting/oopd/detailedIndex.cfm?cfgridkey=628218",
                      "REGULATORY_RECORD", "Orphan Drug Designations and Approvals: nicotinamide riboside and pterostilbene")
    s_daf = f.source("fda-drugsatfda-nda-217785", "https://www.accessdata.fda.gov/scripts/cder/daf/index.cfm?event=overview.process&ApplNo=217785",
                     "REGULATORY_RECORD", "Drugs@FDA NDA 217785")
    s_fr24 = f.source("fr-2024-08935", "https://www.federalregister.gov/documents/2024/05/06/2024-08935/medical-devices-laboratory-developed-tests",
                      "REGULATORY_RECORD", "Medical Devices; Laboratory Developed Tests (89 FR 37286)", published="2024-05-06T00:00:00Z")
    s_fr25 = f.source("fr-2025-18239", "https://www.federalregister.gov/documents/2025/09/19/2025-18239/regulation-identification-number-0910-aj05-medical-devices-laboratory-developed-tests-implementation",
                      "REGULATORY_RECORD", "LDT Implementation of Vacatur (FR 2025-18239)", published="2025-09-19T00:00:00Z")
    s_fr16 = f.source("fr-2016-19164", "https://www.federalregister.gov/documents/2016/08/17/2016-19164/substances-generally-recognized-as-safe",
                      "REGULATORY_RECORD", "Substances Generally Recognized as Safe (81 FR 54960)", published="2016-08-17T00:00:00Z")

    L = {}
    L["grn_conditions"] = f.locator(s_grn, "grn-000635-intended-use", exact="for use as a source of vitamin B3 in vitamin waters, protein shakes, nutrition bars, gum, chews, and powdered beverages at a maximum level of 0.0057% by weight as consumed")
    L["grn_conclusion"] = f.locator(s_grn, "grn-000635-conclusion", exact="the agency has no questions at this time regarding ChromaDex’s conclusion that NR is GRAS under the intended conditions of use. The agency has not, however, made its own determination regarding the GRAS status of the subject use of NR.")
    L["grn_dates"] = f.locator(s_grn, "grn-000635-dates", exact="FDA received the notice on March 9, 2016, filed it on March 29, 2016, and designated it as GRAS Notice No. GRN 000635.")
    L["grn_ul"] = f.locator(s_grn, "grn-000635-ul", exact="ChromaDex estimates an upper tolerable intake level (UL) of 3 mg/kg bw/day, or 180 mg/day assuming a body weight of 60 kg")
    L["grn_basis"] = f.locator(s_grn, "grn-000635-basis", exact="in accordance with the agency’s proposed regulation, proposed 21 Code of Federal Regulations (CFR) 170.36 (62 FR 18938; April 17, 1997; Substances Generally Recognized as Safe (GRAS); the GRAS proposal)")
    L["inv_row"] = f.locator(s_inv, "gras-inventory-635-row", section="GRN No. 635: Date of filing Mar 29, 2016; Date of closure Aug 3, 2016; FDA's Letter: FDA has no questions; Notifier: ChromaDex, Inc.")
    L["tru_grn"] = f.locator(s_tru, "truniagen-gras-line-2026-10-04", exact="FDA GRAS no objection for Niagen (nicotinamide riboside chloride) on August 05, 2016")
    L["k234070"] = f.locator(s_510k, "k234070-record", section="510(k) Number K234070; Device Name Stelo Glucose Biosensor System; Applicant Dexcom, Inc.; Classification Product Code SAF; Date Received 12/22/2023; Decision Date 03/05/2024; Decision Substantially Equivalent (SESE); Predetermined Change Control Plan Authorized No")
    L["den200080"] = f.locator(s_den, "den200080-record", section="De Novo Number DEN200080; Device Name Paige Prostate; Requester paige.ai; Classification Product Code QPN; Regulation Number 864.3750; Date Received 12/31/2020; Decision Date 09/21/2021; Decision granted (DENG); Predetermined Change Control Plan Authorized No")
    L["oopd"] = f.locator(s_oopd, "oopd-628218-record", section="Generic Name: nicotinamide riboside and pterostilbene; Date Designated: 03/19/2018; Orphan Designation: Treatment of Amyotrophic Lateral Sclerosis; Orphan Designation Status: Designated; FDA Orphan Approval Status: Not FDA Approved for Orphan Indication; Sponsor: Elysium Health Inc.")
    L["nda"] = f.locator(s_daf, "nda-217785-orig-1", section="Products on NDA 217785: REZDIFFRA (RESMETIROM) 60MG, 80MG, 100MG TABLET;ORAL; Original Approvals: 03/14/2024 ORIG-1 Approval, Type 1 - New Molecular Entity, PRIORITY")
    L["fr24_dates"] = f.locator(s_fr24, "fr-2024-08935-dates", exact="This rule is effective July 5, 2024.")
    L["fr24_ed"] = f.locator(s_fr24, "fr-2024-08935-phaseout", exact="FDA is phasing out its general enforcement discretion approach for LDTs")
    L["fr25_vacatur"] = f.locator(s_fr25, "fr-2025-18239-summary", exact="On March 31, 2025, a federal district court vacated that rule. This final rule reverts to the text of the regulation as it existed prior to the effective date of the May 2024 final rule.")
    L["fr25_dates"] = f.locator(s_fr25, "fr-2025-18239-dates", exact="This rule is effective September 19, 2025.")
    L["fr16_dates"] = f.locator(s_fr16, "fr-2016-19164-dates", exact="This rule is effective October 17, 2016.")

    f.c("Section B3: subjects (other owners' identities, minimal stubs; W01, W02, W04, W07)")
    f.node("Organization", "hu:org:niagen-bioscience-inc", {"name": "Niagen Bioscience, Inc. (formerly ChromaDex, Inc.)"}, kind="ORGANIZATION")
    f.node("Organization", "hu:org:dexcom-inc", {"name": "Dexcom, Inc."}, kind="ORGANIZATION")
    f.node("Organization", "hu:org:paige-ai", {"name": "paige.ai"}, kind="ORGANIZATION")
    f.node("Organization", "hu:org:elysium-health-inc", {"name": "Elysium Health Inc."}, kind="ORGANIZATION")
    f.node("IngredientMaterial", "hu:material:niagen-nrc", {"name": "Niagen nicotinamide riboside chloride"}, kind="INGREDIENT_MATERIAL")
    f.node("MaterialMixture", "hu:mixture:nr-and-pterostilbene-oopd-628218", {"name": "nicotinamide riboside and pterostilbene (as designated)"}, kind="MATERIAL_MIXTURE")
    f.node("Product", "hu:product:rezdiffra", {"name": "REZDIFFRA (resmetirom) tablets"}, kind="PRODUCT")
    f.node("Product", "hu:product:dexcom-stelo", {"name": "Stelo Glucose Biosensor System"}, kind="PRODUCT")
    f.node("Product", "hu:product:paige-prostate", {"name": "Paige Prostate"}, kind="PRODUCT")
    f.node("Product", "hu:product:tru-niagen-300-capsules", {"name": "Tru Niagen 300 mg capsules (synthetic stub)"}, kind="PRODUCT")
    f.node("Facility", "hu:facility:synthetic-supplement-plant", {"name": "Synthetic supplement plant"}, kind="FACILITY")
    f.node("AssayVersion", "hu:assay-version:synthetic-ldt-nad-panel-v1", {"name": "Synthetic laboratory-developed NAD+ panel v1"}, kind="ASSAY_VERSION")

    f.c("Section B4: pathways (Entity) and legal-basis versions (VersionedState) -- decision W13-D02")
    for key, kind, name, juris in [
        ("us-fda-gras-notice", "GRAS_NOTICE", "FDA GRAS notification program", "US"),
        ("us-fda-ndi-notification", "NDI_NOTIFICATION", "FDA new dietary ingredient notification", "US"),
        ("us-fda-510k", "PREMARKET_NOTIFICATION_510K", "FDA premarket notification 510(k)", "US"),
        ("us-fda-de-novo", "DE_NOVO", "FDA De Novo classification", "US"),
        ("us-fda-nda", "NDA", "FDA new drug application", "US"),
        ("us-fda-orphan-designation", "ORPHAN_DESIGNATION", "FDA orphan drug designation", "US"),
        ("us-fda-food-facility-registration", "FOOD_FACILITY_REGISTRATION", "FDA food facility registration", "US"),
        ("us-fda-ldt-oversight", "LDT_POLICY", "FDA oversight of laboratory developed tests", "US"),
    ]:
        f.node("RegulatoryPathway", "hu:reg-pathway:" + key, {"name": name, "pathwayKind": kind, "jurisdiction": juris},
               kind="REGULATORY_PATHWAY")
        f.edge("OVERSEES", "hu:org:us-fda", "hu:reg-pathway:" + key, {"orderIndex": None})

    f.node("RegulatoryStep", "hu:reg-step:us-fda-ndi-75-day-wait", {"name": "75-day marketing wait after filing date",
                                                                      "stepKind": "WAITING_PERIOD"}, kind="REGULATORY_STEP",
           comment="template step (uid token reg-step pending W13-SR-04)")
    f.edge("HAS_REGULATORY_STEP", "hu:reg-pathway:us-fda-ndi-notification", "hu:reg-step:us-fda-ndi-75-day-wait", {"orderIndex": 2})

    # GRAS versions: proposed 170.36 interim policy (1997-04-17 .. 2016-10-17) and final subpart E (2016-10-17 ..)
    f.node("RegulatoryPathwayVersion", "hu:reg-pathway-version:us-fda-gras-proposed-170-36",
           {"versionLabel": "GRAS notification under the 1997 proposal", "legalBasisCitation": "proposed 21 CFR 170.36 (62 FR 18938; April 17, 1997)",
            "instrumentCitations": ["62 FR 18938", "81 FR 54960 (ends this regime: effective October 17, 2016)"],
            "effectiveFrom": day("1997-04-17"), "jurisdiction": "US"}, kind="REGULATORY_PATHWAY_VERSION")
    f.node("RegulatoryPathwayVersion", "hu:reg-pathway-version:us-fda-gras-subpart-e",
           {"versionLabel": "GRAS notification under 21 CFR part 170 subpart E", "legalBasisCitation": "21 CFR part 170 subpart E (81 FR 54960)",
            "instrumentCitations": ["81 FR 54960"], "effectiveFrom": day("2016-10-17"), "codifiedTextFrom": day("2016-10-17"),
            "jurisdiction": "US"}, kind="REGULATORY_PATHWAY_VERSION")
    a = f.assertion("gras-pathway-v1-in-force", "HAS_PATHWAY_VERSION", "hu:reg-pathway:us-fda-gras-notice",
                    "hu:reg-pathway-version:us-fda-gras-proposed-170-36", loc=[L["grn_basis"], L["fr16_dates"]],
                    extra={"validFrom": day("1997-04-17"), "validFromPrecision": "DAY", "validFromBasis": "STATED_BY_SOURCE",
                           "validTo": day("2016-10-17"), "validToPrecision": "DAY", "validToBasis": "STATED_BY_SOURCE"})
    f.edge("HAS_PATHWAY_VERSION", "hu:reg-pathway:us-fda-gras-notice", "hu:reg-pathway-version:us-fda-gras-proposed-170-36",
           {"relationshipUid": "hu:rel:gras-pathway-v1-ep1", "assertionUid": a, "recordedFrom": "dt:" + REC,
            "validFrom": day("1997-04-17"), "validFromPrecision": "DAY", "validFromBasis": "STATED_BY_SOURCE",
            "validTo": day("2016-10-17"), "validToPrecision": "DAY", "validToBasis": "STATED_BY_SOURCE"})
    a = f.assertion("gras-pathway-v2-in-force", "HAS_PATHWAY_VERSION", "hu:reg-pathway:us-fda-gras-notice",
                    "hu:reg-pathway-version:us-fda-gras-subpart-e", loc=L["fr16_dates"],
                    extra={"validFrom": day("2016-10-17"), "validFromPrecision": "DAY", "validFromBasis": "STATED_BY_SOURCE",
                           "validToBasis": "UNKNOWN"})
    f.edge("HAS_PATHWAY_VERSION", "hu:reg-pathway:us-fda-gras-notice", "hu:reg-pathway-version:us-fda-gras-subpart-e",
           {"relationshipUid": "hu:rel:gras-pathway-v2-ep1", "assertionUid": a, "recordedFrom": "dt:" + REC,
            "validFrom": day("2016-10-17"), "validFromPrecision": "DAY", "validFromBasis": "STATED_BY_SOURCE",
            "validToBasis": "UNKNOWN"})
    return L


def ldt_versions(f, L):
    """LDT oversight: three legal-basis versions, with the vacatur learned late (two recorded-time episodes on V2)."""
    f.c("Section L1: LDT legal-basis versions. V1 general enforcement discretion (start unknown, ends 2024-07-05);\n"
        "V2 21 CFR 809.3(a) as amended by 89 FR 37286 (2024-07-05 .. 2025-03-31 vacatur; codified text until 2025-09-19);\n"
        "V3 reverted text after vacatur (legal effect from 2025-03-31; codified 2025-09-19).\n"
        "Synthetic replay of recorded time: captures of 2024-07-08 and 2025-04-02 are SYNTHETIC_FIXTURE snapshots.")
    s_old = f.source("fr-2024-08935-capture-2024", "https://www.federalregister.gov/documents/2024/05/06/2024-08935/medical-devices-laboratory-developed-tests",
                     "REGULATORY_RECORD", "89 FR 37286 (synthetic 2024 capture)", snap_ret="2024-07-08T00:00:00Z")
    l_old = f.locator(s_old, "fr-2024-08935-dates-2024-capture", exact="This rule is effective July 5, 2024.")
    f.node("RegulatoryPathwayVersion", "hu:reg-pathway-version:us-fda-ldt-general-enforcement-discretion",
           {"versionLabel": "LDTs under general enforcement discretion", "legalBasisCitation": "21 CFR 809.3(a) (pre-2024 text) with FDA general enforcement discretion approach for LDTs",
            "instrumentCitations": ["89 FR 37286 (ends this regime: phaseout of the general enforcement discretion approach)"],
            "jurisdiction": "US"}, kind="REGULATORY_PATHWAY_VERSION")
    f.node("RegulatoryPathwayVersion", "hu:reg-pathway-version:us-fda-ldt-rule-2024",
           {"versionLabel": "LDT rule 2024 (vacated)", "legalBasisCitation": "21 CFR 809.3(a) as amended by 89 FR 37286",
            "instrumentCitations": ["89 FR 37286 (FR Doc. 2024-08935)", "Am. Clinical Lab'y Ass'n v. FDA, No. 4:24-CV-479-SDJ (E.D. Tex. Mar. 31, 2025)", "FR Doc. 2025-18239"],
            "effectiveFrom": day("2024-07-05"), "codifiedTextFrom": day("2024-07-05"), "codifiedTextTo": day("2025-09-19"),
            "jurisdiction": "US"}, kind="REGULATORY_PATHWAY_VERSION")
    f.node("RegulatoryPathwayVersion", "hu:reg-pathway-version:us-fda-ldt-post-vacatur",
           {"versionLabel": "LDTs after vacatur (text reverted)", "legalBasisCitation": "21 CFR 809.3(a) as it existed prior to 89 FR 37286 (FR Doc. 2025-18239)",
            "instrumentCitations": ["Am. Clinical Lab'y Ass'n v. FDA, No. 4:24-CV-479-SDJ (E.D. Tex. Mar. 31, 2025)", "FR Doc. 2025-18239"],
            "codifiedTextFrom": day("2025-09-19"), "jurisdiction": "US"}, kind="REGULATORY_PATHWAY_VERSION")
    P = "hu:reg-pathway:us-fda-ldt-oversight"
    # V1 ends when the 2024 rule takes effect
    a1 = f.assertion("ldt-v1-in-force", "HAS_PATHWAY_VERSION", P, "hu:reg-pathway-version:us-fda-ldt-general-enforcement-discretion",
                     loc=[L["fr24_ed"], L["fr24_dates"]],
                     extra={"validFromBasis": "UNKNOWN", "validTo": day("2024-07-05"), "validToPrecision": "DAY", "validToBasis": "STATED_BY_SOURCE"})
    f.edge("HAS_PATHWAY_VERSION", P, "hu:reg-pathway-version:us-fda-ldt-general-enforcement-discretion",
           {"relationshipUid": "hu:rel:ldt-v1-ep1", "assertionUid": a1, "recordedFrom": "dt:" + REC, "validFromBasis": "UNKNOWN",
            "validTo": day("2024-07-05"), "validToPrecision": "DAY", "validToBasis": "STATED_BY_SOURCE"})
    # V2 episode 1 as known on 2024-07-10: open end
    a2a = f.assertion("ldt-v2-in-force-as-of-2024", "HAS_PATHWAY_VERSION", P, "hu:reg-pathway-version:us-fda-ldt-rule-2024",
                      loc=l_old, rec="2024-07-10T00:00:00Z", status="SUPERSEDED",
                      extra={"validFrom": day("2024-07-05"), "validFromPrecision": "DAY", "validFromBasis": "STATED_BY_SOURCE",
                             "validToBasis": "UNKNOWN", "recordedTo": "dt:2025-04-02T00:00:00Z"})
    f.edge("HAS_PATHWAY_VERSION", P, "hu:reg-pathway-version:us-fda-ldt-rule-2024",
           {"relationshipUid": "hu:rel:ldt-v2-ep1", "assertionUid": a2a, "recordedFrom": "dt:2024-07-10T00:00:00Z",
            "recordedTo": "dt:2025-04-02T00:00:00Z", "validFrom": day("2024-07-05"), "validFromPrecision": "DAY",
            "validFromBasis": "STATED_BY_SOURCE", "validToBasis": "UNKNOWN"},
           comment="episode 1 (recorded 2024-07-10, closed 2025-04-02 when the vacatur was ingested)")
    s_vac = f.source("fda-ldt-page-capture-2025", "https://www.fda.gov/medical-devices/in-vitro-diagnostics/laboratory-developed-tests",
                     "REGULATORY_GUIDANCE", "FDA LDT page (synthetic 2025-04-01 capture)", snap_ret="2025-04-01T00:00:00Z")
    l_vac = f.locator(s_vac, "fda-ldt-page-vacatur-2025-capture", section="vacatur of the LDT final rule on March 31, 2025 (synthetic capture; current wording recorded in SRC-FDA-LDT)")
    a2b = f.assertion("ldt-v2-in-force-bounded", "HAS_PATHWAY_VERSION", P, "hu:reg-pathway-version:us-fda-ldt-rule-2024",
                      loc=[l_vac, L["fr25_vacatur"]], rec="2025-04-02T00:00:00Z",
                      extra={"validFrom": day("2024-07-05"), "validFromPrecision": "DAY", "validFromBasis": "STATED_BY_SOURCE",
                             "validTo": day("2025-03-31"), "validToPrecision": "DAY", "validToBasis": "STATED_BY_SOURCE"})
    f.stmt("MATCH (n:Assertion {uid: 'hu:assertion:ldt-v2-in-force-bounded'}), (o:Assertion {uid: 'hu:assertion:ldt-v2-in-force-as-of-2024'})\n"
           "MERGE (n)-[s:SUPERSEDES]->(o)\nSET s += {supersessionKind: 'VALIDITY_BOUNDED', recordedAt: datetime('2025-04-02T00:00:00Z')}",
           "the vacatur ends the regime: SUPERSEDES {VALIDITY_BOUNDED}; valid time of the old assertion is unchanged")
    f.edge("HAS_PATHWAY_VERSION", P, "hu:reg-pathway-version:us-fda-ldt-rule-2024",
           {"relationshipUid": "hu:rel:ldt-v2-ep2", "assertionUid": a2b, "recordedFrom": "dt:2025-04-02T00:00:00Z",
            "validFrom": day("2024-07-05"), "validFromPrecision": "DAY", "validFromBasis": "STATED_BY_SOURCE",
            "validTo": day("2025-03-31"), "validToPrecision": "DAY", "validToBasis": "STATED_BY_SOURCE"},
           comment="episode 2 (recorded 2025-04-02): bounded by the vacatur; legal effect ends 2025-03-31 although codified text ran to 2025-09-19")
    a3 = f.assertion("ldt-v3-in-force", "HAS_PATHWAY_VERSION", P, "hu:reg-pathway-version:us-fda-ldt-post-vacatur",
                     loc=[l_vac, L["fr25_vacatur"]], rec="2025-04-02T00:00:00Z",
                     extra={"validFrom": day("2025-03-31"), "validFromPrecision": "DAY", "validFromBasis": "STATED_BY_SOURCE",
                            "validToBasis": "UNKNOWN"})
    f.edge("HAS_PATHWAY_VERSION", P, "hu:reg-pathway-version:us-fda-ldt-post-vacatur",
           {"relationshipUid": "hu:rel:ldt-v3-ep1", "assertionUid": a3, "recordedFrom": "dt:2025-04-02T00:00:00Z",
            "validFrom": day("2025-03-31"), "validFromPrecision": "DAY", "validFromBasis": "STATED_BY_SOURCE",
            "validToBasis": "UNKNOWN"})
    return P


def status(f, uid, primary, props, subject, loc, asserter, valid, pathway, version=None, response=None,
           agency="hu:org:us-fda", akey=None, rel=None, rec=REC, rto=None, status_="ACCEPTED", comment=None):
    f.node(primary, uid, props, kind="REGULATORY_STATUS", comment=comment)
    f.asserted_edge("STATUS_OF", uid, subject, akey or ("status-of-" + uid.split(":")[2]), rel or ("status-of-" + uid.split(":")[2]),
                    loc, asserter, valid=valid, rec=rec, rto=rto, status=status_)
    f.edge("UNDER_LEGAL_BASIS", uid, pathway)
    if version:
        f.edge("UNDER_LEGAL_BASIS_VERSION", uid, version)
    if response:
        f.edge("RESULTS_FROM_RESPONSE", uid, response)
    f.edge("ISSUED_BY", uid, agency)


def submission(f, key, props, pathway, loc, submitter, subject, agency="hu:org:us-fda", version=None, sub_asserter=None):
    uid = "hu:reg-submission:" + key
    f.node("RegulatorySubmission", uid, props, kind="REGULATORY_SUBMISSION")
    f.edge("UNDER_PATHWAY", uid, pathway)
    if version:
        f.edge("UNDER_LEGAL_BASIS_VERSION", uid, version)
    if submitter:
        f.asserted_edge("SUBMITTED_BY", uid, submitter, "submitted-by-" + key, "submitted-by-" + key, loc, sub_asserter or agency)
    if subject:
        f.asserted_edge("SUBMISSION_ABOUT", uid, subject, "about-" + key, "about-" + key, loc, sub_asserter or agency)
    return uid


def response(f, key, props, sub, agency="hu:org:us-fda"):
    uid = "hu:reg-response:" + key
    f.node("RegulatoryResponse", uid, props, kind="REGULATORY_RESPONSE")
    f.edge("SUBMISSION_HAS_RESPONSE", sub, uid)
    f.edge("ISSUED_BY", uid, agency)
    return uid


DAYV = lambda d_from, d_to=None: dict(
    [("validFrom", day(d_from)), ("validFromPrecision", "DAY"), ("validFromBasis", "STATED_BY_SOURCE")] +
    ([("validTo", day(d_to)), ("validToPrecision", "DAY"), ("validToBasis", "STATED_BY_SOURCE")] if d_to else [("validToBasis", "UNKNOWN")]))


# =====================================================================================================================
# File 1: positive kinds fixture
# =====================================================================================================================

def file_positive():
    f = F("w13-regulatory-kinds.cypher", """// W13 fixture 1 (positive): one subject per regulatory standing; none reads as approval except APPROVAL.
// Run: run-2026-10-04-fable51-01, worker W13 (Opus 5.5). Generated by a script; every statement binds its own nodes by
// uid (no variable crosses ';'); nodes carry the primary label and the archetype label; uids use registered tokens
// except reg-pathway-version, reg-step and mixture (pending W13-SR-04 / W02). Snapshots use contentHashBasis
// SYNTHETIC_FIXTURE; locator quoteHash values are real sha256 over NFC-WS1-normalized quoted text captured on 2026-10-04.
// Expected: zero rows from V-320a, V-320b, V-321, V-322, V-323, V-334, V-335, V-336 and V-W13-01..12 (V-333 as
// written fires for the two-episode LDT status: catalog defect recorded as W13-D11; V-333r returns zero rows).
// Subjects: APPROVAL REZDIFFRA (NDA 217785); CLEARANCE Stelo (K234070); DE_NOVO_AUTHORIZATION Paige Prostate
// (DEN200080); DESIGNATION NR + pterostilbene (OOPD); NOTIFICATION_ON_FILE Niagen NRC (GRN 000635); ENFORCEMENT_DISCRETION
// synthetic LDT (three bounded episodes across the LDT legal-basis change); ESTABLISHMENT_REGISTRATION synthetic plant;
// a marketed product with no status (Tru Niagen 300 mg) answers NOT_RECORDED, never "approved".
""")
    L = base(f)
    P_ldt = ldt_versions(f, L)

    f.c("Section 1: APPROVAL -- NDA 217785 REZDIFFRA, ORIG-1 approval 2024-03-14 (Drugs@FDA)")
    sub = submission(f, "us-fda-nda-217785-orig-1", {"submissionKind": "NDA", "submissionSubtype": "ORIG-1", "identifier": "NDA 217785",
                                                     "jurisdiction": "US"}, "hu:reg-pathway:us-fda-nda", L["nda"],
                     None, "hu:product:rezdiffra")
    r = response(f, "us-fda-nda-217785-orig-1-approval", {"responseKind": "APPROVED", "decisionTextVerbatim": "Approval",
                                                          "issuedAt": day("2024-03-14"), "jurisdiction": "US"}, sub)
    status(f, "hu:regulatory-status:us-rezdiffra-nda-217785-approval", "DrugApproval",
           {"statusKind": "APPROVAL", "jurisdiction": "US", "applicationNumber": "NDA 217785",
            "scopeText": "REZDIFFRA (resmetirom) tablets 60/80/100 mg, NDA 217785 ORIG-1 (indication text not captured)",
            "legalBasisCitation": "FD&C Act 505(b)"}, "hu:product:rezdiffra", L["nda"], "hu:org:us-fda",
           DAYV("2024-03-14"), "hu:reg-pathway:us-fda-nda", response=r)
    f.stmt("MATCH (p:Product {uid: 'hu:product:rezdiffra'})\nSET p.status = 'APPROVED'",
           "live projection Product.status = APPROVED is backed by an APPROVAL status (V-322 passes)")

    f.c("Section 2: CLEARANCE -- 510(k) K234070 Stelo, SESE 2024-03-05, product code SAF, PCCP not authorized")
    sub = submission(f, "us-fda-510k-k234070", {"submissionKind": "PREMARKET_NOTIFICATION_510K", "submissionSubtype": "Traditional",
                                                "identifier": "K234070", "jurisdiction": "US", "receivedAt": day("2023-12-22")},
                     "hu:reg-pathway:us-fda-510k", L["k234070"], "hu:org:dexcom-inc", "hu:product:dexcom-stelo")
    r = response(f, "us-fda-510k-k234070-sese", {"responseKind": "SUBSTANTIALLY_EQUIVALENT", "decisionTextVerbatim": "Substantially Equivalent (SESE)",
                                                  "issuedAt": day("2024-03-05"), "jurisdiction": "US"}, sub)
    status(f, "hu:regulatory-status:us-stelo-k234070-clearance", "RegulatoryStatus",
           {"statusKind": "CLEARANCE", "jurisdiction": "US", "productCode": "SAF", "pcccAuthorized": False,
            "scopeText": "Integrated Continuous Glucose Monitor For Non-Intensive Glucose Monitoring, Over-The-Counter (21 CFR 862.1355)",
            "legalBasisCitation": "FD&C Act 510(k); 21 CFR 807 subpart E"}, "hu:product:dexcom-stelo", L["k234070"], "hu:org:us-fda",
           DAYV("2024-03-05"), "hu:reg-pathway:us-fda-510k", response=r)

    f.c("Section 3: DE_NOVO_AUTHORIZATION -- DEN200080 Paige Prostate, granted 2021-09-21, product code QPN.\n"
        "Subject is the device Product: the record names no model build, so no AlgorithmVersion is asserted.")
    sub = submission(f, "us-fda-de-novo-den200080", {"submissionKind": "DE_NOVO", "submissionSubtype": "Direct", "identifier": "DEN200080",
                                                     "jurisdiction": "US", "receivedAt": day("2020-12-31")},
                     "hu:reg-pathway:us-fda-de-novo", L["den200080"], "hu:org:paige-ai", "hu:product:paige-prostate")
    r = response(f, "us-fda-de-novo-den200080-granted", {"responseKind": "DE_NOVO_GRANTED", "decisionTextVerbatim": "granted (DENG)",
                                                          "issuedAt": day("2021-09-21"), "jurisdiction": "US"}, sub)
    status(f, "hu:regulatory-status:us-paige-prostate-den200080", "RegulatoryStatus",
           {"statusKind": "DE_NOVO_AUTHORIZATION", "jurisdiction": "US", "productCode": "QPN", "pcccAuthorized": False,
            "scopeText": "software algorithm device to assist users in digital pathology (21 CFR 864.3750)",
            "legalBasisCitation": "FD&C Act 513(f)(2)"}, "hu:product:paige-prostate", L["den200080"], "hu:org:us-fda",
           DAYV("2021-09-21"), "hu:reg-pathway:us-fda-de-novo", response=r)

    f.c("Section 4: DESIGNATION -- orphan designation 'nicotinamide riboside and pterostilbene', ALS, 2018-03-19 (OOPD);\n"
        "'Not FDA Approved for Orphan Indication'. Subject is the designated combination (MaterialMixture), not the Basis product.")
    sub = submission(f, "us-fda-orphan-request-nr-pterostilbene-als", {"submissionKind": "ORPHAN_DESIGNATION", "jurisdiction": "US"},
                     "hu:reg-pathway:us-fda-orphan-designation", L["oopd"], "hu:org:elysium-health-inc",
                     "hu:mixture:nr-and-pterostilbene-oopd-628218")
    r = response(f, "us-fda-orphan-nr-pterostilbene-als-granted", {"responseKind": "ORPHAN_DESIGNATION_GRANTED",
                                                                    "decisionTextVerbatim": "Designated",
                                                                    "issuedAt": day("2018-03-19"), "jurisdiction": "US"}, sub)
    status(f, "hu:regulatory-status:us-orphan-nr-pterostilbene-als", "OrphanDesignation",
           {"statusKind": "DESIGNATION", "jurisdiction": "US", "indication": "Treatment of Amyotrophic Lateral Sclerosis",
            "designatedNameVerbatim": "nicotinamide riboside and pterostilbene",
            "scopeText": "Orphan Designation Status: Designated; FDA Orphan Approval Status: Not FDA Approved for Orphan Indication",
            "legalBasisCitation": "FD&C Act 526; 21 CFR part 316"}, "hu:mixture:nr-and-pterostilbene-oopd-628218", L["oopd"],
           "hu:org:us-fda", DAYV("2018-03-19"), "hu:reg-pathway:us-fda-orphan-designation", response=r)

    f.c("Section 5: NOTIFICATION_ON_FILE -- GRAS notice GRN 000635 (dated 2016-03-08, received 2016-03-09, filed\n"
        "2016-03-29), FDA 'no questions' letter 2016-08-03 under proposed 21 CFR 170.36 (legal-basis version 1).")
    sub = submission(f, "us-fda-grn-000635", {"submissionKind": "GRAS_NOTICE", "identifier": "GRN 000635", "jurisdiction": "US",
                                              "submittedAt": day("2016-03-08"), "receivedAt": day("2016-03-09"),
                                              "filingDate": day("2016-03-29"),
                                              "conditionsOfUseText": "as a source of vitamin B3 in vitamin waters, protein shakes, nutrition bars, gum, chews, and powdered beverages at a maximum level of 0.0057% by weight as consumed"},
                     "hu:reg-pathway:us-fda-gras-notice", [L["grn_dates"], L["inv_row"]], "hu:org:niagen-bioscience-inc",
                     "hu:material:niagen-nrc", version="hu:reg-pathway-version:us-fda-gras-proposed-170-36")
    r = response(f, "us-fda-grn-000635", {"responseKind": "GRAS_NO_QUESTIONS", "decisionTextVerbatim": "FDA has no questions",
                                          "issuedAt": day("2016-08-03"), "publishedAt": day("2016-08-03"), "jurisdiction": "US",
                                          "conditionsOfUseText": "as a source of vitamin B3 in vitamin waters, protein shakes, nutrition bars, gum, chews, and powdered beverages at a maximum level of 0.0057% by weight as consumed",
                                          "agencyDisclaimerText": "The agency has not, however, made its own determination regarding the GRAS status of the subject use of NR. | Accordingly, this response should not be construed to be a statement that foods that contain NR, if introduced or delivered for introduction into interstate commerce, would not violate section 301(ll). | The Office of Food Additive Safety neither consulted with ONFL on this labeling issue nor evaluated the information in your notice to determine whether it would support any claims made about NR on the label or in labeling."},
                 sub)
    status(f, "hu:regulatory-status:us-nrc-grn-000635-on-file", "RegulatoryStatus",
           {"statusKind": "NOTIFICATION_ON_FILE", "jurisdiction": "US",
            "scopeText": "GRAS notice GRN 000635, FDA no questions; intended food uses at up to 0.0057% by weight as consumed; not dietary supplements",
            "legalBasisCitation": "proposed 21 CFR 170.36 (62 FR 18938)"}, "hu:material:niagen-nrc",
           [L["grn_conclusion"], L["inv_row"]], "hu:org:us-fda", DAYV("2016-08-03"), "hu:reg-pathway:us-fda-gras-notice",
           response=r)
    f.c("No UNDER_LEGAL_BASIS_VERSION on this status: the filing regime is recorded on the submission; no captured source\n"
        "makes the status depend on the 1997 proposal, so V-334r must not end it on 2016-10-17 (W13-D03).")

    f.c("Section 6: company characterization of the GRAS response (separate Assertion, asserted by the company) and\n"
        "BellLabs SUPPORT adjudications. Adjudication 1 is the round-0005 rationale (inherited); adjudication 2 supersedes it\n"
        "(RE_REVIEW) after the 2026-10-04 full-letter capture: '180 mg/day' is in the FDA letter only as ChromaDex's\n"
        "estimated UL; FDA's letter is dated August 3, 2016 (company: August 05, 2016); FDA wrote 'no questions'.")
    ch = f.assertion("truniagen-characterizes-grn-000635-2026-10-04", "CHARACTERIZES_REGULATORY_RESPONSE",
                     "hu:reg-response:us-fda-grn-000635",
                     value="FDA GRAS no objection for Niagen (nicotinamide riboside chloride) on August 05, 2016; Dose: 180 mg/day; GRN 635",
                     loc=L["tru_grn"], asserter="hu:org:niagen-bioscience-inc",
                     extra={"jurisdiction": "US", "assertionBasis": "MANUFACTURER_CLAIM", "speechAct": "STATES"})
    f.node("Adjudication", "hu:adjudication:truniagen-grn-000635-r0005", {
        "assessmentType": "ADJUDICATION", "adjudicationKind": "SUPPORT", "verdict": "PARTIALLY_SUPPORTED", "status": "SUPERSEDED",
        "methodVersion": "lane3-adjudication-v0", "reviewerType": "AGENT", "recordedAt": "dt:2026-10-03T00:00:00Z",
        "recordedTo": "dt:" + REC,
        "rationale": "INHERITED (round 0005): FDA response is 'no questions' for listed food uses at 0.0057% by weight; the 180 mg/day figure is not in the captured FDA text."},
        kind="ADJUDICATION")
    f.edge("EVALUATES", "hu:adjudication:truniagen-grn-000635-r0005", ch)
    f.node("Adjudication", "hu:adjudication:truniagen-grn-000635-w13", {
        "assessmentType": "ADJUDICATION", "adjudicationKind": "SUPPORT", "verdict": "PARTIALLY_SUPPORTED", "status": "ACCEPTED",
        "methodVersion": "w13-regulatory-characterization-v1", "reviewerType": "AGENT", "humanReviewPending": True,
        "recordedAt": "dt:" + REC, "reviewedAt": "dt:" + REC,
        "rationale": "Supported: an FDA GRAS response for NR exists (GRN 000635). Not supported: 'no objection' (FDA: 'no questions'); 'August 05, 2016' (letter dated August 3, 2016; inventory closure Aug 3, 2016); 'Dose: 180 mg/day' as an FDA condition (180 mg/day appears only as ChromaDex's estimated UL; FDA's stated use is food categories at up to 0.0057% by weight). FDA made no GRAS determination of its own."},
        kind="ADJUDICATION")
    f.edge("EVALUATES", "hu:adjudication:truniagen-grn-000635-w13", ch)
    for l in (L["grn_conclusion"], L["grn_ul"], L["grn_conditions"], L["inv_row"]):
        f.edge("SUPPORTED_BY", "hu:adjudication:truniagen-grn-000635-w13", l)
    f.stmt("MATCH (n:Adjudication {uid: 'hu:adjudication:truniagen-grn-000635-w13'}), (o:Adjudication {uid: 'hu:adjudication:truniagen-grn-000635-r0005'})\n"
           "MERGE (n)-[s:SUPERSEDES]->(o)\nSET s += {supersessionKind: 'RE_REVIEW', recordedAt: datetime('%s')}" % REC)

    f.c("Section 7: ENFORCEMENT_DISCRETION -- synthetic LDT, three status nodes, one per LDT legal-basis version.\n"
        "S2's STATUS_OF has two recorded-time episodes (open as of 2024-07-10; bounded at 2025-03-31 from 2025-04-02).")
    s_lab = f.source("synthetic-lab-ldt-page", "urn:synthetic:lab-ldt-nad-panel", "ORGANIZATION_WEBPAGE",
                     "Synthetic laboratory test page", snap_ret="2024-07-08T00:00:00Z")
    l_lab = f.locator(s_lab, "synthetic-lab-ldt-page-offered", section="synthetic: test offered as an LDT since 2019")
    A = "hu:assay-version:synthetic-ldt-nad-panel-v1"
    status(f, "hu:regulatory-status:us-synthetic-ldt-ed-v1", "RegulatoryStatus",
           {"statusKind": "ENFORCEMENT_DISCRETION", "jurisdiction": "US", "scopeText": "LDT offered under FDA general enforcement discretion (synthetic)",
            "legalBasisCitation": "FDA general enforcement discretion approach for LDTs"}, A, [l_lab, L["fr24_ed"]], None,
           {"validFrom": day("2019-01-01"), "validFromPrecision": "YEAR", "validFromBasis": "STATED_BY_SOURCE",
            "validTo": day("2024-07-05"), "validToPrecision": "DAY", "validToBasis": "STATED_BY_SOURCE"},
           P_ldt, version="hu:reg-pathway-version:us-fda-ldt-general-enforcement-discretion")
    status(f, "hu:regulatory-status:us-synthetic-ldt-ed-v2", "RegulatoryStatus",
           {"statusKind": "ENFORCEMENT_DISCRETION", "jurisdiction": "US", "scopeText": "LDT within the 2024 rule's phaseout (stage 1 not reached) (synthetic)",
            "legalBasisCitation": "21 CFR 809.3(a) as amended by 89 FR 37286; phaseout policy"}, A, [l_lab, L["fr24_dates"]], None,
           {"validFrom": day("2024-07-05"), "validFromPrecision": "DAY", "validFromBasis": "STATED_BY_SOURCE", "validToBasis": "UNKNOWN"},
           P_ldt, version="hu:reg-pathway-version:us-fda-ldt-rule-2024", akey="status-of-ldt-ed-v2-as-of-2024",
           rel="status-of-ldt-ed-v2-ep1", rec="2024-07-10T00:00:00Z", rto="2025-04-02T00:00:00Z", status_="SUPERSEDED")
    f.stmt("MATCH (a:Assertion {uid: 'hu:assertion:status-of-ldt-ed-v2-as-of-2024'})\nSET a.recordedTo = datetime('2025-04-02T00:00:00Z')")
    f.asserted_edge("STATUS_OF", "hu:regulatory-status:us-synthetic-ldt-ed-v2", A, "status-of-ldt-ed-v2-bounded", "status-of-ldt-ed-v2-ep2",
                    [l_lab, L["fr25_vacatur"]], None, rec="2025-04-02T00:00:00Z",
                    valid={"validFrom": day("2024-07-05"), "validFromPrecision": "DAY", "validFromBasis": "STATED_BY_SOURCE",
                           "validTo": day("2025-03-31"), "validToPrecision": "DAY", "validToBasis": "STATED_BY_SOURCE"})
    f.stmt("MATCH (n:Assertion {uid: 'hu:assertion:status-of-ldt-ed-v2-bounded'}), (o:Assertion {uid: 'hu:assertion:status-of-ldt-ed-v2-as-of-2024'})\n"
           "MERGE (n)-[s:SUPERSEDES]->(o)\nSET s += {supersessionKind: 'VALIDITY_BOUNDED', recordedAt: datetime('2025-04-02T00:00:00Z')}")
    status(f, "hu:regulatory-status:us-synthetic-ldt-ed-v3", "RegulatoryStatus",
           {"statusKind": "ENFORCEMENT_DISCRETION", "jurisdiction": "US", "scopeText": "LDT after vacatur of the 2024 rule (synthetic)",
            "legalBasisCitation": "21 CFR 809.3(a) as it existed prior to 89 FR 37286"}, A, [l_lab, L["fr25_vacatur"]], None,
           {"validFrom": day("2025-03-31"), "validFromPrecision": "DAY", "validFromBasis": "STATED_BY_SOURCE", "validToBasis": "UNKNOWN"},
           P_ldt, version="hu:reg-pathway-version:us-fda-ldt-post-vacatur", rec="2025-04-02T00:00:00Z")

    f.c("Section 8: ESTABLISHMENT_REGISTRATION on a Facility (synthetic) and a company cGMP claim that stays a claim")
    s_ffr = f.source("synthetic-ffr-confirmation", "urn:synthetic:fda-food-facility-registration", "REGULATORY_RECORD",
                     "Synthetic food facility registration confirmation")
    l_ffr = f.locator(s_ffr, "synthetic-ffr-confirmation-w13", section="synthetic registration confirmation")
    status(f, "hu:regulatory-status:us-synthetic-plant-ffr", "RegulatoryStatus",
           {"statusKind": "ESTABLISHMENT_REGISTRATION", "jurisdiction": "US", "scopeText": "food facility registration (synthetic)",
            "legalBasisCitation": "21 CFR part 1 subpart H"}, "hu:facility:synthetic-supplement-plant", l_ffr, "hu:org:us-fda",
           DAYV("2024-11-01"), "hu:reg-pathway:us-fda-food-facility-registration")
    s_mk = f.source("synthetic-plant-marketing", "urn:synthetic:plant-marketing-page", "MARKETING_PAGE", "Synthetic marketing page")
    l_mk = f.locator(s_mk, "synthetic-plant-cgmp-claim", exact="Made in our FDA-registered, cGMP-compliant facility")
    f.assertion("synthetic-plant-claims-cgmp", "CLAIMS_CGMP_COMPLIANCE", "hu:facility:synthetic-supplement-plant",
                value="Made in our FDA-registered, cGMP-compliant facility", loc=l_mk, asserter="hu:org:niagen-bioscience-inc",
                status="EXTRACTED", extra={"assertionBasis": "MANUFACTURER_CLAIM", "speechAct": "STATES"})

    f.c("Section 9: a marketed product with no regulatory status. The company markets it (assertion); no status node\n"
        "exists; CQ-AX-23 must answer NOT_RECORDED and the live Product.status must not be APPROVED.")
    f.assertion("niagen-markets-tru-niagen-300", "MARKETS_PRODUCT", "hu:org:niagen-bioscience-inc", "hu:product:tru-niagen-300-capsules",
                loc=L["tru_grn"], asserter="hu:org:niagen-bioscience-inc", extra={"predicateClass": "COMMERCIAL"})

    f.c("Section 10: legacy derived projections (read-only): HAS_REGULATORY_STATUS for product statuses, FOLLOWS_PATHWAY\n"
        "from SUBMISSION_ABOUT; both carry derivationRule and input assertion uids (never projectionOfAssertionUid).")
    for prod, st in [("hu:product:rezdiffra", "hu:regulatory-status:us-rezdiffra-nda-217785-approval"),
                     ("hu:product:dexcom-stelo", "hu:regulatory-status:us-stelo-k234070-clearance"),
                     ("hu:product:paige-prostate", "hu:regulatory-status:us-paige-prostate-den200080")]:
        f.edge("HAS_REGULATORY_STATUS", prod, st, {"derivationRule": "W13-DR-01", "derivedFromAssertionUids": ["hu:assertion:status-of-" + st.split(":")[2]],
                                                   "derivedAt": "dt:" + REC})
    for prod, pw, key in [("hu:product:dexcom-stelo", "hu:reg-pathway:us-fda-510k", "us-fda-510k-k234070"),
                          ("hu:product:paige-prostate", "hu:reg-pathway:us-fda-de-novo", "us-fda-de-novo-den200080"),
                          ("hu:product:rezdiffra", "hu:reg-pathway:us-fda-nda", "us-fda-nda-217785-orig-1")]:
        f.edge("FOLLOWS_PATHWAY", prod, pw, {"derivationRule": "W13-DR-02", "derivedFromAssertionUids": ["hu:assertion:about-" + key],
                                             "derivedAt": "dt:" + REC})

    f.c("Section 11: identifiers (W00 Identifier, HAS_IDENTIFIER) for two submissions")
    for key, scheme, value in [("us-fda-grn-000635", "FDA_GRN", "000635"), ("us-fda-510k-k234070", "FDA_510K", "K234070")]:
        iu = "hu:identifier:%s-%s" % (scheme.lower().replace("_", "-"), value.lower())
        f.node("Identifier", iu, {"scheme": scheme, "value": value, "issuer": "hu:org:us-fda", "jurisdiction": "US"}, kind="IDENTIFIER")
        loc = L["inv_row"] if scheme == "FDA_GRN" else L["k234070"]
        a = f.assertion("identifier-" + key, "HAS_IDENTIFIER", "hu:reg-submission:" + key, iu, loc=loc, asserter="hu:org:us-fda",
                        extra={"predicateClass": "IDENTITY"})
        f.edge("HAS_IDENTIFIER", "hu:reg-submission:" + key, iu, {"relationshipUid": "hu:rel:identifier-" + key, "assertionUid": a,
                                                                 "recordedFrom": "dt:" + REC, "validFromBasis": "UNKNOWN",
                                                                 "validToBasis": "UNKNOWN", "isPrimary": True})
    f.write()


# =====================================================================================================================
# File 2: negatives (each expected to fire a named validator)
# =====================================================================================================================

def file_negative():
    f = F("w13-negative.cypher", """// W13 fixture 2 (negative): each section writes one forbidden shape with its own uids. Load AFTER
// w13-regulatory-kinds.cypher. Expected violations per section are listed in 06-fixtures-and-queries.md (N-01..N-14).
""")
    L = {"grn": "hu:locator:grn-000635-conclusion", "nda": "hu:locator:nda-217785-orig-1", "ffr": "hu:locator:synthetic-ffr-confirmation-w13",
         "k": "hu:locator:k234070-record", "den": "hu:locator:den200080-record", "oopd": "hu:locator:oopd-628218-record"}
    for u, lab in [("hu:org:us-fda", "RegulatoryAgency"), ("hu:product:rezdiffra", "Product"), ("hu:product:tru-niagen-300-capsules", "Product"),
                   ("hu:material:niagen-nrc", "IngredientMaterial"), ("hu:product:dexcom-stelo", "Product"),
                   ("hu:product:paige-prostate", "Product"), ("hu:facility:synthetic-supplement-plant", "Facility"),
                   ("hu:reg-response:us-fda-grn-000635", "RegulatoryResponse"), ("hu:reg-response:us-fda-510k-k234070-sese", "RegulatoryResponse"),
                   ("hu:reg-response:us-fda-de-novo-den200080-granted", "RegulatoryResponse"),
                   ("hu:reg-response:us-fda-orphan-nr-pterostilbene-als-granted", "RegulatoryResponse"),
                   ("hu:reg-pathway:us-fda-gras-notice", "RegulatoryPathway"), ("hu:reg-pathway:us-fda-nda", "RegulatoryPathway"),
                   ("hu:reg-pathway:us-fda-food-facility-registration", "RegulatoryPathway"),
                   ("hu:reg-pathway:us-fda-ldt-oversight", "RegulatoryPathway"), ("hu:reg-pathway:us-fda-510k", "RegulatoryPathway"),
                   ("hu:reg-pathway:us-fda-de-novo", "RegulatoryPathway"), ("hu:reg-pathway:us-fda-ndi-notification", "RegulatoryPathway"),
                   ("hu:reg-pathway-version:us-fda-ldt-rule-2024", "RegulatoryPathwayVersion"),
                   ("hu:reg-pathway-version:us-fda-gras-subpart-e", "RegulatoryPathwayVersion"),
                   ("hu:mixture:nr-and-pterostilbene-oopd-628218", "MaterialMixture"),
                   ("hu:assay-version:synthetic-ldt-nad-panel-v1", "AssayVersion"),
                   ("hu:regulatory-status:us-synthetic-plant-ffr", "RegulatoryStatus"),
                   ("hu:org:niagen-bioscience-inc", "Organization"),
                   ("hu:regulatory-status:us-nrc-grn-000635-on-file", "RegulatoryStatus")] + [
                   (v, "SourceLocator") for v in L.values()]:
        f.label_of[u] = lab

    f.c("N-01 (V-336, INV-304): APPROVAL status for Tru Niagen with no approving response (company says 'FDA approved')")
    status(f, "hu:regulatory-status:neg-tru-niagen-approval-no-response", "RegulatoryStatus",
           {"statusKind": "APPROVAL", "jurisdiction": "US", "scopeText": "NEGATIVE: approval asserted from nothing"},
           "hu:product:tru-niagen-300-capsules", L["grn"], "hu:org:niagen-bioscience-inc", DAYV("2016-08-03"),
           "hu:reg-pathway:us-fda-nda")
    f.c("N-02 (V-323, INV-304): establishment registration attached to a Product ('made in an FDA-registered facility')")
    f.asserted_edge("STATUS_OF", "hu:regulatory-status:us-synthetic-plant-ffr", "hu:product:tru-niagen-300-capsules",
                    "neg-ffr-status-of-product", "neg-ffr-status-of-product", L["ffr"], "hu:org:niagen-bioscience-inc", valid=DAYV("2024-11-01"))
    f.c("N-03 (V-320a, V-320b, V-336): GRAS 'no questions' projected as approval of NRC")
    status(f, "hu:regulatory-status:neg-nrc-gras-approval", "RegulatoryStatus",
           {"statusKind": "APPROVAL", "jurisdiction": "US", "scopeText": "NEGATIVE: GRAS no questions read as approval"},
           "hu:material:niagen-nrc", L["grn"], None, DAYV("2016-08-03"), "hu:reg-pathway:us-fda-gras-notice",
           response="hu:reg-response:us-fda-grn-000635")
    f.c("N-04 (V-320a, V-321): orphan designation response projected as a DrugApproval")
    status(f, "hu:regulatory-status:neg-orphan-as-drug-approval", "DrugApproval",
           {"statusKind": "APPROVAL", "jurisdiction": "US", "scopeText": "NEGATIVE: designation read as approval"},
           "hu:mixture:nr-and-pterostilbene-oopd-628218", L["oopd"], None, DAYV("2018-03-19"), "hu:reg-pathway:us-fda-nda",
           response="hu:reg-response:us-fda-orphan-nr-pterostilbene-als-granted")
    f.c("N-05 (V-320a, V-336): 510(k) clearance projected as approval")
    status(f, "hu:regulatory-status:neg-stelo-approval", "RegulatoryStatus",
           {"statusKind": "APPROVAL", "jurisdiction": "US", "scopeText": "NEGATIVE: clearance read as approval"},
           "hu:product:dexcom-stelo", L["k"], None, DAYV("2024-03-05"), "hu:reg-pathway:us-fda-510k",
           response="hu:reg-response:us-fda-510k-k234070-sese")
    f.c("N-06 (V-320a, V-W13-12): De Novo grant read as PMA approval (BellLabs inferred assertion derived from the status)")
    a = f.assertion("neg-paige-pma-approval-inferred", "PMA_APPROVAL", "hu:product:paige-prostate", value="PMA approved",
                    extra={"basisKind": "CALCULATED", "derivationRule": "NEGATIVE: De Novo grant read as PMA approval"})
    f.stmt("MATCH (c:Assertion {uid: 'hu:assertion:neg-paige-pma-approval-inferred'}), (i:Assertion {uid: 'hu:assertion:status-of-us-paige-prostate-den200080'})\nMERGE (c)-[:DERIVED_FROM_ASSERTION]->(i)")
    f.c("N-07 (V-322): live Product.status = APPROVED for a marketed supplement with no APPROVAL status")
    f.stmt("MATCH (p:Product {uid: 'hu:product:tru-niagen-300-capsules'})\nSET p.status = 'APPROVED'")
    f.c("N-08 (V-334r): a status under the 2024 LDT rule whose episode outlives the vacatur")
    status(f, "hu:regulatory-status:neg-ldt-outlives-vacatur", "RegulatoryStatus",
           {"statusKind": "ENFORCEMENT_DISCRETION", "jurisdiction": "US", "scopeText": "NEGATIVE: status continues past vacatur"},
           "hu:assay-version:synthetic-ldt-nad-panel-v1", L["grn"], None, DAYV("2024-07-05", "2025-09-19"),
           "hu:reg-pathway:us-fda-ldt-oversight", version="hu:reg-pathway-version:us-fda-ldt-rule-2024")
    f.c("N-09 (V-335): accepted company characterization with no SUPPORT adjudication")
    f.assertion("neg-unadjudicated-characterization", "CHARACTERIZES_REGULATORY_RESPONSE", "hu:reg-response:us-fda-grn-000635",
                value="FDA approved Niagen as safe", loc=L["grn"], asserter="hu:org:niagen-bioscience-inc")
    f.c("N-10 (V-W13-03): response kind outside the submission's pathway (GRAS submission answered with SUBSTANTIALLY_EQUIVALENT)")
    sub = submission(f, "neg-gras-notice-se-response", {"submissionKind": "GRAS_NOTICE", "jurisdiction": "US"},
                     "hu:reg-pathway:us-fda-gras-notice", None, None, None)
    response(f, "neg-gras-notice-se-response", {"responseKind": "SUBSTANTIALLY_EQUIVALENT", "jurisdiction": "US"}, sub)
    f.c("N-11 (V-W13-04, V-W13-05): submissionKind differs from its pathway; status legal-basis version from another pathway")
    submission(f, "neg-kind-mismatch", {"submissionKind": "NDI_NOTIFICATION", "jurisdiction": "US"}, "hu:reg-pathway:us-fda-510k", None, None, None)
    status(f, "hu:regulatory-status:neg-version-from-other-pathway", "RegulatoryStatus",
           {"statusKind": "NOTIFICATION_ON_FILE", "jurisdiction": "US", "scopeText": "NEGATIVE: GRAS status under an LDT version"},
           "hu:material:niagen-nrc", L["grn"], None, DAYV("2016-08-03"), "hu:reg-pathway:us-fda-gras-notice",
           version="hu:reg-pathway-version:us-fda-ldt-rule-2024")
    f.c("N-12 (V-W13-08): legacy HAS_REGULATORY_STATUS written for a Facility registration status onto a Product, citing a non-STATUS_OF input")
    f.edge("HAS_REGULATORY_STATUS", "hu:product:tru-niagen-300-capsules", "hu:regulatory-status:us-synthetic-plant-ffr",
           {"derivationRule": "W13-DR-01", "derivedFromAssertionUids": ["hu:assertion:synthetic-plant-claims-cgmp"], "derivedAt": "dt:" + REC})
    f.c("N-13 (V-W13-12): cGMP compliance inferred from registration and from the company's cGMP claim; GRAS determination\n"
        "inferred from 'no questions'; authorization inferred from enforcement discretion")
    for key, pred, inp in [("neg-cgmp-from-registration", "CGMP_COMPLIANT", "hu:assertion:status-of-us-synthetic-plant-ffr"),
                           ("neg-cgmp-from-claim", "CGMP_COMPLIANT", "hu:assertion:synthetic-plant-claims-cgmp"),
                           ("neg-gras-determination", "FDA_GRAS_DETERMINATION", "hu:assertion:status-of-us-nrc-grn-000635-on-file"),
                           ("neg-ldt-authorized", "AUTHORIZATION", "hu:assertion:status-of-us-synthetic-ldt-ed-v3")]:
        subj = "hu:facility:synthetic-supplement-plant" if "cgmp" in key else ("hu:material:niagen-nrc" if "gras" in key else "hu:assay-version:synthetic-ldt-nad-panel-v1")
        f.assertion(key, pred, subj, value="NEGATIVE inference", extra={"basisKind": "CALCULATED", "derivationRule": "NEGATIVE " + key})
        f.stmt("MATCH (c:Assertion {uid: 'hu:assertion:%s'}), (i:Assertion {uid: '%s'})\nMERGE (c)-[:DERIVED_FROM_ASSERTION]->(i)" % (key, inp))
    f.c("N-14 (V-W13-06): two current HAS_PATHWAY_VERSION episodes of one pathway overlapping in valid time")
    f.edge("HAS_PATHWAY_VERSION", "hu:reg-pathway:us-fda-gras-notice", "hu:reg-pathway-version:us-fda-gras-subpart-e",
           {"relationshipUid": "hu:rel:neg-gras-v2-overlap", "assertionUid": "hu:assertion:gras-pathway-v2-in-force", "recordedFrom": "dt:" + REC,
            "validFrom": day("2010-01-01"), "validFromPrecision": "DAY", "validFromBasis": "INFERRED", "validToBasis": "UNKNOWN"})
    f.write()


# =====================================================================================================================
# File 3: pending seams (jurisdiction partition, NDI filing acknowledgment) -- values not yet in the catalog enums
# =====================================================================================================================

def file_pending():
    f = F("w13-jurisdiction-and-pending-values.cypher", """// W13 fixture 3: jurisdiction partition (US / EU / GB) for nicotinamide riboside chloride and the NDI 1062 filing
// acknowledgment. Load AFTER w13-regulatory-kinds.cypher. Uses PROPOSED enum values (W13-SR-03: PathwayKind
// NOVEL_FOOD_AUTHORISATION, RegulatoryResponseKind NOVEL_FOOD_AUTHORISED; W13-SR-06: NDI_FILING_ACKNOWLEDGED).
// Expected until those seam requests are ruled: V-W13-02 rows for each proposed value; V-336 rows for the two
// APPROVAL statuses (their response kind is not in the approving set). After ruling (approving set extended to
// NOVEL_FOOD_AUTHORISED): zero rows. Jurisdiction code GB-GBN (Great Britain) is requested from W00 in W13-SR-01.
""")
    for u, lab in [("hu:org:us-fda", "RegulatoryAgency"), ("hu:org:european-commission", "RegulatoryAgency"),
                   ("hu:org:uk-food-standards-agency", "RegulatoryAgency"), ("hu:material:niagen-nrc", "IngredientMaterial"),
                   ("hu:org:niagen-bioscience-inc", "Organization"), ("hu:reg-pathway:us-fda-ndi-notification", "RegulatoryPathway"),
                   ("hu:locator:truniagen-gras-line-2026-10-04", "SourceLocator")]:
        f.label_of[u] = lab
    s_eu = f.source("eurlex-2020-16", "https://eur-lex.europa.eu/eli/reg_impl/2020/16/oj/eng", "REGULATORY_RECORD",
                    "Commission Implementing Regulation (EU) 2020/16", published="2020-01-10T00:00:00Z")
    l_eu = f.locator(s_eu, "eurlex-2020-16-union-list-entry", exact="Food Supplements as defined in Directive 2002/46/EC 300 mg/day for the general adult population, excluding pregnant and lactating women")
    l_eu2 = f.locator(s_eu, "eurlex-2020-16-authorised-on", exact="Authorised on 20 February 2020.")
    s_gb = f.source("fsa-gb-novel-96", "https://data.food.gov.uk/regulated-products/novel_authorisations/novel-96", "REGULATORY_RECORD",
                    "FSA register: Nicotinamide riboside chloride NOVEL-96")
    l_gb = f.locator(s_gb, "fsa-novel-96-status", section="Authorised novel ID NOVEL-96; Status: Authorised; Applies in: England, Scotland, Wales; Links: Assimilated EU Regulations 2017/2470, 2020/16")
    for key, juris, name, agency in [("eu-novel-food", "EU", "EU novel food authorisation (Regulation (EU) 2015/2283)", "hu:org:european-commission"),
                                     ("gb-novel-food", "GB-GBN", "GB novel food authorisation (assimilated Regulation (EU) 2015/2283)", "hu:org:uk-food-standards-agency")]:
        f.node("RegulatoryPathway", "hu:reg-pathway:" + key, {"name": name, "pathwayKind": "NOVEL_FOOD_AUTHORISATION", "jurisdiction": juris},
               kind="REGULATORY_PATHWAY")
        f.edge("OVERSEES", agency, "hu:reg-pathway:" + key, {"orderIndex": None})
    sub = submission(f, "eu-novel-food-nrc-chromadex", {"submissionKind": "NOVEL_FOOD_AUTHORISATION", "jurisdiction": "EU",
                                                        "conditionsOfUseText": "food supplements"},
                     "hu:reg-pathway:eu-novel-food", l_eu, "hu:org:niagen-bioscience-inc", "hu:material:niagen-nrc",
                     agency="hu:org:european-commission")
    r = response(f, "eu-2020-16-nrc", {"responseKind": "NOVEL_FOOD_AUTHORISED", "decisionTextVerbatim": "Commission Implementing Regulation (EU) 2020/16",
                                       "issuedAt": day("2020-01-10"), "jurisdiction": "EU",
                                       "conditionsOfUseText": "Food Supplements as defined in Directive 2002/46/EC 300 mg/day for the general adult population, excluding pregnant and lactating women; 230 mg/day for pregnant and lactating women"},
                 sub, agency="hu:org:european-commission")
    status(f, "hu:regulatory-status:eu-nrc-novel-food", "RegulatoryStatus",
           {"statusKind": "APPROVAL", "jurisdiction": "EU", "scopeText": "Union list entry 'Nicotinamide riboside chloride'; food supplements 300 mg/day adults (230 mg/day pregnant and lactating women); data protection to ChromaDex until 20 February 2025",
            "legalBasisCitation": "Regulation (EU) 2015/2283; Commission Implementing Regulation (EU) 2020/16"},
           "hu:material:niagen-nrc", [l_eu, l_eu2], "hu:org:european-commission", DAYV("2020-02-20"), "hu:reg-pathway:eu-novel-food",
           response=r, agency="hu:org:european-commission")
    status(f, "hu:regulatory-status:gb-nrc-novel-food", "RegulatoryStatus",
           {"statusKind": "APPROVAL", "jurisdiction": "GB-GBN", "scopeText": "NOVEL-96 Authorised; applies in England, Scotland, Wales (Northern Ireland not covered by this register entry; NI position not captured)",
            "legalBasisCitation": "Assimilated Regulation (EU) 2020/16"},
           "hu:material:niagen-nrc", l_gb, "hu:org:uk-food-standards-agency",
           {"validFromBasis": "UNKNOWN", "validToBasis": "UNKNOWN"}, "hu:reg-pathway:gb-novel-food", response=r,
           agency="hu:org:uk-food-standards-agency")

    f.c("NDI 1062: submitted 2017-12-27, amended 2018-02-05 and 2018-03-06; FDA filing letter dated 2018-03-07 says acceptance\n"
        "for filing 'is a procedural matter' and 'does not constitute a finding by FDA that the new dietary ingredient ... is safe'.\n"
        "The company lists 'FDA NDIN no objection ... March 07, 2018 ... NDI 1062'. The 2018 response letter was not captured.")
    s_ack = f.source("regulations-gov-fda-2018-s-0023-0032", "https://downloads.regulations.gov/FDA-2018-S-0023-0032/attachment_1.pdf",
                     "REGULATORY_RECORD", "FDA filing letter NDI 1062 (regulations.gov FDA-2018-S-0023-0032)", published="2018-03-07T00:00:00Z")
    l_ack = f.locator(s_ack, "ndi-1062-filing-letter-procedural", exact="Please note that acceptance of this notification for filing is a procedural matter, and thus, does not constitute a finding by FDA that the new dietary ingredient or supplement that contains the new dietary ingredient is safe or is not adulterated under 21 U .S.C. § 342.")
    sub = submission(f, "us-fda-ndi-1062", {"submissionKind": "NDI_NOTIFICATION", "identifier": "NDI 1062", "jurisdiction": "US",
                                            "submittedAt": day("2017-12-27"),
                                            "conditionsOfUseText": "take 2 capsules, each containing 125mg NIAGEN®, for a daily serving of 250 mg NIAGEN® ... no more than 300 mg NIAGEN® a day"},
                     "hu:reg-pathway:us-fda-ndi-notification", l_ack, "hu:org:niagen-bioscience-inc", "hu:material:niagen-nrc")
    ack = response(f, "us-fda-ndi-1062-filing-ack", {"responseKind": "NDI_FILING_ACKNOWLEDGED", "issuedAt": day("2018-03-07"), "jurisdiction": "US",
                                                     "agencyDisclaimerText": "acceptance of this notification for filing is a procedural matter, and thus, does not constitute a finding by FDA that the new dietary ingredient or supplement that contains the new dietary ingredient is safe or is not adulterated"},
                   sub)
    ch = f.assertion("truniagen-characterizes-ndi-1062", "CHARACTERIZES_REGULATORY_RESPONSE", ack,
                     value="FDA NDIN no objection for Niagen (nicotinamide riboside chloride) on March 07, 2018; Dose: 300 mg/day; NDI 1062",
                     loc="hu:locator:truniagen-gras-line-2026-10-04", asserter="hu:org:niagen-bioscience-inc", status="ACCEPTED",
                     extra={"assertionBasis": "MANUFACTURER_CLAIM"})
    f.node("Adjudication", "hu:adjudication:truniagen-ndi-1062-characterization", {
        "assessmentType": "ADJUDICATION", "adjudicationKind": "SUPPORT", "verdict": "INSUFFICIENT", "status": "ACCEPTED",
        "methodVersion": "w13-regulatory-characterization-v1", "reviewerType": "AGENT", "humanReviewPending": True, "recordedAt": "dt:" + REC,
        "rationale": "The FDA letter dated March 7, 2018 is a filing acknowledgment (procedural; no finding of safety). 'No objection' is not established by the captured agency record; a later response letter was not captured, so the claim is not contradicted."},
        kind="ADJUDICATION")
    f.edge("EVALUATES", "hu:adjudication:truniagen-ndi-1062-characterization", ch)
    f.edge("SUPPORTED_BY", "hu:adjudication:truniagen-ndi-1062-characterization", l_ack)
    f.write()


# =====================================================================================================================
# File 4: inspection candidate
# =====================================================================================================================

def file_inspection():
    f = F("w13-inspection.cypher", """// W13 fixture 4 (candidate RegulatoryInspection; CQ-MF-C01, CQ-MF-06). Load AFTER w13-regulatory-kinds.cypher.
// Real: FDA warning letter CMS #723021 (Nutratech, LLC, Phoenix NY; inspection 2025-09-22..2025-10-15; Form FDA 483 issued
// 2025-10-15; letter 2026-06-04) and CMS #698661 (Anti L'Age, Riverside CA) whose text states both 'through October 4,
// 2024' and 'through October 7, 2024'. Classification (NAI/VAI/OAI) not captured (FDA Data Dashboard API needs
// credentials). Uid token regulatory-inspection pending W13-SR-04; candidate predicates INSPECTION_PERIOD,
// INSPECTION_FOUND_VIOLATION pending W13-SR-07. Expected: V-W13-11 zero rows; the CQ-MF-C01 query returns one resolved
// inspection and one CONFLICTING end date; the failing-case section (commented) shows the status collapse firing V-333.
""")
    f.label_of["hu:org:us-fda"] = "RegulatoryAgency"
    for key, uri, title, pub in [
        ("fda-wl-nutratech-723021", "https://www.fda.gov/inspections-compliance-enforcement-and-criminal-investigations/warning-letters/nutratech-llc-723021-06042026",
         "Warning letter Nutratech, LLC CMS #723021", "2026-06-04T00:00:00Z"),
        ("fda-wl-anti-lage-698661", "https://www.fda.gov/inspections-compliance-enforcement-and-criminal-investigations/warning-letters/anti-lage-698661-04172025",
         "Warning letter Anti L'Age CMS #698661", "2025-04-17T00:00:00Z")]:
        f.source(key, uri, "REGULATORY_RECORD", title, published=pub)
    sn = "hu:snapshot:fda-wl-nutratech-723021-2026-10-04"
    sa = "hu:snapshot:fda-wl-anti-lage-698661-2026-10-04"
    l1 = f.locator(sn, "wl-723021-inspection-period", exact="conducted an inspection of your facility located at 67 County Route 59, Phoenix, NY on September 22 through October 15, 2025.")
    l2 = f.locator(sn, "wl-723021-form-483", exact="At the conclusion of the inspection on October 15, 2025, our investigator provided you with a Form FDA 483, Inspectional Observations (FDA 483).")
    l3 = f.locator(sn, "wl-723021-cgmp-violation-4", exact="You failed to establish product specifications for the identity, purity, strength, and composition of the finished batch of the dietary supplement to ensure the quality of the dietary supplement, as required by 21 CFR 111.70(e).")
    la = f.locator(sa, "wl-698661-period-intro", exact="from September 17, 2024, through October 4, 2024")
    lb = f.locator(sa, "wl-698661-period-adulterated", exact="The inspection of your facility from September 17, 2024, through October 7, 2024, identified serious violations")
    lc = f.locator(sa, "wl-698661-form-483", exact="At the conclusion of the inspection on October 4, 2024, our investigator provided you with a Form FDA 483")
    f.node("Facility", "hu:facility:nutratech-phoenix-ny", {"name": "Nutratech, LLC facility, 67 County Route 59, Phoenix, NY"}, kind="FACILITY")
    f.node("Facility", "hu:facility:anti-lage-riverside-ca", {"name": "Anti L'Age facility, 6086 Brockton Ave, Riverside, CA"}, kind="FACILITY")
    f.node("RegulatoryInspection", "hu:regulatory-inspection:us-fda-nutratech-2025-09", {
        "jurisdiction": "US", "startedAt": day("2025-09-22"), "endedAt": day("2025-10-15"),
        "inspectionScopeText": "CGMP in Manufacturing, Packaging, Labeling, or Holding Operations for Dietary Supplements (21 CFR Part 111)",
        "form483Issued": True, "form483IssuedAt": day("2025-10-15"), "maturity": "CANDIDATE"}, kind="REGULATORY_INSPECTION")
    f.edge("CONDUCTED_BY", "hu:regulatory-inspection:us-fda-nutratech-2025-09", "hu:org:us-fda")
    f.asserted_edge("INSPECTED_FACILITY", "hu:regulatory-inspection:us-fda-nutratech-2025-09", "hu:facility:nutratech-phoenix-ny",
                    "inspected-nutratech-2025", "inspected-nutratech-2025", l1, "hu:org:us-fda", valid=DAYV("2025-09-22", "2025-10-16"))
    f.assertion("nutratech-inspection-period", "INSPECTION_PERIOD", "hu:regulatory-inspection:us-fda-nutratech-2025-09",
                value="September 22 through October 15, 2025", loc=l1, asserter="hu:org:us-fda", extra=DAYV("2025-09-22", "2025-10-16"))
    f.assertion("nutratech-violation-111-70e", "INSPECTION_FOUND_VIOLATION", "hu:regulatory-inspection:us-fda-nutratech-2025-09",
                value="21 CFR 111.70(e)", loc=[l3, l2], asserter="hu:org:us-fda")
    f.node("RegulatoryInspection", "hu:regulatory-inspection:us-fda-anti-lage-2024-09", {
        "jurisdiction": "US", "startedAt": day("2024-09-17"), "endedAt": None, "form483Issued": True,
        "form483IssuedAt": day("2024-10-04"), "maturity": "CANDIDATE",
        "inspectionScopeText": "CGMP for dietary supplements (21 CFR Part 111)"}, kind="REGULATORY_INSPECTION")
    f.edge("CONDUCTED_BY", "hu:regulatory-inspection:us-fda-anti-lage-2024-09", "hu:org:us-fda")
    f.asserted_edge("INSPECTED_FACILITY", "hu:regulatory-inspection:us-fda-anti-lage-2024-09", "hu:facility:anti-lage-riverside-ca",
                    "inspected-anti-lage-2024", "inspected-anti-lage-2024", la, "hu:org:us-fda", valid={"validFrom": day("2024-09-17"), "validFromPrecision": "DAY", "validFromBasis": "STATED_BY_SOURCE", "validToBasis": "UNKNOWN"})
    f.assertion("anti-lage-period-oct-4", "INSPECTION_PERIOD", "hu:regulatory-inspection:us-fda-anti-lage-2024-09",
                value="September 17, 2024, through October 4, 2024", loc=[la, lc], asserter="hu:org:us-fda", extra=DAYV("2024-09-17", "2024-10-05"))
    f.assertion("anti-lage-period-oct-7", "INSPECTION_PERIOD", "hu:regulatory-inspection:us-fda-anti-lage-2024-09",
                value="September 17, 2024, through October 7, 2024", loc=lb, asserter="hu:org:us-fda", extra=DAYV("2024-09-17", "2024-10-08"))
    f.c("FAILING CASE without the candidate (load only in a scratch database): the inspection collapsed into a status.\n"
        "Uncomment to see V-333 (statusKind outside the enum) and V-W13-01 (non-registration status on a Facility) fire.")
    f.lines.append("// MERGE (s:RegulatoryStatus:VersionedState {uid: 'hu:regulatory-status:neg-inspection-as-status'})\n"
                   "// SET s += {statusKind: 'INSPECTED_OAI', jurisdiction: 'US', stateType: 'REGULATORY_STATUS', payloadHash: 'sha256:00'};\n"
                   "// MATCH (s:RegulatoryStatus {uid: 'hu:regulatory-status:neg-inspection-as-status'}), (f:Facility {uid: 'hu:facility:nutratech-phoenix-ny'})\n"
                   "// MERGE (s)-[:STATUS_OF {relationshipUid: 'hu:rel:neg-inspection-as-status', assertionUid: 'hu:assertion:none', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN'}]->(f);\n")
    f.write()


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    file_positive()
    file_negative()
    file_pending()
    file_inspection()
    print("ok")
