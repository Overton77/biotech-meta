# Cypher emission helpers for the W15 fixtures (every statement binds its own nodes by uid; nothing crosses ';').
import hashlib, json, re

def sha(s):
    return 'sha256:' + hashlib.sha256(s.encode('utf-8')).hexdigest()

def norm(s):
    return re.sub(r'\s+', ' ', s).strip()

def q(s):
    return "'" + str(s).replace('\\', '\\\\').replace("'", "\\'") + "'"

class DT(str):
    pass

def dt(s):
    return DT(s)

def lit(v):
    if isinstance(v, DT):
        return "datetime(" + q(v) + ")"
    if isinstance(v, bool):
        return 'true' if v else 'false'
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, (list, tuple)):
        return '[' + ', '.join(lit(x) for x in v) + ']'
    return q(v)

def sets(var, props):
    return ', '.join(f"{var}.{k} = {lit(v)}" for k, v in props.items() if v is not None)

def opaque(uid):
    return uid.split(':', 2)[2]

ARCH = {'Entity', 'VersionedState', 'Occurrence', 'InformationArtifact', 'Assertion', 'EvidenceAssessment'}
ARCHFIELD = {'Entity': 'entityType', 'VersionedState': 'stateType', 'Occurrence': 'occurrenceType',
             'InformationArtifact': 'artifactType', 'EvidenceAssessment': 'assessmentType'}

class Fx:
    def __init__(self, ts):
        self.out = []
        self.ts = ts  # default commit instant for createdAt/updatedAt/recordedAt

    def c(self, text):
        self.out.append('// ' + text)

    def blank(self):
        self.out.append('')

    def st(self, text):
        self.out.append(text.rstrip().rstrip(';') + ';')

    def node(self, labels, uid, props=None, ts=None, privacy='PUBLIC'):
        ts = ts or self.ts
        props = dict(props or {})
        arch = [l for l in labels if l in ARCH]
        primary = labels[0]
        if arch and arch[0] in ARCHFIELD and ARCHFIELD[arch[0]] not in props:
            props[ARCHFIELD[arch[0]]] = primary
        base = {'id': opaque(uid)}
        base.update(props)
        if privacy and 'privacyClass' not in base:
            base['privacyClass'] = privacy
        base['createdAt'] = dt(ts)
        base['updatedAt'] = dt(ts)
        self.st(f"MERGE (n:{':'.join(labels)} {{uid: {q(uid)}}})\nON CREATE SET {sets('n', base)}")

    def rel(self, a_label, a_uid, rtype, b_label, b_uid, props=None, key=None):
        props = props or {}
        if key:
            head = f"MERGE (a)-[r:{rtype} {{relationshipUid: {q(key)}}}]->(b)"
        else:
            head = f"MERGE (a)-[r:{rtype}]->(b)"
        s = f"MATCH (a:{a_label} {{uid: {q(a_uid)}}}), (b:{b_label} {{uid: {q(b_uid)}}})\n{head}"
        if props:
            s += f"\nON CREATE SET {sets('r', props)}"
        self.st(s)

    # --- provenance ---------------------------------------------------------------------------------------------
    def source(self, uid, uri, title, kind, ts=None):
        self.node(['Source', 'Entity'], uid, {'canonicalUri': uri, 'title': title, 'sourceKind': kind}, ts)

    def snapshot(self, uid, source_uid, retrieved, observed, completeness, basis, chash=None, published=None,
                 archive=None, notice=None, ts=None):
        chash = chash or sha('W15 synthetic content hash for ' + uid)
        self.node(['SourceSnapshot', 'InformationArtifact'], uid, {
            'retrievedAt': dt(retrieved), 'observedAt': dt(observed), 'publishedAt': dt(published) if published else None,
            'contentHash': chash, 'contentHashBasis': basis, 'captureCompleteness': completeness,
            'archiveUri': archive, 'publisherRevisionNotice': notice}, ts)
        self.rel('Source', source_uid, 'HAS_SNAPSHOT', 'SourceSnapshot', uid)
        self.st(f"MATCH (s:SourceSnapshot {{uid: {q(uid)}}})<-[:HAS_SNAPSHOT]-(src:Source) SET s.canonicalUri = src.canonicalUri")

    def quote(self, uid, snap_uid, exact, ts=None):
        e = norm(exact)
        self.node(['SourceLocator', 'InformationArtifact'], uid, {
            'selectorKind': 'TEXT_QUOTE', 'exact': e, 'quoteHash': sha(e), 'normalizationVersion': 'NFC-WS1'}, ts)
        self.rel('SourceSnapshot', snap_uid, 'HAS_LOCATOR', 'SourceLocator', uid)

    def section(self, uid, snap_uid, section, exact=None, ts=None):
        p = {'selectorKind': 'SECTION', 'section': section, 'normalizationVersion': 'NFC-WS1'}
        if exact:
            p['exact'] = norm(exact)
            p['quoteHash'] = sha(norm(exact))
        self.node(['SourceLocator', 'InformationArtifact'], uid, p, ts)
        self.rel('SourceSnapshot', snap_uid, 'HAS_LOCATOR', 'SourceLocator', uid)

    def adjudicate(self, a_uid, verdict='SUPPORTED', kind='CAPTURE_FIDELITY', ts=None, rationale=None, uid=None):
        ts = ts or self.ts
        j = uid or ('hu:adjudication:' + opaque(a_uid) + ('-cf' if kind == 'CAPTURE_FIDELITY' else '-sup'))
        self.node(['Adjudication', 'EvidenceAssessment'], j, {
            'assessmentType': 'Adjudication', 'methodVersion': 'w15-capture-review/v0', 'status': 'ACCEPTED',
            'recordedAt': dt(ts), 'adjudicationKind': kind, 'verdict': verdict, 'reviewerType': 'HUMAN',
            'reviewedAt': dt(ts), 'rationale': rationale}, ts)
        self.rel('Adjudication', j, 'EVALUATES', 'Assertion', a_uid)

    def assertion(self, uid, pred, s_label, s_uid, o_label=None, o_uid=None, locs=(), status='ACCEPTED', ts=None,
                  value=None, asserter=None, extra=None, edge=None, edge_label_from=None, edge_label_to=None,
                  edge_extra=None, valid_from=None, valid_to=None, vf_basis='OBSERVATION_ONLY', vt_basis='UNKNOWN',
                  vf_prec=None, vt_prec=None, recorded_to=None):
        """Assertion + subject/object/locators (+ capture adjudication if ACCEPTED) + projected asserted edge."""
        ts = ts or self.ts
        props = {'predicate': pred, 'status': status, 'recordedAt': dt(ts), 'polarity': 'POSITIVE',
                 'predicateClass': 'COMMERCIAL', 'speechAct': 'STATES',
                 'validFrom': dt(valid_from) if valid_from else None, 'validTo': dt(valid_to) if valid_to else None,
                 'validFromBasis': vf_basis, 'validToBasis': vt_basis,
                 'validFromPrecision': vf_prec, 'validToPrecision': vt_prec,
                 'recordedTo': dt(recorded_to) if recorded_to else None}
        if value:
            props.update(value)
        if extra:
            props.update(extra)
        props['contentHash'] = sha('|'.join([pred, s_uid, o_uid or json.dumps(value or {}, sort_keys=True),
                                             str(valid_from), str(valid_to)]))
        self.node(['Assertion'], uid, props, ts)
        self.rel('Assertion', uid, 'HAS_SUBJECT', s_label, s_uid)
        if o_uid:
            self.rel('Assertion', uid, 'HAS_OBJECT', o_label, o_uid)
        for l in locs:
            self.rel('Assertion', uid, 'SUPPORTED_BY', 'SourceLocator', l)
        if asserter:
            self.rel('Assertion', uid, 'ASSERTED_BY', asserter[0], asserter[1])
        if status in ('ACCEPTED', 'REJECTED', 'DISPUTED'):
            self.adjudicate(uid, ts=ts)
        if edge and o_uid:
            ep = {'assertionUid': uid, 'validFromBasis': vf_basis, 'validToBasis': vt_basis,
                  'validFrom': dt(valid_from) if valid_from else None, 'validTo': dt(valid_to) if valid_to else None,
                  'validFromPrecision': vf_prec, 'validToPrecision': vt_prec,
                  'recordedFrom': dt(ts), 'recordedTo': dt(recorded_to) if recorded_to else None}
            if edge_extra:
                ep.update(edge_extra)
            self.rel(edge_label_from or s_label, s_uid, pred, edge_label_to or o_label, o_uid, ep,
                     key='hu:rel:' + opaque(uid))

    def price(self, uid, offer_uid, amount, currency, observed, kind, avail=None, loc=None, method=None, text=None,
              cond=None, region=None, unit_q=None, unit=None, plan=None, ts=None):
        self.node(['PriceObservation', 'Occurrence'], uid, {
            'amount': float(amount), 'currency': currency, 'observedAt': dt(observed), 'startedAt': dt(observed),
            'priceKind': kind, 'availabilityObserved': avail, 'sourceLocatorUid': loc, 'captureMethod': method,
            'priceTextVerbatim': text, 'conditionText': cond, 'observationRegion': region, 'unitQuantity': unit_q,
            'unitCode': unit, 'subscriptionPlanUid': plan}, ts)
        self.rel('Offer', offer_uid, 'HAS_PRICE_OBSERVATION', 'PriceObservation', uid)

    def text(self):
        return '\n'.join(self.out) + '\n'
