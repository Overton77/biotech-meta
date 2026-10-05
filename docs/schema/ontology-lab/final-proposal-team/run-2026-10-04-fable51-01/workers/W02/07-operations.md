# W02 operations recommendations

Companion executable file: `operations.cypher`, with indexes in Section A and validators V-W02-01…13 in Section B. It was executed on Neo4j 5.26.31 Community: 25 statements, 25 ok. This document describes requirements only; it is not a runtime implementation.

## 1. Uniqueness and indexes (stored property names)

| Need | Statement | Edition | Note |
|---|---|---|---|
| uid uniqueness | existing `entity_uid` (`FOR (n:Entity) REQUIRE n.uid IS UNIQUE`) | Community | All W02 nodes carry `Entity` (D-001), so no W02-specific uid constraint is needed |
| Live fulltext `CompoundSearch` | `CREATE FULLTEXT INDEX CompoundSearch FOR (n:ChemicalSubstance) ON EACH [n.name, n.preferredName, n.description, n.commonName, n.casNumber, n.searchText]` | Community | D-015. `searchCompounds` was executed through @neo4j/graphql 7.6.3 against fixtures |
| Live fulltext `IngredientSearch` | `CREATE FULLTEXT INDEX IngredientSearch FOR (n:IngredientMaterial) ON EACH [n.name, n.description, n.searchText]` | Community | Covers all specializations (shared label) |
| Lookup keys | range indexes on `ChemicalSubstance.inchikey`, `.pubchemCid`, `.casNumber`; `IngredientMaterial.materialKind`; `BrandedIngredientMaterial.brandName`; `BotanicalTaxon.taxonomyId`; `MicrobialTaxon.taxonomyId`; `MicrobialStrain.depositIdentifier` | Community | Candidates only; an identifier hit is a candidate, never identity |
| As-of retrieval | relationship range index `GOVERNED_BY_SPECIFICATION(recordedFrom)`; `QUANTITATIVELY_CONTAINS(assertionUid)` | Community | Q-05a–c; V-W02-01 |
| Identifier identity | `(scheme, issuer, value)` uniqueness on `Identifier` | Community | W00's constraint, relied on here (contract A2) |
| **Not** constrained | `inchikey`, `pubchemCid`, `casNumber`, `depositIdentifier`, `taxonomyId` uniqueness | — | A merge keeps the old uid resolvable until the redirect is published. Duplicates are reported by V-W02-13 / V-W02-05 |
| Existence and type constraints | e.g. `IngredientMaterial.materialKind IS NOT NULL` | Enterprise only (unverified) | Not proposed; service-enforced instead, as with the baseline's 12 Community-rejected constraints |

**`@vector` retrieval justification** (for Fable, D-014): the live `CompoundSearchEmbedding` served synonym and trade-name lookup ("Niagen", "NR", "nicotinamide ribonucleoside"). If retained:
- it goes on `ChemicalSubstance` and `IngredientMaterial` over `searchText`, with no `provider`, and embeddings computed outside the API;
- it is used only to propose `ResolutionHypothesis` candidates (QS-8), never as identity (INV-107);
- its dimension must be recorded per index.

## 2. Retrieval patterns

| Pattern | Query | Index used |
|---|---|---|
| Label line → referent → active moiety → calculated amount | Q-01 | uid lookups; `DERIVED_FROM_ASSERTION` traversal |
| Material → provides vs contains | Q-02 | uid; `assertionUid` |
| Substance → identifiers with authority snapshot | Q-03 | uid; Identifier edges |
| Material pair → identity facts (input to W10) | Q-04 | uid; `REALIZES_SUBSTANCE`, `HAS_ACTIVE_MOIETY`, `HAS_CHEMICAL_FORM` |
| Branded material → specification at (V, R) | Q-05a–c | `GOVERNED_BY_SPECIFICATION(recordedFrom)` |
| Strain → deposits, current species, viability | Q-06 | uid; `depositIdentifier` |
| Free text → candidate substances or materials | `searchCompounds`, `searchIngredients` (fulltext), then QS-8 | `CompoundSearch`, `IngredientSearch` |

## 3. Application validation (service-enforced at write time)

1. **Asserted edges.** Every W02 relationship write needs an authorizing Assertion with the same predicate, subject and object. The edge carries `relationshipUid`, `assertionUid`, `recordedFrom` (commit time) and both valid-time bases (V-101, V-W02-01). Detected after the fact by V-W02-01 / V-112.
2. **Domain and range.** Checked before commit (V-W02-11). `HAS_MIXTURE_COMPONENT` has no self-loop. `FORM_OF_SUBSTANCE` takes exactly one target per form, so a second write is rejected (V-222).
3. **QUANTITATIVELY_CONTAINS shape.** Validated per V-006r (V-W02-10). Spec limits are rejected with the message "use W12 SpecificationCriterion". A write whose authorizing assertion predicate is PROVIDES_CONSTITUENT is rejected.
4. **CALCULATED assertions.** They require `derivationRule`, at least one `DERIVED_FROM_ASSERTION` and no own `SUPPORTED_BY`, and they never attach to a declaration (V-W02-08, V-330). The calculator recomputes whenever an input is superseded (for example a new MW source) and writes a new assertion linked by `SUPERSEDES {RE_REVIEW}`. The old one is never edited.
5. **ChemicalSubstance creation.** Above CANDIDATE it requires a structure anchor (V-W02-03). A name that resolves to several moieties is routed to a ResolutionHypothesis, never to a substance (V-W02-04).
6. **Specialization labels and `materialKind`** must agree (V-W02-02). Reclassification adds a label and changes the kind; the uid is unchanged (token `material`).
7. **STRAIN_OF exclusivity.** Before projecting a new `STRAIN_OF`, close the previous episode's `recordedTo` in the same transaction, or reject (V-W02-09).
8. **Legacy migration.** Relabel per node only after a reviewed ResolutionHypothesis (identifier first). Write the redirect EquivalenceAssessment when the node resolves to an existing identity. Track progress with V-W02-12.

## 4. Transactions and concurrency

- **Assertion and edge together.** Each asserted edge is written in the same transaction as its Assertion; the asserted_edge profile forbids an edge without its assertion.
- **Calculations.** A CALCULATED assertion and its `DERIVED_FROM_ASSERTION` edges are one transaction. Concurrent recalculation is guarded by a deterministic uid: hash of rule id plus input assertion uids. A second writer then MERGEs onto the same node instead of duplicating it.
- **Identity creation is idempotent.** `MERGE` on uid with `ON CREATE SET` is the pattern used in every fixture, so loading beside the repo fixtures never overwrote their properties. A remaining race is two ingestions minting different uids for the same structure; V-W02-13 detects it.
- **Supersession** of spec attachments or taxon assignments writes `recordedTo` on the old episode only once, from null (bitemporal profile).

## 5. Capability and edition conditions

- **Everything in `operations.cypher` runs on Community 5.26.31.** That covers fulltext, range indexes, relationship range indexes, `COLLECT {}` / `EXISTS {}` subqueries and dynamic list comprehensions; Enterprise was not needed for any of it.
- **Enterprise-only items are unverified.** These are property existence and type constraints, which Community rejects (the baseline shows the same 12 rejections).
- **Library.** `@neo4j/graphql` 7.6.3 built and served union-target relationships with relationship properties (`MaterialContentTarget` + `QuantitativeContentProperties`) and `@settable(onCreate:false,onUpdate:false)` on derived fields. There is no `@unique` directive; uniqueness comes only from the constraints above.

## 6. Idempotence, lifecycle, migration and compatibility

- **Fixture idempotence.** Fixtures and migrations can be re-run. Loading fx-01…07 twice on a fresh database gave 165 nodes / 239 relationships after both passes (executed).
- **Lifecycle.**
  - A material keeps its uid through reclassification, specification revisions and brand-mark changes.
  - A material changes uid only when the identity rule changes (owner, realized substance or form, or brand moved to another material). Then a new node is created, and the old uid stays resolvable.
- **Compatibility.**
  - Live field names `forms`, `formOf`, `modulates`, `affectsMechanisms`, `casNumber`, `commonName` and `compoundClass`, and the live queries `searchCompounds` and `searchIngredients`, survive.
  - `Compound.molecularWeight`, `CompoundForm.dosageForm/concentrationText`, `Ingredient.ingredientRole` and the `Material.*` hints move (migration-map.yaml).
  - Legacy enum value `BRANDED_CHEMICAL_MATERIAL` stays readable.
- **Ingestion overhead.** One Assertion per asserted edge. Typical counts from the fixtures:

  | Item | Assertions |
  |---|---|
  | One label line (USES_MATERIAL + REALIZES_SUBSTANCE + HAS_CHEMICAL_FORM) | 3 |
  | One substance with 3–4 identifiers | 3–4 |
  | One CALCULATED amount (plus 5 input edges) | 1 |

  fx-01 has 97 statements for 2 substances, 3 materials, 7 identifiers and 1 calculation. Authority records (GSRS, PubChem) should be captured once per release and reused across products.
