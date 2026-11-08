#!/usr/bin/env python3
"""Local macOS publisher check after pkgutil signature verification succeeds."""
import re,sys
text=sys.stdin.read()
if not re.search(r"Developer ID Installer: Amazon Web Services, Inc[.]? \([A-Z0-9]+\)",text):
    raise SystemExit("STOP: expected Amazon installer publisher not present")
print("Expected Amazon publisher identified; Gatekeeper must still succeed")
