# Repo labs

These labs walk the Terraform and AWS CLI stacks in this repository (`awseks-tf-*` and `awseks-cli-*`). The 26-chapter class and its guarded `eksclass-cli-*` scripts are in [class/labs/README.md](../class/labs/README.md). Do not point those scripts at a repo cluster. The map is [docs/chapter-map.md](../docs/chapter-map.md).

Each lab below has an objective, prerequisites, commands, what you should observe, a question, a safe failure, a cost note, and cleanup. Do the orientation lab before you create anything. Keep `KUBECONFIG` pointed at one cluster.

| Lab | Needs a cluster? |
| --- | --- |
| [01 Orientation](01-orientation.md) | No |
| [02 Workloads](02-workloads.md) | Yes, for apply. Reading works before that |
| [03 Terraform path](03-terraform-path.md) | Creates one |
| [04 AWS CLI path](04-aws-cli-path.md) | Creates one |
| [05 API access](05-api-access.md) | Yes |
| [06 IAM](06-iam.md) | Yes |
| [07 Networking](07-networking.md) | Yes |
| [08 Policy and load balancers](08-policy-and-load-balancers.md) | Yes, Helm for the controller |
| [09 Operate](09-operate.md) | Yes |
| [07 Networking](07-networking.md) | Yes |
| [08 Policy and load balancers](08-policy-and-load-balancers.md) | Yes |
| [09 Operate](09-operate.md) | Yes |
| [14 Comparisons](14-comparisons.md) | No |

Build only one cluster unless you are comparing the two paths and you can pay for both. They must keep the `awseks-tf-` and `awseks-cli-` names.
