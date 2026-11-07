# Lab 11 — Private AWS endpoints, NAT, and ECR

## Objective

Trace an image pull and an STS call, and say which of those packets can avoid the NAT gateway.

## Architecture

Default stack 01 has a NAT gateway and an S3 gateway endpoint. ECR stores image layers in S3 in the same Region. The layer download can use the S3 gateway. The ECR API (`ecr.api`) and the registry API (`ecr.dkr`) still go to public endpoints through the NAT gateway unless you add interface endpoints.

Pod Identity calls the EKS Auth API. Without an `eks-auth` interface endpoint, that call uses NAT as well. IRSA calls STS.

Interface endpoints are off until you set `enable_interface_endpoints` and `interface_endpoint_confirmation = "enable-interface-endpoints"`. Each one is billed per AZ. Read `docs/COST.md` and the plan before you apply.

## Prerequisites

Stack 01. A pod that can pull the example image, which proves the default path works.

## Steps

```bash
VPC="$(terraform -chdir=terraform/stacks/01-network output -raw vpc_id)"
aws ec2 describe-vpc-endpoints --filters Name=vpc-id,Values="$VPC" \
  --query 'VpcEndpoints[].{Type:VpcEndpointType,Service:ServiceName,State:State}'
kubectl -n lab-fundamentals describe pod -l app.kubernetes.io/name=web | grep -n Image: || true
```

If lab 03 is already gone, the image pull evidence is the node `Ready` state and `aws-node` running. Those images came from ECR through the same path.

## Expected observations

Example only. One Gateway endpoint, service ending in `.s3`, state `available`. No `.ecr.api` or `.eks-auth` endpoint. Nodes are Ready, so the NAT path to ECR's API worked.

## Questions

1. Which of ECR API, ECR Docker, and S3 is already private in the default VPC?
2. What still fails if you remove the NAT gateway but forget `ecr.api`?
3. Why is the S3 endpoint a gateway endpoint rather than another interface endpoint?

## Failure injection

Do not delete the NAT gateway while the class is using the cluster. The safe demonstration is a plan:

```bash
# in terraform.tfvars for stack 01
# enable_interface_endpoints = true
# interface_endpoint_confirmation = "enable-interface-endpoints"
terraform -chdir=terraform/stacks/01-network plan
```

Read the interface endpoint count and the security group. Apply only if the cost was accepted. The endpoint security group allows TCP 443 from the VPC CIDR.

## Diagnostics

`ImagePullBackOff` with `i/o timeout` to `api.ecr` is the NAT or the missing interface endpoint. A timeout only on the layer blob, while the manifest succeeded, points at the S3 path. `aws ec2 describe-prefix-lists` and the private route table show whether the S3 prefix list is associated.

## Answers

1. S3, via the gateway endpoint. ECR API and ECR Docker are still public in the default design.
2. The node cannot authenticate to the registry or fetch the manifest. The S3 gateway does not answer the ECR API.
3. Gateway endpoints have no hourly charge and no ENI. AWS documents that as the way to keep S3 off the NAT gateway. Interface endpoints are the tool for APIs that are not on that gateway list.

## Cleanup

If you applied the endpoints, set `enable_interface_endpoints = false` and apply again before teardown so you are not billed after the discussion. Destroying stack 01 also removes them.

## Cost

Default path: NAT data processing for ECR API calls and anything that is not S3. Opt-in path: hourly interface endpoints in each private subnet's AZ. Count them in the plan.
