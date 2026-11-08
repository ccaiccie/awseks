# API endpoint and Service range — understand before using the terms

## Why the particular historical aws-auth mapping is harder to repair
A ConfigMap is an ordinary Kubernetes object holding named configuration values; generic ConfigMaps are not deprecated. The particular legacy kube-system/aws-auth ConfigMap maps AWS IAM principals to Kubernetes usernames/groups. Because it lives INSIDE Kubernetes, editing it already requires authorized Kubernetes access. A broken identity mapping can therefore remove the very access needed to repair that mapping.

EKS access entries are managed through the separate AWS EKS management API: an IAM-authorized administrator can manage or recover an individual principal entry without a working kubectl session. Separate entries support granular automation and audit. Network reachability and AWS IAM permission are still prerequisites; an entry alone is not an authorization grant. EKS access-policy associations or Kubernetes RBAC authorize operations. Authentication mode (API / API_AND_CONFIG_MAP / CONFIG_MAP) selects the mechanism; it does not make a public endpoint anonymous. Unit6A only reads authorized existing configuration and never edits mappings. Unit6B teaches a separately owned new cluster.


Start in the extracted unit06a folder on YOUR computer. This guide supplements the visible narrated foundation scenes, not a replacement for them. All address/URL/output examples below are illustrative, not your account. Do not create anything just to populate an observation.

## API and two endpoints
API = Application Programming Interface: software makes a defined request and receives a response. An endpoint is the network address accepting those requests. AWS EKS management API (`aws eks describe-cluster`, AWS Terraform provider) manages cloud cluster metadata. The returned HTTPS Kubernetes API server endpoint is used by kubectl / Kubernetes providers to inspect or change cluster objects. It is NOT your public application URL.

DNS resolves the name; TCP443 and routing/security controls permit a connection; TLS validates the server and encrypts it; authentication identifies the caller; authorization permits or refuses an operation. IAM = AWS Identity and Access Management. An EKS access entry can connect that principal to cluster access; Kubernetes RBAC = role-based access control for object operations. Existing legacy access mappings may also be in use; do not change them in Unit6A. Public/private means reachability, not anonymous permission. Public CIDRs govern public access; cluster security group controls the private API path. A security group is an attached stateful traffic allow-list. Private endpoint needs VPC/connected-network reachability and DNS. Do not open all sources or disable TLS verification to pass a tutorial.

A get-Pods request is a read of permitted API objects; apply writes desired state and controllers reconcile it. The API server is not proxying ordinary application traffic for every request.

## Service, virtual address and range
A Pod is a running application unit whose IP can change when replaced. A Service provides a stable application front door while selected backend Pods change. For an ordinary ClusterIP Service, DNS resolves its Service name to a virtual ClusterIP. CIDR = Classless Inter-Domain Routing; /16 fixes the first16 address bits and describes a pool, not a port or interface.

Illustrative VPC10.42.0.0/16 holds node/Pod subnet addresses in the ordinary VPC-CNI mode. Separate Service pool172.20.0.0/16 holds virtual Service addresses, NOT ENI allocations. In this worked example, Service172.20.50.10 port80 forwards to ready Pod10.42.16.21 targetPort8080. `port` is client-facing; `targetPort` is where the backend application listens. DNS web.shop.svc.cluster.local → virtual172.20.50.10:80 → node Service rules select a ready endpoint and translate/forward → Pod10.42.16.21:8080 → corresponding return connection/reverse translation where applicable. kube-proxy or the installed datapath equivalent implements this, not a VPC NAT gateway, static Service-CIDR VPC route, physical ClusterIP ENI, or control-plane proxy per web request. Readiness is not an absolute application-health guarantee.

Headless (`clusterIP: None`) has no allocated ClusterIP; ExternalName returns a DNS alias. Not every Service gets such an IP. Keep VPC, Pod, on-prem, peered and planned connected ranges nonoverlapping and consult IPAM. EKS custom IPv4 Service CIDR must be private RFC1918, /12 through /24, nonoverlapping with VPC CIDRs, and is fixed at creation. Changing an existing Terraform cluster's creation-only Service-range setting can replace the cluster. NEVER change an existing cluster simply to match an example. Unit6A only observes/calculates. Unit6B's separate complete creation root will set `kubernetes_network_config { service_ipv4_cidr = var.service_ipv4_cidr }` at FIRST creation, with an immutable/replacement warning; this is not a fragment to paste into this read-only project.

## Full read commands — choose your shell
First complete AUTH.md: select approved AwsProfile/Region/ExpectedAccount, prove non-root intended identity, and obtain both AWS describe permission AND already-authorized Kubernetes reads. No existing cluster? Stop and use the labelled offline example. Do not create access entries, clusters, Services or workloads here.

Bash assignment and AWS reads:
```bash
# OPTIONAL: only an existing authorized cluster; otherwise skip all these reads.
ClusterName="REPLACE_FROM_AUTHORIZED_EXISTING_CLUSTER_LIST"
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.endpoint' --output text --no-cli-pager
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.resourcesVpcConfig.{Public:endpointPublicAccess,Private:endpointPrivateAccess,PublicCIDRs:publicAccessCidrs,ClusterSG:clusterSecurityGroupId}' --output json --no-cli-pager
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.kubernetesNetworkConfig.serviceIpv4Cidr' --output text --no-cli-pager
# Only with existing Kubernetes read authorization; this writes a SEPARATE LOCAL kubeconfig.
aws eks update-kubeconfig --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --kubeconfig ./private-observation-kubeconfig.yaml --alias unit06a-observe
```
PowerShell alternative (same AWS operation arguments):
```powershell
# OPTIONAL: only an existing authorized cluster; otherwise skip all these reads.
$ClusterName = "REPLACE_FROM_AUTHORIZED_EXISTING_CLUSTER_LIST"
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.endpoint' --output text --no-cli-pager
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.resourcesVpcConfig.{Public:endpointPublicAccess,Private:endpointPrivateAccess,PublicCIDRs:publicAccessCidrs,ClusterSG:clusterSecurityGroupId}' --output json --no-cli-pager
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.kubernetesNetworkConfig.serviceIpv4Cidr' --output text --no-cli-pager
# Only with existing Kubernetes read authorization; this writes a SEPARATE LOCAL kubeconfig.
aws eks update-kubeconfig --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --kubeconfig ./private-observation-kubeconfig.yaml --alias unit06a-observe
```

`update-kubeconfig` is an OPTIONAL LOCAL FILE WRITE, not a cloud mutation or access grant. It may fail on missing AWS describe permission. Keep the dedicated file private; commands never overwrite your default kubeconfig. Replacing our file path with a shared configuration is not needed. After every native command in PowerShell inspect `$LASTEXITCODE`; stop on nonzero. Do not continue from a failed identity/update step. Use only the selected context/file below. Do not use `--raw` or print complete credential configuration.

Shared Bash/PowerShell reads:
```bash
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe config view --minify --output 'jsonpath={.clusters[0].cluster.server}'
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe get pods --all-namespaces --output wide
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe get services --all-namespaces --output wide
```
Choose actual names, not an invented example:
```bash
Namespace="REPLACE_FROM_AUTHORIZED_SERVICE_LIST"
ServiceName="REPLACE_FROM_AUTHORIZED_SERVICE_LIST"
```
```powershell
$Namespace = "REPLACE_FROM_AUTHORIZED_SERVICE_LIST"
$ServiceName = "REPLACE_FROM_AUTHORIZED_SERVICE_LIST"
```
Shared read-only object checks:
```bash
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe --namespace "$Namespace" describe service "$ServiceName"
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe --namespace "$Namespace" get service "$ServiceName" --output 'jsonpath={.spec.clusterIP}'
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe --namespace "$Namespace" get endpointslices --selector "kubernetes.io/service-name=$ServiceName" --output yaml
```

Examples only: endpoint `https://EXAMPLE.invalid` is NOT a working cluster. Pods table could show `shop web-abc 1/1 Running ... 10.42.16.21 node-a`; Service could show `shop web ClusterIP 172.20.50.10 <none> 80/TCP`; description could show `Port:80/TCP`, `TargetPort:8080/TCP`; EndpointSlice could contain `addresses:[10.42.16.21]`, `conditions: {ready:true}`, `ports:[{port:8080,protocol:TCP}]`. Record YOUR readout. Match ServiceIP membership to the actual Service pool and the endpoint IP/port to the actual backend. Kubernetes RBAC Forbidden is different from AWS AccessDenied, expired login, TLS certificate failure, DNS failure or a network timeout. Ask for the narrow approved read; do not bypass validation or give yourself administrator access.

CLI/API boundary: the pinned AWS provider observes `data.aws_eks_cluster.existing` with endpoint and kubernetes_network_config outputs. It does not query Kubernetes Services/EndpointSlices through fake AWS data fields. Those are Kubernetes API reads; a future Kubernetes provider is a separate configured/authorized client, not introduced into this data-only AWS root. No apply/create in these commands.

Safe cleanup: no cloud object was created by this procedure. Remove ONLY your separately created local kubeconfig file when no longer needed (Bash `rm ./private-observation-kubeconfig.yaml`; PowerShell `Remove-Item ./private-observation-kubeconfig.yaml`) after confirming it is the file this procedure wrote. Do not remove default/shared kubeconfig, delete discovered Services or change endpoint configuration. Logging out does not delete cloud resources.

Existing course repository: https://github.com/ccaiccie/awseks — use supplied local Unit6A package; exact matching practice URL pending authorized publication/verification.

## ALB causal security and placement carry-forward
ALB = Application Load Balancer, an HTTP/HTTPS frontend. Internet-facing vs internal describes how clients reach the FRONTEND, not whether backends are secure. Verify DNS/routing and listener permission on the ALB security group, then independently permit the ALB security group at applicable backend target/node/Pod ENI security groups on BOTH the application and configured health-check ports. IP targets do not bypass applicable Pod/ENI SGs. Instance mode reaches NodePort and then the Pod-forwarding path. At least8 AVAILABLE addresses in EACH selected ALB subnet and /27 or larger are capacity prerequisites, not exactly8 allocated ENIs/IPs. Check the actual chosen subnets: internet-facing frontend placement normally public, internal frontend private per design. The offline private-subnet example assumes internal-ALB planning headroom; do not blindly treat that8 as current consumption in every private subnet. Deep deployment remains Unit12. Full existing-object CLI and optional pinned-provider ALB/listener/rule/target-group data are supplied; live per-target health remains CLI-only.

## Why aws-auth, and when NOT to use it
A ConfigMap is a Kubernetes object for named configuration. Deprecated legacy aws-auth maps IAM principal identifiers to Kubernetes usernames/groups, historically including nodes; it is NOT credentials and not blanket administrator permission. EKS access entries are recommended. Actual authenticationMode CONFIG_MAP/API_AND_CONFIG_MAP/API determines supported paths. RBAC or configured EKS access policies authorize operations. API-only need not have aws-auth. Read only when authorized/relevant; never create/edit it here.
```bash
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.accessConfig' --output json --no-cli-pager
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe --namespace kube-system get configmap aws-auth --output yaml
```
The first command reads AWS metadata. Only in a relevant legacy mode and with existing Kubernetes permission run the second. Output is private principal/group metadata, not a working sample to apply. NotFound may be normal; Forbidden is authorization failure. Do not paste roles into a map to fix a tutorial.

## Actual ServiceIP membership — choose ONE shell
These capture ACTUAL successful readouts in the explicitly selected context, then compare locally; no creation or apply. Complete script is supplied. Stop on failure, and inspect Service type for headless/ExternalName skips.
```bash
ServiceCidr=$(aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.kubernetesNetworkConfig.serviceIpv4Cidr' --output text --no-cli-pager) || exit 1
ServiceIp=$(kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe --namespace "$Namespace" get service "$ServiceName" --output 'jsonpath={.spec.clusterIP}') || exit 1
python3 scripts/service_membership.py "$ServiceCidr" "$ServiceIp"
```
```powershell
$ServiceCidr = aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.kubernetesNetworkConfig.serviceIpv4Cidr' --output text --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw "STOP: Service pool read failed" }
$ServiceIp = kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe --namespace "$Namespace" get service "$ServiceName" --output 'jsonpath={.spec.clusterIP}'
if ($LASTEXITCODE -ne 0) { throw "STOP: Service read failed" }
py -3 scripts/service_membership.py "$ServiceCidr" "$ServiceIp"
if ($LASTEXITCODE -ne 0) { throw "STOP: Service membership check failed" }
```

The genuine pinned data.aws_eks_cluster.existing output also includes endpoint and access_config (authentication mode and creator-bootstrap flag). These observe the same existing settings as AWS describe-cluster; they do not grant access or change bootstrap permissions.
