// W01 operations proposal (run-2026-10-04-fable51-01). Neo4j 5.26 Community-compatible statements only.
// Executed on embedded Neo4j 5.26.31 Community on 2026-10-04 (see 07-operations.md section 1 for results).
// Enterprise-only property-existence / type constraints are listed as comments at the end (not executed).

// --- node identity: uid and live id per primary label (labels shared by specializations are covered by the parent label)
CREATE CONSTRAINT w01_organization_uid IF NOT EXISTS FOR (n:Organization) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w01_organization_id IF NOT EXISTS FOR (n:Organization) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w01_consumer_brand_uid IF NOT EXISTS FOR (n:ConsumerBrand) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w01_consumer_brand_id IF NOT EXISTS FOR (n:ConsumerBrand) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w01_facility_uid IF NOT EXISTS FOR (n:Facility) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w01_facility_id IF NOT EXISTS FOR (n:Facility) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w01_org_snapshot_uid IF NOT EXISTS FOR (n:OrganizationSnapshot) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w01_org_snapshot_id IF NOT EXISTS FOR (n:OrganizationSnapshot) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w01_person_uid IF NOT EXISTS FOR (n:Person) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w01_person_id IF NOT EXISTS FOR (n:Person) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w01_pseudonymous_actor_uid IF NOT EXISTS FOR (n:PseudonymousActor) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w01_pseudonymous_actor_id IF NOT EXISTS FOR (n:PseudonymousActor) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w01_anonymous_actor_uid IF NOT EXISTS FOR (n:AnonymousActor) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w01_anonymous_actor_id IF NOT EXISTS FOR (n:AnonymousActor) REQUIRE n.id IS UNIQUE;

// --- relationship identity: relationshipUid unique per W01 asserted edge type (relationship uniqueness constraints, Neo4j >= 5.7)
CREATE CONSTRAINT w01_rel_board_member_of IF NOT EXISTS FOR ()-[r:BOARD_MEMBER_OF]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w01_rel_employed_by IF NOT EXISTS FOR ()-[r:EMPLOYED_BY]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w01_rel_advises_organization IF NOT EXISTS FOR ()-[r:ADVISES_ORGANIZATION]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w01_rel_founded_organization IF NOT EXISTS FOR ()-[r:FOUNDED_ORGANIZATION]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w01_rel_invested_in IF NOT EXISTS FOR ()-[r:INVESTED_IN]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w01_rel_holds_equity_in IF NOT EXISTS FOR ()-[r:HOLDS_EQUITY_IN]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w01_rel_has_ip_interest_in IF NOT EXISTS FOR ()-[r:HAS_IP_INTEREST_IN]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w01_rel_receives_compensation_from IF NOT EXISTS FOR ()-[r:RECEIVES_COMPENSATION_FROM]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w01_rel_affiliated_with IF NOT EXISTS FOR ()-[r:AFFILIATED_WITH]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w01_rel_parent_of IF NOT EXISTS FOR ()-[r:PARENT_OF]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w01_rel_owns_brand IF NOT EXISTS FOR ()-[r:OWNS_BRAND]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w01_rel_operates_facility IF NOT EXISTS FOR ()-[r:OPERATES_FACILITY]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w01_rel_markets_product IF NOT EXISTS FOR ()-[r:MARKETS_PRODUCT]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w01_rel_manufactures_product IF NOT EXISTS FOR ()-[r:MANUFACTURES_PRODUCT]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w01_rel_distributes_product IF NOT EXISTS FOR ()-[r:DISTRIBUTES_PRODUCT]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w01_rel_contract_manufactures_for IF NOT EXISTS FOR ()-[r:CONTRACT_MANUFACTURES_FOR]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w01_rel_supplies_ingredient_material IF NOT EXISTS FOR ()-[r:SUPPLIES_INGREDIENT_MATERIAL]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w01_rel_endorses_product IF NOT EXISTS FOR ()-[r:ENDORSES_PRODUCT]-() REQUIRE r.relationshipUid IS UNIQUE;

// --- retrieval: as-of filters and assertion lookup on the busiest role types
CREATE INDEX w01_board_member_of_asof IF NOT EXISTS FOR ()-[r:BOARD_MEMBER_OF]-() ON (r.recordedFrom, r.validFrom);
CREATE INDEX w01_employed_by_asof IF NOT EXISTS FOR ()-[r:EMPLOYED_BY]-() ON (r.recordedFrom, r.validFrom);
CREATE INDEX w01_advises_asof IF NOT EXISTS FOR ()-[r:ADVISES_ORGANIZATION]-() ON (r.recordedFrom, r.validFrom);
CREATE INDEX w01_holds_equity_asof IF NOT EXISTS FOR ()-[r:HOLDS_EQUITY_IN]-() ON (r.recordedFrom, r.validFrom);
CREATE INDEX w01_affiliated_with_assertion IF NOT EXISTS FOR ()-[r:AFFILIATED_WITH]-() ON (r.assertionUid);
CREATE INDEX w01_parent_of_assertion IF NOT EXISTS FOR ()-[r:PARENT_OF]-() ON (r.assertionUid);
CREATE INDEX w01_org_type IF NOT EXISTS FOR (n:Organization) ON (n.organizationType);
CREATE INDEX w01_facility_kind IF NOT EXISTS FOR (n:Facility) ON (n.facilityKind);

// --- live fulltext indexes retained (D-015); stored property names equal GraphQL names for these types
CREATE FULLTEXT INDEX OrganizationName IF NOT EXISTS FOR (n:Organization) ON EACH [n.name, n.searchText, n.legalName, n.displayName, n.canonicalTicker];
CREATE FULLTEXT INDEX PersonSearch IF NOT EXISTS FOR (n:Person) ON EACH [n.name, n.description, n.bio, n.title, n.searchText];
CREATE FULLTEXT INDEX OrganizationSnapshotSearch IF NOT EXISTS FOR (n:OrganizationSnapshot) ON EACH [n.name, n.description, n.sector, n.searchText];

// --- Enterprise only (NOT executed; Community rejects them, see 00-baseline.md):
// CREATE CONSTRAINT w01_org_entity_type_exists FOR (n:Organization) REQUIRE n.entityType IS NOT NULL;
// CREATE CONSTRAINT w01_cohort_privacy_exists FOR (n:CohortParticipant) REQUIRE n.privacyClass IS NOT NULL;
// CREATE CONSTRAINT w01_board_member_of_assertion_exists FOR ()-[r:BOARD_MEMBER_OF]-() REQUIRE r.assertionUid IS NOT NULL;
// CREATE CONSTRAINT w01_board_member_of_recorded_from_type FOR ()-[r:BOARD_MEMBER_OF]-() REQUIRE r.recordedFrom IS :: ZONED DATETIME;
// (repeat the two relationship constraints for every W01 asserted edge type)
