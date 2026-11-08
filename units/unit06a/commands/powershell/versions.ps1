# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
aws eks describe-cluster-versions --profile "$AwsProfile" --region "$Region" --version-status STANDARD_SUPPORT --query 'clusterVersions[].{Version:clusterVersion,Status:versionStatus,EndStandard:endOfStandardSupportDate}' --output table --no-cli-pager
$K8sVersion = "REPLACE_FROM_VERSION_READOUT"
aws eks describe-addon-versions --profile "$AwsProfile" --region "$Region" --kubernetes-version "$K8sVersion" --addon-name vpc-cni --output json --no-cli-pager
