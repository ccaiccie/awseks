#!/usr/bin/env python3
"""Static alignment checks for the repo and the vendored class bundle."""

import hashlib
import pathlib
import sys

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[2]


def fail(message):
    print(f"FAIL: {message}", file=sys.stderr)
    raise SystemExit(1)


def main():
    svgs = list((ROOT / "class/diagrams").glob("*.svg"))
    if len(svgs) != 38:
        fail(f"expected 38 class SVGs, found {len(svgs)}")
    drawio = (ROOT / "class/diagrams/eks-scenarios.drawio").read_text()
    pages = drawio.count("<diagram ")
    if pages != 37:
        fail(f"expected 37 draw.io pages, found {pages}")
    scripts = list((ROOT / "class/labs/scripts").glob("*.sh"))
    if len(scripts) != 20:
        fail(f"expected 20 class scripts, found {len(scripts)}")
    curriculum = (ROOT / "class/CURRICULUM.md").read_text()
    for chapter in range(26):
        needle = f"|{chapter:02d} "
        if needle not in curriculum:
            fail(f"curriculum missing chapter {chapter:02d}")

    policy_a = (ROOT / "policies/aws-load-balancer-controller-v2.14.1.json").read_bytes()
    policy_b = (ROOT / "class/labs/policies/lbc-v3.6.2.json").read_bytes()
    digest = hashlib.sha256(policy_a).hexdigest()
    if policy_a != policy_b or digest != "16f232c9d9f79366fe949c4550ad517a202380058a9e48d45a4e215044a20a6a":
        fail("load balancer IAM policy bytes drifted from the recorded SHA256")
    chart = (ROOT / "class/sources/lbc-Chart.yaml").read_text()
    if "version: 3.6.2" not in chart or "appVersion: v3.6.2" not in chart:
        fail("chart metadata is not 3.6.2 / v3.6.2")
    tgz = (ROOT / "class/sources/lbc-chart-3.6.2.tgz").read_bytes()
    if hashlib.sha256(tgz).hexdigest() != "9255bf39873b6cb31106dbe61dc87c3617bff4197783b5b94381811a13f99c3c":
        fail("chart tarball hash drifted")

    for path in list((ROOT / "manifests").rglob("*.yaml")) + list((ROOT / "class/labs/manifests").glob("*.yaml")):
        text = path.read_text()
        if "0.0.0.0/0" in text:
            fail(f"{path} contains 0.0.0.0/0")
        if "privileged: true" in text:
            fail(f"{path} is privileged")
        docs = list(yaml.safe_load_all(text))
        if not any(isinstance(doc, dict) and doc.get("kind") for doc in docs):
            fail(f"{path} has no Kubernetes object")

    variables = (ROOT / "terraform/variables.tf").read_text()
    if 'default     = "1.36"' not in variables:
        fail("terraform default Kubernetes minor is not 1.36")
    if "awseks-tf-" not in variables or "awseks-cli-" not in (ROOT / "cli/lib/common.sh").read_text():
        fail("repo ownership prefixes missing")
    example = (ROOT / "class/labs/config.example.env").read_text()
    if "eksclass-cli-" not in example:
        fail("class stack prefix missing")
    if "REPLACE_REVIEWED_REGISTRY_IMAGE_AT_SHA256" not in example:
        fail("class image digest gate was filled in")

    required = [
        "class/CURRICULUM.md",
        "class/TECHNICAL-SPEC.md",
        "class/SOURCE-CLAIMS.md",
        "class/FLOW-SCENARIOS.json",
        "class/diagrams/F01.svg",
        "class/diagrams/F29.svg",
        "class/diagrams/previews/F01.png",
        "docs/class-index.md",
        "docs/chapter-map.md",
        "labs/07-networking.md",
        "labs/08-policy-and-load-balancers.md",
        "labs/09-operate.md",
        "labs/14-comparisons.md",
    ]
    for relative in required:
        if not (ROOT / relative).is_file():
            fail(f"missing {relative}")

    print("alignment checks passed")


if __name__ == "__main__":
    main()
