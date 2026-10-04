# W21 operations recommendation

Target: `@neo4j/graphql` 7.6.3, Neo4j 5.26 (tested 5.26.31 Community embedded). No runtime implementation is proposed; this is the physical contract the merged schema needs for the W21 scope. File: `operations.cypher`.

## 1. Uniqueness and indexes (stored property names)

| Statement | Why | Community 5.26.31 |
|---|---|---|
| `w21_<label>_uid` uniqueness for Platform, Channel, Series, Episode, EpisodeSegment, RelationshipAssertion, ClaimEvidenceAssessment, RetellingFidelityAssessment, ConflictRelevanceAssessment | label-scoped index-backed MERGE on `uid` (fixtures and ingestion bind `(:Episode {uid})`); archetype-label uniqueness (baseline) already guarantees correctness | applied |
| `w21_<label>_id` uniqueness for Platform, Channel, Series, Episode, EpisodeSegment, Claim, ClaimOccurrence, RelationshipAssertion | GraphQL `where: {id}` per type; `id` = opaque uid segment (INV-106); W21 types use no `@alias` | applied |
| `w21_claim_occurrence_segment_kind`, `w21_episode_segment_type` | CQ-CL-08 filters | applied |
| `w21_episode_published_at` | statement date joins (CQ-CL-05, CQ-AX-18) | applied |
| `w21_claim_type` | CQ-CL-02 facet | applied |
| `w21_conflict_relevance_level` (relevanceLevel, disclosureFinding) | CQ-CL-05 | applied |
| relationship-property indexes `APPEARS_IN(roleType)`, `APPEARS_IN(assertionUid)`, `SPONSORS_CONTENT(assertionUid)`, `ACCOMPANIES_TALK(assertionUid)`, `RETELLS(relationshipUid)`, `QUALIFIED_BY(relationshipUid)` | idempotent MERGE keys; QS-4a citation lookups | applied |
| `FULLTEXT EpisodeSearch` on Episode(name, title, summaryText); `FULLTEXT ClaimSearch` on Claim(name, description, searchText) | live `@fulltext` names retained (D-015); the library requires the index to exist | applied |
| Existence constraints: ClaimOccurrence.predicate, EpisodeSegment.segmentType, ConflictRelevanceAssessment.methodVersion, QUALIFIED_BY.qualificationKind, RETELLS.retellingMode, APPEARS_IN.roleType; type constraint SourceLocator.mediaEndSeconds :: FLOAT | defence in depth | **rejected on Community (7 of 37 statements; 30 applied), as expected; Enterprise behaviour unverified** |

Already in the baseline and reused (not repeated): archetype uid uniqueness, `live_claim_uid`, `live_claim_occurrence_uid`, `source_canonical_uri`, `assertion_basis`, `assertion_speech_act`, `assertion_predicate(_recorded)`, `source_locator_quote_hash`, `retells_link_basis_exists` (Enterprise).

Not indexed on purpose: `Episode.title` alone (covered by fulltext), `Platform.url` (display only), `EpisodeSegment.chapterTitleVerbatim` (low selectivity, display).

Vector: Episode and Claim keep `searchEmbedding` as a derived property; whether `@vector` is retained is Fable's merge decision (D-014). Retrieval justification if kept: semantic lookup of claims across paraphrases before `INSTANCE_OF` resolution (CQ-CL-06 candidate matching). Dimensions are not stated because no embedding model is presumed.

## 2. Retrieval patterns

- QS-1a for any ClaimOccurrence (the trace already covers `ASSERTED_BY`, locators, snapshots, adjudications). Add the W21 hops: `OCCURS_IN` container, `OCCURS_IN_SEGMENT` segment kind, `QUALIFIED_BY` qualifiers, outgoing `RETELLS` (primary vs retelling), `ConflictRelevanceAssessment` via `FOR_OCCURRENCE`.
- Rendition view (Q01-1/Q01-2): Episode <- RENDITION_OF - Source - HAS_SNAPSHOT -> SourceSnapshot - HAS_LOCATOR -> SourceLocator <- SUPPORTED_BY - ClaimOccurrence; segments via HAS_SEGMENT + IN_RENDITION.
- Independence count (Q04-1): instances of a Claim without outgoing RETELLS, grouped by asserter (then by W01 affiliation for CQ-AX-05).
- Statement-date role overlap (CQ-AX-18): join `Episode.publishedAt` (or the occurrence's own valid time) to QS-2a over FINANCIAL_INTEREST edges.

## 3. Application validation (service-enforced; Cypher reports)

Write-time rules the ingestion service must enforce, each with its report query:

| Rule | Report |
|---|---|
| ClaimOccurrence: exactly one `ASSERTED_BY` (Person/Organization/PseudonymousActor/AnonymousActor) and exactly one `OCCURS_IN` | V-410, V-W21-04 |
| every locator of an occurrence lies in its container or a rendition | V-411 |
| MEDIA_TIME only on playable renditions, with `mediaTimeBasis` | V-W21-01 |
| segment/occurrence sponsor-read agreement; segment locators on the segment's rendition | V-W21-02, V-W21-05 |
| deck never RENDITION_OF a talk; accompaniment only as an asserted ACCOMPANIES_TALK | V-W21-03, V-421-style assertion backing (add ACCOMPANIES_TALK to assertedTypes) |
| QUALIFIED_BY inside one container, or one snapshot when container-less | V-416 / V-W21-12 |
| RETELLS acyclic, typed, distinct span; fidelity flags only on assessments | V-412..V-415 |
| QUALIFIED_BY inside one container | V-416 |
| INSTANCE_OF names rule or hypothesis; never from QUESTIONS | V-417, V-W21-11 |
| SPONSORS_CONTENT endpoints and assertion backing | V-421, V-W21-07 |
| RECOMMENDS only from the start node's own RECOMMENDS speech act | V-W21-06 (replaces V-423, W21-SR-07) |
| correction keeps the prior citation | V-W21-08, V-402, V-404, V-409 |
| disclosure finding needs a span; NOT_DISCLOSED never from partial capture | V-W21-09, V-426 |

## 4. Transactions, concurrency, idempotence

- One transaction per act of capture: SourceSnapshot + DocumentTextVersion + locators. One transaction per extracted occurrence: the ClaimOccurrence, its `HAS_SUBJECT`/`HAS_OBJECT`, `ASSERTED_BY`, `OCCURS_IN`, `SUPPORTED_BY`, `WAS_GENERATED_BY`, and any projected asserted edge (SPONSORS_CONTENT, APPEARS_IN) that cites it. A projected edge is never committed without its assertion (V-421).
- Idempotence: MERGE nodes on `uid`; MERGE asserted edges on `(start, type, end, assertionUid)`; MERGE structural edges carrying `relationshipUid` (QUALIFIED_BY, RETELLS) on that uid. Derived edges (INSTANCE_OF, RECOMMENDS) are regenerated by rule; deleting and re-deriving them never loses history because the licensing assertion stays.
- Concurrency: two extractors writing the same utterance must converge on one occurrence uid (deterministic uid from container uid + primary locator quoteHash + asserter uid); otherwise V-419-style duplicates appear. Re-anchoring jobs only create new locators and REANCHORS edges; they never update an existing locator (immutability, INV-504).
- Status: `ClaimOccurrence.status` is written only as the projection of CAPTURE_FIDELITY adjudications and SUPERSEDES (INV-103); fixtures use a POLICY adjudication.

## 5. Capability and edition conditions

- Community 5.26: uniqueness, range, text and fulltext indexes and relationship-property indexes work; all cardinality and existence rules are application-side. Enterprise: existence/type constraints in section B of `operations.cypher` add defence in depth (not verified; no Enterprise instance was available).
- `@neo4j/graphql` 7.6.3: no `@unique`; two fields with the same relationship type and direction but different target types (`Episode.personsInEpisode` / `pseudonymousParticipants`, `ClaimEvidenceAssessment.basedOn*`, sponsoring fields) built without error in the stub build (runtime filtering by target label was not exercised against a database).
- GraphQL label behaviour: `ClaimOccurrence` and `RelationshipAssertion` carry the `Assertion` label, so W00's generic `Assertion` type returns them too; consumers wanting only generic assertions filter by absence of the specific labels.

## 6. Lifecycle and migration

Order (see `migration-map.yaml`): (1) create uids and archetype labels; (2) add `Assertion` label to ClaimOccurrence and RelationshipAssertion; copy `UTTERED_BY` to `ASSERTED_BY`, split multi-speaker and multi-container occurrences; (3) relabel ExperienceReport to ClaimOccurrence, route CohortParticipant reports to the private store; (4) backfill SourceSnapshots for every transcript text version (rendition Source per transcript; `captureCompleteness` UNKNOWN when no capture metadata); (5) convert OrderingMetadata time strings to MEDIA_TIME locators only where the rendition is known; (6) backfill assertions for APPEARS_IN, SPONSORS (-> SPONSORS_CONTENT), OPERATES_CHANNEL, SERVES_ON_CHANNEL edges with a MIGRATION adjudication; (7) Claim.evidenceStrength -> ClaimEvidenceAssessment (PROPOSED, `legacy-unspecified`); (8) re-type RECOMMENDS edges by speech act (keep only own RECOMMENDS acts); (9) merge INCLUDES_EPISODE into HAS_EPISODE; (10) run V-41x and V-W21 suites; review rows.

Compatibility: live field names kept where meaning is unchanged (`personsInEpisode`, `hasSeries`, `hasEpisodes`, `includesEpisodes`, `occurrences`, `utteranceText`); retired fields are listed per row in the migration map. `Episode.mentions` stays read-only until W21-SR-10 is ruled.

## 7. Ingestion and normalization overhead

Per captured rendition: one snapshot hash (NFC-WS1 over stored text, or raw bytes when fetchable), one text version. Per occurrence: one locator per rendition in which it is located (typically 1-2), one quoteHash per locator. Per segment: zero to one locator per rendition. Retelling detection requires a ResolutionHypothesis per candidate match (BELLLABS_MATCH) because real retellings rarely cite a span (fx04: the NMN.com citation did not resolve). Dynamic-ad observation requires periodic recapture of directory/feed records: each recapture is a new snapshot and, if sponsors changed, new SPONSORS_CONTENT assertions with OBSERVATION_ONLY bases; older ones are bounded by SUPERSEDES {VALIDITY_BOUNDED} only when a source states an end.
