# Open Schema Questions

These are research tasks, not placeholders to be silently guessed during ingestion.

## Priority 0 — identity and assertion kernel

1. What exact change creates a new Product Variant rather than a new Formulation Version or Package Configuration?
2. Should every accepted semantic relationship exist only as an Assertion, or may selected asserted edges be canonical relationship records with independent identity?
3. Which predicates are stable enough to become typed Neo4j relationships, and which should remain `Assertion.predicate` values?
4. How are retracted, corrected, and superseded source snapshots represented without changing historical adjudications?
5. What minimum fields make an evidence locator reproducible across mutable webpages?

## Priority 1 — ingredient identity and equivalence

1. When are two Ingredient Materials identical, analytically equivalent, formulation equivalent, or merely substance-related?
2. Does a supplier or specification change always create a new Branded Ingredient Material, a new Specification Version, or only a new material lot?
3. How should salt mass, active-moiety mass, nutrient-equivalent amount, and label-declared amount coexist?
4. How are botanical extract ratios, native ratios, solvents, carriers, standardization ranges, and marker measurements normalized?
5. How should nonviable microorganisms, spores, consortia, and strain-specific counts be represented?
6. How should proprietary blends with undisclosed nested quantities be reasoned over without inventing amounts?

## Priority 1 — evidence applicability

1. Which applicability dimensions are categorical, continuous, or explanation-only?
2. How is applicability method versioned and calibrated against expert review?
3. How do investigational batches bridge to commercial lots when only partial analytical evidence exists?
4. How should null primary results and favorable secondary or subgroup results affect claim-level synthesis?
5. What is the ontology for biomarker, surrogate endpoint, intermediate clinical endpoint, and patient-important outcome?

## Priority 2 — quality and commerce

1. What evidence is sufficient to classify an artifact as a Certificate of Analysis rather than a Test Summary?
2. How are specification targets, release limits, shelf-life limits, and measured uncertainty modeled?
3. What creates product identity continuity across a retailer substitute, changed packaging, or marketplace listing merge?
4. How are price, availability, shipping, tax, affiliate compensation, and subscription cancellation terms snapshotted?
5. How should recalled, expired, counterfeit-suspected, and gray-market inventory be represented?

## Agent evaluation questions

1. Which graph shapes consistently produce incorrect retrieval or evidence inheritance?
2. Which concepts are repeatedly confused by extraction agents?
3. Which validation failures predict harmful recommendation errors?
4. Which modeled distinctions are never used and create unnecessary resolution cost?
5. Which new domain cases cannot be expressed without lossy blobs or overloaded labels?

