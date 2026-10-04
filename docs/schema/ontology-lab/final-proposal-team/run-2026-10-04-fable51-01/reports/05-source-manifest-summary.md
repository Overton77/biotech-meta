# 05 Source manifest summary

Heuristic counts over each packet's `03-source-manifest.md` (occurrences of the manifest status markers; a row can carry several). Every packet separates NEW_RETRIEVAL from INHERITED repository citations and SYNTHETIC fixtures, records BLOCKED fetches as blocked (never as absence), and marks capture completeness. The per-packet manifests are the authoritative record; this table is the index.

| Packet | NEW_RETRIEVAL | INHERITED | SYNTHETIC | BLOCKED | SEARCH_EXTRACT | PARTIAL_EXCERPT | COMPLETE |
|---|---|---|---|---|---|---|---|
| W00 | 10 | 5 | 2 | 1 | 4 | 5 | 3 |
| W01 | 7 | 6 | 3 | 5 | 3 | 2 | 3 |
| W02 | 28 | 6 | 4 | 3 | 13 | 9 | 5 |
| W03 | 16 | 3 | 2 | 3 | 0 | 4 | 10 |
| W04 | 14 | 5 | 3 | 4 | 0 | 9 | 4 |
| W05 | 7 | 1 | 3 | 1 | 0 | 5 | 1 |
| W06 | 12 | 2 | 4 | 3 | 3 | 10 | 2 |
| W07 | 13 | 4 | 3 | 2 | 1 | 3 | 9 |
| W08 | 9 | 6 | 3 | 2 | 4 | 5 | 1 |
| W09 | 20 | 6 | 8 | 9 | 3 | 15 | 1 |
| W10 | 13 | 4 | 3 | 9 | 2 | 6 | 6 |
| W11 | 15 | 1 | 3 | 3 | 9 | 6 | 1 |
| W12 | 2 | 1 | 2 | 0 | 1 | 7 | 2 |
| W13 | 1 | 1 | 2 | 0 | 3 | 12 | 6 |
| W14 | 12 | 5 | 9 | 3 | 3 | 5 | 4 |
| W15 | 14 | 4 | 5 | 2 | 7 | 8 | 3 |
| W16 | 12 | 4 | 4 | 1 | 2 | 6 | 3 |
| W17 | 9 | 2 | 7 | 4 | 3 | 6 | 1 |
| W18 | 18 | 7 | 3 | 1 | 8 | 6 | 2 |
| W19 | 1 | 0 | 1 | 6 | 6 | 10 | 2 |
| W20 | 13 | 2 | 2 | 3 | 0 | 7 | 4 |
| W21 | 2 | 1 | 3 | 5 | 3 | 4 | 0 |
| W22 | 15 | 3 | 7 | 3 | 3 | 5 | 7 |
| W23 | 2 | 1 | 2 | 0 | 1 | 0 | 1 |
| **Total** | 265 | 80 | 88 | 73 | 82 | 155 | 81 |

## Retrieval conditions common to all packets

- The egress proxy returned 403 for direct fetches of many first-party hosts (NCBI/PubMed E-utilities, nature.com, sec.gov, fda.gov, DailyMed, ClinicalTrials.gov API v2 and history tab, reactome.org, ebi.ac.uk, patents.google.com, tsdr.uspto.gov, web.archive.org, hubermanlab.com, elysiumhealth.com, truniagen.com, PubChem, GSRS, Wikimedia Commons image bytes). Workers used the PubMed and ClinicalTrials.gov connectors, Firecrawl and Tavily extracts, and recorded each blocked fetch; the ClinicalTrials.gov history tab returned HTTP 200 with an embedded 403 page (W19), so status codes alone were not trusted.
- Consequently most snapshot hashes are over stored excerpt text (`contentHashBasis: STORED_EXCERPT_TEXT` or `SYNTHETIC_FIXTURE`), not raw bytes; W15 hashed two real payloads (a Walmart page and a Shopify products.json). No image bytes were fetched (W22).
- Registry version history for NCT02678611 was not retrievable; `RegistrationVersion.versionDate` stays null in the fixtures.
- Real records verified against primary sources during the run include: PMID 29184669 and erratum PMID 30155270, PMID 9500320 and retraction PMID 20137807, GRN 000635 response letter, NDI 1062 acknowledgment, 510(k) K243236 and K234070, DEN200080, NDA 217785, orphan designations 714319 and 465514, LOINC 4548-4 and 59261-8, GSRS UNII 8XM2XT8VWI and 0I8H2M0L7N, Reactome R-HSA-196807.8, USPTO registration 4606519, US 8,197,807 B2 and the Federal Circuit decision, Cyanotech FY2002 10-K, NAI 10-Ks, the Amazon B0FS82B35K and B000QSNYGI offer blocks, the Rezdiffra EU/US milestones, the Blueprint protocol captures, protocols.io PBMC V.1/V.2 and NICE CG185.
