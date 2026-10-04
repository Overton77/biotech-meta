# 01 Domain and competency-question coverage report

Run `run-2026-10-04-fable51-01`; 24 packets (W00–W23). Coverage is computed mechanically from each packet's `02-cq-coverage.md` and `06-fixtures-and-queries.md` (`validation/inventories/cq-coverage-by-worker.json`); "with fixture or query" means the id appears in the fixtures/queries document, i.e. the packet wrote an executable case for it. Priority classes are the catalog's (`competency-questions.md` section 1).

## 1. Coverage of the 126 recorded competency questions

| Priority | Questions | Covered by at least one packet | With a fixture or query |
|---|---|---|---|
| Essential now | 50 | 50 | 48 |
| Foundational | 55 | 54 | 45 |
| Expansion | 17 | 15 | 10 |
| Research frontier | 3 | 3 | 2 |
| unclassified | 1 | 1 | 1 |
| **All** | 126 | 123 | 106 |

Not covered by any packet: CQ-AX-10, CQ-AX-26, CQ-AX-27. All three are operator-audit Expansion questions (adjudications needing re-review after a newer snapshot; agent-run and reviewer provenance). They are answerable from kernel elements already present (SourceRevisionEvent + Adjudication.reviewedAt + SUPERSEDES; Activity/Agent) and get their queries in the final validation suite (Q-AX-10, Q-AX-26, Q-AX-27) at Wave 6 rather than a new element. The handoff counted 127 questions; the parser found 126 ids in the tables (CQ-ID-06 carries no priority cell in its table and is listed as unclassified).

## 2. Candidate competency questions proposed by the packets

82 candidate questions (`CQ-<AREA>-Cnn`), each labelled candidate in its packet and never presented as an existing id. Families: AX, CL, CM, DX, EC, EN, EV, FL, ID, IP, IV, MD, MF, MX, PF, PR, PV, QA, SF, ST. They justify the candidate elements admitted in `03-decision-report.md` section C; a candidate without a fixture stays out of the SDL.

## 3. Packages, canonical modules and dispositions

| Package | Natural domain (handoff section 2) | Canonical module(s) | Headline disposition |
|---|---|---|---|
| W00 | kernel, identity, time, Evidence Provenance | kernel, provenance, temporal, identity_resolution | kernel preserved; 10 interfaces, 8 edge-property profiles, 37 enums; reconciliation pass rules 130+ seam requests |
| W01 | actors and institutions | organizations | PhysicalLocation merged into Facility; roles as asserted edges; brand never a role target |
| W02 | substances and materials | substances_and_materials | salt = own ChemicalSubstance + HAS_ACTIVE_MOIETY; Material retired; NRPT never a substance |
| W03 | biology and mechanisms | mechanisms | Organ specializes AnatomicalContext; mechanism edges derived in rule mode; Association retired |
| W04 | products, formulations, labels | products_and_commerce, products_and_formulations, labels | package-only vs variant vs declared-basis change settled on real captures; LabelSnapshot is a label on SourceSnapshot |
| W05 | food, lifestyle, exposures | food_lifestyle_exposure (candidate) | FoodItem specializes IngredientMaterial; FoodProduct retired into Product; Exposure immutable characterization |
| W06 | treatments, procedures | interventions (candidate) | Treatment/Procedure are concepts; three identities for one drug name; modality detail stays candidate |
| W07 | diagnostics | diagnostics | DiagnosticResult as interface with declared relationships; LOINC facts verified; one shared ResultQualifier |
| W08 | platforms, instruments, devices | consumer_devices (future) | five live types kept; FirmwareVersion candidate with WHOOP release-note case |
| W09 | studies, interventions, results | studies_and_evidence | registry facts on RegistrationVersion; LEGACY_EVALUATES read-only; four frozen validators corrected |
| W10 | evidence assessment | studies_and_evidence | no calibration bands; MATCH only at ratio 1.0 until calibrated; versioned synthesis real case |
| W11 | manufacturing | products_and_formulations, manufacturing_readiness | SpecificationVersion payload defined; capability stages from NAI 10-K history |
| W12 | quality | quality | COA vs test summary rule; NSF scope covers lots; criterion purpose and decision rule |
| W13 | regulation | regulatory_and_ip | RegulatoryPathwayVersion; GRN 000635 letter corrections to round 0005; inspection candidate |
| W14 | IP | regulatory_and_ip | IpRightStatus candidate (patent active, claims ineligible); license covers only what it names |
| W15 | commerce | products_and_commerce | SELLS_PRODUCT needs seller-of-record + resolved LISTING_FOR; every price an observation |
| W16 | protocols | protocols | edition by content hash; order on HAS_PROTOCOL_STEP; ranges never midpoints; three-valued conditions |
| W17 | safety | safety_and_constraints (candidate) | SafetySignal is an EvidenceAssessment; UseConstraint is the shared blocking identity |
| W18 | communities, events | events_and_narrative (future) | Event clocks from named assertions; CAUSED_BY only from a basisKind assertion; NarrativeArc is an assessment |
| W19 | Source Intelligence | provenance (candidates) | CL-003 identity rule; AuthorityScope over 127 registry entries; discovery outcome BLOCKED distinct |
| W20 | documents, text, chunks | claims_and_documents, provenance | offsets in code points; NFKC rejected; chunk never a locator |
| W21 | narrative media, claims | claims_and_documents | rendition-bound segments; no Presentation type; RECOMMENDS derived |
| W22 | media assets, rights | media (future) | MediaSource retired; bytes on MediaVariant; rights record never permission |
| W23 | access, policy, private boundary | access_and_answers, recommendation_decisions | insert-only AnswerRecord/PolicyVersion; private-store interface; PBAC and PostgreSQL 18 facts |

The natural-domain map of the handoff (section 2) is served without a sector taxonomy: supplements remain one product kind, and the large-biotech horizons (omics, cell/gene therapy, industrial, agricultural, environmental) stay scope candidates with attachment points named by W06 (`TreatmentModality`), W08, W11 and W13.
