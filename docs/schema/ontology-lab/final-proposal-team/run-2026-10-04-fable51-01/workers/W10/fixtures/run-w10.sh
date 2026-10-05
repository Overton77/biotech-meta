#!/bin/bash
# W10 execution pipeline (as run on 2026-10-04). Usage: run-w10.sh <bolt-uri> <harness-dir> <out-dir>
# Order: baseline constraints -> inherited fixture -> W10 operations (Part A + validators) -> W10 positives ->
#        baseline validation suite + W10 validators -> queries -> GraphQL round trip -> negatives -> validators again.
set -u
B=$1; H=$2; O=$3; R=$(cd "$(dirname "$0")/../../../../../.." && pwd)   # docs/schema
D=$(cd "$(dirname "$0")/.." && pwd); RUN=$(cd "$D/../.." && pwd)
mkdir -p "$O"; cd "$H"
python3 -c "import json;a=json.load(open('$RUN/validation/validation-params.json'));a.update(json.load(open('$D/fixtures/w10-params.json')));json.dump(a,open('$O/all-params.json','w'))"
node run-cypher.mjs $B $R/neo4j/constraints.cypher --json $O/00-constraints.json | tail -1
node run-cypher.mjs $B $R/examples/study-vs-product-mismatch.cypher --json $O/01-inherited.json | tail -1
node run-cypher.mjs $B $D/operations.cypher --params $D/fixtures/w10-params.json --json $O/02-operations-empty.json | tail -1
for f in 01-applicability-basis-13dim 02-dose-ratio-minimal-pair 03-surrogate-context 04-null-primary-synthesis 05-synthesis-versioning; do
  node run-cypher.mjs $B $D/fixtures/w10-$f.cypher --json $O/10-$f.json | tail -1; done
node run-cypher.mjs $B $R/neo4j/validation.cypher --params $O/all-params.json --json $O/20-validation-positives.json | tail -1
node run-cypher.mjs $B $D/operations.cypher --params $D/fixtures/w10-params.json --json $O/21-w10-validators-positives.json | tail -1
node run-cypher.mjs $B $D/fixtures/w10-80-queries.cypher --json $O/30-queries.json | tail -1
cat $D/sdl-fragment.graphql $D/fixtures/w10-test-stubs.graphql > $O/build.graphql
VECTOR_PROVIDER=0 node build-schema.mjs $O/build.graphql $O/generated.graphql | tail -2
cp $D/fixtures/w10-gql-roundtrip.mjs $H/w10-gql-roundtrip.mjs && node w10-gql-roundtrip.mjs $B $O/build.graphql > $O/40-graphql.txt 2>&1
node run-cypher.mjs $B $D/fixtures/w10-90-negatives.cypher --json $O/50-negatives.json | tail -1
node run-cypher.mjs $B $R/neo4j/validation.cypher --params $O/all-params.json --json $O/60-validation-negatives.json | tail -1
node run-cypher.mjs $B $D/operations.cypher --params $D/fixtures/w10-params.json --json $O/61-w10-validators-negatives.json | tail -1
