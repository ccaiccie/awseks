#!/usr/bin/env bash
# Static checks only. No AWS credentials, no terraform apply, no terraform destroy.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

fail() {
  echo "static-validate: $*" >&2
  exit 1
}

if [[ -n "${AWS_ACCESS_KEY_ID:-}${AWS_SECRET_ACCESS_KEY:-}${AWS_SESSION_TOKEN:-}" ]]; then
  echo "AWS credential environment variables are set. This script does not use them." >&2
fi

echo "== terraform fmt =="
terraform fmt -check -recursive terraform

echo "== terraform test (no providers) =="
terraform -chdir=terraform/modules/guardrails init -backend=false -input=false
terraform -chdir=terraform/modules/guardrails test
terraform -chdir=terraform/modules/subnet-plan init -backend=false -input=false
terraform -chdir=terraform/modules/subnet-plan test

echo "== terraform init/validate stacks =="
for stack in 01-network 02-cluster 03-platform 04-karpenter; do
  terraform -chdir="terraform/stacks/${stack}" init -backend=false -input=false
  terraform -chdir="terraform/stacks/${stack}" validate
done

echo "== shell syntax and shellcheck =="
shopt -s globstar nullglob
for script in scripts/*.sh; do
  bash -n "$script"
  shellcheck "$script"
done

echo "== yaml parse =="
python3 - <<'PY'
import sys
from pathlib import Path
try:
    import yaml
except ImportError:
    sys.exit("PyYAML is required")

errors = 0
for path in Path("manifests").rglob("*.yaml"):
    text = path.read_text()
    docs = list(yaml.safe_load_all(text))
    if not any(docs):
        print(f"empty yaml: {path}", file=sys.stderr)
        errors += 1
        continue
    for doc in docs:
        if not isinstance(doc, dict):
            continue
        if "privileged" in text and "privileged: true" in text:
            print(f"privileged container: {path}", file=sys.stderr)
            errors += 1
        for key in ("apiVersion", "kind", "metadata"):
            if key not in doc:
                print(f"{path} missing {key}", file=sys.stderr)
                errors += 1
if errors:
    sys.exit(errors)
print(f"parsed {len(list(Path('manifests').rglob('*.yaml')))} manifest files")
PY

echo "== forbidden patterns =="
if rg -n "provisioner|local-exec" --glob "*.tf" terraform; then
  fail "provisioners are not allowed"
fi
if rg -n "AdministratorAccess" --glob "*.tf" terraform; then
  fail "AdministratorAccess found in Terraform"
fi
# The guardrails module names 0.0.0.0/0 only to reject it.
if rg -n "0\\.0\\.0\\.0/0" --glob "*.tf" --glob "!**/guardrails/**" terraform; then
  fail "world-open CIDR found outside the guardrail rejection"
fi
if rg -n "AKIA[0-9A-Z]{16}" terraform manifests labs docs scripts; then
  fail "access key material found"
fi

echo "== kubeconform =="
if ! command -v kubeconform >/dev/null 2>&1; then
  fail "kubeconform is not installed"
fi
kubeconform -strict -summary -kubernetes-version 1.35.0 \
  -ignore-filename-pattern 'lab18-gateway|lab15-karpenter' \
  manifests
kubeconform -summary -kubernetes-version 1.35.0 -ignore-missing-schemas \
  manifests/lab15-karpenter manifests/lab18-gateway

echo "static-validate: passed (not cloud-deployed)"
