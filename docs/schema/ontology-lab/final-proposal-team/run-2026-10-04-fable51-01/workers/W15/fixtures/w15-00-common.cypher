// W15 fixture 00 -- common base (load first). Organizations, persons, agent/activities and minimal STUBS of W04/W12
// identities (ProductVariant, PackageConfiguration, Product, ProductLot) so this packet loads alone. W04/W12 own those types;
// the stubs carry only identity fields. Commit instant for all W15 records: 2026-10-04T02:00:00Z (after every capture).

MERGE (n:Agent:Entity {uid: 'hu:agent:w15-curation'})
ON CREATE SET n.id = 'w15-curation', n.name = 'W15 commerce curation (Opus 5.5 worker, manual review)', n.agentKind = 'HUMAN_OPERATED_TOOL', n.entityType = 'Agent', n.privacyClass = 'INTERNAL', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Activity:Occurrence {uid: 'hu:activity:w15-capture-2026-10-04'})
ON CREATE SET n.id = 'w15-capture-2026-10-04', n.activityKind = 'CAPTURE', n.methodVersion = 'firecrawl-scrape-maxAge0/2026-10-04', n.startedAt = datetime('2026-10-04T01:18:00Z'), n.endedAt = datetime('2026-10-04T01:24:00Z'), n.occurrenceType = 'Activity', n.privacyClass = 'INTERNAL', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Activity:Occurrence {uid: 'hu:activity:w15-commerce-match-2026-10-04'})
ON CREATE SET n.id = 'w15-commerce-match-2026-10-04', n.activityKind = 'RESOLUTION', n.methodVersion = 'w15-gtin-title-match/v0', n.startedAt = datetime('2026-10-04T02:00:00Z'), n.occurrenceType = 'Activity', n.privacyClass = 'INTERNAL', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');

// Marketplace operators and seller accounts. A seller display account is an Organization WITHOUT the LegalEntity label;
// its marketplace merchant id is an Identifier scoped by the marketplace; the legal entity is a ResolutionHypothesis (W01-SR-15b ruling).
MERGE (n:Organization:Entity {uid: 'hu:org:amazon-marketplace-us'})
ON CREATE SET n.id = 'amazon-marketplace-us', n.name = 'Amazon (amazon.com marketplace operator and retailer)', n.organizationType = 'MARKETPLACE', n.entityType = 'Organization', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Organization:Entity {uid: 'hu:org:walmart-marketplace-us'})
ON CREATE SET n.id = 'walmart-marketplace-us', n.name = 'Walmart (walmart.com marketplace operator)', n.organizationType = 'MARKETPLACE', n.entityType = 'Organization', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Organization:Entity {uid: 'hu:org:seller-account-amazon-tru-niagen'})
ON CREATE SET n.id = 'seller-account-amazon-tru-niagen', n.name = 'TRU NIAGEN (Amazon seller display name, merchant A1W0QC6JE0QLDF)', n.organizationType = 'UNKNOWN', n.entityType = 'Organization', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Organization:Entity {uid: 'hu:org:seller-account-amazon-my-nutrition-depot'})
ON CREATE SET n.id = 'seller-account-amazon-my-nutrition-depot', n.name = 'My Nutrition Depot (Amazon seller A2TXQHZ1OKWQ2N)', n.organizationType = 'RETAILER', n.entityType = 'Organization', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Organization:Entity {uid: 'hu:org:seller-account-amazon-zk-inc'})
ON CREATE SET n.id = 'seller-account-amazon-zk-inc', n.name = 'ZK-INC (Amazon seller A2BHMA3GTYX2GC)', n.organizationType = 'UNKNOWN', n.entityType = 'Organization', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Organization:Entity {uid: 'hu:org:seller-account-amazon-be-rebellion-usa'})
ON CREATE SET n.id = 'seller-account-amazon-be-rebellion-usa', n.name = 'BE REBELLION USA (Amazon seller A3Q3QEX08918FS)', n.organizationType = 'UNKNOWN', n.entityType = 'Organization', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Organization:Entity {uid: 'hu:org:seller-account-walmart-sports-med'})
ON CREATE SET n.id = 'seller-account-walmart-sports-med', n.name = 'Sports-Med (Walmart seller display name, seller id E4E44D0D801E45C8A50F187A7AB1A8B0)', n.organizationType = 'UNKNOWN', n.entityType = 'Organization', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Organization:Entity {uid: 'hu:org:truniagen-com-store-operator'})
ON CREATE SET n.id = 'truniagen-com-store-operator', n.name = 'truniagen.com store operator (merchant of record not displayed)', n.organizationType = 'UNKNOWN', n.entityType = 'Organization', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Organization:Entity {uid: 'hu:org:w15-syn-amazon-seller-moringa'})
ON CREATE SET n.id = 'w15-syn-amazon-seller-moringa', n.name = 'SYNTHETIC third-party Amazon seller account (moringa reseller)', n.organizationType = 'UNKNOWN', n.entityType = 'Organization', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Organization:Entity {uid: 'hu:org:w15-syn-testing-lab'})
ON CREATE SET n.id = 'w15-syn-testing-lab', n.name = 'SYNTHETIC public testing organization (off-the-shelf purchases)', n.organizationType = 'LABORATORY', n.entityType = 'Organization', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:LegalEntity:Organization:Entity {uid: 'hu:org:chromadex-inc'})
ON CREATE SET n.id = 'chromadex-inc', n.name = 'ChromaDex, Inc. (brand owner of Tru Niagen; renamed Niagen Bioscience)', n.organizationType = 'COMPANY', n.entityType = 'LegalEntity', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:LegalEntity:Organization:Entity {uid: 'hu:org:blue-peak-distributor-inc'})
ON CREATE SET n.id = 'blue-peak-distributor-inc', n.name = 'BLUE PEAK DISTRIBUTOR INC (legal seller name as exposed in Walmart page data)', n.organizationType = 'COMPANY', n.entityType = 'LegalEntity', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:LegalEntity:Organization:Entity {uid: 'hu:org:ambrosia-brands-llc'})
ON CREATE SET n.id = 'ambrosia-brands-llc', n.name = 'Ambrosia Brands, LLC (New York, NY; Rosabella brand)', n.organizationType = 'COMPANY', n.entityType = 'LegalEntity', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Person:Entity {uid: 'hu:person:john-alexander-fastlifehacks'})
ON CREATE SET n.id = 'john-alexander-fastlifehacks', n.name = 'John Alexander (byline, fastlifehacks.com)', n.entityType = 'Person', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');

// Seller-account identifiers (scheme, issuer, value). Shared values across issuers never merge identities (V-W00-04).
MERGE (n:Identifier:Entity {uid: 'hu:identifier:amazon-merchant-a1w0qc6je0qldf'})
ON CREATE SET n.id = 'amazon-merchant-a1w0qc6je0qldf', n.scheme = 'AMAZON_MERCHANT_ID', n.issuer = 'Amazon', n.value = 'A1W0QC6JE0QLDF', n.jurisdiction = 'US', n.entityType = 'Identifier', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Identifier:Entity {uid: 'hu:identifier:amazon-merchant-a2txqhz1okwq2n'})
ON CREATE SET n.id = 'amazon-merchant-a2txqhz1okwq2n', n.scheme = 'AMAZON_MERCHANT_ID', n.issuer = 'Amazon', n.value = 'A2TXQHZ1OKWQ2N', n.jurisdiction = 'US', n.entityType = 'Identifier', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Identifier:Entity {uid: 'hu:identifier:amazon-merchant-a2bhma3gtyx2gc'})
ON CREATE SET n.id = 'amazon-merchant-a2bhma3gtyx2gc', n.scheme = 'AMAZON_MERCHANT_ID', n.issuer = 'Amazon', n.value = 'A2BHMA3GTYX2GC', n.jurisdiction = 'US', n.entityType = 'Identifier', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Identifier:Entity {uid: 'hu:identifier:amazon-merchant-a3q3qex08918fs'})
ON CREATE SET n.id = 'amazon-merchant-a3q3qex08918fs', n.scheme = 'AMAZON_MERCHANT_ID', n.issuer = 'Amazon', n.value = 'A3Q3QEX08918FS', n.jurisdiction = 'US', n.entityType = 'Identifier', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Identifier:Entity {uid: 'hu:identifier:walmart-seller-e4e44d0d801e45c8a50f187a7ab1a8b0'})
ON CREATE SET n.id = 'walmart-seller-e4e44d0d801e45c8a50f187a7ab1a8b0', n.scheme = 'WALMART_SELLER_ID', n.issuer = 'Walmart', n.value = 'E4E44D0D801E45C8A50F187A7AB1A8B0', n.jurisdiction = 'US', n.entityType = 'Identifier', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');

// STUBS of W04 identities (uids follow W04 fixture w04-02 and examples/filing-vs-capability.cypher where they exist).
MERGE (n:Product:Entity {uid: 'hu:product:tru-niagen'})
ON CREATE SET n.id = 'tru-niagen', n.name = 'Tru Niagen', n.entityType = 'Product', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:ProductVariant:Entity {uid: 'hu:product-variant:tru-niagen-300mg-us-capsule'})
ON CREATE SET n.id = 'tru-niagen-300mg-us-capsule', n.name = 'Tru Niagen 300mg, 1 vegetarian capsule per serving (US)', n.jurisdiction = 'US', n.entityType = 'ProductVariant', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:ProductVariant:Entity {uid: 'hu:product-variant:tru-niagen-beauty-us-30ct'})
ON CREATE SET n.id = 'tru-niagen-beauty-us-30ct', n.name = 'Tru Niagen Beauty (US)', n.jurisdiction = 'US', n.entityType = 'ProductVariant', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:ProductVariant:Entity {uid: 'hu:product-variant:tru-niagen-immune-us-capsule'})
ON CREATE SET n.id = 'tru-niagen-immune-us-capsule', n.name = 'Tru Niagen Immune (US)', n.jurisdiction = 'US', n.entityType = 'ProductVariant', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:ProductVariant:Entity {uid: 'hu:product-variant:tru-niagen-pro-1000mg-us-capsule'})
ON CREATE SET n.id = 'tru-niagen-pro-1000mg-us-capsule', n.name = 'Tru Niagen Pro 1,000mg (US)', n.jurisdiction = 'US', n.entityType = 'ProductVariant', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:ProductVariant:Entity {uid: 'hu:product-variant:on-gsw-double-rich-chocolate-us'})
ON CREATE SET n.id = 'on-gsw-double-rich-chocolate-us', n.name = 'Optimum Nutrition Gold Standard 100% Whey, Double Rich Chocolate (US)', n.jurisdiction = 'US', n.entityType = 'ProductVariant', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:ProductVariant:Entity {uid: 'hu:product-variant:rosabella-moringa-capsules-us'})
ON CREATE SET n.id = 'rosabella-moringa-capsules-us', n.name = 'Rosabella Moringa Capsules (US)', n.jurisdiction = 'US', n.entityType = 'ProductVariant', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:PackageConfiguration:VersionedState {uid: 'hu:package-configuration:tru-niagen-300mg-30ct'})
ON CREATE SET n.id = 'tru-niagen-300mg-30ct', n.name = 'Tru Niagen 300mg bottle of 30', n.unitCount = 30, n.payloadHash = 'sha256:4a6260277e41546ab9c9adf176e01d944744e7879d57e205ec85ee52ad959d71', n.stateType = 'PackageConfiguration', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:PackageConfiguration:VersionedState {uid: 'hu:package-configuration:tru-niagen-300mg-90ct'})
ON CREATE SET n.id = 'tru-niagen-300mg-90ct', n.name = 'Tru Niagen 300mg bottle of 90', n.unitCount = 90, n.payloadHash = 'sha256:d4a41ce79061f68a4f3159cde8bcbdda56ca585cfa21f549a9a7b321c11ae27d', n.stateType = 'PackageConfiguration', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:PackageConfiguration:VersionedState {uid: 'hu:package-configuration:tru-niagen-immune-30ct'})
ON CREATE SET n.id = 'tru-niagen-immune-30ct', n.name = 'Tru Niagen Immune bottle of 30', n.unitCount = 30, n.payloadHash = 'sha256:feee10e68bee507661534a84b4a8ce4b50700f88fb8bc3b011f162f66408fbf9', n.stateType = 'PackageConfiguration', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:PackageConfiguration:VersionedState {uid: 'hu:package-configuration:on-gsw-double-rich-chocolate-5lb'})
ON CREATE SET n.id = 'on-gsw-double-rich-chocolate-5lb', n.name = 'ON Gold Standard Whey Double Rich Chocolate 5 lb', n.payloadHash = 'sha256:014808550495d300814cb12046882a9eb695234315b29d9d9d6b80507cdf07f5', n.stateType = 'PackageConfiguration', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:PackageConfiguration:VersionedState {uid: 'hu:package-configuration:rosabella-moringa-60ct'})
ON CREATE SET n.id = 'rosabella-moringa-60ct', n.name = 'Rosabella Moringa Capsules bottle of 60', n.unitCount = 60, n.payloadHash = 'sha256:d6f010c8de7cd6978ac6307ac99b099d733daf161fe7e24a39a407459028ee71', n.stateType = 'PackageConfiguration', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
// W04 HAS_PACKAGE_CONFIGURATION / HAS_VARIANT episodes needed by the SELLS_PRODUCT derivation path (stub assertions, OBSERVATION_ONLY).
MERGE (n:Assertion {uid: 'hu:assertion:w15-stub-tru-niagen-300mg-us-capsule-has-tru-niagen-300mg-30ct'})
ON CREATE SET n.id = 'w15-stub-tru-niagen-300mg-us-capsule-has-tru-niagen-300mg-30ct', n.predicate = 'HAS_PACKAGE_CONFIGURATION', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:2f89e77571cd70dfa76848ce061bb05d8005270fc19b904847671fde7e884f61', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:w15-stub-tru-niagen-300mg-us-capsule-has-tru-niagen-300mg-30ct'}), (b:ProductVariant {uid: 'hu:product-variant:tru-niagen-300mg-us-capsule'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w15-stub-tru-niagen-300mg-us-capsule-has-tru-niagen-300mg-30ct'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-30ct'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ProductVariant {uid: 'hu:product-variant:tru-niagen-300mg-us-capsule'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-30ct'})
MERGE (a)-[r:HAS_PACKAGE_CONFIGURATION {relationshipUid: 'hu:rel:w15-stub-tru-niagen-300mg-us-capsule-has-tru-niagen-300mg-30ct'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:w15-stub-tru-niagen-300mg-us-capsule-has-tru-niagen-300mg-30ct', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:w15-stub-tru-niagen-300mg-us-capsule-has-tru-niagen-300mg-90ct'})
ON CREATE SET n.id = 'w15-stub-tru-niagen-300mg-us-capsule-has-tru-niagen-300mg-90ct', n.predicate = 'HAS_PACKAGE_CONFIGURATION', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:5517e205f5bcc03206d928f0ae1c218a2fcccde9d55a0e1b1b2fc980be5969dc', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:w15-stub-tru-niagen-300mg-us-capsule-has-tru-niagen-300mg-90ct'}), (b:ProductVariant {uid: 'hu:product-variant:tru-niagen-300mg-us-capsule'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w15-stub-tru-niagen-300mg-us-capsule-has-tru-niagen-300mg-90ct'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-90ct'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ProductVariant {uid: 'hu:product-variant:tru-niagen-300mg-us-capsule'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-90ct'})
MERGE (a)-[r:HAS_PACKAGE_CONFIGURATION {relationshipUid: 'hu:rel:w15-stub-tru-niagen-300mg-us-capsule-has-tru-niagen-300mg-90ct'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:w15-stub-tru-niagen-300mg-us-capsule-has-tru-niagen-300mg-90ct', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:w15-stub-tru-niagen-immune-us-capsule-has-tru-niagen-immune-30ct'})
ON CREATE SET n.id = 'w15-stub-tru-niagen-immune-us-capsule-has-tru-niagen-immune-30ct', n.predicate = 'HAS_PACKAGE_CONFIGURATION', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:e960d03240d6019ce27396cc088bc16dceb5e095b91ae7658c923d4c1f6e262b', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:w15-stub-tru-niagen-immune-us-capsule-has-tru-niagen-immune-30ct'}), (b:ProductVariant {uid: 'hu:product-variant:tru-niagen-immune-us-capsule'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w15-stub-tru-niagen-immune-us-capsule-has-tru-niagen-immune-30ct'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-immune-30ct'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ProductVariant {uid: 'hu:product-variant:tru-niagen-immune-us-capsule'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-immune-30ct'})
MERGE (a)-[r:HAS_PACKAGE_CONFIGURATION {relationshipUid: 'hu:rel:w15-stub-tru-niagen-immune-us-capsule-has-tru-niagen-immune-30ct'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:w15-stub-tru-niagen-immune-us-capsule-has-tru-niagen-immune-30ct', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:w15-stub-on-gsw-double-rich-chocolate-us-has-on-gsw-double-rich-chocolate-5lb'})
ON CREATE SET n.id = 'w15-stub-on-gsw-double-rich-chocolate-us-has-on-gsw-double-rich-chocolate-5lb', n.predicate = 'HAS_PACKAGE_CONFIGURATION', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:ed6029dbc11f0070333d31d2aae1c636a62e9ed8d3322aa1db6a00763827ac17', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:w15-stub-on-gsw-double-rich-chocolate-us-has-on-gsw-double-rich-chocolate-5lb'}), (b:ProductVariant {uid: 'hu:product-variant:on-gsw-double-rich-chocolate-us'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w15-stub-on-gsw-double-rich-chocolate-us-has-on-gsw-double-rich-chocolate-5lb'}), (b:PackageConfiguration {uid: 'hu:package-configuration:on-gsw-double-rich-chocolate-5lb'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ProductVariant {uid: 'hu:product-variant:on-gsw-double-rich-chocolate-us'}), (b:PackageConfiguration {uid: 'hu:package-configuration:on-gsw-double-rich-chocolate-5lb'})
MERGE (a)-[r:HAS_PACKAGE_CONFIGURATION {relationshipUid: 'hu:rel:w15-stub-on-gsw-double-rich-chocolate-us-has-on-gsw-double-rich-chocolate-5lb'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:w15-stub-on-gsw-double-rich-chocolate-us-has-on-gsw-double-rich-chocolate-5lb', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:w15-stub-rosabella-moringa-capsules-us-has-rosabella-moringa-60ct'})
ON CREATE SET n.id = 'w15-stub-rosabella-moringa-capsules-us-has-rosabella-moringa-60ct', n.predicate = 'HAS_PACKAGE_CONFIGURATION', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:4647782104b82875aace9b1c8c1ec8f94c1c7b5680d182bb04fbf96661589908', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:w15-stub-rosabella-moringa-capsules-us-has-rosabella-moringa-60ct'}), (b:ProductVariant {uid: 'hu:product-variant:rosabella-moringa-capsules-us'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w15-stub-rosabella-moringa-capsules-us-has-rosabella-moringa-60ct'}), (b:PackageConfiguration {uid: 'hu:package-configuration:rosabella-moringa-60ct'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ProductVariant {uid: 'hu:product-variant:rosabella-moringa-capsules-us'}), (b:PackageConfiguration {uid: 'hu:package-configuration:rosabella-moringa-60ct'})
MERGE (a)-[r:HAS_PACKAGE_CONFIGURATION {relationshipUid: 'hu:rel:w15-stub-rosabella-moringa-capsules-us-has-rosabella-moringa-60ct'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:w15-stub-rosabella-moringa-capsules-us-has-rosabella-moringa-60ct', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:w15-stub-tru-niagen-has-300mg-variant'})
ON CREATE SET n.id = 'w15-stub-tru-niagen-has-300mg-variant', n.predicate = 'HAS_VARIANT', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:82ad2f2d9f9984e1b545bc367a06263ef5f9a8399e06936d1c9d73eaaed3473e', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:w15-stub-tru-niagen-has-300mg-variant'}), (b:Product {uid: 'hu:product:tru-niagen'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w15-stub-tru-niagen-has-300mg-variant'}), (b:ProductVariant {uid: 'hu:product-variant:tru-niagen-300mg-us-capsule'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Product {uid: 'hu:product:tru-niagen'}), (b:ProductVariant {uid: 'hu:product-variant:tru-niagen-300mg-us-capsule'})
MERGE (a)-[r:HAS_VARIANT {relationshipUid: 'hu:rel:w15-stub-tru-niagen-has-300mg-variant'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:w15-stub-tru-niagen-has-300mg-variant', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
// STUB of a W12 lot (Rosabella lot 5040273, expiry 05/2027 per the FDA notice); W12 owns ProductLot.
MERGE (n:ProductLot:Entity {uid: 'hu:lot:rosabella-moringa-5040273'})
ON CREATE SET n.id = 'rosabella-moringa-5040273', n.lotCode = '5040273', n.expiryDate = datetime('2027-05-01T00:00:00Z'), n.expiryDatePrecision = 'MONTH', n.dateTextVerbatim = '5040273 | 05/2027', n.entityType = 'ProductLot', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
