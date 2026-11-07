#!/usr/bin/env python3
"""Check relative links in the README files that point at this repo."""

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
FILES = [
    ROOT / "README.md",
    ROOT / "docs/class-index.md",
    ROOT / "docs/chapter-map.md",
    ROOT / "docs/class-incoming/README.md",
    ROOT / "docs/diagrams/README.md",
    ROOT / "class/README.md",
    ROOT / "class/diagrams/README.md",
    ROOT / "class/DIAGRAM-INDEX.md",
    ROOT / "class/docs/V5.1-CLASS-README.md",
    ROOT / "labs/README.md",
    ROOT / "terraform/README.md",
]
LINK = re.compile(r"\[[^\]]+\]\(([^)]+)\)")


def fail(message):
    print(f"FAIL: {message}", file=sys.stderr)
    raise SystemExit(1)


def main():
    checked = 0
    for path in FILES:
        if not path.is_file():
            fail(f"missing {path.relative_to(ROOT)}")
        text = path.read_text()
        if "still being built" in text or "animation still" in text:
            fail(f"{path.relative_to(ROOT)} still says the class is unbuilt")
        for raw in LINK.findall(text):
            target = raw.split()[0].strip()
            if target.startswith(("http://", "https://", "mailto:")):
                continue
            if target.startswith("#"):
                continue
            path_part, _, _anchor = target.partition("#")
            if not path_part:
                continue
            resolved = (path.parent / path_part).resolve()
            checked += 1
            if not resolved.is_file() and not resolved.is_dir():
                fail(f"{path.relative_to(ROOT)} -> {target}")
    drawio = ROOT / "class/diagrams/EKS-Masterclass-v5.1-Lecture-and-Flow.drawio"
    import hashlib
    digest = hashlib.sha256(drawio.read_bytes()).hexdigest()
    expected = "6e73873cc031bf0d84202a45798a1aea6bf966fdc7ffe28f3e20624c46135b23"
    if digest != expected:
        fail(f"v5.1 drawio hash {digest}")
    body = drawio.read_text(errors="replace")
    if body.count("<diagram ") != 65:
        fail("v5.1 drawio page count")
    if "data:image/svg+xml," not in body or "data:image/svg+xml;base64" in body:
        fail("v5.1 drawio image URI form")
    print(f"link checks passed ({checked} relative targets); drawio sha256 {digest}")


if __name__ == "__main__":
    main()
