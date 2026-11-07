# Stack 04 — Karpenter, optional

Default apply creates nothing. Set `enable_karpenter = true` and `karpenter_confirmation = "enable-karpenter"` only while teaching lab 15.

The chart pin is 1.15.1. The stack refuses other versions unless `allow_untested_karpenter_version` is true. Read https://karpenter.sh/docs/upgrading/compatibility/ first.

The NodePool and EC2NodeClass are `manifests/lab15-karpenter/nodepool.yaml`. They are applied with kubectl after the CRDs from the Helm release exist. They are not in this state, which avoids a plan that creates custom resources before the CRD is installed.

Controller requests are 100m CPU and 256Mi, smaller than the upstream getting-started sample of 1 CPU and 1Gi, so the request fits on a t3.medium beside the system pods.
