import hashlib, json, unicodedata, re

REC = '2026-10-04T01:00:00Z'      # recordedAt of W01 assertions = recordedFrom of their projected edges
REVIEW = '2026-10-04T01:05:00Z'   # capture-fidelity review instant
CREATED = '2026-10-04T01:00:00Z'

def nfcws(s):
    return re.sub(r'\s+', ' ', unicodedata.normalize('NFC', s)).strip()
def sha(s):
    return 'sha256:' + hashlib.sha256(s.encode('utf-8')).hexdigest()
def q(v):
    if v is None: return 'null'
    if isinstance(v, bool): return 'true' if v else 'false'
    if isinstance(v, (int, float)): return repr(v)
    if isinstance(v, list): return '[' + ', '.join(q(x) for x in v) + ']'
    if isinstance(v, DT): return v.cy()
    s = str(v).replace('\\', '\\\\').replace("'", "\\'")
    return "'" + s + "'"
class DT:
    def __init__(self, iso): self.iso = iso
    def cy(self): return "datetime('" + self.iso + "')"
class D:
    def __init__(self, iso): self.iso = iso
    def cy(self): return "date('" + self.iso + "')"
def bound(spec):
    """('2017','YEAR') | ('2017-08','MONTH') | ('2018-06-01','DAY') -> DT at first instant of the period"""
    if spec is None: return None
    v, p = spec
    if p == 'YEAR': iso = v + '-01-01T00:00:00Z'
    elif p == 'MONTH': iso = v + '-01T00:00:00Z'
    elif p == 'DAY': iso = v + 'T00:00:00Z'
    elif p == 'QUARTER': iso = v + '-01T00:00:00Z'
    else: iso = v
    return DT(iso)
def props(d):
    return '{' + ', '.join(f'{k}: {q(v)}' for k, v in d.items() if v is not None) + '}'
def opaque(uid): return uid.split(':', 2)[2]

class Fx:
    def __init__(self, title, header):
        self.out = ['// ' + l for l in header.strip().split('\n')]
        self.out.append('')
        self.snap_exacts = {}
        self.assertions = {}
    def c(self, text): self.out.append('\n// ' + text)
    def stmt(self, s): self.out.append(s.strip() + ';')
    def node(self, labels, uid, archetype_field=None, privacy='PUBLIC', **p):
        base = {'id': opaque(uid), 'createdAt': DT(CREATED), 'updatedAt': DT(CREATED), 'privacyClass': privacy}
        if archetype_field: base[archetype_field[0]] = archetype_field[1]
        base.update(p)
        lab = ':'.join(labels)
        self.stmt(f"MERGE (n:{lab} {{uid: {q(uid)}}})\nSET n += {props(base)}")
    # convenience
    def person(self, uid, name, **p): self.node(['Person','Entity'], uid, ('entityType','Person'), name=name, **p)
    def legal(self, uid, name, **p): self.node(['LegalEntity','Organization','Entity'], uid, ('entityType','LegalEntity'), name=name, **p)
    def org(self, uid, name, **p): self.node(['Organization','Entity'], uid, ('entityType','Organization'), name=name, **p)
    def brand(self, uid, name, **p): self.node(['ConsumerBrand','Entity'], uid, ('entityType','ConsumerBrand'), name=name, **p)
    def facility(self, uid, name, **p): self.node(['Facility','Entity'], uid, ('entityType','Facility'), name=name, **p)
    def product(self, uid, name, **p): self.node(['Product','Entity'], uid, ('entityType','Product'), name=name, **p)
    def activity(self, uid, method):
        self.node(['Activity','Occurrence'], uid, ('occurrenceType','Activity'), activityKind='EXTRACTION', methodVersion=method,
                  startedAt=DT('2026-10-04T00:52:00Z'), endedAt=DT('2026-10-04T01:00:00Z'), privacy='INTERNAL')
    def source(self, uid, uri, kind, title):
        self.node(['Source','Entity'], uid, ('entityType','Source'), canonicalUri=uri, sourceKind=kind, title=title)
    def snapshot(self, uid, source_uid, retrieved, observed=None, published=None, publishedPrec=None,
                 completeness='PARTIAL_EXCERPT', basis='STORED_EXCERPT_TEXT', excerpts=None, provenance=None):
        # contentHash: STORED_EXCERPT_TEXT = sha256 over NFC-WS1(all TEXT_QUOTE exact strings of this snapshot joined by one space,
        # in the order given); SYNTHETIC_FIXTURE = sha256 over the snapshot uid.
        if basis == 'SYNTHETIC_FIXTURE': h = sha(uid)
        else: h = sha(nfcws(' '.join(excerpts)))
        self.node(['SourceSnapshot','InformationArtifact'], uid, ('artifactType','SourceSnapshot'),
                  retrievedAt=DT(retrieved), observedAt=DT(observed or retrieved), publishedAt=DT(published) if published else None,
                  publishedAtPrecision=publishedPrec, captureCompleteness=completeness, contentHashBasis=basis, contentHash=h,
                  fixtureProvenance=provenance)
        self.stmt(f"MATCH (s:Source {{uid: {q(source_uid)}}}), (sn:SourceSnapshot {{uid: {q(uid)}}})\nMERGE (s)-[:HAS_SNAPSHOT]->(sn)")
    def locator(self, uid, snap_uid, kind='TEXT_QUOTE', exact=None, section=None, uri=None):
        p = {'selectorKind': kind, 'uri': uri}
        if exact is not None:
            p.update(exact=exact, quoteHash=sha(nfcws(exact)), normalizationVersion='NFC-WS1')
        if section is not None: p['section'] = section
        self.node(['SourceLocator','InformationArtifact'], uid, ('artifactType','SourceLocator'), **p)
        self.stmt(f"MATCH (sn:SourceSnapshot {{uid: {q(snap_uid)}}}), (l:SourceLocator {{uid: {q(uid)}}})\nMERGE (sn)-[:HAS_LOCATOR]->(l)")
    def assertion(self, uid, predicate, subj, obj=None, asserter=None, locators=(), activity=None, status='ACCEPTED',
                  vf=None, vt=None, vfBasis=None, vtBasis=None, recordedAt=REC, review=True, extra_labels=(), **p):
        vfrom, vto = bound(vf), bound(vt)
        a = {'id': opaque(uid), 'predicate': predicate, 'status': status, 'polarity': p.pop('polarity', 'POSITIVE'),
             'predicateClass': p.pop('predicateClass', 'ROLE'), 'speechAct': p.pop('speechAct', 'STATES'),
             'assertionBasis': p.pop('assertionBasis', 'UNSTATED'),
             'validFrom': vfrom, 'validFromPrecision': vf[1] if vf else None,
             'validFromBasis': vfBasis or ('STATED_BY_SOURCE' if vf else 'UNKNOWN'),
             'validTo': vto, 'validToPrecision': vt[1] if vt else None,
             'validToBasis': vtBasis or ('STATED_BY_SOURCE' if vt else 'UNKNOWN'),
             'recordedAt': DT(recordedAt), 'extractionMethod': 'manual', 'privacyClass': 'PUBLIC', 'createdAt': DT(CREATED)}
        a.update(p)
        canon = json.dumps({'predicate': predicate, 'subject': subj, 'object': obj, 'polarity': a['polarity'],
                            'valueString': a.get('valueString'), 'validFrom': vfrom.iso if vfrom else None,
                            'validTo': vto.iso if vto else None, 'validFromPrecision': a['validFromPrecision'],
                            'validToPrecision': a['validToPrecision']}, sort_keys=True)
        a['contentHash'] = sha(canon)
        lab = ':'.join(('Assertion',) + tuple(extra_labels))
        self.stmt(f"MERGE (a:{lab} {{uid: {q(uid)}}})\nSET a += {props(a)}")
        m = [f"(a:Assertion {{uid: {q(uid)}}})", f"(s {{uid: {q(subj)}}})"]
        body = ["MERGE (a)-[:HAS_SUBJECT]->(s)"]
        if obj:
            m.append(f"(o {{uid: {q(obj)}}})"); body.append("MERGE (a)-[:HAS_OBJECT]->(o)")
        if asserter:
            m.append(f"(w {{uid: {q(asserter)}}})"); body.append("MERGE (a)-[:ASSERTED_BY]->(w)")
        if activity:
            m.append(f"(act:Activity {{uid: {q(activity)}}})"); body.append("MERGE (a)-[:WAS_GENERATED_BY]->(act)")
        for i, l in enumerate(locators):
            m.append(f"(l{i}:SourceLocator {{uid: {q(l)}}})"); body.append(f"MERGE (a)-[:SUPPORTED_BY]->(l{i})")
        self.stmt("MATCH " + ', '.join(m) + "\n" + "\n".join(body))
        if review and status in ('ACCEPTED', 'REJECTED', 'DISPUTED', 'SUPERSEDED'):
            j = 'hu:adjudication:' + opaque(uid) + '-capture'
            rev = REVIEW if recordedAt <= REVIEW else recordedAt
            self.node(['Adjudication','EvidenceAssessment'], j, ('assessmentType','Adjudication'), adjudicationKind='CAPTURE_FIDELITY',
                      verdict='SUPPORTED', reviewerType='AGENT', methodVersion='w01-capture-review-v0', status='ACCEPTED',
                      reviewedAt=DT(rev), recordedAt=DT(rev), rationale='Assertion matches the cited span (capture fidelity only; not a truth verdict).',
                      privacy='INTERNAL')
            self.stmt(f"MATCH (j:Adjudication {{uid: {q(j)}}}), (a:Assertion {{uid: {q(uid)}}})\nMERGE (j)-[:EVALUATES]->(a)")
        self.assertions[uid] = dict(subj=subj, obj=obj, vf=vf, vt=vt, vfrom=vfrom, vto=vto, vfBasis=a['validFromBasis'],
                                    vtBasis=a['validToBasis'], predicate=predicate, recordedAt=recordedAt)
    def edge(self, rtype, a_uid, from_label, to_label, rel_uid, recordedFrom=REC, recordedTo=None, reverse=False, **qual):
        a = self.assertions[a_uid]
        frm, to = (a['obj'], a['subj']) if reverse else (a['subj'], a['obj'])
        p = {'relationshipUid': rel_uid, 'assertionUid': a_uid, 'validFrom': a['vfrom'], 'validTo': a['vto'],
             'validFromPrecision': a['vf'][1] if a['vf'] else None, 'validToPrecision': a['vt'][1] if a['vt'] else None,
             'validFromBasis': a['vfBasis'], 'validToBasis': a['vtBasis'], 'recordedFrom': DT(recordedFrom),
             'recordedTo': DT(recordedTo) if recordedTo else None}
        p.update(qual)
        self.stmt(f"MATCH (x:{from_label} {{uid: {q(frm)}}}), (y:{to_label} {{uid: {q(to)}}})\n"
                  f"MERGE (x)-[r:{rtype} {{relationshipUid: {q(rel_uid)}}}]->(y)\nSET r += {props(p)}")
    def write(self, path):
        open(path, 'w').write('\n'.join(self.out) + '\n')
