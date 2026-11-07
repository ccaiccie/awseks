# Class index

The `eksclass-cli-` labs and the written curriculum are [class/labs/README.md](../class/labs/README.md), [class/CURRICULUM.md](../class/CURRICULUM.md), and [class/TECHNICAL-SPEC.md](../class/TECHNICAL-SPEC.md). [class/README.md](../class/README.md) is the v5.1 delivery page: 335 scene IDs, 26 chapters, 2:09:55. Audit notes are [class/AUDIT-RESOLUTION.md](../class/AUDIT-RESOLUTION.md) and [class/NARRATION-CORRECTIONS-v2.md](../class/NARRATION-CORRECTIONS-v2.md).

Open [class/diagrams/EKS-Masterclass-v5.1-Lecture-and-Flow.drawio](../class/diagrams/EKS-Masterclass-v5.1-Lecture-and-Flow.drawio) for the lecture diagram and [class/build/SCENE-CHAPTER-MAP.md](../class/build/SCENE-CHAPTER-MAP.md) for IDs `s0000`–`s0334`. Older lecture draw.io files are historical. The practice-lab table is [chapter-map.md](chapter-map.md). Version wording that is easy to over-read is in [versions.md](versions.md). The HTML file and the four audio volumes are not in this repository.

## What is a preview

| Artifact | What it is |
| --- | --- |
| `class/diagrams/*.svg` and `class/diagrams/eks-scenarios.drawio` | Editable static geometry for 37 flow pages plus the architecture page. Green is forward, amber is return. Subordinate pages (`F03-1`, `F13-1`, and the rest) are separate exchanges, not one packet. |
| `class/diagrams/previews/*.png` | PNG renders of those SVGs, including contact sheets. They are pictures of the source diagrams. |
| `class/FLOW-SCENARIOS.json` | The same scenes as data: hops, route-table owners, and stop reasons. |
| `docs/diagrams/*` | Short repo sketches for the Terraform and AWS CLI write-up. They are not the class diagrams. |

## What is not in git

The HTML master and the four audio volumes were delivered privately and are not committed. Transcripts are in `class/docs/`. A PNG preview or an F-scene SVG is not that HTML file. `docs/class-incoming/` does not hold the master.

Addresses in the technical spec (`10.42.0.0/16`, `203.0.113.10`, `198.51.100.10`) are illustrative. Do not type the documentation ranges into a public API allow list. The repo's real CIDRs are `10.0.0.0/16` and `172.20.0.0/16`.

## Two provisioning owners, plus the class CLI

| Stack | Name prefix | Where |
| --- | --- | --- |
| Repo Terraform | `awseks-tf-` | `terraform/` |
| Repo AWS CLI | `awseks-cli-` | `cli/bin/` |
| Class AWS CLI labs | `eksclass-cli-` | `class/labs/scripts/` |

Do not point a class script at an `awseks-` cluster, and do not import class state into Terraform. The class scripts are the full guarded command sequence for the curriculum (VPC through teardown). The repo scripts are a separate implementation with the same standard-EKS shape and different names, sizes, and defaults: repo NAT defaults to one gateway, the class picture uses one NAT per AZ; the repo node default is `t3.medium`, the class example is `m6i.large`; the repo leaves the public API off until you set a real `/32`, the class labs require that `/32` up front.

Class commands that are not AWS CLI, and are labeled as such in `class/labs/README.md`: `kubectl` for manifests, Helm for the load balancer controller.

L13 and the numbered expert extensions (Gateway, EFS, Cluster Autoscaler, Karpenter, prefix delegation, security groups for pods, IPv6, owned DNS) are guided runbooks. They are not fully scripted and they were not executed. `class/labs/scripts/11-private-api.sh` does not create the in-VPC runner or its IAM. That runner or VPN is an external prerequisite.
