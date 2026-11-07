#!/usr/bin/env python3
"""Render teaching diagrams as Mermaid, SVG, and draw.io from one layout.

These are lab diagrams for this repository. They are not the animated class
diagrams. Those arrive later under docs/class-incoming/.
"""

from pathlib import Path
import html

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "diagrams"
SRC = OUT / "sources"

FILLS = {
    "vpc": "#E8F2FC",
    "public": "#E5F6E8",
    "private": "#FFF4E0",
    "aws": "#F3E8FF",
    "k8s": "#E7F7F7",
    "deny": "#FDECEC",
    "id": "#EEF2FF",
    "note": "#F7F7F5",
}


def box(x, y, w, h, text, fill="note"):
    return {"x": x, "y": y, "w": w, "h": h, "text": text, "fill": FILLS[fill]}


def edge(a, b, label=""):
    return {"a": a, "b": b, "label": label}


DIAGRAMS = [
    {
        "id": "01-architecture",
        "title": "Standard EKS lab layout",
        "mermaid": """flowchart TB
  subgraph vpc [VPC 10.0.0.0/16]
    igw[Internet gateway]
    subgraph public [Public subnets]
      nat[NAT gateway]
      lb[Public or internal load balancer]
    end
    subgraph private [Private subnets in at least two AZs]
      cp[EKS control plane ENIs]
      nodes[Managed nodes AL2023]
      pods[Pods with VPC IPs]
    end
  end
  api[Private API always on]
  igw --> nat
  nat --> nodes
  nodes --> pods
  cp --> nodes
  lb --> nodes
  api --> cp
""",
        "boxes": [
            box(40, 40, 920, 520, "", "vpc"),
            box(70, 70, 860, 36, "VPC 10.0.0.0/16  ·  DNS hostnames on  ·  tagged awseks-practice", "vpc"),
            box(70, 130, 400, 160, "Public subnets\nInternet gateway default route\nNAT gateway lives here\nLoad balancer ENIs can live here", "public"),
            box(500, 130, 430, 160, "Private subnets, two or three AZs\nNo public IPv4 on nodes\nControl plane ENIs and worker nodes", "private"),
            box(70, 330, 250, 90, "EKS API\nprivate endpoint on\npublic endpoint optional", "aws"),
            box(350, 330, 250, 90, "Managed node group\nAL2023, no SSH key\nIMDSv2 hop limit 1", "k8s"),
            box(630, 330, 270, 90, "Pods get VPC IPs\nfrom the VPC CNI\nService CIDR is not a subnet", "k8s"),
            box(70, 450, 830, 70, "S3 gateway endpoint is on by default. Interface endpoints are optional and cost money. One NAT is cheaper and fails with that AZ.", "note"),
        ],
        "edges": [],
    },
    {
        "id": "02-api-access",
        "title": "Private API and optional public allow list",
        "mermaid": """flowchart LR
  laptop[Operator laptop]
  publicEp[Public API endpoint]
  privateEp[Private API endpoint]
  eni[Control plane ENIs]
  bastion[In-VPC client]
  laptop -->|"only if CIDR is listed"| publicEp
  bastion --> privateEp
  publicEp --> eni
  privateEp --> eni
""",
        "boxes": [
            box(40, 80, 200, 80, "Operator laptop", "id"),
            box(320, 40, 240, 80, "Public endpoint\noff unless a CIDR is set", "aws"),
            box(320, 160, 240, 80, "Private endpoint\nalways enabled", "aws"),
            box(640, 100, 240, 90, "Control plane ENIs\ncluster security group\nplus the VPC API group", "k8s"),
            box(40, 220, 200, 80, "Client inside the VPC", "private"),
            box(320, 280, 560, 70, "0.0.0.0/0 is rejected. A public endpoint without your /32 does not let you in.", "note"),
        ],
        "edges": [edge(0, 1, "allow list"), edge(4, 2, "TCP 443"), edge(1, 3), edge(2, 3)],
    },
    {
        "id": "03-iam-access-rbac",
        "title": "Human IAM, access entries, and RBAC",
        "mermaid": """flowchart TB
  human[IAM role or user]
  api[EKS access entry mode API]
  policy[EKS access policy or Kubernetes RBAC]
  nodeRole[Node IAM role]
  human --> api --> policy
  nodeRole --> api
""",
        "boxes": [
            box(40, 40, 250, 80, "Human IAM principal\ncreator or named role", "id"),
            box(340, 40, 250, 80, "Access entry\ntype STANDARD", "aws"),
            box(640, 40, 280, 80, "AmazonEKSClusterAdminPolicy\nor View, or your own RBAC", "k8s"),
            box(40, 180, 250, 90, "Node IAM role\ntype EC2_LINUX\nnot cluster-admin", "private"),
            box(340, 180, 250, 90, "Workload role\nPod Identity or IRSA\nnot a human entry", "id"),
            box(640, 180, 280, 90, "Kubernetes RBAC\nRole and RoleBinding\nstill apply inside the cluster", "k8s"),
            box(40, 310, 880, 60, "Authentication mode API does not use the aws-auth ConfigMap. IAM is not the same check as a Kubernetes verb.", "note"),
        ],
        "edges": [edge(0, 1), edge(1, 2), edge(3, 1, "node join"), edge(4, 5, "pod calls")],
    },
    {
        "id": "04-workload-identity",
        "title": "Node role, Pod Identity, and IRSA",
        "mermaid": """flowchart LR
  pod[Pod]
  agent[Pod Identity agent]
  eksauth[EKS Auth API]
  role[IAM role]
  oidc[OIDC provider]
  pod --> agent --> eksauth --> role
  pod -.-> oidc
""",
        "boxes": [
            box(40, 50, 200, 80, "Pod\nservice account", "k8s"),
            box(280, 40, 220, 90, "Pod Identity agent\n169.254.170.23\nhost network", "aws"),
            box(540, 40, 200, 90, "IAM role\ntrust pods.eks", "id"),
            box(280, 180, 220, 90, "IRSA path\nprojected SA token\nOIDC provider", "note"),
            box(540, 180, 200, 90, "Node role via IMDS\nhop limit 1 blocks pods", "deny"),
            box(40, 180, 200, 90, "Human access entry\ndoes not grant this", "id"),
        ],
        "edges": [edge(0, 1), edge(1, 2, "AssumeRole"), edge(0, 3, "optional IRSA")],
    },
    {
        "id": "05-control-plane",
        "title": "Control plane and a Deployment",
        "mermaid": """flowchart TB
  user[kubectl] --> api[kube-apiserver]
  api --> etcd[etcd managed by EKS]
  api --> sched[scheduler]
  sched --> kubelet[kubelet on a node]
  kubelet --> pod[Pod]
""",
        "boxes": [
            box(40, 40, 180, 70, "kubectl", "id"),
            box(260, 40, 200, 70, "kube-apiserver", "aws"),
            box(500, 40, 180, 70, "etcd", "aws"),
            box(720, 40, 200, 70, "scheduler", "aws"),
            box(260, 160, 200, 70, "controller manager", "aws"),
            box(500, 160, 200, 70, "kubelet", "private"),
            box(740, 160, 180, 70, "Pod", "k8s"),
            box(40, 270, 880, 60, "You do not SSH to the control plane. A Deployment is desired state. The controllers reconcile it.", "note"),
        ],
        "edges": [edge(0, 1), edge(1, 2), edge(1, 3), edge(1, 4), edge(3, 5), edge(5, 6)],
    },
    {
        "id": "06-vpc-cni",
        "title": "VPC CNI same-node and cross-node",
        "mermaid": """flowchart LR
  podA[Pod A ENI IP] --> nodeA[Node A]
  podB[Pod B secondary IP] --> nodeA
  podC[Pod C on node B] --> nodeB[Node B]
  nodeA --> nodeB
""",
        "boxes": [
            box(40, 40, 280, 200, "Node A\nprimary ENI\nsecondary IPs for pods", "private"),
            box(80, 100, 90, 50, "Pod A", "k8s"),
            box(190, 100, 90, 50, "Pod B", "k8s"),
            box(400, 40, 280, 200, "Node B\nanother subnet or same VPC", "private"),
            box(470, 100, 90, 50, "Pod C", "k8s"),
            box(40, 270, 640, 70, "Same-node pods bridge on the node. Cross-node packets are VPC routed between ENIs. They are not ClusterIP DNAT.", "note"),
        ],
        "edges": [edge(1, 2, "same node"), edge(2, 4, "VPC route")],
    },
    {
        "id": "07-service-clusterip",
        "title": "CoreDNS, ClusterIP, DNAT, and conntrack",
        "mermaid": """flowchart LR
  pod[Pod] --> dns[CoreDNS ClusterIP]
  dns --> svc[Service ClusterIP]
  svc --> dnat[kube-proxy DNAT]
  dnat --> target[Endpoint pod]
  target --> conn[conntrack return]
""",
        "boxes": [
            box(30, 50, 150, 70, "Client pod", "k8s"),
            box(220, 40, 180, 80, "CoreDNS\nservice kube-dns", "aws"),
            box(440, 40, 180, 80, "ClusterIP\n172.20.0.0/16", "k8s"),
            box(660, 40, 180, 80, "kube-proxy rules\nDNAT to endpoint", "private"),
            box(440, 170, 180, 70, "Endpoint pod", "k8s"),
            box(660, 170, 180, 70, "conntrack\nreturn path", "note"),
            box(30, 270, 810, 60, "The service CIDR is not in the VPC route table. kube-proxy programs the node. CoreDNS answers the name.", "note"),
        ],
        "edges": [edge(0, 1, "DNS"), edge(1, 2), edge(2, 3), edge(3, 4), edge(4, 5)],
    },
    {
        "id": "08-alb-nlb",
        "title": "ALB and NLB target types",
        "mermaid": """flowchart TB
  client[Client] --> alb[ALB]
  client --> nlb[NLB]
  alb --> ip[target-type ip: pod ENI]
  alb --> inst[target-type instance: node port]
  nlb --> ip
  nlb --> inst
""",
        "boxes": [
            box(40, 40, 160, 60, "Client", "id"),
            box(250, 30, 220, 70, "ALB\nHTTP rules", "public"),
            box(520, 30, 220, 70, "NLB\nTCP or UDP", "public"),
            box(250, 150, 220, 80, "target-type ip\npod IP and port", "k8s"),
            box(520, 150, 220, 80, "target-type instance\nnode IP and NodePort", "private"),
            box(40, 270, 700, 60, "Both sample manifests are internal. Apply one at a time. Instance mode needs the NodePort path open in the security group.", "note"),
        ],
        "edges": [edge(0, 1), edge(0, 2), edge(1, 3, "ip"), edge(2, 4, "instance")],
    },
    {
        "id": "09-nat-endpoints",
        "title": "NAT, ECR, and S3",
        "mermaid": """flowchart LR
  node[Private node] --> nat[NAT gateway]
  nat --> ecr[ECR public API]
  node --> s3ep[S3 gateway endpoint]
  node --> ecrep[ECR interface endpoints]
  ecr --> s3[S3 layer buckets]
""",
        "boxes": [
            box(40, 80, 180, 80, "Private node\npulls an image", "private"),
            box(280, 30, 200, 70, "NAT gateway\n0.0.0.0/0 route", "public"),
            box(540, 30, 220, 70, "Public ECR and S3\nif no interface endpoint", "aws"),
            box(280, 150, 200, 80, "S3 gateway endpoint\nprefix list, no hourly fee", "k8s"),
            box(540, 150, 220, 80, "Interface endpoints\necr.api and ecr.dkr", "aws"),
            box(40, 270, 720, 60, "Image layers live in S3. ECR API and ECR DKR without an S3 path still fail. eks-auth is a different endpoint.", "note"),
        ],
        "edges": [edge(0, 1), edge(1, 2), edge(0, 3, "layers"), edge(0, 4, "optional")],
    },
    {
        "id": "10-sg-networkpolicy",
        "title": "Security groups and NetworkPolicy",
        "mermaid": """flowchart TB
  pkt[Packet] --> sg[Security group on ENI]
  sg --> nacl[Network ACL on subnet]
  nacl --> np[NetworkPolicy in the pod network]
""",
        "boxes": [
            box(40, 40, 200, 80, "Packet", "note"),
            box(280, 30, 240, 90, "Security group\nstateful, on the ENI", "aws"),
            box(560, 30, 240, 90, "Network ACL\nstateless, on the subnet\nlab leaves the default", "private"),
            box(280, 170, 240, 90, "NetworkPolicy\nVPC CNI enforcement\nnamespace lab only", "k8s"),
            box(560, 170, 240, 90, "Denied here\ndoes not change the route table", "deny"),
            box(40, 300, 760, 60, "A VPC route decides where a packet can go. A NetworkPolicy decides which pods may talk. IAM does neither.", "note"),
        ],
        "edges": [edge(0, 1), edge(1, 2), edge(1, 3), edge(3, 4, "deny")],
    },
    {
        "id": "11-storage-az",
        "title": "EBS volumes and Availability Zones",
        "mermaid": """flowchart LR
  pvc[PVC] --> sc[gp3 StorageClass]
  sc --> vol[EBS volume in one AZ]
  vol --> pod[Pod on a node in that AZ]
""",
        "boxes": [
            box(40, 50, 180, 70, "PVC", "k8s"),
            box(260, 40, 200, 80, "StorageClass gp3\nWaitForFirstConsumer\nprovisioner ebs.csi.aws.com", "aws"),
            box(500, 40, 220, 80, "EBS volume\none Availability Zone", "private"),
            box(500, 160, 220, 70, "Pod scheduled\nin that same AZ", "k8s"),
            box(40, 250, 680, 60, "A volume cannot attach to a node in another AZ. Delete reclaim destroys the disk. Snapshot before cleanup if you care about the bytes.", "note"),
        ],
        "edges": [edge(0, 1), edge(1, 2), edge(2, 3)],
    },
    {
        "id": "12-scaling-upgrade",
        "title": "Scaling and upgrades",
        "mermaid": """flowchart TB
  hpa[HPA] --> deploy[Deployment replicas]
  ca[Cluster Autoscaler or Karpenter] --> nodes[Node count]
  deploy --> pdb[PodDisruptionBudget]
  upgrade[Node group upgrade] --> pdb
""",
        "boxes": [
            box(40, 40, 220, 70, "HPA\nmetrics-server", "k8s"),
            box(300, 40, 220, 70, "Deployment replicas", "k8s"),
            box(560, 40, 280, 70, "Managed node group\ndesired size", "private"),
            box(40, 160, 250, 80, "Cluster Autoscaler\noptional, fights Terraform\nif desired size is not ignored", "note"),
            box(330, 160, 250, 80, "Karpenter\noptional, Kubernetes 1.35\nneeds Karpenter >= 1.9", "note"),
            box(620, 160, 220, 80, "PDB and drain\nbefore surge or spot", "deny"),
            box(40, 280, 800, 50, "Do not run Cluster Autoscaler and Karpenter against the same capacity.", "note"),
        ],
        "edges": [edge(0, 1), edge(3, 2), edge(4, 2), edge(1, 5), edge(2, 5)],
    },
]


def esc(text):
    return html.escape(text)


def render_svg(diagram):
    boxes = diagram["boxes"]
    width = max(b["x"] + b["w"] for b in boxes) + 40
    height = max(b["y"] + b["h"] for b in boxes) + 40
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}" role="img">',
        "<title>" + esc(diagram["title"]) + "</title>",
        "<rect width='100%' height='100%' fill='#ffffff'/>",
        "<style>text{font-family:Helvetica,Arial,sans-serif;font-size:14px;fill:#1d2430} .title{font-size:18px;font-weight:700}</style>",
        f"<text class='title' x='24' y='28'>{esc(diagram['title'])}</text>",
    ]
    for item in boxes:
        parts.append(
            f"<rect x='{item['x']}' y='{item['y'] + 36}' width='{item['w']}' height='{item['h']}' rx='10' fill='{item['fill']}' stroke='#31415a' stroke-width='1.4'/>"
        )
        lines = [line for line in item["text"].split("\n") if line]
        if lines:
            start = item["y"] + 36 + item["h"] / 2 - (len(lines) - 1) * 9
            for index, line in enumerate(lines):
                parts.append(
                    f"<text x='{item['x'] + item['w'] / 2}' y='{start + index * 18}' text-anchor='middle'>{esc(line)}</text>"
                )
    parts.append("</svg>")
    return "\n".join(parts) + "\n"


def render_drawio(diagram):
    cells = [
        '<mxCell id="0"/>',
        '<mxCell id="1" parent="0"/>',
    ]
    for index, item in enumerate(diagram["boxes"], start=2):
        value = esc(item["text"]).replace("\n", "&#10;")
        style = (
            "rounded=1;whiteSpace=wrap;html=1;arcSize=8;strokeColor=#31415a;"
            f"fillColor={item['fill']};fontFamily=Helvetica;fontSize=13;align=center;verticalAlign=middle;"
        )
        cells.append(
            f'<mxCell id="{index}" value="{value}" style="{style}" vertex="1" parent="1">'
            f'<mxGeometry x="{item["x"]}" y="{item["y"] + 36}" width="{item["w"]}" height="{item["h"]}" as="geometry"/>'
            "</mxCell>"
        )
    next_id = len(diagram["boxes"]) + 2
    for link in diagram["edges"]:
        style = "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;endArrow=block;endFill=1;strokeColor=#31415a;"
        label = esc(link["label"])
        cells.append(
            f'<mxCell id="{next_id}" value="{label}" style="{style}" edge="1" parent="1" source="{link["a"] + 2}" target="{link["b"] + 2}">'
            '<mxGeometry relative="1" as="geometry"/>'
            "</mxCell>"
        )
        next_id += 1
    body = "".join(cells)
    return (
        '<mxfile host="app.diagrams.net" type="device">'
        f'<diagram id="{diagram["id"]}" name="{esc(diagram["title"])}">'
        '<mxGraphModel dx="1200" dy="800" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1169" pageHeight="826" math="0" shadow="0">'
        f"<root>{body}</root></mxGraphModel></diagram></mxfile>\n"
    )


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    SRC.mkdir(parents=True, exist_ok=True)
    for diagram in DIAGRAMS:
        (OUT / f"{diagram['id']}.mmd").write_text(diagram["mermaid"].strip() + "\n")
        (OUT / f"{diagram['id']}.svg").write_text(render_svg(diagram))
        (SRC / f"{diagram['id']}.drawio").write_text(render_drawio(diagram))
    print(f"wrote {len(DIAGRAMS)} diagrams")


if __name__ == "__main__":
    main()
