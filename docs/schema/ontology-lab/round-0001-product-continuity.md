# Round 0001: Product Continuity and Evidence Transfer

Status: `OPEN`

## Intent

Decide how BellLabs distinguishes `Product`, `ProductVariant`, and `FormulationVersion`, because recommendation quality depends on whether evidence about an older or investigational intervention applies to a currently sold item.

Target questions: `CQ-ID-01`, `CQ-ID-02`, `CQ-EV-04`, `CQ-RC-03`.

## Cooperative-adversarial dialogue

**Builder:** A `Product` is the enduring marketed concept. A `ProductVariant` is a consumer-distinguishable realization, commonly separated by dosage form, labeled strength, flavor, jurisdiction, or route. A `FormulationVersion` is the time-bounded composition of a variant. Packaging count alone creates a `PackageConfiguration`, not a new formulation.

**Challenger:** That sounds neat but assumes marketing continuity equals scientific continuity. A company may keep the same name and SKU while changing dose, salt form, excipients, or supplier specification. Conversely, it may rename an unchanged formula. Which identity controls evidence transfer?

**Builder:** None by itself. Product identity supports commerce continuity; evidence transfer is a separate `EvidenceApplicability` assessment. It compares the studied intervention with the target formulation across identity, material/form, dose, route, schedule, duration, population, comparator, outcome, and study quality.

**Challenger:** Then why model Product continuity at all? Recommend directly from formulations.

**Builder:** Users choose commercial products, sources refer to brand/product names, and offers/prices attach to marketed identities. Formulation identity is necessary for evidence reasoning but insufficient for product choice, availability, quality, and explanation.

**Challenger:** Suppose a trial names only the brand and publication year. The historical label is unavailable. Do we attach the trial intervention to the Product, the current FormulationVersion, or neither?

**Builder:** Attach the intervention mention to the durable Product only as a source assertion, preserve the unresolved formulation match, and create an applicability assessment whose formulation and dose dimensions are `UNKNOWN`. Do not connect the trial to the current formulation by default.

**Challenger:** Suppose a current label says a blend “provides 100 mg compound C.” Does that establish that the formulation quantitatively contains 100 mg of pure C?

**Builder:** No. Preserve the label declaration verbatim and use `PROVIDES_CONSTITUENT`. Use `QUANTITATIVELY_CONTAINS` only when the stated material, measurement basis, and unit support that stronger proposition.

## Candidate rule

1. Product-name continuity is not formulation continuity.
2. Formulation continuity is not evidence applicability.
3. `ProductVariant` boundaries follow consumer-distinguishable identity dimensions and jurisdiction, not every mutable property.
4. Any composition change creates a new `FormulationVersion`; whether it also creates a new Variant remains a separate decision.
5. Missing historical formulation evidence produces unknown applicability, not a link to the current formulation.
6. Recommendation retrieval must surface the weakest applicability dimensions and missing facts.

## Remaining challenge

Choose the default rule for a labeled-strength or dosage-form change:

- **Candidate A — conservative:** always create a new `ProductVariant` and `FormulationVersion`.
- **Candidate B — contextual:** create a new Variant only when consumers, regulators, or commerce systems distinguish it; always create a new FormulationVersion.
- **Candidate C — product-led:** retain the Variant whenever brand/SKU continuity exists; create only a new FormulationVersion.

Provisional Builder position: **Candidate B**, with explicit jurisdiction and identity-basis evidence. Challenger burden: produce a case where B creates irreducible ambiguity or unsafe evidence inheritance.

## Fixtures required before acceptance

- same product name and SKU, changed chemical form;
- renamed product with unchanged formulation;
- same formula sold in capsule and powder forms;
- same brand and strength, different jurisdictional labels;
- trial mentioning a brand without a recoverable historical label;
- “contains” versus “provides” label minimal pair;
- current recommendation query whose ranking changes when formulation applicability becomes unknown.
