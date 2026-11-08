$ServiceCidr = aws eks describe-cluster --profile "$AwsProfile" --region "$Region" `
  --name "$ClusterName" --query 'cluster.kubernetesNetworkConfig.serviceIpv4Cidr' `
  --output text --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw "STOP: Service pool read failed" }
$ServiceIp = kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context `
  unit06a-observe --namespace "$Namespace" get service "$ServiceName" --output `
  'jsonpath={.spec.clusterIP}'
if ($LASTEXITCODE -ne 0) { throw "STOP: Service read failed" }
py -3 scripts/service_membership.py "$ServiceCidr" "$ServiceIp"
if ($LASTEXITCODE -ne 0) { throw "STOP: Service membership check failed" }
