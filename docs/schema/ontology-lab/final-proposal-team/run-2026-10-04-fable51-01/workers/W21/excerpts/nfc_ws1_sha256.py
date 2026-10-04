import sys, unicodedata, hashlib, re
def nfcws1(s): return re.sub(r'\s+', ' ', unicodedata.normalize('NFC', s)).strip()
def h(s): return 'sha256:' + hashlib.sha256(nfcws1(s).encode('utf-8')).hexdigest()
if __name__ == '__main__':
    if sys.argv[1] == '-f':
        for f in sys.argv[2:]: print(h(open(f, encoding='utf-8').read()), f)
    else:
        for q in sys.argv[1:]: print(h(q), '|', q)
