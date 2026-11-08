# Draft practice progression, Units 2–8 (same `web` program throughout)

Rule for every unit: a command appears only **after** the lesson has taught the concept it practices.
Each step is introduced with the same parts as Unit 1: where, why and flags, the command, expected output, what to observe, recovery.
Later units are drafts and are not yet narrated. Commands are named here, not yet written out step by step.

## Unit 2: from one container to Kubernetes (local, no AWS, no cost)

**Taught first:**
- why many copies on many computers need a controller
- Pod contains container
- desired state
- Deployment → ReplicaSet → Pods
- Service as a stable front door

**Environment.** One local Kubernetes, so learners never touch a cloud account to learn the objects:
- **kind** (Kubernetes in Docker; reuses the Docker installed in Unit 1), or
- Docker Desktop's built-in Kubernetes.

We pick one and teach only that. **kind** is preferred, because the same commands work on Windows, macOS and Linux.

| Beat | Practice | Observe |
|---|---|---|
| 2.1 | `kubectl version`, `kubectl get nodes` | the client and the cluster are separate; a node is a computer (here a container acting as one) |
| 2.2 | Make `web:1.0` available to the cluster (`kind load docker-image web:1.0`) | the cluster's nodes have their own image store; they do not see your laptop's images automatically |
| 2.3 | `kubectl apply -f pod.yaml` (one Pod, image `web:1.0`), `kubectl get pods -o wide` | Pod → node placement; the Pod's own IP |
| 2.4 | `kubectl port-forward pod/web 8080:8080` + `curl` | same greeting; port-forward is a learning tool, not exposure |
| 2.5 | Delete the Pod and see that nothing recreates it | a bare Pod has no controller |
| 2.6 | `deployment.yaml` with `replicas: 3`; delete one Pod; `kubectl get pods -w` | desired state: the controller replaces it |
| 2.7 | `service.yaml` (ClusterIP), then curl it from a temporary Pod | stable name and address in front of changing Pods |
| 2.8 | Cleanup: `kubectl delete -f .`, `kind delete cluster` | only this exercise's objects |

## Unit 3: Kubernetes actors and the control path

**Taught first:** API server, etcd, scheduler, controllers, kubelet and containerd.
This is where the deferred Unit 1 comparison returns: **Docker tooling versus kubelet + containerd on a node**,
introduced only after each actor's purpose has been taught, with larger sequential pictures.

| Beat | Practice | Observe |
|---|---|---|
| 3.1 | `kubectl apply` a Deployment, then `kubectl get events --sort-by=.lastTimestamp` | stored → scheduled → image pulled → container started |
| 3.2 | `kubectl describe pod <name>`: Events section | which actor did each step |
| 3.3 | Optional, kind only: `docker exec -it <kind-node> crictl ps` | the node runs containers through containerd (CRI), not through `docker run` |
| 3.4 | Scale with `kubectl scale`, and then by editing `replicas`; compare | imperative versus declarative |

## Unit 4: lifecycle, configuration and data

| Beat | Practice | Observe |
|---|---|---|
| 4.1 | `kubectl logs`; trigger a crash (bad CMD in `web:1.2`) and read `CrashLoopBackOff` | restart versus replacement |
| 4.2 | Put the greeting in a **ConfigMap**, mounted as `/app/greeting.txt` | configuration without rebuilding the image (contrast with Unit 1 Step 8) |
| 4.3 | Readiness and liveness probes on `/` | Ready versus running |
| 4.4 | `visits.log` in the writable layer → `emptyDir` → PersistentVolumeClaim | what survives a container restart, a Pod deletion, a node change |

## Unit 5: what Amazon EKS manages (explain before any AWS command)

**Taught first:**
- the AWS-managed control plane versus your worker nodes in your VPC
- shared responsibility
- managed add-ons
- in our standard Linux EC2-worker example, nodes use containerd. Kubernetes does not require Docker Engine. Other EKS compute options exist and are not covered here.

Practice here is **read-only and local**:
- the same Unit 2–4 YAML files, unchanged except the image reference
- a walk through what would change: the image comes from Amazon ECR, the cluster from EKS

No AWS resources are created in Unit 5.

## Unit 6: safe practice setup on AWS (the first unit that can cost money)

Before any command, the lesson explains what costs money and why. It explains, does not narrate project status:

- **EKS control plane.** Billed per cluster-hour while the cluster exists, even when no Pods run.
- **EC2 worker nodes and their EBS disks.** Billed while running. Stopping your laptop does not stop them.
- **NAT gateway, load balancers, public IPv4 addresses.** Billed per hour and per GB processed. These are commonly forgotten.
- **ECR storage, CloudWatch logs.** Small, but billed per GB-month.
- **Prices change.** Learners read the current AWS pricing pages for their Region, and set a budget alert first.
- **Cleanup is part of the exercise.** The cleanup script, then a check that nothing is left: clusters, node groups, load balancers, NAT gateways, elastic IPs.

Then the accepted ordered lab:
1. `config.env`
2. `00-preflight.sh` (account identity confirmation)
3. review the cost, then **edit** `COST_ACK` in `config.env` and `source config.env` again
4. `01-network.sh`
5. roles / trust / PassRole explanation
6. `02-cluster.sh`
7. `03-access.sh`
8. `04-app.sh`

The guards stay. Nothing is silently acknowledged.

## Units 7–8+: networking, exposure, identity, policy, storage, scaling

These follow the same pattern, on the EKS practice cluster only after Unit 6:
- every command is preceded by its concept
- per-hop packet flows use the existing animation engine
- each unit ends with its own targeted cleanup
