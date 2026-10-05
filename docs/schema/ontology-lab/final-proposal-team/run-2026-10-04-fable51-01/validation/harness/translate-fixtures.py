#!/usr/bin/env python3
"""Translate the six 0.2.0 example fixtures to the final proposal's labels and conventions.
Rules (each cited in reports/06-migration-and-compatibility.md): Listing -> MerchantListing (D-007); privacyClass values
upper-cased (MR-10); elysium-basis assertion recordedAt pinned (decision report D); claim-retelling Document stored names
(W20-SR-23); 'FINAL' status is not an AssertionStatus -> ACCEPTED where used on assertions (W00-SR-13 note).
Everything else is left byte-identical. Output lists every substitution made."""
import re, sys, pathlib
src = pathlib.Path('/home/user/biotech-meta/docs/schema/examples'); dst = pathlib.Path(sys.argv[1]); dst.mkdir(exist_ok=True)
log = []
def sub(name, text, pattern, repl, flags=0):
    new, n = re.subn(pattern, repl, text, flags=flags)
    if n: log.append(f"{name}: {n}x {pattern[:60]} -> {repl[:60]}")
    return new
for f in sorted(src.glob('*.cypher')):
    t = f.read_text(); name = f.name
    t = sub(name, t, r':Listing\b', ':MerchantListing')
    t = sub(name, t, r"privacyClass\s*:\s*'public'", "privacyClass: 'PUBLIC'")
    t = sub(name, t, r"privacyClass\s*:\s*'internal'", "privacyClass: 'INTERNAL'")
    t = sub(name, t, r"privacyClass\s*=\s*'public'", "privacyClass = 'PUBLIC'")
    t = sub(name, t, r"privacyClass\s*=\s*'internal'", "privacyClass = 'INTERNAL'")
    if name == 'elysium-basis.cypher':
        t = sub(name, t, r"\.recordedAt = datetime\(\)", ".recordedAt = datetime('2026-10-03T12:00:00Z')")
    if name == 'claim-retelling-provenance.cypher':
        # Document nodes: GraphQL field names -> stored property names (documentId/title/url/type)
        # Document nodes: stored property names (type, url, documentId) per W20-SR-23 / W00-SR-03
        def fix_doc(m):
            uid = m.group(2); seg = uid.split(':',2)[2]
            block = m.group(0).replace('n.documentType =', 'n.type =')
            return block.rstrip(';') + f", n.documentId = '{seg}', n.url = n.canonicalUri;"
        t, n = re.subn(r"(MERGE \(n:Entity:Source:Document \{uid: '([^']+)'\}\)\nSET [^;]*;)", fix_doc, t)
        if n: log.append(f"{name}: {n}x Document stored-name fix (type, documentId, url)")
    if name == 'recommendation-snapshot.cypher':
        # D-004 / CL-013 (CH-R-13): edition -> step edges are HAS_PROTOCOL_STEP (orderIndex kept); diff queries follow.
        t = sub(name, t, r'\bHAS_STEP\b', 'HAS_PROTOCOL_STEP')
        # CH-P-16: the ranking policy version gets its required keys.
        t = sub(name, t, r"pv\.payloadHash = 'sha256:fixture-policy-v3',", "pv.payloadHash = 'sha256:fixture-policy-v3', pv.stateType = 'PolicyVersion', pv.policyKey = 'sleep-support-ranking', pv.versionLabel = 'v3', pv.policyKind = 'RECOMMENDATION_RANKING',")
    if name == 'claim-retelling-provenance.cypher':
        # CH-P-16: the quoting policy placeholder is a VersionedState with the policy-version token and required keys, INTERNAL.
        t = sub(name, t, r"MERGE \(pv:Entity:PolicyVersion \{uid: 'hu:policy:answer-quoting-policy-v0'\}\)\nSET pv\.entityType = 'PolicyVersion',",
                "MERGE (pv:VersionedState:PolicyVersion {uid: 'hu:policy-version:answer-quoting-policy-v0'})\nSET pv.stateType = 'PolicyVersion', pv.policyKey = 'answer-quoting', pv.versionLabel = 'v0', pv.policyKind = 'USE_AUTHORIZATION', pv.privacyClass = 'INTERNAL', pv.payloadHash = 'sha256:fixture-answer-quoting-v0',")
        t = sub(name, t, r"hu:policy:answer-quoting-policy-v0", "hu:policy-version:answer-quoting-policy-v0")
    if name == 'study-vs-product-mismatch.cypher':
        # CH-S-18: uid tokens follow the W00 registry (arm, intervention) so W09/W10 fixtures attach to the same identities.
        t = sub(name, t, r"hu:study-arm:", "hu:arm:")
        t = sub(name, t, r"hu:study-intervention:", "hu:intervention:")
    # Round-2 repairs from the W00 corrections run on the translated set (decision report D, Wave 5):
    t = sub(name, t, r'\bIDENTIFIED_BY\b', 'HAS_IDENTIFIER')                       # W00-R-20 / V-W00-15
    t = sub(name, t, r"hu:reg-status:", "hu:regulatory-status:")                      # V-W00-16 registry token
    t = sub(name, t, r"hu:chemical-form:", "hu:form:")                                # V-W00-16 registry token
    if name == 'diagnostic-comparison.cypher':
        t = sub(name, t, r"\(r:InformationArtifact:DiagnosticResult \{uid: 'hu:result:", "(r:Observation:DiagnosticResult:InformationArtifact {uid: 'hu:observation:")  # CL-008 / V-W00-16
        t = sub(name, t, r"hu:result:", "hu:observation:")
        t = sub(name, t, r"privacyClass = 'synthetic'", "privacyClass = 'INTERNAL'")   # 'synthetic' is not a shared-graph class (V-313r/V-521r); fail closed
        t = sub(name, t, r"(d\.assertionUid = 'hu:assertion:grimage2-derived-from-grimage-v1', d\.recordedFrom = datetime\('2026-10-03T00:00:00Z'\))", r"\1, d.validFrom = datetime('2022-12-14T00:00:00Z'), d.validFromPrecision = 'DAY', d.validFromBasis = 'PUBLICATION_PROXY'")  # V-505r
    if name == 'recommendation-snapshot.cypher':
        t = sub(name, t, r"SET r\.assertionUid = 'hu:assertion:synthetic-host-recommends-nightcue'", "SET r.projectionOfAssertionUid = 'hu:assertion:synthetic-host-recommends-nightcue'")  # D-011 / V-W00-02r
    if name == 'study-vs-product-mismatch.cypher':
        t = sub(name, t, r"v1\.recordedAt = datetime\('2019-06-01T00:00:00Z'\)", "v1.recordedAt = datetime('2026-10-03T12:00:00Z')")  # V-504a: recorded after the cited snapshot
        t = sub(name, t, r"v2\.recordedAt = datetime\('2019-09-15T00:00:00Z'\)", "v2.recordedAt = datetime('2026-10-03T12:30:00Z')")
    # Round-3 repairs (V-423r, V-W00-16 assertion/outcome tokens):
    if name == 'recommendation-snapshot.cypher':
        t = sub(name, t, r"SET r\.projectionOfAssertionUid = 'hu:assertion:synthetic-host-recommends-nightcue'", "SET r.projectionOfAssertionUid = 'hu:assertion:synthetic-host-recommends-nightcue', r.derivationRule = 'recommends-speech-act/v1', r.derivedFromAssertionUids = ['hu:assertion:synthetic-host-recommends-nightcue']")
    bad = set(re.findall(r":OutcomeDefinition[A-Za-z:]* \{uid: '(hu:outcome:[^']+)'", t))
    for u in sorted(bad):
        t = sub(name, t, re.escape(u), u.replace('hu:outcome:', 'hu:outcome-definition:'))
    # Round-4 repairs (Challenger matrix defects D1, D3):
    if name == 'recommendation-snapshot.cypher':
        t = sub(name, t, r"ea\.identityMatch = 'UNKNOWN', ea\.doseMatch = 'MATCH', ea\.populationMatch = 'PARTIAL',", "ea.identityMatch = 'UNKNOWN', ea.doseMatch = 'UNKNOWN', ea.populationMatch = 'PARTIAL',")  # D1: flat field follows its EXPOSURE dimension (V-F5-04)
    if name == 'study-vs-product-mismatch.cypher':
        t = sub(name, t, r"v1\.status = 'ACCEPTED', v1\.createdAt = datetime\(\)", "v1.status = 'SUPERSEDED', v1.recordedTo = datetime('2026-10-03T12:30:00Z'), v1.createdAt = datetime()")  # D3: superseded synthesis closed at v2.recordedAt (V-F5-14)
    (dst / name).write_text(t)
print("\n".join(log) if log else "no substitutions")
