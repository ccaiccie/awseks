#!/usr/bin/env bash
# Static checks only. No AWS credentials, no terraform apply, no cluster.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${root}"

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform is required" >&2
  exit 1
fi
if ! command -v shellcheck >/dev/null 2>&1; then
  echo "shellcheck is required" >&2
  exit 1
fi

terraform -chdir=terraform fmt -check -recursive
terraform -chdir=terraform init -backend=false -input=false
terraform -chdir=terraform validate

while IFS= read -r script; do
  bash -n "${script}"
done < <(find cli/bin cli/lib stages class/labs/scripts -name '*.sh' -type f | sort)

shellcheck -x cli/lib/common.sh cli/bin/*.sh stages/aws-load-balancer-controller/*.sh stages/metrics-server/install.sh
# Class scripts source a gitignored config.env. Do not follow that missing file.
shellcheck --exclude=SC1091 class/labs/scripts/*.sh

python3 tests/static/check_alignment.py
echo "static checks passed"
