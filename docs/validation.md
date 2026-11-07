# What was validated

This repository was checked without an AWS account and without `terraform apply`.

| Check | What it means |
| --- | --- |
| `terraform fmt -check -recursive` | Files match `terraform fmt` |
| `terraform init -backend=false` | Provider 6.72.0 downloads and the lock file is written. No backend, no state upload |
| `terraform validate` | The configuration is internally consistent. It does not call the EKS API |
| `bash -n` and ShellCheck | Scripts parse and pass ShellCheck with `.shellcheckrc` |
| YAML parse and a small policy scan | Repo and class manifests are YAML, are not privileged, and do not open `0.0.0.0/0` |
| Class bundle counts | 26 curriculum chapters, 38 SVGs, 37 draw.io pages, 20 class scripts, matching controller policy and chart hashes |

Not done, and not claimed:

- `terraform plan` against a live account
- `terraform apply` or `terraform destroy`
- `cli/bin/provision.sh` against a live account
- `helm install` against a live cluster
- A browser session of a load balancer
- Any statement that a node became `Ready`

`aws eks describe-addon-versions` is the compatibility check at plan or provision time. Until someone runs it in the target account and region, the table pins are the versions published in the user guide on 2026-11-07, not a live API response from this workspace.

The class bundle's own `VALIDATION-LABS.md` records source-phase checks only. This workspace re-ran `bash -n` and ShellCheck on those 20 scripts and checked file counts and hashes. It did not re-fetch all 66 documentation snapshots. The rollback, Auto Mode, and controller pages cited in `docs/versions.md` were read from the bundle snapshots and, for the EKS load-balancer install page and the versioned Gateway API URL, fetched again on 2026-11-07. Image digests were read from the public registries with no pull and no AWS account.
