# Lab 02 — Pods, deployments, probes, config, limits

## Objective

Run a non-root demo and see the difference between a Pod and a Deployment.

## Prerequisites

A kubeconfig whose `current-context` is your lab cluster. Either path's verify step has passed.

## Diagram

[docs/diagrams/05-control-plane.svg](../docs/diagrams/05-control-plane.svg)

## Commands

```bash
kubectl config current-context
kubectl apply -f manifests/base/namespace.yaml
kubectl apply -f manifests/base/config.yaml
kubectl apply -f manifests/base/pod.yaml
kubectl wait -n lab --for=condition=Ready pod/demo --timeout=120s
kubectl describe pod -n lab demo
kubectl delete pod -n lab demo --wait=true
kubectl apply -f manifests/base/deployment.yaml
kubectl apply -f manifests/base/service-clusterip.yaml
kubectl rollout status deployment/demo -n lab --timeout=180s
kubectl exec -n lab deploy/demo -- wget -qO- 127.0.0.1:8080 | head
```

The container listens on 8080. The image digest is pinned in the manifest. Requests are 50m CPU and 64Mi memory. Limits are 200m and 128Mi. Probes use HTTP `/`. The root filesystem is read-only except an `emptyDir` at `/tmp`.

If `wget` is not in the image, the probe output in `kubectl describe` is the readiness signal instead. A failed exec is not a failed probe.

## Expected observation

The standalone Pod does not return after you delete it. The Deployment does. `Ready` is true only after the readiness probe succeeds. `DEMO_MESSAGE` is set only on the Deployment, from the ConfigMap.

## Question

Why can the readiness probe succeed while a Service still has no endpoints?

## Explanation

The probe talks to the container. Endpoints exist when the Pod is Ready and the Service selector matches. Apply the Service after the Deployment and `kubectl get endpoints -n lab demo` should list pod IPs from the VPC, not the ClusterIP.

## Safe failure

Change the readiness path to `/missing` in a copy of the manifest and apply it. The Pod stays unready and the Service drops it from endpoints. Restore the file from git. Do not point the probe at a privileged port.

## Troubleshooting

`ImagePullBackOff` is egress, not the probe. See lab 07. `CreateContainerConfigError` means the ConfigMap was not applied. Pod Security `restricted` on the namespace rejects a root user or added capabilities. The manifest is written for that policy.

## Cost

One extra pod's CPU and memory on nodes you are already paying for. No load balancer.

## Cleanup

```bash
kubectl delete -f manifests/base/deployment.yaml -f manifests/base/service-clusterip.yaml --wait=true
```
