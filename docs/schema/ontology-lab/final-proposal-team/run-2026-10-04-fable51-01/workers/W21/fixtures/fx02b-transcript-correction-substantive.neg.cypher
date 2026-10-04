// fx02b NEGATIVE injection.
// N02-c: the successor no longer re-anchors the prior citation (prior citation lost from the correction chain)
// -> V-W21-08 row. (Removing the SUPERSEDES edge instead is caught by the baseline V-109 and V-506.)
MATCH (:SourceLocator {uid: 'hu:locator:synthetic-hl52-page-reviewed-nmn-half-gram'})-[r:REANCHORS]->(:SourceLocator {uid: 'hu:locator:hl52-page-nmn-gram-daily'})
DELETE r;
