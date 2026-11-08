#!/usr/bin/env python3
"""Local integrity check only: no AWS, install or hidden download."""
import hashlib,pathlib,re,sys
mode,name,checks=sys.argv[1:]
p=pathlib.Path(name)
actual=hashlib.sha256(p.read_bytes()).hexdigest()
text=pathlib.Path(checks).read_text().strip()
if mode=="sha256-list":
    rows=[x.split() for x in text.splitlines()]
    matches=[a for a,b in rows if b.lstrip("*")==p.name]
    if len(matches)!=1:raise SystemExit("STOP: no unique checksum entry")
    expected=matches[0]
elif mode=="sha256":expected=text
else:raise SystemExit("STOP: unknown verification mode")
if not re.fullmatch("[0-9a-fA-F]{64}",expected):
    raise SystemExit("STOP: malformed checksum")
if actual.lower()!=expected.lower():
    raise SystemExit("STOP: checksum mismatch")
print("Publisher HTTPS checksum matches; not independent signature proof")
