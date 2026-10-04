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
    (dst / name).write_text(t)
print("\n".join(log) if log else "no substitutions")
