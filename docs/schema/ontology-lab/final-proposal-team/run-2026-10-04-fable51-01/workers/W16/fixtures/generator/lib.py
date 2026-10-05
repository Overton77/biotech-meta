# W16 fixture generator helpers. Emits Cypher where every statement binds its own nodes by uid.
import hashlib, json

T0 = "2026-10-04T01:00:00Z"   # fixture createdAt

class DT(str): pass          # datetime literal
class D(str): pass           # date literal

def lit(v):
    if v is None: return "null"
    if isinstance(v, bool): return "true" if v else "false"
    if isinstance(v, DT): return f"datetime('{v}')"
    if isinstance(v, D): return f"date('{v}')"
    if isinstance(v, (int, float)): return repr(v)
    if isinstance(v, (list, tuple)): return "[" + ", ".join(lit(x) for x in v) + "]"
    s = str(v).replace("\\", "\\\\").replace("'", "\\'")
    return f"'{s}'"

def mapl(d):
    return "{" + ", ".join(f"{k}: {lit(v)}" for k, v in d.items()) + "}"

def sha(obj):
    return "sha256:" + hashlib.sha256(json.dumps(obj, sort_keys=True, default=str).encode()).hexdigest()

ARCH = {"Protocol": "Entity", "ProtocolEdition": "VersionedState", "ProtocolStep": "Entity", "Constraint": "Entity",
        "MeasurementPlan": "Entity", "ProtocolAdjustmentRule": "Entity", "Target": "Entity", "FunctionalGoal": "Entity",
        "Observation": "InformationArtifact", "ProtocolResult": "InformationArtifact",
        "Source": "Entity", "SourceSnapshot": "InformationArtifact", "SourceLocator": "InformationArtifact",
        "Assertion": None, "Metric": "Entity", "LabTest": "Entity", "AssayVersion": "VersionedState",
        "Person": "Entity", "Organization": "Entity", "Product": "Entity", "ProductVariant": "Entity",
        "FormulationVersion": "VersionedState", "ChemicalSubstance": "Entity", "ToolOrInstrument": "Entity",
        "Publication": "InformationArtifact", "Activity": "Occurrence", "Outcome": "Entity"}
TYPEPROP = {"Entity": "entityType", "VersionedState": "stateType", "InformationArtifact": "artifactType", "Occurrence": "occurrenceType"}

class Fx:
    def __init__(self, name, header):
        self.name = name; self.out = [header.rstrip() + "\n"]
    def c(self, text): self.out.append("\n// " + text.replace("\n", "\n// ") + "\n")
    def raw(self, text): self.out.append(text.strip() + ";\n")
    def node(self, label, uid, props=None, extra_labels=(), privacy="PUBLIC"):
        a = ARCH.get(label, "Entity")
        labels = ":".join([label] + ([a] if a else []) + list(extra_labels))
        p = {"id": uid.split(":", 2)[2], "createdAt": DT(T0)}
        if privacy: p["privacyClass"] = privacy
        if a: p[TYPEPROP[a]] = label
        p.update(props or {})
        self.out.append(f"MERGE (n:{labels} {{uid: {lit(uid)}}}) SET n += {mapl(p)};\n")
    def edge(self, fl, fu, typ, tl, tu, props=None, key=None):
        k = f" {{relationshipUid: {lit(key)}}}" if key else ""
        s = f"MATCH (a:{fl} {{uid: {lit(fu)}}}), (b:{tl} {{uid: {lit(tu)}}}) MERGE (a)-[r:{typ}{k}]->(b)"
        if props: s += f" SET r += {mapl(props)}"
        self.out.append(s + ";\n")
    def source(self, src, uri, title, kind, snap, observedAt, retrievedAt, completeness, loc, selector, publishedAt=None, basis="SYNTHETIC_FIXTURE"):
        self.node("Source", src, {"canonicalUri": uri, "title": title, "sourceKind": kind})
        self.node("SourceSnapshot", snap, {"canonicalUri": uri, "observedAt": DT(observedAt), "retrievedAt": DT(retrievedAt),
                  "publishedAt": DT(publishedAt) if publishedAt else None, "contentHash": "synthetic:" + snap,
                  "contentHashBasis": basis, "captureCompleteness": completeness})
        sel = {"selectorKind": selector[0]}
        if selector[0] == "TEXT_QUOTE": sel["exact"] = selector[1]
        if selector[0] == "SECTION": sel["section"] = selector[1]
        self.node("SourceLocator", loc, sel)
        self.edge("Source", src, "HAS_SNAPSHOT", "SourceSnapshot", snap)
        self.edge("SourceSnapshot", snap, "HAS_LOCATOR", "SourceLocator", loc)
    def assertion(self, uid, predicate, subj, obj=None, props=None, locs=(), asserter=None):
        p = {"predicate": predicate, "status": "ACCEPTED", "polarity": "POSITIVE", "recordedAt": DT(T0),
             "recordedTo": None, "contentHash": sha([uid, predicate]), "privacyClass": "PUBLIC"}
        p.update(props or {})
        self.out.append(f"MERGE (n:Assertion {{uid: {lit(uid)}}}) SET n += {mapl(p)};\n")
        self.edge("Assertion", uid, "HAS_SUBJECT", subj[0], subj[1])
        if obj: self.edge("Assertion", uid, "HAS_OBJECT", obj[0], obj[1])
        for l in locs: self.edge("Assertion", uid, "SUPPORTED_BY", "SourceLocator", l)
        if asserter: self.edge("Assertion", uid, "ASSERTED_BY", asserter[0], asserter[1])
    def asserted_edge(self, fl, fu, typ, tl, tu, auid, rel):
        # projection of exactly one Assertion: copy its valid time, recordedFrom = assertion.recordedAt
        self.out.append(
            f"MATCH (a:{fl} {{uid: {lit(fu)}}}), (b:{tl} {{uid: {lit(tu)}}}), (x:Assertion {{uid: {lit(auid)}}}) "
            f"MERGE (a)-[r:{typ} {{relationshipUid: {lit(rel)}}}]->(b) "
            "SET r.assertionUid = x.uid, r.validFrom = x.validFrom, r.validFromPrecision = x.validFromPrecision, "
            "r.validFromBasis = coalesce(x.validFromBasis, 'UNKNOWN'), r.validTo = x.validTo, r.validToPrecision = x.validToPrecision, "
            "r.validToBasis = coalesce(x.validToBasis, 'UNKNOWN'), r.recordedFrom = x.recordedAt, r.recordedTo = x.recordedTo;\n")
    def write(self, path):
        open(path, "w").write("".join(self.out))

def step_hash(step, edges):
    return sha({"canon": "W16-CANON-1", "step": {k: v for k, v in step.items() if k not in ("uid",)}, "edges": edges})

class Step:
    """A step definition; uid and payloadHash derive from content so unchanged steps are shared across editions."""
    def __init__(self, protocol_slug, key, props, uses=(), employs=(), constraints=(), deps=(), version=1):
        self.key = key; self.props = dict(props); self.uses = list(uses); self.employs = list(employs)
        self.constraints = list(constraints); self.deps = list(deps)
        self.props.setdefault("requirementBasis", "STATED_BY_SOURCE")
        self.hash = step_hash({"stepKey": key, **self.props},
                              {"uses": [(u[1], u[2]) for u in self.uses], "employs": [e[1] for e in self.employs],
                               "constraints": [(c[0], c[1]) for c in self.constraints], "deps": [(d[0], d[1]) for d in self.deps]})
        self.uid = f"hu:protocol-step:{protocol_slug}-{key}-v{version}"
    def emit(self, fx):
        fx.node("ProtocolStep", self.uid, {"stepKey": self.key, "payloadHash": self.hash, **self.props})
        for (lab, uid, dose) in self.uses: fx.edge("ProtocolStep", self.uid, "USES", lab, uid, dose)
        for (lab, uid) in self.employs: fx.edge("ProtocolStep", self.uid, "EMPLOYS", lab, uid, {"orderIndex": 1})
        for (cuid, role, grp, neg) in self.constraints:
            fx.edge("ProtocolStep", self.uid, "HAS_CONSTRAINT", "Constraint", cuid,
                    {"constraintRole": role, "conditionGroup": grp, "negated": neg})

def emit_deps(fx, step, resolver):
    for (target_key, kind, extra) in step.deps:
        fx.edge("ProtocolStep", step.uid, "DEPENDS_ON", "ProtocolStep", resolver[target_key].uid, {"dependencyKind": kind, **(extra or {})})

def edition(fx, uid, label, prov, steps, extra=None, other_payload=()):
    """steps: list of (Step, edgeProps) — order and section live on the HAS_PROTOCOL_STEP edge."""
    ph = sha({"canon": "W16-CANON-1", "steps": sorted((s.key, s.hash) for s, _ in steps), "other": sorted(other_payload)})
    p = {"editionLabel": label, "changeProvenance": prov, "payloadHash": ph, "payloadCanonicalizationVersion": "W16-CANON-1",
         "stepKeyAlignmentVersion": "W16-STEPKEY-1"}
    p.update(extra or {})
    fx.node("ProtocolEdition", uid, p)
    for i, (s, ep) in enumerate(steps, 1):
        fx.edge("ProtocolEdition", uid, "HAS_PROTOCOL_STEP", "ProtocolStep", s.uid, {"orderIndex": i, **(ep or {})})

def attach(fx, protocol_uid, edition_uid, auid, rel, loc, vf, vfp, vfb, vt, vtp, vtb, recordedAt=None, asserter=None):
    fx.assertion(auid, "HAS_PROTOCOL_EDITION", ("Protocol", protocol_uid), ("ProtocolEdition", edition_uid),
                 {"validFrom": vf, "validFromPrecision": vfp, "validFromBasis": vfb, "validTo": vt, "validToPrecision": vtp,
                  "validToBasis": vtb, "recordedAt": DT(recordedAt or T0), 
                  "speechAct": "STATES", "assertionBasis": "UNSTATED"}, [loc], asserter)
    fx.asserted_edge("Protocol", protocol_uid, "HAS_PROTOCOL_EDITION", "ProtocolEdition", edition_uid, auid, rel)
