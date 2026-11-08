# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
aws elbv2 describe-load-balancers --profile "$AwsProfile" --region "$Region" --query 'LoadBalancers[].{Name:LoadBalancerName,Arn:LoadBalancerArn,Type:Type,Scheme:Scheme,State:State.Code,Subnets:AvailabilityZones[].SubnetId}' --output json --no-cli-pager
# Continue ONLY if an authorized existing Type=application load balancer exists:
LoadBalancerArn="REPLACE_FROM_EXISTING_ALB_READOUT"
aws elbv2 describe-listeners --profile "$AwsProfile" --region "$Region" --load-balancer-arn "$LoadBalancerArn" --output json --no-cli-pager
ListenerArn="REPLACE_FROM_LISTENER_READOUT"
aws elbv2 describe-rules --profile "$AwsProfile" --region "$Region" --listener-arn "$ListenerArn" --output json --no-cli-pager
aws elbv2 describe-target-groups --profile "$AwsProfile" --region "$Region" --load-balancer-arn "$LoadBalancerArn" --output json --no-cli-pager
TargetGroupArn="REPLACE_FROM_TARGET_GROUP_READOUT"
aws elbv2 describe-target-health --profile "$AwsProfile" --region "$Region" --target-group-arn "$TargetGroupArn" --output json --no-cli-pager
