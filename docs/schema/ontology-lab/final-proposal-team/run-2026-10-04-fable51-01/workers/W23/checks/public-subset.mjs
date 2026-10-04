// node public-subset.mjs <stub.graphql> <sdl-fragment.graphql> [out.json]
// Derives a PUBLIC_ANSWER read-only sub-schema: drops INTERNAL types (AnswerRecord is exposed only through its
// reproducibility allow-list, modelled here as a separate read type is out of scope, so it is dropped), drops every
// field whose type is a dropped type, drops INTERNAL fields (mongoResearchRunId, privacyClass), disables mutations
// with @mutation(operations: []), then builds the actual Neo4jGraphQL schema.
import { readFileSync, writeFileSync } from "node:fs";
import { parse, print, visit, Kind } from "graphql";
import { Neo4jGraphQL } from "@neo4j/graphql";
const [stubF, fragF, outF] = process.argv.slice(2);
const INTERNAL_TYPES = new Set(["AnswerRecord", "PolicyVersion", "DecisionCriterion", "Activity", "PolicyKind"]);
const INTERNAL_FIELDS = new Set(["mongoResearchRunId", "privacyClass"]);
const doc = parse(readFileSync(stubF, "utf8") + "\n" + readFileSync(fragF, "utf8"));
const named = t => t.kind === Kind.NAMED_TYPE ? t.name.value : named(t.type);
const kept = { ...doc, definitions: doc.definitions.filter(d => !(d.name && INTERNAL_TYPES.has(d.name.value))) };
const pub = visit(kept, {
  FieldDefinition(node) { if (INTERNAL_FIELDS.has(node.name.value) || INTERNAL_TYPES.has(named(node.type))) return null; },
  ObjectTypeDefinition(node) {
    if (node.directives.some(d => d.name.value === "relationshipProperties")) return;
    const mut = { kind: Kind.DIRECTIVE, name: { kind: Kind.NAME, value: "mutation" }, arguments: [{ kind: Kind.ARGUMENT, name: { kind: Kind.NAME, value: "operations" }, value: { kind: Kind.LIST, values: [] } }] };
    return { ...node, directives: [...node.directives.filter(d => d.name.value !== "mutation"), mut] };
  }
});
const sdl = print(pub);
const schema = await new Neo4jGraphQL({ typeDefs: sdl }).getSchema();
const types = Object.keys(schema.getTypeMap());
const res = { build: "ok", leakedInternalTypes: types.filter(t => [...INTERNAL_TYPES].some(i => t === i || t.startsWith(i))),
  mutationFields: schema.getMutationType() ? Object.keys(schema.getMutationType().getFields()) : [],
  queryFields: Object.keys(schema.getQueryType().getFields()),
  privacyClassFieldPresent: /privacyClass/.test(sdl), mongoResearchRunIdPresent: /mongoResearchRunId/.test(sdl) };
if (outF) writeFileSync(outF, JSON.stringify(res, null, 1));
console.log(JSON.stringify(res, null, 1));
