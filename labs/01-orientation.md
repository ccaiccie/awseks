# Lab 01 — Orientation

## Objective

Prove which account you are in, which tools you have, and what will bill you, before any create call.

## Prerequisites

AWS CLI v2, kubectl, Helm 3, jq, Python 3. Terraform only if you will use that path. An IAM principal in the account you mean to spend.

## Diagram

[docs/diagrams/01-architecture.svg](../docs/diagrams/01-architecture.svg)

## Commands

```bash
aws --version
aws sts get-caller-identity --output json
curl -fsS https://checkip.amazonaws.com
```

Read [docs/cost.md](../docs/cost.md) and the pricing pages it names. Do not paste the IP address into git.

## Expected observation

`aws --version` starts with `aws-cli/2.`. `Account` is 12 digits and is the account you intend. The checkip command prints one address. Nothing in the AWS console's VPC or EKS list was created by these commands.

## Question

Which charges start when the cluster exists even if you never create a load balancer or a PVC?

## Explanation

The control plane, the nodes, and a NAT gateway. Interface endpoints and load balancers are extra and are off by default.

## Safe failure

Run `aws sts get-caller-identity --profile does-not-exist`. You should get a profile error and no resources.

## Troubleshooting

If the CLI is v1, install v2. The scripts check the `aws-cli/2.` prefix. Empty credentials are not a cluster problem.

## Cost

None from this lab.

## Cleanup

None.
