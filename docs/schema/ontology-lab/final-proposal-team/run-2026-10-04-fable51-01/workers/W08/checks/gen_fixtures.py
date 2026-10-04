#!/usr/bin/env python3
"""W08 fixture generator. Writes ../fixtures/w08-*.cypher deterministically.

Every statement binds its own nodes by uid (no variable crosses ';'); every node carries its primary label and its
archetype label; quote hashes are NFC-WS1 sha256 over the exact quote; assertion contentHash is sha256 over
predicate|subject|object|value (illustrative; production uses the W00 assertion canonical form).
Snapshots of real pages use contentHashBasis STORED_EXCERPT_TEXT over the stored excerpt file in ../fixtures/excerpts/
(sha256 of the file bytes); synthetic sources use SYNTHETIC_FIXTURE.
"""
import hashlib, re, unicodedata, os

HERE = os.path.dirname(os.path.abspath(__file__))
FIX = os.path.join(HERE, "..", "fixtures")
EXC = os.path.join(FIX, "excerpts")


def nfcws1(s):
    return "sha256:" + hashlib.sha256(re.sub(r"\s+", " ", unicodedata.normalize("NFC", s)).strip().encode()).hexdigest()


def filehash(name):
    with open(os.path.join(EXC, name), "rb") as f:
        return "sha256:" + hashlib.sha256(f.read()).hexdigest()


def synth(uid):
    return "sha256:" + hashlib.sha256(uid.encode()).hexdigest()


def q(s):
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'") + "'"


def dt(s):
    return f"datetime('{s}')"


def props(d):
    out = []
    for k, v in d.items():
        if v is None:
            continue
        if isinstance(v, bool):
            out.append(f"{k}: {'true' if v else 'false'}")
        elif isinstance(v, (int, float)):
            out.append(f"{k}: {v}")
        elif isinstance(v, str) and v.startswith("datetime("):
            out.append(f"{k}: {v}")
        elif isinstance(v, list):
            out.append(f"{k}: [" + ", ".join(q(x) for x in v) + "]")
        else:
            out.append(f"{k}: {q(v)}")
    return ", ".join(out)


class Fx:
    def __init__(self, title, header):
        self.lines = [f"// {title}", *[f"// {h}" for h in header], ""]

    def c(self, text):
        self.lines.append(f"// {text}")

    def stmt(self, s):
        self.lines.append(s.rstrip().rstrip(";") + ";")
        self.lines.append("")

    def node(self, labels, uid, **p):
        p = {k: v for k, v in p.items()}
        p.setdefault("createdAt", "datetime()")
        p.setdefault("privacyClass", "PUBLIC")  # stored enum name (W23 D-W23-06); V-522
        sets = props({k: v for k, v in p.items() if k != "createdAt"})
        lab = ":".join(labels)
        idv = uid.split(":", 2)[2]
        self.stmt(f"MERGE (n:{lab} {{uid: {q(uid)}}})\nSET n += {{id: {q(idv)}{', ' + sets if sets else ''}}}, n.createdAt = coalesce(n.createdAt, datetime())")

    def rel(self, a_label, a_uid, rtype, b_label, b_uid, **p):
        sets = props(p)
        self.stmt(f"MATCH (a:{a_label} {{uid: {q(a_uid)}}}), (b:{b_label} {{uid: {q(b_uid)}}})\nMERGE (a)-[r:{rtype}]->(b)" + (f"\nSET r += {{{sets}}}" if sets else ""))

    def source(self, key, uri, title, kind, excerpt=None, retrieved="2026-10-04T00:00:00Z", observed=None, published=None, completeness="PARTIAL_EXCERPT"):
        self.node(["Source", "Entity"], f"hu:source:{key}", canonicalUri=uri, title=title, sourceKind=kind, entityType="SOURCE")
        if excerpt:
            h, basis = filehash(excerpt), "STORED_EXCERPT_TEXT"
        else:
            h, basis = synth(f"hu:snapshot:{key}"), "SYNTHETIC_FIXTURE"
        self.node(["SourceSnapshot", "InformationArtifact"], f"hu:snapshot:{key}-2026-10-04", canonicalUri=uri, artifactType="SOURCE_SNAPSHOT",
                  retrievedAt=dt(retrieved), observedAt=dt(observed or retrieved), publishedAt=dt(published) if published else None,
                  contentHash=h, contentHashBasis=basis, captureCompleteness=completeness, excerptFile=excerpt)
        self.rel("Source", f"hu:source:{key}", "HAS_SNAPSHOT", "SourceSnapshot", f"hu:snapshot:{key}-2026-10-04")

    def locator(self, key, lkey, kind, exact=None, page=None, section=None):
        uid = f"hu:locator:{lkey}"
        p = dict(selectorKind=kind, artifactType="SOURCE_LOCATOR")
        if exact:
            p.update(exact=exact, quoteHash=nfcws1(exact), normalizationVersion="NFC-WS1")
        if page is not None:
            p["page"] = page
        if section:
            p["section"] = section
        self.node(["SourceLocator", "InformationArtifact"], uid, **p)
        self.rel("SourceSnapshot", f"hu:snapshot:{key}-2026-10-04", "HAS_LOCATOR", "SourceLocator", uid)

    def assertion(self, akey, predicate, subj, obj=None, locator=None, asserter=None, edge=None, edge_props=None, **p):
        """subj/obj = (label, uid). edge: create the projected asserted edge subj-[predicate]->obj with edge_props type."""
        uid = f"hu:assertion:{akey}"
        p.setdefault("status", "EXTRACTED")
        p.setdefault("recordedAt", dt("2026-10-04T02:00:00Z"))
        value = p.get("valueString") or p.get("valueNumber") or ""  # one literal at most (V-003); qualifier text goes to description
        p["contentHash"] = "sha256:" + hashlib.sha256(f"{predicate}|{subj[1]}|{obj[1] if obj else ''}|{value}".encode()).hexdigest()
        self.node(["Assertion"], uid, predicate=predicate, **p)
        self.rel("Assertion", uid, "HAS_SUBJECT", subj[0], subj[1])
        if obj:
            self.rel("Assertion", uid, "HAS_OBJECT", obj[0], obj[1])
        if locator:
            self.rel("Assertion", uid, "SUPPORTED_BY", "SourceLocator", f"hu:locator:{locator}")
        if asserter:
            self.rel("Assertion", uid, "ASSERTED_BY", asserter[0], asserter[1])
        if edge:
            ep = dict(relationshipUid=f"hu:rel:{akey}", assertionUid=uid,
                      validFrom=p.get("validFrom"), validTo=p.get("validTo"),
                      validFromPrecision=p.get("validFromPrecision"), validToPrecision=p.get("validToPrecision"),
                      validFromBasis=p.get("validFromBasis", "UNKNOWN"), validToBasis=p.get("validToBasis", "UNKNOWN"),
                      recordedFrom=p["recordedAt"])
            ep.update(edge_props or {})
            self.rel(subj[0], subj[1], predicate, obj[0], obj[1], **ep)
        return uid

    def write(self, name):
        with open(os.path.join(FIX, name), "w") as f:
            f.write("\n".join(self.lines).rstrip() + "\n")


ORG = lambda u: ("Organization", u)
WHOOP = ORG("hu:org:whoop-inc")
ILLUMINA = ORG("hu:org:illumina-inc")
FDA = ("RegulatoryAgency", "hu:org:us-fda")
BELLLABS = ("Agent", "hu:agent:belllabs-w08-curation")


def common_actors(f):
    f.node(["Organization", "Entity"], WHOOP[1], name="WHOOP, Inc.", entityType="ORGANIZATION")
    f.node(["Organization", "Entity"], ILLUMINA[1], name="Illumina, Inc.", entityType="ORGANIZATION")
    f.node(["RegulatoryAgency", "Organization", "Entity"], FDA[1], name="U.S. Food and Drug Administration", agencyCode="FDA", jurisdiction="US", entityType="ORGANIZATION")
    f.node(["Agent", "Entity"], BELLLABS[1], name="BellLabs W08 curation (fixture)", agentKind="MANUAL_AGENT", entityType="AGENT")


# ---------------------------------------------------------------------------------------------------------------
# Fixture 1: platform class versus instrument model (minimal pair), same kit on two instruments
# ---------------------------------------------------------------------------------------------------------------
f = Fx("W08 fixture 1: technology platform versus instrument model (Illumina Infinium / iScan / NextSeq 550)", [
    "Run run-2026-10-04-fable51-01, worker W08. Neo4j 5.x Cypher. Every statement binds its own nodes by uid.",
    "Public source: Illumina Infinium MethylationEPIC v2.0 product page (retrieved 2026-10-04; excerpt in excerpts/).",
    "Synthetic: 'synthetic-lab-c' and its two assay versions (no lab publishes this pair); the kit number and the",
    "instrument list are from the Illumina page. Minimal pair: one TechnologyPlatform, two ToolOrInstrument models;",
    "same kit 20087706 + same method principle on two instruments = two AssayVersions, never one series without a",
    "ComparabilityAssessment (forbidden implication [SAME_TECHNOLOGY_PLATFORM, COMPARABLE_ASSAY_VERSION]).",
])
common_actors(f)
f.node(["Organization", "Entity"], "hu:org:synthetic-lab-c", name="Synthetic Lab C (methylation service)", entityType="ORGANIZATION")
f.source("illumina-epic-v2-product-page", "https://www.illumina.com/products/by-type/microarray-kits/infinium-methylation-epic.html",
         "Infinium MethylationEPIC v2.0 Kit | Methylation profiling array", "MANUFACTURER_LABEL_PAGE", excerpt="illumina-epic-v2-product-page-2026-10-04.txt")
f.locator("illumina-epic-v2-product-page", "illumina-epic-v2-processed-on-iscan-or-nextseq550", "TEXT_QUOTE", exact="The kit is processed on the iScan or NextSeq 550 Systems")
f.locator("illumina-epic-v2-product-page", "illumina-epic-v2-spec-table", "SECTION", section="Specifications: Assay type Infinium HD Methylation; Instruments NextSeq 550 System, NextSeq 550Dx in Research Mode, iScan System; Method Methylation array; Technology Microarray")
f.source("synthetic-lab-c-methods-page", "urn:synthetic:lab-c-methods", "Synthetic Lab C methylation methods page", "ORGANIZATION_WEBPAGE")
f.locator("synthetic-lab-c-methods-page", "synthetic-lab-c-methods-two-instruments", "SECTION", section="Arrays are scanned on an iScan System; overflow batches run on a NextSeq 550 System")

f.node(["TechnologyPlatform", "Entity"], "hu:technology-platform:illumina-infinium-beadchip", name="Illumina Infinium BeadChip array", platformClass="MICROARRAY", entityType="TECHNOLOGY_PLATFORM", privacyClass="PUBLIC", maturity="PROVISIONAL")
f.node(["ToolOrInstrument", "Entity"], "hu:instrument:illumina-iscan-system", name="Illumina iScan System", toolClass="array scanner", entityType="TOOL_OR_INSTRUMENT", privacyClass="PUBLIC")
f.node(["ToolOrInstrument", "Entity"], "hu:instrument:illumina-nextseq-550-system", name="Illumina NextSeq 550 System", toolClass="sequencer (array scanning capable)", entityType="TOOL_OR_INSTRUMENT", privacyClass="PUBLIC")
f.node(["MeasurementMethod", "Entity"], "hu:method:methylation-array", name="Methylation array (bisulfite conversion + array hybridization)", methodPrinciple="METHYLATION_ARRAY", entityType="MEASUREMENT_METHOD")
f.node(["Product", "Entity"], "hu:product:illumina-iscan-system", name="iScan System (Illumina product)", entityType="PRODUCT")

f.c("Platform-level assertions (Illumina statements on its own product page).")
f.assertion("illumina-develops-infinium", "DEVELOPS_PLATFORM", ILLUMINA, ("TechnologyPlatform", "hu:technology-platform:illumina-infinium-beadchip"),
            locator="illumina-epic-v2-spec-table", asserter=ILLUMINA, edge=True, assertionBasis="MANUFACTURER_CLAIM", speechAct="STATES", predicateClass="OTHER")
f.assertion("iscan-implements-infinium", "IMPLEMENTS_PLATFORM", ("ToolOrInstrument", "hu:instrument:illumina-iscan-system"), ("TechnologyPlatform", "hu:technology-platform:illumina-infinium-beadchip"),
            locator="illumina-epic-v2-processed-on-iscan-or-nextseq550", asserter=ILLUMINA, edge=True, edge_props=dict(usageContext="BeadChip scanning", isPrimary=True),
            assertionBasis="MANUFACTURER_CLAIM", speechAct="STATES", predicateClass="OTHER")
f.assertion("nextseq550-implements-infinium", "IMPLEMENTS_PLATFORM", ("ToolOrInstrument", "hu:instrument:illumina-nextseq-550-system"), ("TechnologyPlatform", "hu:technology-platform:illumina-infinium-beadchip"),
            locator="illumina-epic-v2-processed-on-iscan-or-nextseq550", asserter=ILLUMINA, edge=True, edge_props=dict(usageContext="BeadChip processing on a sequencer"),
            assertionBasis="MANUFACTURER_CLAIM", speechAct="STATES", predicateClass="OTHER")
f.assertion("iscan-product-embodies-iscan-model", "EMBODIES_MODEL", ("Product", "hu:product:illumina-iscan-system"), ("ToolOrInstrument", "hu:instrument:illumina-iscan-system"),
            locator="illumina-epic-v2-spec-table", asserter=ILLUMINA, edge=True, assertionBasis="MANUFACTURER_CLAIM", speechAct="STATES", predicateClass="OTHER")
f.c("RUNS_ON_PLATFORM is structural (reference-concept link; accepted from W07): no assertion.")
f.rel("MeasurementMethod", "hu:method:methylation-array", "RUNS_ON_PLATFORM", "TechnologyPlatform", "hu:technology-platform:illumina-infinium-beadchip", notes="Illumina page: Method 'Methylation array' on Infinium BeadChips")
f.c("The lab uses both instruments (synthetic organization page).")
for k, inst in (("iscan", "hu:instrument:illumina-iscan-system"), ("nextseq550", "hu:instrument:illumina-nextseq-550-system")):
    f.assertion(f"synthetic-lab-c-uses-{k}", "USES_EQUIPMENT", ("Organization", "hu:org:synthetic-lab-c"), ("ToolOrInstrument", inst),
                locator="synthetic-lab-c-methods-two-instruments", asserter=("Organization", "hu:org:synthetic-lab-c"), edge=True,
                edge_props=dict(usageContext="methylation array scanning", isPrimary=(k == "iscan")), assertionBasis="UNSTATED", speechAct="STATES", predicateClass="OTHER")

f.c("Two assay versions: same lab, same kit, same method, different instrument model (W07 AssayVersion shape).")
for k, inst in (("iscan", "hu:instrument:illumina-iscan-system"), ("nextseq550", "hu:instrument:illumina-nextseq-550-system")):
    uid = f"hu:assay-version:synthetic-lab-c-epic-v2-{k}"
    f.node(["AssayVersion", "VersionedState"], uid, name=f"Synthetic Lab C EPIC v2.0 on {k}", stateType="ASSAY_VERSION",
           payloadHash=synth(uid), assayKitIdentifier="20087706", softwareVersionStatus="NOT_REPORTED")
    f.rel("AssayVersion", uid, "ASSAY_OPERATED_BY", "Organization", "hu:org:synthetic-lab-c")
    f.rel("AssayVersion", uid, "USES_METHOD", "MeasurementMethod", "hu:method:methylation-array")
    f.rel("AssayVersion", uid, "RUNS_ON_INSTRUMENT", "ToolOrInstrument", inst)
f.write("w08-platform-vs-instrument.cypher")

# ---------------------------------------------------------------------------------------------------------------
# Fixture 2: device identity vs assay configuration vs firmware version (WHOOP 4.0)
# ---------------------------------------------------------------------------------------------------------------
f = Fx("W08 fixture 2: device identity vs firmware version vs assay configuration (WHOOP 4.0)", [
    "Run run-2026-10-04-fable51-01, worker W08. Neo4j 5.x Cypher. Every statement binds its own nodes by uid.",
    "Public sources: WHOOP 4.0 Firmware Release Notes (support.whoop.com, last published 2025-05-23, retrieved 2026-10-04)",
    "and the WHOOP Locker heart-rate page (dated 2026-07-21, retrieved 2026-10-04). Excerpts in excerpts/.",
    "Same Device (WHOOP 4.0), two core FirmwareVersions (41.15.3.0, 41.16.1.0) plus one Bluetooth firmware version,",
    "two heart-rate AssayVersions that differ ONLY in softwareVersion (= firmware label). Release-note statements are",
    "Assertions whose subject is the FirmwareVersion (failing case F-1 for softwareVersion-only). No release date is",
    "stated by the page, so every validFrom is null with basis UNKNOWN (missing fact kept missing). Includes an",
    "extraction correction (SUPERSEDES {EXTRACTION_FIX}) and an unversioned July 2026 accuracy claim (marketing).",
])
common_actors(f)
f.source("whoop-4-0-firmware-release-notes", "https://support.whoop.com/s/article/WHOOP-4-0-Firmware-Release-Notes", "WHOOP 4.0 Firmware Release Notes",
         "ORGANIZATION_WEBPAGE", excerpt="whoop-4-0-firmware-release-notes-2026-10-04.txt", published="2025-05-23T20:15:00Z")
f.locator("whoop-4-0-firmware-release-notes", "whoop-4-0-fw-41-16-1-0-row", "TEXT_QUOTE", exact="Firmware version 41.16.1.0 - Improved heart rate estimation algorithm")
f.locator("whoop-4-0-firmware-release-notes", "whoop-4-0-fw-41-15-3-0-row", "TEXT_QUOTE", exact="Firmware version 41.15.3.0 - Improved strap stability and issue reporting - Bug fixes")
f.locator("whoop-4-0-firmware-release-notes", "whoop-4-0-fw-41-11-7-0-row", "TEXT_QUOTE", exact="Firmware version 41.11.7.0 - Improved HR estimation during sleep - Bug fixes and improvements")
f.locator("whoop-4-0-firmware-release-notes", "whoop-4-0-fw-components", "TEXT_QUOTE", exact="Release notes for the device's core firmware and Bluetooth firmware are listed below.")
f.locator("whoop-4-0-firmware-release-notes", "whoop-4-0-fw-phased-rollout", "TEXT_QUOTE", exact="It may take 1-2 weeks before all of our members receive the update.")
f.source("whoop-locker-heart-rate", "https://www.whoop.com/us/en/thelocker/a-look-behind-the-data-how-whoop-measures-heart-rate/",
         "A Look Behind The Data: How WHOOP Measures Heart Rate", "MARKETING_PAGE", excerpt="whoop-locker-heart-rate-2026-10-04.txt",
         retrieved="2026-10-04T00:00:00Z", observed="2026-10-03T17:50:48Z", published="2026-07-21T00:00:00Z")
f.locator("whoop-locker-heart-rate", "whoop-locker-hr-july-2026-claim", "TEXT_QUOTE", exact="WHOOP just delivered another across-the-board improvement to heart rate accuracy.")
f.locator("whoop-locker-heart-rate", "whoop-locker-updates-through-firmware", "TEXT_QUOTE", exact="Updates are delivered through firmware, meaning you benefit automatically without purchasing new hardware.")

f.node(["Device", "Entity"], "hu:device:whoop-4-0", name="WHOOP 4.0", deviceClass="wrist-worn wearable", deviceFamily="WHOOP", entityType="DEVICE", privacyClass="PUBLIC", maturity="PROVISIONAL")
f.node(["Metric", "Entity"], "hu:metric:heart-rate-bpm", name="Heart rate", canonicalUnitCode="/min", entityType="METRIC")
f.node(["MeasurementMethod", "Entity"], "hu:method:ppg-heart-rate-estimation", name="Photoplethysmography heart-rate estimation", methodPrinciple="PPG", entityType="MEASUREMENT_METHOD")
f.node(["Modality", "Entity"], "hu:modality:photoplethysmography", name="Photoplethysmography (PPG)", modalityClass="optical", modalityFamily="sensing", entityType="MODALITY")
fw = {}
for comp, ver in (("core", "41.15.3.0"), ("core", "41.16.1.0"), ("core", "41.11.7.0"), ("bluetooth", "17.2.2.0")):
    uid = f"hu:firmware-version:whoop-4-0-{comp}-{ver.replace('.', '-')}"
    fw[ver] = uid
    label = "core firmware" if comp == "core" else "Bluetooth firmware"
    f.node(["FirmwareVersion", "VersionedState"], uid, name=f"WHOOP 4.0 {label} {ver}", stateType="FIRMWARE_VERSION",
           payloadHash=nfcws1("\u001f".join(["hu:device:whoop-4-0", label, ver])), versionLabel=ver, versionBasis="VENDOR_VERSION_STRING",
           componentLabel=label, maturity="CANDIDATE")
    f.rel("FirmwareVersion", uid, "FIRMWARE_VERSION_OF", "Device", "hu:device:whoop-4-0")

f.c("Release-note assertions: subject is the firmware release, asserter is WHOOP (manufacturer claim).")
f.assertion("whoop-4-0-fw-41-16-1-0-release-note", "RELEASE_NOTE_STATES", ("FirmwareVersion", fw["41.16.1.0"]), None,
            locator="whoop-4-0-fw-41-16-1-0-row", asserter=WHOOP, valueString="Improved heart rate estimation algorithm",
            assertionBasis="MANUFACTURER_CLAIM", speechAct="STATES", predicateClass="CLAIM", polarity="POSITIVE")
f.assertion("whoop-4-0-fw-41-15-3-0-release-note", "RELEASE_NOTE_STATES", ("FirmwareVersion", fw["41.15.3.0"]), None,
            locator="whoop-4-0-fw-41-15-3-0-row", asserter=WHOOP, valueString="Improved strap stability and issue reporting; Bug fixes",
            assertionBasis="MANUFACTURER_CLAIM", speechAct="STATES", predicateClass="CLAIM", polarity="POSITIVE")

f.c("Temporal correction: an extraction mistakenly attached the 'HR estimation during sleep' note to 41.16.1.0;")
f.c("the corrected assertion attaches it to 41.11.7.0. Valid time unchanged; old assertion closed by recordedTo.")
f.assertion("whoop-4-0-fw-sleep-hr-note-misattributed", "RELEASE_NOTE_STATES", ("FirmwareVersion", fw["41.16.1.0"]), None,
            locator="whoop-4-0-fw-41-11-7-0-row", asserter=WHOOP, valueString="Improved HR estimation during sleep",
            assertionBasis="MANUFACTURER_CLAIM", speechAct="STATES", predicateClass="CLAIM", status="SUPERSEDED",
            recordedAt=dt("2026-10-04T02:00:00Z"), recordedTo=dt("2026-10-04T03:00:00Z"))
f.assertion("whoop-4-0-fw-sleep-hr-note", "RELEASE_NOTE_STATES", ("FirmwareVersion", fw["41.11.7.0"]), None,
            locator="whoop-4-0-fw-41-11-7-0-row", asserter=WHOOP, valueString="Improved HR estimation during sleep",
            assertionBasis="MANUFACTURER_CLAIM", speechAct="STATES", predicateClass="CLAIM", recordedAt=dt("2026-10-04T03:00:00Z"))
f.stmt("MATCH (new:Assertion {uid: 'hu:assertion:whoop-4-0-fw-sleep-hr-note'}), (old:Assertion {uid: 'hu:assertion:whoop-4-0-fw-sleep-hr-note-misattributed'})\n"
       "MERGE (new)-[s:SUPERSEDES]->(old)\nSET s.supersessionKind = 'EXTRACTION_FIX', s.recordedAt = datetime('2026-10-04T03:00:00Z')")

f.c("Two heart-rate AssayVersions: identical operator, method, device and metric; only softwareVersion differs.")
for ver in ("41.15.3.0", "41.16.1.0"):
    uid = f"hu:assay-version:whoop-4-0-heart-rate-fw-{ver.replace('.', '-')}"
    f.node(["AssayVersion", "VersionedState"], uid, name=f"WHOOP 4.0 heart rate, firmware {ver}", stateType="ASSAY_VERSION",
           payloadHash=synth(uid), softwareVersion=ver, softwareVersionStatus="REPORTED", reportedUnitCode="/min")
    f.rel("AssayVersion", uid, "ASSAY_OPERATED_BY", "Organization", WHOOP[1])
    f.rel("AssayVersion", uid, "USES_METHOD", "MeasurementMethod", "hu:method:ppg-heart-rate-estimation")
    f.rel("AssayVersion", uid, "RUNS_ON_INSTRUMENT", "Device", "hu:device:whoop-4-0")
    f.rel("AssayVersion", uid, "RUNS_FIRMWARE_VERSION", "FirmwareVersion", fw[ver])
    f.rel("AssayVersion", uid, "ASSAY_FOR_METRIC", "Metric", "hu:metric:heart-rate-bpm")
    f.c(f"Which assay version the device's HR feature ran with: BellLabs curation from the release note; dates not stated.")
    f.assertion(f"whoop-4-0-hr-performed-with-fw-{ver.replace('.', '-')}", "PERFORMED_WITH_ASSAY_VERSION", ("Device", "hu:device:whoop-4-0"), ("AssayVersion", uid),
                locator="whoop-4-0-fw-41-16-1-0-row" if ver == "41.16.1.0" else "whoop-4-0-fw-41-15-3-0-row", asserter=BELLLABS, edge=True,
                assertionBasis="MANUFACTURER_CLAIM", speechAct="STATES", predicateClass="OTHER", validFromBasis="UNKNOWN", validToBasis="UNKNOWN")

f.c("Vendor states the device reports heart rate (asserted MEASURES_METRIC; never implies MEASURED resultKind).")
f.assertion("whoop-4-0-measures-heart-rate", "MEASURES_METRIC", ("Device", "hu:device:whoop-4-0"), ("Metric", "hu:metric:heart-rate-bpm"),
            locator="whoop-locker-updates-through-firmware", asserter=WHOOP, edge=True, assertionBasis="MANUFACTURER_CLAIM", speechAct="STATES", predicateClass="OTHER")
f.assertion("whoop-4-0-uses-ppg", "USES_MODALITY", ("Device", "hu:device:whoop-4-0"), ("Modality", "hu:modality:photoplethysmography"),
            locator="whoop-locker-updates-through-firmware", asserter=WHOOP, edge=True, edge_props=dict(usageContext="optical heart-rate sensing", isPrimary=True),
            assertionBasis="MANUFACTURER_CLAIM", speechAct="STATES", predicateClass="OTHER",
            description="page names 'WHOOP' generically; device-model resolution to WHOOP 4.0 is a curation choice (ResolutionHypothesis pending)")

f.c("July 2026 accuracy claim: no firmware version, no device model, no number. Kept as a marketing assertion whose")
f.c("subject is an unresolved assay version; nothing is written onto Device or FirmwareVersion.")
f.node(["AssayVersion", "VersionedState"], "hu:assay-version:whoop-heart-rate-2026-07-update-unresolved", name="WHOOP heart rate after the July 2026 update (device and firmware unresolved)",
       stateType="ASSAY_VERSION", payloadHash=synth("hu:assay-version:whoop-heart-rate-2026-07-update-unresolved"), softwareVersionStatus="NOT_REPORTED")
f.rel("AssayVersion", "hu:assay-version:whoop-heart-rate-2026-07-update-unresolved", "ASSAY_OPERATED_BY", "Organization", WHOOP[1])
f.rel("AssayVersion", "hu:assay-version:whoop-heart-rate-2026-07-update-unresolved", "ASSAY_FOR_METRIC", "Metric", "hu:metric:heart-rate-bpm")
f.assertion("whoop-locker-july-2026-hr-accuracy-claim", "CLAIMS_ACCURACY_IMPROVEMENT", ("AssayVersion", "hu:assay-version:whoop-heart-rate-2026-07-update-unresolved"), None,
            locator="whoop-locker-hr-july-2026-claim", asserter=WHOOP, valueString="across-the-board improvement to heart rate accuracy (no figure, no firmware version stated)",
            assertionBasis="MANUFACTURER_CLAIM", speechAct="STATES", predicateClass="CLAIM", polarity="POSITIVE",
            validFrom=dt("2026-07-01T00:00:00Z"), validFromPrecision="MONTH", validFromBasis="STATED_BY_SOURCE", validToBasis="UNKNOWN")
f.write("w08-device-firmware-assay.cypher")

# ---------------------------------------------------------------------------------------------------------------
# Fixture 3: 510(k) clearance (not approval) of a software product that runs on a device; performance claims
# ---------------------------------------------------------------------------------------------------------------
f = Fx("W08 fixture 3: 510(k) clearance of a software product vs the device model; performance claim as manufacturer assertion", [
    "Run run-2026-10-04-fable51-01, worker W08. Neo4j 5.x Cypher. Every statement binds its own nodes by uid.",
    "Public sources: FDA 510(k) database record K243236 and the K243236 PDF (FDA letter + applicant-prepared 510(k)",
    "Summary), FDA closeout letter 709755 (2026-06-17). Excerpts in excerpts/. Regulatory node shapes follow W13",
    "(RegulatorySubmission/Response/Status, STATUS_OF asserted). W08 contribution: the clearance attaches to the Product",
    "'WHOOP ECG (electrocardiogram) Feature', which RUNS_ON_DEVICE the Device 'WHOOP MG'; the Device carries no status",
    "and no performance property. Late arrival: valid from 2025-04-04 (decision date), recorded 2026-10-04.",
])
common_actors(f)
f.source("fda-510k-k243236-record", "https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfpmn/pmn.cfm?ID=K243236", "510(k) Premarket Notification K243236",
         "REGULATORY_RECORD", excerpt="fda-510k-K243236-record-2026-10-04.txt", observed="2026-09-28T00:00:00Z", completeness="COMPLETE")
f.locator("fda-510k-k243236-record", "fda-k243236-record-whole", "WHOLE_SNAPSHOT")
f.source("fda-k243236-pdf", "https://www.accessdata.fda.gov/cdrh_docs/pdf24/K243236.pdf", "K243236 SE letter, Indications for Use, 510(k) Summary",
         "REGULATORY_RECORD", excerpt="fda-K243236-pdf-2026-10-04.txt", published="2025-04-04T00:00:00Z")
f.locator("fda-k243236-pdf", "fda-k243236-summary-performance", "PDF_PAGE", page=9,
          exact="The ECG feature demonstrated 96.2% sensitivity in classifying AFib (HR 50-150 bpm) and 99.4% specificity in classifying sinus rhythm (HR 50-150 bpm) in classifiable recordings.")
f.locator("fda-k243236-pdf", "fda-k243236-summary-inconclusive", "PDF_PAGE", page=9, exact="During this study, the WHOOP ECG Feature determined 11% of recordings were inconclusive.")
f.locator("fda-k243236-pdf", "fda-k243236-summary-compatibility", "PDF_PAGE", page=8, exact="WHOOP Strap version - WHOOP MG")
f.locator("fda-k243236-pdf", "fda-k243236-summary-non-device-system", "PDF_PAGE", page=5,
          exact="The WHOOP ECG Feature is a software-only medical mobile application integrated into the consumer (non-device) WHOOP System.")
f.source("fda-closeout-whoop-709755", "https://www.fda.gov/inspections-compliance-enforcement-and-criminal-investigations/warning-letters/whoop-inc-709755-06172026",
         "WHOOP, Inc. - 709755 - 06/17/2026 (closeout letter)", "REGULATORY_RECORD", excerpt="fda-whoop-closeout-709755-2026-10-04.txt",
         observed="2026-10-02T01:22:10Z", published="2026-06-23T07:26:00Z")
f.locator("fda-closeout-whoop-709755", "fda-closeout-709755-bpi-as-modified", "TEXT_QUOTE",
          exact="FDA does not intend to enforce the device statutory and regulatory requirements for your BPI product as modified.")

f.node(["Device", "Entity"], "hu:device:whoop-mg", name="WHOOP MG", deviceClass="wrist-worn wearable", deviceFamily="WHOOP", entityType="DEVICE", privacyClass="PUBLIC", maturity="PROVISIONAL")
f.node(["Sensor", "Entity"], "hu:sensor:whoop-mg-ecg-electrodes", name="WHOOP MG ECG electrodes (wrist and clasp)", sensorType="ECG electrode", entityType="SENSOR")
f.node(["Modality", "Entity"], "hu:modality:single-lead-ecg", name="Single-lead ECG (Lead I-like)", modalityClass="electrical", modalityFamily="sensing", entityType="MODALITY")
f.node(["Product", "Entity"], "hu:product:whoop-ecg-feature", name="WHOOP ECG (electrocardiogram) Feature", entityType="PRODUCT")
f.node(["Product", "Entity"], "hu:product:whoop-blood-pressure-insights", name="WHOOP Blood Pressure Insights (BPI)", entityType="PRODUCT")

f.c("Device-side assertions (applicant-prepared 510(k) Summary; asserter WHOOP, Inc., not FDA).")
f.assertion("whoop-ecg-feature-runs-on-whoop-mg", "RUNS_ON_DEVICE", ("Product", "hu:product:whoop-ecg-feature"), ("Device", "hu:device:whoop-mg"),
            locator="fda-k243236-summary-compatibility", asserter=WHOOP, edge=True, assertionBasis="MANUFACTURER_CLAIM", speechAct="STATES", predicateClass="OTHER")
f.assertion("whoop-mg-has-ecg-electrodes", "HAS_SENSOR", ("Device", "hu:device:whoop-mg"), ("Sensor", "hu:sensor:whoop-mg-ecg-electrodes"),
            locator="fda-k243236-summary-non-device-system", asserter=WHOOP, edge=True, assertionBasis="MANUFACTURER_CLAIM", speechAct="STATES", predicateClass="OTHER")
f.assertion("whoop-mg-uses-single-lead-ecg", "USES_MODALITY", ("Device", "hu:device:whoop-mg"), ("Modality", "hu:modality:single-lead-ecg"),
            locator="fda-k243236-summary-non-device-system", asserter=WHOOP, edge=True, edge_props=dict(usageContext="30-second on-demand ECG spot check"),
            assertionBasis="MANUFACTURER_CLAIM", speechAct="STATES", predicateClass="OTHER")

f.c("Regulatory chain (W13 shapes): submission -> response SUBSTANTIALLY_EQUIVALENT -> status CLEARANCE STATUS_OF the Product.")
f.node(["RegulatoryPathway", "Entity"], "hu:reg-pathway:us-fda-510k", name="FDA premarket notification 510(k)", pathwayKind="PREMARKET_NOTIFICATION_510K", jurisdiction="US", entityType="REGULATORY_PATHWAY")
f.node(["RegulatorySubmission", "InformationArtifact"], "hu:reg-submission:us-fda-k243236", submissionKind="PREMARKET_NOTIFICATION_510K", identifier="K243236",
       jurisdiction="US", submittedAt=dt("2024-10-10T00:00:00Z"), artifactType="REGULATORY_SUBMISSION")
f.node(["RegulatoryResponse", "InformationArtifact"], "hu:reg-response:us-fda-k243236", responseKind="SUBSTANTIALLY_EQUIVALENT", jurisdiction="US",
       issuedAt=dt("2025-04-04T00:00:00Z"), conditionsOfUseText="OTC; adults 22 years and older; AFib, normal sinus rhythm, low and high heart rate on a classifiable waveform; not recommended for users with other known arrhythmias",
       agencyDisclaimerText="FDA's issuance of a substantial equivalence determination does not mean that FDA has made a determination that your device complies with other requirements of the Act",
       artifactType="REGULATORY_RESPONSE")
f.node(["RegulatoryStatus", "VersionedState"], "hu:reg-status:us-whoop-ecg-feature-k243236-clearance", statusKind="CLEARANCE", jurisdiction="US", productCode="QDA",
       pcccAuthorized=False, legalBasisCitation="21 CFR 870.2345", scopeText="WHOOP ECG (electrocardiogram) Feature (1.0); compatible WHOOP Strap version WHOOP MG; OTC",
       effectiveFrom=dt("2025-04-04T00:00:00Z"), stateType="REGULATORY_STATUS", payloadHash=synth("hu:reg-status:us-whoop-ecg-feature-k243236-clearance"))
f.rel("RegulatorySubmission", "hu:reg-submission:us-fda-k243236", "UNDER_PATHWAY", "RegulatoryPathway", "hu:reg-pathway:us-fda-510k")
f.rel("RegulatorySubmission", "hu:reg-submission:us-fda-k243236", "SUBMISSION_HAS_RESPONSE", "RegulatoryResponse", "hu:reg-response:us-fda-k243236")
f.rel("RegulatoryResponse", "hu:reg-response:us-fda-k243236", "ISSUED_BY", "RegulatoryAgency", FDA[1])
f.rel("RegulatoryStatus", "hu:reg-status:us-whoop-ecg-feature-k243236-clearance", "RESULTS_FROM_RESPONSE", "RegulatoryResponse", "hu:reg-response:us-fda-k243236")
f.rel("RegulatoryStatus", "hu:reg-status:us-whoop-ecg-feature-k243236-clearance", "UNDER_LEGAL_BASIS", "RegulatoryPathway", "hu:reg-pathway:us-fda-510k")
f.rel("RegulatoryStatus", "hu:reg-status:us-whoop-ecg-feature-k243236-clearance", "ISSUED_BY", "RegulatoryAgency", FDA[1])
f.assertion("k243236-clearance-status-of-whoop-ecg-feature", "STATUS_OF", ("RegulatoryStatus", "hu:reg-status:us-whoop-ecg-feature-k243236-clearance"), ("Product", "hu:product:whoop-ecg-feature"),
            locator="fda-k243236-record-whole", asserter=FDA, edge=True, assertionBasis="UNSTATED", speechAct="STATES", predicateClass="REGULATORY",
            validFrom=dt("2025-04-04T00:00:00Z"), validFromPrecision="DAY", validFromBasis="STATED_BY_SOURCE", validToBasis="UNKNOWN", jurisdiction="US")

f.c("Performance claims: applicant statements in the 510(k) Summary about the software product (not Device properties).")
for key, pred, val, vs in (("afib-sensitivity", "REPORTS_SENSITIVITY", 96.2, "AFib classification, HR 50-150 bpm, classifiable recordings only; reference: cardiologist-read 12-lead ECG; approx. 540 subjects (NCT06622265)"),
                           ("sinus-specificity", "REPORTS_SPECIFICITY", 99.4, "sinus rhythm classification, HR 50-150 bpm, classifiable recordings only"),):
    f.assertion(f"k243236-summary-{key}", pred, ("Product", "hu:product:whoop-ecg-feature"), None, locator="fda-k243236-summary-performance", asserter=WHOOP,
                valueNumber=val, unitCode="%", description=vs, assertionBasis="STUDY_RESULT", speechAct="STATES", predicateClass="QUANTITY", polarity="POSITIVE")
f.assertion("k243236-summary-inconclusive-rate", "REPORTS_INCONCLUSIVE_RATE", ("Product", "hu:product:whoop-ecg-feature"), None, locator="fda-k243236-summary-inconclusive", asserter=WHOOP,
            valueNumber=11, unitCode="%", description="share of recordings classified inconclusive in the clinical study; excluded from the sensitivity/specificity denominators",
            assertionBasis="STUDY_RESULT", speechAct="STATES", predicateClass="QUANTITY", polarity="NEGATIVE")

f.c("Enforcement discretion for a modified wellness feature: not an authorization, not a clearance (W13 statusKind).")
f.node(["RegulatoryStatus", "VersionedState"], "hu:reg-status:us-whoop-bpi-as-modified-enforcement-discretion", statusKind="ENFORCEMENT_DISCRETION", jurisdiction="US",
       scopeText="BPI product as modified; letter is specific to that modification and not to any other product, feature or other modifications",
       effectiveFrom=dt("2026-06-17T00:00:00Z"), stateType="REGULATORY_STATUS", payloadHash=synth("hu:reg-status:us-whoop-bpi-as-modified-enforcement-discretion"))
f.rel("RegulatoryStatus", "hu:reg-status:us-whoop-bpi-as-modified-enforcement-discretion", "ISSUED_BY", "RegulatoryAgency", FDA[1])
f.assertion("fda-closeout-709755-bpi-enforcement-discretion", "STATUS_OF", ("RegulatoryStatus", "hu:reg-status:us-whoop-bpi-as-modified-enforcement-discretion"), ("Product", "hu:product:whoop-blood-pressure-insights"),
            locator="fda-closeout-709755-bpi-as-modified", asserter=FDA, edge=True, assertionBasis="UNSTATED", speechAct="STATES", predicateClass="REGULATORY",
            validFrom=dt("2026-06-17T00:00:00Z"), validFromPrecision="DAY", validFromBasis="STATED_BY_SOURCE", validToBasis="UNKNOWN", jurisdiction="US")
f.write("w08-clearance-and-performance-claim.cypher")

# ---------------------------------------------------------------------------------------------------------------
# Fixture 4: negatives (each expected to be reported by a named validator)
# ---------------------------------------------------------------------------------------------------------------
f = Fx("W08 fixture 4: negative cases (load AFTER fixtures 1-3; each block is expected to fail a named validator)", [
    "Run run-2026-10-04-fable51-01, worker W08. Neo4j 5.x Cypher. Every statement binds its own nodes by uid.",
    "All uids contain 'w08-neg-' so they can be removed with one DETACH DELETE. Expected rows are in 06-fixtures-and-queries.md.",
    "N1 platform used as instrument (V-W08-01); N2 regulatory/performance property on a Device (V-W08-02); N3 status",
    "attached to a Device (V-W08-03); N4 510(k) response read as approval (V-320a); N5 softwareVersion disagrees with",
    "declared FirmwareVersion (V-W08-05); N6 firmware version of two devices (V-W08-06); N7 asserted W08 edge without",
    "assertion (V-W08-04); N8 private device unit leaked into the shared graph (V-113, V-W08-09); N9 retired Sensor",
    "MEASURES_METRIC (V-W08-08); N10 name collision: two device models named 'WHOOP' (informational V-W08-10, no merge);",
    "N11 performance claim about a device model without asserter or basis (V-W08-11).",
])
f.c("N1")
f.node(["AssayVersion", "VersionedState"], "hu:assay-version:w08-neg-platform-as-instrument", name="bad: runs on a platform", stateType="ASSAY_VERSION", payloadHash=synth("n1"), softwareVersionStatus="NOT_REPORTED")
f.rel("AssayVersion", "hu:assay-version:w08-neg-platform-as-instrument", "RUNS_ON_INSTRUMENT", "TechnologyPlatform", "hu:technology-platform:illumina-infinium-beadchip")
f.c("N2")
f.node(["Device", "Entity"], "hu:device:w08-neg-device-with-status-props", name="bad device", entityType="DEVICE", fdaCleared=True, clearanceNumber="K243236", accuracyPercent=96.2, medicalGrade=True)
f.c("N3")
f.node(["RegulatoryStatus", "VersionedState"], "hu:reg-status:w08-neg-clearance-on-device", statusKind="CLEARANCE", jurisdiction="US", stateType="REGULATORY_STATUS", payloadHash=synth("n3"))
f.stmt("MATCH (s:RegulatoryStatus {uid: 'hu:reg-status:w08-neg-clearance-on-device'}), (d:Device {uid: 'hu:device:whoop-mg'})\n"
       "MERGE (s)-[r:STATUS_OF]->(d)\nSET r.relationshipUid = 'hu:rel:w08-neg-clearance-on-device', r.assertionUid = 'hu:assertion:w08-neg-missing', r.recordedFrom = datetime('2026-10-04T04:00:00Z'), r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN'")
f.c("N4")
f.node(["RegulatoryStatus", "VersionedState"], "hu:reg-status:w08-neg-510k-read-as-approval", statusKind="APPROVAL", jurisdiction="US", stateType="REGULATORY_STATUS", payloadHash=synth("n4"))
f.rel("RegulatoryStatus", "hu:reg-status:w08-neg-510k-read-as-approval", "RESULTS_FROM_RESPONSE", "RegulatoryResponse", "hu:reg-response:us-fda-k243236")
f.c("N5")
f.node(["AssayVersion", "VersionedState"], "hu:assay-version:w08-neg-firmware-mismatch", name="bad: label disagrees", stateType="ASSAY_VERSION", payloadHash=synth("n5"), softwareVersion="41.16.2.0", softwareVersionStatus="REPORTED")
f.rel("AssayVersion", "hu:assay-version:w08-neg-firmware-mismatch", "RUNS_ON_INSTRUMENT", "Device", "hu:device:whoop-4-0")
f.rel("AssayVersion", "hu:assay-version:w08-neg-firmware-mismatch", "RUNS_FIRMWARE_VERSION", "FirmwareVersion", "hu:firmware-version:whoop-4-0-core-41-16-1-0")
f.c("N6")
f.node(["FirmwareVersion", "VersionedState"], "hu:firmware-version:w08-neg-two-devices", versionLabel="1.0", stateType="FIRMWARE_VERSION", payloadHash=synth("n6"))
f.rel("FirmwareVersion", "hu:firmware-version:w08-neg-two-devices", "FIRMWARE_VERSION_OF", "Device", "hu:device:whoop-4-0")
f.rel("FirmwareVersion", "hu:firmware-version:w08-neg-two-devices", "FIRMWARE_VERSION_OF", "Device", "hu:device:whoop-mg")
f.c("N7")
f.stmt("MATCH (o:Organization {uid: 'hu:org:whoop-inc'}), (p:TechnologyPlatform {uid: 'hu:technology-platform:illumina-infinium-beadchip'})\n"
       "MERGE (o)-[r:USES_PLATFORM]->(p)\nSET r.relationshipUid = 'hu:rel:w08-neg-unbacked-uses-platform', r.recordedFrom = datetime('2026-10-04T04:00:00Z'), r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN'")
f.c("N8 (fixture device: :PrivateRecord marks a private-store record that must never be in the shared graph)")
f.stmt("MERGE (u:PrivateRecord:Entity {uid: 'hu:private-device-unit:w08-neg-unit-0001'})\nSET u.serialNumber = 'SYNTHETIC-SERIAL-0001', u.privacyClass = 'private-personal', u.entityType = 'DEVICE_UNIT', u.createdAt = datetime()")
f.stmt("MATCH (d:Device {uid: 'hu:device:whoop-4-0'}), (u:PrivateRecord {uid: 'hu:private-device-unit:w08-neg-unit-0001'})\nMERGE (d)-[:HAS_UNIT]->(u)")
f.node(["Device", "Entity"], "hu:device:w08-neg-device-with-serial", name="bad: unit-level device", entityType="DEVICE", serialNumber="SYNTHETIC-SERIAL-0002")
f.c("N9")
f.node(["Sensor", "Entity"], "hu:sensor:w08-neg-sensor-measures", name="bad sensor", sensorType="PPG", entityType="SENSOR")
f.rel("Sensor", "hu:sensor:w08-neg-sensor-measures", "MEASURES_METRIC", "Metric", "hu:metric:heart-rate-bpm")
f.c("N10")
f.node(["Device", "Entity"], "hu:device:w08-neg-whoop-name-a", name="WHOOP", entityType="DEVICE", deviceFamily="WHOOP")
f.node(["Device", "Entity"], "hu:device:w08-neg-whoop-name-b", name="WHOOP", entityType="DEVICE", deviceFamily="WHOOP")
f.c("N11 performance claim written about a device model, with no asserter and no basis (V-W08-11)")
f.node(["Assertion"], "hu:assertion:w08-neg-device-accuracy-claim", predicate="REPORTS_ACCURACY", status="EXTRACTED", recordedAt=dt("2026-10-04T04:00:00Z"),
       valueNumber=99.0, unitCode="%", contentHash=synth("n11"))
f.rel("Assertion", "hu:assertion:w08-neg-device-accuracy-claim", "HAS_SUBJECT", "Device", "hu:device:whoop-mg")
f.write("w08-negatives.cypher")
print("fixtures written")
