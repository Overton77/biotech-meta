#!/usr/bin/env python3
"""Re-score a Wave 6 record under one consistent policy and print unmet expectations.
Policy: informational ids (0.2.0 list + any id ending in 'i') never fail a zero-rows step; load-order artifacts (ids whose rows
the normalization/backfill removes: V-117, V-F5-61, V-503r, V-F5-LBL*, V-F5-ARCH-2) are counted separately; renamed ids in rows:
expectations are remapped to their successors."""
import json,sys,re,collections
R=json.load(open(sys.argv[1])); P=json.load(open(sys.argv[2]))
INFO={"V-111b","V-118","V-120","V-212","V-223","V-331","V-401b","V-514b","V-522","V-505i","V-217i","V-W00-19","V-F5-16"}
ARTIFACT={"V-117","V-F5-61","V-503r","V-F5-ARCH-2"}
REMAP={"V-423":"V-F5-47","V-423r":"V-F5-47","V-W21-06":"V-F5-47","V-201":"V-F5-01","V-218":"V-F5-08","V-215r":"V-F5-07","V-W00-16":"V-F5-62","V-104":"V-F5-58","V-117":"V-F5-61","V-121":"V-F5-23","V-113":"V-F5-26","V-115":"V-F5-26","V-116":"V-F5-26","V-604":"V-F5-43","V-605":"V-F5-41","V-528p":"V-F5-30","V-536p":"V-F5-33","V-542p":"V-F5-39"}
steps={s['name']:s for s in P['steps']}
out=collections.Counter(); defects=collections.defaultdict(collections.Counter); unmet=[]
for x in R['results']:
    s=steps.get(x['name'],{}); exp=s.get('expect','')
    keys={k:v for k,v in x['rowsById'].items() if not k.startswith('#')}
    if exp=='all-ok': v='PASS' if x['failed']==0 else 'FAIL-LOAD'
    elif exp=='errors-ok': v='recorded'
    elif exp=='zero-rows':
        info=INFO|set(s.get('informational',[]))
        bad={k:n for k,n in keys.items() if k not in info and not k.endswith('i') and k not in ARTIFACT and not k.startswith('V-F5-LBL')}
        art={k:n for k,n in keys.items() if k in ARTIFACT or k.startswith('V-F5-LBL')}
        v='PASS' if x['failed']==0 and not bad else ('FAIL-ROWS' if x['failed']==0 else 'FAIL-LOAD')
        if bad:
            blk=re.match(r'^(union: )?(W\d\d)',x['name']); b=blk.group(2) if blk else 'global'
            for k,n in bad.items(): defects[b][k]+=n
        if art and not bad: v='PASS(artifact-rows)'
    elif exp.startswith('rows:'):
        want=dict(p.split('=') for p in exp[5:].split(','))
        got=lambda k: max(x['rowsById'].get(k,0), x['rowsById'].get(REMAP.get(k,''),0), x['rowsById'].get(k+'r',0), x['rowsById'].get(k+'p',0))
        miss=[k for k,n in want.items() if got(k)<int(n)]
        v='PASS' if not miss else 'FAIL-EXPECT'
        if miss: unmet.append((x['name'],miss,{k:x['rowsById'].get(k) for k in list(x['rowsById'])[:12]}))
    else: v='recorded'
    out[v]+=1
print('rescored verdicts', dict(out))
print('\nunmet rows: expectations'); [print(' -',n,'missing',m) for n,m,_ in unmet]
print('\nnon-informational rows per block (fixture defects or real findings):')
for b in sorted(defects): print(' ',b, dict(defects[b].most_common(12)))
