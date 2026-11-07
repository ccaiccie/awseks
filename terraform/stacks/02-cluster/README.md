# Stack 02 — standard EKS

AWS provider only. Apply after stack 01. Do not add a `kubernetes` or `helm` provider to this directory.

The public API is off unless `endpoint_public_access` is true and `endpoint_public_access_cidrs` passes the guardrail. While the public endpoint is off, the AWS API still stores a CIDR list. This stack stores `203.0.113.1/32` (the documentation range) so the module's own default of `0.0.0.0/0` is never sent.

`authentication_mode` is `API`. Access entries come from `admin_principal_arns`. The cluster creator is not granted admin automatically.

Node group `lab` is on-demand `t3.medium`, desired 2, IMDSv2, hop limit 1, no SSH key. Optional group `spot` stays at desired 0.

Add-on versions for VPC CNI, CoreDNS, and kube-proxy come from the AWS tables recorded in `docs/VERSIONS.md`. EBS CSI is pinned to the build named in that file and should be re-checked. The Pod Identity agent uses `most_recent` until you set `pod_identity_agent_addon_version`.
