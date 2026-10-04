# W23 08 Completion report

- Worker: **W23 Access, answers, policy and private-store boundary**; model **Opus 5.5** (`claude-opus-5-5`); coordinator and synthesizer Fable 5.1.
- Run: `run-2026-10-04-fable51-01`. Started ≈ 2026-10-04T00:42Z (after the worker brief was written); ended 2026-10-04T01:41Z.
- Admitted against: catalog `8fb50ff06f80621d460813118f739d7c4d3902a0ea631c16952e11d3815f84f0`, live schema `86b5e0b5…f112`, shared contract and registry as frozen at Wave 0. Writes only inside `workers/W23/`.

## 1. Deliverables

All eight fixed-name deliverables plus `private-store-interface.md` are present: `01-domain-recommendation.md`, `02-cq-coverage.md`, `03-source-manifest.md`, `04-model-cards.md`, `sdl-fragment.graphql`, `migration-map.yaml` (57 entries, YAML-valid), `05-decision-seam-ledger.md` + `seam-requests.yaml` (16 requests, YAML-valid), `06-fixtures-and-queries.md` + `fixtures/*.cypher`, `07-operations.md` + `operations.cypher` + `operations-enterprise.cypher`, this report.

Fragment content: enums `AccessTier`, `TraceDepth`, `PrivateContextMode`, candidate `PolicyKind`; node types `AnswerRecord` (Occurrence), `PolicyVersion` (VersionedState), `DecisionCriterion` (Entity), all INTERNAL and insert-only; edges `CITES_ASSERTION`, `CITES_ASSESSMENT`, candidate `DECLARES_CRITERION`, endpoint fields on W00's `WAS_GENERATED_BY`/`AUTHORIZED_BY`. No private-personal type, field, enum value or uid prefix (grep for `PRIVATE_PERSONAL` / `hu:private-` in the fragment: 0).

## 2. Tools actually used and availability

| Tool | Used for | Availability |
|---|---|---|
| Firecrawl `firecrawl_scrape` (maxAge 0) | Neo4j 5.x operations manual (3 pages), PostgreSQL 18/17 docs, release notes, versioning, RLS (5 pages) | worked (HTTP 200 on all 8) |
| Embedded Neo4j 5.26.31 Community (run harness, copied to scratchpad; JVM `-Xmx1g`) | all fixtures, validators, operations, constraint violation tests | worked; first instance killed (exit 137, memory) during a run and was restarted with a bounded heap; all results reported come from the second instance |
| `@neo4j/graphql` 7.6.3, `graphql` 16.14.2, `neo4j-driver` 6.2.0 (npm, scratchpad) | build, round trip, label-overlap probe, public sub-schema | worked |
| Fable's `merge-fragments.mjs`, `run-cypher.mjs`, `query.mjs`, `validation-params.json` | merge check, statement runner, parameters | worked |
| pglast 8.4 (PostgreSQL 18.4 grammar), pglast 7.20 (17.7 grammar), PyPI | parser-only check of the PCS DDL sketch | worked |
| PostgreSQL 16 binaries (`/usr/lib/postgresql/16`) | intended live test of EXCLUDE | **not usable**: PostgreSQL refuses root, and the sandbox denied the `nobody` user access to the scratchpad even with traverse bits (bits reverted). No PostgreSQL server test was run |
| PubMed, ClinicalTrials.gov, Tavily, bioRxiv, ICD-10, NPI | not needed for this package | not used |
| W3C ODRL | — | **not reviewed** (by instruction and by fact) |

## 3. Key findings (each executed)

1. **Detection gaps in the 0.2.0 suite** (fixtures 10–13): an index over a private label/property created before any private node exists is invisible to V-115/V-116 (V-W23-04 sees it); V-521 misses an upper-case `PRIVATE_PERSONAL` class with no private uid and private uids inside list-valued relationship properties (V-W23-09, V-W23-10); a private value copied into a public Observation without any private marker is seen by no existing query (V-W23-05); V-121 misses an OWNER_PRIVATE answer and keys it does not name (V-W23-01a/b); V-429 accepts authorization by the wrong kind of policy or after expiry (V-W23-07).
2. **Casing**: `@neo4j/graphql` stores enum names (`INTERNAL`), while V-313, V-521 and the QS-5b/QS-6 guards compare with catalog lower-case spellings (D-W23-06, W23-SR-08).
3. **Interface/union targets duplicate nodes** whose label sets nest (ClaimOccurrence returned twice); `CITES_ASSERTION` therefore targets the concrete `Assertion` type (W00 reached the same rule independently).
4. **Contract B3 archetype interfaces lack `uid`**, so interface-typed relationships cannot be connected or filtered by uid through the API (W23-SR-03).
5. **APOC is required** for DateTime reads through the 7.6.3 generated API (`apoc.date.convertFormat`).
6. **Pins for the rejected alternative**: Neo4j PBAC Enterprise/AuraDB BC/VDC, introduced 5.24, DENY fails open; PostgreSQL `WITHOUT OVERLAPS` from 18 (2025-09-25; 18.6 current), absent in 17; `EXCLUDE` equivalent everywhere.
7. **Cross-worker collision observed** (not W23's): W07 and W12 both define `enum ResultQualifier` with different values (reported in W23-SR-14).
8. **V-432** matches `COMPARES` instead of the catalog's `COMPARES_IDENTITIES` (W23-SR-07).

## 4. Research gaps and what remains qualified

- No live PostgreSQL test (parser-only); Enterprise RBAC behaviour not executed (documentation only).
- Policy payload vocabulary is a BellLabs candidate; ODRL alignment unreviewed; legal regimes, retention periods, minimum-cell thresholds, break-glass and ad hoc answer logs remain user decisions (OPEN-QUESTIONS P2 private items 1, 3, 6, 7).
- Redirect record shape and contribution record shape depend on W00/W21 (W23-SR-06, W23-SR-13).
- Fixtures are synthetic; no real policy corpus exists to calibrate `criterionKind` or `PolicyKind`.

## 5. Unresolved seams (open at hand-off)

W23-SR-01 (tokens), -02 (WAS_GENERATED_BY domain), -03 (uid on archetype interfaces, kernel change), -04/-05 (register candidates), -06/-07 (redirect, V-432), -08 (casing and validators), -09 (adopt V-W23), -10 (kernel field classes), -11 (W16 V-533p), -12 (W01 confirmations), -13 (contribution record), -14 (W07 V-313; ResultQualifier collision), -15 (UseKind for media), -16 (runtime findings for Fable).

## 6. Confidence per dimension

| Dimension | Confidence | Basis |
|---|---|---|
| Placement and boundary rules | high | round 0008 plus 5.x-pinned primary docs; executed leak probes |
| AnswerRecord shape and replay | high | executed replay, reverse lookup, negatives |
| Projection closure table | medium | executed data-level closure; field classes on W00 types are proposals pending W23-SR-10 |
| Policy layer (PolicyVersion, DecisionCriterion) | medium | executed constraints and validators; kinds and criteria vocabulary are candidates without a policy corpus |
| Use/rights semantics | medium-low | separation is clear and executed; vocabulary unreviewed against ODRL; legal input absent |
| Private-store interface | medium | contract complete; DDL parser-checked only |
| PostgreSQL / Neo4j capability statements | high | official docs retrieved live; grammar check matches the docs |

## 7. Review status

Self-reviewed in challenger role (05, objections table). Cross-read for consistency with in-progress W00, W01, W07, W16, W21, W22 fragments (no edits to them): W00 confirms AccessTier/TraceDepth are W23's and keeps W23 types out of `AssertionSubjectTarget`; W01 retires HAS_PARTICIPANT_TOKEN and scopes participant tokens; W16 restricts RECORDS/POSTS_RESULT to public persons and references PolicyVersion by uid; W21 retires ExperienceReport/REPORTS; W22 states that a rights record is never permission. Not yet reviewed by another worker or by Fable.

## 8. Artifact digests (SHA-256, at 2026-10-04T01:40Z; this report excluded)

```
0c72aa52c9401b71209ae5c3e610222de5f08ffde6c9d356bac8d8a4a6306f38  01-domain-recommendation.md
876e63ebedcc91650a5fe97c700b65b8d5d3cbb137d932385af3e38af8424c3c  02-cq-coverage.md
ed4885f698716d7dbbcb18f7c6ac6fc8001aa867924ec155d2384d83d11d5562  03-source-manifest.md
076c96491f6d0971d0da2fcb4a7f384a969aedfe7803090c1f28930a61405c8c  04-model-cards.md
13b439442ffd7c0a6012a2312d16307350b6d1a75118c4f879d5290cd2e25684  05-decision-seam-ledger.md
71607e4cb5abc96c52b91e86188d995ef0559ec599139d3b9cf8eab7a3c025ff  06-fixtures-and-queries.md
6e9833a77d89d29dedc4d7ca26e1323c4c363dfd94522bd73494bf03f0bc8fb7  07-operations.md
33f5c03403779f4605419469d5eb35b834b4d40918eeaa5e5c19d0bad1fdeddb  sdl-fragment.graphql
99bf71c6da5fb0212c5fe8da16248b15fe29614174911ef004ddf47376c7d820  migration-map.yaml
415c2728212f2a1086da27e81d83c3ebb662bc00df951dd5792a8d38b5c387ff  seam-requests.yaml
ce39f8b9456dfa38d600976fd92f9b3d21722636465aa125fe78572e7612b760  private-store-interface.md
02e6937807d0cca74b033df37a344469fa2d7ab97d5c2bcd86eabe9bccda8135  operations.cypher
98db82d32091adaca2fd7c5272c48d7c6dc9e2d05dc678490bb9b368746d7fdc  operations-enterprise.cypher
7721e00e254ace344fb3b2deab6a6ea70692c333f397cc6b11ce85bedd0a8af4  fixtures/00-shared-base.cypher
ab1d3d3c56d5b0876167fc47e4ed9a2368fe1a7828f349e2a344a7fe28c0be00  fixtures/01-answer-record-replay.cypher
f2ff9e58c88f79dea796611a6d612036cb5687e4010ad743c4c027ae21529eb7  fixtures/02-public-projection.cypher
71d5d771886b7b2384a1b1f6c9d97dee903157cd24cbc982c41cd2568fd9ed44  fixtures/03-decision-replay-after-correction.cypher
d9210b73bb1997c04f0d1096cbbe9105bdb3763384076c9f3cd092e0f85c2623  fixtures/04-uid-redirect.cypher
365f0bf0566cabd897321de5de10314a1e45110653ba1724ee0aae3d1964f595  fixtures/10-leak-probe-qs6.cypher
bd58f4bc6a1c27e960f33b983c3b3e9d35b32788e0ed5b09106e870210fdee1e  fixtures/10-leak-probe-queries.cypher
77459a0876aaddfd8964461f7317fe8a36dfde537ea9df8fd78b8c37ba99c6a7  fixtures/11-public-person-only.cypher
24e1db4525e684254b4b2d1ec36015c01fa3c17a5ba97daa0d0c6dac4db119cc  fixtures/12-answer-record-negative.cypher
40b55aa6cedb536df7bb44ee01225b96f2a4bbb4172338f9c5e85654501c8a23  fixtures/13-use-authorization-negative.cypher
2c36ffa1c0b6b833ebee31f932e4435b87abc7057712c14adcc983ff96a1adfb  fixtures/13-fail-open-queries.cypher
b96d858901041b12c8abbaffede255cbaecd76182c5a329b3bf5484ef1ceafbc  fixtures/validation-w23.cypher
fa661c6154436915e39921c14e139a9a8e0f16afd69574bec125dc015b19e108  fixtures/replay-params.json
c09bfbfaf1c88f0210db07bea89b2412eb51ba2c39eb52d020304a3b220e122e  fixtures/params-leak.json
190bffcc0d89afd924b16ccf863afa34e6e2f7e37c45a713c40bb50b561572d5  fixtures/reset.cypher
250154fbb7e908316f694d3e6ffe0bd6bb89be0d0aef9ce452e8b50c6647398e  checks/run-all.sh
934e0ccbc298b0dfc446684fc93f5bab365eca06013c81931ec53ab0b0c7dcc6  checks/build-stub.graphql
8e74abb90fcb1e39b0edbc0424a9a7d8e06592e824089ef49a75d9076e74f531  checks/build-stub-variant-b-uid-on-archetype.graphql
3731fb98fdb58ba7de74b5fd92cdc916a294b286be129c76244b32f86aef7034  checks/build-and-roundtrip.mjs
5617d4ea9c528a866742313f08531b7af411819af57f5867c3d417efdc9af767  checks/roundtrip-variant-a-contract-B3.json
55826e9eec72f0ba154db6b2f1dccf4e0e0f56329ea96aaf30ff5b2e9e0679bd  checks/roundtrip-variant-b-uid-on-archetype.json
a0a36858a5043cdac18ad8948a5b75bf6b2e18e25fa9f4b2a9bd0ecae78a3101  checks/label-overlap-probe.graphql
dd24ddfc5b0ac6c57c59e77ccf815cde5e3710fe78c76c4ab08568fdd7ecd691  checks/label-overlap-probe.mjs
2c892f5e826a9c028371eece9168978c3484849537053817bb46fc33105e4d69  checks/label-overlap-probe-result.json
0838aacc22e0346ec55f94b347580031ca5022fa51f48717439eb2ab1512331a  checks/public-subset.mjs
3602d3ac64ea28a2a806bcede0fb3940603c16cab2761444e239173bde79c622  checks/public-subset-result.json
d3c4fd39734376972fa7b13168a165c185aa05af8f50cf613d90473b6ddc5812  checks/constraint-violation-tests.cypher
b21410121bf4efd997944ce34cc7c44902a569b06b3e7300b9799433ea495436  checks/constraint-violation-tests-result.json
b15aa34337046b96138ac22bce9bdbd9b2ccf718ec2988a9328271096e13c9a0  checks/operations-community-result.json
a0c680fbc8f7c8a4e387cfe7f6e6d44da98921a669167f7a051e016353226b09  checks/operations-enterprise-on-community-result.json
b37fc131a14aacbc2d365d004b934318e1eecab5ce12c550461db7be9f80ce82  checks/pcs-ddl-sketch.sql
0ea4eb0070b36aa69a1717dec1af1b0c67c328e74cdad8e61fc01f407ba368cd  checks/pcs-ddl-parse-result.txt
```

The 29 result JSON files under `fixtures/results/` are regenerated by `checks/run-all.sh`; their digests were taken at the same time (command: `find . -type f | sort | xargs sha256sum`) and are not repeated here.
