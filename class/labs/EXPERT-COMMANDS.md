# Expert command reference — teach, review, then run only in authorized sandbox

These are **reference commands, not execution evidence or a run-all script**. Set/export variables from your own guarded lab state/config; uppercase names below are explicit placeholders. Never substitute an arbitrary production ID. Read operations first; write/upgrade/DNS/storage/scale examples require separate operator review and costs/data planning. Primary complete creation path remains scripts00..03; kubectl/Helm still have distinct roles.

## Component compatibility / observe actual proxy implementation
```bash
aws eks describe-cluster-versions --version-status STANDARD_SUPPORT
aws eks describe-addon-versions --addon-name vpc-cni --kubernetes-version "$K8S_VERSION"
aws eks describe-addon-configuration --addon-name vpc-cni --addon-version "$CNI_ADDON_BUILD"
aws eks describe-addon-configuration --addon-name kube-proxy --addon-version "$PROXY_ADDON_BUILD"
aws eks describe-addon --cluster-name "$STACK" --addon-name vpc-cni
kubectl -n kube-system get cm kube-proxy-config -o yaml
kubectl -n kube-system logs daemonset/kube-proxy --tail=100
kubectl -n kube-system get ds aws-node -o yaml
kubectl -n kube-system logs daemonset/aws-node -c aws-network-policy-agent --tail=100
```
Native nftables proxy mode isn't the same thing as iptables' nft backend. Do not change mode/schema blindly; primary flow lecture assumes **proven** iptables canonical track. Exact addon build/schema is discovered, then pinned; verify request values against returned schema before update.

## Debug Service and lifecycle
```bash
kubectl -n eksclass describe pod "$EXACT_POD_NAME"
kubectl -n eksclass logs "$EXACT_POD_NAME" -c web --previous
kubectl -n eksclass get endpointslices -l kubernetes.io/service-name=web -o yaml
kubectl -n eksclass get service web -o yaml
kubectl -n eksclass rollout history deployment/web
# Explicit sandbox mutation after reviewing desired image/config:
kubectl -n eksclass rollout restart deployment/web
kubectl -n eksclass rollout status deployment/web --timeout=300s
# Application-only rollback; does not undo DB schema, PVC data or EKS version:
kubectl -n eksclass rollout undo deployment/web --to-revision="$KNOWN_GOOD_REVISION"
```
Do not interpret `--previous` failure when no previous container exists as a system failure. A Deployment revision captures Pod template, not arbitrary external data/config history.

## LB health and security diagnostics
```bash
aws elbv2 describe-load-balancers --load-balancer-arns "$EXACT_LB_ARN"
aws elbv2 describe-target-groups --load-balancer-arn "$EXACT_LB_ARN"
aws elbv2 describe-target-health --target-group-arn "$EXACT_TG_ARN"
aws elbv2 describe-target-group-attributes --target-group-arn "$EXACT_TG_ARN"
aws elbv2 describe-load-balancer-attributes --load-balancer-arn "$EXACT_LB_ARN"
aws ec2 describe-security-groups --group-ids "$EXACT_LB_SG" "$EXACT_BACKEND_SG"
kubectl -n eksclass describe ingress web-alb
kubectl -n kube-system logs deployment/aws-load-balancer-controller --tail=100
```
Correlate exact ARN, VPC and Kubernetes ownership tags before changing anything; no ELB delete loop. ALB backend TLS/health settings and NLB preservation/proxy-protocol attributes are not interchangeable.

## Finite capacity change and upgrade plan
```bash
aws eks list-insights --cluster-name "$STACK"
aws eks describe-insight --cluster-name "$STACK" --id "$EXACT_INSIGHT_ID"
aws eks describe-nodegroup --cluster-name "$STACK" --nodegroup-name "$STACK-ng"
kubectl get pdb -A
kubectl get nodes -o wide
# After explicit cost review, exact managed group only:
aws eks update-nodegroup-config --cluster-name "$STACK" --nodegroup-name "$STACK-ng" \
  --scaling-config minSize=2,maxSize=4,desiredSize=3
# Record returned update.id, then (configuration updates do not necessarily change cluster status):
aws eks describe-update --name "$STACK" --nodegroup-name "$STACK-ng" --update-id "$EXACT_UPDATE_ID"
```
Separate upgrade writes (NOT automated in primary lab):
```bash
# AFTER supported one-minor target, insight, application and backup/restore gates:
aws eks update-cluster-version --name "$STACK" --kubernetes-version "$REVIEWED_NEXT_MINOR"
aws eks describe-update --name "$STACK" --update-id "$EXACT_UPDATE_ID"
# AFTER addon compatibility + saved old config review:
aws eks update-addon --cluster-name "$STACK" --addon-name "$EXACT_ADDON_NAME" \
  --addon-version "$REVIEWED_COMPATIBLE_BUILD" --resolve-conflicts PRESERVE
aws eks wait addon-active --cluster-name "$STACK" --addon-name "$EXACT_ADDON_NAME"
# AFTER canary, capacity/PDB and release review; managed node group explicit upgrade:
aws eks update-nodegroup-version --cluster-name "$STACK" --nodegroup-name "$STACK-ng" \
  --kubernetes-version "$REVIEWED_NEXT_MINOR" --release-version "$REVIEWED_AMI_RELEASE"
aws eks describe-update --name "$STACK" --nodegroup-name "$STACK-ng" --update-id "$EXACT_UPDATE_ID"
```
`--resolve-conflicts PRESERVE` preserves changed field ownership, not a compatibility guarantee. Don't pass newer nodes to an older control plane, skip minor versions or assume wait cluster-active proves workload health. For updated launch-template versions, follow explicit managed-nodegroup launch-template update constraints rather than inventing an AMI/launch-template combination.

**Current conditional rollback**: source S50 documents previous-minor rollback within7days for eligible in-place upgrades. Validate eligibility/insights and roll back too-new nodes first, addons separately. The control-plane API is `aws eks update-cluster-version --name "$STACK" --kubernetes-version "$ELIGIBLE_PREVIOUS_MINOR"`; do not run against created-at-current clusters, unsupported boundaries or incompatible feature state. No `--force` default. This does not revert app/PV/etcd data.

## Owned DNS + ACM TLS reference
```bash
# EXACT_OWNED_FQDN must be controlled by learner; this creates a billable/managed external resource.
aws acm request-certificate --domain-name "$EXACT_OWNED_FQDN" --validation-method DNS \
  --idempotency-token "$REVIEWED_ALPHANUMERIC_TOKEN"
aws acm describe-certificate --certificate-arn "$EXACT_CERT_ARN"
# Write reviewed exact DNS validation CNAME batch from Certificate.DomainValidationOptions.
aws route53 change-resource-record-sets --hosted-zone-id "$EXACT_OWNED_ZONE_ID" \
  --change-batch file://reviewed-acm-validation-record.json
aws acm wait certificate-validated --certificate-arn "$EXACT_CERT_ARN"
```
Set ALB Ingress certificate-arn, HTTPS443 listen-ports and HTTP→HTTPS redirect using the reviewed ACM ARN. Create exact Route53 alias record using LB DNSName + CanonicalHostedZoneId from describe-load-balancers (no guessed fixedIP). The alias change batch must match owned zone/name. Validate certificate SAN/SNI with `curl https://"$EXACT_OWNED_FQDN"/healthz`, not by public LB IP. Do not delete shared validation records/certificates on cleanup; track ownership first. DNS commands intentionally not embedded in the primary environment bootstrap.

## EFS, Gateway, prefix, SG-for-Pods, IPv6
Follow README L13 guided stages and authoritative sources; these aren't safe single-command toggles. EFS requires filesystem+mount targets+SG2049+CSI IAM/storage topology; Gateway requires matched controller+CRD prerequisites and accepted route references; prefix/SGP changes require node/type/IP-budget/ENI compatibility; IPv6 family requires a NEW cluster. Full specialized automation is explicitly not provided/cloud-tested in this phase. Terraform implementation belongs to the separate awseks repo workstream and a separate resource/state namespace.
