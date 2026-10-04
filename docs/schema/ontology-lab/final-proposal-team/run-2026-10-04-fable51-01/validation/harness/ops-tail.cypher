
// =====================================================================================================================
// Hand-written sections (Fable, Wave 5). Everything below is idempotent and a no-op on a fresh database.
// =====================================================================================================================

// ---- 6. Migration from the live graph: label renames and merges (report 06 section 2). Run BEFORE sections 1–5 on a
//         database that holds live data; on a fresh database the statements match nothing. Each statement keeps the old
//         label until the uniqueness constraints have been verified, then the old label is removed in 6b. ----
MATCH (n:Compound) WHERE NOT n:ChemicalSubstance SET n:ChemicalSubstance;
MATCH (n:Ingredient) WHERE NOT n:IngredientMaterial SET n:IngredientMaterial;
MATCH (n:PhysicalLocation) WHERE NOT n:Facility SET n:Facility;
MATCH (n:Listing) WHERE NOT n:MerchantListing SET n:MerchantListing;
MATCH (n:Population) WHERE NOT n:StudyPopulation SET n:StudyPopulation;
MATCH (n:OutcomeMeasure) WHERE NOT n:OutcomeDefinition SET n:OutcomeDefinition;
MATCH (n:OutcomeResult) WHERE NOT n:StudyResult SET n:StudyResult;
MATCH (n:FoodProduct) WHERE NOT n:Product SET n:Product, n.productKind = coalesce(n.productKind, 'CONVENTIONAL_FOOD');
MATCH (n:FoodItem) WHERE NOT n:IngredientMaterial SET n:IngredientMaterial;
MATCH (n:ExperienceReport) WHERE NOT n:ClaimOccurrence SET n:ClaimOccurrence:Assertion, n.assertionBasis = coalesce(n.assertionBasis, 'PERSONAL_EXPERIENCE');
// Material is split by hand (IngredientMaterial or ChemicalSubstance per row, W11/W02 migration maps); no blanket relabel.

// ---- 6a. Relationship type renames (MR-04, MR-05, D-004, D-006, CL-014). Properties are copied verbatim; the old edge is
//          deleted in the same statement, so a re-run finds nothing. ----
MATCH (a)-[r:HAS_SNAPSHOT]->(b) WHERE NOT a:Source AND (b:OrganizationSnapshot OR b:ProductSnapshot)
CREATE (a)-[n:HAS_STATE]->(b) SET n = properties(r) DELETE r;
// Listing -[:HAS_SNAPSHOT]-> ListingSnapshot is detached, not renamed: the capture becomes a SourceSnapshot + Offer +
// PriceObservation by the W15 migration (M-03/M-04/M-06); the old node is kept as LegacyListingSnapshot for audit.
MATCH (n:ListingSnapshot) WHERE NOT n:LegacyListingSnapshot SET n:LegacyListingSnapshot;
MATCH (a:Study)-[r:EVALUATES]->(b) CREATE (a)-[n:LEGACY_EVALUATES]->(b) SET n = properties(r) DELETE r;
MATCH (a:ClaimOccurrence)-[r:UTTERED_BY]->(b) CREATE (a)-[n:ASSERTED_BY]->(b) SET n = properties(r) DELETE r;
MATCH (a:MediaAsset)-[r:HAS_VARIANT]->(b) CREATE (a)-[n:HAS_MEDIA_VARIANT]->(b) SET n = properties(r) DELETE r;
// Live Protocol -[:HAS_STEP]-> ProtocolStep becomes one legacy ProtocolEdition per protocol (D-004, CL-013; CH-R-13): steps hang
// from the edition, never from the Protocol. The edition is SNAPSHOT_DIFF of the live record; its HAS_PROTOCOL_EDITION episode is
// LEGACY_UNDATED until the ingestion service back-fills the authorizing assertion (QS-2b).
MATCH (a:Protocol)-[r:HAS_STEP]->(b:ProtocolStep)
MERGE (ed:ProtocolEdition:VersionedState {uid: 'hu:protocol-edition:' + split(a.uid, ':')[-1] + '-legacy'})
  ON CREATE SET ed.id = split(a.uid, ':')[-1] + '-legacy', ed.stateType = 'ProtocolEdition', ed.editionLabel = 'legacy',
    ed.changeProvenance = 'SNAPSHOT_DIFF', ed.payloadHash = 'sha256:legacy-migration-' + split(a.uid, ':')[-1],
    ed.privacyClass = coalesce(a.privacyClass, 'INTERNAL'), ed.createdAt = coalesce(a.createdAt, datetime()), ed.updatedAt = coalesce(a.updatedAt, datetime())
MERGE (a)-[he:HAS_PROTOCOL_EDITION]->(ed) ON CREATE SET he.relationshipUid = 'hu:rel:' + ed.id + ':has-protocol-edition', he.status = 'LEGACY_UNDATED'
CREATE (ed)-[n:HAS_PROTOCOL_STEP]->(b) SET n = properties(r), n.orderIndex = coalesce(r.orderIndex, r.position, r.order) DELETE r;
// Person-[:LINKS_TO]->PseudonymousActor and HAS_PARTICIPANT_TOKEN are identity claims: exported to ResolutionHypothesis
// records by the ingestion service, then deleted; not rewritten here (W01, W23).

// ---- 6b. Archetype and parent labels for every @node(labels: [...]) type, generated from the final SDL. ----
