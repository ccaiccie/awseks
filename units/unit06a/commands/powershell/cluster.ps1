# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
aws eks list-clusters --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
$ClusterName = "REPLACE_WITH_AUTHORIZED_EXISTING_CLUSTER"
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.{Name:name,Version:version,Status:status,Network:resourcesVpcConfig,Service:kubernetesNetworkConfig,Support:upgradePolicy}' --output json --no-cli-pager
aws eks list-addons --profile "$AwsProfile" --region "$Region" --cluster-name "$ClusterName" --output json --no-cli-pager
aws eks describe-addon --profile "$AwsProfile" --region "$Region" --cluster-name "$ClusterName" --addon-name vpc-cni --output json --no-cli-pager
