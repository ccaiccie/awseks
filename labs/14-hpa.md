# Lab 14 — Requests, limits, and HPA

## Objective

Show that HPA uses the metrics-server resource metrics, and that a pod without requests is not a CPU target.

## Architecture

metrics-server scrapes kubelets and serves the `metrics.k8s.io` API. The HPA controller reads that API. This is not the VPC and not kube-proxy. Stack 03 installs the chart with `--kubelet-insecure-tls` because the kubelet certificate is not in the chart's default trust. That flag skips verification of the kubelet. Do not copy it into a production cluster without a kubelet CA.

The Deployment requests 50m CPU and limits at 100m. The HPA target is 50% of the request, minimum 1, maximum 3. The node group max is 3 nodes, so this lab should scale pods, not the cluster. Karpenter is a different lab and is not required here.

## Prerequisites

Stack 03 with `enable_metrics_server = true`. `kubectl top nodes` returns numbers. If it errors on certificates, the chart values were changed. Read the stack README before you add more flags.

## Steps

```bash
kubectl apply -f manifests/lab14-hpa/hpa.yaml
kubectl -n lab-hpa rollout status deploy/web
kubectl top pods -n lab-hpa
kubectl -n lab-hpa get hpa web
kubectl -n lab-hpa describe hpa web
```

Generate load from a second pod in the namespace. This stays inside the cluster and does not open a load balancer.

```bash
kubectl -n lab-hpa run load --image=docker.io/nginxinc/nginx-unprivileged:1.29@sha256:18d5312e3b7e455cf9e4fb8becfc2dafaf98063dab542759c2a38708956574b7 \
  --restart=Never --command -- sleep 300
kubectl -n lab-hpa exec load -- sh -c 'for i in $(seq 1 40); do wget -qO- http://web.lab-hpa.svc.cluster.local/ >/dev/null; done'
kubectl -n lab-hpa get hpa web
```

The nginx image may not include a shell named `sh` on every variant. If exec fails, skip the loop and use `kubectl -n lab-hpa exec deploy/web -- wget -qO- http://127.0.0.1:8080` a few times. CPU may not cross 50%. That is a useful result: say so, and do not lower the target to 1% to force a scale.

## Expected observations

Example only. `kubectl top` shows millicores under the 50m request. The HPA prints `TARGETS` like `4%/50%` and `REPLICAS` stays 1. If the loop does push CPU over 50% of the request, replicas become 2 and then stop at 3. The node count stays 2 unless something else asked the node group to scale.

## Questions

1. Utilization is a fraction of which number, the request or the limit?
2. Why does the node group not have to scale for this HPA?
3. What does metrics-server have to do with the VPC CNI?

## Failure injection

Optional. Remove the CPU request from a copy of the Deployment and apply it. The HPA status becomes `FailedGetResourceMetric` or a similar message that the target has no request. Restore the file from git.

## Diagnostics

`kubectl top` error `Metrics API not available`: the APIService for metrics-server is missing. `kubectl -n kube-system logs deploy/metrics-server`. x509 errors are the kubelet TLS issue the chart flag is there for. HPA `<unknown>` for several minutes is normal on first scrape. A scale that never happens with high CPU means the metric is from a different container name.

## Answers

1. The request. The limit is the cgroup ceiling. HPA's 50% target is 25m if the request is 50m.
2. Three pods at 50m request fit on the two t3.medium nodes beside the system DaemonSets. Cluster autoscaling is the node group's `max_size`, or Karpenter in lab 15. HPA does not talk to EC2.
3. Nothing directly. metrics-server uses the Kubernetes API and the kubelet port. The pod network has to carry that scrape. It does not allocate the pod IP.

## Cleanup

```bash
kubectl delete namespace lab-hpa
```

## Cost

No new AWS resource if the node group does not scale. If you raised `maxReplicas` far enough to pressure the nodes, the managed group can add a third t3.medium up to `node_max_size`. Watch `kubectl get nodes` before you leave the lab.
