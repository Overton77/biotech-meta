// fx02a NEGATIVE injections.
// N02-a: "update in place": the old locator is re-hung on the new snapshot -> V-404 row (its text version derives
// from the old snapshot) and the prior citation is no longer reproducible against the 2026-10-03 hash.
MATCH (s1:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-03'})-[h:HAS_LOCATOR]->(l:SourceLocator {uid: 'hu:locator:hl52-page-nmn-gram-daily'}),
      (s2:SourceSnapshot {uid: 'hu:snapshot:synthetic-hubermanlab-52-page-reviewed-2026-11-15'})
DELETE h
MERGE (s2)-[:HAS_LOCATOR]->(l);

// N02-b: REANCHORS written old -> new -> V-409 row.
MATCH (old:SourceLocator {uid: 'hu:locator:hl52-page-nmn-gram-daily'}), (n:SourceLocator {uid: 'hu:locator:synthetic-hl52-page-reviewed-nmn-gram-daily'})
MERGE (old)-[r:REANCHORS]->(n) SET r.anchorMatch = 'FUZZY';
