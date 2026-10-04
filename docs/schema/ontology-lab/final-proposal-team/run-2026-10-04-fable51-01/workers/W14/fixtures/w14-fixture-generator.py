#!/usr/bin/env python3
"""W14 fixture generator. Emits Cypher where every statement binds its own nodes by uid (no variable crosses ';')."""
import hashlib, json, unicodedata, re, sys, os

OUT = sys.argv[1]

def nfcws1(s):
    s = unicodedata.normalize('NFC', s)
    return re.sub(r'\s+', ' ', s).strip()

def sha(s):
    return 'sha256:' + hashlib.sha256(s.encode('utf-8')).hexdigest()

def lit(v):
    if v is None: return 'null'
    if isinstance(v, bool): return 'true' if v else 'false'
    if isinstance(v, (int, float)): return repr(v)
    if isinstance(v, list): return '[' + ', '.join(lit(x) for x in v) + ']'
    if isinstance(v, str):
        if v.startswith('@dt:'): return "datetime('%s')" % v[4:]
        if v.startswith('@d:'): return "date('%s')" % v[3:]
        return "'" + v.replace('\\', '\\\\').replace("'", "\\'") + "'"
    raise TypeError(v)

def props(d):
    return '{' + ', '.join('%s: %s' % (k, lit(v)) for k, v in d.items() if v is not None) + '}'

LABELS = {}   # uid -> label list
class F:
    def __init__(self, title):
        self.lines = ['// ' + l for l in title.strip().split('\n')]
        self.lines.append('')
        self.n = 0
    def c(self, text):
        self.lines.append('// ' + text)
    def stmt(self, s):
        self.lines.append(s.strip() + ';')
        self.n += 1
    def node(self, uid, labels, **p):
        LABELS[uid] = labels
        primary = labels[0]
        extra = ''.join(':' + l for l in labels[1:])
        p = {k: v for k, v in p.items()}
        p.setdefault('privacyClass', 'PUBLIC')
        setlabels = ('n%s, ' % extra) if extra else ''
        self.stmt('MERGE (n:%s {uid: %s})\nSET %sn += %s' % (primary, lit(uid), setlabels, props(p)))
    def edge(self, a, t, b, merge_key=None, **p):
        la, lb = LABELS[a][0], LABELS[b][0]
        key = (' ' + props({'relationshipUid': merge_key})) if merge_key else ''
        setp = ('\nSET r += %s' % props(p)) if p else ''
        self.stmt('MATCH (a:%s {uid: %s}), (b:%s {uid: %s})\nMERGE (a)-[r:%s%s]->(b)%s' % (la, lit(a), lb, lit(b), t, key, setp))
    def write(self, path):
        with open(path, 'w') as fh:
            fh.write('\n'.join(self.lines) + '\n')
        return self.n

T_REC = '@dt:2026-10-04T01:30:00Z'      # recordedAt of W14 assertions (service-assigned in production; fixed here)
T_REV = '@dt:2026-10-04T02:00:00Z'      # adjudication reviewedAt
T_REC_OLD = '@dt:2026-10-04T01:20:00Z'  # recordedAt of the superseded extraction
ACT = 'hu:activity:w14-curation-2026-10-04'
ADJ = 'hu:adjudication:w14-capture-fidelity-2026-10-04'
NODEFAULT = object()

def rel_uid(s):
    return 'hu:rel:w14-' + s

# --------------------------------------------------------------------------------------------------------------
def kernel(f, synthetic=False):
    f.node(ACT, ['Activity', 'Occurrence'], occurrenceType='Activity', activityKind='EXTRACTION',
           startedAt='@dt:2026-10-04T00:57:00Z', endedAt='@dt:2026-10-04T01:30:00Z', methodVersion='w14-manual-curation/v1',
           externalRunSystem='claude-code', externalRunId='run-2026-10-04-fable51-01/W14', createdAt=T_REC)
    f.node('hu:agent:w14-opus-5-5', ['Agent', 'Entity'], entityType='Agent', name='W14 worker (Opus 5.5)', agentKind='MANUAL_VALIDATION_OF_AUTOMATED_AGENT',
           model='claude-opus-5-5', createdAt=T_REC)
    f.edge(ACT, 'WAS_ASSOCIATED_WITH', 'hu:agent:w14-opus-5-5')
    f.node(ADJ, ['Adjudication', 'EvidenceAssessment'], assessmentType='Adjudication', adjudicationKind='CAPTURE_FIDELITY', verdict='SUPPORTED',
           reviewerType='AGENT', reviewedAt=T_REV, recordedAt=T_REV, methodVersion='w14-capture-check/v1', status='ACCEPTED', createdAt=T_REV,
           rationale='Each evaluated assertion was compared with the stored excerpt of its locator.')

def source(f, key, uri, title, kind, publisher, retrieved, observed=None, published=None, completeness='PARTIAL_EXCERPT', basis='SYNTHETIC_FIXTURE', chash=None):
    s, sn = 'hu:source:' + key, 'hu:snapshot:' + key
    f.node(s, ['Source', 'Entity'], entityType='Source', canonicalUri=uri, title=title, sourceKind=kind, name=publisher, createdAt=T_REC)
    if chash is None:
        chash = sha(sn)
    f.node(sn, ['SourceSnapshot', 'InformationArtifact'], artifactType='SourceSnapshot', canonicalUri=uri, retrievedAt=retrieved,
           observedAt=observed or retrieved, publishedAt=published, contentHash=chash, contentHashBasis=basis,
           captureCompleteness=completeness, createdAt=T_REC)
    f.edge(s, 'HAS_SNAPSHOT', sn)
    f.edge(sn, 'WAS_GENERATED_BY', ACT)
    return sn

LOC_N = [0]
def locator(f, snap, key, exact=None, kind='TEXT_QUOTE', section=None):
    uid = 'hu:locator:' + key
    p = dict(artifactType='SourceLocator', selectorKind=kind, createdAt=T_REC)
    if exact is not None:
        p.update(exact=exact, quoteHash=sha(nfcws1(exact)), normalizationVersion='NFC-WS1')
    if section: p['section'] = section
    f.node(uid, ['SourceLocator', 'InformationArtifact'], **p)
    f.edge(snap, 'HAS_LOCATOR', uid)
    return uid

def assertion(f, key, predicate, subj, obj=None, asserter=None, loc=None, status='ACCEPTED', recordedAt=T_REC, recordedTo=None,
              vf=None, vfp=None, vfb='UNKNOWN', vt=None, vtp=None, vtb='UNKNOWN', project=True, edge_type=None,
              edge_props_type='asserted', predicateClass='OTHER', assertionBasis='UNSTATED', jurisdiction=None, value=None,
              basisKind=None, derivationRule=None, adjudicate=True, extra=None):
    uid = 'hu:assertion:w14-' + key
    body = '|'.join(str(x) for x in [predicate, subj, obj, value, vf, vt, jurisdiction])
    p = dict(predicate=predicate, status=status, recordedAt=recordedAt, recordedTo=recordedTo, contentHash=sha(body), polarity='POSITIVE',
             predicateClass=predicateClass, assertionBasis=assertionBasis, speechAct='STATES', validFrom=vf, validFromPrecision=vfp,
             validFromBasis=vfb, validTo=vt, validToPrecision=vtp, validToBasis=vtb, jurisdiction=jurisdiction, valueString=value,
             basisKind=basisKind, derivationRule=derivationRule, extractionMethod='manual', createdAt=recordedAt)
    if extra: p.update(extra)
    f.node(uid, ['Assertion'], **p)
    f.edge(uid, 'HAS_SUBJECT', subj)
    if obj: f.edge(uid, 'HAS_OBJECT', obj)
    if asserter: f.edge(uid, 'ASSERTED_BY', asserter)
    if loc: f.edge(uid, 'SUPPORTED_BY', loc)
    f.edge(uid, 'WAS_GENERATED_BY', ACT)
    if adjudicate and status == 'ACCEPTED':
        f.edge(ADJ, 'EVALUATES', uid)
    if project and obj:
        ep = dict(assertionUid=uid, validFrom=vf, validTo=vt, validFromPrecision=vfp, validToPrecision=vtp, validFromBasis=vfb,
                  validToBasis=vtb, recordedFrom=recordedAt, recordedTo=recordedTo)
        f.edge(subj, edge_type or predicate, obj, merge_key=rel_uid(key), **ep)
    return uid

def identifier(f, key, scheme, issuer, value, jurisdiction, norm):
    uid = 'hu:identifier:' + key
    f.node(uid, ['Identifier', 'Entity'], entityType='Identifier', scheme=scheme, issuer=issuer, value=value, jurisdiction=jurisdiction,
           normalizationRule=norm, createdAt=T_REC)
    return uid

def status(f, key, statusKind, jurisdiction, ef=None, et=None, verb=None, scope=None, classes=None, legal=None, proc=None):
    uid = 'hu:ip-status:' + key
    payload = json.dumps(dict(statusKind=statusKind, jurisdiction=jurisdiction, scopeText=scope, niceClasses=classes,
                              legalBasisCitation=legal, proceedingReference=proc, effectiveFrom=ef, effectiveTo=et), sort_keys=True)
    f.node(uid, ['IpRightStatus', 'VersionedState'], stateType='IpRightStatus', payloadHash=sha(payload), statusKind=statusKind,
           jurisdiction=jurisdiction, effectiveFrom=ef, effectiveTo=et, statusTextVerbatim=verb, scopeText=scope, niceClasses=classes,
           legalBasisCitation=legal, proceedingReference=proc, privacyClass='PUBLIC', maturity='CANDIDATE', createdAt=T_REC)
    return uid

def license_(f, key, **p):
    uid = 'hu:patent-license:' + key
    payload = json.dumps({k: p.get(k) for k in sorted(p)}, sort_keys=True, default=str)
    f.node(uid, ['PatentLicense', 'VersionedState'], stateType='PatentLicense', payloadHash=sha(payload), privacyClass='PUBLIC',
           maturity='PROVISIONAL', createdAt=T_REC, **p)
    return uid

def org(f, key, name, legal=True, **p):
    uid = 'hu:org:' + key
    f.node(uid, (['LegalEntity', 'Organization', 'Entity'] if legal else ['Organization', 'Entity']), entityType='Organization', name=name,
           createdAt=T_REC, **p)
    return uid

# ==============================================================================================================
# CORE (real records)
# ==============================================================================================================
core = F('''W14 fixture 1/4: core real records (NEW_RETRIEVAL 2026-10-04). Nicotinamide riboside patent family displayed for
US 8,197,807 B2 (Google Patents), the Dartmouth -> ChromaDex, Inc. exclusive license of 2014-05-16 (SEC exhibit via Justia
mirror), the 2012 agreement with terms not captured, the Federal Circuit 2023 affirmance holding claims 1-3 patent-ineligible,
and the USPTO TSDR record for NIAGEN (serial 85932490, reg. 4606519). Run with run-cypher.mjs: every statement binds its own
nodes by uid; nodes carry primary + archetype labels. Proposed uid tokens (W14-SR-01): patent-family, patent-application,
granted-patent, patent-claim, patent-license, trademark, ip-status. Snapshot hashes: the Google Patents snapshot hashes the
stored Firecrawl markdown (STORED_EXCERPT_TEXT); all other snapshots use SYNTHETIC_FIXTURE (sha256 of the snapshot uid)
because their bytes were not stored; locator quoteHash values are real sha256 over NFC-WS1-normalized excerpts.''')
f = core
kernel(f)

# ---- organizations (W01 types, referenced) ----
DART = org(f, 'trustees-of-dartmouth-college', 'Trustees of Dartmouth College')
CDX_INC = org(f, 'chromadex-inc', 'ChromaDex, Inc.', legalName='ChromaDex Inc.', jurisdiction='US-CA',
              description='Wholly owned subsidiary named in the Niagen Bioscience FY2025 10-K; TSDR owner of NIAGEN (CALIFORNIA corporation).')
NAGE = org(f, 'niagen-bioscience-inc', 'Niagen Bioscience, Inc.', legalName='Niagen Bioscience, Inc.',
           description='SEC registrant CIK 1386570, formerly ChromaDex Corporation (renamed 2025); parent of ChromaDex, Inc.')
GOOG = org(f, 'google-llc', 'Google LLC (Google Patents)', legal=True)
USPTO = org(f, 'uspto', 'United States Patent and Trademark Office', legal=False)
CAFC = org(f, 'us-court-of-appeals-federal-circuit', 'United States Court of Appeals for the Federal Circuit', legal=False)

# ---- materials (W02 types, referenced) ----
NIAGEN = 'hu:material:niagen'
f.node(NIAGEN, ['BrandedIngredientMaterial', 'IngredientMaterial', 'Entity'], entityType='IngredientMaterial', name='Niagen',
       brandName='Niagen', materialKind='BRANDED_INGREDIENT', createdAt=T_REC)
NR = 'hu:substance:nicotinamide-riboside'
f.node(NR, ['ChemicalSubstance', 'Entity'], entityType='ChemicalSubstance', name='nicotinamide riboside', preferredName='nicotinamide riboside', createdAt=T_REC)

# ---- sources ----
gp_hash = 'sha256:fb6766d4786a83b77711494effcf7cf053291e2dbd86f8b152f2877395b2e22d'
SN_GP = source(f, 'google-patents-us8197807b2-2026-10-04', 'https://patents.google.com/patent/US8197807B2/en',
               'US8197807B2 - Nicotinamide riboside kinase compositions and methods for using the same - Google Patents', 'THIRD_PARTY_DIRECTORY',
               'Google LLC', '@dt:2026-10-04T00:57:09Z', completeness='COMPLETE', basis='STORED_EXCERPT_TEXT', chash=gp_hash)
SN_LIC14 = source(f, 'justia-contract-406825-2026-10-04', 'https://contracts.justia.com/companies/chromadex-corp-3165/contract/406825/',
                  'Exclusive Patent License Agreement between Trustees of Dartmouth College and ChromaDex, Inc. (Justia mirror of an SEC exhibit)',
                  'SECURITIES_FILING', 'Justia (mirror); filer ChromaDex Corp.', '@dt:2026-10-04T00:57:36Z')
SN_LIC12 = source(f, 'edgar-online-0001654954-16-003772-ex10-6-2026-10-04',
                  'https://content.edgar-online.com/ExternalLink/EDGAR/0001654954-16-003772.html?hash=dbaa120c152cc5c8548a8e5422aa36ce915f7175ceeb2d60a2895c3a1be4fda1&dest=EX10-6_HTM',
                  'ChromaDex Corp. Form 10-Q received 2016-11-10, Exhibit 10.6 (EDGAR Online mirror)', 'SECURITIES_FILING',
                  'EDGAR Online (mirror); filer ChromaDex Corp.', '@dt:2026-10-04T00:57:43Z', published='@dt:2016-11-10T00:00:00Z')
SN_10K23 = source(f, 'sec-cdxc-10k-fy2023-2026-10-04', 'https://www.sec.gov/Archives/edgar/data/1386570/000162828024009380/cdxc-20231231.htm',
                  'ChromaDex Corporation Form 10-K for fiscal year 2023', 'SECURITIES_FILING', 'ChromaDex Corporation (SEC EDGAR CIK 1386570)',
                  '@dt:2026-10-04T00:58:03Z')
SN_CAFC = source(f, 'cafc-22-1116-opinion-2026-10-04', 'https://www.cafc.uscourts.gov/opinions-orders/22-1116.OPINION.2-13-2023_2079642.pdf',
                 'ChromaDex, Inc. v. Elysium Health, Inc., No. 2022-1116 (Fed. Cir. Feb. 13, 2023), opinion', 'LEGAL_RECORD',
                 'United States Court of Appeals for the Federal Circuit', '@dt:2026-10-04T00:58:20Z', published='@dt:2023-02-13T00:00:00Z')
SN_TSDR = source(f, 'uspto-tsdr-sn85932490-2026-10-04', 'https://tsdr.uspto.gov/statusview/sn85932490', 'TSDR status: NIAGEN, serial 85932490',
                 'REGULATORY_RECORD', 'United States Patent and Trademark Office', '@dt:2026-10-04T00:58:37Z', observed='@dt:2026-10-04T00:58:38Z',
                 completeness='COMPLETE')
SN_R9 = source(f, 'sec-nage-10k-fy2025-r9-2026-10-04', 'https://www.sec.gov/Archives/edgar/data/1386570/000138657026000013/R9.htm',
               'Niagen Bioscience, Inc. 10-K FY2025, XBRL R9 Nature of Business', 'SECURITIES_FILING', 'Niagen Bioscience, Inc. (SEC EDGAR CIK 1386570)',
               '@dt:2026-10-04T00:58:54Z', completeness='COMPLETE')
SN_PR18 = source(f, 'globenewswire-2018-01-22-ptab-2026-10-04',
                 'https://www.globenewswire.com/news-release/2018/01/22/1298324/0/en/elysium-health-inc-challenge-of-chromadex-licensed-patent-denied-by-patent-trial-and-appeal-board-ptab.html',
                 'Elysium Health, Inc. Challenge of ChromaDex Licensed Patent Denied by PTAB (press release, search extract only)', 'PRESS_RELEASE',
                 'ChromaDex Corp. via GlobeNewswire', '@dt:2026-10-04T00:57:30Z', published='@dt:2018-01-22T00:00:00Z', completeness='UNKNOWN')

# ---- locators (exact excerpts) ----
L_GP_FAMILY = locator(f, SN_GP, 'gp-us8197807-worldwide-applications', kind='SECTION', section='Worldwide applications list (2005 CA, AU, JP, EP, WO; 2006 US x2; 2012 US)')
L_GP_EP = locator(f, SN_GP, 'gp-us8197807-ep05722944', 'EP Application number: EP05722944A Filing date: 2005-02-09 Legal status: Withdrawn')
L_GP_US = locator(f, SN_GP, 'gp-us8197807-us11912400', 'US Application number: US11/912,400 Filing date: 2006-04-20 Legal status: Active')
L_GP_GRANT = locator(f, SN_GP, 'gp-us8197807-events', '2012-06-12 Application granted 2012-06-12 Publication of US8197807B2 Status Active 2026-11-19 Adjusted expiration')
L_GP_ASSIGNEE = locator(f, SN_GP, 'gp-us8197807-assignee', 'Inventor Charles M. Brenner Current Assignee The listed assignees may be inaccurate. Google has not performed a legal analysis and makes no representation or warranty as to the accuracy of the list. Dartmouth College')
CLAIMS = {
 1: "A composition comprising isolated nicotinamide riboside in combination with one or more of tryptophan, nicotinic acid, or nicotinamide, wherein said combination is in admixture with a carrier comprising a sugar, starch, cellulose, powdered tragacanth, malt, gelatin, talc, cocoa butter, suppository wax, oil, glycol, polyol, ester, agar, buffering agent, alginic acid, isotonic saline, Ringer's solution, ethyl alcohol, polyester, polycarbonate, or polyanhydride, wherein said composition is formulated for oral administration and increases NAD+ biosynthesis upon oral administration.",
 2: "The composition of claim 1, wherein the nicotinamide riboside is isolated from a natural or synthetic source.",
 3: "The composition of claim 1, wherein the formulation comprises a tablet, troche, capsule, elixir, suspension, syrup, wafer, chewing gum, or food.",
}
L_GP_CLAIM1 = locator(f, SN_GP, 'gp-us8197807-claim-1', '1. ' + CLAIMS[1])
L_LIC14_PARTIES = locator(f, SN_LIC14, 'justia-406825-effective', 'This agreement, effective May 16, 2014, is between the Trustees of Dartmouth College and ChromaDex, Inc.')
L_LIC14_RIGHTS = locator(f, SN_LIC14, 'justia-406825-patent-rights', '"Dartmouth Patent Rights" shall mean United States Patent Nos. 8,197,807, 8,114,626 and 8,383,086, Australian Patent No. 2006238858, Canadian Patent Application Serial No. 2,609,633 filed October 4, 2006, and any Foreign Patents issuing therefrom, and any reissues, reexaminations or extensions thereof.')
L_LIC14_GRANT = locator(f, SN_LIC14, 'justia-406825-grant', 'Dartmouth hereby grants to Company and its Subsidiaries an exclusive, royalty-bearing license under Dartmouth Patent Rights to make, have made, use, and/or sell Licensed Products in the Field in the Territory')
L_LIC12_RIGHTS = locator(f, SN_LIC12, 'edgar-online-ex10-6-rights', '13/260,392, filed September 26, 2011, and United States Patent No.')
L_LIC12_GRANT = locator(f, SN_LIC12, 'edgar-online-ex10-6-grant', 'Dartmouth hereby grants to Company and its Subsidiaries an , royalty-bearing license under Dartmouth Patent Rights to make, have made, use, and/or sell Licensed Products in the Field in the Territory')
L_10K23 = locator(f, SN_10K23, 'cdxc-10k-fy2023-dartmouth', "U.S. Patent Nos. 8,197,807 ('807 Patent) and 8,383,086 ('086 Patent) that comprise compositions containing isolated nicotinamide riboside held by Dartmouth and licensed exclusively to ChromaDex")
L_CAFC = locator(f, SN_CAFC, 'cafc-22-1116-holding', "District Court for the District of Delaware granting Elysium Health, Inc.'s (\"Elysium\") motion for summary judgment that the asserted claims of U.S. Patent No. 8,197,807 (\"the '807 patent\") are directed to unpatentable subject matter under 35 U.S.C. § 101. We affirm. The asserted claims are claims 1-3 of the '807 patent.")
L_TSDR_MARK = locator(f, SN_TSDR, 'tsdr-85932490-header', 'Mark: NIAGEN US Serial Number: 85932490 Application Filing Date: May 15, 2013 US Registration Number: 4606519 Registration Date: Sep. 16, 2014 Register: Principal')
L_TSDR_STATUS = locator(f, SN_TSDR, 'tsdr-85932490-status', 'LIVE/REGISTRATION/Issued and Active The trademark application has been registered with the Office. Status: The registration has been renewed. Status Date: Jul. 24, 2025')
L_TSDR_GOODS = locator(f, SN_TSDR, 'tsdr-85932490-goods', 'For: Phytochemicals for use in the manufacturing of dietary supplements, nutritional products [, pharmaceuticals and cosmetics ] International Class(es): 001 For: Dietary and nutritional supplements International Class(es): 005')
L_TSDR_OWNER = locator(f, SN_TSDR, 'tsdr-85932490-owner', 'Current Owner(s) Information Owner Name: ChromaDex Inc. Legal Entity Type: CORPORATION State or Country Where Organized: CALIFORNIA')
L_TSDR_IR = locator(f, SN_TSDR, 'tsdr-85932490-related-ir', 'International Registration Number: 1336169 International Application(s) /Registration(s) Based on this Property: A0063731/1336169')
L_R9_MARK = locator(f, SN_R9, 'nage-r9-niagen', 'Niagen Bioscience is the innovator behind the NAD+ precursor nicotinamide riboside chloride ("NRC" or "NRCL," commonly referred to as "NR"), commercialized as the flagship ingredient Niagen®, available in both food and pharmaceutical grades.')
L_R9_SUPPLY = locator(f, SN_R9, 'nage-r9-supply', 'supplies these ingredients as raw materials to the manufacturers of consumer products and U.S. FDA-registered 503B outsourcing facilities, respectively.')
L_R9_SUBS = locator(f, SN_R9, 'nage-r9-subsidiaries', 'Niagen Bioscience, Inc. (formerly ChromaDex Corporation) and its wholly owned subsidiaries, ChromaDex, Inc., ChromaDex International, Inc.')
L_PR18 = locator(f, SN_PR18, 'globenewswire-2018-01-22-807', "Patent No. 8,197,807 (\"the '807 patent\"), covering compositions comprising nicotinamide riboside, which ChromaDex currently licenses from the Trustees of Dartmouth College.")

# ---- family, applications, grant, claims ----
FAM = 'hu:patent-family:gp-us8197807-worldwide'
f.node(FAM, ['PatentFamily', 'Entity'], entityType='PatentFamily', familyDefinition='SOURCE_DISPLAYED', familyIdentifier=None,
       title='Nicotinamide riboside kinase compositions and methods for using the same', maturity='PROVISIONAL', createdAt=T_REC,
       description='Worldwide-applications list displayed by Google Patents for US8197807B2 on 2026-10-04 (8 entries; 2 instantiated here).')
APP_US = 'hu:patent-application:us-11912400'
f.node(APP_US, ['PatentApplication', 'InformationArtifact'], artifactType='PatentApplication', applicationNumber='11/912,400', jurisdiction='US',
       officeKey='US:11912400', filingDate='@d:2006-04-20', applicationKind='NATIONAL', publishedAt='@dt:2008-08-28T00:00:00Z',
       observedAt='@dt:2026-10-04T00:57:09Z', title='Nicotinamide riboside kinase compositions and methods for using the same',
       applicantNamesVerbatim=['Dartmouth College'], inventorNamesVerbatim=['Charles M. Brenner'], createdAt=T_REC,
       description='National stage of PCT/US2006/015495 per the description; applicant name as displayed by Google Patents.')
APP_EP = 'hu:patent-application:ep-05722944'
f.node(APP_EP, ['PatentApplication', 'InformationArtifact'], artifactType='PatentApplication', applicationNumber='EP05722944', jurisdiction='EP',
       officeKey='EP:05722944', filingDate='@d:2005-02-09', applicationKind='REGIONAL', observedAt='@dt:2026-10-04T00:57:09Z', createdAt=T_REC)
GR = 'hu:granted-patent:us-8197807'
f.node(GR, ['GrantedPatent', 'InformationArtifact'], artifactType='GrantedPatent', patentNumber='8,197,807', kindCode='B2', jurisdiction='US',
       officeKey='US:8197807', grantDate='@d:2012-06-12', publishedAt='@dt:2012-06-12T00:00:00Z', observedAt='@dt:2026-10-04T00:57:09Z',
       title='Nicotinamide riboside kinase compositions and methods for using the same', inventorNamesVerbatim=['Charles M. Brenner'],
       assigneeNamesVerbatim=None, createdAt=T_REC, description='assigneeNamesVerbatim null: the grant face page was not captured.')
GR86 = 'hu:granted-patent:us-8383086'
f.node(GR86, ['GrantedPatent', 'InformationArtifact'], artifactType='GrantedPatent', patentNumber='8,383,086', jurisdiction='US', officeKey='US:8383086',
       createdAt=T_REC, description='Named in the 2014 license and the FY2023 10-K; its application and family membership were not captured (unknown, not absent).')
APP_1326 = 'hu:patent-application:us-13260392'
f.node(APP_1326, ['PatentApplication', 'InformationArtifact'], artifactType='PatentApplication', applicationNumber='13/260,392', jurisdiction='US',
       officeKey='US:13260392', filingDate='@d:2011-09-26', applicationKind='NATIONAL', createdAt=T_REC)
f.edge(FAM, 'FAMILY_HAS_APPLICATION', APP_US, orderIndex=1, notes='displayed 2006 US entry')
f.edge(FAM, 'FAMILY_HAS_APPLICATION', APP_EP, orderIndex=2, notes='displayed 2005 EP entry (from PCT/US2005/004337 branch)')
CL = {}
for n, text in CLAIMS.items():
    uid = 'hu:patent-claim:us-8197807-c%d' % n
    CL[n] = uid
    f.node(uid, ['PatentClaim', 'InformationArtifact'], artifactType='PatentClaim', claimNumber=n, claimKind='INDEPENDENT' if n == 1 else 'DEPENDENT',
           dependsOnClaimNumbers=[] if n == 1 else [1], claimText=text, claimTextHash=sha(nfcws1(text)), claimTextNormalization='NFC-WS1',
           contentHash=sha(nfcws1(text)), publishedAt='@dt:2012-06-12T00:00:00Z', observedAt='@dt:2026-10-04T00:57:09Z', createdAt=T_REC)
    f.edge(GR, 'HAS_PATENT_CLAIM', uid, orderIndex=n)

f.c('APPLICATION_GRANTED_AS asserted by the aggregator display (Google), not by the USPTO record (not captured).')
assertion(f, 'app-us11912400-granted-as-us8197807', 'APPLICATION_GRANTED_AS', APP_US, GR, GOOG, L_GP_GRANT, vf='@dt:2012-06-12T00:00:00Z',
          vfp='DAY', vfb='STATED_BY_SOURCE', predicateClass='REGULATORY', jurisdiction='US')

# ---- identifiers ----
ids = [
 ('uspto-patent-app-11912400', 'US_PATENT_APPLICATION_NUMBER', 'USPTO', '11912400', 'US', 'digits-only-v1', APP_US, L_GP_US),
 ('epo-app-05722944', 'EP_APPLICATION_NUMBER', 'EPO', '05722944', 'EP', 'ep-strip-prefix-kind-v1', APP_EP, L_GP_EP),
 ('uspto-patent-8197807', 'US_PATENT_NUMBER', 'USPTO', '8197807', 'US', 'digits-only-v1', GR, L_GP_GRANT),
 ('uspto-patent-pub-us20080206221a1', 'US_PATENT_PUBLICATION_NUMBER', 'USPTO', 'US20080206221A1', 'US', 'uppercase-v1', APP_US, L_GP_GRANT),
 ('uspto-tm-serial-85932490', 'USPTO_TM_SERIAL', 'USPTO', '85932490', 'US', 'digits-only-v1', 'hu:trademark:us-sn85932490-niagen', L_TSDR_MARK),
 ('uspto-tm-reg-4606519', 'USPTO_TM_REGISTRATION', 'USPTO', '4606519', 'US', 'digits-only-v1', 'hu:trademark:us-sn85932490-niagen', L_TSDR_MARK),
 ('wipo-madrid-ir-1336169', 'WIPO_MADRID_IR', 'WIPO', '1336169', 'WO', 'digits-only-v1', 'hu:trademark:wo-ir1336169-niagen', L_TSDR_IR),
]
# trademarks first (identifier targets)
TM = 'hu:trademark:us-sn85932490-niagen'
f.node(TM, ['Trademark', 'Entity'], entityType='Trademark', markText='NIAGEN', jurisdiction='US', applicationSerialNumber='85932490',
       registrationNumber='4606519', officeKey='US:85932490', markDrawingKind='STANDARD_CHARACTER', maturity='PROVISIONAL', createdAt=T_REC)
TM_IR = 'hu:trademark:wo-ir1336169-niagen'
f.node(TM_IR, ['Trademark', 'Entity'], entityType='Trademark', markText='NIAGEN', jurisdiction='WO', registrationNumber='1336169',
       officeKey='WO:1336169', maturity='PROVISIONAL', createdAt=T_REC,
       description='Madrid international registration listed on the US TSDR record as based on the US property; its own WIPO record was not retrieved (owner, status and designations unknown).')
for key, scheme, issuer, value, jur, norm, target, loc in ids:
    iu = identifier(f, key, scheme, issuer, value, jur, norm)
    asserter = GOOG if loc in (L_GP_US, L_GP_EP, L_GP_GRANT) else USPTO
    assertion(f, 'id-' + key, 'HAS_IDENTIFIER', target, iu, asserter, loc, predicateClass='IDENTITY', jurisdiction=jur,
              vfb='UNKNOWN', vtb='UNKNOWN', edge_props_type='identifier')
f.c('Identity-collision guard: the same digits under another issuer are a different Identifier and never establish identity.')
identifier(f, 'jpo-patent-8197807-synthetic', 'JP_PATENT_NUMBER', 'JPO', '8197807', 'JP', 'digits-only-v1')

# ---- statuses (bounded states) ----
f.c('F-STATUS-01: aggregator "Active" (patent level) and court "held invalid" (claim level) coexist; neither implies the other.')
ST_G_ACTIVE = status(f, 'us-8197807-in-force-gp', 'GRANTED_IN_FORCE', 'US', ef='@dt:2012-06-12T00:00:00Z', et='@dt:2026-11-19T00:00:00Z',
                     verb='Status Active; Adjusted expiration 2026-11-19')
assertion(f, 'status-us8197807-in-force-gp', 'IP_STATUS_OF', ST_G_ACTIVE, GR, GOOG, L_GP_GRANT, vf='@dt:2012-06-12T00:00:00Z', vfp='DAY',
          vfb='STATED_BY_SOURCE', vt='@dt:2026-11-19T00:00:00Z', vtp='DAY', vtb='STATED_BY_SOURCE', predicateClass='REGULATORY', jurisdiction='US')
ST_G_EXP = status(f, 'us-8197807-expired-calc', 'EXPIRED', 'US', ef='@dt:2026-11-19T00:00:00Z',
                  verb=None, scope='Projected from the displayed adjusted expiration; not an office record.')
assertion(f, 'status-us8197807-expired-calc', 'IP_STATUS_OF', ST_G_EXP, GR, 'hu:agent:w14-opus-5-5', None, vf='@dt:2026-11-19T00:00:00Z', vfp='DAY',
          vfb='INFERRED', predicateClass='REGULATORY', jurisdiction='US', basisKind='CALCULATED',
          derivationRule='ip-term-end/v1: EXPIRED begins at the stated end of the in-force episode', adjudicate=False, status='PROPOSED')
f.stmt("MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-expired-calc'}), (b:Assertion {uid: 'hu:assertion:w14-status-us8197807-in-force-gp'})\nMERGE (a)-[:DERIVED_FROM_ASSERTION]->(b)")
for n in (1, 2, 3):
    st = status(f, 'us-8197807-c%d-held-invalid-cafc' % n, 'CLAIM_HELD_INVALID', 'US', ef='@dt:2023-02-13T00:00:00Z',
                verb='directed to unpatentable subject matter under 35 U.S.C. § 101 ... We affirm.', scope='claim %d of US 8,197,807' % n,
                legal='35 U.S.C. § 101', proc='Fed. Cir. No. 2022-1116 (affirming D. Del. summary judgment; district-court date not captured)')
    assertion(f, 'status-us8197807-c%d-held-invalid' % n, 'IP_STATUS_OF', st, CL[n], CAFC, L_CAFC, vf='@dt:2023-02-13T00:00:00Z', vfp='DAY',
              vfb='STATED_BY_SOURCE', predicateClass='REGULATORY', jurisdiction='US')
ST_EP = status(f, 'ep-05722944-withdrawn-gp', 'WITHDRAWN', 'EP', verb='Legal status: Withdrawn')
assertion(f, 'status-ep05722944-withdrawn', 'IP_STATUS_OF', ST_EP, APP_EP, GOOG, L_GP_EP, vfb='OBSERVATION_ONLY', predicateClass='REGULATORY', jurisdiction='EP')
f.c('Late arrival (TM-R6): renewal of 2025-07-24 first recorded 2026-10-04; observedAt is the TSDR generation instant.')
ST_TM_REG = status(f, 'us-sn85932490-registered', 'REGISTERED', 'US', ef='@dt:2014-09-16T00:00:00Z',
                   verb='REGISTERED-PRINCIPAL REGISTER', scope='Class 001: Phytochemicals for use in the manufacturing of dietary supplements, nutritional products [, pharmaceuticals and cosmetics ]; Class 005: Dietary and nutritional supplements (amendment date of the bracketed deletion not captured)',
                   classes=[1, 5])
assertion(f, 'status-tm-niagen-registered', 'IP_STATUS_OF', ST_TM_REG, TM, USPTO, L_TSDR_MARK, vf='@dt:2014-09-16T00:00:00Z', vfp='DAY',
          vfb='STATED_BY_SOURCE', predicateClass='REGULATORY', jurisdiction='US')
ST_TM_REN = status(f, 'us-sn85932490-renewed-2025', 'RENEWED', 'US', ef='@dt:2025-07-24T00:00:00Z',
                   verb='LIVE/REGISTRATION/Issued and Active; The registration has been renewed.', classes=[1, 5],
                   scope='REGISTERED AND RENEWED (FIRST RENEWAL - 10 YRS); SEC. 8 (10-YR) ACCEPTED/SEC. 9 GRANTED')
assertion(f, 'status-tm-niagen-renewed-2025', 'IP_STATUS_OF', ST_TM_REN, TM, USPTO, L_TSDR_STATUS, vf='@dt:2025-07-24T00:00:00Z', vfp='DAY',
          vfb='STATED_BY_SOURCE', predicateClass='REGULATORY', jurisdiction='US')

# ---- ownership / assignment ----
assertion(f, 'owns-tm-niagen-chromadex-inc', 'OWNS_TRADEMARK', CDX_INC, TM, USPTO, L_TSDR_OWNER, vfb='OBSERVATION_ONLY', predicateClass='COMMERCIAL', jurisdiction='US')
assertion(f, 'assigned-us8197807-dartmouth-10k', 'ASSIGNED_PATENT', DART, GR, NAGE, L_10K23, predicateClass='COMMERCIAL', jurisdiction='US')
assertion(f, 'assigned-us8383086-dartmouth-10k', 'ASSIGNED_PATENT', DART, GR86, NAGE, L_10K23, predicateClass='COMMERCIAL', jurisdiction='US')

# ---- licenses ----
L14 = license_(f, 'dartmouth-chromadex-inc-2014-05-16', agreementTitle='Exclusive Patent License Agreement', effectiveFrom='@dt:2014-05-16T00:00:00Z',
               exclusive=True, exclusivityReportedStatus='REPORTED', fieldOfUse='human and animal therapeutics', fieldOfUseReportedStatus='REPORTED',
               territory='worldwide', territoryJurisdictions=['WORLDWIDE'], territoryReportedStatus='REPORTED', sublicensable=True,
               coverageRuleText='"Dartmouth Patent Rights" shall mean United States Patent Nos. 8,197,807, 8,114,626 and 8,383,086, Australian Patent No. 2006238858, Canadian Patent Application Serial No. 2,609,633 filed October 4, 2006, and any Foreign Patents issuing therefrom, and any reissues, reexaminations or extensions thereof.',
               termText='shall remain in full force during the life of the last to expire patents under Dartmouth Patent Rights contemplated by this agreement in the last to expire territory.')
L12 = license_(f, 'dartmouth-chromadex-inc-2012-07-13', agreementTitle='ChromaDex, Inc. - Dartmouth Exclusive License Agreement (title as indexed)',
               effectiveFrom='@dt:2012-07-13T00:00:00Z', exclusive=None, fieldOfUse=None, territory=None,
               termText='shall remain in full force during the life of the last to expire patents under Dartmouth Patent Rights contemplated by this agreement in the last to expire territory.',
               description='Grant clause, Field and Territory definitions came back empty in the captured mirror (PARTIAL_EXCERPT): redaction vs extraction loss cannot be distinguished, so terms and their reportedStatus stay null (unknown).')
VF14 = dict(vf='@dt:2014-05-16T00:00:00Z', vfp='DAY', vfb='STATED_BY_SOURCE')
VF12 = dict(vf='@dt:2012-07-13T00:00:00Z', vfp='DAY', vfb='STATED_BY_SOURCE')
assertion(f, 'licensee-l2014-chromadex-inc', 'LICENSES_PATENT', CDX_INC, L14, NAGE, L_LIC14_PARTIES, predicateClass='COMMERCIAL', **VF14)
assertion(f, 'licensor-l2014-dartmouth', 'GRANTS_PATENT_LICENSE', DART, L14, NAGE, L_LIC14_PARTIES, predicateClass='COMMERCIAL', **VF14)
assertion(f, 'covers-l2014-us8197807', 'LICENSE_COVERS', L14, GR, NAGE, L_LIC14_RIGHTS, predicateClass='COMMERCIAL', **VF14)
assertion(f, 'covers-l2014-us8383086', 'LICENSE_COVERS', L14, GR86, NAGE, L_LIC14_RIGHTS, predicateClass='COMMERCIAL', **VF14)
assertion(f, 'licensee-l2012-chromadex-inc', 'LICENSES_PATENT', CDX_INC, L12, NAGE, L_LIC12_GRANT, predicateClass='COMMERCIAL', **VF12)
assertion(f, 'licensor-l2012-dartmouth', 'GRANTS_PATENT_LICENSE', DART, L12, NAGE, L_LIC12_GRANT, predicateClass='COMMERCIAL', **VF12)
assertion(f, 'covers-l2012-us13260392', 'LICENSE_COVERS', L12, APP_1326, NAGE, L_LIC12_RIGHTS, predicateClass='COMMERCIAL', **VF12)

# ---- trademark use on a material marketed by another entity ----
f.c('Mark owner (ChromaDex, Inc., TSDR) differs from the asserter/marketer of the branded material (Niagen Bioscience, Inc. group, 10-K).')
assertion(f, 'niagen-marketed-under-mark', 'MARKETED_UNDER_MARK', NIAGEN, TM, NAGE, L_R9_MARK, predicateClass='COMMERCIAL', jurisdiction='US',
          extra={'description': 'Mark resolution to the US registration is by markText + jurisdiction (ResolutionHypothesis in production).'})
assertion(f, 'nage-supplies-niagen', 'SUPPLIES_INGREDIENT_MATERIAL', NAGE, NIAGEN, NAGE, L_R9_SUPPLY, predicateClass='COMMERCIAL',
          extra={'description': "Group-level subject: the filing's 'Company' is the parent with its subsidiaries collectively."})
assertion(f, 'niagen-realizes-nr', 'REALIZES_SUBSTANCE', NIAGEN, NR, NAGE, L_R9_MARK, predicateClass='IDENTITY')
assertion(f, 'chromadex-inc-subsidiary-of-nage', 'SUBSIDIARY_OF', CDX_INC, NAGE, NAGE, L_R9_SUBS, predicateClass='COMMERCIAL')

# ---- what the patent claims (asserted coverage, never efficacy) ----
assertion(f, 'patent-claims-us8197807-nr-pr2018', 'PATENT_CLAIMS', GR, NR, NAGE, L_PR18, predicateClass='OTHER', assertionBasis='MANUFACTURER_CLAIM',
          project=False, extra={'description': "Licensee's press-release characterization ('covering compositions comprising nicotinamide riboside')."})
assertion(f, 'patent-claims-us8197807-c1-nr-curator', 'PATENT_CLAIMS', CL[1], NR, 'hu:agent:w14-opus-5-5', L_GP_CLAIM1, predicateClass='OTHER',
          project=False, extra={'description': 'Curator reading: claim 1 recites isolated nicotinamide riboside in an oral composition. Recitation, not infringement and not efficacy.'})

# ==============================================================================================================
# MINIMAL PAIRS (synthetic; SYNTHETIC_FIXTURE)
# ==============================================================================================================
mp = F('''W14 fixture 2/4: synthetic minimal pairs (SYNTHETIC_FIXTURE; no real organization is involved). Run after w14-ip-core.cypher.
MP-1 family-level license (stated) vs named-member license (core L2014); MP-2 sublicense licensor != assignee;
MP-3 field of use NOT_REPORTED (redacted) vs null/null unknown (core L2012); MP-4 lapsed trademark as bounded state
(VALIDITY_BOUNDED); MP-5 temporal correction of an expiry bound (EXTRACTION_FIX) visible in recorded time; MP-6 two jurisdictions,
one grant, bounded license episode that ended.''')
f = mp
kernel(f)
SU = org(f, 'syn-university', 'Synthetic University')
SA = org(f, 'syn-licensee-a', 'Synthetic Licensee A')
SB = org(f, 'syn-sublicensee-b', 'Synthetic Sublicensee B')
SM = org(f, 'syn-mark-owner', 'Synthetic Mark Owner LLC')
SREG = org(f, 'syn-registry-office', 'Synthetic Patent Office', legal=False)
SN_SYN = source(f, 'syn-ip-dossier-2026-10-04', 'https://example.invalid/w14/syn-ip-dossier', 'Synthetic IP dossier (fixture)', 'LEGAL_RECORD',
                'synthetic', '@dt:2026-10-04T00:00:00Z', completeness='COMPLETE')
LS = locator(f, SN_SYN, 'syn-ip-dossier-whole', kind='WHOLE_SNAPSHOT')
SFAM = 'hu:patent-family:syn-fam-a'
f.node(SFAM, ['PatentFamily', 'Entity'], entityType='PatentFamily', familyDefinition='DOCDB_SIMPLE', familyIdentifier='SYN-000001',
       title='Synthetic composition family A', maturity='PROVISIONAL', createdAt=T_REC)
SA_US = 'hu:patent-application:syn-us-a'
f.node(SA_US, ['PatentApplication', 'InformationArtifact'], artifactType='PatentApplication', applicationNumber='SYN/000,001', jurisdiction='US',
       officeKey='US:SYN000001', filingDate='@d:2015-03-02', applicationKind='NATIONAL', createdAt=T_REC)
SA_EP = 'hu:patent-application:syn-ep-a'
f.node(SA_EP, ['PatentApplication', 'InformationArtifact'], artifactType='PatentApplication', applicationNumber='EPSYN000001', jurisdiction='EP',
       officeKey='EP:SYN000001', filingDate='@d:2016-03-01', applicationKind='REGIONAL', createdAt=T_REC)
SG_US = 'hu:granted-patent:syn-us-a'
f.node(SG_US, ['GrantedPatent', 'InformationArtifact'], artifactType='GrantedPatent', patentNumber='SYN-9,000,001', kindCode='B1', jurisdiction='US',
       officeKey='US:SYN9000001', grantDate='@d:2018-05-01', createdAt=T_REC)
SCL = 'hu:patent-claim:syn-us-a-c1'
sct = 'A synthetic oral composition comprising compound Q and a carrier.'
f.node(SCL, ['PatentClaim', 'InformationArtifact'], artifactType='PatentClaim', claimNumber=1, claimKind='INDEPENDENT', dependsOnClaimNumbers=[],
       claimText=sct, claimTextHash=sha(nfcws1(sct)), claimTextNormalization='NFC-WS1', createdAt=T_REC)
f.edge(SFAM, 'FAMILY_HAS_APPLICATION', SA_US, orderIndex=1)
f.edge(SFAM, 'FAMILY_HAS_APPLICATION', SA_EP, orderIndex=2)
f.edge(SG_US, 'HAS_PATENT_CLAIM', SCL, orderIndex=1)
assertion(f, 'syn-us-a-granted', 'APPLICATION_GRANTED_AS', SA_US, SG_US, SREG, LS, vf='@dt:2018-05-01T00:00:00Z', vfp='DAY', vfb='STATED_BY_SOURCE', predicateClass='REGULATORY', jurisdiction='US')
assertion(f, 'syn-fam-a-assigned-univ', 'ASSIGNED_PATENT', SU, SFAM, SREG, LS, predicateClass='COMMERCIAL')
assertion(f, 'syn-us-a-in-force', 'IP_STATUS_OF', status(f, 'syn-us-a-in-force', 'GRANTED_IN_FORCE', 'US', ef='@dt:2018-05-01T00:00:00Z', et='@dt:2035-03-02T00:00:00Z'),
          SG_US, SREG, LS, vf='@dt:2018-05-01T00:00:00Z', vfp='DAY', vfb='STATED_BY_SOURCE', vt='@dt:2035-03-02T00:00:00Z', vtp='DAY', vtb='STATED_BY_SOURCE',
          predicateClass='REGULATORY', jurisdiction='US')
f.c('MP-1 / MP-6: family-level coverage is stated by the source; field and territory bounded; the license episode ended 2025-01-01.')
LF = license_(f, 'syn-univ-licensee-a-2020', agreementTitle='Synthetic family license', effectiveFrom='@dt:2020-01-01T00:00:00Z', effectiveTo='@dt:2025-01-01T00:00:00Z',
              exclusive=False, exclusivityReportedStatus='REPORTED', fieldOfUse='dietary supplements', fieldOfUseReportedStatus='REPORTED',
              territory='United States', territoryJurisdictions=['US'], territoryReportedStatus='REPORTED', sublicensable=True,
              coverageRuleText='all patents and applications in family SYN-000001')
VFL = dict(vf='@dt:2020-01-01T00:00:00Z', vfp='DAY', vfb='STATED_BY_SOURCE', vt='@dt:2025-01-01T00:00:00Z', vtp='DAY', vtb='STATED_BY_SOURCE')
assertion(f, 'syn-lf-licensee', 'LICENSES_PATENT', SA, LF, SU, LS, predicateClass='COMMERCIAL', **VFL)
assertion(f, 'syn-lf-licensor', 'GRANTS_PATENT_LICENSE', SU, LF, SU, LS, predicateClass='COMMERCIAL', **VFL)
assertion(f, 'syn-lf-covers-family', 'LICENSE_COVERS', LF, SFAM, SU, LS, predicateClass='COMMERCIAL', **VFL)
f.c('MP-2 / MP-3: sublicense granted by the licensee (licensor != assignee); territory redacted in the source -> NOT_REPORTED.')
LSUB = license_(f, 'syn-licensee-a-sublicensee-b-2021', agreementTitle='Synthetic sublicense', effectiveFrom='@dt:2021-03-01T00:00:00Z',
                exclusive=False, exclusivityReportedStatus='REPORTED', fieldOfUse='dietary supplements', fieldOfUseReportedStatus='REPORTED',
                territory=None, territoryReportedStatus='NOT_REPORTED', sublicensable=False, coverageRuleText='[***] (redacted in source)')
VFS = dict(vf='@dt:2021-03-01T00:00:00Z', vfp='DAY', vfb='STATED_BY_SOURCE')
assertion(f, 'syn-lsub-licensee', 'LICENSES_PATENT', SB, LSUB, SA, LS, predicateClass='COMMERCIAL', **VFS)
assertion(f, 'syn-lsub-licensor', 'GRANTS_PATENT_LICENSE', SA, LSUB, SA, LS, predicateClass='COMMERCIAL', **VFS)
assertion(f, 'syn-lsub-covers-family', 'LICENSE_COVERS', LSUB, SFAM, SA, LS, predicateClass='COMMERCIAL', **VFS)
f.c('MP-4: lapsed trademark as bounded state; the REGISTERED episode is closed by VALIDITY_BOUNDED, CANCELLED follows.')
STM = 'hu:trademark:syn-us-examplemark'
f.node(STM, ['Trademark', 'Entity'], entityType='Trademark', markText='EXAMPLEMARK', jurisdiction='US', applicationSerialNumber='SYN90000001',
       registrationNumber='SYN5000001', officeKey='US:SYN90000001', createdAt=T_REC)
assertion(f, 'syn-tm-owner', 'OWNS_TRADEMARK', SM, STM, SREG, LS, vf='@dt:2015-01-06T00:00:00Z', vfp='DAY', vfb='STATED_BY_SOURCE', predicateClass='COMMERCIAL', jurisdiction='US')
S_REG = status(f, 'syn-examplemark-registered', 'REGISTERED', 'US', ef='@dt:2015-01-06T00:00:00Z', classes=[5])
S_CAN = status(f, 'syn-examplemark-cancelled', 'CANCELLED', 'US', ef='@dt:2021-07-06T00:00:00Z', verb='Registration cancelled: Section 8 declaration not filed', classes=[5])
f.c('A1 (recorded 01:20, open end) is bounded by A2 (recorded 01:30, same object and start, end 2021-07-06): TM-R3, V-507b.')
assertion(f, 'syn-tm-registered-open', 'IP_STATUS_OF', S_REG, STM, SREG, LS, status='SUPERSEDED', recordedAt=T_REC_OLD, recordedTo=T_REC,
          vf='@dt:2015-01-06T00:00:00Z', vfp='DAY', vfb='STATED_BY_SOURCE', predicateClass='REGULATORY', jurisdiction='US', adjudicate=False)
assertion(f, 'syn-tm-registered', 'IP_STATUS_OF', S_REG, STM, SREG, LS, vf='@dt:2015-01-06T00:00:00Z', vfp='DAY', vfb='STATED_BY_SOURCE',
          vt='@dt:2021-07-06T00:00:00Z', vtp='DAY', vtb='STATED_BY_SOURCE', predicateClass='REGULATORY', jurisdiction='US')
f.stmt("MATCH (n:Assertion {uid: 'hu:assertion:w14-syn-tm-registered'}), (o:Assertion {uid: 'hu:assertion:w14-syn-tm-registered-open'})\nMERGE (n)-[r:SUPERSEDES]->(o) SET r.supersessionKind = 'VALIDITY_BOUNDED', r.recordedAt = datetime('2026-10-04T01:30:00Z')")
assertion(f, 'syn-tm-cancelled', 'IP_STATUS_OF', S_CAN, STM, SREG, LS, vf='@dt:2021-07-06T00:00:00Z', vfp='DAY', vfb='STATED_BY_SOURCE',
          predicateClass='REGULATORY', jurisdiction='US')
f.c('MP-5: correction in recorded time. v0 (recorded 01:20) bounded the in-force episode at a naive 20-year term 2035-03-02 -> wrong;')
f.c('the corrected assertion (recorded 01:30) carries the stated adjusted expiry 2035-09-30. v0 is SUPERSEDED (EXTRACTION_FIX).')
SG2 = 'hu:granted-patent:syn-us-b'
f.node(SG2, ['GrantedPatent', 'InformationArtifact'], artifactType='GrantedPatent', patentNumber='SYN-9,000,002', jurisdiction='US', officeKey='US:SYN9000002',
       grantDate='@d:2017-01-10', createdAt=T_REC)
S0 = status(f, 'syn-us-b-in-force-v0', 'GRANTED_IN_FORCE', 'US', ef='@dt:2017-01-10T00:00:00Z', et='@dt:2035-03-02T00:00:00Z')
S1 = status(f, 'syn-us-b-in-force-v1', 'GRANTED_IN_FORCE', 'US', ef='@dt:2017-01-10T00:00:00Z', et='@dt:2035-09-30T00:00:00Z', verb='Adjusted expiration 2035-09-30')
assertion(f, 'syn-us-b-in-force-v0', 'IP_STATUS_OF', S0, SG2, 'hu:agent:w14-opus-5-5', LS, status='SUPERSEDED', recordedAt=T_REC_OLD, recordedTo=T_REC,
          vf='@dt:2017-01-10T00:00:00Z', vfp='DAY', vfb='STATED_BY_SOURCE', vt='@dt:2035-03-02T00:00:00Z', vtp='DAY', vtb='INFERRED',
          predicateClass='REGULATORY', jurisdiction='US', adjudicate=False,
          derivationRule='WRONG: naive 20-year term from filing 2015-03-02, ignores patent term adjustment')
assertion(f, 'syn-us-b-in-force-v1', 'IP_STATUS_OF', S1, SG2, SREG, LS, vf='@dt:2017-01-10T00:00:00Z', vfp='DAY', vfb='STATED_BY_SOURCE',
          vt='@dt:2035-09-30T00:00:00Z', vtp='DAY', vtb='STATED_BY_SOURCE', predicateClass='REGULATORY', jurisdiction='US')
f.stmt("MATCH (n:Assertion {uid: 'hu:assertion:w14-syn-us-b-in-force-v1'}), (o:Assertion {uid: 'hu:assertion:w14-syn-us-b-in-force-v0'})\nMERGE (n)-[r:SUPERSEDES]->(o) SET r.supersessionKind = 'EXTRACTION_FIX', r.recordedAt = datetime('2026-10-04T01:30:00Z')")
f.c('Supersession is recorded between the authorizing assertions only; states are never linked by SUPERSEDES (V-507).')

# ==============================================================================================================
# NEGATIVE (expected violations)
# ==============================================================================================================
neg = F('''W14 fixture 3/4: NEGATIVE cases. Each statement block writes a record that a W14 validator must flag. Run after
fixtures 1 and 2. Expected: V-W14-01 (1 row), V-W14-02 (1), V-W14-05 (1), V-W14-07 (1), V-W14-08 (1), V-W14-09 (1), V-W14-12 (1).''')
f = neg
kernel(f)
STUDY = 'hu:study:nct02712593'
f.node(STUDY, ['Study', 'Entity'], entityType='Study', title='Niagen dose-response study registered as NCT02712593 (identity stub; owner W09)', createdAt=T_REC)
f.c('N-1 [LICENSES_PATENT, OWNS_STUDY]: a derived OWNS_STUDY edge whose only input is the license assertion.')
f.stmt("MATCH (o:LegalEntity {uid: 'hu:org:chromadex-inc'}), (s:Study {uid: 'hu:study:nct02712593'})\nMERGE (o)-[r:OWNS_STUDY]->(s)\nSET r.derivationRule = 'BAD: licensee of NR patent owns NR studies', r.derivedFromAssertionUids = ['hu:assertion:w14-licensee-l2014-chromadex-inc'], r.derivedAt = datetime('2026-10-04T01:40:00Z')")
f.c('N-2 [PATENT_CLAIMS, PROVES_EFFICACY]: a CALCULATED efficacy assertion derived from the claim-1 functional limitation.')
assertion(f, 'neg-proves-efficacy', 'PROVES_EFFICACY', NR, None, 'hu:agent:w14-opus-5-5', None, status='PROPOSED', basisKind='CALCULATED',
          derivationRule='BAD: claim says increases NAD+ biosynthesis upon oral administration', value='increases NAD+ biosynthesis', adjudicate=False)
f.stmt("MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-proves-efficacy'}), (b:Assertion {uid: 'hu:assertion:w14-patent-claims-us8197807-c1-nr-curator'})\nMERGE (a)-[:DERIVED_FROM_ASSERTION]->(b)")
f.c('N-3 family membership read as license coverage: LICENSE_COVERS L2014 -> EP application, citing an assertion with another predicate.')
f.stmt("MATCH (l:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2014-05-16'}), (p:PatentApplication {uid: 'hu:patent-application:ep-05722944'})\nMERGE (l)-[r:LICENSE_COVERS {relationshipUid: 'hu:rel:w14-neg-family-coverage'}]->(p)\nSET r.assertionUid = 'hu:assertion:w14-licensee-l2014-chromadex-inc', r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T01:40:00Z')")
f.c('N-4 claim validity read from patent-level status: CLAIM_CONFIRMED derived from the aggregator GRANTED_IN_FORCE assertion.')
NS = status(f, 'neg-us8197807-c1-confirmed', 'CLAIM_CONFIRMED', 'US', ef='@dt:2012-06-12T00:00:00Z')
assertion(f, 'neg-c1-confirmed-from-active', 'IP_STATUS_OF', NS, 'hu:patent-claim:us-8197807-c1', 'hu:agent:w14-opus-5-5', None, status='PROPOSED',
          basisKind='CALCULATED', derivationRule='BAD: patent Active implies claims valid', vf='@dt:2012-06-12T00:00:00Z', vfp='DAY', vfb='INFERRED',
          predicateClass='REGULATORY', jurisdiction='US', adjudicate=False)
f.stmt("MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-c1-confirmed-from-active'}), (b:Assertion {uid: 'hu:assertion:w14-status-us8197807-in-force-gp'})\nMERGE (a)-[:DERIVED_FROM_ASSERTION]->(b)")
f.c('N-5 identity collision: the Madrid IR number (listed as a related property on the US record) attached to the US right.')
assertion(f, 'neg-ir-on-us-right', 'HAS_IDENTIFIER', 'hu:trademark:us-sn85932490-niagen', 'hu:identifier:wipo-madrid-ir-1336169', USPTO,
          'hu:locator:tsdr-85932490-related-ir', status='PROPOSED', predicateClass='IDENTITY', adjudicate=False)
f.c('N-6 legacy status property written on an IP artifact instead of an IpRightStatus episode.')
f.stmt("MATCH (g:GrantedPatent {uid: 'hu:granted-patent:us-8197807'}) SET g.status = 'Active'")
f.c('N-7 [OWNS_TRADEMARK, MARKETS/SUPPLIES]: supplier role derived from mark ownership.')
assertion(f, 'neg-supplies-from-mark', 'SUPPLIES_INGREDIENT_MATERIAL', 'hu:org:chromadex-inc', NIAGEN, 'hu:agent:w14-opus-5-5', None, status='PROPOSED',
          basisKind='CALCULATED', derivationRule='BAD: mark owner supplies the marked material', project=False, adjudicate=False)
f.stmt("MATCH (a:Assertion {uid: 'hu:assertion:w14-neg-supplies-from-mark'}), (b:Assertion {uid: 'hu:assertion:w14-owns-tm-niagen-chromadex-inc'})\nMERGE (a)-[:DERIVED_FROM_ASSERTION]->(b)")

os.makedirs(OUT, exist_ok=True)
for name, fx in [('w14-ip-core.cypher', core), ('w14-ip-minimal-pairs.cypher', mp), ('w14-ip-negative.cypher', neg)]:
    print(name, fx.write(os.path.join(OUT, name)), 'statements')
print('claim hashes:', {n: sha(nfcws1(t)) for n, t in CLAIMS.items()})
