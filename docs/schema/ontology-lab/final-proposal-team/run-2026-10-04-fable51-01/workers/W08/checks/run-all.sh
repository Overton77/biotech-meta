#!/usr/bin/env bash
# W08 reproducible run. Usage: run-all.sh <harness dir with node_modules + run-cypher.mjs> <bolt.uri file> <out dir>
# Requires an EMPTY Neo4j 5.26.x database (the script clears it first). Writes JSON results per step.
set -euo pipefail
H=$1; U=$2; O=$3; mkdir -p "$O"
D=$(cd "$(dirname "$0")/.." && pwd); F=$D/fixtures; RUN=$(cd "$D/../.." && pwd)
cd "$H"
node query.mjs "$(cat "$U")" "MATCH (n) DETACH DELETE n" > /dev/null
for f in w08-platform-vs-instrument w08-device-firmware-assay w08-clearance-and-performance-claim; do
  node run-cypher.mjs "$U" "$F/$f.cypher" --json "$O/load-$f.json" | tail -1
done
node run-cypher.mjs "$U" "$F/w08-validation.cypher" --json "$O/validation-positive.json" | tail -1
node run-cypher.mjs "$U" "$F/w08-queries.cypher" --json "$O/queries-positive.json" | tail -1
node run-cypher.mjs "$U" /home/user/biotech-meta/docs/schema/neo4j/validation.cypher --params "$RUN/validation/validation-params.json" --json "$O/baseline-suite-positive.json" | tail -1
node run-cypher.mjs "$U" "$F/w08-negatives.cypher" --json "$O/load-w08-negatives.json" | tail -1
node run-cypher.mjs "$U" "$F/w08-validation.cypher" --json "$O/validation-with-negatives.json" | tail -1
node run-cypher.mjs "$U" /home/user/biotech-meta/docs/schema/neo4j/validation.cypher --params "$RUN/validation/validation-params.json" --json "$O/baseline-suite-with-negatives.json" | tail -1
