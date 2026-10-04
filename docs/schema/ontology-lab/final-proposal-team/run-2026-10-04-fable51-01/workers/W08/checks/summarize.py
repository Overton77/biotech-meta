#!/usr/bin/env python3
"""Summarize run-cypher.mjs JSON: per statement the last V-/Q- id in its header comment, row count, sample."""
import json, re, sys
d = json.load(open(sys.argv[1])); verbose = '-v' in sys.argv; nonzero = '--nonzero' in sys.argv
for s in d['results']:
    h = s.get('header') or ''
    ids = re.findall(r'^//\s*((?:V|Q)-(?:W08-)?\d+[a-z]?)\b', h, re.M)
    label = ids[-1] if ids else f"stmt{s['n']}"
    rows = int(s['rows'] or 0)
    if nonzero and rows == 0 and s['status'] == 'ok':
        continue
    print(f"{label}: status={s['status']} rows={rows}")
    if verbose:
        for r in (s.get('sample') or [])[:12]:
            print('    ' + json.dumps(r, default=str)[:420])
