// Each query should return zero rows in a valid committed graph unless noted.

// V-000a: uid is globally unique across base archetypes, not merely per label.
MATCH (n)
WHERE n:Entity OR n:VersionedState OR n:Occurrence OR n:InformationArtifact OR n:Assertion OR n:EvidenceAssessment
WITH n.uid AS uid, collect(n) AS nodes
WHERE uid IS NULL OR size(nodes) <> 1
RETURN uid, size(nodes) AS nodeCount;

// V-000b: every semantic node has exactly one base archetype.
MATCH (n)
WHERE n:Entity OR n:VersionedState OR n:Occurrence OR n:InformationArtifact OR n:Assertion OR n:EvidenceAssessment
WITH n,
     size([label IN labels(n)
           WHERE label IN ['Entity', 'VersionedState', 'Occurrence', 'InformationArtifact', 'Assertion', 'EvidenceAssessment']]) AS archetypeCount
WHERE archetypeCount <> 1
RETURN n.uid AS uid, labels(n) AS labels, archetypeCount;

// V-001: accepted assertions require exact source attribution.
MATCH (a:Assertion {status: 'ACCEPTED'})
WHERE NOT (a)-[:SUPPORTED_BY]->(:SourceLocator)
RETURN a.uid AS assertionWithoutSource;

// V-002: assertions require exactly one subject.
MATCH (a:Assertion)
OPTIONAL MATCH (a)-[:HAS_SUBJECT]->(s)
WITH a, count(s) AS subjects
WHERE subjects <> 1
RETURN a.uid AS assertionUid, subjects;

// V-003: assertions must have exactly one object OR one typed literal.
MATCH (a:Assertion)
OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o)
WITH a, count(o) AS objects,
     size([x IN [a.valueString, a.valueNumber, a.valueBoolean] WHERE x IS NOT NULL]) AS literals
WHERE objects + literals <> 1
RETURN a.uid AS assertionUid, objects, literals;

// V-004: no direct composition shortcut may masquerade as authoritative history.
MATCH (p)-[r:CONTAINS]->(m:IngredientMaterial)
WHERE r.projectionOfAssertionUid IS NULL AND r.derivationRule IS NULL
RETURN p.uid AS productUid, m.uid AS materialUid;

// V-005: formulation components must identify a material.
MATCH (c:IngredientComponent)
WHERE NOT (c)-[:USES_MATERIAL]->(:IngredientMaterial)
RETURN c.uid AS componentWithoutMaterial;

// V-006: quantitative containment requires quantity, unit, and basis.
MATCH ()-[r:QUANTITATIVELY_CONTAINS]->()
WHERE r.quantity IS NULL OR r.unitCode IS NULL OR r.basis IS NULL
RETURN r;

// V-007: accepted advisor-product endorsement cannot be inferred only from advising.
MATCH (p:Person)-[:ADVISES_ORGANIZATION]->(o:Organization),
      (p)-[e:ENDORSES_PRODUCT]->(product:Product)
WHERE e.projectionOfAssertionUid IS NULL
RETURN p.uid AS advisorUid, o.uid AS organizationUid, product.uid AS productUid;

// V-008: a Certificate of Analysis must report on a lot or execution.
MATCH (c:CertificateOfAnalysis)
WHERE NOT (c)-[:CERTIFIES_RESULTS_FOR]->(:ProductLot|TestExecution)
RETURN c.uid AS orphanCertificate;

// V-009: a Certification Listing must have explicit scope.
MATCH (l:CertificationListing)
WHERE NOT (l)-[:HAS_CERTIFICATION_SCOPE]->(:CertificationScope)
RETURN l.uid AS listingWithoutScope;

// V-010: orphan designation and drug approval may not share an identity node.
MATCH (n:OrphanDesignation:DrugApproval)
RETURN n.uid AS collapsedRegulatoryIdentity;

// V-011: label declarations must not be modeled as measured results.
MATCH (n:LabelDeclaration:MeasuredResult)
RETURN n.uid AS collapsedDeclarationAndMeasurement;

// V-012: registrations, protocols, publications, and studies are distinct identities.
MATCH (n)
WHERE (n:Study AND (n:TrialRegistration OR n:ProtocolVersion OR n:Publication))
RETURN n.uid AS collapsedStudyArtifact;

// V-013: show unresolved source identifier conflicts for agent review (informational).
MATCH (a:Assertion {status: 'DISPUTED'})-[:HAS_OBJECT]->(r:TrialRegistration)
RETURN a.uid, r.registry, r.registrationId, a.confidence
ORDER BY a.recordedAt DESC;
