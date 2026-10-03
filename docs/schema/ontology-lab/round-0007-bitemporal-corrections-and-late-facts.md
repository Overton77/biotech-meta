# Round 0007: Bitemporal Corrections and Late-Arriving Facts

> **Integration decision (2026-10-03):** `ACCEPTED`. KCR-0007-1, -2, -3 accepted. Per-bound precision and basis replace the single validTimeBasis of round 0009. Asserted edges carry assertionUid (not projectionOfAssertionUid, which stays the derived-edge property). Catalog 0.2.0; see [proposal-index.md](./proposal-index.md).


Status recommended by Lane 5: `ACCEPTED` for the temporal edge profile, the correction / fact-end / late-fact rules, precision and basis fields, the exclusivity rule, and the live `*Snapshot` seam. `OPEN` for kernel-change requests KCR-0007-1, KCR-0007-2 and KCR-0007-3 until the coordinator rules on them. The coordinator sets the final status.

## Header

- Round ID: 0007
- Date: 2026-10-03
- Builder: Lane 5 (time, private user context, protocols-in-use, recommendation history)
- Challenger: Lane 5 internal challenger; cross-lane review requested from Lane 4 (provenance, live evidence pipeline) and Lane 6 (adversarial review)
- Owning module: `temporal` (with explicit kernel-change requests against `kernel` and `provenance`)
- Candidate schema version: 0.2.0 (breaking meaning: `Assertion.status` becomes a current projection and historical status is recovered from adjudications; see migration note)
- Source schema digest: `current_biotech_schema.graphql` sha256 `86b5e0b5d11d203bd75b69b4507b0aad97d5df2495d3897ca64272068ea5f112`; `catalog/schema.yaml` 0.1.0 sha256 `4c3203f57706c43fe508549211ed6f11910e2150947814c047122eb34f29825f`
- Decision status: `ACCEPTED` (set by the integration owner on 2026-10-03; the lane recommendation is preserved below)

## Intent and competency questions

- Decision or workflow being supported: replay any answer or recommendation exactly as BellLabs held it at a recorded instant `R` about a domain instant `V`; ingest corrections, retractions, late historical sources, and validity endings without rewriting the past.
- In scope: storage of valid time and recorded time on (a) `HAS_STATE` attachments, (b) asserted edges, (c) `Assertion` nodes, (d) `SourceSnapshot` and source revision events; correction versus fact ending; late facts; retracted, corrected, and superseded sources without changing historical adjudications (closes OPEN-QUESTIONS P0-4); `timePrecision` and `validTimeBasis`; exclusion of overlapping mutually exclusive states; mapping of the live `OrganizationSnapshot`, `ProductSnapshot`, `ListingSnapshot` (`TemporalSnapshot` interface) and of `TemporalMetadata` / `RecommendationMetadata`.
- Out of scope: parsing of free-text temporal expressions and recurrences (protocol schedules stay in the protocol module), time zones beyond "store UTC instants plus precision", planned or expected future times (owned by round 0008 as `expectedBy`), physical storage engine choice for the shared graph.
- Competency question IDs: `CQ-TM-01`, `CQ-TM-02`, `CQ-TM-03`, `CQ-TM-04` (extended), `CQ-TM-05`, `CQ-TM-06` (new), `CQ-TM-07` (new), `CQ-EV-05`, `CQ-RC-04`, `CQ-RC-07` (new, shared with round 0008).

## Case packet

| Source snapshot | Source kind | Exact locator | Published/observed time | Authority scope |
|---|---|---|---|---|
| PubMed record PMID 9500320 (Wakefield et al., Lancet 1998;351:637-41, DOI 10.1016/s0140-6736(97)11096-0) | bibliographic database record | PubMed E-utilities record, field `PublicationTypeList` | published 1998-02-28; observed 2026-10-03 with publication types `Journal Article`, `Research Support, Non-U.S. Gov't`, `Retracted Publication` | what the record shows now; not what the record showed before the retraction was linked |
| PubMed record PMID 20137807 (Lancet 2010;375:445, DOI 10.1016/S0140-6736(10)60175-4) | retraction notice record | PubMed record, publication type `Retraction Notice` | published 2010-02-06; observed 2026-10-03 | that a retraction notice was issued for the article; not the reasons in full |
| NLM, "Errata, Retractions, and Other Linked Citations in PubMed" (SRC-NLM-ERRATA-RETRACTION-POLICY) | database policy page | sections on Retraction Notice [PT], Retracted Publication [PT], errata, corrected and republished articles | observed 2026-10-03 | how PubMed links notices to originals and which publication types mark them |
| HL7 FHIR R5 Provenance (SRC-FHIR-R5-PROVENANCE) | interoperability standard | elements `occurred[x]`, `recorded`, `entity.role` (`revision`, `quotation`, `source`, `instantiates`, `removal`) | FHIR v5.0.0; observed 2026-10-03 | separation of when an activity occurred from when it was recorded; revision and removal as provenance roles |
| Snodgrass, *Developing Time-Oriented Database Applications in SQL* (2000) (SRC-SNODGRASS-TDB-2000) | textbook | ch. 10 "Bitemporal Tables" (valid-time begin/end and transaction-time start/stop columns; modifications sequenced on valid time are current on transaction time) | 2000; author PDF observed 2026-10-03 | bitemporal semantics, sequenced modifications, granularity |
| Kulkarni and Michels, "Temporal features in SQL:2011", SIGMOD Record 41(3):34-43, 2012 (SRC-SQL2011-TEMPORAL) | standards explainer | system-versioned tables, application-time period tables, `WITHOUT OVERLAPS` | 2012 | system time is set by the DBMS, not by users; application-time keys may forbid overlaps |
| PostgreSQL wiki "SQL2011Temporal" (SRC-PG-WIKI-SQL2011-TEMPORAL) | implementation notes | `PRIMARY KEY (id, valid_at WITHOUT OVERLAPS)`; "Application Time and System Time do not interact" | observed 2026-10-03 | syntax and semantics of temporal keys in a transactional store |
| XTDB "Time in XTDB" (SRC-XTDB-TIME) | product documentation | `FOR VALID_TIME AS OF`, `FOR SYSTEM_TIME AS OF`, `_valid_from/_valid_to/_system_from/_system_to` | observed 2026-10-03 | a native bitemporal as-of query contract |
| Datomic "Database Filters" (SRC-DATOMIC-FILTERS) | product documentation | `as-of`, `since`, `history` filters | observed 2026-10-03 | transaction-time time travel only; valid time must be modeled in the domain |
| Neo4j community versioning pattern (SRC-NEO4J-VERSIONED-GRAPH-PATTERN) | community engineering write-ups | identity node plus state nodes, `from`/`to` on relationships; one write-up uses a max-long sentinel for open `to` | observed 2026-10-03 | that Neo4j users model time explicitly; not an official Neo4j feature |

Search for an official Neo4j bitemporal or `AS OF` feature: none found. Direct fetch of neo4j.com was blocked by the egress proxy; Neo4j documentation pages were read through a search-extraction tool. The statement "Neo4j has no native system-versioned time travel" is therefore an unverified negative, recorded as such.

## Identification and clustering

For this round the mentions are temporal expressions and revision signals.

| Mention | Candidate kind | Candidate identity | External identifiers | Resolution status | Rationale |
|---|---|---|---|---|---|
| "Retracted Publication" on PMID 9500320 | new `SourceSnapshot` of the PubMed record plus `SourceRevisionEvent` (RETRACTION) | `hu:source:pubmed-9500320` | PMID 9500320, DOI 10.1016/s0140-6736(97)11096-0 | resolved | the record changed; the article text did not |
| "Retraction--Ileal-lymphoid-nodular hyperplasia..." | notice `Source` that announces the event | `hu:source:pubmed-20137807` | PMID 20137807 | resolved | a notice is its own publication with its own identifiers |
| "published 1998 Feb 28" | `SourceSnapshot.publishedAt`, precision DAY | n/a | n/a | resolved | issuer date |
| "Formula updated November 2025" (synthetic label, fixture) | `Assertion.validFrom` = 2025-11-01, `validFromPrecision` MONTH, `validFromBasis` STATED_BY_SOURCE | fixture | none | synthetic | stated month, unknown day |
| "Available as of March" | observation witness only; `validFromBasis` OBSERVATION_ONLY, `validFrom` null | n/a | n/a | rule | minimal pair 5 in competency-questions.md |
| "Launched in March 2026" | `validFrom` 2026-03-01 MONTH, STATED_BY_SOURCE | n/a | n/a | rule | minimal pair 5 |
| archived page capture of 2019-05-10 fetched 2026-08-01 | `observedAt` 2019-05-10, `retrievedAt` 2026-08-01, assertion `recordedAt` 2026-08-01 | fixture | none | synthetic | late-arriving historical fact |

## Cooperative-adversarial dialogue

**Builder:** The catalog already names the clocks. What it lacks is an executable rule for where each clock is stored and what may be written when. I propose: valid time is claimed by an `Assertion` and copied onto the edges that project it; recorded time lives on every attachment or asserted edge as `recordedFrom` / `recordedTo` and on the `Assertion` as `recordedAt` / `recordedTo`. Everything is append-only except a single write that closes `recordedTo`.

**Challenger:** Why not let ingestion simply set `validTo` on the existing edge when a formulation is replaced? It is one write and the current answer is right.

**Builder:** The current answer is right and the past answer becomes wrong. On 2026-05-01 BellLabs believed the formulation had no known end. A recommendation made on that day cites that belief. If we overwrite `validTo`, replaying the 2026-05-01 decision shows BellLabs "knew" an end date it learned on 2026-06-20. Snodgrass's bitemporal modification rule is the reference: a modification is sequenced on valid time and current on transaction time. We close the old episode in recorded time and open a new one with the bounded validity.

**Challenger:** Then a correction and a fact ending produce the same shape: old episode closed, new episode opened. How does a query tell them apart?

**Builder:** By two things that differ in the graph, not by a label alone. After a fact ends, the old state is still attached in current recorded time for its now-bounded valid interval. After a correction, the old state has no current-recorded attachment for that interval at all, because BellLabs no longer believes it was ever true; the replacement state covers the same valid interval. In addition the `SUPERSEDES` edge carries `supersessionKind` `VALIDITY_BOUNDED` or `SOURCE_CORRECTION`. The as-of query at `R` = now and `V` = April returns the old value in the first case and the new value in the second.

**Challenger:** PubMed now tags PMID 9500320 as a Retracted Publication. Do we mark every assertion extracted from it `REJECTED`?

**Builder:** No. The assertion "this article reported association X" is still a correct record of what the article reported. What changed is whether that report supports anything. We record the revision as a `SourceRevisionEvent`, capture the changed PubMed record as a new `SourceSnapshot`, and add a new `Adjudication` (recorded now, citing the revision event) that supersedes the earlier one. The 2009 adjudication stays as it was, pointing at the snapshot it examined. That is how OPEN-QUESTIONS P0-4 closes.

**Challenger:** An erratum that changes a number is different. The article now reports 25 where it used to report 250.

**Builder:** Agreed. That is a source correction of content. The corrected snapshot yields a new assertion with the corrected literal, and it supersedes the old assertion with kind `SOURCE_CORRECTION`. The old assertion's `validFrom` and `validTo` are untouched; its `recordedTo` is set to when BellLabs learned of the correction.

**Challenger:** `Assertion.status` is a single mutable field. If it moves from `ACCEPTED` to `SUPERSEDED`, a replay at a time when it was accepted reads `SUPERSEDED`.

**Builder:** Correct, and that is the failing case behind KCR-0007-1 and KCR-0007-2. Status becomes a current projection. Historical status is recovered from immutable `Adjudication` records, each with `recordedAt`, and from `SUPERSEDES` edges with `recordedAt`. Automated acceptance is recorded as an `Adjudication` with `reviewerType: POLICY`, so every transition has a timestamped record.

**Challenger:** A late source from 2019 arrives today. If we set `recordedFrom` to 2019, every replay of 2024 decisions changes.

**Builder:** `recordedFrom` is set by the ingestion service to the commit time, never supplied by a client, which is the SQL:2011 system-versioning rule. Valid time can be in the past; recorded time cannot. The archive capture time goes to `SourceSnapshot.observedAt`, and the fetch goes to `retrievedAt`.

**Challenger:** "Launched in 2019" stored as 2019-01-01 makes the product "valid" in February 2019 when we do not know that.

**Builder:** Hence `validFromPrecision` and `validToPrecision`. A bound is stored as the first instant of its precision period. An as-of check returns `KNOWN` only when `V` is outside the uncertainty period, and `POSSIBLE` inside it.

**Challenger:** Two formulation versions for one variant overlap because one has an unknown end. Do we reject the commit?

**Builder:** Only definite overlaps are rejected: both intervals have known bounds on the overlapping sides after precision is accounted for, and their recorded intervals also overlap. Possible overlaps caused by an unknown bound go to a review queue. Nonexclusive relationships, such as two marketers of one product, may overlap freely.

## Builder proposal

### 1. Clocks and where each one lives

| Clock | Meaning | Stored on | Set by | Mutability |
|---|---|---|---|---|
| `validFrom` / `validTo` | when the proposition or state held in the modeled world (half-open) | `Assertion` (claimed); copied to `HAS_STATE` and asserted edges that project it | extractor from source text, or reviewer by inference with a rule | immutable on every record |
| `validFromPrecision` / `validToPrecision` | granularity of each bound | same records as the bound | extractor | immutable |
| `validFromBasis` / `validToBasis` | why the bound has its value: stated, publication proxy, observation only, inferred, unknown | same records as the bound | extractor or reviewer | immutable |
| `recordedFrom` / `recordedTo` | when BellLabs held this attachment as part of its record | `HAS_STATE` and asserted edges | ingestion service transaction time | `recordedFrom` immutable; `recordedTo` written once |
| `recordedAt` / `recordedTo` | when BellLabs held this assertion as part of its record | `Assertion` | ingestion service | `recordedAt` immutable; `recordedTo` written once (KCR-0007-1) |
| `recordedAt` | when the adjudication was committed | `Adjudication` (KCR-0007-2) | service | immutable |
| `publishedAt` | issuer's date for this version of the artifact | `SourceSnapshot` | extractor | immutable |
| `observedAt` | when the content was seen as displayed (crawl time, or archive capture time) | `SourceSnapshot` | capture tool | immutable |
| `retrievedAt` | when BellLabs fetched the bytes | `SourceSnapshot` | capture tool | immutable |
| `effectiveFrom` / `effectiveTo` | an effective period printed inside a versioned artifact (for example a specification's stated effective date) | `VersionedState` payload | extractor | immutable payload; the attachment edge governs queries |
| `createdAt` | creation of the record | every node | service | never a domain time |

`effectiveFrom` / `effectiveTo` is clarified (`# CHANGE`): it is payload text the source states about itself. Query validity is always taken from the attachment edge, which may differ when BellLabs has evidence that the stated period was wrong.

### 2. (a) `HAS_STATE` attachment

Properties, per starter-property-model.md, refined:

| Property | Required | Rule |
|---|---|---|
| `relationshipUid` | yes | stable audit id of this episode |
| `validFrom`, `validTo` | nullable | half-open; null means unknown; sentinel maximum dates are forbidden |
| `validFromPrecision`, `validToPrecision` | required when the bound is non-null | `INSTANT`, `DAY`, `MONTH`, `QUARTER`, `YEAR`, `DECADE` |
| `validFromBasis`, `validToBasis` | yes | `STATED_BY_SOURCE`, `PUBLICATION_PROXY`, `OBSERVATION_ONLY`, `INFERRED`, `UNKNOWN` (`# CHANGE`: the single `validTimeBasis` splits per bound) |
| `recordedFrom` | yes | transaction time of the commit; never client-supplied |
| `recordedTo` | nullable | written once, `>= recordedFrom` |
| `assertionUid` | when source-derived | the assertion that authorizes this episode |

Rules:

1. One relationship per recorded-time episode. Neo4j permits parallel relationships between the same pair; a retracted-then-reinstated state gets a second edge to the same immutable state node.
2. All properties are immutable after commit except one write of `recordedTo` from null to a timestamp.
3. Domain attachment types that carry a versioned state (`HAS_FORMULATION_VERSION`, `HAS_PACKAGE_CONFIGURATION`, `HAS_REGISTRATION_VERSION`, the proposed `HAS_PROTOCOL_EDITION`) declare `temporalProfile: bitemporal_attachment` in the catalog and carry exactly these properties. `HAS_STATE` is the generic type used when no domain type exists. There is one contract, not two edges.
4. The state node holds only payload plus `payloadHash`; it holds no valid or recorded time of its own.

### 3. (b) Asserted edges

An asserted edge (for example `MARKETS_PRODUCT`) carries the same profile plus `assertionUid` (required; the integration owner renamed the lane's `projectionOfAssertionUid` here because that property is reserved for derived edges). Its valid bounds, precisions, and bases are copied from the assertion at projection time and must equal them (V-505); a mismatch means someone edited one of them. `recordedFrom >= assertion.recordedAt`; the edge's `recordedTo` equals the assertion's `recordedTo` when the assertion is closed. The edge is a regenerable traversal projection; the assertion is the history.

### 4. (c) `Assertion`: KCR-0007-1

- Content is immutable: `predicate`, `polarity`, subject, object or typed literal, `validFrom`, `validTo`, precisions, bases, `jurisdiction`. `contentHash` is the sha256 of the canonicalized content and is written at commit.
- `recordedAt` (required, existing): when the assertion entered the record.
- `recordedTo` (new, nullable): when BellLabs stopped holding this assertion as a current record because it was superseded. Written once. An assertion that is merely rejected by review is not closed; it stays in the record with a rejecting adjudication, which is how "a source said it and we rejected it" is preserved.
- `SUPERSEDES` (new, structural): `(newer:Assertion)-[:SUPERSEDES {supersessionKind, recordedAt, sourceRevisionEventUid}]->(older:Assertion)`. `supersessionKind`: `SOURCE_CORRECTION` (the source changed the content), `VALIDITY_BOUNDED` (same content, a bound became known), `EXTRACTION_FIX` (BellLabs misread an unchanged source), `RESOLUTION_FIX` (wrong entity linked), `DUPLICATE_MERGE`. On commit, `older.recordedTo = SUPERSEDES.recordedAt = newer.recordedAt`.
- No `supersededBy` property. The edge is the single representation.
- `status` becomes a current projection (`# CHANGE`, breaking meaning). Historical status at `R` is derived: `SUPERSEDED` if `recordedTo <= R`; otherwise the verdict mapping of the latest `Adjudication` with `recordedAt <= R`; otherwise `EXTRACTED`.

Failing case that forces the change: a recommendation recorded 2026-04-10 cites assertion A1 (status then `ACCEPTED`). A1 is superseded on 2026-06-15. With a mutable status and no `recordedTo`, the replay of the 2026-04-10 decision reads `SUPERSEDED` and cannot show that A1 was the accepted belief at decision time.

### 5. `Adjudication`: KCR-0007-2

- `recordedAt` required; adjudications are immutable.
- A re-review is a new `Adjudication` with `(new)-[:SUPERSEDES {supersessionKind: 'RE_REVIEW' | 'SOURCE_REVISION', recordedAt}]->(old)`.
- An adjudication's `SUPPORTED_BY` / `CONTRADICTED_BY` locators belong to snapshots whose `retrievedAt <= adjudication.recordedAt` (V-511). Historical adjudications are never re-pointed to newer snapshots.
- `reviewerType` gains `POLICY` for automated acceptance, so status transitions always have a record.

Verdict to status projection (as integrated): `Assertion.status` projects only adjudications with `adjudicationKind = CAPTURE_FIDELITY` and `SUPERSEDES` records. A SUPPORT adjudication (whether the proposition is supported by evidence) never changes status; the lane's original table, which mapped `CONTRADICTED` to `REJECTED`, was replaced on 2026-10-03 because it put truth into status (round 0006 KCR-4.6, catalog `assertionStatusMeaning`).

| Latest CAPTURE_FIDELITY adjudication at `R` | Projected status at `R` |
|---|---|
| `SUPPORTED` (the record accurately captures the source statement) | `ACCEPTED` |
| `CONTRADICTED` (the record misreads the source) | `REJECTED` |
| `PARTIALLY_SUPPORTED` or `INSUFFICIENT` | `UNRESOLVED` |
| two unsuperseded capture-fidelity adjudications with different verdicts | `DISPUTED` |
| `recordedTo <= R` with an incoming `SUPERSEDES` | `SUPERSEDED` |
| none | `EXTRACTED` (or `PROPOSED` if a proposing agent run is recorded) |

### 6. (d) `SourceSnapshot` and source revisions: KCR-0007-3

- `SourceSnapshot` is immutable. A changed page, a changed database record, or a newly linked notice produces a new snapshot with a new `contentHash`.
- `publishedAt` (issuer's date of this version, with `publishedAtPrecision`), `observedAt` (when the content was seen as displayed), `retrievedAt` (fetch time). For a live crawl `observedAt = retrievedAt`. For an archive capture they differ, and that difference is what makes a late-arriving fact honest.
- New `SourceRevisionEvent` (`Occurrence`, provenance module, kernel-owned): `revisionKind` in `ERRATUM`, `RETRACTION`, `EXPRESSION_OF_CONCERN`, `CORRECTED_AND_REPUBLISHED`, `NEW_VERSION`, `SILENT_CONTENT_CHANGE`, `WITHDRAWAL`, `REINSTATEMENT`; `occurredAt` (issuer time, nullable, with precision), `recordedAt` (when BellLabs learned). Edges: `REVISES_SOURCE` to the affected `Source`; `PRIOR_SNAPSHOT` and `RESULTING_SNAPSHOT` to snapshots (each 0..1); `ANNOUNCED_IN` to the notice's snapshot (0..1). The revision kinds follow the NLM publication types (Retraction Notice, Retracted Publication, Published Erratum, Corrected and Republished Article, Expression of Concern) plus the web-specific silent change, and map to FHIR Provenance `entity.role` `revision` and `removal`.
- Consequences by kind:

| Revision kind | Assertions from the prior snapshot | Adjudications | Recommendations that used them |
|---|---|---|---|
| `RETRACTION`, `WITHDRAWAL` | unchanged (they still record what the source said) | new adjudication supersedes with `SOURCE_REVISION`; old stays | flagged for re-review (CQ-RC-07); snapshots unchanged |
| `ERRATUM`, `CORRECTED_AND_REPUBLISHED` with changed content | new assertion from the resulting snapshot `SUPERSEDES` old with `SOURCE_CORRECTION`; old `recordedTo` set | new adjudication of the new assertion | flagged for re-review |
| `EXPRESSION_OF_CONCERN` | unchanged | new adjudication may lower evidence-strength assessment; old stays | flagged if the policy says so |
| `SILENT_CONTENT_CHANGE` | if the changed content contradicts an assertion, treat as `SOURCE_CORRECTION` only when the page states it corrects an error; otherwise it is a new observation that may bound validity (`VALIDITY_BOUNDED`) | as above | as above |

This answers OPEN-QUESTIONS P0-4: retracted, corrected, and superseded source snapshots are represented by immutable snapshots plus a `SourceRevisionEvent`, and historical adjudications keep pointing at the snapshots they examined; change happens only by new adjudications and superseding assertions.

### 7. The minimal pair: "source corrected in June" versus "fact ceased in June"

Shared starting state (both cases), recorded 2026-03-02 from a label snapshot observed 2026-03-02:

```text
A1: Assertion {predicate: HAS_FORMULATION_VERSION, recordedAt: 2026-03-02, recordedTo: null,
               validFrom: 2025-11-01, validFromPrecision: MONTH, validFromBasis: STATED_BY_SOURCE,
               validTo: null, validToBasis: UNKNOWN}
     HAS_SUBJECT -> variant V ; HAS_OBJECT -> FV1 (component: 200 mg)
e1:  (V)-[:HAS_FORMULATION_VERSION {validFrom: 2025-11-01, validTo: null, recordedFrom: 2026-03-02,
               recordedTo: null, assertionUid: A1}]->(FV1)
```

Delta A, "the source corrected the label in June" (the brand states the 200 mg figure was a printing error; the amount was always 120 mg):

```text
+ SourceSnapshot S2 {observedAt: 2026-06-15, retrievedAt: 2026-06-15}
+ SourceRevisionEvent {revisionKind: ERRATUM, occurredAt: 2026-06-14, recordedAt: 2026-06-15}
      REVISES_SOURCE -> label Source ; PRIOR_SNAPSHOT -> S1 ; RESULTING_SNAPSHOT -> S2
+ FV1c (component: 120 mg)                       // new immutable state
+ A2 {validFrom: 2025-11-01 MONTH STATED, validTo: null, recordedAt: 2026-06-15}  -> FV1c
+ (A2)-[:SUPERSEDES {supersessionKind: SOURCE_CORRECTION, recordedAt: 2026-06-15}]->(A1)
~ A1.recordedTo = 2026-06-15                       // the only write to A1
~ e1.recordedTo = 2026-06-15                       // the only write to e1
+ e2: (V)-[:HAS_FORMULATION_VERSION {validFrom: 2025-11-01, validTo: null, recordedFrom: 2026-06-15}]->(FV1c)
  unchanged: A1.validFrom, A1.validTo, e1.validFrom, e1.validTo
```

Delta B, "the formulation ceased in June" (the brand reformulated, effective 2026-06-10; BellLabs learns on 2026-06-20):

```text
+ SourceSnapshot S3 {observedAt: 2026-06-20}
+ A1b {same content as A1 except validTo: 2026-06-10, validToPrecision: DAY,
       validToBasis: STATED_BY_SOURCE, recordedAt: 2026-06-20}  -> FV1      // same state node
+ (A1b)-[:SUPERSEDES {supersessionKind: VALIDITY_BOUNDED, recordedAt: 2026-06-20}]->(A1)
~ A1.recordedTo = 2026-06-20 ; e1.recordedTo = 2026-06-20
+ e1b: (V)-[:HAS_FORMULATION_VERSION {validFrom: 2025-11-01, validTo: 2026-06-10, recordedFrom: 2026-06-20}]->(FV1)
+ FV2 (component: 150 mg) ; A3 {validFrom: 2026-06-10 DAY STATED, recordedAt: 2026-06-20} -> FV2
+ e3: (V)-[:HAS_FORMULATION_VERSION {validFrom: 2026-06-10, validTo: null, recordedFrom: 2026-06-20}]->(FV2)
  no SourceRevisionEvent: the source was not wrong
```

Discriminating answers (as-of query below, `V` = 2026-04-01):

| Recorded viewpoint `R` | Delta A answer | Delta B answer |
|---|---|---|
| 2026-05-01 | FV1 (200 mg) | FV1 (200 mg) |
| 2026-07-01 | FV1c (120 mg); FV1 has no current attachment | FV1 (200 mg) for [2025-11, 2026-06-10) |

and at `V` = 2026-07-01, `R` = 2026-07-01: Delta A returns FV1c, Delta B returns FV2.

### 8. Late-arriving historical facts

An archived 2019 label for the same variant is found on 2026-08-01:

```text
+ SourceSnapshot S0 {observedAt: 2019-05-10, retrievedAt: 2026-08-01, publishedAt: null}
+ A0 {validFrom: 2019-01-01 YEAR STATED_BY_SOURCE, validTo: 2025-11-01 MONTH INFERRED, recordedAt: 2026-08-01} -> FV0
+ e0 {validFrom: 2019-01-01, validTo: 2025-11-01, recordedFrom: 2026-08-01}
```

`recordedFrom` is 2026-08-01, never 2019. A replay at `R` = 2026-04-10 does not see FV0. The inferred `validTo` names the inference (`derivationRule: 'successor_state_start'`) and stays distinguishable from a stated end.

### 9. Precision and basis

- A non-null bound is stored as the first UTC instant of its precision period. `validTo` with precision `YEAR` = 2023-01-01 means "ended at some instant in [2023-01-01, 2024-01-01)".
- At `V`, an interval is `KNOWN` valid when `V >= validFrom + precisionLength(validFromPrecision)` and `V < validTo`; `POSSIBLE` when `V` falls inside an uncertainty period or a bound is null; `KNOWN_NOT_VALID` when `V >= validTo + precisionLength(validToPrecision)` or `V < validFrom`.
- `OBSERVATION_ONLY` forces the corresponding bound to be null. Witness instants (when the state was seen to hold) are derived from the supporting snapshots' `observedAt`; no property duplicates them.
- `PUBLICATION_PROXY` is allowed only as an explicit basis and is excluded by default from "known start" answers.
- `INFERRED` requires `derivationRule` or an `EvidenceAssessment` uid on the record.
- A page that no longer lists an offer is a new observation (a negative-polarity assertion at `observedAt`), not a `validTo`. A bound closes only by a stated end or an explicit inference.

### 10. Mutually exclusive states (CQ-TM-05)

- The catalog declares `temporalCardinality: EXCLUSIVE | NONEXCLUSIVE` for each attachment type and literal predicate, with `exclusivityPartition` keys. Initial `EXCLUSIVE` set: `HAS_FORMULATION_VERSION` (per `ProductVariant`, partition `jurisdiction`), `HAS_REGISTRATION_VERSION` (per `TrialRegistration`), `HAS_PROTOCOL_EDITION` (per `Protocol`), `HAS_CONTEXT_VERSION` and `HAS_ADOPTION_VERSION` in the private store (round 0008). Everything else defaults to `NONEXCLUSIVE` (for example `MARKETS_PRODUCT`, `HAS_PACKAGE_CONFIGURATION`, `LISTING_FOR`).
- Conflict: same subject, same type, same partition values, different target, overlapping valid intervals and overlapping recorded intervals.
- `DEFINITE` conflict: the overlap holds after each interval is shrunk by its precision uncertainty and every bound used is non-null. The ingestion service refuses the commit (service-enforced); V-508 reports any that slipped through.
- `POSSIBLE` conflict: the overlap depends on a null or imprecise bound. It goes to a review queue (V-509).
- Literal exclusive predicates (for example a registration's recruitment status): two currently recorded assertions with the same subject and predicate, different values, a definite valid overlap, and both projected `ACCEPTED` are a conflict (V-510). Disagreeing sources are preserved as separate assertions; at most one may be accepted for an overlapping interval, the others are `DISPUTED` or `REJECTED`.
- Neo4j 5 cannot express any of these as a constraint. The transactional analogue (`PRIMARY KEY (id, valid_at WITHOUT OVERLAPS)` from SQL:2011 / PostgreSQL) is available to the private store in round 0008, where the user-context version table can enforce it natively.

### 11. As-of query for CQ-TM-01

```cypher
// CQ-TM-01: what did BellLabs hold at recorded instant $R about $predicate for subject $subjectUid valid at $V?
// status: statically-checked
MATCH (a:Assertion {predicate: $predicate})-[:HAS_SUBJECT]->(s {uid: $subjectUid})
WHERE a.recordedAt <= $R
  AND (a.recordedTo IS NULL OR a.recordedTo > $R)
  AND (a.validFrom IS NULL OR a.validFrom <= $V)
  AND (a.validTo IS NULL OR a.validTo > $V)
OPTIONAL MATCH (adj:Adjudication)-[:EVALUATES]->(a)
WHERE adj.recordedAt <= $R
WITH a, adj
ORDER BY adj.recordedAt DESC
WITH a, collect(adj)[0] AS latestAdjudication
OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o)
RETURN a.uid AS assertionUid,
       o.uid AS objectUid,
       a.valueNumber AS valueNumber,
       a.unitCode AS unitCode,
       latestAdjudication.verdict AS verdictAsOfR,
       CASE WHEN a.validFrom IS NULL OR a.validTo IS NULL THEN 'POSSIBLE_OR_OPEN' ELSE 'BOUNDED' END AS boundState,
       a.validFrom AS validFrom, a.validFromPrecision AS validFromPrecision, a.validFromBasis AS validFromBasis,
       a.validTo AS validTo, a.validToPrecision AS validToPrecision, a.validToBasis AS validToBasis;
```

Attachment form (used for traversal; equivalent when projections are faithful):

```cypher
// status: statically-checked
MATCH (v {uid: $subjectUid})-[h:HAS_FORMULATION_VERSION]->(fv:FormulationVersion)
WHERE h.recordedFrom <= $R AND (h.recordedTo IS NULL OR h.recordedTo > $R)
  AND (h.validFrom IS NULL OR h.validFrom <= $V)
  AND (h.validTo IS NULL OR h.validTo > $V)
RETURN fv.uid AS formulationVersionUid, h.assertionUid AS authorizedBy, h.validFrom, h.validTo;
```

Both queries treat a null bound as "possibly valid" and report it rather than hiding it, which serves CQ-TM-04.

### 12. Live `TemporalSnapshot` types: `OrganizationSnapshot`, `ProductSnapshot`, `ListingSnapshot`

Decision: `seam` with refinements. The live types stay as a read projection of catalog `VersionedState` payload plus one `HAS_STATE` episode.

| Live element | Catalog counterpart | Projection rule |
|---|---|---|
| `*Snapshot` node payload fields | `VersionedState` payload (`payloadHash`) | payload fields never change after commit; `updatedAt` must equal `createdAt` except for the single `recordedTo` write (V-513) |
| node `validFrom`, `validTo`, `recordedFrom`, `recordedTo` | `HAS_STATE` episode properties | one live snapshot node per attachment episode; re-instatement creates a new node with the same `payloadHash` |
| `HAS_SNAPSHOT` (no properties) | `HAS_STATE` | kept as is; because the live projection has one snapshot node per episode, the episode properties live on the node; no second edge type is added |
| `SUPPORTED_BY_DOCUMENT` / `SUPPORTED_BY_CHUNK` with `ExtractionMetadata` | `Assertion` -> `SourceLocator` | shortcut only; each snapshot carries `assertionUids` for the assertions it projects |
| `ListingSnapshot.capturedAt` | `SourceSnapshot.observedAt` | same meaning; keep |
| `ProductSnapshot.launchYear`, `approvedYear`, `status`, `regulatoryAuthorizationId` | assertions (lane 3 owns regulatory meaning) | display projections; year values carry precision `YEAR`; not authoritative |
| `ProductSnapshot.formulationSummary` | `FormulationVersion` (INV-005) | display text only |

Why not keep time only on the node: node-level `recordedTo` forces a write on the payload node, re-instatement duplicates payload without a link, and a correction of one field (for example `employeeCountEstimate`) forces a new snapshot of every field with no record of which field was corrected. The seam keeps the live API working while new writes follow the episode rule.

### 13. `TemporalMetadata` and `RecommendationMetadata`

- `TemporalMetadata` (used by `HAS_CEO`, `HAS_LOCATION`, `LISTS_PRODUCT`, `LISTS_PROCEDURE`, `HOSTS_PROCESS`): `refine`. It is the live form of the asserted-edge profile. Add precision, basis, `assertionUid`, `relationshipUid`. Stop writing `confidence` (single scalar violates the confidence vector) and `notes` for new records.
- `OwnershipMetadata`, `RoleMetadata`: their time fields follow the same profile; `refine` (Lane 4 and Lane 1 own the role semantics).
- `RecommendationMetadata` on `Person-[:RECOMMENDS]->Recommendable`: `refine` and restrict. It records that a person (a source) recommends something. It is never a BellLabs recommendation. `strength` and `confidence` are uninterpretable without method and source; new writes require `assertionUid` and the temporal profile. Detailed in round 0008.

GraphQL delta snippets are in the lane fragment `live-schema-decisions.md`.

## Challenger objections

| ID | Lens | Counterexample or failure | Severity | Proposed discriminating test | Resolution |
|---|---|---|---|---|---|
| O-01 | Temporal | Overwriting `validTo` when a formulation is replaced makes the 2026-05-01 replay claim knowledge of a 2026-06-10 end | high | fixture replay at `R` before and after the learning date | new episode; one-time `recordedTo` write only |
| O-02 | Ontological | correction and fact-end look the same | high | minimal pair deltas A and B; as-of answers table | different current attachments plus `supersessionKind` |
| O-03 | Epistemic | retraction marks source assertions `REJECTED`, erasing what the paper said | high | PMID 9500320: assertion "article reported X" must survive | new adjudication, assertion unchanged |
| O-04 | Epistemic | mutable `status` breaks replay | high | fixture Q-1 replay returns the belief held at decision time | KCR-0007-1 and -2 |
| O-05 | Operational | one adjudication per automated acceptance is costly | medium | count of adjudications per 10k assertions in a pilot | accepted cost; alternative "status episode" node rejected as a third vocabulary |
| O-06 | Linguistic | "as of March" read as a start date | medium | minimal pair 5 | `OBSERVATION_ONLY` forces null bound |
| O-07 | Temporal | "launched 2019" stored as 2019-01-01 answers February 2019 as known | medium | `KNOWN` vs `POSSIBLE` evaluation | precision per bound |
| O-08 | Operational | unknown bounds flood exclusivity checks | medium | split V-508 / V-509 | definite rejects, possible queues |
| O-09 | Provenance | archive capture time confused with fetch time, producing a backdated belief | high | `observedAt` 2019 vs `retrievedAt` 2026 in fixture | separate fields; V-504 |
| O-10 | Operational | parallel episode edges duplicate rows in naive traversals | medium | any query without a temporal viewpoint | projection contract already requires `temporalView`; API default is `recordedTo IS NULL` |
| O-11 | Ontological | live `*Snapshot` nodes are mutable (`updatedAt` on UPDATE) | medium | V-513 | seam rule: payload frozen after commit |

## Linguistic analysis

- Source wording: "Retraction in: ..." (PubMed linking phrase), "Formula updated November 2025", "Available as of March", "Launched in March", "discontinued in 2023".
- Normalized proposition: revision event; stated start with MONTH precision; observation witness; stated start; stated end with YEAR precision.
- Negation: "no longer available" is a new observation, not a validity end.
- Modality/hedging: "expected to launch in Q3" is a planned time, not a valid time; it is stored only as a separate forward-looking assertion with its own predicate.
- Quantification: "since 2019" gives a start bound only.
- Scope ambiguity: "updated" may refer to the page or to the formula; resolve to page revision (`SILENT_CONTENT_CHANGE`) unless the text names the formula.
- Presuppositions not licensed as facts: a retraction does not establish that the reported observation did not occur; a page change does not establish that the earlier page was wrong.

## Confidence vector

| Dimension | Value/status | Method version | Evidence | Calibration set |
|---|---|---|---|---|
| Extraction | temporal-expression extraction of bounds, precision, basis | not yet defined | case packet expressions | needed: 200 labeled temporal expressions across labels, registries, press releases |
| Resolution | n/a for time; revision events resolve notice to target by PMID link | PubMed link fields | PMID 20137807 to 9500320 | NLM linked citations |
| Source reliability | per source kind; unchanged by this round | n/a | n/a | n/a |
| Evidence strength | unchanged | n/a | n/a | n/a |
| Applicability | unchanged | n/a | n/a | n/a |
| Adjudication | now time-stamped and immutable | KCR-0007-2 | fixture | n/a |
| Decision | replay uses recorded viewpoint | round 0008 | fixture | n/a |

## Schema projection

- Projection request ID: not generated (no projection tool run in this lane).
- Selected modules: `kernel`, `provenance`, `temporal`.
- Closure additions: enums `TimePrecision`, `ValidTimeBasis`, `SupersessionKind`, `SourceRevisionKind`; relationship profile `bitemporal_attachment`.
- Explicit exclusions: private context (round 0008), protocol schedules.
- Budget result / projection digest: not computed.

## Qualification evidence

| Gate | Artifact | Expected | Actual | Pass |
|---|---|---|---|---|
| Positive fixture | `examples/recommendation-snapshot.cypher` shared section | validation queries return zero rows | not executed (no Neo4j in this environment) | statically checked only |
| Negative fixture | V-505 / V-5xx in fixture | rows appear if a correction edits valid time | not executed | statically checked only |
| Minimal pair | Product A correction vs Product B reformulation in fixture | different as-of answers at `R` = 2026-07-01 | not executed | statically checked only |
| Temporal correction | A2 supersedes A1 | replay at 2026-04-10 returns FV1 | not executed | statically checked only |
| Identity collision | n/a | n/a | n/a | n/a |
| Extraction evaluation | temporal expressions | not available | not run | no |
| Retrieval evaluation | CQ-TM-01 query | defined | not run | no |
| Migration compatibility | live `*Snapshot` seam | additive delta only | reviewed | yes (static) |

## Decision

- Outcome (recommended): ACCEPT the temporal rules; KCR-0007-1, -2, -3 OPEN for coordinator ruling.
- Accepted semantic rule: valid time is immutable on every record; change in belief is a new recorded-time episode; a correction supersedes with `SOURCE_CORRECTION` and leaves the corrected state without a current attachment; a fact ending supersedes with `VALIDITY_BOUNDED` and keeps the old state attached for its bounded interval; recorded time is service-assigned and never backdated; historical adjudications and snapshots are immutable.
- Rejected alternatives: in-place `validTo` update; status overwrite without history; sentinel maximum dates (used in one community Neo4j pattern); node-level recorded time as the only form (live `*Snapshot`); a separate "status episode" node type; storing witness observation times on the edge.
- Residual uncertainty: cost of adjudication-per-transition at scale; whether Neo4j property-type constraints are available in the deployed edition; extraction accuracy for precision and basis.
- Required catalog/schema changes: see `../catalog/schema.yaml` (0.2.0; merged from the lane's catalog-patch fragment) (temporal module, KCRs, enums, `SUPERSEDES`, `SourceRevisionEvent`, per-bound precision and basis).
- Required ingestion changes: service-assigned `recordedFrom` / `recordedAt`; commit-time exclusivity check; `contentHash` and `payloadHash` at commit; revision-event detection for PubMed publication-type changes (`Retracted Publication`, `Retraction Notice`, `Published Erratum`, `Corrected and Republished Article`, `Expression of Concern`).
- Required retrieval/API/MCP changes: every query binds a temporal viewpoint; answers report `KNOWN` / `POSSIBLE` and basis.
- Changelog and migration references: 0.2.0. Migration: existing assertions get `recordedTo = null`, `contentHash` computed, and one synthetic `Adjudication {reviewerType: 'MIGRATION', recordedAt: migration time}` per non-`EXTRACTED` status so the projection reproduces current status; history before migration is declared unknown.
