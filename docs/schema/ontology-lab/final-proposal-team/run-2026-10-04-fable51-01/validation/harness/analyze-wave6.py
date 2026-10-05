#!/usr/bin/env python3
"""Aggregate the Wave 6 record: for every FAIL step, which validator keys fired, in which blocks; emit a triage table."""
import json,sys,re,collections
R=json.load(open(sys.argv[1])); res=R['results']
byid=collections.defaultdict(lambda: {'steps':0,'rows':0,'blocks':set()})
def block(n): m=re.match(r'^(union: )?(W\d\d):',n); return (m.group(2)+('(u)' if m.group(1) else '')) if m else ('union' if n.startswith('union') else 'global')
for x in res:
    if x['verdict']!='FAIL': continue
    info=set(x.get('informational',[]))
    for k,v in x['rowsById'].items():
        if k.startswith('#'): continue
        byid[k]['steps']+=1; byid[k]['rows']+=v; byid[k]['blocks'].add(block(x['name']))
    for e in x['errors'][:1]:
        byid['ERROR:'+e[:80]]['steps']+=1; byid['ERROR:'+e[:80]]['blocks'].add(block(x['name']))
rows=sorted(byid.items(), key=lambda kv:(-kv[1]['steps'],kv[0]))
print('| key | failing steps | rows | blocks |'); print('|---|---|---|---|')
for k,v in rows: print(f"| {k} | {v['steps']} | {v['rows']} | {', '.join(sorted(v['blocks']))} |")
print(); print('FAIL steps:', sum(1 for x in res if x['verdict']=='FAIL'), 'of', len(res))
