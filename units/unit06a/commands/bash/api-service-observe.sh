# REFERENCE ONLY: run one reviewed step at a time; skip if no authorized existing cluster.
# OPTIONAL: only an existing authorized cluster; otherwise skip all these reads.
ClusterName="REPLACE_FROM_AUTHORIZED_EXISTING_CLUSTER_LIST"
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.endpoint' --output text --no-cli-pager
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.resourcesVpcConfig.{Public:endpointPublicAccess,Private:endpointPrivateAccess,PublicCIDRs:publicAccessCidrs,ClusterSG:clusterSecurityGroupId}' --output json --no-cli-pager
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.kubernetesNetworkConfig.serviceIpv4Cidr' --output text --no-cli-pager
# Only with existing Kubernetes read authorization; this writes a SEPARATE LOCAL kubeconfig.
aws eks update-kubeconfig --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --kubeconfig ./private-observation-kubeconfig.yaml --alias unit06a-observe

kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe config view --minify --output 'jsonpath={.clusters[0].cluster.server}'
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe get pods --all-namespaces --output wide
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe get services --all-namespaces --output wide

Namespace="REPLACE_FROM_AUTHORIZED_SERVICE_LIST"
ServiceName="REPLACE_FROM_AUTHORIZED_SERVICE_LIST"
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe --namespace "$Namespace" describe service "$ServiceName"
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe --namespace "$Namespace" get service "$ServiceName" --output 'jsonpath={.spec.clusterIP}'
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe --namespace "$Namespace" get endpointslices --selector "kubernetes.io/service-name=$ServiceName" --output yaml

# Optional legacy-map reads only when relevant/authorized; NEVER edit.
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.accessConfig' --output json --no-cli-pager
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe --namespace kube-system get configmap aws-auth --output yaml

ServiceCidr=$(aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.kubernetesNetworkConfig.serviceIpv4Cidr' --output text --no-cli-pager) || exit 1
ServiceIp=$(kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe --namespace "$Namespace" get service "$ServiceName" --output 'jsonpath={.spec.clusterIP}') || exit 1
python3 scripts/service_membership.py "$ServiceCidr" "$ServiceIp"
