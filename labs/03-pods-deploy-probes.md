# Lab 03 — Pod, Deployment, probe, config

## Objective

Run the example web pod as uid 101, with a readiness probe, and see the Service send traffic only to a ready pod.

## Architecture

No AWS load balancer. The Service is ClusterIP. kube-proxy is described in lab 04. This lab stops at the pod.

## Prerequisites

Lab 02. Both nodes Ready. The image digest is the multi-arch index recorded in `docs/VERSIONS.md`.

## Steps

```bash
kubectl apply -f manifests/lab03-fundamentals/app.yaml
kubectl -n lab-fundamentals rollout status deploy/web
kubectl -n lab-fundamentals get pods -o wide
kubectl -n lab-fundamentals describe pod -l app.kubernetes.io/name=web | sed -n '/Readiness/,+6p'
kubectl -n lab-fundamentals exec deploy/web -- id
kubectl -n lab-fundamentals exec deploy/web -- wget -qO- http://127.0.0.1:8080
```

`wget` is in the nginx image. If it is not, use `kubectl port-forward` from your laptop:

```bash
kubectl -n lab-fundamentals port-forward svc/web 8080:80
```

Then request `http://127.0.0.1:8080/` on the machine where port-forward is running.

## Expected observations

Example only. Two pods Running, each `1/1` Ready, on different nodes if the scheduler can place them. `id` prints `uid=101`. The body is `practice web`. The container port is 8080. The Service port is 80.

## Questions

1. Why is the container port 8080 rather than 80?
2. What fails if `readOnlyRootFilesystem` is true and the emptyDir mounts are removed?
3. Which objects in this namespace will Terraform destroy later?

## Failure injection

Optional. Change the readiness path to `/missing` in a copy of the file and apply it. Watch `0/1` Ready and the endpoints list shrink. Restore the original file and apply it again.

```bash
kubectl -n lab-fundamentals get endpoints web
```

## Diagnostics

`ImagePullBackOff` means the node could not reach the registry through NAT or the VPC endpoints. `CreateContainerConfigError` on the ConfigMap means the name does not match. CrashLoop with a permission error on `/var/cache/nginx` means an emptyDir mount is missing.

## Answers

1. uid 101 cannot bind to port 80. The `nginxinc/nginx-unprivileged` image listens on 8080.
2. nginx needs to write its cache, pid, and temporary files. A read-only root without those mounts fails the start.
3. None. The namespace is labeled `awseks.practice/owner: student`. `scripts/delete-lab-workloads.sh` deletes it. Terraform does not have it in state.

## Cleanup

Leave the namespace until lab 04. Delete it before lab 19.

## Cost

Two extra containers on the nodes you already pay for. No load balancer.
