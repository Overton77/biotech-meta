#!/usr/bin/env python3
# Generates the W15 fixtures. Output: workers/W15/fixtures/*.cypher. Real captures are cited in 03-source-manifest.md.
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cy import Fx, dt, sha, norm, q, opaque

OUT = '/home/user/biotech-meta/docs/schema/ontology-lab/final-proposal-team/run-2026-10-04-fable51-01/workers/W15/fixtures'
COMMIT = '2026-10-04T02:00:00Z'
ORG = ['Organization', 'Entity']
LEGAL = ['LegalEntity', 'Organization', 'Entity']

def header(f, title, lines):
    f.c(f'W15 fixture {title}')
    for l in lines:
        f.c(l)
    f.c('Binding rule: every statement MATCHes or MERGEs its nodes by uid; no variable crosses a ";". Load after w15-00-common.cypher.')
    f.blank()

# ======================================================================================================================
# 00 common base
# ======================================================================================================================
def f00():
    f = Fx(COMMIT)
    f.c('W15 fixture 00 -- common base (load first). Organizations, persons, agent/activities and minimal STUBS of W04/W12')
    f.c('identities (ProductVariant, PackageConfiguration, Product, ProductLot) so this packet loads alone. W04/W12 own those types;')
    f.c('the stubs carry only identity fields. Commit instant for all W15 records: 2026-10-04T02:00:00Z (after every capture).')
    f.blank()
    f.node(['Agent', 'Entity'], 'hu:agent:w15-curation', {'name': 'W15 commerce curation (Opus 5.5 worker, manual review)', 'agentKind': 'HUMAN_OPERATED_TOOL'}, privacy='INTERNAL')
    f.node(['Activity', 'Occurrence'], 'hu:activity:w15-capture-2026-10-04', {'activityKind': 'CAPTURE', 'methodVersion': 'firecrawl-scrape-maxAge0/2026-10-04', 'startedAt': dt('2026-10-04T01:18:00Z'), 'endedAt': dt('2026-10-04T01:24:00Z')}, privacy='INTERNAL')
    f.node(['Activity', 'Occurrence'], 'hu:activity:w15-commerce-match-2026-10-04', {'activityKind': 'RESOLUTION', 'methodVersion': 'w15-gtin-title-match/v0', 'startedAt': dt('2026-10-04T02:00:00Z')}, privacy='INTERNAL')
    f.blank()
    f.c('Marketplace operators and seller accounts. A seller display account is an Organization WITHOUT the LegalEntity label;')
    f.c('its marketplace merchant id is an Identifier scoped by the marketplace; the legal entity is a ResolutionHypothesis (W01-SR-15b ruling).')
    orgs = [
        ('hu:org:amazon-marketplace-us', 'Amazon (amazon.com marketplace operator and retailer)', 'MARKETPLACE'),
        ('hu:org:walmart-marketplace-us', 'Walmart (walmart.com marketplace operator)', 'MARKETPLACE'),
        ('hu:org:seller-account-amazon-tru-niagen', 'TRU NIAGEN (Amazon seller display name, merchant A1W0QC6JE0QLDF)', 'UNKNOWN'),
        ('hu:org:seller-account-amazon-my-nutrition-depot', 'My Nutrition Depot (Amazon seller A2TXQHZ1OKWQ2N)', 'RETAILER'),
        ('hu:org:seller-account-amazon-zk-inc', 'ZK-INC (Amazon seller A2BHMA3GTYX2GC)', 'UNKNOWN'),
        ('hu:org:seller-account-amazon-be-rebellion-usa', 'BE REBELLION USA (Amazon seller A3Q3QEX08918FS)', 'UNKNOWN'),
        ('hu:org:seller-account-walmart-sports-med', 'Sports-Med (Walmart seller display name, seller id E4E44D0D801E45C8A50F187A7AB1A8B0)', 'UNKNOWN'),
        ('hu:org:truniagen-com-store-operator', 'truniagen.com store operator (merchant of record not displayed)', 'UNKNOWN'),
        ('hu:org:w15-syn-amazon-seller-moringa', 'SYNTHETIC third-party Amazon seller account (moringa reseller)', 'UNKNOWN'),
        ('hu:org:w15-syn-testing-lab', 'SYNTHETIC public testing organization (off-the-shelf purchases)', 'LABORATORY'),
    ]
    for uid, name, ot in orgs:
        f.node(ORG, uid, {'name': name, 'organizationType': ot})
    for uid, name in [('hu:org:chromadex-inc', 'ChromaDex, Inc. (brand owner of Tru Niagen; renamed Niagen Bioscience)'),
                      ('hu:org:blue-peak-distributor-inc', 'BLUE PEAK DISTRIBUTOR INC (legal seller name as exposed in Walmart page data)'),
                      ('hu:org:ambrosia-brands-llc', 'Ambrosia Brands, LLC (New York, NY; Rosabella brand)')]:
        f.node(LEGAL, uid, {'name': name, 'organizationType': 'COMPANY'})
    f.node(['Person', 'Entity'], 'hu:person:john-alexander-fastlifehacks', {'name': 'John Alexander (byline, fastlifehacks.com)'})
    f.blank()
    f.c('Seller-account identifiers (scheme, issuer, value). Shared values across issuers never merge identities (V-W00-04).')
    ids = [
        ('hu:identifier:amazon-merchant-a1w0qc6je0qldf', 'AMAZON_MERCHANT_ID', 'Amazon', 'A1W0QC6JE0QLDF', 'hu:org:seller-account-amazon-tru-niagen'),
        ('hu:identifier:amazon-merchant-a2txqhz1okwq2n', 'AMAZON_MERCHANT_ID', 'Amazon', 'A2TXQHZ1OKWQ2N', 'hu:org:seller-account-amazon-my-nutrition-depot'),
        ('hu:identifier:amazon-merchant-a2bhma3gtyx2gc', 'AMAZON_MERCHANT_ID', 'Amazon', 'A2BHMA3GTYX2GC', 'hu:org:seller-account-amazon-zk-inc'),
        ('hu:identifier:amazon-merchant-a3q3qex08918fs', 'AMAZON_MERCHANT_ID', 'Amazon', 'A3Q3QEX08918FS', 'hu:org:seller-account-amazon-be-rebellion-usa'),
        ('hu:identifier:walmart-seller-e4e44d0d801e45c8a50f187a7ab1a8b0', 'WALMART_SELLER_ID', 'Walmart', 'E4E44D0D801E45C8A50F187A7AB1A8B0', 'hu:org:seller-account-walmart-sports-med'),
    ]
    for uid, sch, iss, val, _ in ids:
        f.node(['Identifier', 'Entity'], uid, {'scheme': sch, 'issuer': iss, 'value': val, 'jurisdiction': 'US'})
    f.blank()
    f.c('STUBS of W04 identities (uids follow W04 fixture w04-02 and examples/filing-vs-capability.cypher where they exist).')
    f.node(['Product', 'Entity'], 'hu:product:tru-niagen', {'name': 'Tru Niagen'})
    for uid, name in [('hu:product-variant:tru-niagen-300mg-us-capsule', 'Tru Niagen 300mg, 1 vegetarian capsule per serving (US)'),
                      ('hu:product-variant:tru-niagen-beauty-us-30ct', 'Tru Niagen Beauty (US)'),
                      ('hu:product-variant:tru-niagen-immune-us-capsule', 'Tru Niagen Immune (US)'),
                      ('hu:product-variant:tru-niagen-pro-1000mg-us-capsule', 'Tru Niagen Pro 1,000mg (US)'),
                      ('hu:product-variant:on-gsw-double-rich-chocolate-us', 'Optimum Nutrition Gold Standard 100% Whey, Double Rich Chocolate (US)'),
                      ('hu:product-variant:rosabella-moringa-capsules-us', 'Rosabella Moringa Capsules (US)')]:
        f.node(['ProductVariant', 'Entity'], uid, {'name': name, 'jurisdiction': 'US'})
    for uid, name, n in [('hu:package-configuration:tru-niagen-300mg-30ct', 'Tru Niagen 300mg bottle of 30', 30),
                         ('hu:package-configuration:tru-niagen-300mg-90ct', 'Tru Niagen 300mg bottle of 90', 90),
                         ('hu:package-configuration:tru-niagen-immune-30ct', 'Tru Niagen Immune bottle of 30', 30),
                         ('hu:package-configuration:on-gsw-double-rich-chocolate-5lb', 'ON Gold Standard Whey Double Rich Chocolate 5 lb', None),
                         ('hu:package-configuration:rosabella-moringa-60ct', 'Rosabella Moringa Capsules bottle of 60', 60)]:
        f.node(['PackageConfiguration', 'VersionedState'], uid, {'name': name, 'unitCount': n, 'payloadHash': sha('W04-stub|' + uid)})
    f.c('W04 HAS_PACKAGE_CONFIGURATION / HAS_VARIANT episodes needed by the SELLS_PRODUCT derivation path (stub assertions, OBSERVATION_ONLY).')
    for v, p in [('hu:product-variant:tru-niagen-300mg-us-capsule', 'hu:package-configuration:tru-niagen-300mg-30ct'),
                 ('hu:product-variant:tru-niagen-300mg-us-capsule', 'hu:package-configuration:tru-niagen-300mg-90ct'),
                 ('hu:product-variant:tru-niagen-immune-us-capsule', 'hu:package-configuration:tru-niagen-immune-30ct'),
                 ('hu:product-variant:on-gsw-double-rich-chocolate-us', 'hu:package-configuration:on-gsw-double-rich-chocolate-5lb'),
                 ('hu:product-variant:rosabella-moringa-capsules-us', 'hu:package-configuration:rosabella-moringa-60ct')]:
        f.assertion('hu:assertion:w15-stub-' + opaque(v) + '-has-' + opaque(p), 'HAS_PACKAGE_CONFIGURATION', 'ProductVariant', v,
                    'PackageConfiguration', p, status='PROPOSED', edge=True)
    f.assertion('hu:assertion:w15-stub-tru-niagen-has-300mg-variant', 'HAS_VARIANT', 'Product', 'hu:product:tru-niagen',
                'ProductVariant', 'hu:product-variant:tru-niagen-300mg-us-capsule', status='PROPOSED', edge=True)
    f.c('STUB of a W12 lot (Rosabella lot 5040273, expiry 05/2027 per the FDA notice); W12 owns ProductLot.')
    f.node(['ProductLot', 'Entity'], 'hu:lot:rosabella-moringa-5040273', {'lotCode': '5040273', 'expiryDate': dt('2027-05-01T00:00:00Z'), 'expiryDatePrecision': 'MONTH', 'dateTextVerbatim': '5040273 | 05/2027'})
    return f

# ======================================================================================================================
# 01 Amazon B0FS82B35K: host / seller of record / fulfiller distinct; derived SELLS_PRODUCT from SELLER_OF_RECORD_FOR only
# ======================================================================================================================
def f01():
    f = Fx(COMMIT)
    header(f, '01 -- Amazon B0FS82B35K: marketplace host, seller of record and fulfiller are separate roles (CQ-CM-01, CQ-CM-03).', [
        'PUBLIC record, NEW_RETRIEVAL 2026-10-04T01:19:18Z (Firecrawl scrape, buy-box tags only: PARTIAL_EXCERPT; hash SYNTHETIC_FIXTURE).',
        'The page states: "Ships from: Amazon  Sold by: TRU NIAGEN"; merchant link seller=A1W0QC6JE0QLDF ... isAmazonFulfilled=1;',
        '"One-Time Price: $49.00"; "$44.10 with 10 percent savings"; "$41.65 with 15 percent savings"; "$1.63 per count"; "In Stock".',
        'Host = Amazon, fulfiller = Amazon (same party, two roles), seller of record = the TRU NIAGEN seller account (legal entity unresolved).',
        'SELLS_PRODUCT is derived for the seller account ONLY, from its SELLER_OF_RECORD_FOR assertion (V-326a/b/c pass). Amazon gets no',
        'SELLS_PRODUCT here (the must-fail twin is in w15-07-negatives-must-fail.cypher).'])
    S, SN = 'hu:source:amazon-b0fs82b35k', 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'
    f.source(S, 'https://www.amazon.com/dp/B0FS82B35K', 'Amazon detail page B0FS82B35K', 'MARKETPLACE_LISTING')
    f.snapshot(SN, S, '2026-10-04T01:19:18Z', '2026-10-04T01:19:18Z', 'PARTIAL_EXCERPT', 'SYNTHETIC_FIXTURE')
    L = lambda k: 'hu:locator:amazon-b0fs82b35k-' + k
    f.quote(L('ships-sold'), SN, 'Ships from: Amazon Sold by: TRU NIAGEN')
    f.quote(L('merchant-link'), SN, 'seller=A1W0QC6JE0QLDF&asin=B0FS82B35K&ref_=dp_merchant_link&isAmazonFulfilled=1')
    f.quote(L('one-time'), SN, 'One-Time Price: $49.00')
    f.quote(L('per-count'), SN, '$49.00 $1.63 per count')
    f.quote(L('sns-10'), SN, '$44.10 with 10 percent savings')
    f.quote(L('sns-15'), SN, '$41.65 with 15 percent savings')
    f.quote(L('sns-terms'), SN, 'Save 10% now and up to 15% on repeat deliveries.')
    f.quote(L('sns-15-rule'), SN, "Save 15% when you receive 5 or more products in one auto-delivery to one address. Currently, you'll save 10% on your Nov 5 delivery.")
    f.quote(L('sns-frequency'), SN, 'From once every 2 weeks to once every 6 months')
    f.quote(L('sns-no-fees'), SN, 'No fees. Skip or cancel anytime.')
    f.quote(L('coupon'), SN, '10% off coupon applied. First Subscribe & Save orders only.')
    f.quote(L('returns'), SN, 'Non-returnable due to Food safety reasons')
    f.quote(L('in-stock'), SN, 'In Stock')
    f.quote(L('title'), SN, 'TRU NIAGEN Beauty NAD+ Supplement, Hair, Skin & Nails, Biotin, 30-Count')
    f.quote(L('delivery-context'), SN, 'Delivering to Fairfax 22030')
    f.blank()
    ML, OF = 'hu:listing:amazon-us-b0fs82b35k', 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'
    f.node(['MerchantListing', 'Entity'], ML, {'merchantListingId': 'B0FS82B35K', 'marketplace': 'amazon.com', 'commercePlatform': 'AMAZON', 'marketplaceRegion': 'US',
           'title': 'TRU NIAGEN Beauty NAD+ Supplement, Hair, Skin & Nails, Biotin, 30-Count', 'canonicalUrl': 'https://www.amazon.com/dp/B0FS82B35K'})
    f.node(['TradeItemIdentifier', 'Identifier', 'Entity'], 'hu:trade-id:asin-b0fs82b35k', {'scheme': 'ASIN', 'issuer': 'Amazon', 'value': 'B0FS82B35K', 'jurisdiction': 'US'})
    f.assertion('hu:assertion:amazon-b0fs82b35k-identified-by-asin', 'IDENTIFIED_BY', 'MerchantListing', ML, 'TradeItemIdentifier', 'hu:trade-id:asin-b0fs82b35k',
                locs=[L('merchant-link')], extra={'predicateClass': 'IDENTITY'}, edge=True, edge_extra={'isPrimary': True})
    f.node(['Offer', 'VersionedState'], OF, {'offerKind': 'PURCHASE', 'currency': 'USD', 'termsText': 'Non-returnable due to Food safety reasons',
           'sellerOfferRef': 'A1W0QC6JE0QLDF|NEW', 'observedAt': dt('2026-10-04T01:19:18Z'),
           'payloadHash': sha('PURCHASE|USD|null|Non-returnable due to Food safety reasons|A1W0QC6JE0QLDF|NEW')})
    f.rel('MerchantListing', ML, 'HAS_OFFER', 'Offer', OF)
    f.c('Roles. Every role is its own asserted edge; validFrom null with basis OBSERVATION_ONLY (observed, start unknown), validTo null UNKNOWN.')
    f.assertion('hu:assertion:amazon-hosts-listing-b0fs82b35k-2026-10-04', 'HOSTS_LISTING', 'Organization', 'hu:org:amazon-marketplace-us', 'MerchantListing', ML,
                locs=[L('ships-sold')], extra={'predicateClass': 'ROLE'}, edge=True)
    f.assertion('hu:assertion:amazon-fulfills-offer-b0fs82b35k-2026-10-04', 'FULFILLS_OFFER', 'Organization', 'hu:org:amazon-marketplace-us', 'Offer', OF,
                locs=[L('ships-sold'), L('merchant-link')], extra={'predicateClass': 'ROLE'}, edge=True)
    f.assertion('hu:assertion:tru-niagen-account-seller-of-record-b0fs82b35k-2026-10-04', 'SELLER_OF_RECORD_FOR', 'Organization', 'hu:org:seller-account-amazon-tru-niagen', 'Offer', OF,
                locs=[L('ships-sold'), L('merchant-link')], extra={'predicateClass': 'ROLE'}, edge=True)
    f.c('Seller account merchant id (HAS_IDENTIFIER episode) and the unresolved legal entity (ResolutionHypothesis, not an edge).')
    f.assertion('hu:assertion:tru-niagen-account-has-merchant-id', 'HAS_IDENTIFIER', 'Organization', 'hu:org:seller-account-amazon-tru-niagen', 'Identifier', 'hu:identifier:amazon-merchant-a1w0qc6je0qldf',
                locs=[L('merchant-link')], extra={'predicateClass': 'IDENTITY'}, edge=True, edge_extra={'isPrimary': True})
    f.node(['ResolutionHypothesis', 'EvidenceAssessment'], 'hu:resolution:amazon-a1w0qc6je0qldf-operated-by-chromadex', {
        'assessmentType': 'ResolutionHypothesis', 'methodVersion': 'w15-seller-account-resolution/v0', 'status': 'PROPOSED', 'recordedAt': dt(COMMIT),
        'resolutionType': 'SELLER_ACCOUNT_OPERATED_BY_LEGAL_ENTITY', 'score': 0.6, 'resolutionStatus': 'UNRESOLVED',
        'rationale': 'Display name equals the brand; Amazon seller profile (business name, address) not captured. A display name is not a legal entity.'})
    f.rel('ResolutionHypothesis', 'hu:resolution:amazon-a1w0qc6je0qldf-operated-by-chromadex', 'PROPOSES_MATCH', 'Organization', 'hu:org:seller-account-amazon-tru-niagen')
    f.rel('ResolutionHypothesis', 'hu:resolution:amazon-a1w0qc6je0qldf-operated-by-chromadex', 'PROPOSES_MATCH', 'Organization', 'hu:org:chromadex-inc')
    f.c('Listing identity: LISTING_FOR to the Beauty variant (merchant title, 30-Count) plus an ACCEPTED CommerceMatch SAME_ITEM.')
    f.assertion('hu:assertion:amazon-b0fs82b35k-listing-for-beauty-variant', 'LISTING_FOR', 'MerchantListing', ML, 'ProductVariant', 'hu:product-variant:tru-niagen-beauty-us-30ct',
                locs=[L('title')], extra={'predicateClass': 'IDENTITY'}, edge=True)
    CM = 'hu:commerce-match:amazon-b0fs82b35k-to-tru-niagen-beauty'
    f.node(['CommerceMatch', 'EvidenceAssessment'], CM, {'assessmentType': 'CommerceMatch', 'methodVersion': 'w15-gtin-title-match/v0', 'status': 'ACCEPTED',
           'recordedAt': dt(COMMIT), 'matchKind': 'LISTING_TO_ITEM', 'matchOutcome': 'SAME_ITEM', 'score': 0.9,
           'rationale': 'Brand seller account sells under the brand name; title names Tru Niagen Beauty, 30-Count. No GTIN captured on this page: package-level identity not asserted.'})
    for lab, u in [('MerchantListing', ML), ('ProductVariant', 'hu:product-variant:tru-niagen-beauty-us-30ct')]:
        f.rel('CommerceMatch', CM, 'MATCHES_COMMERCE_ITEM', lab, u)
    f.rel('CommerceMatch', CM, 'SUPPORTED_BY', 'SourceLocator', L('title'))
    f.rel('CommerceMatch', CM, 'WAS_GENERATED_BY', 'Activity', 'hu:activity:w15-commerce-match-2026-10-04')
    f.c('Subscription plan (Amazon Subscribe & Save) as displayed; the plan is not a price.')
    SP = 'hu:subscription-plan:amazon-subscribe-and-save-b0fs82b35k-2026-10-04'
    f.node(['SubscriptionPlan', 'VersionedState'], SP, {'planGroupName': 'Subscribe & Save', 'planName': 'Subscribe & Save', 'planProvider': 'AMAZON_SUBSCRIBE_AND_SAVE',
           'intervalOptionsText': 'From once every 2 weeks to once every 6 months', 'termsText': 'No fees. Skip or cancel anytime.',
           'minimumCommitmentStatus': 'NOT_REPORTED', 'payloadHash': sha('AMAZON_SUBSCRIBE_AND_SAVE|2w-6m|No fees. Skip or cancel anytime.')})
    f.assertion('hu:assertion:amazon-b0fs82b35k-offer-uses-sns', 'USES_SUBSCRIPTION_PLAN', 'Offer', OF, 'SubscriptionPlan', SP,
                locs=[L('sns-terms'), L('sns-frequency'), L('sns-no-fees')], edge=True)
    f.c('Prices: one observation per displayed price and kind; never averaged. $41.65 is the 15% Subscribe & Save tier on this capture;')
    f.c('round 0005 recorded "$41.65 with coupon" from a brand-store search snippet (COUPON_ADJUSTED) -- see fixture 04 / queries Q-W15-03.')
    T = '2026-10-04T01:19:18Z'
    P = lambda k: 'hu:price-obs:amazon-b0fs82b35k-2026-10-04t0119-' + k
    f.price(P('one-time'), OF, 49.00, 'USD', T, 'ONE_TIME', 'IN_STOCK', L('one-time'), 'HTML_SELECTOR', 'One-Time Price: $49.00', region='US-VA')
    f.price(P('per-count'), OF, 1.63, 'USD', T, 'PER_UNIT', 'IN_STOCK', L('per-count'), 'HTML_SELECTOR', '$1.63 per count', region='US-VA', unit_q=1.0, unit='{count}')
    f.price(P('sns-10'), OF, 44.10, 'USD', T, 'SUBSCRIPTION', 'IN_STOCK', L('sns-10'), 'HTML_SELECTOR', '$44.10 with 10 percent savings',
            cond='Save 10% now and up to 15% on repeat deliveries.', region='US-VA', plan=SP)
    f.price(P('sns-15'), OF, 41.65, 'USD', T, 'SUBSCRIPTION', 'IN_STOCK', L('sns-15'), 'HTML_SELECTOR', '$41.65 with 15 percent savings',
            cond='Save 15% when you receive 5 or more products in one auto-delivery to one address.', region='US-VA', plan=SP)
    f.c('The coupon ("10% off coupon applied. First Subscribe & Save orders only.") shows no resulting amount: NO COUPON_ADJUSTED observation is invented.')
    f.c('Derived SELLS_PRODUCT: seller account -> Beauty variant, from the SELLER_OF_RECORD_FOR assertion only; the identity licence is the CommerceMatch.')
    f.rel('Organization', 'hu:org:seller-account-amazon-tru-niagen', 'SELLS_PRODUCT', 'ProductVariant', 'hu:product-variant:tru-niagen-beauty-us-30ct', {
        'derivationRule': 'w15-sells-product-from-seller-of-record/v1',
        'derivedFromAssertionUids': ['hu:assertion:tru-niagen-account-seller-of-record-b0fs82b35k-2026-10-04'],
        'derivedFromAssessmentUids': [CM], 'derivedAt': dt('2026-10-04T02:05:00Z')})
    f.c('Projections (read-only, projection service): latest ONE_TIME observation; answers cite lastObservedAt.')
    f.st(f"MATCH (ml:MerchantListing {{uid: {q(ML)}}}) SET ml.priceAmount = 49.0, ml.currency = 'USD', ml.availabilityStatus = 'IN_STOCK', ml.priceKindProjected = 'ONE_TIME', ml.lastObservedAt = datetime('{T}'), ml.capturedAt = datetime('{T}'), ml.currentAsOf = datetime('2026-10-04T02:05:00Z'), ml.projectedFromPriceObservationUid = {q(P('one-time'))}")
    f.st(f"MATCH (o:Offer {{uid: {q(OF)}}}) SET o.availabilityStatus = 'IN_STOCK', o.firstObservedAt = datetime('{T}'), o.lastObservedAt = datetime('{T}'), o.projectedFromPriceObservationUid = {q(P('one-time'))}")
    return f

# ======================================================================================================================
# 02 Listing merge: Amazon B000QSNYGI, one MerchantListing, four Offers
# ======================================================================================================================
def f02():
    f = Fx(COMMIT)
    header(f, '02 -- listing merge: one MerchantListing (ASIN B000QSNYGI), four sellers\' Offers (CQ-CM-01, CQ-CM-02, CQ-CM-03).', [
        'PUBLIC record, NEW_RETRIEVAL 2026-10-04T01:22:25Z, Amazon all-offers panel (aod=1), PARTIAL_EXCERPT, hash SYNTHETIC_FIXTURE.',
        'Offers as displayed: Amazon.com ships+sells $102.81 (List Price $114.99); My Nutrition Depot ships+sells $109.99;',
        'ZK-INC ships+sells $149.00; BE REBELLION USA sold, Ships from Amazon.com, $155.00. One listing, four propositions;',
        'the listing is not four products and not one seller. Amazon is seller of record ONLY for its own retail offer, so SELLS_PRODUCT',
        'for Amazon is derived from that one SELLER_OF_RECORD_FOR assertion; Amazon hosting/fulfilling the BE REBELLION offer adds nothing.'])
    S, SN = 'hu:source:amazon-b000qsnygi-aod', 'hu:snapshot:amazon-b000qsnygi-aod-2026-10-04t0122'
    f.source(S, 'https://www.amazon.com/dp/B000QSNYGI?aod=1', 'Amazon all offers B000QSNYGI', 'MARKETPLACE_LISTING')
    f.snapshot(SN, S, '2026-10-04T01:22:25Z', '2026-10-04T01:22:25Z', 'PARTIAL_EXCERPT', 'SYNTHETIC_FIXTURE')
    L = lambda k: 'hu:locator:amazon-b000qsnygi-' + k
    f.quote(L('title'), SN, 'Optimum Nutrition Gold Standard Whey Protein, Double Rich Chocolate, 5 LB')
    f.quote(L('o1-roles'), SN, 'Ships from Amazon.com Sold by Amazon.com')
    f.quote(L('o1-price'), SN, '$102.81 with 11 percent savings')
    f.quote(L('o1-list'), SN, 'List Price: $114.99')
    f.quote(L('o2-roles'), SN, 'Ships from My Nutrition Depot™ Sold by My Nutrition Depot™')
    f.quote(L('o2-price'), SN, '$109.99 $1.37 per ounce')
    f.quote(L('o3-roles'), SN, 'Ships from ZK-INC Sold by ZK-INC')
    f.quote(L('o3-price'), SN, '$149.00 $1.86 per ounce')
    f.quote(L('o4-roles'), SN, 'Ships from Amazon.com Sold by BE REBELLION USA')
    f.quote(L('o4-price'), SN, '$155.00 $1.94 per ounce')
    ML = 'hu:listing:amazon-us-b000qsnygi'
    f.node(['MerchantListing', 'Entity'], ML, {'merchantListingId': 'B000QSNYGI', 'marketplace': 'amazon.com', 'commercePlatform': 'AMAZON', 'marketplaceRegion': 'US',
           'title': 'Optimum Nutrition Gold Standard Whey Protein, Double Rich Chocolate, 5 LB', 'canonicalUrl': 'https://www.amazon.com/dp/B000QSNYGI'})
    f.assertion('hu:assertion:amazon-hosts-listing-b000qsnygi-2026-10-04', 'HOSTS_LISTING', 'Organization', 'hu:org:amazon-marketplace-us', 'MerchantListing', ML,
                locs=[L('o1-roles')], extra={'predicateClass': 'ROLE'}, edge=True)
    f.assertion('hu:assertion:amazon-b000qsnygi-listing-for-on-5lb', 'LISTING_FOR', 'MerchantListing', ML, 'PackageConfiguration', 'hu:package-configuration:on-gsw-double-rich-chocolate-5lb',
                locs=[L('title')], extra={'predicateClass': 'IDENTITY'}, edge=True)
    CM = 'hu:commerce-match:amazon-b000qsnygi-to-on-5lb'
    f.node(['CommerceMatch', 'EvidenceAssessment'], CM, {'assessmentType': 'CommerceMatch', 'methodVersion': 'w15-gtin-title-match/v0', 'status': 'ACCEPTED',
           'recordedAt': dt(COMMIT), 'matchKind': 'LISTING_TO_ITEM', 'matchOutcome': 'SAME_ITEM', 'score': 0.85,
           'rationale': 'Brand, line, flavor and net weight in the title match the package; GTIN not captured.'})
    for lab, u in [('MerchantListing', ML), ('PackageConfiguration', 'hu:package-configuration:on-gsw-double-rich-chocolate-5lb')]:
        f.rel('CommerceMatch', CM, 'MATCHES_COMMERCE_ITEM', lab, u)
    f.rel('CommerceMatch', CM, 'SUPPORTED_BY', 'SourceLocator', L('title'))
    offers = [
        ('o1', 'amazon-retail', 'hu:org:amazon-marketplace-us', 'hu:org:amazon-marketplace-us', 102.81, '$102.81 with 11 percent savings', 'AMAZON_RETAIL|NEW'),
        ('o2', 'my-nutrition-depot', 'hu:org:seller-account-amazon-my-nutrition-depot', 'hu:org:seller-account-amazon-my-nutrition-depot', 109.99, '$109.99', 'A2TXQHZ1OKWQ2N|NEW'),
        ('o3', 'zk-inc', 'hu:org:seller-account-amazon-zk-inc', 'hu:org:seller-account-amazon-zk-inc', 149.00, '$149.00', 'A2BHMA3GTYX2GC|NEW'),
        ('o4', 'be-rebellion-usa', 'hu:org:seller-account-amazon-be-rebellion-usa', 'hu:org:amazon-marketplace-us', 155.00, '$155.00', 'A3Q3QEX08918FS|NEW'),
    ]
    T = '2026-10-04T01:22:25Z'
    for k, slug, seller, fulfiller, amt, txt, ref in offers:
        OF = 'hu:offer:amazon-us-b000qsnygi-' + slug
        f.node(['Offer', 'VersionedState'], OF, {'offerKind': 'PURCHASE', 'currency': 'USD', 'itemCondition': 'NEW', 'sellerOfferRef': ref,
               'observedAt': dt(T), 'payloadHash': sha('PURCHASE|USD|NEW|null|' + ref)})
        f.rel('MerchantListing', ML, 'HAS_OFFER', 'Offer', OF)
        f.assertion(f'hu:assertion:{slug}-seller-of-record-b000qsnygi-2026-10-04', 'SELLER_OF_RECORD_FOR', 'Organization', seller, 'Offer', OF,
                    locs=[L(k + '-roles')], extra={'predicateClass': 'ROLE'}, edge=True)
        f.assertion(f'hu:assertion:{slug}-offer-fulfilled-b000qsnygi-2026-10-04', 'FULFILLS_OFFER', 'Organization', fulfiller, 'Offer', OF,
                    locs=[L(k + '-roles')], extra={'predicateClass': 'ROLE'}, edge=True)
        f.price(f'hu:price-obs:amazon-b000qsnygi-{slug}-2026-10-04t0122-one-time', OF, amt, 'USD', T, 'ONE_TIME', 'NOT_DISPLAYED',
                L(k + '-price'), 'HTML_SELECTOR', txt, region='US-VA')
    f.price('hu:price-obs:amazon-b000qsnygi-amazon-retail-2026-10-04t0122-list', 'hu:offer:amazon-us-b000qsnygi-amazon-retail', 114.99, 'USD', T, 'LIST',
            None, L('o1-list'), 'HTML_SELECTOR', 'List Price: $114.99', region='US-VA')
    f.c('Amazon SELLS_PRODUCT from its own retail SELLER_OF_RECORD_FOR assertion only (not from hosting, not from fulfilling BE REBELLION).')
    f.rel('Organization', 'hu:org:amazon-marketplace-us', 'SELLS_PRODUCT', 'ProductVariant', 'hu:product-variant:on-gsw-double-rich-chocolate-us', {
        'derivationRule': 'w15-sells-product-from-seller-of-record/v1',
        'derivedFromAssertionUids': ['hu:assertion:amazon-retail-seller-of-record-b000qsnygi-2026-10-04'],
        'derivedFromAssessmentUids': [CM], 'derivedAt': dt('2026-10-04T02:05:00Z')})
    return f

# ======================================================================================================================
# 03 DTC Shopify: listings per variant, selling plans, JSON vs rendered subscription price, bundles
# ======================================================================================================================
def f03():
    f = Fx(COMMIT)
    header(f, '03 -- DTC Shopify store truniagen.com: selling plans, JSON vs rendered subscription price, bundles (CQ-CM-02, CQ-CM-03).', [
        'PUBLIC records, NEW_RETRIEVAL 2026-10-04: /products/tru-niagen-300mg.js (01:18:33Z, complete JSON, not hashed: SYNTHETIC_FIXTURE),',
        '/products.json?limit=50 (01:18:22Z, sha256 over the extracted JSON text, NORMALIZED_TEXT), rendered PDP (01:18:46Z, PARTIAL_EXCERPT).',
        'JSON: variants 30 ($49.00, SKU CTNUS3006030010, barcode 850015311857), 90 ($127.00), 180 ($244.00, SKU CTNUS3006090010-KIT);',
        'selling_plan_group "Subscribe and Save" (app_id ordergroove-subscribe-and-save) with plans 1316552773/1341685829/1341718597/1341751365',
        '(every month / 2 / 3 / 6 months), price_adjustments [] and per_delivery_price 4900 for the 30-count.',
        'Rendered PDP: "Subscribe & Save: 1 month supply Save 20% $39.20 $1.31/count"; "3 months supply Save 30% $101.60"; "6 months supply',
        'Save 33% $195.20"; "Save 20% on recurring orders."; "Pause, skip, or cancel anytime."; "One-Time Purchase: 1 month supply $49.00".',
        'The JSON plan carries no price adjustment while the page shows 20% off: TWO SUBSCRIPTION observations (49.00 RAW_STRUCTURED_DATA,',
        '39.20 LLM_DIRECT_QUOTE) are kept, never merged or averaged. "Save 30%" for the 90-count is relative to three 30-counts ($147),',
        '"Save 20%" relative to $127: the percentages have different references and are kept only as conditionText.',
        'Listing granularity: one MerchantListing per Shopify variant (the purchasable entry); the product page is the parent (parentListingRef).',
        'Shopify is the platform (commercePlatform), not a host. The DTC merchant of record is not displayed: SELLER_OF_RECORD_FOR stays PROPOSED',
        'and no SELLS_PRODUCT is derived.'])
    SJ, SNJ = 'hu:source:truniagen-300mg-js', 'hu:snapshot:truniagen-300mg-js-2026-10-04t0118'
    SP_, SNP = 'hu:source:truniagen-products-json', 'hu:snapshot:truniagen-products-json-2026-10-04t0118'
    SD, SND = 'hu:source:truniagen-300mg-pdp', 'hu:snapshot:truniagen-300mg-pdp-2026-10-04t0118'
    f.source(SJ, 'https://www.truniagen.com/products/tru-niagen-300mg.js', 'Shopify product JSON tru-niagen-300mg', 'MARKETING_PAGE')
    f.snapshot(SNJ, SJ, '2026-10-04T01:18:33Z', '2026-10-04T01:18:33Z', 'COMPLETE', 'SYNTHETIC_FIXTURE')
    f.source(SP_, 'https://www.truniagen.com/products.json?limit=50', 'Shopify products.json truniagen.com', 'MARKETING_PAGE')
    f.snapshot(SNP, SP_, '2026-10-04T01:18:22Z', '2026-10-04T01:18:22Z', 'COMPLETE', 'NORMALIZED_TEXT',
               chash='sha256:17271356b2bdfa7d672a2511faef0f0877aae38fcbbe5192309d03aa09375b56')
    f.source(SD, 'https://www.truniagen.com/products/tru-niagen-300mg', 'Tru Niagen 300mg product page', 'MARKETING_PAGE')
    f.snapshot(SND, SD, '2026-10-04T01:18:46Z', '2026-10-04T01:18:46Z', 'PARTIAL_EXCERPT', 'SYNTHETIC_FIXTURE')
    J = lambda k: 'hu:locator:truniagen-300mg-js-' + k
    D = lambda k: 'hu:locator:truniagen-300mg-pdp-' + k
    PJ = lambda k: 'hu:locator:truniagen-products-json-' + k
    f.section(J('variant-30'), SNJ, 'variants[0]', 'id 41905353850949 title 30 sku CTNUS3006030010 price 4900 barcode 850015311857 requires_selling_plan false')
    f.section(J('variant-90'), SNJ, 'variants[1]', 'id 41905353883717 title 90 sku CTNUS3006090010 price 12700 barcode 850015311895')
    f.section(J('variant-180'), SNJ, 'variants[2]', 'id 41905353916485 title 180 sku CTNUS3006090010-KIT price 24400 barcode 850064273106')
    f.section(J('alloc-30-monthly'), SNJ, 'variants[0].selling_plan_allocations[0]', 'price_adjustments [] price 4900 per_delivery_price 4900 selling_plan_id 1316552773')
    f.section(J('plan-group'), SNJ, 'selling_plan_groups[0]', 'name Subscribe and Save; app_id ordergroove-subscribe-and-save; plans 1316552773 Delivered every month, 1341685829 Delivered every 2 months, 1341718597 Delivered every 3 months, 1341751365 Delivered every 6 months; price_adjustments []')
    f.section(PJ('immune-bundle'), SNP, 'products[handle=tru-niagen-300mg-30ct-immune-bundle].variants[0]', 'id 44628427604037 title 30/30 price 85.00 sku CTNUSCK00000004-KIT')
    f.quote(D('sns-30'), SND, '1 month supplySave 20% $39.20$1.31/count')
    f.quote(D('sns-90'), SND, '3 months supplySave 30% $101.60$1.13/count')
    f.quote(D('sns-180'), SND, '6 months supplySave 33% $195.20$1.08/count')
    f.quote(D('sns-terms'), SND, 'Save 20% on recurring orders.Free U.S. shipping on every order, always.Pause, skip, or cancel anytime.')
    f.quote(D('one-time-30'), SND, 'One-Time Purchase: 1 month supply $49.00$1.63/count')
    f.quote(D('bundle-each'), SND, '30-day supply each: 300mg and Immune.')
    T_J, T_D, T_P = '2026-10-04T01:18:33Z', '2026-10-04T01:18:46Z', '2026-10-04T01:18:22Z'
    plans = [('1316552773', 'Delivered every month', 'MONTH', 1), ('1341685829', 'Delivered every 2 months', 'MONTH', 2),
             ('1341718597', 'Delivered every 3 months', 'MONTH', 3), ('1341751365', 'Delivered every 6 months', 'MONTH', 6)]
    for pid, pname, iv, n in plans:
        f.node(['SubscriptionPlan', 'VersionedState'], 'hu:subscription-plan:truniagen-shopify-' + pid, {
            'sellingPlanId': pid, 'planGroupName': 'Subscribe and Save', 'planName': pname, 'interval': iv, 'intervalCount': n,
            'planProvider': 'ordergroove-subscribe-and-save', 'priceAdjustmentText': 'price_adjustments: []',
            'termsText': 'Pause, skip, or cancel anytime.', 'minimumCommitmentStatus': 'NOT_REPORTED',
            'payloadHash': sha('|'.join([pid, 'Subscribe and Save', pname, iv, str(n), 'ordergroove-subscribe-and-save', 'price_adjustments: []']))})
    f.blank()
    variants = [
        ('41905353850949', '30', 'PackageConfiguration', 'hu:package-configuration:tru-niagen-300mg-30ct', 49.00, J('variant-30')),
        ('41905353883717', '90', 'PackageConfiguration', 'hu:package-configuration:tru-niagen-300mg-90ct', 127.00, J('variant-90')),
        ('41905353916485', '180', 'Bundle', 'hu:bundle:tru-niagen-300mg-180-kit', 244.00, J('variant-180')),
    ]
    f.node(['Bundle', 'Entity'], 'hu:bundle:tru-niagen-300mg-180-kit', {'name': 'Tru Niagen 300mg "180" (kit SKU CTNUS3006090010-KIT)', 'bundleKind': 'MULTI_PACK_SAME_ITEM'})
    BC = 'hu:bundle-component:tru-niagen-300mg-180-kit-90ct'
    f.node(['BundleComponent', 'VersionedState'], BC, {'quantity': None, 'quantityStatus': 'NOT_REPORTED', 'componentRole': 'PRIMARY',
           'payloadHash': sha('null|NOT_REPORTED|PRIMARY|hu:package-configuration:tru-niagen-300mg-90ct')})
    f.rel('Bundle', 'hu:bundle:tru-niagen-300mg-180-kit', 'HAS_BUNDLE_COMPONENT', 'BundleComponent', BC, {'orderIndex': 0})
    f.c('Component identity inferred from the kit SKU (CTNUS3006090010 + "-KIT"): PROPOSED, basisKind HYPOTHESIS; count NOT_REPORTED (180/90 = 2 is not stated).')
    f.assertion('hu:assertion:truniagen-180-kit-component-is-90ct', 'COMPONENT_PRODUCT', 'BundleComponent', BC, 'PackageConfiguration', 'hu:package-configuration:tru-niagen-300mg-90ct',
                locs=[J('variant-180')], status='PROPOSED', extra={'basisKind': 'HYPOTHESIS', 'predicateClass': 'IDENTITY'}, edge=True)
    for vid, title, tlab, target, amt, loc in variants:
        ML, OF = 'hu:listing:truniagen-shopify-' + vid, 'hu:offer:truniagen-shopify-' + vid
        f.node(['MerchantListing', 'Entity'], ML, {'merchantListingId': vid, 'marketplace': 'truniagen.com', 'parentListingRef': '7387359477829',
               'commercePlatform': 'SHOPIFY', 'marketplaceRegion': 'US', 'title': 'Tru Niagen® 300mg - ' + title,
               'canonicalUrl': 'https://www.truniagen.com/products/tru-niagen-300mg?variant=' + vid})
        f.node(['TradeItemIdentifier', 'Identifier', 'Entity'], 'hu:trade-id:truniagen-shopify-variant-' + vid, {'scheme': 'SHOPIFY_VARIANT_ID', 'issuer': 'truniagen.com', 'value': vid})
        f.assertion('hu:assertion:truniagen-' + vid + '-identified-by-variant-id', 'IDENTIFIED_BY', 'MerchantListing', ML, 'TradeItemIdentifier',
                    'hu:trade-id:truniagen-shopify-variant-' + vid, locs=[loc], extra={'predicateClass': 'IDENTITY'}, edge=True, edge_extra={'isPrimary': True})
        f.assertion('hu:assertion:truniagen-' + vid + '-listing-for', 'LISTING_FOR', 'MerchantListing', ML, tlab, target, locs=[loc],
                    extra={'predicateClass': 'IDENTITY'}, edge=True)
        f.node(['Offer', 'VersionedState'], OF, {'offerKind': 'PURCHASE', 'currency': 'USD', 'sellerOfferRef': vid, 'observedAt': dt(T_J),
               'payloadHash': sha('PURCHASE|USD|null|null|' + vid)})
        f.rel('MerchantListing', ML, 'HAS_OFFER', 'Offer', OF)
        f.assertion('hu:assertion:truniagen-store-hosts-' + vid, 'HOSTS_LISTING', 'Organization', 'hu:org:truniagen-com-store-operator', 'MerchantListing', ML,
                    locs=[loc], extra={'predicateClass': 'ROLE'}, edge=True)
        f.assertion('hu:assertion:truniagen-store-seller-of-record-' + vid, 'SELLER_OF_RECORD_FOR', 'Organization', 'hu:org:truniagen-com-store-operator', 'Offer', OF,
                    locs=[loc], status='PROPOSED', extra={'predicateClass': 'ROLE', 'assertionBasis': 'UNSTATED'}, edge=True)
        for pid, _, _, _ in plans:
            f.assertion('hu:assertion:truniagen-' + vid + '-uses-plan-' + pid, 'USES_SUBSCRIPTION_PLAN', 'Offer', OF, 'SubscriptionPlan',
                        'hu:subscription-plan:truniagen-shopify-' + pid, locs=[J('plan-group')], edge=True)
        f.price('hu:price-obs:truniagen-' + vid + '-2026-10-04t0118-one-time-json', OF, amt, 'USD', T_J, 'ONE_TIME', 'IN_STOCK', loc,
                'RAW_STRUCTURED_DATA', 'price ' + str(int(amt * 100)), region='US')
    f.c('Identity licence for the DTC entries: the variant barcode in the brand\'s own JSON equals the package GTIN (W04 IDENTIFIED_BY) -> ACCEPTED SAME_ITEM;')
    f.c('the "180" kit composition is not stated -> PROPOSED / UNRESOLVED (its LISTING_FOR to the Bundle stays asserted-only).')
    for vid, tlab, target, outcome, status, why in [
            ('41905353850949', 'PackageConfiguration', 'hu:package-configuration:tru-niagen-300mg-30ct', 'SAME_ITEM', 'ACCEPTED', 'Brand JSON variant barcode 850015311857 equals the 30-count package GTIN.'),
            ('41905353883717', 'PackageConfiguration', 'hu:package-configuration:tru-niagen-300mg-90ct', 'SAME_ITEM', 'ACCEPTED', 'Brand JSON variant barcode 850015311895 equals the 90-count package GTIN.'),
            ('41905353916485', 'Bundle', 'hu:bundle:tru-niagen-300mg-180-kit', 'UNRESOLVED', 'PROPOSED', 'Kit SKU CTNUS3006090010-KIT and barcode 850064273106; component count not stated, so the bundle composition is unresolved.')]:
        cm = 'hu:commerce-match:truniagen-shopify-' + vid + '-to-item'
        f.node(['CommerceMatch', 'EvidenceAssessment'], cm, {'assessmentType': 'CommerceMatch', 'methodVersion': 'w15-gtin-title-match/v0', 'status': status,
               'recordedAt': dt(COMMIT), 'matchKind': 'LISTING_TO_ITEM', 'matchOutcome': outcome, 'rationale': why})
        f.rel('CommerceMatch', cm, 'MATCHES_COMMERCE_ITEM', 'MerchantListing', 'hu:listing:truniagen-shopify-' + vid)
        f.rel('CommerceMatch', cm, 'MATCHES_COMMERCE_ITEM', tlab, target)
        f.rel('CommerceMatch', cm, 'SUPPORTED_BY', 'SourceLocator', J({'41905353850949': 'variant-30', '41905353883717': 'variant-90', '41905353916485': 'variant-180'}[vid]))
    OF30 = 'hu:offer:truniagen-shopify-41905353850949'
    f.price('hu:price-obs:truniagen-41905353850949-2026-10-04t0118-subscription-json', OF30, 49.00, 'USD', T_J, 'SUBSCRIPTION', 'IN_STOCK',
            J('alloc-30-monthly'), 'RAW_STRUCTURED_DATA', 'per_delivery_price 4900 (price_adjustments [])', region='US', plan='hu:subscription-plan:truniagen-shopify-1316552773')
    f.price('hu:price-obs:truniagen-41905353850949-2026-10-04t0118-subscription-pdp', OF30, 39.20, 'USD', T_D, 'SUBSCRIPTION', 'NOT_DISPLAYED',
            D('sns-30'), 'LLM_DIRECT_QUOTE', '1 month supply Save 20% $39.20', cond='Save 20% on recurring orders.', region='US',
            plan='hu:subscription-plan:truniagen-shopify-1316552773')
    f.price('hu:price-obs:truniagen-41905353850949-2026-10-04t0118-subscription-per-count-pdp', OF30, 1.31, 'USD', T_D, 'PER_UNIT', 'NOT_DISPLAYED',
            D('sns-30'), 'LLM_DIRECT_QUOTE', '$1.31/count', cond='Subscribe & Save, 1 month supply', region='US', unit_q=1.0, unit='{count}')
    f.price('hu:price-obs:truniagen-41905353850949-2026-10-04t0118-one-time-pdp', OF30, 49.00, 'USD', T_D, 'ONE_TIME', 'NOT_DISPLAYED',
            D('one-time-30'), 'LLM_DIRECT_QUOTE', 'One-Time Purchase: 1 month supply $49.00', region='US')
    f.price('hu:price-obs:truniagen-41905353883717-2026-10-04t0118-subscription-pdp', 'hu:offer:truniagen-shopify-41905353883717', 101.60, 'USD', T_D, 'SUBSCRIPTION',
            'NOT_DISPLAYED', D('sns-90'), 'LLM_DIRECT_QUOTE', '3 months supply Save 30% $101.60', cond='Save 30% (displayed; reference not stated); Save 20% on recurring orders.', region='US')
    f.price('hu:price-obs:truniagen-41905353916485-2026-10-04t0118-subscription-pdp', 'hu:offer:truniagen-shopify-41905353916485', 195.20, 'USD', T_D, 'SUBSCRIPTION',
            'NOT_DISPLAYED', D('sns-180'), 'LLM_DIRECT_QUOTE', '6 months supply Save 33% $195.20', cond='Save 33% (displayed; reference not stated)', region='US')
    f.c('Mixed kit: "Tru Niagen 300mg 30ct + Immune Bundle" (products.json variant 44628427604037, SKU CTNUSCK00000004-KIT, $85.00).')
    B2, ML2, OF2 = 'hu:bundle:tru-niagen-300mg-30ct-immune-kit', 'hu:listing:truniagen-shopify-44628427604037', 'hu:offer:truniagen-shopify-44628427604037'
    f.node(['Bundle', 'Entity'], B2, {'name': 'Tru Niagen 300mg 30ct + Immune Bundle (CTNUSCK00000004-KIT)', 'bundleKind': 'MIXED_KIT'})
    for i, (slug, pkg) in enumerate([('300mg-30ct', 'hu:package-configuration:tru-niagen-300mg-30ct'), ('immune-30ct', 'hu:package-configuration:tru-niagen-immune-30ct')]):
        bc = 'hu:bundle-component:tru-niagen-300mg-immune-kit-' + slug
        f.node(['BundleComponent', 'VersionedState'], bc, {'quantity': 1, 'quantityStatus': 'REPORTED', 'componentRole': 'PRIMARY',
               'payloadHash': sha('1|REPORTED|PRIMARY|' + pkg)})
        f.rel('Bundle', B2, 'HAS_BUNDLE_COMPONENT', 'BundleComponent', bc, {'orderIndex': i})
        f.assertion('hu:assertion:truniagen-immune-kit-component-' + slug, 'COMPONENT_PRODUCT', 'BundleComponent', bc, 'PackageConfiguration', pkg,
                    locs=[PJ('immune-bundle'), D('bundle-each')], extra={'predicateClass': 'IDENTITY'}, edge=True)
    f.node(['MerchantListing', 'Entity'], ML2, {'merchantListingId': '44628427604037', 'marketplace': 'truniagen.com', 'parentListingRef': '7953098997829',
           'commercePlatform': 'SHOPIFY', 'marketplaceRegion': 'US', 'title': 'Tru Niagen® 300mg 30ct + Immune Bundle - 30/30',
           'canonicalUrl': 'https://www.truniagen.com/products/tru-niagen-300mg-30ct-immune-bundle?variant=44628427604037'})
    f.assertion('hu:assertion:truniagen-44628427604037-listing-for', 'LISTING_FOR', 'MerchantListing', ML2, 'Bundle', B2, locs=[PJ('immune-bundle')],
                extra={'predicateClass': 'IDENTITY'}, edge=True)
    f.node(['Offer', 'VersionedState'], OF2, {'offerKind': 'PURCHASE', 'currency': 'USD', 'sellerOfferRef': '44628427604037', 'observedAt': dt(T_P),
           'payloadHash': sha('PURCHASE|USD|null|null|44628427604037')})
    f.rel('MerchantListing', ML2, 'HAS_OFFER', 'Offer', OF2)
    f.price('hu:price-obs:truniagen-44628427604037-2026-10-04t0118-one-time-json', OF2, 85.00, 'USD', T_P, 'ONE_TIME', 'IN_STOCK', PJ('immune-bundle'),
            'RAW_STRUCTURED_DATA', 'price 85.00', region='US')
    f.c('Store operator -> brand owner: ResolutionHypothesis only (site terms naming the merchant of record were not captured).')
    f.node(['ResolutionHypothesis', 'EvidenceAssessment'], 'hu:resolution:truniagen-com-store-operated-by-chromadex', {
        'assessmentType': 'ResolutionHypothesis', 'methodVersion': 'w15-seller-account-resolution/v0', 'status': 'PROPOSED', 'recordedAt': dt(COMMIT),
        'resolutionType': 'STORE_OPERATED_BY_LEGAL_ENTITY', 'score': 0.7, 'resolutionStatus': 'UNRESOLVED',
        'rationale': 'Brand DTC domain; vendor "Tru Niagen" in product JSON is the brand, not a legal seller; terms of sale not captured.'})
    f.rel('ResolutionHypothesis', 'hu:resolution:truniagen-com-store-operated-by-chromadex', 'PROPOSES_MATCH', 'Organization', 'hu:org:truniagen-com-store-operator')
    f.rel('ResolutionHypothesis', 'hu:resolution:truniagen-com-store-operated-by-chromadex', 'PROPOSES_MATCH', 'Organization', 'hu:org:chromadex-inc')
    return f

# ======================================================================================================================
# 04 Walmart: price conflict between captures, OPEN_END_STALE, late-arriving archive price, listing with NO product identity
# ======================================================================================================================
def f04():
    f = Fx(COMMIT)
    header(f, '04 -- Walmart item 1038593372: two disagreeing captures, open end, late arrival, unresolved identity (CQ-CM-02/03/05, CQ-AX-06).', [
        'PUBLIC record, NEW_RETRIEVAL 2026-10-04. Capture A 01:20:44Z (Firecrawl LLM directQuote): "current price $19.90", "Sold by Sports-Med",',
        '"Fulfilled by Walmart". Capture B 01:21:32Z (rendered HTML, sha256 3ea4967d... RAW_BYTES of the capture as returned): __NEXT_DATA__',
        'product.priceInfo.currentPrice.price 45, availabilityStatus IN_STOCK, sellerDisplayName "Sports-Med", sellerName "BLUE PEAK DISTRIBUTOR INC",',
        'sellerId E4E44D0D801E45C8A50F187A7AB1A8B0, offerId 6B703781AD47343680CA645C778BE7D6, wfsEnabled true, upc "850015311116", delivery context',
        'Silver Spring MD 20904, transactableOfferCount 1. The two prices are two observations with different capture methods; neither is averaged',
        'or discarded. The displayed UPC differs from the brand\'s current 30-count GTIN 850015311857: NO LISTING_FOR; an UNRESOLVED CommerceMatch.',
        'SYNTHETIC late arrival: an archive capture of the same page (observedAt 2026-10-02, retrieved 2026-10-12) adds a price recorded on 2026-10-12.'])
    S = 'hu:source:walmart-ip-1038593372'
    SA, SB, SC = 'hu:snapshot:walmart-1038593372-2026-10-04t0120-query', 'hu:snapshot:walmart-1038593372-2026-10-04t0121-raw', 'hu:snapshot:w15-syn-walmart-1038593372-archive-2026-10-02'
    f.source(S, 'https://www.walmart.com/ip/Tru-Niagen-Nicotinamide-Riboside-300-mg-30-Vegetarian-Capsules/1038593372', 'Walmart item 1038593372', 'MARKETPLACE_LISTING')
    f.snapshot(SA, S, '2026-10-04T01:20:44Z', '2026-10-04T01:20:44Z', 'PARTIAL_EXCERPT', 'SYNTHETIC_FIXTURE')
    f.snapshot(SB, S, '2026-10-04T01:21:32Z', '2026-10-04T01:21:32Z', 'COMPLETE', 'RAW_BYTES',
               chash='sha256:3ea4967d42c1e9bf696a7c2af6ac2e82dc9c937eb29cff12503b6a8e720e3e66')
    L = lambda k: 'hu:locator:walmart-1038593372-' + k
    f.quote(L('a-price'), SA, 'current price $19.90')
    f.quote(L('a-roles'), SA, 'Sold by Sports-Med Fulfilled by Walmart')
    f.quote(L('a-title'), SA, 'Tru Niagen Nicotinamide Riboside Chloride 300 mg 30 Vegetarian Capsules for Cellular Health')
    f.section(L('b-price'), SB, '__NEXT_DATA__ props.pageProps.initialData.data.product.priceInfo.currentPrice', 'price 45 priceString $45.00 currencyUnit USD')
    f.section(L('b-seller'), SB, '__NEXT_DATA__ props.pageProps.initialData.data.product (seller fields)',
              'sellerId E4E44D0D801E45C8A50F187A7AB1A8B0 sellerName BLUE PEAK DISTRIBUTOR INC sellerDisplayName Sports-Med sellerType EXTERNAL wfsEnabled true catalogSellerId 2924')
    f.section(L('b-upc'), SB, '__NEXT_DATA__ props.pageProps.initialData.data.product.upc', 'upc 850015311116')
    f.section(L('b-availability'), SB, '__NEXT_DATA__ props.pageProps.initialData.data.product.availabilityStatus', 'availabilityStatus IN_STOCK')
    f.section(L('b-title'), SB, '__NEXT_DATA__ props.pageProps.initialData.data.product.name', 'Tru Niagen Nicotinamide Riboside Chloride, 300 mg, 30 Vegetarian Capsules')
    ML, OF = 'hu:listing:walmart-us-1038593372', 'hu:offer:walmart-us-1038593372-sports-med'
    f.node(['MerchantListing', 'Entity'], ML, {'merchantListingId': '1038593372', 'marketplace': 'walmart.com', 'commercePlatform': 'WALMART_MARKETPLACE', 'marketplaceRegion': 'US',
           'title': 'Tru Niagen Nicotinamide Riboside Chloride, 300 mg, 30 Vegetarian Capsules',
           'canonicalUrl': 'https://www.walmart.com/ip/Tru-Niagen-Nicotinamide-Riboside-300-mg-30-Vegetarian-Capsules/1038593372'})
    for tid, sch, val, loc in [('hu:trade-id:walmart-item-1038593372', 'WALMART_ITEM_ID', '1038593372', L('b-seller')),
                               ('hu:trade-id:walmart-displayed-upc-850015311116', 'UPC_AS_DISPLAYED_BY_WALMART', '850015311116', L('b-upc'))]:
        f.node(['TradeItemIdentifier', 'Identifier', 'Entity'], tid, {'scheme': sch, 'issuer': 'Walmart', 'value': val, 'jurisdiction': 'US'})
        f.assertion('hu:assertion:walmart-1038593372-identified-by-' + opaque(tid), 'IDENTIFIED_BY', 'MerchantListing', ML, 'TradeItemIdentifier', tid,
                    locs=[loc], extra={'predicateClass': 'IDENTITY'}, edge=True)
    f.node(['Offer', 'VersionedState'], OF, {'offerKind': 'PURCHASE', 'currency': 'USD', 'itemCondition': 'NEW', 'sellerOfferRef': '6B703781AD47343680CA645C778BE7D6',
           'observedAt': dt('2026-10-04T01:20:44Z'), 'payloadHash': sha('PURCHASE|USD|NEW|null|6B703781AD47343680CA645C778BE7D6')})
    f.rel('MerchantListing', ML, 'HAS_OFFER', 'Offer', OF)
    f.assertion('hu:assertion:walmart-hosts-listing-1038593372-2026-10-04', 'HOSTS_LISTING', 'Organization', 'hu:org:walmart-marketplace-us', 'MerchantListing', ML,
                locs=[L('a-roles'), L('b-seller')], extra={'predicateClass': 'ROLE'}, edge=True)
    f.assertion('hu:assertion:sports-med-seller-of-record-1038593372-2026-10-04', 'SELLER_OF_RECORD_FOR', 'Organization', 'hu:org:seller-account-walmart-sports-med', 'Offer', OF,
                locs=[L('a-roles'), L('b-seller')], extra={'predicateClass': 'ROLE'}, edge=True)
    f.assertion('hu:assertion:walmart-fulfills-1038593372-2026-10-04', 'FULFILLS_OFFER', 'Organization', 'hu:org:walmart-marketplace-us', 'Offer', OF,
                locs=[L('a-roles')], extra={'predicateClass': 'ROLE'}, edge=True)
    f.assertion('hu:assertion:sports-med-has-walmart-seller-id', 'HAS_IDENTIFIER', 'Organization', 'hu:org:seller-account-walmart-sports-med', 'Identifier',
                'hu:identifier:walmart-seller-e4e44d0d801e45c8a50f187a7ab1a8b0', locs=[L('b-seller')], extra={'predicateClass': 'IDENTITY'}, edge=True, edge_extra={'isPrimary': True})
    f.node(['ResolutionHypothesis', 'EvidenceAssessment'], 'hu:resolution:walmart-sports-med-is-blue-peak-distributor', {
        'assessmentType': 'ResolutionHypothesis', 'methodVersion': 'w15-seller-account-resolution/v0', 'status': 'PROPOSED', 'recordedAt': dt(COMMIT),
        'resolutionType': 'SELLER_ACCOUNT_OPERATED_BY_LEGAL_ENTITY', 'score': 0.8, 'resolutionStatus': 'PROPOSED',
        'rationale': 'Walmart page data pairs sellerDisplayName "Sports-Med" with sellerName "BLUE PEAK DISTRIBUTOR INC" under one sellerId; no registry record captured.'})
    f.rel('ResolutionHypothesis', 'hu:resolution:walmart-sports-med-is-blue-peak-distributor', 'PROPOSES_MATCH', 'Organization', 'hu:org:seller-account-walmart-sports-med')
    f.rel('ResolutionHypothesis', 'hu:resolution:walmart-sports-med-is-blue-peak-distributor', 'PROPOSES_MATCH', 'Organization', 'hu:org:blue-peak-distributor-inc')
    f.rel('ResolutionHypothesis', 'hu:resolution:walmart-sports-med-is-blue-peak-distributor', 'SUPPORTED_BY', 'SourceLocator', L('b-seller'))
    f.c('Two captures, two observations (never averaged). Capture A is an LLM direct quote; capture B is the page\'s structured data.')
    f.price('hu:price-obs:walmart-1038593372-2026-10-04t0120-one-time-query', OF, 19.90, 'USD', '2026-10-04T01:20:44Z', 'ONE_TIME', None, L('a-price'),
            'LLM_DIRECT_QUOTE', 'current price $19.90', region='US')
    f.price('hu:price-obs:walmart-1038593372-2026-10-04t0121-one-time-raw', OF, 45.00, 'USD', '2026-10-04T01:21:32Z', 'ONE_TIME', 'IN_STOCK', L('b-price'),
            'RAW_STRUCTURED_DATA', '$45.00', region='US-MD')
    f.c('SYNTHETIC late arrival: archive capture retrieved 2026-10-12 of the page as displayed on 2026-10-02; recorded 2026-10-12, valid-time 2026-10-02.')
    LATE = '2026-10-12T09:00:00Z'
    f.snapshot(SC, S, LATE, '2026-10-02T15:00:00Z', 'PARTIAL_EXCERPT', 'SYNTHETIC_FIXTURE', archive='https://web.archive.org/web/20261002150000/https://www.walmart.com/ip/1038593372 (SYNTHETIC)', ts=LATE)
    f.quote(L('c-price'), SC, 'current price $44.00 (SYNTHETIC)', ts=LATE)
    f.price('hu:price-obs:w15-syn-walmart-1038593372-2026-10-02-archive', OF, 44.00, 'USD', '2026-10-02T15:00:00Z', 'ONE_TIME', 'IN_STOCK', L('c-price'),
            'HTML_SELECTOR', 'current price $44.00 (SYNTHETIC)', region='US', ts=LATE)
    f.c('No LISTING_FOR. Unresolved identity is an assessment, kept PROPOSED/UNRESOLVED; CQ-CM-02 answers "identity unknown".')
    CM = 'hu:commerce-match:walmart-1038593372-to-tru-niagen-300mg-30ct'
    f.node(['CommerceMatch', 'EvidenceAssessment'], CM, {'assessmentType': 'CommerceMatch', 'methodVersion': 'w15-gtin-title-match/v0', 'status': 'PROPOSED',
           'recordedAt': dt(COMMIT), 'matchKind': 'LISTING_TO_ITEM', 'matchOutcome': 'UNRESOLVED', 'score': 0.5,
           'rationale': 'Title and brand fit Tru Niagen 300mg 30 capsules, but the displayed UPC 850015311116 differs from the brand\'s current 30-count GTIN 850015311857 (truniagen.com JSON). Could be an earlier package/label version or a different package; label not captured. Not determinable.'})
    for lab, u in [('MerchantListing', ML), ('PackageConfiguration', 'hu:package-configuration:tru-niagen-300mg-30ct'), ('ProductVariant', 'hu:product-variant:tru-niagen-300mg-us-capsule')]:
        f.rel('CommerceMatch', CM, 'MATCHES_COMMERCE_ITEM', lab, u)
    f.rel('CommerceMatch', CM, 'SUPPORTED_BY', 'SourceLocator', L('b-upc'))
    f.rel('CommerceMatch', CM, 'SUPPORTED_BY', 'SourceLocator', L('b-title'))
    f.rel('CommerceMatch', CM, 'WAS_GENERATED_BY', 'Activity', 'hu:activity:w15-commerce-match-2026-10-04')
    f.c('Authorized-channel check: NOT_DETERMINABLE (no Tru Niagen authorized-reseller statement captured). A low price from an LLM capture is not a gray-market finding.')
    CM2 = 'hu:commerce-match:walmart-1038593372-authorized-channel'
    f.node(['CommerceMatch', 'EvidenceAssessment'], CM2, {'assessmentType': 'CommerceMatch', 'methodVersion': 'w15-authorized-channel/v0', 'status': 'PROPOSED',
           'recordedAt': dt(COMMIT), 'matchKind': 'AUTHORIZED_CHANNEL', 'matchOutcome': 'NOT_DETERMINABLE',
           'rationale': 'Third-party seller (sellerType EXTERNAL); brand authorized-reseller list not captured; the $19.90 capture is LLM-extracted and contradicted by the structured price $45.00 one minute later.'})
    for lab, u in [('Offer', OF), ('Organization', 'hu:org:seller-account-walmart-sports-med')]:
        f.rel('CommerceMatch', CM2, 'MATCHES_COMMERCE_ITEM', lab, u)
    f.rel('CommerceMatch', CM2, 'SUPPORTED_BY', 'SourceLocator', L('b-seller'))
    f.st(f"MATCH (o:Offer {{uid: {q(OF)}}}) SET o.availabilityStatus = 'IN_STOCK', o.firstObservedAt = datetime('2026-10-04T01:20:44Z'), o.lastObservedAt = datetime('2026-10-04T01:21:32Z'), o.projectedFromPriceObservationUid = 'hu:price-obs:walmart-1038593372-2026-10-04t0121-one-time-raw'")
    return f

# ======================================================================================================================
# 05 affiliate link and listing-title amounts
# ======================================================================================================================
def f05():
    f = Fx(COMMIT)
    header(f, '05 -- affiliate links (Amazon Associates tag) and listing-title amounts that never become label declarations (CQ-CM-01/04, CQ-AX-17).', [
        'PUBLIC records, NEW_RETRIEVAL 2026-10-04T01:22:47Z: fastlifehacks.com "Rhonda Patrick Supplement List" (by John Alexander; published',
        '2018-01-27, "Last Updated: September 23, 2026"). Links: anchor "Tru Niagen Pro" -> https://www.amazon.com/dp/B0CLQZHVHL?...&tag=partnerid1275-20...;',
        'anchor "Tru Niagen" -> https://www.amazon.com/dp/B07Y2ZGM48?...&tag=partnerid1275-20... (a TWO-BOTTLE listing). Text: "The regular Tru Niagen',
        'product is 300 mg per capsule." and "She has no affiliation with the brands mentioned." Disclosure (search snippet 01:22:42Z): "as an Amazon',
        'Associate, I earn from qualifying purchases". Titles from the Amazon all-offers capture of B07TK5K5TQ (01:19:48Z, recommendation list).',
        'The affiliate is the page author (tag holder per the first-person disclosure), NOT the subject of the article; AFFILIATE_FOR_OFFER is PROPOSED',
        'because the tag-to-person link rests on a search snippet. The featured offer behind the affiliate link was not captured: an Offer placeholder',
        'with NO seller of record stands for it (seller unknown, never inferred). Titles "1000mg", "300mg", "300 mg" are LISTING_TITLE_AMOUNT',
        'assertions on listings; no LabelDeclaration or QuantityDeclaration is created from them ([LISTING_TITLE_AMOUNT, LABEL_DECLARED_AMOUNT]).'])
    S, SN = 'hu:source:fastlifehacks-rhonda-patrick-supplements', 'hu:snapshot:fastlifehacks-rhonda-patrick-2026-10-04t0122'
    f.source(S, 'https://fastlifehacks.com/dr-rhonda-patricks-supplements-list/', 'Rhonda Patrick Supplement List - with Brands (2026)', 'THIRD_PARTY_PROFILE_PAGE')
    f.snapshot(SN, S, '2026-10-04T01:22:47Z', '2026-10-04T01:22:47Z', 'PARTIAL_EXCERPT', 'SYNTHETIC_FIXTURE', published='2018-01-27T21:34:08Z',
               notice='Last Updated: September 23, 2026')
    SS, SNS = 'hu:source:firecrawl-search-fastlifehacks-disclosure', 'hu:snapshot:firecrawl-search-fastlifehacks-2026-10-04t0122'
    f.source(SS, 'https://fastlifehacks.com/dr-rhonda-patricks-supplements-list/#search-snippet', 'Search-result snippet of the fastlifehacks page (Firecrawl search)', 'THIRD_PARTY_PROFILE_PAGE')
    f.snapshot(SNS, SS, '2026-10-04T01:22:42Z', '2026-10-04T01:22:42Z', 'PARTIAL_EXCERPT', 'SYNTHETIC_FIXTURE')
    SA, SNA = 'hu:source:amazon-b07tk5k5tq-aod', 'hu:snapshot:amazon-b07tk5k5tq-aod-2026-10-04t0119'
    f.source(SA, 'https://www.amazon.com/dp/B07TK5K5TQ?aod=1', 'Amazon all offers B07TK5K5TQ', 'MARKETPLACE_LISTING')
    f.snapshot(SNA, SA, '2026-10-04T01:19:48Z', '2026-10-04T01:19:48Z', 'PARTIAL_EXCERPT', 'SYNTHETIC_FIXTURE')
    L = lambda k: 'hu:locator:fastlifehacks-' + k
    A = lambda k: 'hu:locator:amazon-b07tk5k5tq-aod-' + k
    URL1 = 'https://www.amazon.com/dp/B0CLQZHVHL?ref=t_ac_spc_accepted_tile&linkCode=tr1&tag=partnerid1275-20&linkId=B0CLQZHVHL_1783587143730'
    URL2 = 'https://www.amazon.com/dp/B07Y2ZGM48?ref=t_ac_spc_accepted_tile&linkCode=tr1&tag=partnerid1275-20&linkId=B07Y2ZGM48_1783587261301'
    f.quote(L('link-pro'), SN, '[Tru Niagen Pro](' + URL1 + ')')
    f.quote(L('link-regular'), SN, 'The regular [Tru Niagen](' + URL2 + ') product is 300 mg per capsule.')
    f.quote(L('no-affiliation'), SN, 'She has no affiliation with the brands mentioned.')
    f.quote('hu:locator:firecrawl-search-fastlifehacks-disclosure', SNS, 'Please note that where I link to products, some of these links are affiliate links. For example, as an Amazon Associate, I earn from qualifying ...')
    f.quote(A('title-b07tk5k5tq'), SNA, 'TRU NIAGEN NAD+ Supplement, Nicotinamide Riboside 300mg, 30 Daily Servings')
    f.quote(A('title-b0clqzhvhl'), SNA, 'TRU NIAGEN NAD+ Supplement, Nicotinamide Riboside 1000mg, 30 Daily Servings')
    f.quote(A('title-b07y2zgm48'), SNA, 'TRU NIAGEN NAD+ Supplement, NR 300mg, 60 Daily Servings | Two-bottle supply of patented Niagen NR')
    f.quote(A('roles-b07tk5k5tq'), SNA, 'Ships from Amazon.com Sold by TRU NIAGEN')
    listings = [('hu:listing:amazon-us-b0clqzhvhl', 'B0CLQZHVHL', 'TRU NIAGEN NAD+ Supplement, Nicotinamide Riboside 1000mg, 30 Daily Servings', A('title-b0clqzhvhl')),
                ('hu:listing:amazon-us-b07y2zgm48', 'B07Y2ZGM48', 'TRU NIAGEN NAD+ Supplement, NR 300mg, 60 Daily Servings | Two-bottle supply of patented Niagen NR', A('title-b07y2zgm48')),
                ('hu:listing:amazon-us-b07tk5k5tq', 'B07TK5K5TQ', 'TRU NIAGEN NAD+ Supplement, Nicotinamide Riboside 300mg, 30 Daily Servings', A('title-b07tk5k5tq'))]
    for uid, asin, title, loc in listings:
        f.node(['MerchantListing', 'Entity'], uid, {'merchantListingId': asin, 'marketplace': 'amazon.com', 'commercePlatform': 'AMAZON', 'marketplaceRegion': 'US',
               'title': title, 'canonicalUrl': 'https://www.amazon.com/dp/' + asin})
    f.c('Listing-title amounts: literal assertions on the LISTING (subject MerchantListing), never label declarations.')
    for uid, amt, txt, loc in [('hu:listing:amazon-us-b0clqzhvhl', 1000.0, 'Nicotinamide Riboside 1000mg', A('title-b0clqzhvhl')),
                               ('hu:listing:amazon-us-b07tk5k5tq', 300.0, 'Nicotinamide Riboside 300mg', A('title-b07tk5k5tq')),
                               ('hu:listing:amazon-us-b07y2zgm48', 300.0, 'NR 300mg', A('title-b07y2zgm48'))]:
        f.assertion('hu:assertion:' + opaque(uid) + '-title-amount', 'LISTING_TITLE_AMOUNT', 'MerchantListing', uid, locs=[loc],
                    value={'valueNumber': amt, 'unitCode': 'mg'}, extra={'predicateClass': 'QUANTITY', 'assertionBasis': 'MANUFACTURER_CLAIM'})
    f.assertion('hu:assertion:walmart-us-1038593372-title-amount', 'LISTING_TITLE_AMOUNT', 'MerchantListing', 'hu:listing:walmart-us-1038593372',
                locs=['hu:locator:walmart-1038593372-b-title'], value={'valueNumber': 300.0, 'unitCode': 'mg'},
                extra={'predicateClass': 'QUANTITY', 'assertionBasis': 'MANUFACTURER_CLAIM'})
    f.c('Two-bottle listing B07Y2ZGM48 is for a Bundle (2 x 30-count), not for the variant the anchor text names.')
    B = 'hu:bundle:tru-niagen-300mg-amazon-two-bottle'
    f.node(['Bundle', 'Entity'], B, {'name': 'Tru Niagen 300mg two-bottle supply (Amazon B07Y2ZGM48)', 'bundleKind': 'MULTI_PACK_SAME_ITEM'})
    BC = 'hu:bundle-component:tru-niagen-300mg-amazon-two-bottle-30ct'
    f.node(['BundleComponent', 'VersionedState'], BC, {'quantity': 2, 'quantityStatus': 'REPORTED', 'componentRole': 'PRIMARY', 'payloadHash': sha('2|REPORTED|PRIMARY|30ct')})
    f.rel('Bundle', B, 'HAS_BUNDLE_COMPONENT', 'BundleComponent', BC, {'orderIndex': 0})
    f.assertion('hu:assertion:amazon-two-bottle-component-30ct', 'COMPONENT_PRODUCT', 'BundleComponent', BC, 'PackageConfiguration', 'hu:package-configuration:tru-niagen-300mg-30ct',
                locs=[A('title-b07y2zgm48')], status='PROPOSED', extra={'predicateClass': 'IDENTITY', 'basisKind': 'HYPOTHESIS'}, edge=True)
    f.assertion('hu:assertion:amazon-b07y2zgm48-listing-for-two-bottle', 'LISTING_FOR', 'MerchantListing', 'hu:listing:amazon-us-b07y2zgm48', 'Bundle', B,
                locs=[A('title-b07y2zgm48')], status='PROPOSED', extra={'predicateClass': 'IDENTITY'}, edge=True)
    f.c('Affiliate links (immutable artifacts) -> listings.')
    for al, url, anchor, ml, loc in [('hu:affiliate-link:fastlifehacks-b0clqzhvhl-partnerid1275-20', URL1, 'Tru Niagen Pro', 'hu:listing:amazon-us-b0clqzhvhl', L('link-pro')),
                                     ('hu:affiliate-link:fastlifehacks-b07y2zgm48-partnerid1275-20', URL2, 'Tru Niagen', 'hu:listing:amazon-us-b07y2zgm48', L('link-regular'))]:
        f.node(['AffiliateLink', 'InformationArtifact'], al, {'url': url, 'contentHash': sha(url), 'trackingParameter': 'tag', 'trackingValue': 'partnerid1275-20',
               'affiliateProgram': 'AMAZON_ASSOCIATES', 'anchorText': anchor, 'sourceLocatorUid': loc, 'observedAt': dt('2026-10-04T01:22:47Z'),
               'publishedAt': dt('2018-01-27T21:34:08Z')})
        f.rel('AffiliateLink', al, 'LINKS_TO', 'MerchantListing', ml)
    OF = 'hu:offer:amazon-us-b0clqzhvhl-featured-seller-not-captured'
    f.node(['Offer', 'VersionedState'], OF, {'offerKind': 'PURCHASE', 'currency': 'USD', 'observedAt': dt('2026-10-04T01:19:48Z'), 'maturity': 'CANDIDATE',
           'description': 'Featured offer behind the affiliate link; seller of record not captured (placeholder; merge by EquivalenceAssessment when captured).',
           'payloadHash': sha('PURCHASE|USD|null|null|featured-not-captured')})
    f.rel('MerchantListing', 'hu:listing:amazon-us-b0clqzhvhl', 'HAS_OFFER', 'Offer', OF)
    f.assertion('hu:assertion:john-alexander-affiliate-for-b0clqzhvhl-offer', 'AFFILIATE_FOR_OFFER', 'Person', 'hu:person:john-alexander-fastlifehacks', 'Offer', OF,
                locs=[L('link-pro'), 'hu:locator:firecrawl-search-fastlifehacks-disclosure'], status='PROPOSED',
                extra={'predicateClass': 'ROLE', 'assertionBasis': 'UNSTATED'}, asserter=('Person', 'hu:person:john-alexander-fastlifehacks'), edge=True)
    return f

# ======================================================================================================================
# 06 recall scope and gray-market candidates (Rosabella moringa; FDA notice 2026-02-13) -- synthetic listing/unit
# ======================================================================================================================
def f06():
    f = Fx(COMMIT)
    header(f, '06 -- recalled-lot and unauthorized-channel CANDIDATES (OPEN-QUESTIONS quality/commerce 5; CQ-CM-C03).', [
        'PUBLIC record, NEW_RETRIEVAL 2026-10-04T01:23:28Z: FDA company announcement "Ambrosia Brands, LLC Recalls Rosabella Moringa Capsules',
        'Because of Possible Health Risk" (2026-02-13): lots incl. "5040273 | 05/2027"; "None of the impacted lots were sold by us on Amazon.com,',
        'however, while we do not have any authorized resellers on Amazon.com, we urge you to check your lot numbers for any Rosabella Moringa',
        'capsules purchased on the site." SYNTHETIC: an Amazon listing/offer by a third-party seller and one unit bought off the shelf by a public',
        'testing organization with printed lot 5040273. Both findings stay PROPOSED CommerceMatch candidates supported by the FDA locator; no',
        'property such as recalled/grayMarket/counterfeit exists on the offer, listing, unit or variant.'])
    S, SN = 'hu:source:fda-recall-ambrosia-rosabella-2026-02-13', 'hu:snapshot:fda-recall-ambrosia-rosabella-2026-10-04t0123'
    f.source(S, 'https://www.fda.gov/safety/recalls-market-withdrawals-safety-alerts/ambrosia-brands-llc-recalls-rosabella-moringa-capsules-because-possible-health-risk',
             'Ambrosia Brands, LLC Recalls Rosabella Moringa Capsules Because of Possible Health Risk', 'REGULATORY_RECORD')
    f.snapshot(SN, S, '2026-10-04T01:23:28Z', '2026-10-04T01:23:28Z', 'PARTIAL_EXCERPT', 'SYNTHETIC_FIXTURE', published='2026-02-13T00:00:00Z')
    L = lambda k: 'hu:locator:fda-recall-ambrosia-rosabella-' + k
    f.quote(L('amazon-resellers'), SN, 'None of the impacted lots were sold by us on Amazon.com, however, while we do not have any authorized resellers on Amazon.com, we urge you to check your lot numbers for any Rosabella Moringa capsules purchased on the site.')
    f.quote(L('lot-5040273'), SN, '| 5040273 | 05/2027 |')
    f.quote(L('lot-format'), SN, 'Lots impacted (all start with 1356 as the sku number, and end in a -1 or -2 after the lot code):')
    SS, SNS = 'hu:source:w15-syn-amazon-rosabella-listing', 'hu:snapshot:w15-syn-amazon-rosabella-2026-09-20'
    f.source(SS, 'urn:synthetic:w15:amazon-rosabella-moringa-listing', 'SYNTHETIC Amazon listing for Rosabella Moringa Capsules 60 count', 'MARKETPLACE_LISTING')
    f.snapshot(SNS, SS, '2026-09-20T12:00:00Z', '2026-09-20T12:00:00Z', 'PARTIAL_EXCERPT', 'SYNTHETIC_FIXTURE')
    f.quote('hu:locator:w15-syn-amazon-rosabella-roles', SNS, 'Ships from: W15 Synthetic Reseller Sold by: W15 Synthetic Reseller (SYNTHETIC)')
    ML, OF = 'hu:listing:w15-syn-amazon-rosabella-moringa-60ct', 'hu:offer:w15-syn-amazon-rosabella-moringa-60ct-reseller'
    f.node(['MerchantListing', 'Entity'], ML, {'merchantListingId': 'W15SYNASIN1', 'marketplace': 'amazon.com', 'marketplaceRegion': 'US',
           'title': 'Rosabella Moringa Capsules 60 Count (SYNTHETIC listing)', 'canonicalUrl': 'urn:synthetic:w15:amazon-rosabella-moringa-listing'})
    f.node(['Offer', 'VersionedState'], OF, {'offerKind': 'PURCHASE', 'currency': 'USD', 'itemCondition': 'NEW', 'observedAt': dt('2026-09-20T12:00:00Z'),
           'payloadHash': sha('PURCHASE|USD|NEW|null|synthetic-reseller')})
    f.rel('MerchantListing', ML, 'HAS_OFFER', 'Offer', OF)
    f.assertion('hu:assertion:w15-syn-reseller-seller-of-record-rosabella', 'SELLER_OF_RECORD_FOR', 'Organization', 'hu:org:w15-syn-amazon-seller-moringa', 'Offer', OF,
                locs=['hu:locator:w15-syn-amazon-rosabella-roles'], extra={'predicateClass': 'ROLE'}, edge=True)
    f.assertion('hu:assertion:w15-syn-amazon-hosts-rosabella', 'HOSTS_LISTING', 'Organization', 'hu:org:amazon-marketplace-us', 'MerchantListing', ML,
                locs=['hu:locator:w15-syn-amazon-rosabella-roles'], extra={'predicateClass': 'ROLE'}, edge=True)
    f.assertion('hu:assertion:w15-syn-rosabella-listing-for-60ct', 'LISTING_FOR', 'MerchantListing', ML, 'PackageConfiguration', 'hu:package-configuration:rosabella-moringa-60ct',
                locs=['hu:locator:w15-syn-amazon-rosabella-roles'], extra={'predicateClass': 'IDENTITY'}, edge=True)
    f.price('hu:price-obs:w15-syn-amazon-rosabella-2026-09-20-one-time', OF, 24.99, 'USD', '2026-09-20T12:00:00Z', 'ONE_TIME', 'IN_STOCK',
            'hu:locator:w15-syn-amazon-rosabella-roles', 'MANUAL_TRANSCRIPTION', '$24.99 (SYNTHETIC)', region='US')
    CM1 = 'hu:commerce-match:w15-syn-rosabella-offer-authorized-channel'
    f.node(['CommerceMatch', 'EvidenceAssessment'], CM1, {'assessmentType': 'CommerceMatch', 'methodVersion': 'w15-authorized-channel/v0', 'status': 'PROPOSED',
           'recordedAt': dt(COMMIT), 'matchKind': 'AUTHORIZED_CHANNEL', 'matchOutcome': 'NO_AUTHORIZATION_FOUND', 'score': 0.7,
           'rationale': 'Brand statement of 2026-02-13 (FDA-published company announcement): no authorized resellers on Amazon.com. The offer was observed 2026-09-20; the statement\'s validity after 2026-02-13 is not established. Unauthorized-channel CANDIDATE, not a counterfeit finding.'})
    for lab, u in [('Offer', OF), ('Organization', 'hu:org:w15-syn-amazon-seller-moringa'), ('Organization', 'hu:org:ambrosia-brands-llc')]:
        f.rel('CommerceMatch', CM1, 'MATCHES_COMMERCE_ITEM', lab, u)
    f.rel('CommerceMatch', CM1, 'SUPPORTED_BY', 'SourceLocator', L('amazon-resellers'))
    f.c('SYNTHETIC public testing purchase: one unit, lot code as printed; UNIT_FROM_LOT is PROPOSED (printed code parsed by rule).')
    SU, SNU = 'hu:source:w15-syn-lab-purchase-record', 'hu:snapshot:w15-syn-lab-purchase-record-2026-09-25'
    f.source(SU, 'urn:synthetic:w15:lab-purchase-record', 'SYNTHETIC public test report purchase record', 'AUDIT_REPORT')
    f.snapshot(SNU, SU, '2026-09-25T12:00:00Z', '2026-09-25T12:00:00Z', 'PARTIAL_EXCERPT', 'SYNTHETIC_FIXTURE')
    f.quote('hu:locator:w15-syn-lab-purchase-lot', SNU, 'Lot 13565040273-1 EXP 05/2027, purchased 2026-09-22 from the Amazon offer (SYNTHETIC)')
    U = 'hu:individual-unit:w15-syn-rosabella-unit-0001'
    f.node(['IndividualUnit', 'Entity'], U, {'lotCodeAsPrinted': '13565040273-1', 'expiryTextAsPrinted': 'EXP 05/2027', 'acquiredFromOfferUid': OF,
           'acquisitionContext': 'PUBLIC_TESTING_PURCHASE'})
    f.assertion('hu:assertion:w15-syn-unit-from-lot-5040273', 'UNIT_FROM_LOT', 'IndividualUnit', U, 'ProductLot', 'hu:lot:rosabella-moringa-5040273',
                locs=['hu:locator:w15-syn-lab-purchase-lot'], status='PROPOSED', extra={'predicateClass': 'IDENTITY', 'basisKind': 'HYPOTHESIS',
                'derivationRule': 'rosabella-printed-code: strip leading 1356 sku and trailing -1/-2'}, edge=True)
    CM2 = 'hu:commerce-match:w15-syn-rosabella-unit-recall-scope'
    f.node(['CommerceMatch', 'EvidenceAssessment'], CM2, {'assessmentType': 'CommerceMatch', 'methodVersion': 'w15-recall-scope/v0', 'status': 'PROPOSED',
           'recordedAt': dt(COMMIT), 'matchKind': 'RECALL_SCOPE', 'matchOutcome': 'IN_SCOPE', 'score': 0.9,
           'rationale': 'Printed code 1356 + 5040273 + -1 matches the notice\'s lot format and lists lot 5040273 (exp 05/2027). Recall exposure CANDIDATE pending review; the recall event itself is W13\'s record.'})
    for lab, u in [('IndividualUnit', U), ('ProductLot', 'hu:lot:rosabella-moringa-5040273'), ('Offer', OF)]:
        f.rel('CommerceMatch', CM2, 'MATCHES_COMMERCE_ITEM', lab, u)
    f.rel('CommerceMatch', CM2, 'SUPPORTED_BY', 'SourceLocator', L('lot-5040273'))
    f.rel('CommerceMatch', CM2, 'SUPPORTED_BY', 'SourceLocator', L('lot-format'))
    f.rel('CommerceMatch', CM2, 'SUPPORTED_BY', 'SourceLocator', 'hu:locator:w15-syn-lab-purchase-lot')
    f.c('SYNTHETIC inventory record of the reseller (merchant SKU) tied to the package; recall exposure of the inventory is also only a candidate.')
    INV = 'hu:inventory-item:w15-syn-reseller-sku-rbm60'
    f.node(['InventoryItem', 'Entity'], INV, {'merchantInventoryId': 'RBM-60-SYN', 'merchantOrganizationUid': 'hu:org:w15-syn-amazon-seller-moringa'})
    f.assertion('hu:assertion:w15-syn-inventory-instance-of-rosabella-60ct', 'INVENTORY_INSTANCE_OF', 'InventoryItem', INV, 'PackageConfiguration', 'hu:package-configuration:rosabella-moringa-60ct',
                locs=['hu:locator:w15-syn-amazon-rosabella-roles'], status='PROPOSED', extra={'predicateClass': 'IDENTITY'}, edge=True)
    return f

# ======================================================================================================================
# 07 negatives: must fail (each block names the validator rows it must produce)
# ======================================================================================================================
def f07():
    f = Fx(COMMIT)
    f.c('W15 fixture 07 -- NEGATIVE cases (must produce the validator rows named per block). Load after 00 and 01 (and 05 for N7).')
    f.c('SYNTHETIC. Never load into a production database. Every statement binds its own nodes by uid.')
    f.blank()
    f.c('N1 [HOSTS_LISTING, SELLS_PRODUCT]: Amazon "sells" Tru Niagen Beauty because it hosts B0FS82B35K. Expect V-326c, V-112 FORBIDDEN_IMPLICATION_AMONG_DERIVATION_INPUTS, V-W15-01.')
    f.rel('Organization', 'hu:org:amazon-marketplace-us', 'SELLS_PRODUCT', 'ProductVariant', 'hu:product-variant:tru-niagen-beauty-us-30ct', {
        'derivationRule': 'w15-neg-sells-from-hosting', 'derivedFromAssertionUids': ['hu:assertion:amazon-hosts-listing-b0fs82b35k-2026-10-04'], 'derivedAt': dt(COMMIT)})
    f.c('N2 [FULFILLS_OFFER, SELLS_PRODUCT]: Amazon "sells" because it ships. Different target (variant 300mg) so N1/N2 stay separate edges. Expect V-326c, V-112, V-W15-01.')
    f.rel('Organization', 'hu:org:amazon-marketplace-us', 'SELLS_PRODUCT', 'ProductVariant', 'hu:product-variant:tru-niagen-300mg-us-capsule', {
        'derivationRule': 'w15-neg-sells-from-fulfilment', 'derivedFromAssertionUids': ['hu:assertion:amazon-fulfills-offer-b0fs82b35k-2026-10-04'], 'derivedAt': dt(COMMIT)})
    f.c('N3 SELLS_PRODUCT with no citation at all. Expect V-326a, V-112 NO_CITATION, V-W15-01.')
    f.rel('Organization', 'hu:org:walmart-marketplace-us', 'SELLS_PRODUCT', 'ProductVariant', 'hu:product-variant:tru-niagen-300mg-us-capsule', {'derivedAt': dt(COMMIT)})
    f.c('N4 SELLER_OF_RECORD_FOR written from fulfilment, without an assertion, on the B0FS82B35K offer that already has a seller. Expect V-326b (orgFulfillsTheOffer true, orgHostsTheListing true), V-327, V-101.')
    f.st("MATCH (o:Organization {uid: 'hu:org:amazon-marketplace-us'}), (off:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'})\nMERGE (o)-[r:SELLER_OF_RECORD_FOR {relationshipUid: 'hu:rel:w15-neg-amazon-sor-from-fulfilment'}]->(off)\nON CREATE SET r.recordedFrom = datetime('2026-10-04T02:00:00Z'), r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN'")
    f.c('N5 averaged price without a kind, and a non-catalog kind. Expect V-328 (two rows).')
    f.node(['PriceObservation', 'Occurrence'], 'hu:price-obs:w15-neg-averaged', {'amount': 45.55, 'currency': 'USD', 'observedAt': dt('2026-10-04T01:19:18Z'),
           'priceTextVerbatim': 'average of 49.00 and 41.65 and 44.10 (WRONG)'})
    f.node(['PriceObservation', 'Occurrence'], 'hu:price-obs:w15-neg-kind-average', {'amount': 45.55, 'currency': 'USD', 'observedAt': dt('2026-10-04T01:19:18Z'), 'priceKind': 'AVERAGE'})
    f.rel('Offer', 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new', 'HAS_PRICE_OBSERVATION', 'PriceObservation', 'hu:price-obs:w15-neg-averaged')
    f.rel('Offer', 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new', 'HAS_PRICE_OBSERVATION', 'PriceObservation', 'hu:price-obs:w15-neg-kind-average')
    f.c('N6 live-style Listing price with no PriceObservation behind it (legacy label Listing kept during migration). Expect V-329 and V-W15-03.')
    f.st("MERGE (l:Listing:MerchantListing:Entity {uid: 'hu:listing:w15-neg-unbacked-price'})\nON CREATE SET l.id = 'w15-neg-unbacked-price', l.entityType = 'MerchantListing', l.priceAmount = 39.0, l.currency = 'USD', l.availabilityStatus = 'IN_STOCK', l.currentAsOf = datetime('2026-10-04T02:00:00Z'), l.privacyClass = 'PUBLIC', l.createdAt = datetime('2026-10-04T02:00:00Z'), l.updatedAt = datetime('2026-10-04T02:00:00Z')")
    f.c('N7 [LISTING_TITLE_AMOUNT, LABEL_DECLARED_AMOUNT]: a "label declaration" built from the B0CLQZHVHL title on the marketplace snapshot. Expect V-W15-04 (two rows).')
    f.node(['LabelDeclaration', 'InformationArtifact'], 'hu:label-declaration:w15-neg-from-title', {'verbatimText': 'Nicotinamide Riboside 1000mg', 'declarationKind': 'OTHER_DIETARY_INGREDIENT'})
    f.rel('SourceSnapshot', 'hu:snapshot:amazon-b07tk5k5tq-aod-2026-10-04t0119', 'HAS_DECLARATION', 'LabelDeclaration', 'hu:label-declaration:w15-neg-from-title')
    f.node(['QuantityDeclaration', 'InformationArtifact'], 'hu:quantity-declaration:w15-neg-from-title', {'value': 1000.0, 'unitCode': 'mg', 'amountReferent': 'LISTED_INGREDIENT_AS_LISTED'})
    f.rel('LabelDeclaration', 'hu:label-declaration:w15-neg-from-title', 'HAS_QUANTITY_DECLARATION', 'QuantityDeclaration', 'hu:quantity-declaration:w15-neg-from-title')
    f.rel('QuantityDeclaration', 'hu:quantity-declaration:w15-neg-from-title', 'DERIVED_FROM_ASSERTION', 'Assertion', 'hu:assertion:amazon-us-b0clqzhvhl-title-amount')
    f.c('N8 commerce risk written as properties instead of CommerceMatch candidates. Expect V-W15-07 (two rows).')
    f.st("MATCH (o:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-zk-inc'}) SET o.isGrayMarket = true")
    f.st("MATCH (l:MerchantListing {uid: 'hu:listing:amazon-us-b000qsnygi'}) SET l.recalled = false")
    f.c('N9 LISTING_FOR written without an assertion (silent identity). Expect V-101 (catalog list extended by W15), V-W15-02.')
    f.st("MATCH (l:MerchantListing {uid: 'hu:listing:walmart-us-1038593372'}), (p:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-30ct'})\nMERGE (l)-[r:LISTING_FOR {relationshipUid: 'hu:rel:w15-neg-silent-listing-for'}]->(p)\nON CREATE SET r.recordedFrom = datetime('2026-10-04T02:00:00Z'), r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN'")
    f.c('N10 [AFFILIATE_FOR_OFFER, ENDORSES_PRODUCT]: endorsement derived from the affiliate link. Expect V-112 FORBIDDEN_IMPLICATION_AMONG_DERIVATION_INPUTS, V-W15-06.')
    f.rel('Person', 'hu:person:john-alexander-fastlifehacks', 'ENDORSES_PRODUCT', 'ProductVariant', 'hu:product-variant:tru-niagen-pro-1000mg-us-capsule', {
        'derivationRule': 'w15-neg-endorse-from-affiliate', 'derivedFromAssertionUids': ['hu:assertion:john-alexander-affiliate-for-b0clqzhvhl-offer'], 'derivedAt': dt(COMMIT)})
    f.c('N11 SELLS_PRODUCT from a seller-of-record assertion whose listing identity is only an UNRESOLVED CommerceMatch (Walmart, no LISTING_FOR). Expect V-W15-01 (V-326c passes: input predicate is right).')
    f.rel('Organization', 'hu:org:seller-account-walmart-sports-med', 'SELLS_PRODUCT', 'ProductVariant', 'hu:product-variant:tru-niagen-300mg-us-capsule', {
        'derivationRule': 'w15-sells-product-from-seller-of-record/v1', 'derivedFromAssertionUids': ['hu:assertion:sports-med-seller-of-record-1038593372-2026-10-04'], 'derivedAt': dt(COMMIT)})
    return f

# ======================================================================================================================
# 08 legacy migration (live Listing / LISTS / LISTS_PRODUCT / ListingSnapshot) -> final shapes
# ======================================================================================================================
def f08():
    f = Fx('2026-10-04T03:00:00Z')
    f.c('W15 fixture 08 -- live-shaped legacy records (SYNTHETIC) and the migration statements of migration-map.yaml applied to them.')
    f.c('Part A writes what the live API stores today (label Listing, LISTS with listRole, LISTS_PRODUCT with TemporalMetadata, ListingSnapshot via')
    f.c('HAS_SNAPSHOT, price fields on the listing). Part B is the migration: relabel, split roles into PROPOSED review assertions (never ACCEPTED')
    f.c('without a capture), turn the snapshot into a SourceSnapshot + Offer + PriceObservation, keep LISTS/LISTS_PRODUCT read-only (LEGACY_UNDATED).')
    f.blank()
    f.c('Part A (live shape).')
    f.st("MERGE (l:Listing {id: 'w15-legacy-listing-1'})\nON CREATE SET l.name = 'Legacy listing (synthetic)', l.url = 'https://shop.example.invalid/p/1', l.priceAmount = 59.0, l.currency = 'USD', l.availabilityStatus = 'in stock', l.capturedAt = datetime('2025-11-02T10:00:00Z'), l.currentAsOf = datetime('2025-11-02T10:05:00Z'), l.listingType = 'product', l.commercialTermsSummary = 'Subscribe and save 15%', l.createdAt = datetime('2025-11-02T10:05:00Z'), l.updatedAt = datetime('2025-11-02T10:05:00Z')")
    f.st("MERGE (o:Organization {id: 'w15-legacy-shop-org'}) ON CREATE SET o.name = 'Legacy Shop Inc (synthetic)', o.createdAt = datetime('2025-11-02T10:05:00Z'), o.updatedAt = datetime('2025-11-02T10:05:00Z')")
    f.st("MATCH (l:Listing {id: 'w15-legacy-listing-1'}), (o:Organization {id: 'w15-legacy-shop-org'}) MERGE (o)-[r:LISTS]->(l) ON CREATE SET r.listRole = 'seller', r.localPriceAmount = 59.0, r.localCurrency = 'USD'")
    f.st("MERGE (p:Product {id: 'w15-legacy-product-1'}) ON CREATE SET p.name = 'Legacy product (synthetic)', p.createdAt = datetime('2025-11-02T10:05:00Z'), p.updatedAt = datetime('2025-11-02T10:05:00Z')")
    f.st("MATCH (l:Listing {id: 'w15-legacy-listing-1'}), (p:Product {id: 'w15-legacy-product-1'}) MERGE (l)-[r:LISTS_PRODUCT]->(p) ON CREATE SET r.validFrom = datetime('2025-11-02T00:00:00Z'), r.confidence = 0.8")
    f.st("MERGE (s:ListingSnapshot {id: 'w15-legacy-listing-1-snap-1'}) ON CREATE SET s.name = 'snapshot', s.url = 'https://shop.example.invalid/p/1', s.priceAmount = 59.0, s.currency = 'USD', s.availabilityStatus = 'in stock', s.capturedAt = datetime('2025-11-02T10:00:00Z'), s.validFrom = datetime('2025-11-02T10:00:00Z'), s.createdAt = datetime('2025-11-02T10:05:00Z'), s.updatedAt = datetime('2025-11-02T10:05:00Z')")
    f.st("MATCH (l:Listing {id: 'w15-legacy-listing-1'}), (s:ListingSnapshot {id: 'w15-legacy-listing-1-snap-1'}) MERGE (l)-[:HAS_SNAPSHOT]->(s)")
    f.c('Part B (migration M-01..M-07, see migration-map.yaml and 07-operations.md section 5).')
    f.st("MATCH (l:Listing) WHERE l.uid IS NULL SET l.uid = 'hu:listing:' + l.id, l:MerchantListing:Entity, l.entityType = 'MerchantListing', l.canonicalUrl = coalesce(l.canonicalUrl, l.url), l.privacyClass = coalesce(l.privacyClass, 'PUBLIC')")
    f.st("MATCH (o:Organization) WHERE o.uid IS NULL AND o.id = 'w15-legacy-shop-org' SET o.uid = 'hu:org:' + o.id, o:Entity, o.entityType = 'Organization', o.privacyClass = 'PUBLIC'")
    f.st("MATCH (p:Product) WHERE p.uid IS NULL AND p.id = 'w15-legacy-product-1' SET p.uid = 'hu:product:' + p.id, p:Entity, p.entityType = 'Product', p.privacyClass = 'PUBLIC'")
    f.c('M-03: each ListingSnapshot -> Source (once per URL) + SourceSnapshot (observedAt = capturedAt, retrievedAt = createdAt, hash basis SYNTHETIC_FIXTURE because the bytes were never kept, completeness UNKNOWN).')
    f.st("MATCH (l:MerchantListing)-[:HAS_SNAPSHOT]->(ls:ListingSnapshot) WHERE ls.id = 'w15-legacy-listing-1-snap-1'\nMERGE (src:Source:Entity {uid: 'hu:source:legacy-' + l.id})\nON CREATE SET src.id = 'legacy-' + l.id, src.entityType = 'Source', src.canonicalUri = coalesce(ls.url, l.canonicalUrl), src.sourceKind = 'MARKETPLACE_LISTING', src.privacyClass = 'PUBLIC', src.createdAt = datetime('2026-10-04T03:00:00Z'), src.updatedAt = datetime('2026-10-04T03:00:00Z')\nMERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:legacy-' + ls.id})\nON CREATE SET sn.id = 'legacy-' + ls.id, sn.artifactType = 'SourceSnapshot', sn.canonicalUri = src.canonicalUri, sn.observedAt = ls.capturedAt, sn.retrievedAt = ls.createdAt, sn.contentHash = 'sha256:' + '0000000000000000000000000000000000000000000000000000000000000000', sn.contentHashBasis = 'SYNTHETIC_FIXTURE', sn.captureCompleteness = 'UNKNOWN', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-10-04T03:00:00Z'), sn.updatedAt = datetime('2026-10-04T03:00:00Z')\nMERGE (src)-[:HAS_SNAPSHOT]->(sn)")
    f.c('M-04: LISTS{listRole: seller} -> Offer (one per listing x seller) + PROPOSED SELLER_OF_RECORD_FOR review assertion (no locator: legacy rows were never captured), PriceObservation per snapshot price.')
    f.st("MATCH (o:Organization)-[r:LISTS]->(l:MerchantListing) WHERE r.listRole = 'seller' AND l.id = 'w15-legacy-listing-1'\nMERGE (off:Offer:VersionedState {uid: 'hu:offer:legacy-' + l.id + '-' + o.id})\nON CREATE SET off.id = 'legacy-' + l.id + '-' + o.id, off.stateType = 'Offer', off.offerKind = 'UNKNOWN', off.currency = r.localCurrency, off.termsText = l.commercialTermsSummary, off.payloadHash = 'sha256:legacy-migration-unhashed', off.privacyClass = 'PUBLIC', off.createdAt = datetime('2026-10-04T03:00:00Z'), off.updatedAt = datetime('2026-10-04T03:00:00Z')\nMERGE (l)-[:HAS_OFFER]->(off)\nMERGE (a:Assertion {uid: 'hu:assertion:legacy-sor-' + l.id + '-' + o.id})\nON CREATE SET a.id = 'legacy-sor-' + l.id + '-' + o.id, a.predicate = 'SELLER_OF_RECORD_FOR', a.status = 'PROPOSED', a.recordedAt = datetime('2026-10-04T03:00:00Z'), a.predicateClass = 'ROLE', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.assertionBasis = 'UNSTATED', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T03:00:00Z'), a.updatedAt = datetime('2026-10-04T03:00:00Z')\nMERGE (a)-[:HAS_SUBJECT]->(o)\nMERGE (a)-[:HAS_OBJECT]->(off)\nMERGE (o)-[e:SELLER_OF_RECORD_FOR {relationshipUid: 'hu:rel:legacy-sor-' + l.id + '-' + o.id}]->(off)\nON CREATE SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN'")
    f.st("MATCH (l:MerchantListing)-[:HAS_SNAPSHOT]->(ls:ListingSnapshot), (l)-[:HAS_OFFER]->(off:Offer) WHERE l.id = 'w15-legacy-listing-1' AND ls.priceAmount IS NOT NULL\nMERGE (po:PriceObservation:Occurrence {uid: 'hu:price-obs:legacy-' + ls.id})\nON CREATE SET po.id = 'legacy-' + ls.id, po.occurrenceType = 'PriceObservation', po.amount = ls.priceAmount, po.currency = ls.currency, po.observedAt = ls.capturedAt, po.startedAt = ls.capturedAt, po.priceKind = 'ONE_TIME', po.availabilityObserved = 'UNKNOWN', po.captureMethod = 'LEGACY_MIGRATION', po.sourceLocatorUid = null, po.privacyClass = 'PUBLIC', po.createdAt = datetime('2026-10-04T03:00:00Z'), po.updatedAt = datetime('2026-10-04T03:00:00Z')\nMERGE (off)-[:HAS_PRICE_OBSERVATION]->(po)")
    f.c('M-05: listing projections now name their backing observation; availability free text "in stock" is kept only in the legacy snapshot.')
    f.st("MATCH (l:MerchantListing)-[:HAS_OFFER]->(:Offer)-[:HAS_PRICE_OBSERVATION]->(po:PriceObservation) WHERE l.id = 'w15-legacy-listing-1'\nSET l.projectedFromPriceObservationUid = po.uid, l.lastObservedAt = po.observedAt, l.priceKindProjected = po.priceKind, l.availabilityStatus = po.availabilityObserved")
    f.c('M-06: ListingSnapshot nodes are relabelled as retired compatibility records (kept for audit; no API type) and detached from HAS_SNAPSHOT.')
    f.st("MATCH (l:MerchantListing)-[h:HAS_SNAPSHOT]->(ls:ListingSnapshot) WHERE l.id = 'w15-legacy-listing-1' SET ls:LegacyListingSnapshot REMOVE ls:ListingSnapshot DELETE h")
    return f

for name, fn in [('w15-00-common', f00), ('w15-01-amazon-host-seller-fulfiller', f01), ('w15-02-listing-merge-four-offers', f02),
                 ('w15-03-dtc-subscription-and-bundles', f03), ('w15-04-walmart-price-conflict-open-end-unresolved', f04),
                 ('w15-05-affiliate-and-title-amounts', f05), ('w15-06-recall-and-unauthorized-channel-candidates', f06),
                 ('w15-07-negatives-must-fail', f07), ('w15-08-legacy-listing-migration', f08)]:
    with open(os.path.join(OUT, name + '.cypher'), 'w') as fh:
        fh.write(fn().text())
    print('wrote', name)
