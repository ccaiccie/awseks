# Sources / exact scope of checks — 2026-11-08 PST

Official pages opened this revision:
- https://docs.aws.amazon.com/cli/latest/reference/eks/describe-cluster-versions.html — real CLI flags version-status/clusterVersions lifecycle fields; no pinned current version invented.
- https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sign-in.html — CLI >=2.32.0, SignInLocalDevelopmentAccess prerequisite, console login, Identity Center distinction, session refresh/logout, documented credential_process bridge.
- https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html — credential/config order and options; CLI and SDK differences require actual identity check.
- https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html — SCP member-root/delegated-admin restriction; management-account/service-linked-role exceptions.
- https://docs.aws.amazon.com/eks/latest/userguide/network-reqs.html — two AZs, EKS ENIs, >=6 free IPs (16 recommended), DNS, disallowed AZ IDs, nonoverlap caveats.
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type — genuine type-limit attribute names (also checked against pinned schema).
- https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/v6.21.0/website/docs/d/ec2_instance_type_offerings.html.markdown — locations/location_type/filter support.
- https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/v6.21.0/website/docs/d/eks_cluster_versions.html.markdown — genuine version data source, lifecycle fields and version_status.

Pinned provider actual schema was downloaded with Terraform init and inspected offline. **This caught and corrected two initial assumptions before packaging**: aws_subnet DOES expose available_ip_address_count, and aws_eks_cluster_versions DOES exist in 6.21.0. aws_region.name is deprecated; code uses .region. Terraform fmt/init -backend=false/validate tested locally; no authenticated AWS plan/apply or deployment was performed.

Additional authoritative references retained from accepted Unit 6A; these URLs are technical references, not claims every page was reopened this revision:
- https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html — AWS CLI installation, signing and OS prerequisites.
- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli — Terraform installation / signature verification.
- https://developer.hashicorp.com/terraform/language/data-sources — data sources; https://developer.hashicorp.com/terraform/language/state — state; https://developer.hashicorp.com/terraform/cli/commands/init — backend initialization.
- https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html — client version skew.
- https://docs.aws.amazon.com/vpc/latest/userguide/subnet-sizing.html — five reserved IPv4 addresses.
- https://docs.aws.amazon.com/eks/latest/APIReference/API_KubernetesNetworkConfigRequest.html — IPv4 Service CIDR constraints.
- https://docs.aws.amazon.com/vpc/latest/userguide/route-tables-priority.html — longest-prefix selection.
- https://docs.aws.amazon.com/vpc/latest/userguide/infrastructure-security.html — SG stateful / NACL stateless distinction.
- https://docs.aws.amazon.com/vpc/latest/userguide/custom-network-acl.html — return/ephemeral ports and direction.
- https://docs.aws.amazon.com/eks/latest/userguide/choosing-instance-type.html — classic node capacity caveats.
- https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-best-practices.html — delayed data/alerts; https://aws.amazon.com/aws-cost-management/aws-budgets/pricing/ — monitoring vs action-enabled budgets.
- https://docs.aws.amazon.com/cli/latest/reference/budgets/create-budget.html — complete budget/notification JSON mutation API; https://docs.aws.amazon.com/cli/latest/reference/budgets/describe-subscribers-for-notification.html — subscriber verification.
- https://docs.aws.amazon.com/cost-management/latest/userguide/billing-example-policies.html — budgets:ViewBudget / ModifyBudget naming.
- https://aws.amazon.com/eks/pricing/ ; https://aws.amazon.com/vpc/pricing/ — check current prices/Region on build day; this package does not estimate the user's current bill.

All CIDRs/counts/ports/identifiers/output examples are explicitly illustrative. Source inputs accepted HTML and ZIP were SHA256-matched; no old artifact was overwritten. No runtime source citations or URL spam should be narrated. Repository URL is existing course repository, not evidence new files have been published.

## Additional ALB facts re-opened for this revision
- https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html — ALB layer seven, listener/rule/target-group model, host/path selection.
- https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html — all-unhealthy target fail-open caveat; checks are not a security boundary.
- https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html — configured controller prerequisites; IP/Pod versus instance/NodePort alternative target modes, at least eight available subnet IPs. No Ingress was applied.

## Updated cadence correction, verified 2026-11-08 PST
Reopened Service IPv4 network API, VPC subnet sizing and Budgets best-practices pages. The current Budgets page says billing data is updated **at least once per day**, with alerts following that refresh cadence. The accepted r3 “up to three times / 8–12 hours” wording is replaced in r4 narration and its genuine Mermaid diagram label; it is not retained as a current maximum-delay promise. Ordinary RFC1918 IPv4 subnet examples reserve five addresses; BYOIP is a distinct exception outside this lesson.

## Pricing pages re-opened 2026-11-08 PST
EKS pricing confirms ordinary cluster standard support USD 0.10/hour and extended USD 0.60/hour, with optional features such as Provisioned Control Plane/Auto Mode billed separately. VPC pricing confirms zonal NAT hourly/data processing/partial-hour billing and ordinary dedicated Amazon-provided public IPv4 USD 0.005/hour in-use or idle. BYOIP/COIP and Amazon-provided contiguous IPv4 blocks are separate exceptions/products; the lesson narrows its ordinary-IP wording accordingly. The course two-zonal-NAT design is not a claim regional NAT products do not exist. No current-account spend or regional instance/NAT price is invented.


## Stage3 sources opened 2026-11-08 PST
- https://kubernetes.io/docs/concepts/services-networking/service/ — stable Service abstraction, port/targetPort, DNS, EndpointSlices, headless/ExternalName exceptions; current ready-traffic-policy qualification.
- https://docs.aws.amazon.com/eks/latest/APIReference/API_KubernetesNetworkConfigRequest.html — serviceIpv4Cidr RFC1918 /12–/24/nonoverlap/creation-only; defaults10.100.0.0/16 or172.20.0.0/16 when omitted.
- https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html — AWS API versus Kubernetes API endpoint, public/private reachability; private cluster-SG versus public-access-CIDR boundaries, TLS/identity remains required.
- https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/v6.21.0/website/docs/d/lb.html.markdown
- https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/v6.21.0/website/docs/d/lb_listener.html.markdown
- https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/v6.21.0/website/docs/d/lb_listener_rule.html.markdown
- https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/v6.21.0/website/docs/d/lb_target_group.html.markdown
Pinned ALB data docs and actual provider schema verified; Terraform fmt/validate pass, not authenticated plan. No live target-health evaluator invented. C3 worked Service pool is consistently172.20.0.0/16; immutable accepted/legacy comparison fixtures may use172.20.0.0/16. Never change an existing cluster to match either.

- https://docs.aws.amazon.com/eks/latest/userguide/auth-configmap.html — opened stage3: deprecated aws-auth mapping purpose; access entries recommended. Legacy creator/access behavior is not assumed universal for API-only/bootstrap-disabled clusters. No edit/apply steps from that legacy page are executed or taught here.

- https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html — opened09:15PST, AZ subnet /27 or larger and at least8 FREE addresses; frontend/back-end connections. Course range restored to accepted172.20.0.0/16 per latest parent correction; no existing cluster modified.

Pinned provider schema explicitly confirms aws_eks_cluster.access_config(authentication_mode, bootstrap_cluster_creator_admin_permissions) and endpoint. Those observations are not an IAM/RBAC effective-permission evaluator.
