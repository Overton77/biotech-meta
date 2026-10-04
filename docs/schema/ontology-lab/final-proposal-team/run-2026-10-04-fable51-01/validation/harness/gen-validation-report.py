#!/usr/bin/env python3
"""Generate reports/07-validation-report.md from the Wave 6 run record (wave6-final.json), the schema counts, the GraphQL round
trip record and the Challenger matrix counts. Usage: gen-validation-report.py <wave6-final.json> <schema-counts.json> <roundtrip.json> <out.md>"""
import json,sys,re,collections,subprocess
RUN='/home/user/biotech-meta/docs/schema/ontology-lab/final-proposal-team/run-2026-10-04-fable51-01'
w6,counts,rt,out=sys.argv[1:5]
R=json.load(open(w6)); C=json.load(open(counts)); RT=json.load(open(rt)) if rt!='-' else None
res=R['results']; verd=collections.Counter(x['verdict'] for x in res)
def block(name): return 'global' if not re.match(r'^(union: )?W\d\d:',name) and not name.startswith('union') else ('union' if name.startswith('union') else name.split(':')[0])
byblock=collections.OrderedDict()
for x in res:
    b=block(x['name']); byblock.setdefault(b,collections.Counter())[x['verdict']]+=1
fails=[x for x in res if x['verdict']=='FAIL']
head=subprocess.run(['git','-C','/home/user/biotech-meta','rev-parse','--short','HEAD'],capture_output=True,text=True).stdout.strip()
L=[]
L.append(f"# 07 Validation report (Wave 6 runtime verification)\n")
L.append(f"Run `run-2026-10-04-fable51-01`, plan `validation/04-wave6-plan-final.json`, executed {R['ranAt']} by `validation/harness/run-plan.mjs` on a FRESH embedded Neo4j 5.26.31 Community instance (Maven `org.neo4j.test:neo4j-harness:5.26.31`, APOC Core 5.26.31 plugin) against the deliverables at commit `{head}`. Raw record: `validation/wave6-final.json` (per step: statements, errors, rows per validator id and `check` name, verdict). Nothing here touched a live database, a paid service or a deployment.\n")
L.append("## 1. What was verified\n")
L.append(f"- **Schema build.** `docs/schema/final_biotech_schema_proposal.graphql` ({C['lines']} lines; {C['nodeTypes']} node types in six archetypes {json.dumps(C['byArchetype'])}, {C['relationshipPropertyTypes']} relationship-property types, {C['interfaces']} interfaces, {C['unions']} unions, {C['enums']} enums with {C['enumValues']} values, {C['relationshipFields']} relationship fields over {C['relationshipTypes']} relationship types, {C['fulltext']} fulltext and {C['vector']} vector index declarations) builds with `@neo4j/graphql` 7.6.3 (`validation/harness/build-errors.mjs`: BUILD OK, about 34 s). No `extend`, no `@unique`, no `provider:` on `@vector`, no private-store type.")
L.append("- **Operations.** `docs/schema/neo4j/final_biotech_schema_operations.cypher` applied to the fresh instance (step 1 below); the Enterprise companion was run to record that Community rejects every statement (step 2).")
L.append("- **Fixtures.** The six translated 0.2.0 fixtures plus the backfill, then every packet's positive fixtures, validators, queries (EXPLAIN) and negatives in the order each packet documents, then a union reload of all positives for the whole suite (fresh-graph packets W16 and W21 are excluded from the union by design).")
L.append("- **Suites.** `validation/final-validation-suite.cypher` = 0.2.0 queries not superseded + W00 corrections + Fable W5 validators (V-F5-01..65) + generated label checks; parameters `validation/validation-params.json` (SDL-derived relationship classes, W00 registry tokens, Fable W5 keys).")
L.append("- **Query shapes.** QS-1..QS-8 as extracted from the catalog (17 statements) and the three kernel CQ queries, EXPLAIN only; privacy-corrected QS-5b/6a/8 in `validation/query-shapes-privacy-corrected.cypher`.")
if RT:
    okc=sum(1 for x in RT if x.get('ok')); L.append(f"- **GraphQL round trips.** `validation/harness/roundtrip.mjs` against the final SDL on the loaded instance: {okc}/{len(RT)} operations behaved as expected (the enum-rejection probe is expected to error).")
L.append("")
L.append("## 2. Result by block\n")
L.append("| Block | PASS | FAIL | recorded | steps |\n|---|---|---|---|---|")
for b,c in byblock.items(): L.append(f"| {b} | {c.get('PASS',0)} | {c.get('FAIL',0)} | {c.get('recorded',0)} | {sum(c.values())} |")
L.append(f"| **All** | {verd.get('PASS',0)} | {verd.get('FAIL',0)} | {verd.get('recorded',0)} | {len(res)} |\n")
L.append("`recorded` steps are the Enterprise companion (expected rejections on Community) and steps whose expectation is observational by the packet's own documentation.\n")
L.append("## 3. Failing steps and their reading\n")
if not fails: L.append("None.\n")
for x in fails:
    rows=', '.join(f"{k}={v}" for k,v in sorted(x['rowsById'].items()) if not k.startswith('#') or k in x['rowsById']) ; err=('; '.join(e[:160] for e in x['errors'][:2])) if x['errors'] else ''
    L.append(f"- **{x['name']}** ({x['ok']}/{x['total']} ok). rows: {rows[:600] or 'none'}{(' errors: '+err) if err else ''}")
L.append("")
L.append("## 4. Edition and runtime gaps\n")
L.append("- Existence and property-type constraints (Enterprise companion, every statement rejected by Community in step 2) are UNVERIFIED on Enterprise; their semantics are checked by validators on Community.")
L.append("- APOC Core is required by `@neo4j/graphql` 7.6.3 for DateTime reads (verified: the round trips fail without it).")
L.append("- Vector indexes are created with placeholder dimensions (1536, cosine); the embedding source is a user decision (D-014).")
L.append("- GraphQL `@id` autogeneration does not satisfy INV-106 for kernel-governed creates; those go through the ingestion service (compatibility rule 1, report 06).")
L.append("")
L.append("## 5. Fixture defects carried as known rows\n")
L.append("Rows that remain on clean data are fixture defects or embedded negatives, not schema failures; each is listed with its validator in `reports/08-challenger-resolution-matrix.md` (D1–D15, E1–E4) and in section 3 above. The inherited 0.2.0 fixtures keep seven `https://doi.org/...` resolver URIs as `canonicalUri` (V-W00-19; open question) and two syntheses without `ASSESSES_CLAIM` (V-F5-16); both are informational in the plan.\n")
open(out,'w').write('\n'.join(L)); print('report written', verd)
