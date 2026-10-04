import sys
sys.path.insert(0, '/tmp/claude-0/-home-user-biotech-meta/c83435a6-8371-518c-961a-6504ccbc2c3e/scratchpad/w01')
from gen_lib import *
OUT = '/home/user/biotech-meta/docs/schema/ontology-lab/final-proposal-team/run-2026-10-04-fable51-01/workers/W01/fixtures/'
ACT = 'hu:activity:w01-curation-2026-10-04'
NAGE = 'hu:org:niagen-bioscience-inc'
SEGT = 'hu:org:segterra'
SINC = 'hu:person:david-a-sinclair'
COMMON_HDR = """Run run-2026-10-04-fable51-01, worker W01 (Opus 5.5). Generated 2026-10-04 by the W01 fixture generator (scratchpad).
Rules: statements separated by ';'; every statement binds its own nodes by uid (no variable crosses ';');
nodes carry the primary label and the archetype label; uids use registered tokens (org, person, brand, facility,
source, snapshot, locator, assertion, adjudication, activity, rel, identifier, product) plus the tokens requested in
W01-SR-01 (org-snapshot, cohort-participant). Snapshots of real pages hash the stored excerpt text
(contentHashBasis STORED_EXCERPT_TEXT: NFC-WS1 over the TEXT_QUOTE exact strings of the snapshot joined by one space);
synthetic sources use SYNTHETIC_FIXTURE. Status ACCEPTED means capture fidelity only (a CAPTURE_FIDELITY
adjudication is attached), never truth. Executed on embedded Neo4j 5.26.31 Community (see 06-fixtures-and-queries.md)."""

def common(f):
    f.c('Shared lineage record for W01 manual curation')
    f.activity(ACT, 'w01-manual-curation-v0')

def sec_proxy(f):
    f.source('hu:source:sec-nage-def14a-2025', 'https://www.sec.gov/Archives/edgar/data/1386570/000162828025020690/cdxc-20250429.htm',
             'SECURITIES_FILING', 'Niagen Bioscience, Inc. definitive proxy statement, 2025 annual meeting')
    ex = ['has been a director of the Company since August 2017',
          'Mr. Robert Fried, who became our Chief Executive Officer in June 2018',
          'Mr. Frank Jaksch, Jr., who transitioned from Executive Chairman to Chairman of the Board in July 2022',
          'Ms. Yu serves as the director nominated by Pioneer Step Holdings Limited pursuant to rights granted to Pioneer Step Holdings Limited pursuant to that certain Securities Purchase Agreement, dated April 26, 2017',
          'Since 2012, Ms. Yu has served as the Chief Digital Officer of Horizons Digital Group Limited (affiliate of Horizons Ventures Limited, a Hong Kong based investment firm)',
          'Pioneer Step Holdings Limited (“Pioneer Step”) beneficially owned and had sole voting and dispositive power with respect to 6,917,783 shares',
          'Niagen Bioscience, Inc. (formerly ChromaDex Corporation), a Delaware corporation']
    f.snapshot('hu:snapshot:sec-nage-def14a-2025-tavily-2026-10-04', 'hu:source:sec-nage-def14a-2025', '2026-10-04T00:56:00Z',
               published='2025-04-29T00:00:00Z', publishedPrec='DAY', excerpts=ex)
    S = 'hu:snapshot:sec-nage-def14a-2025-tavily-2026-10-04'
    f.locator('hu:locator:nage-proxy-2025-yu-since-august-2017', S, exact=ex[0])
    f.locator('hu:locator:nage-proxy-2025-fried-ceo-june-2018', S, exact=ex[1])
    f.locator('hu:locator:nage-proxy-2025-jaksch-transition-july-2022', S, exact=ex[2])
    f.locator('hu:locator:nage-proxy-2025-yu-nominated-by-pioneer-step', S, exact=ex[3])
    f.locator('hu:locator:nage-proxy-2025-yu-horizons-cdo', S, exact=ex[4])
    f.locator('hu:locator:nage-proxy-2025-pioneer-step-beneficial-ownership', S, exact=ex[5])
    f.locator('hu:locator:nage-proxy-2025-formerly-chromadex-delaware', S, exact=ex[6])
    for who in ['wendy-yu', 'robert-fried', 'frank-jaksch-jr', 'steven-rubin']:
        f.locator(f'hu:locator:nage-proxy-2025-nominee-table-{who}', S, kind='SECTION',
                  section=f"Proposal 1 director nominee table (columns Nominee | Age | Director Since), row for {who.replace('-', ' ').title()}")

def sinclair_page(f):
    f.source('hu:source:sinclair-lab-affiliations', 'https://sinclair.hms.harvard.edu/david-sinclairs-affiliations',
             'SELF_DISCLOSURE_PAGE', "David A. Sinclair's Affiliations (The Sinclair Lab)")
    line = 'InsideTracker (Segterra), Cambridge, MA B (2011-2017) I,A,IP (2011-present)'
    legend = 'F=Founder; I=Investor; E=Equity; A=Advisor/Consultant; B=Board of Directors; IP=Inventor on licensed patents; L=Funding for laboratory'
    f.snapshot('hu:snapshot:w01-sinclair-affiliations-2026-10-03-replica', 'hu:source:sinclair-lab-affiliations', '2026-10-03T11:00:00Z',
               excerpts=[line, legend])
    f.snapshot('hu:snapshot:w01-sinclair-affiliations-2026-10-04', 'hu:source:sinclair-lab-affiliations', '2026-10-04T00:58:00Z',
               excerpts=[line, legend])
    f.locator('hu:locator:sinclair-affiliations-2026-10-03-insidetracker-line', 'hu:snapshot:w01-sinclair-affiliations-2026-10-03-replica', exact=line)
    f.locator('hu:locator:sinclair-affiliations-2026-10-04-insidetracker-line', 'hu:snapshot:w01-sinclair-affiliations-2026-10-04', exact=line)
    f.locator('hu:locator:sinclair-affiliations-2026-10-04-legend', 'hu:snapshot:w01-sinclair-affiliations-2026-10-04', exact=legend)
    f.stmt("MATCH (n:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-04-insidetracker-line'}), "
           "(o:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-03-insidetracker-line'})\n"
           "MERGE (n)-[r:REANCHORS]->(o)\nSET r.anchorMatch = 'EXACT', r.activityUid = 'hu:activity:w01-curation-2026-10-04'")

# ------------------------------------------------------------------------------------------------ F1
f = Fx('F1', COMMON_HDR + """
FIXTURE w01-01-role-time-precision: time-bounded board and officer roles at YEAR and MONTH precision (CQ-AX-18,
CQ-CL-05 time part, CQ-TM-04), plus a temporal correction (EXTRACTION_FIX) of a year-precision end bound.
Sources: Niagen Bioscience 2025 DEF 14A (NEW_RETRIEVAL, Tavily extract, PARTIAL_EXCERPT); Sinclair affiliations page
(INHERITED SRC-SINCLAIR-AFFILIATIONS, re-extracted 2026-10-04).""")
common(f)
f.c('Identities'); f.legal(NAGE, 'Niagen Bioscience', legalName='Niagen Bioscience, Inc.', jurisdiction='US-DE', organizationType='COMPANY')
f.legal(SEGT, 'Segterra', jurisdiction=None)
for u, n in [('hu:person:wendy-yu', 'Wendy Yu'), ('hu:person:robert-fried', 'Robert Fried'), ('hu:person:frank-jaksch-jr', 'Frank Jaksch, Jr.'),
             ('hu:person:steven-rubin', 'Steven Rubin'), (SINC, 'David A. Sinclair')]:
    f.person(u, n)
f.c('Sources, snapshots, locators'); sec_proxy(f); sinclair_page(f)
f.c('Role assertions asserted by the issuer in its proxy statement (asserter = the LegalEntity that filed)')
f.assertion('hu:assertion:nage-proxy-2025-yu-director-since-2017', 'BOARD_MEMBER_OF', 'hu:person:wendy-yu', NAGE, NAGE,
            ['hu:locator:nage-proxy-2025-nominee-table-wendy-yu'], ACT, vf=('2017', 'YEAR'), roleTitleVerbatim='Director Since 2017')
f.assertion('hu:assertion:nage-proxy-2025-yu-director-since-aug-2017', 'BOARD_MEMBER_OF', 'hu:person:wendy-yu', NAGE, NAGE,
            ['hu:locator:nage-proxy-2025-yu-since-august-2017'], ACT, vf=('2017-08', 'MONTH'),
            roleTitleVerbatim='has been a director of the Company since August 2017', statedTense='PRESENT')
f.assertion('hu:assertion:nage-proxy-2025-rubin-director-since-2017', 'BOARD_MEMBER_OF', 'hu:person:steven-rubin', NAGE, NAGE,
            ['hu:locator:nage-proxy-2025-nominee-table-steven-rubin'], ACT, vf=('2017', 'YEAR'), roleTitleVerbatim='Director Since 2017')
f.assertion('hu:assertion:nage-proxy-2025-fried-director-since-2015', 'BOARD_MEMBER_OF', 'hu:person:robert-fried', NAGE, NAGE,
            ['hu:locator:nage-proxy-2025-nominee-table-robert-fried'], ACT, vf=('2015', 'YEAR'), roleTitleVerbatim='Director Since 2015')
f.assertion('hu:assertion:nage-proxy-2025-fried-ceo-since-june-2018', 'EMPLOYED_BY', 'hu:person:robert-fried', NAGE, NAGE,
            ['hu:locator:nage-proxy-2025-fried-ceo-june-2018'], ACT, vf=('2018-06', 'MONTH'),
            roleTitleVerbatim='Chief Executive Officer')
f.assertion('hu:assertion:nage-proxy-2025-jaksch-director-since-2000', 'BOARD_MEMBER_OF', 'hu:person:frank-jaksch-jr', NAGE, NAGE,
            ['hu:locator:nage-proxy-2025-nominee-table-frank-jaksch-jr'], ACT, vf=('2000', 'YEAR'), roleTitleVerbatim='Director Since 2000')
f.c('Executive Chairman: an executive qualifier on a board title; employment is not stated, so AFFILIATED_WITH keeps the title (normalization rule R-ROLE-2)')
f.assertion('hu:assertion:nage-proxy-2025-jaksch-executive-chairman-until-july-2022', 'AFFILIATED_WITH', 'hu:person:frank-jaksch-jr', NAGE, NAGE,
            ['hu:locator:nage-proxy-2025-jaksch-transition-july-2022'], ACT, vt=('2022-07', 'MONTH'), roleTitleVerbatim='Executive Chairman')
f.c('Projected role edges (one per ACCEPTED assertion; bounds copied from the assertion)')
f.edge('BOARD_MEMBER_OF', 'hu:assertion:nage-proxy-2025-yu-director-since-2017', 'Person', 'Organization', 'hu:rel:w01-yu-board-nage-year',
       roleType='BOARD_MEMBER', corporateRoleType='DIRECTOR', seniorityLevel='BOARD', roleTitleVerbatim='Director Since 2017')
f.edge('BOARD_MEMBER_OF', 'hu:assertion:nage-proxy-2025-yu-director-since-aug-2017', 'Person', 'Organization', 'hu:rel:w01-yu-board-nage-month',
       roleType='BOARD_MEMBER', corporateRoleType='DIRECTOR', seniorityLevel='BOARD', roleTitleVerbatim='has been a director of the Company since August 2017')
f.edge('BOARD_MEMBER_OF', 'hu:assertion:nage-proxy-2025-rubin-director-since-2017', 'Person', 'Organization', 'hu:rel:w01-rubin-board-nage-year',
       roleType='BOARD_MEMBER', corporateRoleType='DIRECTOR', seniorityLevel='BOARD', roleTitleVerbatim='Director Since 2017')
f.edge('BOARD_MEMBER_OF', 'hu:assertion:nage-proxy-2025-fried-director-since-2015', 'Person', 'Organization', 'hu:rel:w01-fried-board-nage-year',
       roleType='BOARD_MEMBER', corporateRoleType='DIRECTOR', seniorityLevel='BOARD', roleTitleVerbatim='Director Since 2015')
f.edge('EMPLOYED_BY', 'hu:assertion:nage-proxy-2025-fried-ceo-since-june-2018', 'Person', 'Organization', 'hu:rel:w01-fried-ceo-nage',
       roleType='CEO', corporateRoleType='CEO', seniorityLevel='C_SUITE', roleTitleVerbatim='Chief Executive Officer')
f.edge('BOARD_MEMBER_OF', 'hu:assertion:nage-proxy-2025-jaksch-director-since-2000', 'Person', 'Organization', 'hu:rel:w01-jaksch-board-nage-year',
       roleType='BOARD_MEMBER', corporateRoleType='DIRECTOR', seniorityLevel='BOARD', roleTitleVerbatim='Director Since 2000')
f.edge('AFFILIATED_WITH', 'hu:assertion:nage-proxy-2025-jaksch-executive-chairman-until-july-2022', 'Person', 'Organization', 'hu:rel:w01-jaksch-exec-chair-nage',
       roleType='CHAIRPERSON', corporateRoleType='CHAIR', seniorityLevel='BOARD', roleTitleVerbatim='Executive Chairman')
f.c('Temporal correction (late fix of an extraction error): the 0.2.0 reading stored "B (2011-2017)" with validTo 2018-01-01 YEAR,\n'
    '// which under the round 0007 rule means "ended during 2018". The W01 re-extraction stores validTo 2017-01-01 YEAR\n'
    '// ("ended at some instant in 2017") and supersedes the old assertion with EXTRACTION_FIX; the old edge is closed in recorded time.')
f.assertion('hu:assertion:w01-sinclair-board-segterra-legacy-reading', 'BOARD_MEMBER_OF', SINC, SEGT, SINC,
            ['hu:locator:sinclair-affiliations-2026-10-03-insidetracker-line'], ACT, status='SUPERSEDED',
            vf=('2011', 'YEAR'), vt=('2018', 'YEAR'), recordedAt='2026-10-03T12:00:00Z', recordedTo=DT(REC),
            roleTitleVerbatim='B', assertionBasis='PERSONAL_EXPERIENCE')
f.assertion('hu:assertion:w01-sinclair-board-segterra-2011-2017', 'BOARD_MEMBER_OF', SINC, SEGT, SINC,
            ['hu:locator:sinclair-affiliations-2026-10-04-insidetracker-line', 'hu:locator:sinclair-affiliations-2026-10-04-legend'], ACT,
            vf=('2011', 'YEAR'), vt=('2017', 'YEAR'), roleTitleVerbatim='B', assertionBasis='PERSONAL_EXPERIENCE')
f.stmt("MATCH (n:Assertion {uid: 'hu:assertion:w01-sinclair-board-segterra-2011-2017'}), (o:Assertion {uid: 'hu:assertion:w01-sinclair-board-segterra-legacy-reading'})\n"
       f"MERGE (n)-[s:SUPERSEDES]->(o)\nSET s.supersessionKind = 'EXTRACTION_FIX', s.recordedAt = datetime('{REC}')")
f.edge('BOARD_MEMBER_OF', 'hu:assertion:w01-sinclair-board-segterra-legacy-reading', 'Person', 'Organization', 'hu:rel:w01-sinclair-board-segterra-legacy',
       recordedFrom='2026-10-03T12:00:00Z', recordedTo=REC, roleType='BOARD_MEMBER', seniorityLevel='BOARD', roleTitleVerbatim='B')
f.edge('BOARD_MEMBER_OF', 'hu:assertion:w01-sinclair-board-segterra-2011-2017', 'Person', 'Organization', 'hu:rel:w01-sinclair-board-segterra-2011-2017',
       roleType='BOARD_MEMBER', seniorityLevel='BOARD', roleTitleVerbatim='B')
f.write(OUT + 'w01-01-role-time-precision.cypher')

# ------------------------------------------------------------------------------------------------ F2
f = Fx('F2', COMMON_HDR + """
FIXTURE w01-02-advises-not-endorses: an ADVISES_ORGANIZATION assertion and edge with NO ENDORSES_PRODUCT edge
(forbidden implication [ADVISES_ORGANIZATION, ENDORSES_PRODUCT]; V-007, V-112, V-422), the investor-versus-equity
code split (I without E), a brand juxtaposition kept PROPOSED, and the minimal-pair positive: a SYNTHETIC explicit
endorsement assertion that does project ENDORSES_PRODUCT. Load after w01-01 (reuses its sources).""")
common(f)
f.legal(SEGT, 'Segterra'); f.person(SINC, 'David A. Sinclair')
f.brand('hu:brand:insidetracker', 'InsideTracker')
sinclair_page(f)
L = ['hu:locator:sinclair-affiliations-2026-10-04-insidetracker-line', 'hu:locator:sinclair-affiliations-2026-10-04-legend']
f.c('Code A (2011-present): advisor/consultant. Object resolved to the company (Segterra), never to the brand: a brand has no advisors.')
f.assertion('hu:assertion:w01-sinclair-advises-segterra-2011-open', 'ADVISES_ORGANIZATION', SINC, SEGT, SINC, L, ACT,
            vf=('2011', 'YEAR'), roleTitleVerbatim='A', assertionBasis='PERSONAL_EXPERIENCE', statedTense='PRESENT')
f.edge('ADVISES_ORGANIZATION', 'hu:assertion:w01-sinclair-advises-segterra-2011-open', 'Person', 'Organization', 'hu:rel:w01-sinclair-advises-segterra',
       roleType='ADVISOR', seniorityLevel='ADVISOR', roleTitleVerbatim='A')
f.c('Code I without E: INVESTED_IN only; no HOLDS_EQUITY_IN is written (forbidden implication [INVESTED_IN, HOLDS_EQUITY_IN])')
f.assertion('hu:assertion:w01-sinclair-invested-in-segterra-2011-open', 'INVESTED_IN', SINC, SEGT, SINC, L, ACT,
            vf=('2011', 'YEAR'), roleTitleVerbatim='I', assertionBasis='PERSONAL_EXPERIENCE', statedTense='PRESENT')
f.edge('INVESTED_IN', 'hu:assertion:w01-sinclair-invested-in-segterra-2011-open', 'Person', 'Organization', 'hu:rel:w01-sinclair-invested-segterra',
       roleTitleVerbatim='I')
f.c('"InsideTracker (Segterra)" only juxtaposes a brand and a legal name: OWNS_BRAND stays PROPOSED and is NOT projected')
f.assertion('hu:assertion:w01-segterra-owns-insidetracker-brand-proposed', 'OWNS_BRAND', SEGT, 'hu:brand:insidetracker', SINC, L[:1], ACT,
            status='PROPOSED', roleTitleVerbatim='InsideTracker (Segterra)')
f.c('Minimal-pair positive (SYNTHETIC): an explicit endorsement statement by a synthetic person projects ENDORSES_PRODUCT')
f.person('hu:person:w01-synthetic-endorser', 'Synthetic Endorser (fixture only)', fixtureProvenance='SYNTHETIC')
f.product('hu:product:w01-synthetic-blood-test-plan', 'Synthetic blood-testing plan (fixture only)', fixtureProvenance='SYNTHETIC')
f.source('hu:source:w01-synthetic-testimonial-page', 'urn:synthetic:w01:testimonial-page', 'MARKETING_PAGE', 'Synthetic testimonial page (fixture)')
f.snapshot('hu:snapshot:w01-synthetic-testimonial-page', 'hu:source:w01-synthetic-testimonial-page', '2026-10-04T00:59:00Z',
           basis='SYNTHETIC_FIXTURE', completeness='COMPLETE', provenance='SYNTHETIC')
f.locator('hu:locator:w01-synthetic-testimonial-quote', 'hu:snapshot:w01-synthetic-testimonial-page',
          exact='I personally use and recommend the Synthetic blood-testing plan.')
f.assertion('hu:assertion:w01-synthetic-endorser-endorses-plan', 'ENDORSES_PRODUCT', 'hu:person:w01-synthetic-endorser',
            'hu:product:w01-synthetic-blood-test-plan', 'hu:person:w01-synthetic-endorser', ['hu:locator:w01-synthetic-testimonial-quote'], ACT,
            assertionBasis='PERSONAL_EXPERIENCE', speechAct='RECOMMENDS', fixtureProvenance='SYNTHETIC')
f.edge('ENDORSES_PRODUCT', 'hu:assertion:w01-synthetic-endorser-endorses-plan', 'Person', 'Product', 'hu:rel:w01-synthetic-endorser-endorses-plan')
f.write(OUT + 'w01-02-advises-not-endorses.cypher')

# ------------------------------------------------------------------------------------------------ F3
f = Fx('F3', COMMON_HDR + """
FIXTURE w01-03-brand-vs-legal-entity: brand versus legal entity minimal pair and the similar-name pair
(ChromaDex Corporation = former legal name of Niagen Bioscience, Inc. versus ChromaDex, Inc., its wholly owned
subsidiary and the registrant of the TRU NIAGEN mark). Legal name and ticker are OrganizationSnapshot state
attached by HAS_STATE episodes (CQ-EC-02, CQ-EC-C01). Sources: Niagen FY2025 10-K (INHERITED SRC-SEC-NAGE-10K-FY2025,
new excerpt via search extract), name-change press release (NEW, search extract), Trademarkia record of USPTO data
(NEW, third-party aggregator; USPTO TSDR itself BLOCKED/JS-only). Load after w01-01.""")
common(f)
f.legal(NAGE, 'Niagen Bioscience', legalName='Niagen Bioscience, Inc.', canonicalTicker='NAGE', currentAsOf=DT(REC), jurisdiction='US-DE', organizationType='COMPANY')
f.legal('hu:org:chromadex-inc', 'ChromaDex, Inc.', legalName='ChromaDex, Inc.', organizationType='COMPANY')
f.brand('hu:brand:tru-niagen', 'Tru Niagen')
f.source('hu:source:sec-nage-10k-fy2025', 'https://www.sec.gov/Archives/edgar/data/1386570/000138657026000013/cdxc-20251231.htm',
         'SECURITIES_FILING', 'Niagen Bioscience, Inc. Form 10-K for fiscal year 2025')
k1 = 'Effective March 19, 2025, the Company changed its name to “Niagen Bioscience, Inc.”. In connection with the Company’s new name, the Company changed the ticker symbol for the Company’s common stock on Nasdaq, to “NAGE”.'
k2 = 'Niagen Bioscience, Inc. (formerly ChromaDex Corporation) and its wholly owned subsidiaries, ChromaDex, Inc., ChromaDex International, Inc., ChromaDex Analytics, Inc., ChromaDex Asia Limited, Asia Pacific Scientific, Inc., ChromaDex Asia Pacific Ventures Limited, ChromaDex Europa B.V., and ChromaDex Trading (Shanghai) Co., Ltd.'
f.snapshot('hu:snapshot:sec-nage-10k-fy2025-tavily-2026-10-04', 'hu:source:sec-nage-10k-fy2025', '2026-10-04T00:57:00Z', excerpts=[k1, k2])
f.locator('hu:locator:nage-10k-fy2025-name-change', 'hu:snapshot:sec-nage-10k-fy2025-tavily-2026-10-04', exact=k1)
f.locator('hu:locator:nage-10k-fy2025-wholly-owned-subsidiaries', 'hu:snapshot:sec-nage-10k-fy2025-tavily-2026-10-04', exact=k2)
f.source('hu:source:nage-pr-name-change-2025', 'https://investors.niagenbioscience.com/news/news-details/2025/ChromaDex-Corp--Announces-Name-Change-to-Niagen-Bioscience-Inc--and-New-Ticker-Symbol-NAGE-Effective-March-19-2025/default.aspx',
         'PRESS_RELEASE', 'ChromaDex Corp. Announces Name Change to Niagen Bioscience, Inc. and New Ticker Symbol "NAGE" Effective March 19, 2025')
p1 = 'ChromaDex Corp. (NASDAQ:CDXC)'
p2 = 'Niagen® is the active ingredient in ChromaDex’s consumer products, sold as the brand Tru Niagen®'
f.snapshot('hu:snapshot:nage-pr-name-change-2025-tavily-2026-10-04', 'hu:source:nage-pr-name-change-2025', '2026-10-04T00:57:30Z', excerpts=[p1, p2])
f.locator('hu:locator:nage-pr-2025-old-ticker', 'hu:snapshot:nage-pr-name-change-2025-tavily-2026-10-04', exact=p1)
f.locator('hu:locator:nage-pr-2025-sold-as-brand', 'hu:snapshot:nage-pr-name-change-2025-tavily-2026-10-04', exact=p2)
f.source('hu:source:trademarkia-tru-niagen-87497901', 'https://www.trademarkia.com/tru-niagen-87497901', 'THIRD_PARTY_DIRECTORY',
         'TRU NIAGEN Trademark (Trademarkia rendering of USPTO serial 87497901)')
t1 = 'TRU NIAGEN is a registered trademark (Registration #5370103) owned by ChromaDex Inc., a Irvine based entity located in CA.'
f.snapshot('hu:snapshot:trademarkia-tru-niagen-2026-10-04', 'hu:source:trademarkia-tru-niagen-87497901', '2026-10-04T00:58:30Z', excerpts=[t1])
f.locator('hu:locator:trademarkia-tru-niagen-owner', 'hu:snapshot:trademarkia-tru-niagen-2026-10-04', exact=t1)
f.c('Legal-name and ticker state: two OrganizationSnapshot payloads attached to the SAME LegalEntity (identity survives the rename)')
f.node(['OrganizationSnapshot', 'VersionedState'], 'hu:org-snapshot:niagen-legal-name-chromadex-corporation', ('stateType', 'LEGAL_NAME_AND_TICKER'),
       name='ChromaDex Corporation (legal name state)', legalName='ChromaDex Corporation', canonicalTicker='CDXC',
       payloadHash=sha(nfcws('legalName=ChromaDex Corporation;canonicalTicker=CDXC')), effectiveTo=DT('2025-03-19T00:00:00Z'),
       validTo=DT('2025-03-19T00:00:00Z'), recordedFrom=DT(REC),
       assertionUids=['hu:assertion:w01-nage-state-chromadex-corporation'])
f.node(['OrganizationSnapshot', 'VersionedState'], 'hu:org-snapshot:niagen-legal-name-niagen-bioscience-inc', ('stateType', 'LEGAL_NAME_AND_TICKER'),
       name='Niagen Bioscience, Inc. (legal name state)', legalName='Niagen Bioscience, Inc.', canonicalTicker='NAGE',
       payloadHash=sha(nfcws('legalName=Niagen Bioscience, Inc.;canonicalTicker=NAGE')), effectiveFrom=DT('2025-03-19T00:00:00Z'),
       validFrom=DT('2025-03-19T00:00:00Z'), recordedFrom=DT(REC),
       assertionUids=['hu:assertion:w01-nage-state-niagen-bioscience-inc'])
f.assertion('hu:assertion:w01-nage-state-chromadex-corporation', 'HAS_STATE', NAGE, 'hu:org-snapshot:niagen-legal-name-chromadex-corporation', NAGE,
            ['hu:locator:nage-10k-fy2025-name-change', 'hu:locator:nage-10k-fy2025-wholly-owned-subsidiaries', 'hu:locator:nage-pr-2025-old-ticker'], ACT,
            vt=('2025-03-19', 'DAY'), predicateClass='IDENTITY')
f.assertion('hu:assertion:w01-nage-state-niagen-bioscience-inc', 'HAS_STATE', NAGE, 'hu:org-snapshot:niagen-legal-name-niagen-bioscience-inc', NAGE,
            ['hu:locator:nage-10k-fy2025-name-change'], ACT, vf=('2025-03-19', 'DAY'), predicateClass='IDENTITY')
f.edge('HAS_STATE', 'hu:assertion:w01-nage-state-chromadex-corporation', 'LegalEntity', 'OrganizationSnapshot', 'hu:rel:w01-nage-state-chromadex-corporation')
f.edge('HAS_STATE', 'hu:assertion:w01-nage-state-niagen-bioscience-inc', 'LegalEntity', 'OrganizationSnapshot', 'hu:rel:w01-nage-state-niagen-bioscience-inc')
f.c('Identifier: SEC CIK 1386570 (from the EDGAR archive path of both filings) identifies the registrant across the rename')
f.node(['Identifier', 'Entity'], 'hu:identifier:sec-cik-1386570', ('entityType', 'Identifier'), scheme='SEC_CIK', issuer='US-SEC', value='1386570')
f.assertion('hu:assertion:w01-nage-has-cik-1386570', 'HAS_IDENTIFIER', NAGE, 'hu:identifier:sec-cik-1386570', NAGE,
            ['hu:locator:nage-10k-fy2025-name-change'], ACT, predicateClass='IDENTITY')
f.edge('HAS_IDENTIFIER', 'hu:assertion:w01-nage-has-cik-1386570', 'LegalEntity', 'Identifier', 'hu:rel:w01-nage-has-cik', isPrimary=True)
f.c('Control: the parent states ChromaDex, Inc. is a wholly owned subsidiary -> PARENT_OF (stakePercent left null: "wholly owned" kept verbatim)')
f.assertion('hu:assertion:w01-nage-parent-of-chromadex-inc', 'PARENT_OF', NAGE, 'hu:org:chromadex-inc', NAGE,
            ['hu:locator:nage-10k-fy2025-wholly-owned-subsidiaries'], ACT, roleTitleVerbatim='its wholly owned subsidiaries, ChromaDex, Inc.')
f.edge('PARENT_OF', 'hu:assertion:w01-nage-parent-of-chromadex-inc', 'LegalEntity', 'LegalEntity', 'hu:rel:w01-nage-parent-of-chromadex-inc',
       stakeClassVerbatim='wholly owned subsidiary', roleTitleVerbatim='its wholly owned subsidiaries, ChromaDex, Inc.')
f.c('Brand: the parent calls Tru Niagen the brand of "ChromaDex\'s consumer products" (group-level wording); the mark registrant is the\n'
    '// subsidiary. Neither statement says who owns the brand, so both OWNS_BRAND readings stay PROPOSED (no projected edge):\n'
    '// [GROUP_LEVEL_ROLE, MEMBER_COMPANY_ROLE] and INV-009.')
f.assertion('hu:assertion:w01-nage-owns-tru-niagen-brand-proposed', 'OWNS_BRAND', NAGE, 'hu:brand:tru-niagen', NAGE,
            ['hu:locator:nage-pr-2025-sold-as-brand'], ACT, status='PROPOSED', roleTitleVerbatim='ChromaDex’s consumer products, sold as the brand Tru Niagen®')
f.assertion('hu:assertion:w01-chromadex-inc-owns-tru-niagen-brand-proposed', 'OWNS_BRAND', 'hu:org:chromadex-inc', 'hu:brand:tru-niagen', None,
            ['hu:locator:trademarkia-tru-niagen-owner'], ACT, status='PROPOSED', roleTitleVerbatim='registered trademark (Registration #5370103) owned by ChromaDex Inc.')
f.write(OUT + 'w01-03-brand-vs-legal-entity.cypher')

# ------------------------------------------------------------------------------------------------ F4
f = Fx('F4', COMMON_HDR + """
FIXTURE w01-04-investor-vs-parent: investor/equity holder versus controlling parent minimal pair (CQ-EC-01,
CQ-EC-C02). Pioneer Step holds Niagen common stock and has a director-nomination right; it is NOT Niagen's parent.
Niagen is the parent of ChromaDex, Inc. (w01-03). Affiliate-of between two Horizons companies stays AFFILIATED_WITH,
never PARENT_OF. Load after w01-01 and w01-03.""")
common(f)
f.legal(NAGE, 'Niagen Bioscience'); f.person('hu:person:wendy-yu', 'Wendy Yu')
f.legal('hu:org:pioneer-step-holdings-limited', 'Pioneer Step Holdings Limited', legalName='Pioneer Step Holdings Limited')
f.legal('hu:org:horizons-digital-group-limited', 'Horizons Digital Group Limited', legalName='Horizons Digital Group Limited')
f.legal('hu:org:horizons-ventures-limited', 'Horizons Ventures Limited', legalName='Horizons Ventures Limited', organizationType='VENTURE_CAPITAL_FIRM')
f.c('Equity stake as of a stated date (13D/A of 2024-08-20 relayed by the proxy): the source gives a point-in-time holding, which the kernel\n'
    '// cannot store as a witness instant (W01-SR-07); both bounds stay null/UNKNOWN. No stakePercent is written (not stated in the excerpt).')
f.assertion('hu:assertion:nage-proxy-2025-pioneer-step-equity', 'HOLDS_EQUITY_IN', 'hu:org:pioneer-step-holdings-limited', NAGE, NAGE,
            ['hu:locator:nage-proxy-2025-pioneer-step-beneficial-ownership'], ACT,
            roleTitleVerbatim='beneficially owned and had sole voting and dispositive power with respect to 6,917,783 shares (Schedule 13D/A filed 2024-08-20)')
f.edge('HOLDS_EQUITY_IN', 'hu:assertion:nage-proxy-2025-pioneer-step-equity', 'Organization', 'Organization', 'hu:rel:w01-pioneer-step-equity-nage',
       stakeClassVerbatim='6,917,783 shares of common stock; sole voting and dispositive power', roleTitleVerbatim='beneficially owned and had sole voting and dispositive power with respect to 6,917,783 shares (Schedule 13D/A filed 2024-08-20)')
f.c('Nomination right: the director is the investor\'s nominee. That is a tie (AFFILIATED_WITH), not control and not employment.')
f.assertion('hu:assertion:nage-proxy-2025-yu-nominee-of-pioneer-step', 'AFFILIATED_WITH', 'hu:person:wendy-yu', 'hu:org:pioneer-step-holdings-limited', NAGE,
            ['hu:locator:nage-proxy-2025-yu-nominated-by-pioneer-step'], ACT, roleTitleVerbatim='the director nominated by Pioneer Step Holdings Limited',
            statedTense='PRESENT')
f.edge('AFFILIATED_WITH', 'hu:assertion:nage-proxy-2025-yu-nominee-of-pioneer-step', 'Person', 'Organization', 'hu:rel:w01-yu-nominee-pioneer-step',
       roleTitleVerbatim='the director nominated by Pioneer Step Holdings Limited')
f.assertion('hu:assertion:nage-proxy-2025-yu-cdo-horizons-digital', 'EMPLOYED_BY', 'hu:person:wendy-yu', 'hu:org:horizons-digital-group-limited', NAGE,
            ['hu:locator:nage-proxy-2025-yu-horizons-cdo'], ACT, vf=('2012', 'YEAR'), roleTitleVerbatim='Chief Digital Officer', statedTense='PRESENT')
f.edge('EMPLOYED_BY', 'hu:assertion:nage-proxy-2025-yu-cdo-horizons-digital', 'Person', 'Organization', 'hu:rel:w01-yu-cdo-horizons-digital',
       seniorityLevel='C_SUITE', roleTitleVerbatim='Chief Digital Officer')
f.assertion('hu:assertion:nage-proxy-2025-horizons-digital-affiliate-of-horizons-ventures', 'AFFILIATED_WITH', 'hu:org:horizons-digital-group-limited',
            'hu:org:horizons-ventures-limited', NAGE, ['hu:locator:nage-proxy-2025-yu-horizons-cdo'], ACT, roleTitleVerbatim='affiliate of Horizons Ventures Limited')
f.edge('AFFILIATED_WITH', 'hu:assertion:nage-proxy-2025-horizons-digital-affiliate-of-horizons-ventures', 'Organization', 'Organization',
       'hu:rel:w01-horizons-digital-affiliate-horizons-ventures', roleTitleVerbatim='affiliate of Horizons Ventures Limited')
f.write(OUT + 'w01-04-investor-vs-parent.cypher')

# ------------------------------------------------------------------------------------------------ F5
f = Fx('F5', COMMON_HDR + """
FIXTURE w01-05-facility-label-roles (SYNTHETIC): label 'Distributed by' versus manufacturer, label place of business
versus manufacturing Facility (21 CFR 101.5(b),(c),(e)), brand owned by a legal entity (projected OWNS_BRAND),
contract manufacturer operating a plant (CQ-MF-01). Every node and source here is synthetic.""")
common(f)
BO = 'hu:org:w01-synthetic-brand-owner-llc'; CMO = 'hu:org:w01-synthetic-cmo-inc'; PR = 'hu:product:w01-synthetic-sleepwell-capsules'
f.legal(BO, 'Synthetic Brand Owner LLC', legalName='Synthetic Brand Owner LLC', fixtureProvenance='SYNTHETIC')
f.legal(CMO, 'Synthetic Contract Manufacturing Inc.', legalName='Synthetic Contract Manufacturing Inc.', organizationType='CONTRACT_DEVELOPMENT_AND_MANUFACTURING_ORGANIZATION', fixtureProvenance='SYNTHETIC')
f.brand('hu:brand:w01-synthetic-sleepwell', 'SleepWell (synthetic)', fixtureProvenance='SYNTHETIC')
f.product(PR, 'SleepWell capsules (synthetic)', fixtureProvenance='SYNTHETIC')
f.facility('hu:facility:w01-synthetic-brand-owner-office', 'Synthetic Brand Owner office', facilityKind='CORPORATE_OFFICE',
           addressText='100 Example Ave', city='Austin', region='TX', country='US', postalCode='78701', fixtureProvenance='SYNTHETIC')
f.facility('hu:facility:w01-synthetic-cmo-plant', 'Synthetic CMO capsule plant', facilityKind='MANUFACTURING_SITE',
           addressText='1 Synthetic Way', city='Ogden', region='UT', country='US', fixtureProvenance='SYNTHETIC')
f.source('hu:source:w01-synthetic-sleepwell-label', 'urn:synthetic:w01:sleepwell-label', 'MANUFACTURER_LABEL_PAGE', 'Synthetic SleepWell label')
f.snapshot('hu:snapshot:w01-synthetic-sleepwell-label', 'hu:source:w01-synthetic-sleepwell-label', '2026-10-04T00:59:00Z', basis='SYNTHETIC_FIXTURE',
           completeness='COMPLETE', provenance='SYNTHETIC')
f.locator('hu:locator:w01-synthetic-label-distributed-by', 'hu:snapshot:w01-synthetic-sleepwell-label',
          exact='Distributed by: Synthetic Brand Owner LLC, 100 Example Ave, Austin, TX 78701')
f.locator('hu:locator:w01-synthetic-label-brand-mark', 'hu:snapshot:w01-synthetic-sleepwell-label', exact='SleepWell™ is a trademark of Synthetic Brand Owner LLC.')
f.source('hu:source:w01-synthetic-cmo-site-page', 'urn:synthetic:w01:cmo-site', 'ORGANIZATION_WEBPAGE', 'Synthetic CMO facility page')
f.snapshot('hu:snapshot:w01-synthetic-cmo-site-page', 'hu:source:w01-synthetic-cmo-site-page', '2026-10-04T00:59:00Z', basis='SYNTHETIC_FIXTURE',
           completeness='COMPLETE', provenance='SYNTHETIC')
f.locator('hu:locator:w01-synthetic-cmo-encapsulates-sleepwell', 'hu:snapshot:w01-synthetic-cmo-site-page',
          exact='At our Ogden, Utah plant we encapsulate SleepWell capsules for Synthetic Brand Owner LLC under contract since March 2024.')
f.assertion('hu:assertion:w01-synth-bo-distributes-sleepwell', 'DISTRIBUTES_PRODUCT', BO, PR, BO, ['hu:locator:w01-synthetic-label-distributed-by'], ACT,
            roleTitleVerbatim='Distributed by', fixtureProvenance='SYNTHETIC')
f.edge('DISTRIBUTES_PRODUCT', 'hu:assertion:w01-synth-bo-distributes-sleepwell', 'Organization', 'Product', 'hu:rel:w01-synth-bo-distributes-sleepwell',
       roleType='DISTRIBUTOR', roleTitleVerbatim='Distributed by')
f.assertion('hu:assertion:w01-synth-bo-owns-sleepwell-brand', 'OWNS_BRAND', BO, 'hu:brand:w01-synthetic-sleepwell', BO, ['hu:locator:w01-synthetic-label-brand-mark'], ACT,
            roleTitleVerbatim='is a trademark of', fixtureProvenance='SYNTHETIC')
f.edge('OWNS_BRAND', 'hu:assertion:w01-synth-bo-owns-sleepwell-brand', 'Organization', 'ConsumerBrand', 'hu:rel:w01-synth-bo-owns-sleepwell-brand')
f.assertion('hu:assertion:w01-synth-bo-place-of-business', 'OPERATES_FACILITY', BO, 'hu:facility:w01-synthetic-brand-owner-office', BO,
            ['hu:locator:w01-synthetic-label-distributed-by'], ACT, roleTitleVerbatim='label place of business', fixtureProvenance='SYNTHETIC')
f.edge('OPERATES_FACILITY', 'hu:assertion:w01-synth-bo-place-of-business', 'Organization', 'Facility', 'hu:rel:w01-synth-bo-operates-office',
       roleTitleVerbatim='label place of business')
f.assertion('hu:assertion:w01-synth-cmo-manufactures-sleepwell', 'MANUFACTURES_PRODUCT', CMO, PR, CMO, ['hu:locator:w01-synthetic-cmo-encapsulates-sleepwell'], ACT,
            vf=('2024-03', 'MONTH'), roleTitleVerbatim='we encapsulate', fixtureProvenance='SYNTHETIC')
f.edge('MANUFACTURES_PRODUCT', 'hu:assertion:w01-synth-cmo-manufactures-sleepwell', 'Organization', 'Product', 'hu:rel:w01-synth-cmo-manufactures-sleepwell',
       roleType='MANUFACTURER', roleTitleVerbatim='we encapsulate')
f.assertion('hu:assertion:w01-synth-cmo-contract-manufactures-for-bo', 'CONTRACT_MANUFACTURES_FOR', CMO, BO, CMO, ['hu:locator:w01-synthetic-cmo-encapsulates-sleepwell'], ACT,
            vf=('2024-03', 'MONTH'), roleTitleVerbatim='under contract', fixtureProvenance='SYNTHETIC')
f.edge('CONTRACT_MANUFACTURES_FOR', 'hu:assertion:w01-synth-cmo-contract-manufactures-for-bo', 'Organization', 'Organization', 'hu:rel:w01-synth-cmo-for-bo',
       roleTitleVerbatim='under contract')
f.assertion('hu:assertion:w01-synth-cmo-operates-ogden-plant', 'OPERATES_FACILITY', CMO, 'hu:facility:w01-synthetic-cmo-plant', CMO,
            ['hu:locator:w01-synthetic-cmo-encapsulates-sleepwell'], ACT, roleTitleVerbatim='our Ogden, Utah plant', fixtureProvenance='SYNTHETIC')
f.edge('OPERATES_FACILITY', 'hu:assertion:w01-synth-cmo-operates-ogden-plant', 'Organization', 'Facility', 'hu:rel:w01-synth-cmo-operates-plant',
       facilityRole='MANUFACTURING_SITE', roleTitleVerbatim='our Ogden, Utah plant')
f.write(OUT + 'w01-05-facility-label-roles.cypher')

# ------------------------------------------------------------------------------------------------ F6
f = Fx('F6', COMMON_HDR + """
FIXTURE w01-06-cohort-participant-identity (SYNTHETIC): two public datasets each publish a participant token 'P03'.
Same scheme and value across two issuers does not establish identity (identity_resolution forbidden implication
[SHARED_IDENTIFIER_SCHEME_VALUE_ACROSS_ISSUERS, SAME_IDENTITY]); no Person is linked to either participant.""")
common(f)
for k in ['a', 'b']:
    src = f'hu:source:w01-synthetic-public-dataset-{k}'
    f.source(src, f'urn:synthetic:w01:public-dataset-{k}', 'PEER_REVIEWED_PUBLICATION', f'Synthetic public dataset {k.upper()}')
    f.snapshot(f'hu:snapshot:w01-synthetic-public-dataset-{k}', src, '2026-10-04T00:59:00Z', basis='SYNTHETIC_FIXTURE', completeness='COMPLETE', provenance='SYNTHETIC')
    f.locator(f'hu:locator:w01-synthetic-dataset-{k}-p03', f'hu:snapshot:w01-synthetic-public-dataset-{k}', exact=f'Participant P03 (dataset {k.upper()}) reported improved sleep latency.')
    cp = f'hu:cohort-participant:w01-synthetic-dataset-{k}-p03'
    f.node(['CohortParticipant', 'PseudonymousActor', 'Entity'], cp, ('entityType', 'CohortParticipant'), name=f'Participant P03 of dataset {k.upper()}',
           participantToken='P03', fixtureProvenance='SYNTHETIC')
    idu = f'hu:identifier:w01-participant-token-dataset-{k}-p03'
    f.node(['Identifier', 'Entity'], idu, ('entityType', 'Identifier'), scheme='PARTICIPANT_TOKEN', issuer=src, value='P03')
    f.assertion(f'hu:assertion:w01-dataset-{k}-p03-token', 'HAS_IDENTIFIER', cp, idu, None, [f'hu:locator:w01-synthetic-dataset-{k}-p03'], ACT,
                predicateClass='IDENTITY', fixtureProvenance='SYNTHETIC')
    f.edge('HAS_IDENTIFIER', f'hu:assertion:w01-dataset-{k}-p03-token', 'CohortParticipant', 'Identifier', f'hu:rel:w01-dataset-{k}-p03-token', isPrimary=True)
f.write(OUT + 'w01-06-cohort-participant-identity.cypher')

# ------------------------------------------------------------------------------------------------ F90 negatives
f = Fx('F90', COMMON_HDR + """
NEGATIVE FIXTURE w01-90-negative-forbidden-implications: load ONLY after w01-01..w01-06 into a scratch database.
Each block writes one violation; the expected violation ids are listed in 06-fixtures-and-queries.md section 4.
N1 ENDORSES_PRODUCT projected from an ADVISES_ORGANIZATION assertion (V-007, V-112, V-422, V-W01-02).
N2 HOLDS_EQUITY_IN projected from an INVESTED_IN assertion (V-112 FORBIDDEN_IMPLICATION_USED_AS_PREMISE, V-W01-02).
N3 PARENT_OF projected from a HOLDS_EQUITY_IN assertion (V-W01-02; V-112 once candidate pair [HOLDS_EQUITY_IN, PARENT_OF] is registered).
N4 BOARD_MEMBER_OF targeting a ConsumerBrand (V-W01-01; note V-434 does not see it).
N5 a node labelled ConsumerBrand and LegalEntity (V-433, V-W01-03).
N6 MANUFACTURES_PRODUCT projected from a DISTRIBUTES_PRODUCT assertion (V-112, V-W01-02).
N7 a Facility with facilityKind VIRTUAL and an Organization label (V-W01-04).
N8 a role edge projected from a PROPOSED assertion (V-W01-07).
N9 a person-level equity edge pushed down to a group member company without an assertion naming it (V-434).""")
f.stmt("MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}), (x:Product {uid: 'hu:product:w01-synthetic-blood-test-plan'})\n"
       "MERGE (p)-[r:ENDORSES_PRODUCT {relationshipUid: 'hu:rel:w01-neg-n1'}]->(x)\n"
       "SET r += {assertionUid: 'hu:assertion:w01-sinclair-advises-segterra-2011-open', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:10:00Z')}")
f.stmt("MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}), (o:Organization {uid: 'hu:org:segterra'})\n"
       "MERGE (p)-[r:HOLDS_EQUITY_IN {relationshipUid: 'hu:rel:w01-neg-n2'}]->(o)\n"
       "SET r += {assertionUid: 'hu:assertion:w01-sinclair-invested-in-segterra-2011-open', validFrom: datetime('2011-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:10:00Z')}")
f.stmt("MATCH (p:Organization {uid: 'hu:org:pioneer-step-holdings-limited'}), (o:Organization {uid: 'hu:org:niagen-bioscience-inc'})\n"
       "MERGE (p)-[r:PARENT_OF {relationshipUid: 'hu:rel:w01-neg-n3'}]->(o)\n"
       "SET r += {assertionUid: 'hu:assertion:nage-proxy-2025-pioneer-step-equity', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:10:00Z')}")
f.stmt("MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}), (b:ConsumerBrand {uid: 'hu:brand:insidetracker'})\n"
       "MERGE (p)-[r:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:w01-neg-n4'}]->(b)\n"
       "SET r += {assertionUid: 'hu:assertion:w01-sinclair-board-segterra-2011-2017', validFrom: datetime('2011-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validTo: datetime('2017-01-01T00:00:00Z'), validToPrecision: 'YEAR', validToBasis: 'STATED_BY_SOURCE', recordedFrom: datetime('2026-10-04T01:10:00Z')}")
f.stmt("MERGE (n:ConsumerBrand:LegalEntity:Organization:Entity {uid: 'hu:org:w01-neg-insidetracker-merged'})\n"
       "SET n += {id: 'w01-neg-insidetracker-merged', entityType: 'LegalEntity', name: 'InsideTracker (Segterra) merged', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:10:00Z')}")
f.stmt("MATCH (o:Organization {uid: 'hu:org:w01-synthetic-brand-owner-llc'}), (x:Product {uid: 'hu:product:w01-synthetic-sleepwell-capsules'})\n"
       "MERGE (o)-[r:MANUFACTURES_PRODUCT {relationshipUid: 'hu:rel:w01-neg-n6'}]->(x)\n"
       "SET r += {assertionUid: 'hu:assertion:w01-synth-bo-distributes-sleepwell', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:10:00Z')}")
f.stmt("MERGE (n:Facility:Organization:Entity {uid: 'hu:facility:w01-neg-virtual-office'})\n"
       "SET n += {id: 'w01-neg-virtual-office', entityType: 'Facility', name: 'Virtual office (negative)', facilityKind: 'VIRTUAL', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:10:00Z')}")
f.stmt("MATCH (o:Organization {uid: 'hu:org:segterra'}), (b:ConsumerBrand {uid: 'hu:brand:insidetracker'})\n"
       "MERGE (o)-[r:OWNS_BRAND {relationshipUid: 'hu:rel:w01-neg-n8'}]->(b)\n"
       "SET r += {assertionUid: 'hu:assertion:w01-segterra-owns-insidetracker-brand-proposed', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:10:00Z')}")
f.stmt("MERGE (n:Organization:Entity {uid: 'hu:org:w01-neg-group-member-co'})\n"
       "SET n += {id: 'w01-neg-group-member-co', entityType: 'Organization', name: 'Group member company (negative)', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:10:00Z')}")
f.stmt("MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}), (o:Organization {uid: 'hu:org:w01-neg-group-member-co'})\n"
       "MERGE (p)-[r:HOLDS_EQUITY_IN {relationshipUid: 'hu:rel:w01-neg-n9'}]->(o)\n"
       "SET r += {assertionUid: 'hu:assertion:w01-sinclair-invested-in-segterra-2011-open', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:10:00Z')}")
f.write(OUT + 'w01-90-negative-forbidden-implications.cypher')

# ------------------------------------------------------------------------------------------------ F91 privacy leak
f = Fx('F91', COMMON_HDR + """
NEGATIVE FIXTURE w01-91-negative-privacy-leak: expected to FAIL. Load only after w01-06 into a scratch database.
L1 live-style HAS_PARTICIPANT_TOKEN from a named Person to a CohortParticipant (re-identification; V-W01-05).
L2 a CohortParticipant without privacyClass (V-W01-05, V-522).
L3 a :PrivateRecord node with a hu:private- uid reached from a shared CohortParticipant (V-113; V-521 on the shared side's property).""")
f.stmt("MERGE (n:Person:Entity {uid: 'hu:person:w01-synthetic-named-volunteer'})\n"
       "SET n += {id: 'w01-synthetic-named-volunteer', entityType: 'Person', name: 'Synthetic Named Volunteer (negative)', privacyClass: 'PUBLIC', fixtureProvenance: 'SYNTHETIC', createdAt: datetime('2026-10-04T01:10:00Z')}")
f.stmt("MATCH (p:Person {uid: 'hu:person:w01-synthetic-named-volunteer'}), (c:CohortParticipant {uid: 'hu:cohort-participant:w01-synthetic-dataset-a-p03'})\n"
       "MERGE (p)-[:HAS_PARTICIPANT_TOKEN]->(c)")
f.stmt("MERGE (n:CohortParticipant:PseudonymousActor:Entity {uid: 'hu:cohort-participant:w01-neg-unclassified'})\n"
       "SET n += {id: 'w01-neg-unclassified', entityType: 'CohortParticipant', participantToken: 'X1', createdAt: datetime('2026-10-04T01:10:00Z')}")
f.stmt("MERGE (n:PrivateRecord {uid: 'hu:private-measurement:w01-neg-sleep-latency'})\n"
       "SET n += {privacyClass: 'private-personal', valueNumber: 12.0, unitCode: 'min'}")
f.stmt("MATCH (c:CohortParticipant {uid: 'hu:cohort-participant:w01-synthetic-dataset-b-p03'}), (p:PrivateRecord {uid: 'hu:private-measurement:w01-neg-sleep-latency'})\n"
       "MERGE (c)-[:RECORDS]->(p)")
f.write(OUT + 'w01-91-negative-privacy-leak.cypher')
print('done')
