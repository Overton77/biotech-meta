#!/usr/bin/env bash
# W23 reproducible runner. Usage: HARNESS=<dir with run-cypher.mjs, query.mjs, node_modules, run/bolt.uri> bash run-all.sh
# Target: embedded Neo4j 5.26.31 Community from ../../../validation/harness (EmbeddedNeo4j.java). Disposable database only:
# every scenario starts with fixtures/reset.cypher (MATCH (n) DETACH DELETE n; drop the W23 leak index).
set -euo pipefail
W="$(cd "$(dirname "$0")/.." && pwd)"; F="$W/fixtures"; R="$F/results"; V="$W/../../validation"
SCHEMA="$(cd "$W/../../../../.." && pwd)"   # docs/schema
H="${HARNESS:?set HARNESS}"; B="$H/run/bolt.uri"; cd "$H"
run() { node run-cypher.mjs "$B" "$@"; }
summ() { python3 - "$1" "$2" <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))
out={'file':d['file'],'total':d['total'],'ok':d['ok'],'failed':d['failed'],'rowsByStatement':[{'n':r['n'],'id':r.get('id'),'title':r['header'].split('\n')[0][3:90],'status':r['status'],'rows':r.get('rows'),'error':r.get('error'),'sample':r.get('sample',[])[:5]} for r in d['results'] if r['status']!='ok' or r.get('rows',0)>0]}
json.dump(out,open(sys.argv[2],'w'),indent=1,default=str)
PY
}
scenario() { # name, extra fixture files...
  local n="$1"; shift
  run "$F/reset.cypher" >/dev/null; run "$F/00-shared-base.cypher" --json "$R/$n-load-00.json"
  for f in "$@"; do run "$F/$f" --json "$R/$n-load-$(basename "$f" .cypher).json"; done
}
validate() { # name, params
  run "$SCHEMA/neo4j/validation.cypher" --params "$2" --json "$H/$1-validation.json" >/dev/null; summ "$H/$1-validation.json" "$R/$1-validation-summary.json"
  run "$F/validation-w23.cypher" --json "$H/$1-w23.json" >/dev/null; summ "$H/$1-w23.json" "$R/$1-w23-summary.json"
}
scenario S1; validate S1 "$V/validation-params.json"
run "$F/01-answer-record-replay.cypher" --json "$R/S1-01-answer-record-replay.json"
run "$F/02-public-projection.cypher" --json "$R/S1-02-public-projection.json"
run "$F/03-decision-replay-after-correction.cypher" --params "$F/replay-params.json" --json "$R/S1-03-decision-replay-after-correction.json"
scenario S2 04-uid-redirect.cypher; validate S2 "$V/validation-params.json"
scenario S3 10-leak-probe-qs6.cypher; validate S3 "$F/params-leak.json"
run "$F/10-leak-probe-queries.cypher" --json "$R/S3-10-leak-probe-queries.json"
scenario S4 11-public-person-only.cypher; validate S4 "$V/validation-params.json"
scenario S5 12-answer-record-negative.cypher; validate S5 "$V/validation-params.json"
scenario S6 13-use-authorization-negative.cypher; validate S6 "$V/validation-params.json"
run "$F/13-fail-open-queries.cypher" --json "$R/S6-13-fail-open-queries.json"
run "$F/reset.cypher" >/dev/null
echo "W23 run-all complete"
