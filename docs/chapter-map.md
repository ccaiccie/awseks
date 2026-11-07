# Chapter, lab, and diagram map

This table lines practice labs up with the 26 curriculum chapters. The measured class timing, 335 scenes and 2:09:55, is [class/build/SCENE-CHAPTER-MAP.md](../class/build/SCENE-CHAPTER-MAP.md). The lecture diagram is [class/diagrams/EKS-Masterclass-v5.1-Lecture-and-Flow.drawio](../class/diagrams/EKS-Masterclass-v5.1-Lecture-and-Flow.drawio). F01–F29 SVG and PNG files under [class/diagrams/](../class/diagrams/README.md) are the static reference geometry. Labs L00–L17 are in [class/labs/README.md](../class/labs/README.md). Repo labs in `labs/` are the shorter Terraform and AWS CLI path. They do not replace L00–L17.

| Ch | Unit | Class lab | Class diagrams | Repo lab |
| --- | --- | --- | --- | --- |
| 00 | Orientation and safety | L00 | F01, F09 | [labs/01-orientation.md](../labs/01-orientation.md) |
| 01 | Linux and networks | — | F04, F05 | [labs/07-networking.md](../labs/07-networking.md) |
| 02 | Images to containers | L04 | F03 | [labs/02-workloads.md](../labs/02-workloads.md) |
| 03 | Kubernetes object model | L04 | F03 | [labs/02-workloads.md](../labs/02-workloads.md) |
| 04 | Config and lifecycle | L04, L12 | F20, F21 | [labs/02-workloads.md](../labs/02-workloads.md) |
| 05 | EKS architecture | L02 | F03 | [labs/03-terraform-path.md](../labs/03-terraform-path.md) |
| 06 | Compute choice | — | F18, F19 | [labs/14-comparisons.md](../labs/14-comparisons.md) |
| 07 | VPC and IP budgets | L01 | F05, F12, F13 | [labs/07-networking.md](../labs/07-networking.md) |
| 08 | Build a standard cluster | L00–L03 | F01, F03 | [labs/03-terraform-path.md](../labs/03-terraform-path.md), [labs/04-aws-cli-path.md](../labs/04-aws-cli-path.md) |
| 09 | Human access | L03, L08 | F01, F02, F22 | [labs/05-api-access.md](../labs/05-api-access.md), [labs/06-iam.md](../labs/06-iam.md) |
| 10 | VPC CNI | L05 | F04, F05, F23 | [labs/07-networking.md](../labs/07-networking.md) |
| 11 | Services and CoreDNS | L05 | F06, F07, F08 | [labs/07-networking.md](../labs/07-networking.md) |
| 12 | Four identities | L07, L09 | F14, F15 | [labs/06-iam.md](../labs/06-iam.md) |
| 13 | Egress and private AWS | L10 | F12, F13 | [labs/07-networking.md](../labs/07-networking.md) |
| 14 | Expose applications | L06 | F09, F10 | [labs/08-policy-and-load-balancers.md](../labs/08-policy-and-load-balancers.md) |
| 15 | NLB and Gateway API | L06, L13 | F11, F24, F25 | [labs/08-policy-and-load-balancers.md](../labs/08-policy-and-load-balancers.md) |
| 16 | DNS and TLS | L06 optional | F09 | [labs/08-policy-and-load-balancers.md](../labs/08-policy-and-load-balancers.md) |
| 17 | East-west security | L11 | F16, F17, F26 | [labs/08-policy-and-load-balancers.md](../labs/08-policy-and-load-balancers.md) |
| 18 | Persistent storage | L09 | F18, F27 | [labs/09-operate.md](../labs/09-operate.md) |
| 19 | Scaling | L12 | F19, F20 | [labs/09-operate.md](../labs/09-operate.md) |
| 20 | Observability | L14 | F22, F23, F26 | [labs/09-operate.md](../labs/09-operate.md) |
| 21 | Failure practicum | L14 | F22, F23, F26, F27 | [labs/09-operate.md](../labs/09-operate.md) |
| 22 | Upgrade and rollback | L15 | F21, F28 | [labs/09-operate.md](../labs/09-operate.md) |
| 23 | Security, cost, DR | L16 | F29 | [labs/09-operate.md](../labs/09-operate.md) |
| 24 | Terraform progression | class does not own this apply | same F01–F29 pictures | [labs/03-terraform-path.md](../labs/03-terraform-path.md) |
| 25 | Capstone and teardown | L17 | F01–F29 recap | [docs/cleanup.md](cleanup.md) |

Subordinate pages (`F03-1`, `F03-2`, `F03-3`, `F13-1`, `F14-1`, `F15-1`, `F18-1`, `F18-2`) are extra scenes for the same scenario. Count them when you say 37 draw.io pages. Do not animate a subordinate page as if it were the same packet as the parent page.
