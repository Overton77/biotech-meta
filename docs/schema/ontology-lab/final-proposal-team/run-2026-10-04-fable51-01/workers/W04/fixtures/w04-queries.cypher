// W04 competency queries. Parameters are passed by the runner ($...). Each statement is self-contained.
// Expected rows per parameter set are in 06-fixtures-and-queries.md.

// Q-W04-01 (QS-2b verbatim from query-shapes.md; CQ-TM-01, CQ-ID-01): formulation of a variant believed at R and valid at V.
MATCH (v:ProductVariant {uid: $variantUid})-[r:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
WHERE (r.recordedFrom IS NOT NULL AND r.recordedFrom <= $recordedAsOf
       AND (r.recordedTo IS NULL OR $recordedAsOf < r.recordedTo))
   OR (r.recordedFrom IS NULL AND $includeLegacy)
OPTIONAL MATCH (a:Assertion {uid: coalesce(r.assertionUid, r.projectionOfAssertionUid)})
CALL {
  WITH a
  OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(snap:SourceSnapshot)
  WHERE snap.retrievedAt <= $recordedAsOf
  RETURN max(snap.observedAt) AS lastObservedAt
}
WITH v, r, f, a, lastObservedAt,
     CASE
       WHEN r.validFrom IS NOT NULL AND r.validFrom > $validAt THEN 'EXCLUDED'
       WHEN r.validTo IS NOT NULL AND r.validTo <= $validAt THEN 'EXCLUDED'
       WHEN r.validFrom IS NULL AND r.validTo IS NULL THEN 'UNKNOWN_BOTH_BOUNDS'
       WHEN r.validFrom IS NULL THEN 'UNKNOWN_START'
       WHEN r.validTo IS NOT NULL THEN 'KNOWN_WITHIN'
       WHEN lastObservedAt IS NOT NULL AND lastObservedAt >= $validAt THEN 'OPEN_END_SUPPORTED'
       ELSE 'OPEN_END_STALE'
     END AS validityClass
WHERE validityClass <> 'EXCLUDED'
RETURN f.uid AS formulationUid,
       validityClass,
       r.validFrom AS validFrom, r.validTo AS validTo, r.validFromBasis AS validFromBasis, r.validToBasis AS validToBasis,
       r.recordedFrom AS recordedFrom, r.recordedTo AS recordedTo,
       CASE WHEN r.recordedFrom IS NULL THEN 'LEGACY_UNDATED' ELSE 'RECORDED' END AS recordedClass,
       lastObservedAt,
       a.uid AS authorizingAssertionUid
ORDER BY r.recordedFrom DESC, f.uid;

// Q-W04-02 (QS-2b-W04 refinement; CQ-ID-01, CQ-ID-05): the same slice plus the observation window of each believed version
// (first and last observedAt of the snapshots behind its authorizing assertion) and the component amounts, so "current vs historical"
// is answerable when the source states no bounds.
MATCH (v:ProductVariant {uid: $variantUid})-[r:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
WHERE r.recordedFrom <= $recordedAsOf AND (r.recordedTo IS NULL OR $recordedAsOf < r.recordedTo)
  AND (r.validFrom IS NULL OR r.validFrom <= $validAt) AND (r.validTo IS NULL OR $validAt < r.validTo)
MATCH (a:Assertion {uid: r.assertionUid})
CALL {
  WITH a
  OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(snap:SourceSnapshot)
  WHERE snap.retrievedAt <= $recordedAsOf
  RETURN min(snap.observedAt) AS firstObservedAt, max(snap.observedAt) AS lastObservedAt
}
CALL {
  WITH f
  MATCH (f)-[:HAS_INGREDIENT_COMPONENT]->(c:IngredientComponent)
  OPTIONAL MATCH (c)-[:USES_MATERIAL]->(m:IngredientMaterial)
  WITH c, m ORDER BY c.labelOrder
  RETURN collect(c.declaredAs + ' ' + toString(c.quantity) + ' ' + c.unitCode + ' ' + coalesce(c.quantityBasis, '?') + ' ' + coalesce(c.massBasis, '?') + ' -> ' + coalesce(m.uid, 'NO_MATERIAL')) AS components
}
WITH collect({formulationUid: f.uid, validFrom: r.validFrom, validTo: r.validTo, validFromBasis: r.validFromBasis,
                firstObservedAt: firstObservedAt, lastObservedAt: lastObservedAt, components: components}) AS rows
WITH rows, reduce(mx = null, x IN rows | CASE WHEN mx IS NULL OR x.lastObservedAt > mx THEN x.lastObservedAt ELSE mx END) AS latest
UNWIND rows AS x
RETURN x.formulationUid AS formulationUid, x.validFrom AS validFrom, x.validTo AS validTo, x.validFromBasis AS validFromBasis,
       x.firstObservedAt AS firstObservedAt, x.lastObservedAt AS lastObservedAt,
       CASE WHEN x.lastObservedAt = latest THEN 'MOST_RECENTLY_OBSERVED' ELSE 'EARLIER_OBSERVED' END AS recency,
       x.components AS components
ORDER BY lastObservedAt;

// Q-W04-03 (QS-2b-interval + observation window; CQ-ID-02 qualified answer): which formulation applied during the study's administration
// interval. A version whose first observation is after the interval and whose start is unknown is never presented as "the" formulation.
MATCH (st:Study {uid: $studyUid})<-[:HAS_SUBJECT]-(span:Assertion {predicate: 'STUDY_CONDUCTED_DURING'})
WITH st, span.validFrom AS intervalStart,
     span.validTo + CASE span.validToPrecision WHEN 'MONTH' THEN duration('P1M') WHEN 'DAY' THEN duration('P1D') WHEN 'YEAR' THEN duration('P1Y') ELSE duration('PT0S') END AS intervalEnd
MATCH (v:ProductVariant {uid: $variantUid})-[r:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
WHERE r.recordedFrom <= $recordedAsOf AND (r.recordedTo IS NULL OR $recordedAsOf < r.recordedTo)
MATCH (a:Assertion {uid: r.assertionUid})
CALL {
  WITH a
  OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(snap:SourceSnapshot)
  WHERE snap.retrievedAt <= $recordedAsOf
  RETURN min(snap.observedAt) AS firstObservedAt
}
WITH st, intervalStart, intervalEnd, f, r, firstObservedAt,
     CASE
       WHEN r.validTo IS NOT NULL AND r.validTo <= intervalStart THEN 'EXCLUDED'
       WHEN r.validFrom IS NOT NULL AND r.validFrom >= intervalEnd THEN 'EXCLUDED'
       WHEN r.validFrom IS NULL AND firstObservedAt >= intervalEnd THEN 'START_UNKNOWN_FIRST_OBSERVED_AFTER_INTERVAL'
       WHEN r.validFrom IS NULL THEN 'OVERLAP_START_UNKNOWN'
       WHEN r.validFrom <= intervalStart AND r.validTo IS NULL THEN 'COVERS_INTERVAL_IF_STILL_TRUE'
       WHEN r.validFrom <= intervalStart AND r.validTo >= intervalEnd THEN 'COVERS_INTERVAL'
       ELSE 'PARTIAL_OVERLAP'
     END AS overlapClass
WHERE overlapClass <> 'EXCLUDED'
WITH st, intervalStart, intervalEnd, collect({formulationUid: f.uid, overlapClass: overlapClass, firstObservedAt: firstObservedAt}) AS candidates
OPTIONAL MATCH (ls:LabelSnapshot)-[:LABEL_FOR]->(:ProductVariant {uid: $variantUid})
WHERE ls.observedAt < intervalEnd
WITH st, intervalStart, intervalEnd, candidates, count(ls) AS labelsObservedBeforeIntervalEnd
RETURN st.uid AS studyUid, intervalStart, intervalEnd, candidates, labelsObservedBeforeIntervalEnd,
       CASE WHEN all(c IN candidates WHERE c.overlapClass = 'START_UNKNOWN_FIRST_OBSERVED_AFTER_INTERVAL') OR size(candidates) = 0
            THEN 'FORMULATION_AT_ADMINISTRATION_UNKNOWN' ELSE 'SEE_CANDIDATES' END AS answer;

// Q-W04-04 (CQ-ID-05): classify the change between two formulation versions as composition change, declared-basis refinement or none.
// Derived, not stored (an Adjudication is written only if a reviewer decides).
MATCH (fa:FormulationVersion {uid: $fromFormulationUid}), (fb:FormulationVersion {uid: $toFormulationUid})
CALL {
  WITH fa
  MATCH (fa)-[:HAS_INGREDIENT_COMPONENT]->(c:IngredientComponent)
  OPTIONAL MATCH (c)-[:USES_MATERIAL]->(m)
  OPTIONAL MATCH (fa)-[:USES_SERVING_DEFINITION]->(s:ServingDefinition)
  RETURN collect({o: c.labelOrder, m: m.uid, q: c.quantity, u: c.unitCode, qb: c.quantityBasis, mb: c.massBasis, ar: c.amountReferent, d: c.declaredAs, sc: s.servingCount}) AS ca
}
CALL {
  WITH fb
  MATCH (fb)-[:HAS_INGREDIENT_COMPONENT]->(c:IngredientComponent)
  OPTIONAL MATCH (c)-[:USES_MATERIAL]->(m)
  OPTIONAL MATCH (fb)-[:USES_SERVING_DEFINITION]->(s:ServingDefinition)
  RETURN collect({o: c.labelOrder, m: m.uid, q: c.quantity, u: c.unitCode, qb: c.quantityBasis, mb: c.massBasis, ar: c.amountReferent, d: c.declaredAs, sc: s.servingCount}) AS cb
}
WITH fa, fb, ca, cb,
     [x IN ca | [x.o, x.m, x.q, x.u, x.qb, x.sc]] AS compA, [x IN cb | [x.o, x.m, x.q, x.u, x.qb, x.sc]] AS compB,
     [x IN ca | [x.o, x.mb, x.ar]] AS basisA, [x IN cb | [x.o, x.mb, x.ar]] AS basisB,
     [x IN ca | x.d] AS textA, [x IN cb | x.d] AS textB
RETURN fa.uid AS fromUid, fb.uid AS toUid,
       CASE WHEN fa.payloadHash = fb.payloadHash THEN 'SAME_PAYLOAD'
            WHEN NOT all(x IN compA WHERE x IN compB) OR NOT all(x IN compB WHERE x IN compA) THEN 'COMPOSITION_CHANGED'
            WHEN NOT all(x IN basisA WHERE x IN basisB) OR NOT all(x IN basisB WHERE x IN basisA) THEN 'DECLARED_BASIS_CHANGED_COMPOSITION_NOT_ESTABLISHED'
            ELSE 'DECLARATION_TEXT_ONLY' END AS changeClass,
       textA, textB;

// Q-W04-05 (CQ-ID-05 package side): packages believed at two valid times for one variant, and the formulation episodes over the same span.
MATCH (v:ProductVariant {uid: $variantUid})
CALL {
  WITH v
  MATCH (v)-[h:HAS_PACKAGE_CONFIGURATION]->(p:PackageConfiguration)
  WHERE h.recordedFrom <= $recordedAsOf AND (h.recordedTo IS NULL OR $recordedAsOf < h.recordedTo)
    AND (h.validFrom IS NULL OR h.validFrom <= $validAt1) AND (h.validTo IS NULL OR $validAt1 < h.validTo)
  RETURN collect(p.unitCount) AS packagesAtV1
}
CALL {
  WITH v
  MATCH (v)-[h:HAS_PACKAGE_CONFIGURATION]->(p:PackageConfiguration)
  WHERE h.recordedFrom <= $recordedAsOf AND (h.recordedTo IS NULL OR $recordedAsOf < h.recordedTo)
    AND (h.validFrom IS NULL OR h.validFrom <= $validAt2) AND (h.validTo IS NULL OR $validAt2 < h.validTo)
  RETURN collect(p.unitCount) AS packagesAtV2
}
CALL {
  WITH v
  MATCH (v)-[h:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
  WHERE h.recordedFrom <= $recordedAsOf AND (h.recordedTo IS NULL OR $recordedAsOf < h.recordedTo)
    AND (h.validFrom IS NULL OR h.validFrom <= $validAt2) AND (h.validTo IS NULL OR $validAt1 < h.validTo)
  RETURN collect(DISTINCT f.uid) AS formulationsSpanningV1toV2
}
RETURN v.uid AS variantUid, packagesAtV1, packagesAtV2, formulationsSpanningV1toV2,
       CASE WHEN packagesAtV1 <> packagesAtV2 AND size(formulationsSpanningV1toV2) = 1 THEN 'PACKAGE_ONLY_CHANGE'
            WHEN packagesAtV1 = packagesAtV2 AND size(formulationsSpanningV1toV2) > 1 THEN 'FORMULATION_CHANGE_SAME_PACKAGE'
            WHEN packagesAtV1 <> packagesAtV2 THEN 'PACKAGE_AND_FORMULATION_CHANGE'
            ELSE 'NO_CHANGE_RECORDED' END AS changeClass;

// Q-W04-06 (CQ-PF-01): what a declared amount refers to, which calculated amounts follow, and any measured result -- three kinds, never merged.
MATCH (ls:LabelSnapshot {uid: $labelSnapshotUid})-[:HAS_DECLARATION]->(d:LabelDeclaration)-[:HAS_QUANTITY_DECLARATION]->(q:QuantityDeclaration)
OPTIONAL MATCH (d)-[:DECLARATION_IDENTIFIES_MATERIAL]->(m:IngredientMaterial)
OPTIONAL MATCH (ls)-[:DECLARES_FORMULATION]->(:FormulationVersion)-[:HAS_INGREDIENT_COMPONENT]->(c:IngredientComponent)-[:USES_MATERIAL]->(m)
OPTIONAL MATCH (calc:Assertion {predicate: 'ACTIVE_MOIETY_AMOUNT', basisKind: 'CALCULATED'})-[:HAS_SUBJECT]->(c)
OPTIONAL MATCH (calc)-[:DERIVED_FROM_ASSERTION]->(:Assertion {predicate: 'HAS_ACTIVE_MOIETY'})-[:HAS_OBJECT]->(moiety)
OPTIONAL MATCH (lot:ProductLot)-[:LOT_OF]->(:ProductVariant)<-[:LABEL_FOR]-(ls)
OPTIONAL MATCH (:TestExecution)-[:PRODUCED_RESULT]->(mr:MeasuredResult)
WHERE mr.analyteUid IS NOT NULL
RETURN d.verbatimText AS declared, q.value AS declaredValue, q.unitCode AS unit, q.quantityBasis AS basis, q.amountReferent AS amountReferent,
       q.dailyValueStatus AS dailyValueStatus, m.uid AS declaredMaterial,
       calc.valueNumber AS calculatedActiveMoietyAmount, moiety.uid AS activeMoiety, calc.derivationRule AS rule,
       collect(DISTINCT {value: mr.value, unit: mr.unitCode, analyte: mr.analyte, kind: 'MEASURED'}) AS measured;

// Q-W04-07 (CQ-AX-25): variants whose formulation believed at R and valid at V lists >= $minAmount of a substance (via material ->
// REALIZES_SUBSTANCE), with basis; blends that only PROVIDE the substance are listed separately; the derived CONTAINS edge is not used.
MATCH (sub:ChemicalSubstance {uid: $substanceUid})
MATCH (v:ProductVariant)-[h:HAS_FORMULATION_VERSION]->(f:FormulationVersion)-[:HAS_INGREDIENT_COMPONENT]->(c:IngredientComponent)-[:USES_MATERIAL]->(m:IngredientMaterial)
WHERE h.recordedFrom <= $recordedAsOf AND (h.recordedTo IS NULL OR $recordedAsOf < h.recordedTo)
  AND (h.validFrom IS NULL OR h.validFrom <= $validAt) AND (h.validTo IS NULL OR $validAt < h.validTo)
  AND c.quantity >= $minAmount AND c.unitCode = $unitCode
MATCH (ra:Assertion {predicate: 'REALIZES_SUBSTANCE'})-[:HAS_SUBJECT]->(m), (ra)-[:HAS_OBJECT]->(sub)
WHERE ra.recordedAt <= $recordedAsOf AND NOT EXISTS { MATCH (sup:Assertion)-[:SUPERSEDES]->(ra) WHERE sup.recordedAt <= $recordedAsOf }
RETURN v.uid AS variantUid, ra.status AS materialRealizesSubstanceStatus, f.uid AS formulationUid, c.declaredAs AS declaredAs, c.quantity AS quantity, c.unitCode AS unit,
       c.quantityBasis AS quantityBasis, c.massBasis AS massBasis, c.amountReferent AS amountReferent,
       CASE WHEN h.validFrom IS NULL THEN 'VALID_START_UNKNOWN' ELSE 'VALID_START_KNOWN' END AS validity
ORDER BY quantity DESC;

// Q-W04-08 (CQ-AX-17 product side): declared amount per serving and per dosage unit; per day only if a directions declaration is captured.
MATCH (v:ProductVariant {uid: $variantUid})-[h:HAS_FORMULATION_VERSION]->(f:FormulationVersion)-[:HAS_INGREDIENT_COMPONENT]->(c:IngredientComponent)
WHERE h.recordedTo IS NULL
OPTIONAL MATCH (f)-[:USES_SERVING_DEFINITION]->(s:ServingDefinition)
OPTIONAL MATCH (ls:LabelSnapshot)-[:DECLARES_FORMULATION]->(f)
OPTIONAL MATCH (ls)-[:HAS_DECLARATION]->(dir:LabelDeclaration {declarationKind: 'DIRECTIONS'})
RETURN f.uid AS formulationUid, c.declaredAs AS declaredAs, c.quantity AS perServing, c.unitCode AS unit, c.massBasis AS massBasis,
       s.servingCount AS dosageUnitsPerServing,
       CASE WHEN s.servingCount IS NULL THEN null ELSE c.quantity / s.servingCount END AS perDosageUnit,
       CASE WHEN dir IS NULL THEN 'PER_DAY_NOT_ESTABLISHED (no directions captured)' ELSE dir.verbatimText END AS perDayBasis;

// Q-W04-09 (selector survival, OPEN-QUESTIONS P0-5 residual): for each re-captured locator chain on one Source, how far each selector re-anchored.
MATCH (src:Source {uid: $sourceUid})-[:HAS_SNAPSHOT]->(sn:SourceSnapshot)-[:HAS_LOCATOR]->(l:SourceLocator)
OPTIONAL MATCH (l)-[ra:REANCHORS]->(older:SourceLocator)
RETURN sn.observedAt AS observedAt, l.selectorKind AS selectorKind, l.exact AS exact, ra.anchorMatch AS anchorMatchToPrevious, older.uid AS previousLocator
ORDER BY l.exact, observedAt;

// Q-W04-10 (CQ-PF-02, parser-only in this packet: no MerchantListing fixture in W04): listing-title amount vs label declaration for the same variant.
MATCH (ml:MerchantListing)-[:LISTING_FOR]->(v:ProductVariant {uid: $variantUid})
OPTIONAL MATCH (t:Assertion {predicate: 'LISTING_TITLE_AMOUNT'})-[:HAS_SUBJECT]->(ml)
OPTIONAL MATCH (ls:LabelSnapshot)-[:LABEL_FOR]->(v)
OPTIONAL MATCH (ls)-[:HAS_DECLARATION]->(:LabelDeclaration)-[:HAS_QUANTITY_DECLARATION]->(q:QuantityDeclaration)
RETURN ml.uid AS listingUid, t.valueNumber AS titleAmount, t.unitCode AS titleUnit, collect(DISTINCT {label: ls.uid, value: q.value, unit: q.unitCode, referent: q.amountReferent}) AS labelDeclarations,
       CASE WHEN ls IS NULL THEN 'UNKNOWN_NO_LABEL_SNAPSHOT' ELSE 'COMPARE' END AS comparability;
