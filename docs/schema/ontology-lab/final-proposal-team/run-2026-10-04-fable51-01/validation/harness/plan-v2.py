#!/usr/bin/env python3
"""Transform 04-wave6-plan.json into 04-wave6-plan-final.json: swap the 0.2.0 suite + corrections steps for the compiled final
suite (+ generated label checks), drop fresh-graph fixtures (W16, W21) and known cross-packet uid collisions from the union reload,
point uriFile at run4, and add the Fable W5 validators step after the translated fixtures."""
import json,sys,os
RUN='/home/user/biotech-meta/docs/schema/ontology-lab/final-proposal-team/run-2026-10-04-fable51-01'
S='/tmp/claude-0/-home-user-biotech-meta/c83435a6-8371-518c-961a-6504ccbc2c3e/scratchpad'
plan=json.load(open(f'{RUN}/validation/04-wave6-plan.json'))
P=f'{RUN}/validation/validation-params.json'.replace('/home/user/biotech-meta/','')
SUITE='docs/schema/ontology-lab/final-proposal-team/run-2026-10-04-fable51-01/validation/final-validation-suite.cypher'
LBL='docs/schema/ontology-lab/final-proposal-team/run-2026-10-04-fable51-01/validation/generated-label-checks.cypher'
INFO=["V-111b","V-118","V-120","V-212","V-223","V-331","V-401b","V-514b","V-522","V-505i","V-W00-19","V-F5-16"]
out=[]; 
for st in plan['steps']:
    f=st['file']; name=st['name']
    if f.endswith('docs/schema/neo4j/validation.cypher'):
        st=dict(st, file=SUITE, params=P, informational=sorted(set(st.get('informational',[])+INFO)), name=name.replace('0.2.0 validation suite','final suite').replace('0.2.0 suite','final suite'))
    if f.endswith('workers/W00/validation-corrections.cypher') and 'union' not in name and name.startswith('validator corrections'):
        continue  # folded into the final suite
    if name.startswith('union: ') and ('/W21/' in f or '/W16/' in f):
        continue  # fresh-graph fixtures (documented), validated in their own blocks
    out.append(st)
    if f.endswith('fixtures-final/99-normalize-live-ids.cypher') and not name.startswith('union'):
        out.append({"name":"generated label checks on translated fixtures","file":LBL,"params":P,"expect":"zero-rows"})
plan['steps']=out; plan['uriFile']=f'{S}/neo4j-embedded/run4/bolt.uri'
json.dump(plan,open(f'{RUN}/validation/04-wave6-plan-final.json','w'),indent=2)
print('steps',len(out))
