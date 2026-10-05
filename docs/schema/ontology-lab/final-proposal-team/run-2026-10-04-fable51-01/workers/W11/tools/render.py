# Renders {{qh:TEXT}} -> sha256 over NFC-WS1(TEXT); {{h:TEXT}} -> sha256 over TEXT (utf-8);
# {{py:EXPR}} -> str(eval(EXPR)) with helpers sh(text), cj(obj) canonical JSON, digest([payloadHash...]).
import sys, re, hashlib, unicodedata, json
def nfcws1(t): return re.sub(r'\s+', ' ', unicodedata.normalize('NFC', t)).strip()
def sh(t): return 'sha256:' + hashlib.sha256(t.encode('utf-8')).hexdigest()
def cj(o): return json.dumps(o, sort_keys=True, separators=(',', ':'), ensure_ascii=False)
def digest(hs): return sh('\n'.join(sorted(hs)))
import os
C = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'crit.json'))) if os.path.exists(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'crit.json')) else {}
src = open(sys.argv[1], encoding='utf-8').read()
src = re.sub(r'\{\{py:(.*?)\}\}', lambda m: str(eval(m.group(1))), src, flags=re.S)
src = re.sub(r'\{\{qh:(.*?)\}\}', lambda m: sh(nfcws1(m.group(1))), src, flags=re.S)
src = re.sub(r'\{\{h:(.*?)\}\}', lambda m: sh(m.group(1)), src, flags=re.S)
assert '{{' not in src, 'unrendered marker'
open(sys.argv[2], 'w', encoding='utf-8').write(src)
print('rendered', sys.argv[2])
