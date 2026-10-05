// =====================================================================================================
// W21 fixture fx04: a practice report with two qualifications versus retellings (round 0006 pairs 22, 28;
// CQ-CL-02/03/04/06, CQ-PV-05, CQ-AX-05, CQ-RC-05).
//   A1 (real): guest's practice report "we take a gram of NMN every day" (REPORTS_PRACTICE, PERSONAL_EXPERIENCE);
//   Q1 (real): "I'm not the same as everybody else ..." (INDIVIDUAL_VARIATION); Q2 (real): "what I do may not
//   perfectly, or work at all for others" (HEDGE) -- each its own occurrence with its own locator;
//   R1 (SYNTHETIC, inherited round 0006 text): digest says Sinclair "recommends taking a gram of NMN every morning to
//   slow aging" (speechAct STATES, reportedSpeechAct RECOMMENDS);
//   R2 (real, NMN.com, PARTIAL capture): "Dr. Sinclair personally takes a precursor to NAD+ called NMN" with a
//   "Story Source" citation naming a 2023 "Huberman Lab Essentials" video that does not resolve to a captured work.
// Expected: independent first-hand support for "Sinclair takes ~1 g NMN/day" stays 1 after both retellings;
// no RECOMMENDS edge exists; qualification loss lives only on RetellingFidelityAssessments.
// =====================================================================================================
MERGE (n:Entity:Person {uid: 'hu:person:david-a-sinclair'})
SET n.id = 'david-a-sinclair', n.entityType = 'Person', n.name = 'David A. Sinclair', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Person {uid: 'hu:person:synthetic-digest-author'})
SET n.id = 'synthetic-digest-author', n.entityType = 'Person', n.name = 'Synthetic Digest Author (fixture only)', n.fixtureProvenance = 'SYNTHETIC', n.createdAt = datetime('2026-10-04T01:00:00Z');
// The NMN.com article's author/operator was not established in the capture; the outlet is recorded as the asserter.
MERGE (n:Entity:Organization {uid: 'hu:org:nmn-com-publisher'})
SET n.id = 'nmn-com-publisher', n.entityType = 'Organization', n.name = 'Publisher of nmn.com (legal entity not established)', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'})
SET n.id = 'nicotinamide-mononucleotide', n.entityType = 'ChemicalSubstance', n.name = 'Nicotinamide mononucleotide', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
SET n.id = 'huberman-lab-52-sinclair', n.entityType = 'Episode', n.name = 'The Biology of Slowing & Reversing Aging | Dr. David Sinclair', n.episodeNumber = 52,
    n.publishedAt = datetime('2021-12-27T09:00:00Z'), n.publishedAtPrecision = 'INSTANT', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Claim {uid: 'hu:claim:sinclair-reports-taking-1g-nmn-daily'})
SET n.id = 'sinclair-reports-taking-1g-nmn-daily', n.entityType = 'Claim', n.claimText = 'David A. Sinclair reports taking about 1 g of NMN per day.', n.claimType = 'DOSING_CLAIM', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Claim {uid: 'hu:claim:1g-nmn-daily-slows-aging'})
SET n.id = '1g-nmn-daily-slows-aging', n.entityType = 'Claim', n.claimText = 'Taking 1 g of NMN daily slows aging.', n.claimType = 'EFFICACY_CLAIM', n.isCausal = true, n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Agent {uid: 'hu:agent:w21-curator'})
SET n.id = 'w21-curator', n.entityType = 'Agent', n.name = 'W21 fixture curator (Opus 5.5)', n.agentKind = 'MANUAL_AGENT', n.createdAt = datetime('2026-10-04T01:00:00Z');
MATCH (g:Agent {uid: 'hu:agent:w21-curator'})
MERGE (a:Occurrence:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'})
SET a.id = 'w21-extraction-2026-10-04', a.occurrenceType = 'Activity', a.activityKind = 'EXTRACTION', a.methodVersion = 'w21-manual-curation-v0.1', a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

// ---- Sources and snapshots ---------------------------------------------------------------------------------
MERGE (n:Entity:Source:Document {uid: 'hu:source:hubermanlab-com-episode-52'})
SET n.id = 'hubermanlab-com-episode-52', n.documentId = 'hubermanlab-com-episode-52', n.entityType = 'Source',
    n.canonicalUri = 'https://www.hubermanlab.com/episode/dr-david-sinclair-the-biology-of-slowing-and-reversing-aging', n.sourceKind = 'PODCAST_TRANSCRIPT_PAGE', n.type = 'WEBPAGE', n.createdAt = datetime('2026-10-04T01:00:00Z');
MATCH (s:Source {uid: 'hu:source:hubermanlab-com-episode-52'}), (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}) MERGE (s)-[:RENDITION_OF]->(e);
MATCH (src:Source {uid: 'hu:source:hubermanlab-com-episode-52'})
MERGE (s:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-04'})
SET s.id = 'hubermanlab-52-page-2026-10-04', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri, s.retrievedAt = datetime('2026-10-04T00:49:30Z'), s.observedAt = datetime('2026-10-04T00:49:30Z'),
    s.contentHash = 'sha256:19e3e32cbaca1a127bebb1404237659509bd64e97066577208b25bc71278511e', s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT', s.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);

MERGE (n:Entity:Source:Document {uid: 'hu:source:synthetic-longevity-digest-issue-1'})
SET n.id = 'synthetic-longevity-digest-issue-1', n.documentId = 'synthetic-longevity-digest-issue-1', n.entityType = 'Source', n.canonicalUri = 'https://longevity-digest.example.invalid/issue-1',
    n.title = 'Synthetic Longevity Digest, issue 1 (fixture only)', n.sourceKind = 'NEWSLETTER', n.type = 'BLOG_POST', n.fixtureProvenance = 'SYNTHETIC', n.createdAt = datetime('2026-10-04T01:00:00Z');
MATCH (src:Source {uid: 'hu:source:synthetic-longevity-digest-issue-1'})
MERGE (s:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:synthetic-digest-issue-1-2026-10-04'})
SET s.id = 'synthetic-digest-issue-1-2026-10-04', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri, s.retrievedAt = datetime('2026-10-04T00:00:00Z'), s.observedAt = datetime('2026-10-04T00:00:00Z'),
    s.contentHash = 'sha256:8ce840f01f650b3451dea17970f7b254671f80f807ac418c7c00590f227e7a04', s.contentHashBasis = 'SYNTHETIC_FIXTURE', s.captureCompleteness = 'COMPLETE', s.fixtureProvenance = 'SYNTHETIC', s.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);

// sourceKind for a single-topic news article is not cleanly in the catalog list (seam W21-SR-13); NEWSLETTER is the
// closest listed value and is flagged as such.
MERGE (n:Entity:Source:Document {uid: 'hu:source:nmn-com-huberman-lab-essentials-sinclair'})
SET n.id = 'nmn-com-huberman-lab-essentials-sinclair', n.documentId = 'nmn-com-huberman-lab-essentials-sinclair', n.entityType = 'Source',
    n.canonicalUri = 'https://www.nmn.com/news/huberman-lab-essentials-the-biology-of-slowing-reversing-aging-with-david-sinclair',
    n.title = 'Huberman Lab Essentials: “The Biology of Slowing & Reversing Aging” with David Sinclair', n.sourceKind = 'NEWSLETTER', n.type = 'NEWS_ARTICLE', n.createdAt = datetime('2026-10-04T01:00:00Z');
MATCH (src:Source {uid: 'hu:source:nmn-com-huberman-lab-essentials-sinclair'})
MERGE (s:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:nmn-com-huberman-lab-essentials-sinclair-2026-10-04'})
SET s.id = 'nmn-com-huberman-lab-essentials-sinclair-2026-10-04', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri, s.retrievedAt = datetime('2026-10-04T00:58:00Z'),
    s.observedAt = datetime('2026-10-04T00:58:00Z'), s.publishedAt = NULL,
    s.contentHash = 'sha256:4eaf763865a40cf1c9300e4b05e6aeba66e29119ff8b942a4487f75d15a20f77', s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT',
    s.storageUri = 'repo:workers/W21/excerpts/nmncom-essentials-2026-10-04.txt', s.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);

// ---- Locators ------------------------------------------------------------------------------------------------
UNWIND [
  {u: 'hu:locator:w21-hl52-page-nmn-gram-daily', i: 'w21-hl52-page-nmn-gram-daily', x: 'My 82 -year-old father, we take a gram of NMN every day.', h: 'sha256:96fe6eb5c9177e4e2c18035be1bd8bfce8f7325882994ff8274de98cf4516e56'},
  {u: 'hu:locator:w21-hl52-page-not-same-as-everybody', i: 'w21-hl52-page-not-same-as-everybody', x: "Now another important point, which is I'm not the same as everybody else. I have different microbiome, age, sex.", h: "sha256:3b3b6b061f0b29b0d46c261494eddb3f9d52b6aaeda77d013713c7d09be86656"},
  {u: 'hu:locator:w21-hl52-page-may-not-work-for-others', i: 'w21-hl52-page-may-not-work-for-others', x: 'So I just want people to be aware that what I do may not perfectly, or work at all for others.', h: 'sha256:d194845a360e2bd8a0e3572e5b077e59913710631ff51342568035a018fb07e1'}
] AS row
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: row.u})
SET l.id = row.i, l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.exact = row.x, l.quoteHash = row.h,
    l.normalizationVersion = 'NFC-WS1', l.speakerLabelInSource = 'David Sinclair', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:synthetic-digest-issue-1-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:synthetic-digest-retelling'})
SET l.id = 'synthetic-digest-retelling', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'Harvard geneticist David Sinclair recommends taking a gram of NMN every morning to slow aging.',
    l.quoteHash = 'sha256:c1cd687f504b3172a8b0e76ddca1208eec9b3cb2b6d9d949c7191efb918ed099',
    l.normalizationVersion = 'NFC-WS1', l.fixtureProvenance = 'SYNTHETIC', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:nmn-com-huberman-lab-essentials-sinclair-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-nmncom-sinclair-personally-takes-nmn'})
SET l.id = 'w21-nmncom-sinclair-personally-takes-nmn', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'Dr. Sinclair personally takes a precursor to NAD+ called NMN (nicotinamide mononucleotide).',
    l.quoteHash = 'sha256:8394dcfcc07cc56cb8a269d1f043053211740b761d62c092f00ddf82bb3eb28b',
    l.section = 'The Role of Supplements: NMN and NAD+', l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:nmn-com-huberman-lab-essentials-sinclair-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-nmncom-story-source-citation'})
SET l.id = 'w21-nmncom-story-source-citation', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'Huberman, A. & Sinclair, D. (2023). Huberman Lab Essentials: Dr. David Sinclair – The Science of Aging, Longevity, and Actionable Protocols. YouTube.',
    l.quoteHash = 'sha256:0b8e9c03247af29c61f889ce5fb8d5dfa810b116058e38049844b12122f69234',
    l.section = 'Story Source', l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

// ---- The original practice report and its two qualifications -------------------------------------------
MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}), (nmn:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'}),
      (l:SourceLocator {uid: 'hu:locator:w21-hl52-page-nmn-gram-daily'}), (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'}), (c:Claim {uid: 'hu:claim:sinclair-reports-taking-1g-nmn-daily'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-sinclair-nmn-1g-daily'})
SET a.id = 'w21-hl52-sinclair-nmn-1g-daily', a.predicate = 'SELF_REPORTED_DAILY_INTAKE', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.assertionBasis = 'PERSONAL_EXPERIENCE',
    a.speechAct = 'REPORTS_PRACTICE', a.valueNumber = 1.0, a.unitCode = 'g', a.quantityBasis = 'PER_DAY', a.utteranceText = l.exact, a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(nmn)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[i:INSTANCE_OF]->(c) SET i.derivationRule = 'w21-manual-proposition-match-v0.1';

UNWIND [
  {u: 'hu:claim-occurrence:w21-hl52-sinclair-not-same-as-everybody', i: 'w21-hl52-sinclair-not-same-as-everybody', l: 'hu:locator:w21-hl52-page-not-same-as-everybody',
   p: 'STATES_INDIVIDUAL_DIFFERENCE', v: 'different microbiome, age, sex', k: 'INDIVIDUAL_VARIATION', r: 'hu:rel:w21-qualified-by-nmn-individual-variation', o: 1},
  {u: 'hu:claim-occurrence:w21-hl52-sinclair-may-not-work-for-others', i: 'w21-hl52-sinclair-may-not-work-for-others', l: 'hu:locator:w21-hl52-page-may-not-work-for-others',
   p: 'STATES_INDIVIDUAL_DIFFERENCE', v: 'what I do may not work at all for others', k: 'HEDGE', r: 'hu:rel:w21-qualified-by-nmn-hedge', o: 2}
] AS row
MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}), (l:SourceLocator {uid: row.l}),
      (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'}), (a1:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-sinclair-nmn-1g-daily'})
MERGE (q:Assertion:ClaimOccurrence {uid: row.u})
SET q.id = row.i, q.predicate = row.p, q.status = 'ACCEPTED', q.polarity = 'POSITIVE', q.assertionBasis = 'UNSTATED', q.speechAct = 'CAUTIONS', q.valueString = row.v,
    q.utteranceText = l.exact, q.validFromBasis = 'UNKNOWN', q.validToBasis = 'UNKNOWN', q.recordedAt = datetime('2026-10-04T01:00:00Z'), q.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (q)-[:HAS_SUBJECT]->(sp)
MERGE (q)-[:ASSERTED_BY]->(sp)
MERGE (q)-[:OCCURS_IN]->(ep)
MERGE (q)-[:SUPPORTED_BY]->(l)
MERGE (q)-[:WAS_GENERATED_BY]->(act)
MERGE (a1)-[x:QUALIFIED_BY]->(q)
SET x.qualificationKind = row.k, x.relationshipUid = row.r, x.orderIndex = row.o;

// ---- R1: SYNTHETIC retelling that turns the practice report into a recommendation --------------------------
MATCH (au:Person {uid: 'hu:person:synthetic-digest-author'}), (sp:Person {uid: 'hu:person:david-a-sinclair'}), (doc:Source {uid: 'hu:source:synthetic-longevity-digest-issue-1'}),
      (nmn:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'}), (l:SourceLocator {uid: 'hu:locator:synthetic-digest-retelling'}),
      (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'}), (c:Claim {uid: 'hu:claim:1g-nmn-daily-slows-aging'})
MERGE (r:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:synthetic-digest-says-sinclair-recommends-nmn'})
SET r.id = 'synthetic-digest-says-sinclair-recommends-nmn', r.predicate = 'RECOMMENDS_DAILY_INTAKE', r.status = 'ACCEPTED', r.polarity = 'POSITIVE',
    r.assertionBasis = 'EXPERT_OPINION', r.speechAct = 'STATES', r.reportedSpeechAct = 'RECOMMENDS', r.valueNumber = 1.0, r.unitCode = 'g', r.quantityBasis = 'PER_DAY',
    r.utteranceText = l.exact, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.fixtureProvenance = 'SYNTHETIC',
    r.recordedAt = datetime('2026-10-04T01:00:00Z'), r.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (r)-[:HAS_SUBJECT]->(nmn)
MERGE (r)-[:ASSERTED_BY]->(au)
MERGE (r)-[:ATTRIBUTES_TO]->(sp)
MERGE (r)-[:OCCURS_IN]->(doc)
MERGE (r)-[:SUPPORTED_BY]->(l)
MERGE (r)-[:WAS_GENERATED_BY]->(act)
MERGE (r)-[i:INSTANCE_OF]->(c) SET i.derivationRule = 'w21-manual-proposition-match-v0.1';

// ---- R2: real NMN.com retelling (partial capture); practice preserved, amount absent --------------------
MATCH (pub:Organization {uid: 'hu:org:nmn-com-publisher'}), (sp:Person {uid: 'hu:person:david-a-sinclair'}), (doc:Source {uid: 'hu:source:nmn-com-huberman-lab-essentials-sinclair'}),
      (nmn:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'}), (l:SourceLocator {uid: 'hu:locator:w21-nmncom-sinclair-personally-takes-nmn'}),
      (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'}), (c:Claim {uid: 'hu:claim:sinclair-reports-taking-1g-nmn-daily'})
MERGE (r:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-nmncom-says-sinclair-takes-nmn'})
SET r.id = 'w21-nmncom-says-sinclair-takes-nmn', r.predicate = 'SELF_REPORTED_DAILY_INTAKE', r.status = 'ACCEPTED', r.polarity = 'POSITIVE',
    r.assertionBasis = 'THIRD_PARTY_ANECDOTE', r.speechAct = 'STATES', r.reportedSpeechAct = 'REPORTS_PRACTICE', r.valueString = 'takes NMN (amount not stated in the captured excerpt)',
    r.utteranceText = l.exact, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedAt = datetime('2026-10-04T01:00:00Z'), r.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (r)-[:HAS_SUBJECT]->(nmn)
MERGE (r)-[:ASSERTED_BY]->(pub)
MERGE (r)-[:ATTRIBUTES_TO]->(sp)
MERGE (r)-[:OCCURS_IN]->(doc)
MERGE (r)-[:SUPPORTED_BY]->(l)
MERGE (r)-[:WAS_GENERATED_BY]->(act)
MERGE (r)-[i:INSTANCE_OF]->(c) SET i.derivationRule = 'w21-manual-proposition-match-v0.1';

// ---- Retelling links: both are BellLabs matches backed by hypotheses ------------------------------------
MATCH (r:Assertion {uid: 'hu:claim-occurrence:synthetic-digest-says-sinclair-recommends-nmn'}), (o:Assertion {uid: 'hu:claim-occurrence:w21-hl52-sinclair-nmn-1g-daily'})
MERGE (h:EvidenceAssessment:ResolutionHypothesis {uid: 'hu:resolution:w21-retelling-source-synthetic-digest-to-hl52-nmn'})
SET h.id = 'w21-retelling-source-synthetic-digest-to-hl52-nmn', h.assessmentType = 'ResolutionHypothesis', h.resolutionType = 'RETELLING_SOURCE', h.resolutionStatus = 'PROPOSED',
    h.rationale = 'Same speaker, substance, amount and daily schedule; the retelling cites no source.', h.methodVersion = 'w21-manual-curation-v0.1', h.status = 'PROPOSED',
    h.recordedAt = datetime('2026-10-04T01:00:00Z'), h.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (h)-[:PROPOSES_MATCH]->(o)
MERGE (h)-[:PROPOSES_MATCH]->(r)
MERGE (r)-[x:RETELLS]->(o)
SET x.retellingMode = 'PARAPHRASE', x.linkBasis = 'BELLLABS_MATCH', x.hypothesisUid = h.uid, x.relationshipUid = 'hu:rel:w21-retells-synthetic-digest-hl52-nmn';

MATCH (r:Assertion {uid: 'hu:claim-occurrence:w21-nmncom-says-sinclair-takes-nmn'}), (o:Assertion {uid: 'hu:claim-occurrence:w21-hl52-sinclair-nmn-1g-daily'}),
      (cl:SourceLocator {uid: 'hu:locator:w21-nmncom-story-source-citation'})
MERGE (h:EvidenceAssessment:ResolutionHypothesis {uid: 'hu:resolution:w21-retelling-source-nmncom-to-hl52-nmn'})
SET h.id = 'w21-retelling-source-nmncom-to-hl52-nmn', h.assessmentType = 'ResolutionHypothesis', h.resolutionType = 'RETELLING_SOURCE', h.resolutionStatus = 'PROPOSED',
    h.rationale = 'The article cites "Huberman Lab Essentials ... (2023) YouTube"; that title/year matches neither the 2025-10-30 Essentials feed item nor episode 52, and the cited video was not captured. Matched to the episode 52 practice report by speaker and substance; the Essentials cut may be the actual source.',
    h.methodVersion = 'w21-manual-curation-v0.1', h.status = 'PROPOSED', h.recordedAt = datetime('2026-10-04T01:00:00Z'), h.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (h)-[:PROPOSES_MATCH]->(o)
MERGE (h)-[:PROPOSES_MATCH]->(r)
MERGE (r)-[x:RETELLS]->(o)
SET x.retellingMode = 'PARAPHRASE', x.linkBasis = 'BELLLABS_MATCH', x.hypothesisUid = h.uid, x.citationLocatorUid = cl.uid,
    x.relationshipUid = 'hu:rel:w21-retells-nmncom-hl52-nmn';

// ---- Fidelity assessments (loss is a property of the comparison) -----------------------------------------
MATCH (r:Assertion {uid: 'hu:claim-occurrence:synthetic-digest-says-sinclair-recommends-nmn'}), (o:Assertion {uid: 'hu:claim-occurrence:w21-hl52-sinclair-nmn-1g-daily'}),
      (q1:Assertion {uid: 'hu:claim-occurrence:w21-hl52-sinclair-not-same-as-everybody'}), (q2:Assertion {uid: 'hu:claim-occurrence:w21-hl52-sinclair-may-not-work-for-others'}),
      (cur:Agent {uid: 'hu:agent:w21-curator'})
MERGE (f:EvidenceAssessment:RetellingFidelityAssessment {uid: 'hu:assessment:w21-retelling-fidelity-synthetic-digest-vs-hl52-nmn'})
SET f.id = 'w21-retelling-fidelity-synthetic-digest-vs-hl52-nmn', f.assessmentType = 'RetellingFidelityAssessment', f.methodVersion = 'retelling-fidelity-v0.1', f.status = 'PROPOSED',
    f.qualificationLost = true, f.lostQualificationKinds = ['INDIVIDUAL_VARIATION', 'HEDGE'], f.speechActChanged = true, f.speechActFrom = 'REPORTS_PRACTICE', f.speechActTo = 'RECOMMENDS',
    f.assertionBasisChanged = true, f.scopeBroadened = true, f.addedPurposeText = 'to slow aging', f.quantityChanged = false, f.attributionChanged = false, f.correctionIgnored = false,
    f.recordedAt = datetime('2026-10-04T01:00:00Z'), f.assessedAt = datetime('2026-10-04T01:00:00Z'), f.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (f)-[:ASSESSES_RETELLING]->(r)
MERGE (f)-[:AGAINST_ORIGINAL]->(o)
MERGE (f)-[:IDENTIFIES_LOST_QUALIFICATION]->(q1)
MERGE (f)-[:IDENTIFIES_LOST_QUALIFICATION]->(q2)
MERGE (f)-[:ASSESSED_BY]->(cur);

// The NMN.com capture is partial: whether its full text carries the caveats is NOT assessed (null), not "faithful".
MATCH (r:Assertion {uid: 'hu:claim-occurrence:w21-nmncom-says-sinclair-takes-nmn'}), (o:Assertion {uid: 'hu:claim-occurrence:w21-hl52-sinclair-nmn-1g-daily'}), (cur:Agent {uid: 'hu:agent:w21-curator'})
MERGE (f:EvidenceAssessment:RetellingFidelityAssessment {uid: 'hu:assessment:w21-retelling-fidelity-nmncom-vs-hl52-nmn'})
SET f.id = 'w21-retelling-fidelity-nmncom-vs-hl52-nmn', f.assessmentType = 'RetellingFidelityAssessment', f.methodVersion = 'retelling-fidelity-v0.1', f.status = 'PROPOSED',
    f.qualificationLost = NULL, f.speechActChanged = false, f.speechActFrom = 'REPORTS_PRACTICE', f.speechActTo = 'REPORTS_PRACTICE', f.assertionBasisChanged = NULL,
    f.scopeBroadened = NULL, f.quantityChanged = NULL, f.attributionChanged = false, f.correctionIgnored = NULL,
    f.summary = 'Partial capture: amount and caveats not present in the captured excerpt; their absence in the full article is not established.',
    f.recordedAt = datetime('2026-10-04T01:00:00Z'), f.assessedAt = datetime('2026-10-04T01:00:00Z'), f.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (f)-[:ASSESSES_RETELLING]->(r)
MERGE (f)-[:AGAINST_ORIGINAL]->(o)
MERGE (f)-[:ASSESSED_BY]->(cur);

MATCH (a:Assertion) WHERE a.status IN ['ACCEPTED', 'REJECTED', 'DISPUTED']
MERGE (j:EvidenceAssessment:Adjudication {uid: 'hu:adjudication:w21-fx04-capture-fidelity-policy'})
ON CREATE SET j.id = 'w21-fx04-capture-fidelity-policy', j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
    j.reviewerType = 'POLICY', j.methodVersion = 'w21-fixture-capture-policy-1', j.status = 'ACCEPTED', j.reviewedAt = datetime('2026-10-04T01:30:00Z'),
    j.recordedAt = datetime('2026-10-04T01:30:00Z'), j.createdAt = datetime('2026-10-04T01:30:00Z'), j.privacyClass = 'internal'
MERGE (j)-[:EVALUATES]->(a);
