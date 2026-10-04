# W14 Intellectual property and licensing: domain recommendation

Worker W14 (Opus 5.5), run `run-2026-10-04-fable51-01`. Canonical modules are unchanged: `regulatory_and_ip` (patents, licenses), `products_and_formulations` (Trademark, `MARKETED_UNDER_MARK`) and `organizations` (the asserted predicates `OWNS_TRADEMARK`, `ASSIGNED_PATENT`, `LICENSES_PATENT`). Authority: catalog 0.2.0 (`8fb50ff0…84f0`), architecture.md section 10 (last paragraph: "Patent family, application, grant, and claim; assignee, inventor, and licensee; trademark and the branded material sold under it remain separate as in 0.1.0") and section 9 (`LICENSES_PATENT != OWNS_STUDY`).

## 1. Boundaries and subdomains

| Subdomain | In W14 scope | Out of scope (owner) |
|---|---|---|
| Patent rights structure | Family (under a stated family definition), application per office, grant per office, numbered claim per publication | Patent PDF or HTML as a document (`Document` with `DocumentType` PATENT / PATENT_APPLICATION, W20; `MediaSourceType.PATENT_FIGURE`, W22) |
| Legal status of rights | Pending, published, granted/in force, expired, lapsed, withdrawn, abandoned, cancelled; claim held invalid, unpatentable or cancelled; trademark registered, renewed, cancelled. All are episodes of the candidate `IpRightStatus` | Regulatory status (`RegulatoryStatus`, W13; INV-010 keeps the two apart) |
| Holding and transacting rights | Assignment (`ASSIGNED_PATENT`), license terms (`PatentLicense`), licensee (`LICENSES_PATENT`), licensor (candidate `GRANTS_PATENT_LICENSE`), coverage (`LICENSE_COVERS`) | Organizations and persons as identities, the FINANCIAL_INTEREST family including `HAS_IP_INTEREST_IN`, predicate registration (W01) |
| What a claim covers | `PATENT_CLAIMS` assertions (asserter-bound): what a claim or patent reads on, never efficacy | Efficacy and outcomes (W09/W10), substances and materials (W02) |
| Marks | `Trademark` as a jurisdictional right; `MARKETED_UNDER_MARK` from the branded material; `OWNS_TRADEMARK` | `ConsumerBrand` (W01), `BrandedIngredientMaterial` (W02), product marks on `Product` (W04, candidate only) |
| Identifiers | Office numbers are `Identifier` records (scheme, issuer, jurisdiction) with materialized `officeKey` on the node | `Identifier` type and `HAS_IDENTIFIER` (W00) |

The live schema (`current_biotech_schema.graphql`, digest `86b5e0b5…f112`) has **no patent or trademark node type** (confirmed by grep: the only IP-related symbols are enum values `DocumentType.PATENT`, `DocumentType.PATENT_APPLICATION`, `DocumentDomain.PATENT_IP`, `MediaSourceType.PATENT_FIGURE`, `EventCategory.LICENSING_EVENT` and the free-text `MediaAsset.license`). The migration map therefore contains only catalog elements and those live enum values, with their owners.

## 2. Identity, state, artifact, occurrence

| Concept | Archetype | Why |
|---|---|---|
| `PatentFamily` | Entity | An enduring grouping, but **only under one family definition**. The Google Patents worldwide list for US 8,197,807 B2 mixes a 2005 PCT branch (CA, AU, JP, EP, WO) with the 2006 US national stage, while the 2014 Dartmouth license names AU 2006238858 and CA 2,609,633, which that captured list does not show. One application can belong to two families under two definitions; they are compared with an `EquivalenceAssessment`, never merged. |
| `PatentApplication`, `GrantedPatent`, `PatentClaim` | InformationArtifact | Immutable records as filed, published or granted. The catalog's `status` property on these nodes is **retired** because status changes after capture (US 8,197,807 is "Active" on Google Patents while the Federal Circuit affirmed that claims 1–3 are patent-ineligible). |
| `PatentLicense` | VersionedState | The terms of one agreement version. Its parties and coverage are asserted episodes. |
| `IpRightStatus` (candidate) | VersionedState | A bounded legal status of one right or claim, attached through asserted `IP_STATUS_OF` episodes. It mirrors `RegulatoryStatus` but stays a separate type (INV-010). |
| `Trademark` | Entity | A **jurisdictional right**: one office filing or registration. The same mark text in another jurisdiction is another node. The NIAGEN US registration lists international registration 1336169 as "based on this property"; that IR is a different `Trademark`, never an identifier of the US right. |
| Litigation, office actions, assignments as events | not modelled (Occurrence candidates) | No CQ needs the event itself. Its outcome is an `IpRightStatus` episode with `proceedingReference`. The live `EventCategory.LICENSING_EVENT` belongs to W18. |

## 3. Disposition of every element in scope

| Element | Origin | Disposition | Note |
|---|---|---|---|
| `PatentFamily` {familyIdentifier, title} | cat | **refine** | Adds `familyDefinition` (required; candidate enum) and `entityType`. `familyIdentifier` becomes a materialized key of an `Identifier` and is nullable for SOURCE_DISPLAYED and CURATED families. |
| `PatentApplication` {applicationNumber, jurisdiction, filingDate, status} | cat | **refine** | `status` is retired into `IpRightStatus`. Adds `officeKey` (unique), `applicationKind`, `title`, and `applicantNamesVerbatim` and `inventorNamesVerbatim` (as printed, immutable). |
| `GrantedPatent` {patentNumber, jurisdiction, grantDate, status} | cat | **refine** | `status` is retired. Adds `kindCode`, `officeKey`, `title`, and `assigneeNamesVerbatim` and `inventorNamesVerbatim` as printed. |
| `PatentClaim` {claimNumber, claimTextHash, claimKind} | cat | **refine** | Adds `claimText`, `dependsOnClaimNumbers` and `claimTextNormalization` (NFC-WS1). Validity lives in `IpRightStatus`. A claim as filed and a claim as granted are two nodes. |
| `PatentLicense` {exclusive, fieldOfUse, territory, effectiveFrom, effectiveTo} | cat | **refine** | Adds per-term `*ReportedStatus` (W00 `ReportedStatus`), so that a redacted term (NOT_REPORTED) differs from an uncaptured one (null). Also adds `territoryJurisdictions`, `sublicensable`, `coverageRuleText`, `termText` and `agreementTitle`. |
| `Trademark` {markText, registrationNumber, jurisdiction, status} | cat (products_and_formulations) | **refine; keep module (T-001: no transfer)** | `status` is retired. Adds `applicationSerialNumber`, `officeKey` (serial-based, stable from filing) and `markDrawingKind`. No failing case shows that the module placement changes any query, so T-001 stays as the baseline: W14 writes the SDL and the canonical module stays `products_and_formulations`. |
| `FAMILY_HAS_APPLICATION` | cat, structural | **keep** | Membership under the family node's own definition. |
| `APPLICATION_GRANTED_AS` | cat, asserted | **keep** | Asserter is the office record, or an aggregator display when that is all that was captured. |
| `HAS_PATENT_CLAIM` | cat, structural | **keep** | Exactly one parent per claim (V-W14-06). |
| `LICENSE_COVERS` | cat, asserted | **keep, with a rule** | Exactly the members the source names. Family-level coverage only when the source states it. `coverageRuleText` is never expanded (V-W14-05). |
| `MARKETED_UNDER_MARK` | cat, asserted | **keep** | BrandedIngredientMaterial → Trademark. The outgoing field is requested from W02 (W14-SR-05). |
| `OWNS_TRADEMARK` | cat predicate | **project** Organization → Trademark | Predicate registration stays with W01 (W14-SR-03). |
| `ASSIGNED_PATENT` | cat predicate | **project** Organization → PatentFamily, PatentApplication or GrantedPatent | A family-level target is used only when the source speaks of the family ("held by Dartmouth" names patents, so the fixture uses grants). |
| `LICENSES_PATENT` | cat predicate | **project** Organization (licensee) → PatentLicense | The object is the license state, not the patent: one licensee can hold two agreements with different terms (2012 and 2014 Dartmouth agreements). |
| `GRANTS_PATENT_LICENSE` | new | **candidate (in fragment)** | Licensor side. Failing case: a sublicense's licensor is the licensee, not the assignee (Q-05). |
| `IpRightStatus`, `IP_STATUS_OF`, `IpRightStatusSubjectTarget` | new | **candidate (in fragment)** | Failing case F-STATUS-01: patent-level "Active" with claims held invalid; the trademark renewal; lapse and expiry as bounded states. |
| `PATENT_CLAIMS` | cat forbidden-implication premise | **register as asserted predicate (assertion only, no projected edge)** | `[PATENT_CLAIMS, PROVES_EFFICACY]` then applies literally. W14-SR-04. |
| `PatentLicenseTarget` | registry | **keep** | PatentFamily, PatentApplication, GrantedPatent and PatentClaim. |
| Inventor role (`NAMED_INVENTOR`) | handoff, architecture section 10 | **defer (CANDIDATE, not in fragment)** | Names are kept verbatim on the artifact. A Person-to-patent role needs a CQ. Inventorship, assignment and `HAS_IP_INTEREST_IN` are three different facts (W14-SR-06). |
| License agreement identity (an Entity grouping amendments), `SUBLICENSE_OF` | new | **defer** | No CQ fails without them. Amendments are new `PatentLicense` states, with assertion-level supersession. |
| Product-level marks (TRU NIAGEN on `Product` or `ConsumerBrand`) | new | **defer** | Seam with W04/W01. The catalog edge covers branded materials only. |
| Live `DocumentType.PATENT`, `PATENT_APPLICATION`, `DocumentDomain.PATENT_IP` | live enum | **seam, no change by W14** | W20 owns them. A patent Document is a rendition Source about the artifact. |
| Live `MediaSourceType.PATENT_FIGURE` | live enum | **seam** | W22. |
| Live `EventCategory.LICENSING_EVENT` | live enum | **seam** | W18. Not a license record. |

## 4. Alternatives considered

1. **Status as a property on the artifact (catalog 0.2.0).** Rejected. It cannot hold "Active per Google as of 2026-10-04" together with "claims 1–3 held invalid per CAFC 2023-02-13" and "adjusted expiry 2026-11-19". It also makes an immutable InformationArtifact mutable. The CQ-IP-C01 query would return invalid claims as enforceable.
2. **Status as plain assertion literals (`valueString`) with no state node.** This is close to sufficient, but scope (amended goods and services, classes), legal basis and proceeding do not fit one literal. The RegulatoryStatus precedent gives a consistent shape, so the smallest consistent choice is a VersionedState.
3. **Reuse `RegulatoryStatus` for IP.** Rejected under INV-010: patent status, regulatory notification and approval must remain distinct, and the `statusKind` vocabularies conflict.
4. **License terms on the `LICENSES_PATENT` edge (no PatentLicense node).** Rejected. The catalog already has `PatentLicense`, two agreements between the same parties would become parallel edges that differ only in properties, and coverage (`LICENSE_COVERS`) needs a source node.
5. **Trademark as a cross-jurisdiction mark identity, with registrations as identifiers.** Rejected. Ownership, status and goods are per right. Attaching the IR number to the US right is exactly the identity collision that V-W14-08 catches.
6. **Licensor inferred from the assignee.** Rejected because of the sublicense failing case (Q-05: naive "Synthetic University" against the asserted "Synthetic Licensee A").

## 5. Smallest recommended model

Six catalog types (refined as above), one union (`PatentLicenseTarget`), five catalog relationships and three projected organization predicates. Two candidates carry failing cases: `IpRightStatus` with `IP_STATUS_OF` and its union, and `GRANTS_PATENT_LICENSE`. One assertion-only predicate is registered: `PATENT_CLAIMS`. There are **no** new relationship-property types: every edge reuses W00's `AssertedEdgeProperties`, `StructuralEdgeProperties` or `IdentifierLinkProperties`. There are no new enums in the fragment; four closed vocabularies are requested (W14-SR-02).
