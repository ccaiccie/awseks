# Lab 01 — VPC and routing

## Objective

Show the default route of a private subnet, and explain what a single NAT gateway fails when its AZ fails.

## Architecture

Use the VPC figure in [docs/DIAGRAMS.md](../docs/DIAGRAMS.md). The context under that figure is the one that matches this stack.

## Prerequisites

Stack 01 applied. `terraform output` in `terraform/stacks/01-network` prints a VPC id and two private subnet ids.

## Steps

```bash
cd terraform/stacks/01-network
terraform output
VPC="$(terraform output -raw vpc_id)"
aws ec2 describe-route-tables \
  --filters Name=vpc-id,Values="$VPC" Name=tag:Name,Values='*private*' \
  --query 'RouteTables[].Routes'
aws ec2 describe-nat-gateways \
  --filter Name=vpc-id,Values="$VPC" Name=state,Values=available \
  --query 'NatGateways[].{Id:NatGatewayId,Subnet:SubnetId,AZ:SubnetId}'
aws ec2 describe-vpc-endpoints \
  --filters Name=vpc-id,Values="$VPC" \
  --query 'VpcEndpoints[].{Type:VpcEndpointType,Service:ServiceName}'
```

The NAT query above does not return the AZ. Describe the subnet id from the NAT and read its `AvailabilityZone`.

## Expected observations

Example only. Two private route tables each contain `0.0.0.0/0` pointing at the same `nat-` id, plus a prefix-list route for S3. `describe-vpc-endpoints` shows one Gateway endpoint for S3 and no Interface endpoints. `describe-nat-gateways` returns one gateway.

## Questions

1. Which subnets have `kubernetes.io/role/elb=1`, and why are the workers not in them?
2. If the NAT gateway's AZ is unhealthy, which pods lose internet egress?
3. Does the S3 gateway endpoint use a security group?

## Failure injection

Do not delete the NAT gateway. In a second window, only if the instructor agrees, set `nat_gateway_per_az = true`, plan, and read the extra NAT and EIP. Apply only if the room has accepted the cost. Otherwise stop at the plan.

## Diagnostics

`terraform state list` should show the VPC module, one NAT, and `aws_vpc_endpoint.s3`. A private route of `0.0.0.0/0` to an internet gateway means the subnet is not private. Stop and re-read the plan before using that VPC for nodes.

## Answers

1. The public subnets carry `kubernetes.io/role/elb=1`. The AWS Load Balancer Controller places internet-facing load balancers there. Workers use `kubernetes.io/role/internal-elb=1` subnets so they do not receive public addresses.
2. All of them. Both private route tables default to that one NAT.
3. No. A gateway endpoint is a route. Interface endpoints, which this lab leaves off, use a security group.

## Cleanup

Leave the VPC up for the rest of the class.

## Cost

One NAT gateway hour is running from the moment stack 01 applied. See `docs/COST.md`.
