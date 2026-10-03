# Starter Competency Questions

Status: candidate

These questions define the first supplement–compound–product–study recommendation slice. A model is useful only if it can answer these questions without unsafe inference.

## Identity and composition

- `CQ-ID-01`: Is the marketed product in a study the same enduring product, variant, formulation version, or merely a similarly named product?
- `CQ-ID-02`: Which label or formulation was effective when a study intervention was administered?
- `CQ-ID-03`: Does a label declare a chemical substance, a material that realizes it, or a constituent the material is said to provide?
- `CQ-ID-04`: Which external identifiers support a substance match, and at what authority/version?
- `CQ-ID-05`: Did a packaging-only change, formulation change, supplier/specification change, or product-identity change occur?

## Evidence and claims

- `CQ-EV-01`: What exact proposition does a source make, and which span supports it?
- `CQ-EV-02`: Is the proposition a source assertion, a BellLabs adjudication, or a derived retrieval shortcut?
- `CQ-EV-03`: Which trials, case reports, observational studies, or marketing testimonials support or contradict the proposition?
- `CQ-EV-04`: Does evidence apply to the current formulation, dose, route, schedule, duration, population, comparator, and outcome?
- `CQ-EV-05`: Has a result been corrected, retracted, superseded, or contradicted without deleting the historical assertion?

## Time

- `CQ-TM-01`: What did BellLabs believe on recorded date `R` about facts valid on domain date `V`?
- `CQ-TM-02`: When a late historical source arrives, can the system add past valid time without pretending BellLabs knew it earlier?
- `CQ-TM-03`: Can the system distinguish publication time, observation time, study time, effective time, and ingestion time?
- `CQ-TM-04`: Are unknown temporal bounds preserved as unknown rather than replaced with the current time?
- `CQ-TM-05`: Can two nonexclusive assertions overlap while mutually exclusive states are rejected for overlapping intervals?

## Recommendation and choice

- `CQ-RC-01`: Why was one product preferred over another for a stated goal and decision context?
- `CQ-RC-02`: Which evidence, applicability assessments, constraints, price/availability observations, and policy version affected the decision?
- `CQ-RC-03`: Which missing or disputed facts could change the ranking?
- `CQ-RC-04`: Can a decision be replayed as of both its domain-time and system-time viewpoint?
- `CQ-RC-05`: Can the system distinguish “evidence favors,” “BellLabs recommends,” “a source recommends,” and “a user selected”?
- `CQ-RC-06`: Can contraindications or interaction uncertainty block a recommendation rather than merely lower a score?

## Minimal adversarial pairs

Each pair must produce different graph deltas.

1. “Product X contains 250 mg of compound C” versus “Product X’s blend provides compound C.”
2. “The trial evaluated Product X” versus “The trial evaluated the same compound sold in Product X.”
3. “The company says X improves sleep” versus “A randomized trial found X improved sleep.”
4. “No adverse events were reported” versus “No adverse events occurred.”
5. “Available as of March” versus “launched in March.”
6. “Current label retrieved today” versus “label effective today.”
7. “Evidence is insufficient” versus “evidence shows no effect.”
8. “The source was corrected in June” versus “the underlying fact ceased to be true in June.”

## Initial acceptance target

The first vertical slice should answer `CQ-ID-01`, `CQ-ID-02`, `CQ-EV-01`, `CQ-EV-04`, `CQ-TM-01`, `CQ-TM-02`, `CQ-RC-01`, and `CQ-RC-03` over a small fixture set containing two products, two formulation versions, one trial, one case report, one conflicting marketing claim, and one late-arriving correction.
