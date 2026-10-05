"""W18 fixture helpers: emit Cypher statements that each bind their own nodes by uid (no variable crosses ';').
Quote hashes use NFC-WS1 (catalog conventions.normalizationVersions): NFC, whitespace runs -> one space, trim, sha256."""
import hashlib, unicodedata, re

CREATED = "2026-10-04T08:00:00Z"

class DT(str):
    pass

def nfcws1(s):
    return re.sub(r"\s+", " ", unicodedata.normalize("NFC", s)).strip()

def qhash(s):
    return "sha256:" + hashlib.sha256(nfcws1(s).encode("utf-8")).hexdigest()

def shash(s):
    return "sha256:" + hashlib.sha256(s.encode("utf-8")).hexdigest()

def lit(v):
    if isinstance(v, DT):
        return f"datetime('{v}')"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, (list, tuple)):
        return "[" + ", ".join(lit(x) for x in v) + "]"
    s = str(v).replace("\\", "\\\\").replace("'", "\\'")
    return f"'{s}'"

def props(d):
    return "{" + ", ".join(f"{k}: {lit(v)}" for k, v in d.items() if v is not None) + "}"

def opaque(uid):
    return uid.split(":", 2)[2]

class Fx:
    def __init__(self, header):
        self.out = [header.rstrip()]
        self.labels = {}

    def stmt(self, s):
        self.out.append(s.rstrip().rstrip(";") + ";")

    def node(self, labels, uid, **p):
        self.labels[uid] = labels[0]
        base = {"id": opaque(uid), "createdAt": DT(CREATED), "updatedAt": DT(CREATED), "privacyClass": p.pop("privacyClass", "PUBLIC")}
        base.update(p)
        self.stmt(f"MERGE (n:{':'.join(labels)} {{uid: {lit(uid)}}}) SET n += {props(base)}")
        return uid

    def edge(self, a, typ, b, **p):
        la, lb = self.labels[a], self.labels[b]
        key = p.pop("relationshipUid", None)
        keyp = f" {{relationshipUid: {lit(key)}}}" if key else ""
        setp = f" SET r += {props(p)}" if p else ""
        self.stmt(f"MATCH (a:{la} {{uid: {lit(a)}}}), (b:{lb} {{uid: {lit(b)}}}) MERGE (a)-[r:{typ}{keyp}]->(b){setp}")

    # --- provenance chain -------------------------------------------------------------
    def source(self, uid, uri, title, kind, labels=("Source", "Entity"), **p):
        return self.node(list(labels), uid, entityType="Source", canonicalUri=uri, title=title, sourceKind=kind, **p)

    def snapshot(self, uid, src, uri, retrievedAt, publishedAt=None, publishedAtPrecision=None, observedAt=None,
                 completeness="PARTIAL_EXCERPT", basis="SYNTHETIC_FIXTURE"):
        self.node(["SourceSnapshot", "InformationArtifact"], uid, artifactType="SourceSnapshot", canonicalUri=uri,
                  retrievedAt=DT(retrievedAt), observedAt=DT(observedAt or retrievedAt),
                  publishedAt=DT(publishedAt) if publishedAt else None, publishedAtPrecision=publishedAtPrecision,
                  contentHash=shash(uid), contentHashBasis=basis, captureCompleteness=completeness)
        self.edge(src, "HAS_SNAPSHOT", uid)
        return uid

    def locator(self, uid, snap, exact=None, section=None, uri=None):
        if exact is not None:
            self.node(["SourceLocator", "InformationArtifact"], uid, artifactType="SourceLocator", uri=uri,
                      selectorKind="TEXT_QUOTE", exact=nfcws1(exact), quoteHash=qhash(exact), normalizationVersion="NFC-WS1")
        else:
            self.node(["SourceLocator", "InformationArtifact"], uid, artifactType="SourceLocator", uri=uri,
                      selectorKind="SECTION", section=section)
        self.edge(snap, "HAS_LOCATOR", uid)
        return uid

    def assertion(self, uid, predicate, subject, obj=None, asserter=None, locators=(), recordedAt=None,
                  status="EXTRACTED", **p):
        self.node(["Assertion"], uid, predicate=predicate, status=status, recordedAt=DT(recordedAt),
                  contentHash=shash(uid + "|" + predicate), **p)
        self.edge(uid, "HAS_SUBJECT", subject)
        if obj:
            self.edge(uid, "HAS_OBJECT", obj)
        if asserter:
            self.edge(uid, "ASSERTED_BY", asserter)
        for l in locators:
            self.edge(uid, "SUPPORTED_BY", l)
        return uid

    def asserted_edge(self, a, typ, b, assertion_uid, recordedFrom, rel_uid, **extra):
        p = dict(relationshipUid=rel_uid, assertionUid=assertion_uid, recordedFrom=DT(recordedFrom),
                 validFromBasis=extra.pop("validFromBasis", "UNKNOWN"), validToBasis=extra.pop("validToBasis", "UNKNOWN"))
        p.update(extra)
        self.edge(a, typ, b, **p)

    def write(self, path):
        with open(path, "w", encoding="utf-8") as f:
            f.write("\n".join(self.out) + "\n")
        return len(self.out) - 1

def known(fx, mapping):
    """Register nodes created by an earlier fixture file (uid -> primary label)."""
    fx.labels.update(mapping)
