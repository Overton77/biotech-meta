# Validation harness (pinned)

- `build-schema.mjs <sdl> [out]` builds the actual Neo4jGraphQL generated schema (`@neo4j/graphql` 7.6.3, `graphql` 16.14.2). `VECTOR_PROVIDER=0` disables the placeholder vector-provider feature config.
- `run-cypher.mjs <bolt-uri-or-file> <file.cypher> [--db neo4j] [--params p.json] [--explain] [--json out.json]` splits on `;` outside strings/comments, runs each statement in its own transaction, never shares variables across statements, records rows/counters/errors per statement.
- `query.mjs <uri> "<cypher>" [db]` ad hoc query.
- `EmbeddedNeo4j.java` + `pom.xml`: in-process Neo4j 5.26.31 Community through `org.neo4j.test:neo4j-harness` (bolt only, HTTP server disabled); writes `bolt.uri`; stops when a `STOP` file appears.

Install: `npm i @neo4j/graphql@7.6.3 graphql@16 neo4j-driver@6` and `mvn dependency:copy-dependencies -DoutputDirectory=lib`; `javac -cp "lib/*" -d classes EmbeddedNeo4j.java`; `java -cp "classes:lib/*" EmbeddedNeo4j run`.
