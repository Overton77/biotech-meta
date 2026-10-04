import hashlib, json, unicodedata, re
def nfcws1(s): return re.sub(r'\s+',' ',unicodedata.normalize('NFC',s)).strip()
def sha(s): return 'sha256:'+hashlib.sha256(s.encode('utf-8')).hexdigest()
def cy(s): return "'" + s.replace('\\','\\\\').replace("'","\\'").replace('\n','\\n') + "'"
EL = "\n[...]\n"
X = {}
X['pmchtml'] = ("Resveratrol, a naturally occurring polyphenol, may increase SIRT1 affinity for NAD+17. Therefore, the NICotinamidE riboside with and without resveratrol to improve functioning in PAD (NICE) clinical trial tested the hypotheses that NR alone improves 6-min walk distance, compared to placebo, and that NR + resveratrol improves 6-min walk distance, compared to placebo, in people with PAD.\nHere we show that NR meaningfully improves 6-min walk, and resveratrol does not add benefit to NR alone in PAD."
  + EL + "Primary outcomes\nCompared to placebo, NR improved 6-min walk by 17.6 meters (90% CI: + 1.77, +∞, P = 0.08) at 6-month follow-up, meeting the pre-specified criterion for statistical significance (Table 2 and Fig. 2A).")
X['pmcxml'] = ("Resveratrol, a naturally occurring polyphenol, may increase SIRT1 affinity for NAD+. Therefore, theotinamidriboside with and without resveratrol to improve functioning in PAD () clinical trial tested the hypotheses that NR alone improves 6-min walk distance, compared to placebo, and that NR + resveratrol improves 6-min walk distance, compared to placebo, in people with PAD.\n\nHere we show that NR meaningfully improves 6-min walk, and resveratrol does not add benefit to NR alone in PAD."
  + EL + "Primary outcomes\n\nCompared to placebo, NR improved 6-min walk by 17.6 meters (90% CI: + 1.77, +∞,= 0.08) at 6-month follow-up, meeting the pre-specified criterion for statistical significance (Tableand Fig.).")
X['pdf'] = ("Resveratrol, a naturally occurring polyphenol, may increase SIRT1\naffinity for NAD+<sup>17</sup>. Therefore, the NICotinamidE riboside with and\nwithout resveratrol to improve functioning in PAD (NICE) clinical trial\ntested the hypotheses that NR alone improves 6-min walk distance,\ncompared to placebo, and that NR + resveratrol improves 6-min walk\ndistance, compared to placebo, in people with PAD.\n\nHere we show that NR meaningfully improves 6-min walk, and\nresveratrol does not add benefit toNR aloneinPAD."
  + EL + "### Primary outcomes\n\nCompared to placebo, NR improved 6-min walk by 17.6 meters (90%\nCI: + 1.77, +∞, P = 0.08) at 6-month follow-up, meeting the pre-specified\ncriterion for statistical significance (Table 2 and Fig. 2A).")
X['hlpage'] = ("David Sinclair:\nWell, I'm always happy to tell you what I do and what my father does. My 82 -year-old father, we take a gram of NMN every day.\nAndrew Huberman:\nSo it's a gram of resveratrol and a gram of NMN.\nDavid Sinclair:\nRight.\nAndrew Huberman:\nOkay. A thousand milligrams.\nDavid Sinclair:\nNow another important point, which is I'm not the same as everybody else. I have different microbiome, age, sex.")
X['yt'] = ("[1:02:45] - Well, I'm always happy to tell you what I do and what my father does, my 82-year-old father, we take a gram of NMN every day.\n[1:02:53] - So it's a gram resveratrol and a gram of NMN. - Right. - Okay a thousand milligrams.\n[1:02:58] - Now another important point, which is, I'm not the same as everybody else.\n[1:03:04] I have a different microbiome, age, sex, right?")
Q = {
 'pmchtml': "Compared to placebo, NR improved 6-min walk by 17.6 meters (90% CI: + 1.77, +∞, P = 0.08) at 6-month follow-up, meeting the pre-specified criterion for statistical significance (Table 2 and Fig. 2A).",
 'pmcxml': "Compared to placebo, NR improved 6-min walk by 17.6 meters (90% CI: + 1.77, +∞,= 0.08) at 6-month follow-up, meeting the pre-specified criterion for statistical significance (Tableand Fig.).",
 'pdf': "Compared to placebo, NR improved 6-min walk by 17.6 meters (90%\nCI: + 1.77, +∞, P = 0.08) at 6-month follow-up, meeting the pre-specified\ncriterion for statistical significance (Table 2 and Fig. 2A).",
 'hlpage': "My 82 -year-old father, we take a gram of NMN every day.",
 'yt': "my 82-year-old father, we take a gram of NMN every day.",
}
P={}
for k in X:
    t=X[k]; q=Q[k]; s=t.index(q); P[k]={'textHash':sha(t),'start':s,'end':s+len(q),'quoteHash':sha(nfcws1(q)),'len':len(t)}
json.dump(P,open('gen04-params.json','w'),indent=1)
meta = {
 'pmchtml': dict(doc='hu:document:pmc-pmc11176364-html', docId='pmc-pmc11176364-html', title='Nicotinamide riboside for peripheral artery disease: the NICE randomized clinical trial (PMC article page)',
                 uri='https://pmc.ncbi.nlm.nih.gov/articles/PMC11176364/', type='SCIENTIFIC_ARTICLE', sk='PEER_REVIEWED_PUBLICATION', fmt='text/html',
                 snap='hu:snapshot:pmc11176364-html-tavily-2026-10-04', tv='hu:text-version:pmc11176364-html-tavily-2026-10-04', tvlabel='pmc-html-tavily-extract-text', src='tavily-extract (advanced, text)',
                 cap='hu:activity:w20f04-capture-tavily', ext='hu:activity:w20f04-extract-tavily', retrieved='2026-10-04T00:58:00Z'),
 'pmcxml': dict(doc='hu:document:pmc-pmc11176364-fulltext-connector', docId='pmc-pmc11176364-fulltext-connector', title='Nicotinamide riboside for peripheral artery disease: the NICE randomized clinical trial (PMC full text via PubMed connector)',
                 uri='mcp:pubmed/get_full_text_article/PMC11176364', type='SCIENTIFIC_ARTICLE', sk='PEER_REVIEWED_PUBLICATION', fmt='application/json',
                 snap='hu:snapshot:pmc11176364-connector-2026-10-04', tv='hu:text-version:pmc11176364-connector-fulltext-2026-10-04', tvlabel='pmc-jats-derived-text-pubmed-mcp', src='pubmed-mcp get_full_text_article (JATS-derived plain text; converter version not disclosed)',
                 cap='hu:activity:w20f04-capture-pubmed-mcp', ext='hu:activity:w20f04-extract-pubmed-mcp', retrieved='2026-10-04T00:57:00Z'),
 'pdf': dict(doc='hu:document:nature-s41467-024-49092-5-pdf', docId='nature-s41467-024-49092-5-pdf', title='Nicotinamide riboside for peripheral artery disease: the NICE randomized clinical trial (publisher PDF)',
                 uri='https://www.nature.com/articles/s41467-024-49092-5.pdf', type='SCIENTIFIC_ARTICLE', sk='PEER_REVIEWED_PUBLICATION', fmt='application/pdf',
                 snap='hu:snapshot:nature-49092-pdf-firecrawl-2026-10-04', tv='hu:text-version:nature-49092-pdf-firecrawl-md-2026-10-04', tvlabel='pdf-firecrawl-markdown-pages-1-3', src='firecrawl pdf parser (markdown; parser version not disclosed)',
                 cap='hu:activity:w20f04-capture-firecrawl', ext='hu:activity:w20f04-extract-firecrawl', retrieved='2026-10-04T01:00:00Z'),
 'hlpage': dict(doc='hu:document:hubermanlab-com-episode-52-page', docId='hubermanlab-com-episode-52-page', title='Dr. David Sinclair: The Biology of Slowing & Reversing Aging',
                 uri='https://www.hubermanlab.com/episode/dr-david-sinclair-the-biology-of-slowing-and-reversing-aging', type='TRANSCRIPT_PAGE', sk='PODCAST_TRANSCRIPT_PAGE', fmt='text/html',
                 snap='hu:snapshot:hubermanlab-52-page-tavily-2026-10-04', tv='hu:text-version:hubermanlab-52-page-tavily-2026-10-04', tvlabel='publisher-transcript-page-tavily-text', src='tavily-extract (basic, text)',
                 cap='hu:activity:w20f04-capture-tavily', ext='hu:activity:w20f04-extract-tavily', retrieved='2026-10-04T01:02:00Z'),
 'yt': dict(doc='hu:document:youtube-n9IxomBusuw-watch-page', docId='youtube-n9IxomBusuw-watch-page', title='The Biology of Slowing & Reversing Aging | Dr. David Sinclair',
                 uri='https://www.youtube.com/watch?v=n9IxomBusuw', type='VIDEO_PAGE', sk='VIDEO_RENDITION', fmt='text/html',
                 snap='hu:snapshot:youtube-n9IxomBusuw-tavily-2026-10-04', tv='hu:text-version:youtube-n9IxomBusuw-transcript-tavily-2026-10-04', tvlabel='youtube-transcript-cues-tavily-text (caption track origin unknown)', src='tavily-extract (advanced, text) of the rendered transcript; auto-generated vs uploaded track NOT established',
                 cap='hu:activity:w20f04-capture-tavily', ext='hu:activity:w20f04-extract-tavily', retrieved='2026-10-04T01:02:30Z'),
}
L=[]; w=L.append
w("// W20 fixture 04: real text-version pairs (NEW_RETRIEVAL 2026-10-04). Snapshots hash the STORED EXCERPT TEXT actually returned by the tools")
w("// (contentHashBasis STORED_EXCERPT_TEXT, captureCompleteness PARTIAL_EXCERPT); '\\n[...]\\n' joins two returned passages and is part of the stored text.")
w("// NiCE trial (PMID 38871717, PMCID PMC11176364, DOI 10.1038/s41467-024-49092-5): PMC HTML vs PubMed-connector JATS-derived text vs publisher PDF text.")
w("// Huberman Lab 52: publisher transcript page vs YouTube transcript cues. No audio was heard; neither text is verified against audio.")
w("// Generated by gen04.py. Every statement binds its own nodes by uid.")
w("MERGE (n:Agent:Entity {uid: 'hu:agent:tavily-extract'}) SET n.entityType = 'Agent', n.name = 'Tavily extract API', n.agentKind = 'AUTOMATED_AGENT', n.toolVersion = 'unknown', n.createdAt = datetime('2026-10-04T01:05:00Z')")
w(";\nMERGE (n:Agent:Entity {uid: 'hu:agent:pubmed-mcp'}) SET n.entityType = 'Agent', n.name = 'PubMed MCP connector', n.agentKind = 'AUTOMATED_AGENT', n.toolVersion = 'unknown', n.createdAt = datetime('2026-10-04T01:05:00Z')")
w(";\nMERGE (n:Agent:Entity {uid: 'hu:agent:firecrawl-pdf'}) SET n.entityType = 'Agent', n.name = 'Firecrawl scrape (pdf parser)', n.agentKind = 'AUTOMATED_AGENT', n.toolVersion = 'unknown', n.createdAt = datetime('2026-10-04T01:05:00Z')")
for uid,kind,ag in [('hu:activity:w20f04-capture-tavily','CAPTURE','hu:agent:tavily-extract'),('hu:activity:w20f04-extract-tavily','TEXT_EXTRACTION','hu:agent:tavily-extract'),
                    ('hu:activity:w20f04-capture-pubmed-mcp','CAPTURE','hu:agent:pubmed-mcp'),('hu:activity:w20f04-extract-pubmed-mcp','TEXT_EXTRACTION','hu:agent:pubmed-mcp'),
                    ('hu:activity:w20f04-capture-firecrawl','CAPTURE','hu:agent:firecrawl-pdf'),('hu:activity:w20f04-extract-firecrawl','TEXT_EXTRACTION','hu:agent:firecrawl-pdf')]:
    w(f";\nMERGE (n:Activity:Occurrence {{uid: '{uid}'}}) SET n.occurrenceType = 'Activity', n.activityKind = '{kind}', n.startedAt = datetime('2026-10-04T00:56:00Z'), n.methodVersion = 'unknown', n.externalRunSystem = 'w20-session', n.createdAt = datetime('2026-10-04T01:05:00Z')")
    w(f";\nMATCH (a:Activity {{uid: '{uid}'}}), (g:Agent {{uid: '{ag}'}}) MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g)")
w(";\nMERGE (p:Publication:InformationArtifact {uid: 'hu:publication:nice-trial-2024-ncomms'}) SET p.artifactType = 'Publication', p.name = 'Nicotinamide riboside for peripheral artery disease: the NICE randomized clinical trial', p.publishedAt = datetime('2024-06-13T00:00:00Z'), p.createdAt = datetime('2026-10-04T01:05:00Z')")
w(";\nMERGE (e:Episode:Entity {uid: 'hu:episode:huberman-lab-52-sinclair'}) SET e.entityType = 'Episode', e.name = 'Huberman Lab 52: Dr. David Sinclair', e.createdAt = datetime('2026-10-04T01:05:00Z')")
for k,m in meta.items():
    t=X[k]; p=P[k]
    work = "(w:Publication {uid: 'hu:publication:nice-trial-2024-ncomms'})" if k in ('pmchtml','pmcxml','pdf') else "(w:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})"
    w(f";\nMERGE (d:Document:Source:Entity {{uid: '{m['doc']}'}})\nSET d.documentId = '{m['docId']}', d.entityType = 'Document', d.title = {cy(m['title'])}, d.canonicalUri = '{m['uri']}', d.url = '{m['uri']}',\n    d.type = '{m['type']}', d.sourceKind = '{m['sk']}', d.fileFormat = '{m['fmt']}', d.languageCode = 'en', d.privacyClass = 'PUBLIC', d.createdAt = datetime('2026-10-04T01:05:00Z'), d.updatedAt = datetime('2026-10-04T01:05:00Z')")
    w(f";\nMATCH (d:Document {{uid: '{m['doc']}'}}), {work} MERGE (d)-[:RENDITION_OF]->(w)")
    w(f";\nMATCH (d:Document {{uid: '{m['doc']}'}}), (act:Activity {{uid: '{m['cap']}'}})\nMERGE (s:SourceSnapshot:InformationArtifact {{uid: '{m['snap']}'}})\nSET s.artifactType = 'SourceSnapshot', s.canonicalUri = d.canonicalUri, s.retrievedAt = datetime('{m['retrieved']}'), s.observedAt = datetime('{m['retrieved']}'),\n    s.contentHash = '{p['textHash']}', s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT', s.mimeType = 'text/plain', s.language = 'en', s.createdAt = datetime('2026-10-04T01:05:00Z')\nMERGE (d)-[:HAS_SNAPSHOT]->(s)\nMERGE (s)-[:WAS_GENERATED_BY]->(act)")
    w(f";\nMATCH (d:Document {{uid: '{m['doc']}'}}), (s:SourceSnapshot {{uid: '{m['snap']}'}}), (act:Activity {{uid: '{m['ext']}'}})\nMERGE (tv:DocumentTextVersion:InformationArtifact {{uid: '{m['tv']}'}})\nSET tv.documentTextVersionId = '{m['tv'].split(':',2)[2]}', tv.artifactType = 'DocumentTextVersion', tv.versionLabel = {cy(m['tvlabel'])}, tv.source = {cy(m['src'])},\n    tv.text = {cy(t)},\n    tv.textVersionHash = '{p['textHash']}', tv.contentHash = '{p['textHash']}', tv.languageCode = 'en', tv.observedAt = s.observedAt, tv.createdAt = datetime('2026-10-04T01:05:00Z'), tv.updatedAt = datetime('2026-10-04T01:05:00Z')\nMERGE (d)-[:HAS_TEXT_VERSION]->(tv)\nMERGE (tv)-[:TEXT_OF_SNAPSHOT]->(s)\nMERGE (tv)-[:WAS_GENERATED_BY]->(act)")
    luid = 'hu:locator:' + m['tv'].split(':',2)[2] + '-q1'
    if k == 'yt':
        w(f";\nMATCH (s:SourceSnapshot {{uid: '{m['snap']}'}}), (tv:DocumentTextVersion {{uid: '{m['tv']}'}})\nMERGE (l:SourceLocator:InformationArtifact {{uid: '{luid}'}})\nSET l.artifactType = 'SourceLocator', l.uri = 'https://www.youtube.com/watch?v=n9IxomBusuw&t=3765s', l.selectorKind = 'MEDIA_TIME',\n    l.exact = {cy(Q[k])}, l.quoteHash = '{p['quoteHash']}', l.normalizationVersion = 'NFC-WS1',\n    l.mediaStartSeconds = 3765.0, l.mediaEndSeconds = 3773.0, l.mediaTimeBasis = 'RENDITION_TRANSCRIPT_CUE', l.createdAt = datetime('2026-10-04T01:05:00Z')\nMERGE (s)-[:HAS_LOCATOR]->(l)")
    else:
        w(f";\nMATCH (s:SourceSnapshot {{uid: '{m['snap']}'}}), (tv:DocumentTextVersion {{uid: '{m['tv']}'}})\nMERGE (l:SourceLocator:InformationArtifact {{uid: '{luid}'}})\nSET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_POSITION',\n    l.exact = {cy(Q[k])}, l.quoteHash = '{p['quoteHash']}', l.normalizationVersion = 'NFC-WS1', l.startOffset = {p['start']}, l.endOffset = {p['end']}, l.createdAt = datetime('2026-10-04T01:05:00Z')\nMERGE (s)-[:HAS_LOCATOR]->(l)\nMERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv)")
open('w20-04-text-version-pairs.cypher','w').write('\n'.join(L).replace('\n;\n',';\n')+";\n")
print(json.dumps(P,indent=1))
