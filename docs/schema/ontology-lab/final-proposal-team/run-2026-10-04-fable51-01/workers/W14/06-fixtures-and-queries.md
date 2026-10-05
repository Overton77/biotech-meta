# W14 fixtures and queries

All files are in `fixtures/`. **Execution status: RUN.** Every file was executed on an embedded **Neo4j 5.26.31 Community** instance (`CALL dbms.components()` → `Neo4jKernel 5.26.31 community`). The instance used the run harness (`validation/harness/EmbeddedNeo4j.java`, `run-cypher.mjs`) from a private scratch directory, with a fresh in-process database. The execution log is `fixtures/w14-run-log.txt`. Load order: core → minimal pairs → (checks) → negative → (checks). Each statement binds its own nodes by uid and no variable crosses `;`. Nodes carry primary + archetype labels (`LegalEntity` nodes also carry `Organization`, and `BrandedIngredientMaterial` also carries `IngredientMaterial`). uid tokens are the **proposed** W14 tokens (W14-SR-01). `fixtures/w14-fixture-generator.py` regenerates the three data files byte-for-byte (`python3 w14-fixture-generator.py <dir>`).

| File | Statements | Content | Result |
|---|---|---|---|
| `w14-ip-core.cypher` | 375 | Real records: displayed family of US 8,197,807 B2 (US 11/912,400 + EP 05722944 + grant US 8,197,807 B2 + claims 1–3); US 8,383,086 and US appl. 13/260,392 (named by licenses); statuses (aggregator in force to 2026-11-19, calculated EXPIRED, claims 1–3 held invalid 2023-02-13, EP withdrawn, NIAGEN registered 2014-09-16 and renewed 2025-07-24); identifiers (USPTO, EPO, WIPO, plus a JPO collision guard); 2014 and 2012 Dartmouth→ChromaDex, Inc. licenses; NIAGEN US and IR trademarks; mark owner, mark use, supplier, subsidiary; PATENT_CLAIMS assertions | 375 ok |
| `w14-ip-minimal-pairs.cypher` | 152 | Synthetic MP-1…MP-6 (below) | 152 ok |
| `w14-ip-negative.cypher` | 34 | N-1…N-7 forbidden-implication and integrity violations | 34 ok (writes succeed; validators must flag) |
| `w14-validation.cypher` | 14 | V-W14-01…14 | see table below |
| `w14-cq-queries.cypher` | 12 | Q-01…Q-12 | see table below |

## Mandatory cases → fixture

| Brief requirement | Where | Expected / observed |
|---|---|---|
| Family with two applications in two jurisdictions and one grant | core: `hu:patent-family:gp-us8197807-worldwide` → `us-11912400` (US), `ep-05722944` (EP); `APPLICATION_GRANTED_AS` → `us-8197807`; synthetic `syn-fam-a` (US, EP, one grant) | Q-09: 4 rows (2 per family; one grant each) ✔ |
| License covering a family with field-of-use and territory bounds (episode) | MP-1/MP-6: `syn-univ-licensee-a-2020` `LICENSE_COVERS` → `syn-fam-a`, field "dietary supplements", territory ["US"], episode [2020-01-01, 2025-01-01). Real named-member license 2014 ("human and animal therapeutics", WORLDWIDE, from 2014-05-16) | Q-04 at 2023-06-01: license + sublicense; at 2026-10-04: sublicense only ✔. Q-03: 2014 license ✔ |
| License must not imply OWNS_STUDY or efficacy | N-1 (derived OWNS_STUDY), N-2 (PROVES_EFFICACY from a claim limitation) | V-W14-01 = 1, V-W14-02 = 1; kernel V-112 also flags N-1 ✔; Q-06 → 0 asserted study roles, 0 accepted efficacy assertions ✔ |
| Trademark owned by one entity and used on a material marketed by another | core: OWNS_TRADEMARK ChromaDex, Inc. → NIAGEN US (asserter USPTO); MARKETED_UNDER_MARK Niagen → NIAGEN (asserter Niagen Bioscience, Inc.); SUPPLIES_INGREDIENT_MATERIAL Niagen Bioscience, Inc. → Niagen | Q-07 row ✔; N-7 → V-W14-12 = 1 ✔ |
| Expired/lapsed status as a bounded state | core: in force [2012-06-12, 2026-11-19) then calculated EXPIRED; EP WITHDRAWN (start unknown, OBSERVATION_ONLY); MP-4 trademark REGISTERED [2015-01-06, 2021-07-06) via VALIDITY_BOUNDED supersession, then CANCELLED | Q-02 (2026-12-01: terminated) ✔; Q-08 ✔ |
| Temporal correction / late arrival | MP-5 EXTRACTION_FIX (v0 naive 20-year expiry recorded 01:20, closed 01:30; v1 stated adjusted expiry); core: renewal 2025-07-24 first recorded 2026-10-04 (TM-R6), with snapshot observedAt from the TSDR generation stamp | Q-11 ✔ |
| Identity collision | Same digits `8197807` under USPTO and JPO; NIAGEN US vs NIAGEN Madrid IR; N-5 attaches the IR number to the US right | Q-12 ✔; V-W14-08 = 1 ✔ |
| Missing facts | 2012 license: field, territory and exclusivity null with null reportedStatus (unknown); MP-3 territory NOT_REPORTED; GrantedPatent `assigneeNamesVerbatim` null (face page not captured); US 8,383,086 with no application | V-W14-13 = 1 (the 2012 license only); V-W14-11 = 2 (informational) ✔ |
| Access leakage | Not applicable: all W14 content is PUBLIC; no private record or INTERNAL node is written | — |

### Minimal pairs (synthetic)

| Pair | A | B | Distinguishing query and outcome |
|---|---|---|---|
| MP-1 | License states family-level coverage (`LICENSE_COVERS` → PatentFamily) | Real 2014 license names members only | Q-03/Q-04 include family-level coverage only for A. N-3 (coverage written from family membership) → V-W14-05 |
| MP-2 | Licensor = assignee (University → Licensee A) | Sublicense: licensor Licensee A ≠ assignee University | Q-05 `sameParty` false for B |
| MP-3 | Territory redacted → NOT_REPORTED | 2012 license: not captured → null/null | V-W14-13 flags only the 2012 license |
| MP-4 | Mark open-ended REGISTERED (recorded 01:20, SUPERSEDED) | Same start, closed end 2021-07-06 (recorded 01:30) + CANCELLED | Q-08: REGISTERED (2020), CANCELLED (2021-07-06, 2026) |
| MP-5 | v0 expiry 2035-03-02 (INFERRED, wrong rule) | v1 expiry 2035-09-30 (stated) | Q-11: as recorded 01:25 → not in force on 2035-06-01; as recorded 01:35 → in force |
| MP-6 | Family license episode ended 2025-01-01 | Sublicense end unknown | Q-04: at 2026-10-04 only the sublicense, `validToBasis` UNKNOWN |

## Validators (expected = observed)

| Check | Meaning | After core + MP | After + negative |
|---|---|---|---|
| V-W14-01 | `[LICENSES_PATENT, OWNS_STUDY]`: no study role derived from IP assertions | 0 | **1** (N-1 `OWNS_STUDY` chromadex-inc → nct02712593) |
| V-W14-02 | `[PATENT_CLAIMS, PROVES_EFFICACY]` | 0 | **1** (N-2) |
| V-W14-03 | Asserted W14 edge ↔ its Assertion (predicate, subject, object, recordedFrom) | 0 | **1** (N-3 cites a LICENSES_PATENT assertion) |
| V-W14-04 | Endpoint types | 0 | 0 |
| V-W14-05 | Coverage only from a LICENSE_COVERS assertion naming that target | 0 | **1** (N-3 → EP 05722944) |
| V-W14-06 | Claim has exactly one parent | 0 | 0 |
| V-W14-07 | Claim-level vs patent-level status; no claim status derived from a patent-level one | 0 | **1** (N-4) |
| V-W14-08 | Office identifier jurisdiction = right jurisdiction | 0 | **1** (N-5 IR 1336169 on the US right) |
| V-W14-09 | No `status` property on IP nodes | 0 | **1** (N-6) |
| V-W14-10 | officeKey format and uniqueness | 0 | 0 |
| V-W14-11 (info) | Grant without exactly one application link | 2 (US 8,383,086; syn-us-b) | 2 |
| V-W14-12 | No commercial role from mark ownership | 0 | **1** (N-7) |
| V-W14-13 (info) | License terms unknown | 1 (2012 license) | 1 |
| V-W14-14 | Definite in-force/terminal overlap in current recorded time | 0 | 0 |

**Kernel suite** (`docs/schema/neo4j/validation.cypher`, 174 statements, params `validation/validation-params.json`): on core + MP, all violation queries return 0 rows. Only the informational V-401b (13 ACCEPTED synthetic assertions resting on a WHOLE_SNAPSHOT locator, expected for synthetic data) and V-514b (0 assertions without contentHash) report. After the negative fixture, **V-112** additionally reports the N-1 `OWNS_STUDY` edge (`FORBIDDEN_IMPLICATION_AMONG_DERIVATION_INPUTS`). An earlier draft was caught by kernel V-507 (state→state SUPERSEDES) and V-503 (INFERRED bound without derivationRule) and was corrected (decision W14-D02).

## CQ queries (expected = observed; all RUN)

| Query | CQ | Expected rows |
|---|---|---|
| Q-01 | CQ-IP-C01, US, D 2026-10-04 | 4 rows: claim 1 (curator, claim level; and Niagen Bioscience press release, patent level), claims 2 and 3 (press release, patent level). All have `patentInForce=true`, `patentTerminated=false`, `claimHeldInvalid=true`, **`enforceableAsOfD=false`** |
| Q-02 | CQ-IP-C01 at 2022-06-01 / 2026-12-01 | 2022: inForce true, terminated false, claimInvalid false (enforceable on the captured data; the D. Del. date is uncaptured, W14-D14). 2026-12: inForce false, terminated true, claimInvalid true |
| Q-03 | CQ-IP-C02 for US 8,197,807 | 1 row: 2014 license, licensee ChromaDex, Inc., licensor Trustees of Dartmouth College, exclusive true, "human and animal therapeutics" (REPORTED), "worldwide" / [WORLDWIDE], validFrom 2014-05-16, validTo null, validToBasis UNKNOWN, coveredVia GrantedPatent |
| Q-04 | CQ-IP-C02 synthetic family | 3 rows: 2023-06-01 → sublicense (B from A, territory NOT_REPORTED, end UNKNOWN) and family license (A from University, [US], end 2025-01-01); 2026-10-04 → sublicense only |
| Q-05 | licensor ≠ assignee | 4 rows; `sameParty` false only for the sublicense (naive "Synthetic University" vs asserted "Synthetic Licensee A"). The 2014 license appears twice because it covers two assigned grants |
| Q-06 | CQ-IP-C03 | 1 row: licensesHeld 2, assertedStudyRoles 0, acceptedEfficacyAssertions 0 (unchanged after the negative fixture, because derived or PROPOSED records are not asserted or accepted facts) |
| Q-07 | CQ-IP-C04 / CQ-MF-01 | 1 row: NIAGEN, US, 4606519, owners [ChromaDex, Inc.], statusesAtD [RENEWED, REGISTERED], suppliers [Niagen Bioscience, Inc.], markUseAsserter Niagen Bioscience, Inc. |
| Q-08 | CQ-IP-C04 lapsed | 2020-01-01 [REGISTERED]; 2021-07-06 [CANCELLED]; 2026-10-04 [CANCELLED] |
| Q-09 | CQ-IP-C05 | 4 rows: gp family EP 05722944 (no grant, [WITHDRAWN]), US 11/912,400 → 8,197,807; syn family EP (no grant), US → SYN-9,000,001 |
| Q-10 | CQ-EC-01 | 3 rows: LICENSES_PATENT 2012 license (covers US:13260392), LICENSES_PATENT 2014 license (covers US:8383086, US:8197807), OWNS_TRADEMARK NIAGEN US (validFrom null, OBSERVATION_ONLY) |
| Q-11 | correction | as recorded 01:25 → v0, validTo 2035-03-02, INFERRED, false; as recorded 01:35 → v1, 2035-09-30, STATED_BY_SOURCE, true |
| Q-12 | CQ-EC-02 identity | USPTO 8197807 → grant; JPO 8197807 → []; WIPO 1336169 → IR trademark; NIAGEN US:85932490 and WO:1336169 as two Trademark rows |

Essential-now CQs covered with at least one query: CQ-MF-01 (Q-07). The Foundational CQs CQ-EC-01 (Q-10) and CQ-EC-02 (Q-12) and the candidates C01–C05 each have at least one query.
