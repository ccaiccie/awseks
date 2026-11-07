# IAM, access entries, and PassRole

Four identities stay distinct.

| Identity | Who uses it | What it must not be |
| --- | --- | --- |
| Cluster role | `eks.amazonaws.com`, to manage ENIs and the control plane | A role you assume to run kubectl |
| Node role | kubelet and the Pod Identity agent on the instance | A workload role, and not cluster-admin |
| Human principal | You, through an access entry | The node role |
| Pod Identity or IRSA role | One service account | The node role and not an access-entry admin |

## Access entries

Authentication mode is `API`. The `aws-auth` ConfigMap is not the control. With `API`, a managed node group gets an access entry of type `EC2_LINUX` for the node role. That type is how the node joins. It is not `AmazonEKSClusterAdminPolicy`. The Terraform path does not create a second entry for the node role, because a duplicate principal fails. The CLI path lists entries and creates `EC2_LINUX` only if the node role is missing.

`bootstrap_cluster_creator_admin_permissions` defaults to true so the caller who creates the cluster can use kubectl. That grants the creator the cluster-admin access policy. It does not grant it to every principal in the account. Set `extra_admin_principal_arn` if a different role should be admin, and leave the creator flag on unless that ARN is set. A viewer ARN, if you set one, gets `AmazonEKSViewPolicy` only.

Kubernetes RBAC still exists. An access policy is not a `RoleBinding`. You can add a `Role` later for a namespace without giving the IAM principal `eks:*`.

## PassRole

`eks:CreateCluster` does not make EKS use your credentials as the cluster role. You pass the cluster role to `eks.amazonaws.com`. `eks:CreateNodegroup` passes the node role the same way. Without `iam:PassRole` on those role ARNs, create calls fail even if you have `eks:CreateCluster`.

The condition used in [policies/operator-baseline.json](../policies/operator-baseline.json) is:

```json
"Condition": {
  "StringEquals": {
    "iam:PassedToService": "eks.amazonaws.com"
  }
}
```

The resource is `arn:aws:iam::ACCOUNT:role/awseks-*`, not `*`. Self-managed nodes would also pass a role to `ec2.amazonaws.com` for an instance profile. This lab uses managed node groups, and EKS creates the instance profile. Do not create one yourself.

## Pod Identity

Trust policy, from the EKS Pod Identity role page:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "pods.eks.amazonaws.com"},
    "Action": ["sts:AssumeRole", "sts:TagSession"],
    "Condition": {
      "StringEquals": {
        "aws:RequestTag/kubernetes-namespace": "kube-system",
        "aws:RequestTag/kubernetes-service-account": "ebs-csi-controller-sa"
      }
    }
  }]
}
```

The controller role uses the same shape with service account `aws-load-balancer-controller`. The association is per cluster. The agent on the node calls EKS Auth. Pods do not use the node role when hop limit is 1.

The agent must reach `eks-auth`. With a NAT, that is the public AWS API. With `nat_strategy = none`, the interface endpoint `com.amazonaws.<region>.eks-auth` is part of the set the lab creates. The agent does not use `service_account_role_arn` (that argument is IRSA).

## IRSA

IRSA is a different mechanism. The cluster has an OIDC issuer. You create an IAM OIDC provider and a role whose trust is `sts:AssumeRoleWithWebIdentity`, conditioned on `aud` `sts.amazonaws.com` and `sub` `system:serviceaccount:namespace:name`. The pod needs a projected service account token. Pod Identity does not need that provider.

This lab does not create the OIDC provider in the default apply, so the default path cannot be half IRSA and half Pod Identity by accident. The IRSA exercise is in [labs/06-iam.md](../labs/06-iam.md) and is optional. Commands there use the issuer from `aws eks describe-cluster`.

## Moving the CNI off the node role

Leave `vpc_cni_use_pod_identity` false until the Pod Identity agent is ACTIVE and nodes are Ready. A first apply that withholds `AmazonEKS_CNI_Policy` from the node and also waits for the agent before installing `aws-node` can leave nodes `NotReady`. The second apply attaches the policy to a role trusted by `aws-node` and drops it from the node role. `aws-node` is host-networked, so it can still start while the agent becomes ready. Watch `kubectl get pods -n kube-system -l k8s-app=aws-node` after that apply.

## What is intentionally not granted

No `AdministratorAccess`, no `iam:*`, no `eks:*` on `*`, and no access policy on the node role. The account-root `kms:*` statement exists only inside the optional secrets key policy so the key can be administered. It is off unless `encrypt_kubernetes_secrets` is true.
