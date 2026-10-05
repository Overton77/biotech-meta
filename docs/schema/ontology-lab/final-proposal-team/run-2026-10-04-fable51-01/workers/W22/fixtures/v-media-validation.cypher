// W22 candidate validation family V-601..V-615 (media). Read-only queries; each returns violating rows.
// Proposed for docs/schema/neo4j/validation.cypher at Fable's discretion (ids are candidates; W22-SR-08).
// Expected rows with all six W22 fixtures loaded are listed in 06-fixtures-and-queries.md; only the intentionally
// negative fixture members appear.

// V-601: an IMAGE_REGION locator names its annotation (mediaAnnotationUid), declares a coordinate normalization, and
// reaches exactly that one annotation through LOCATES_REGION (D-010).
// status: executed
MATCH (l:SourceLocator {selectorKind: 'IMAGE_REGION'})
OPTIONAL MATCH (l)-[:LOCATES_REGION]->(a:MediaAnnotation)
WITH l, collect(a) AS anns
WHERE size(anns) <> 1 OR anns[0].uid <> l.mediaAnnotationUid OR l.normalizationVersion IS NULL
RETURN l.uid AS imageRegionLocator, size(anns) AS locatedAnnotations, l.mediaAnnotationUid AS namedAnnotation
ORDER BY imageRegionLocator;

// V-602: the coordinates of an IMAGE_REGION are defined on the rendition that carries the annotation; that rendition's
// raw-byte hash must equal the hash of the snapshot the locator hangs from (same bytes, same raster).
// status: executed
MATCH (ss:SourceSnapshot)-[:HAS_LOCATOR]->(l:SourceLocator {selectorKind: 'IMAGE_REGION'})-[:LOCATES_REGION]->(a:MediaAnnotation)<-[:HAS_ANNOTATION]-(v:MediaVariant)
WHERE v.contentHash IS NULL OR ss.contentHash IS NULL OR v.contentHash <> ss.contentHash
RETURN l.uid AS locator, v.uid AS annotatedRendition, v.variantKind AS kind
ORDER BY locator;

// V-603: media byte hashes are 'sha256:<64 hex>' with a named basis; a publisher-stated checksum never sits in contentHash.
// status: executed
MATCH (n)
WHERE (n:MediaAsset OR n:MediaVariant) AND n.contentHash IS NOT NULL
  AND (NOT n.contentHash =~ 'sha256:[0-9a-f]{64}' OR n.contentHashBasis IS NULL OR n.contentHash = n.statedChecksum)
RETURN n.uid AS badHash, n.contentHash AS contentHash;

// V-604: EVIDENCES is derived only (rule MEDIA-EV-1): it names its rule and input assertion, and the support path from
// that assertion through an IMAGE_REGION locator to an ORIGINAL rendition of the evidencing asset (or the panel region) exists.
// status: executed
MATCH (m)-[e:EVIDENCES]->(x)
WHERE e.derivationRule IS NULL OR NOT x.uid IN coalesce(e.derivedFromAssertionUids, [])
   OR NOT (
     EXISTS { MATCH (x)-[:SUPPORTED_BY]->(:SourceLocator {selectorKind: 'IMAGE_REGION'})-[:LOCATES_REGION]->(:MediaAnnotation)<-[:HAS_ANNOTATION]-(:MediaVariant {variantKind: 'ORIGINAL'})<-[:HAS_MEDIA_VARIANT]-(m) }
     OR EXISTS { MATCH (x)-[:SUPPORTED_BY]->(:SourceLocator {selectorKind: 'IMAGE_REGION'})-[:LOCATES_REGION]->(:MediaAnnotation)<-[:FROM_ANNOTATION]-(m) }
   )
RETURN m.uid AS evidencingAsset, x.uid AS evidenced, e.derivationRule AS rule;

// V-605 (forbidden implication GENERATED_ILLUSTRATION -> SOURCE_SUPPORT): a GENERATED asset never EVIDENCES anything and
// its renditions never back a locator that supports a non-media assertion.
// status: executed
MATCH (m:MediaAsset {generationMode: 'GENERATED'})
WHERE EXISTS { MATCH (m)-[:EVIDENCES]->() }
   OR EXISTS { MATCH (m)-[:HAS_MEDIA_VARIANT]->(:MediaVariant)-[:HAS_ANNOTATION]->(:MediaAnnotation)<-[:LOCATES_REGION]-(:SourceLocator)<-[:SUPPORTED_BY]-(x:Assertion)
               WHERE NOT x.predicate IN ['DEPICTS', 'EXPLAINS', 'VISUALIZES', 'ANNOTATES_SUBJECT', 'HAS_RIGHTS_RECORD'] }
RETURN m.uid AS generatedAssetUsedAsEvidence;

// V-606: an IMAGE_REGION locator used as support selects a region of an ORIGINAL rendition, never of a crop, overlay,
// resize or other derivative.
// status: executed
MATCH (x:Assertion)-[:SUPPORTED_BY]->(l:SourceLocator {selectorKind: 'IMAGE_REGION'})-[:LOCATES_REGION]->(:MediaAnnotation)<-[:HAS_ANNOTATION]-(v:MediaVariant)
WHERE v.variantKind <> 'ORIGINAL'
RETURN x.uid AS assertion, l.uid AS locator, v.uid AS derivedRendition, v.variantKind AS kind
ORDER BY assertion;

// V-607: every non-ORIGINAL rendition has a generating Activity: a CAPTURE (publisher-provided rendition) or a
// MEDIA_TRANSFORMATION that USED another rendition of the same asset.
// status: executed
MATCH (m:MediaAsset)-[:HAS_MEDIA_VARIANT]->(v:MediaVariant)
WHERE v.variantKind <> 'ORIGINAL'
  AND NOT EXISTS { MATCH (v)-[:WAS_GENERATED_BY]->(:Activity {activityKind: 'CAPTURE'}) }
  AND NOT EXISTS { MATCH (v)-[:WAS_GENERATED_BY]->(:Activity {activityKind: 'MEDIA_TRANSFORMATION'})-[:USED]->(p:MediaVariant)<-[:HAS_MEDIA_VARIANT]-(m) WHERE p <> v }
RETURN m.uid AS asset, v.uid AS renditionWithoutLineage;

// V-608 (state 5, analogue of V-429): an answer-composition activity that USED a media asset or rendition must name the
// policy version that authorized display (useKind DISPLAY_MEDIA, proposed W22-SR-02).
// status: executed
MATCH (act:Activity {activityKind: 'ANSWER_COMPOSITION'})-[:USED]->(x)
WHERE (x:MediaVariant OR x:MediaAsset)
  AND NOT EXISTS { MATCH (act)-[u:AUTHORIZED_BY]->(:PolicyVersion) WHERE u.useKind = 'DISPLAY_MEDIA' }
RETURN act.uid AS unauthorizedMediaUse, x.uid AS usedRendition;

// V-608b (informational; forbidden implications PUBLICLY_ACCESSIBLE -> REUSE_PERMITTED and NO_STATEMENT_FOUND -> PERMISSION):
// an authorized display of an asset none of whose current rights records is permitting (or that has none). Each row needs a
// recorded legal or policy decision; the graph does not decide fair use.
// status: executed
MATCH (act:Activity {activityKind: 'ANSWER_COMPOSITION'})-[u:AUTHORIZED_BY {useKind: 'DISPLAY_MEDIA'}]->(:PolicyVersion)
MATCH (act)-[:USED]->(v:MediaVariant)<-[:HAS_MEDIA_VARIANT]-(m:MediaAsset)
OPTIONAL MATCH (m)-[hr:HAS_RIGHTS_RECORD]->(r:MediaRightsRecord) WHERE hr.recordedTo IS NULL
WITH act, m, collect(r.rightsStatus) AS rights
WHERE size(rights) = 0 OR NOT all(s IN rights WHERE s IN ['OPEN_LICENSE', 'PUBLIC_DOMAIN', 'PERMISSION_GRANTED', 'HELD_BY_OPERATOR'])
RETURN act.uid AS authorizedDisplayNeedsDecision, m.uid AS asset, rights;

// V-609: a non-legacy suitability assessment assesses exactly one asset, names its dimension, verdict and method, and
// has a generating Activity; a legacy-unsourced assessment is never ACCEPTED.
// status: executed
MATCH (a:MediaSuitabilityAssessment)
OPTIONAL MATCH (a)-[:ASSESSES_MEDIA]->(m:MediaAsset)
WITH a, count(m) AS assets
WHERE (a.methodVersion = 'legacy-unsourced' AND a.status = 'ACCEPTED')
   OR (a.methodVersion <> 'legacy-unsourced' AND (assets <> 1 OR a.dimension IS NULL OR a.verdict IS NULL OR NOT EXISTS { MATCH (a)-[:WAS_GENERATED_BY]->(:Activity) }))
RETURN a.uid AS badAssessment, assets;

// V-610 (migration completeness, informational): legacy media properties that the final model retires (unsourced
// scores, licence strings, bare confidence, document-level primary flag) still present on nodes.
// status: executed
MATCH (n)
WHERE (n:MediaAsset OR n:MediaVariant OR n:MediaAnnotation OR n:FigurePanel OR n:ProductLabelRegion)
  AND (n.qualityScore IS NOT NULL OR n.authenticityScore IS NOT NULL OR n.license IS NOT NULL OR n.usageRestrictions IS NOT NULL
       OR n.copyrightHolder IS NOT NULL OR n.checksumSha256 IS NOT NULL OR n.confidence IS NOT NULL OR n.isPrimarySource IS NOT NULL)
RETURN n.uid AS nodeWithRetiredMediaProperty, [k IN keys(n) WHERE k IN ['qualityScore', 'authenticityScore', 'license', 'usageRestrictions', 'copyrightHolder', 'checksumSha256', 'confidence', 'isPrimarySource']] AS retiredKeys
ORDER BY nodeWithRetiredMediaProperty;

// V-611: an asset with renditions has exactly one ORIGINAL, and the asset's contentHash repeats the ORIGINAL's.
// status: executed
MATCH (m:MediaAsset)-[:HAS_MEDIA_VARIANT]->(v:MediaVariant)
WITH m, [x IN collect(v) WHERE x.variantKind = 'ORIGINAL'] AS originals
WHERE size(originals) <> 1 OR (m.contentHash IS NOT NULL AND m.contentHash <> originals[0].contentHash)
RETURN m.uid AS asset, size(originals) AS originals;

// V-612: an asserted media edge (DEPICTS, EXPLAINS, VISUALIZES, ANNOTATES_SUBJECT, HAS_RIGHTS_RECORD) is the projection of
// one Assertion with the same predicate, subject and object (contract A5, D-011).
// status: executed
MATCH (s)-[e:DEPICTS|EXPLAINS|VISUALIZES|ANNOTATES_SUBJECT|HAS_RIGHTS_RECORD]->(o)
WHERE e.assertionUid IS NULL OR e.relationshipUid IS NULL OR e.recordedFrom IS NULL
   OR NOT EXISTS { MATCH (x:Assertion {uid: e.assertionUid})-[:HAS_SUBJECT]->(s) MATCH (x)-[:HAS_OBJECT]->(o) WHERE x.predicate = type(e) }
RETURN type(e) AS edge, s.uid AS fromNode, o.uid AS toNode, e.assertionUid AS assertionUid;

// V-613: a FigurePanel belongs to exactly one asset; a ProductLabelRegion is delimited by exactly one annotation.
// status: executed
MATCH (n)
WHERE n:FigurePanel OR n:ProductLabelRegion
OPTIONAL MATCH (n)-[:PART_OF_MEDIA]->(m:MediaAsset)
OPTIONAL MATCH (n)-[:FROM_ANNOTATION]->(a:MediaAnnotation)
WITH n, count(DISTINCT m) AS assets, count(DISTINCT a) AS regions
WHERE (n:FigurePanel AND (assets <> 1 OR regions > 1)) OR (n:ProductLabelRegion AND regions <> 1)
RETURN n.uid AS badPanelOrRegion, assets, regions;

// V-614: a CROPPED rendition's generating Activity USED the region annotation on another rendition of the same asset.
// status: executed
MATCH (m:MediaAsset)-[:HAS_MEDIA_VARIANT]->(c:MediaVariant {variantKind: 'CROPPED'})
WHERE NOT EXISTS {
  MATCH (c)-[:WAS_GENERATED_BY]->(act:Activity)-[:USED]->(ann:MediaAnnotation)<-[:HAS_ANNOTATION]-(p:MediaVariant)<-[:HAS_MEDIA_VARIANT]-(m)
  WHERE p <> c
}
RETURN m.uid AS asset, c.uid AS cropWithoutRegionLineage;

// V-615 (forbidden implication DEPICTS -> SUPPORTED_BY): support always goes through a SourceLocator; an assertion never
// points SUPPORTED_BY at a media node.
// status: executed
MATCH (x:Assertion)-[:SUPPORTED_BY]->(n)
WHERE n:MediaAsset OR n:MediaVariant OR n:MediaAnnotation OR n:FigurePanel OR n:ProductLabelRegion OR n:GraphView
RETURN x.uid AS assertion, n.uid AS mediaNodeUsedAsSupport;
