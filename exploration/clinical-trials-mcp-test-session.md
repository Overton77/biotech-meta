# ClinicalTrials.gov MCP — test session

**Date:** 2025-03-24  
**Purpose:** Exercise `clinical-trials-mcp` endpoints and record responses for exploration / regression reference.

---

## 1. `get_available_fields` (category: `identification`)

**Request:** category = `identification`

**Response (summary):**

| Property | Value |
|----------|--------|
| category | identification |
| description | Basic trial identification and titles |
| fields | `NCTId`, `BriefTitle`, `OfficialTitle`, `Acronym`, `SecondaryId` |

**Status:** OK — returns a small, typed field list for that category.

---

## 2. `search_trials_by_condition`

**Request:** conditions = `["type 2 diabetes"]`, max_studies = 5, fields = `NCTId`, `BriefTitle`, `OverallStatus`, `Phase`, `LeadSponsorName`

**Observations:**

- Response shape: array of studies under `studies`, each with nested `protocolSection` (API v2 style).
- Requested “flat” field names map into modules (e.g. identification, status, design, sponsor).
- `nextPageToken` present when more results exist (pagination works).

**Sample rows (NCTId → brief title → status → phase → lead sponsor):**

| NCTId | BriefTitle (truncated) | OverallStatus | Phase | Lead sponsor |
|-------|------------------------|---------------|-------|--------------|
| NCT03758144 | Rifaximin Improves Gut Dysbiosis… | UNKNOWN | NA | Zagazig University |
| NCT03449199 | Phase 2 Study of TMX-049… | COMPLETED | PHASE2 | Teijin America, Inc. |
| NCT06519448 | Reducing Non-Alcoholic Steatohepatitis | ENROLLING_BY_INVITATION | NA | Military University Hospital, Prague |
| NCT00536549 | Effect of Real Time CGM… Type 2 Diabetes | COMPLETED | NA | Korea University |
| NCT03202277 | BeWell24: Smartphone-based Diabetes Prevention… | COMPLETED | NA | Arizona State University |

**Status:** OK.

---

## 3. `search_trials_nct_ids_only`

**Request:** conditions = `["Alzheimer disease"]`, max_studies = 8

**Observations:**

- Lighter payload: each item includes `nctId`, `briefTitle`, `interventions`, `conditions`, `phases`, `sponsors`, `hasResults`, optional `acronym`.
- Some hits are broad (e.g. air quality study) — condition matching can include non-primary associations; worth noting for query design.

**Returned NCT IDs (8):**  
`NCT04570644`, `NCT04906863`, `NCT05997784`, `NCT00479349`, `NCT01397539`, `NCT03823404`, `NCT03545789`, `NCT02158910`

**Status:** OK.

---

## 4. `analyze_trial_phases`

**Request:** conditions = `["oncology"]`, max_studies = 200

**Response:**

- `total_studies`: 200  
- `phase_distribution` (counts): PHASE1 42, PHASE2 59, NA 47, PHASE3 20, Unknown 40, PHASE4 4, EARLY_PHASE1 5  
- `phase_percentages`: PHASE1 21%, PHASE2 29.5%, NA 23.5%, PHASE3 10%, Unknown 20%, PHASE4 2%, EARLY_PHASE1 2.5%

**Status:** OK — useful for quick phase mix on a condition slice.

---

## 5. `get_field_statistics`

**Request:** field_names = `["Phase", "OverallStatus"]`

**Summary (top values only):**

**Phase** (`protocolSection.designModule.phases`):

- NA — 223,316 studies  
- PHASE2 — 87,581  
- PHASE1 — 63,801  
- PHASE3 — 48,749  
- PHASE4 — 34,952  
- EARLY_PHASE1 — 6,188  
- `missingStudiesCount`: 136,889  
- `uniqueValuesCount`: 6  

**OverallStatus** (`protocolSection.statusModule.overallStatus`):

- COMPLETED — 315,284  
- UNKNOWN — 89,623  
- RECRUITING — 65,526  
- (plus 11 other enum values with smaller counts)  
- `missingStudiesCount`: 0  
- `uniqueValuesCount`: 14  

**Status:** OK — global DB stats; numbers are snapshot at query time.

---

## 6. `search_trials_combined`

**Request:** interventions = `["pembrolizumab"]`, max_studies = 3, fields = `NCTId`, `BriefTitle`, `Phase`

**Results:**

| NCTId | BriefTitle (short) | Phase |
|-------|-------------------|--------|
| NCT03589339 | NBTXR3 + radiotherapy + anti-PD-1 | PHASE1 |
| NCT02513472 | Eribulin + pembrolizumab mTNBC | PHASE1, PHASE2 |
| NCT05792995 | PD-1 expression in peripheral blood T cells | PHASE2 |

`nextPageToken` returned.

**Status:** OK.

---

## 7. `get_trial_details`

**Request:** nct_id = `NCT03449199`, fields = `NCTId`, `BriefTitle`, `OverallStatus`, `Phase`, `ConditionsModule`, `ArmsInterventionsModule`

**Response included:** identification (NCTId, brief title), status (COMPLETED), design (PHASE2).  
Modules requested in `fields` that did not appear in the captured JSON may be omitted when empty or not returned for this field set — verify in UI or broaden fields if full eligibility/arms are needed.

**Status:** OK for core identification/status/design.

---

## 8. `search_trials_by_sponsor`

**Request:** sponsors = `["National Cancer Institute"]`, max_studies = 3, fields = `NCTId`, `BriefTitle`

**Results:**

- NCT00423930 — Cisplatin, Bevacizumab, IMRT head and neck cancer  
- NCT00963807 — FLT vs FDG PET/CT NSCLC  
- NCT00002571 — SWOG-9320 AIDS-related lymphoma  

`nextPageToken` returned.

**Status:** OK.

---

## Tools not called in this session

The following MCP tools exist but were not invoked here (candidates for a follow-up pass):

- `search_trials_by_intervention` (dedicated intervention search)  
- `search_trials_by_acronym`  
- `search_trials_by_nct_ids`  
- `get_trial_details_batched`  

---

## Overall conclusion

All exercised endpoints returned structured JSON without errors. Pagination tokens appear on list-style searches. Field lists and statistics align with ClinicalTrials.gov API v2-style nesting under `protocolSection`. For strict condition relevance, prefer combined queries or post-filtering when using broad condition text.
