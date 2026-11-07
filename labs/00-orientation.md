# Lab 00 — Orientation

## Objective

Name the track that owns each object, and say what the default apply will bill before you create it.

## Architecture

Read [docs/DIAGRAMS.md](../docs/DIAGRAMS.md) and [docs/OWNERSHIP.md](../docs/OWNERSHIP.md). No cluster yet.

## Prerequisites

A sandbox AWS account, Terraform >= 1.10, AWS CLI v2, kubectl, and Helm 3. The IAM notes are in [terraform/iam/README.md](../terraform/iam/README.md).

## Steps

1. From the repo root, run `./scripts/static-validate.sh` if the tools are installed, or read `.github/workflows/static.yml` and see that it never calls `terraform apply`.
2. Open `terraform/stacks/02-cluster/main.tf` and find `compute_config`. Confirm it is null.
3. Open `terraform/modules/guardrails/variables.tf` and find the public CIDR rule.
4. Run `./scripts/teardown-checklist.sh` and confirm it prints commands and exits without deleting.

## Expected observations

Example only. `./scripts/teardown-checklist.sh` exits 0 and the first line says the script never deletes resources. `compute_config` is null.

## Questions

1. Why is the load balancer controller not in stack 02?
2. Which identity is allowed to call `s3:GetObject` on the demo bucket after stack 03, and which identity is not?
3. What changes on the bill if the cluster is still on Kubernetes 1.34 on 2026-12-03?

## Failure injection

None. Do not apply in this lab.

## Diagnostics

If `terraform fmt -check` fails, run `terraform fmt -recursive terraform` and look at the diff. Do not ignore a validation error by adding `-refresh=false` and applying.

## Answers

1. Stack 02 finishes before the API exists. The controller is a Helm release that needs that API. Combining them makes the provider configure itself from a cluster the same plan is still creating.
2. The Pod Identity role `lab-workload` can `s3:GetObject` under `lab08/`. The IRSA role `lab-irsa` can only `s3:ListBucket`. The node role is neither of those policies.
3. 1.34 leaves standard support on 2026-12-02. Extended support is $0.60 per cluster-hour instead of $0.10. Source: the EKS pricing page and the version table in `docs/VERSIONS.md`.

## Cleanup

Nothing was created.

## Cost

Zero, if you did not apply.
