# Scene–chapter map (v2)

## Ch00 Orientation and safety — 9 scenes (0 demos)
- s0000 [lecture/hero] Welcome
- s0001 [lecture/concept] Managed service is not free
- s0002 [lecture/mechanism] Architecture map
- s0003 [lecture/concept] CLI versus Terraform ownership
- s0004 [lecture/command] Cost and create discipline preview
- s0005 [lecture/command] Preflight before create (eksclass-cli)
- s0006 [lecture/question] Why closing the laptop does not stop billing
- s0007 [lecture/takeaway] Why closing the laptop does not stop billing — answer
- s0008 [lecture/takeaway] Orientation takeaway

## Ch01 Linux and networks foundations — 15 scenes (9 demos)
- s0009 [lecture/hero] Linux and networks foundations
- s0010 [lecture/mechanism] Longest-prefix matching
- s0011 [lecture/concept] Security group versus network ACL
- s0012 [demo/flow] F04: Pod network namespace default route · F04_forward owner=a hop=[0, 0] dir=forward stop=False
- s0013 [demo/flow] F04: Linux FIB local Pod route · F04_forward owner=host hop=[0, 0] dir=forward stop=False
- s0014 [demo/flow] F04: Network policy + socket accept · F04_forward owner=c hop=[1, 1] dir=forward stop=False
- s0015 [demo/flow] F04: Linux FIB local Pod route · F04_return owner=host hop=[0, 0] dir=return stop=False
- s0016 [demo/flow] F05: Node ENI / CNI forwarding · F05_forward owner=a hop=[0, 0] dir=forward stop=False
- s0017 [demo/flow] F05: Subnet route lookup · F05_forward owner=vpc hop=[0, 0] dir=forward stop=False
- s0018 [demo/flow] F05: ENI SG / subnet NACL / Pod policy · F05_forward owner=b hop=[1, 1] dir=forward stop=False
- s0019 [demo/flow] F05: Subnet route lookup · F05_return owner=vpc hop=[0, 0] dir=return stop=False
- s0020 [demo/flow] F05: Stateful return + host Pod route · F05_return owner=a hop=[1, 1] dir=return stop=False
- s0021 [lecture/question] Winning prefix for Pod B
- s0022 [lecture/takeaway] Winning prefix for Pod B — answer
- s0023 [lecture/takeaway] Linux nets takeaway

## Ch02 Images to containers — 6 scenes (3 demos)
- s0024 [lecture/hero] Images to containers
- s0025 [lecture/concept] Tag versus digest and pull path
- s0026 [demo/flow] F03 exchange: Deployment watch and object writes · F03_sub1 owner=api hop=[0, 1] dir=subflow stop=False
- s0027 [demo/flow] F03 exchange: Kubelet watch and status · F03_sub2 owner=api hop=[0, 1] dir=subflow stop=False
- s0028 [demo/flow] F03 exchange: Registry image bytes · F03_sub3 owner=node hop=[0, 1] dir=subflow stop=False
- s0029 [lecture/takeaway] Images takeaway

## Ch03 Kubernetes object model — 14 scenes (9 demos)
- s0030 [lecture/hero] Kubernetes object model
- s0031 [lecture/mechanism] Reconciliation is asynchronous
- s0032 [demo/flow] F03: Kubernetes object submission · F03_forward owner=client hop=[0, 0] dir=forward stop=False
- s0033 [demo/flow] F03: Desired-state persistence · F03_forward owner=api hop=[0, 0] dir=forward stop=False
- s0034 [demo/flow] F03: Scheduling binding · F03_sub1 owner=sched hop=[0, 0] dir=forward stop=False
- s0035 [demo/flow] F03: CRI + CNI + CSI · F03_sub2 owner=node hop=[0, 0] dir=forward stop=False
- s0036 [demo/flow] F03: Registry IAM/TLS · F03_sub3 owner=registry hop=[0, 0] dir=forward stop=False
- s0037 [demo/flow] F03: Readiness status and watch updates · F03_sub2 owner=node hop=[0, 0] dir=return stop=False
- s0038 [demo/flow] F03 exchange: Deployment watch and object writes · F03_sub1 owner=api hop=[0, 1] dir=subflow stop=False
- s0039 [demo/flow] F03 exchange: Kubelet watch and status · F03_sub2 owner=api hop=[0, 1] dir=subflow stop=False
- s0040 [demo/flow] F03 exchange: Registry image bytes · F03_sub3 owner=node hop=[0, 1] dir=subflow stop=False
- s0041 [lecture/question] Delete one Pod
- s0042 [lecture/takeaway] Delete one Pod — answer
- s0043 [lecture/takeaway] Object model takeaway

## Ch04 Config and lifecycle — 6 scenes (0 demos)
- s0044 [lecture/hero] Config and lifecycle
- s0045 [lecture/mechanism] Mechanism — config projection
- s0046 [lecture/mechanism] Probes and drain
- s0047 [lecture/lab] Observable check — rollout and probes
- s0048 [lecture/command] Lifecycle lab pointers
- s0049 [lecture/takeaway] Config takeaway

## Ch05 EKS architecture — 4 scenes (0 demos)
- s0050 [lecture/hero] EKS architecture
- s0051 [lecture/mechanism] Mechanism — shared responsibility
- s0052 [lecture/lab] Worked example — describe the cluster boundary
- s0053 [lecture/takeaway] Architecture takeaway

## Ch06 Compute choice — 3 scenes (0 demos)
- s0054 [lecture/hero] Compute choice
- s0055 [lecture/mechanism] Variant matrix
- s0056 [lecture/takeaway] Compute takeaway

## Ch07 Plan VPC and IP budgets — 12 scenes (8 demos)
- s0057 [lecture/hero] Plan VPC and IP budgets
- s0058 [lecture/mechanism] Public versus private is routing
- s0059 [lecture/command] Build teaching VPC (eksclass-cli)
- s0060 [demo/flow] F05: Node ENI / CNI forwarding · F05_forward owner=a hop=[0, 0] dir=forward stop=False
- s0061 [demo/flow] F05: Subnet route lookup · F05_forward owner=vpc hop=[0, 0] dir=forward stop=False
- s0062 [demo/flow] F05: ENI SG / subnet NACL / Pod policy · F05_forward owner=b hop=[1, 1] dir=forward stop=False
- s0063 [demo/flow] F12: Default CNI off-VPC SNAT · F12_forward owner=node hop=[0, 0] dir=forward stop=False
- s0064 [demo/flow] F12: Private A subnet route lookup · F12_forward owner=node hop=[0, 0] dir=forward stop=False
- s0065 [demo/flow] F12: Stateful NAT translation · F12_forward owner=nat hop=[1, 1] dir=forward stop=False
- s0066 [demo/flow] F12: Public subnet route lookup · F12_forward owner=nat hop=[1, 1] dir=forward stop=False
- s0067 [demo/flow] F12: EIP address mapping · F12_forward owner=igw hop=[2, 2] dir=forward stop=False
- s0068 [lecture/takeaway] VPC plan takeaway

## Ch08 Build Standard cluster — 15 scenes (12 demos)
- s0069 [lecture/hero] Build Standard cluster
- s0070 [lecture/command] Create cluster and node group
- s0071 [demo/flow] F01: Local SigV4 token signing + TLS · F01_forward owner=client hop=[0, 0] dir=forward stop=False
- s0072 [demo/flow] F01: Endpoint public CIDR admission · F01_forward owner=api hop=[0, 0] dir=forward stop=False
- s0073 [demo/flow] F01: IAM authentication then authorization · F01_forward owner=api hop=[0, 0] dir=forward stop=False
- s0074 [demo/flow] F03: Kubernetes object submission · F03_forward owner=client hop=[0, 0] dir=forward stop=False
- s0075 [demo/flow] F03: Desired-state persistence · F03_forward owner=api hop=[0, 0] dir=forward stop=False
- s0076 [demo/flow] F03: Scheduling binding · F03_sub1 owner=sched hop=[0, 0] dir=forward stop=False
- s0077 [demo/flow] F03: CRI + CNI + CSI · F03_sub2 owner=node hop=[0, 0] dir=forward stop=False
- s0078 [demo/flow] F03: Registry IAM/TLS · F03_sub3 owner=registry hop=[0, 0] dir=forward stop=False
- s0079 [demo/flow] F03: Readiness status and watch updates · F03_sub2 owner=node hop=[0, 0] dir=return stop=False
- s0080 [demo/flow] F03 exchange: Deployment watch and object writes · F03_sub1 owner=api hop=[0, 1] dir=subflow stop=False
- s0081 [demo/flow] F03 exchange: Kubelet watch and status · F03_sub2 owner=api hop=[0, 1] dir=subflow stop=False
- s0082 [demo/flow] F03 exchange: Registry image bytes · F03_sub3 owner=node hop=[0, 1] dir=subflow stop=False
- s0083 [lecture/takeaway] Build takeaway

## Ch09 Human access — 16 scenes (11 demos)
- s0084 [lecture/hero] Human access
- s0085 [lecture/command] Access entry and kubeconfig
- s0086 [demo/flow] F01: Local SigV4 token signing + TLS · F01_forward owner=client hop=[0, 0] dir=forward stop=False
- s0087 [demo/flow] F01: Endpoint public CIDR admission · F01_forward owner=api hop=[0, 0] dir=forward stop=False
- s0088 [demo/flow] F01: IAM authentication then authorization · F01_forward owner=api hop=[0, 0] dir=forward stop=False
- s0089 [demo/flow] F01: API response · F01_return owner=api hop=[0, 0] dir=return stop=False
- s0090 [demo/flow] F02: Private DNS resolution · F02_forward owner=runner hop=[0, 0] dir=forward stop=False
- s0091 [demo/flow] F02: VPC subnet route lookup · F02_forward owner=vpc hop=[0, 0] dir=forward stop=False
- s0092 [demo/flow] F02: Cluster SG then IAM/RBAC · F02_forward owner=api hop=[1, 1] dir=forward stop=False
- s0093 [demo/flow] F02: VPC subnet route lookup · F02_return owner=vpc hop=[0, 0] dir=return stop=False
- s0094 [demo/flow] F22: IAM authentication succeeds · F22_forward owner=api hop=[0, 0] dir=forward stop=False
- s0095 [demo/flow] F22: RBAC/EKS access authorization · F22_forward owner=api hop=[0, 0] dir=forward stop=False
- s0096 [demo/flow] F22: 403 response on existing TLS session · F22_return owner=api hop=[0, 0] dir=return stop=True
- s0097 [lecture/question] Namespace viewer
- s0098 [lecture/takeaway] Namespace viewer — answer
- s0099 [lecture/takeaway] Access takeaway

## Ch10 VPC CNI deep mechanics — 7 scenes (4 demos)
- s0100 [lecture/hero] VPC CNI deep mechanics
- s0101 [demo/flow] F23: Scheduling successful · F23_forward owner=sched hop=[0, 0] dir=forward stop=False
- s0102 [demo/flow] F23: CNI ADD · F23_forward owner=kubelet hop=[0, 0] dir=forward stop=False
- s0103 [demo/flow] F23: IP/prefix allocation · F23_forward owner=ipamd hop=[1, 1] dir=forward stop=False
- s0104 [demo/flow] F23: Error events and retry · F23_return owner=kubelet hop=[0, 0] dir=return stop=True
- s0105 [lecture/command] Observe CNI
- s0106 [lecture/takeaway] CNI takeaway

## Ch11 Service discovery and proxying — 14 scenes (11 demos)
- s0107 [lecture/hero] Service discovery and proxying
- s0108 [demo/flow] F06: Kubernetes Service DNAT · F06_forward owner=proxy hop=[0, 0] dir=forward stop=False
- s0109 [demo/flow] F06: DNS zone/cache lookup · F06_forward owner=dns hop=[1, 1] dir=forward stop=False
- s0110 [demo/flow] F06: Conntrack reverse Service DNAT · F06_return owner=proxy hop=[0, 0] dir=return stop=False
- s0111 [demo/flow] F07: Service/EndpointSlice backend selection + DNAT · F07_forward owner=proxy hop=[0, 0] dir=forward stop=False
- s0112 [demo/flow] F07: Private A subnet route lookup AFTER DNAT · F07_forward owner=vpc hop=[1, 1] dir=forward stop=False
- s0113 [demo/flow] F07: Pod ingress policy then application · F07_forward owner=b hop=[2, 2] dir=forward stop=False
- s0114 [demo/flow] F07: Private B subnet route lookup · F07_return owner=vpc hop=[0, 0] dir=return stop=False
- s0115 [demo/flow] F07: Conntrack reverse DNAT · F07_return owner=proxy hop=[1, 1] dir=return stop=False
- s0116 [demo/flow] F08: Service DNAT · F08_forward owner=host hop=[0, 0] dir=forward stop=False
- s0117 [demo/flow] F08: Linux local Pod route · F08_forward owner=host hop=[0, 0] dir=forward stop=False
- s0118 [demo/flow] F08: Reverse conntrack · F08_return owner=host hop=[0, 0] dir=return stop=False
- s0119 [lecture/mechanism] Ordinary DNAT versus policy fixture ports
- s0120 [lecture/takeaway] Services takeaway

## Ch12 Four identity boundaries — 14 scenes (9 demos)
- s0121 [lecture/hero] Four identity boundaries
- s0122 [lecture/mechanism] Pod Identity versus IRSA
- s0123 [demo/flow] F14: SDK container-credential provider · F14_forward owner=pod hop=[0, 0] dir=forward stop=False
- s0124 [demo/flow] F14: Node-authorized EKS Auth request · F14_forward owner=agent hop=[0, 0] dir=forward stop=False
- s0125 [demo/flow] F14: Association + service role trust + tags · F14_forward owner=auth hop=[1, 1] dir=forward stop=False
- s0126 [demo/flow] F14: Separate signed application API request after credential response · F14_return owner=pod hop=[0, 1] dir=return stop=False
- s0127 [demo/flow] F14 exchange: Signed application AWS API · F14_sub1 owner=pod hop=[0, 1] dir=subflow stop=False
- s0128 [demo/flow] F15: WebIdentity SDK provider · F15_forward owner=pod hop=[0, 0] dir=forward stop=False
- s0129 [demo/flow] F15: AssumeRoleWithWebIdentity trust validation · F15_forward owner=sts hop=[0, 0] dir=forward stop=False
- s0130 [demo/flow] F15: Separate signed AWS API call · F15_return owner=pod hop=[0, 0] dir=return stop=False
- s0131 [demo/flow] F15 exchange: Signed application AWS API · F15_sub1 owner=pod hop=[0, 1] dir=subflow stop=False
- s0132 [lecture/command] Identity lab pointer
- s0133 [lecture/command] Workload identity lab
- s0134 [lecture/takeaway] Identity takeaway

## Ch13 Pod egress and private AWS — 17 scenes (14 demos)
- s0135 [lecture/hero] Pod egress and private AWS
- s0136 [demo/flow] F12: Default CNI off-VPC SNAT · F12_forward owner=node hop=[0, 0] dir=forward stop=False
- s0137 [demo/flow] F12: Private A subnet route lookup · F12_forward owner=node hop=[0, 0] dir=forward stop=False
- s0138 [demo/flow] F12: Stateful NAT translation · F12_forward owner=nat hop=[1, 1] dir=forward stop=False
- s0139 [demo/flow] F12: Public subnet route lookup · F12_forward owner=nat hop=[1, 1] dir=forward stop=False
- s0140 [demo/flow] F12: EIP address mapping · F12_forward owner=igw hop=[2, 2] dir=forward stop=False
- s0141 [demo/flow] F12: Reverse EIP mapping · F12_return owner=igw hop=[0, 0] dir=return stop=False
- s0142 [demo/flow] F12: NAT connection-state reverse translation · F12_return owner=nat hop=[1, 1] dir=return stop=False
- s0143 [demo/flow] F12: Public subnet local route to node · F12_return owner=nat hop=[1, 1] dir=return stop=False
- s0144 [demo/flow] F12: Reverse CNI SNAT + host delivery · F12_return owner=node hop=[2, 2] dir=return stop=False
- s0145 [demo/flow] F13: Private DNS · F13_forward owner=pod hop=[0, 0] dir=forward stop=False
- s0146 [demo/flow] F13: Private A subnet route lookup · F13_forward owner=vpc hop=[0, 0] dir=forward stop=False
- s0147 [demo/flow] F13: Endpoint SG + endpoint policy + IAM · F13_forward owner=vpce hop=[1, 1] dir=forward stop=False
- s0148 [demo/flow] F13: Separate ECR/S3 layer subflow · F13_forward owner=aws hop=[2, 2] dir=forward stop=False
- s0149 [demo/flow] F13 exchange: ECR S3 layer download (separate connection) · F13_sub1 owner=pod hop=[0, 3] dir=subflow stop=False
- s0150 [lecture/command] Optional private endpoints
- s0151 [lecture/takeaway] Egress takeaway

## Ch14 Expose applications — 14 scenes (10 demos)
- s0152 [lecture/hero] Expose applications
- s0153 [demo/flow] F09: TLS termination and L7 rule/healthy target selection · F09_forward owner=alb hop=[0, 0] dir=forward stop=False
- s0154 [demo/flow] F09: ALB subnet route lookup · F09_forward owner=vpc hop=[1, 1] dir=forward stop=False
- s0155 [demo/flow] F09: Backend subnet route lookup · F09_return owner=vpc hop=[0, 0] dir=return stop=False
- s0156 [demo/flow] F09: Proxy backend response onto client TLS connection · F09_return owner=alb hop=[1, 1] dir=return stop=False
- s0157 [demo/flow] F10: ALB subnet route lookup · F10_forward owner=vpcA hop=[0, 0] dir=forward stop=False
- s0158 [demo/flow] F10: NodePort DNAT and external Cluster masquerade · F10_forward owner=node hop=[1, 1] dir=forward stop=False
- s0159 [demo/flow] F10: Node subnet route lookup · F10_forward owner=vpcB hop=[2, 2] dir=forward stop=False
- s0160 [demo/flow] F10: PodB subnet route lookup · F10_return owner=vpcB hop=[0, 0] dir=return stop=False
- s0161 [demo/flow] F10: Reverse conntrack DNAT/SNAT · F10_return owner=node hop=[1, 1] dir=return stop=False
- s0162 [demo/flow] F10: NodeA route to ALB · F10_return owner=vpcA hop=[2, 2] dir=return stop=False
- s0163 [lecture/command] Deploy app first (04-app, B1 namespace order)
- s0164 [lecture/command] Install LBC and internal LBs (after 04-app)
- s0165 [lecture/takeaway] Expose takeaway

## Ch15 NLB and Gateway API — 18 scenes (15 demos)
- s0166 [lecture/hero] NLB and Gateway API
- s0167 [demo/flow] F11: L4 healthy target selection + source/destination translation · F11_forward owner=nlb hop=[0, 0] dir=forward stop=False
- s0168 [demo/flow] F11: LB subnet route lookup · F11_forward owner=vpc hop=[1, 1] dir=forward stop=False
- s0169 [demo/flow] F11: Backend subnet route lookup · F11_return owner=vpc hop=[0, 0] dir=return stop=False
- s0170 [demo/flow] F11: Reverse flow mapping · F11_return owner=nlb hop=[1, 1] dir=return stop=False
- s0171 [demo/flow] F24: Frontend-to-instance tuple mapping · F24_forward owner=nlb hop=[0, 0] dir=forward stop=False
- s0172 [demo/flow] F24: NLB target selection preserving client IPv4 · F24_forward owner=nlb hop=[0, 0] dir=forward stop=False
- s0173 [demo/flow] F24: NLB subnet route to node target · F24_forward owner=nlb hop=[0, 0] dir=forward stop=False
- s0174 [demo/flow] F24: Local NodePort DNAT, no remote-node forward · F24_forward owner=node hop=[1, 1] dir=forward stop=False
- s0175 [demo/flow] F24: Application socket · F24_forward owner=pod hop=[2, 2] dir=forward stop=False
- s0176 [demo/flow] F24: Reverse NodePort mapping · F24_return owner=node hop=[0, 0] dir=return stop=False
- s0177 [demo/flow] F24: LB return flow mapping · F24_return owner=nlb hop=[1, 1] dir=return stop=False
- s0178 [demo/flow] F25: Resource attachment / ReferenceGrant validation · F25_forward owner=route hop=[0, 0] dir=forward stop=False
- s0179 [demo/flow] F25: IAM-authorized reconciliation · F25_forward owner=ctrl hop=[0, 0] dir=forward stop=False
- s0180 [demo/flow] F25: Listener/target provisioning · F25_forward owner=elb hop=[1, 1] dir=forward stop=False
- s0181 [demo/flow] F25: Target health · F25_forward owner=target hop=[2, 2] dir=forward stop=False
- s0182 [lecture/concept] Guided Gateway note
- s0183 [lecture/takeaway] NLB/Gateway takeaway

## Ch16 DNS and TLS operations — 5 scenes (0 demos)
- s0184 [lecture/hero] DNS and TLS operations
- s0185 [lecture/mechanism] Mechanism — resolver and certificate chain
- s0186 [lecture/lab] Worked example — owned domain procedure
- s0187 [lecture/command] DNS/TLS observation (no unowned writes)
- s0188 [lecture/takeaway] DNS/TLS takeaway

## Ch17 East-west security — 16 scenes (10 demos)
- s0189 [lecture/hero] East-west security
- s0190 [lecture/mechanism] V1 — discover the real agent
- s0191 [lecture/command] Policy agent discovery commands
- s0192 [lecture/mechanism] B2/V2 — fixture semantics
- s0193 [lecture/command] Policy baseline → apply → enforce
- s0194 [demo/flow] F16: Source subnet VPC route lookup · F16_forward owner=vpc hop=[0, 0] dir=forward stop=False
- s0195 [demo/flow] F16: Destination ingress NetworkPolicy · F16_forward owner=dest hop=[1, 1] dir=forward stop=True
- s0196 [demo/flow] F17: Source egress allow union · F17_forward owner=client hop=[0, 0] dir=forward stop=False
- s0197 [demo/flow] F17: Subnet route lookup · F17_forward owner=vpc hop=[0, 0] dir=forward stop=False
- s0198 [demo/flow] F17: Destination ingress allow union · F17_forward owner=web hop=[1, 1] dir=forward stop=False
- s0199 [demo/flow] F17: Reverse route and established policy state · F17_return owner=vpc hop=[0, 0] dir=return stop=False
- s0200 [demo/flow] F26: Source subnet local route · F26_forward owner=vpc hop=[0, 0] dir=forward stop=False
- s0201 [demo/flow] F26: Stateless inbound rule · F26_forward owner=nacl hop=[1, 1] dir=forward stop=False
- s0202 [demo/flow] F26: Response generated · F26_forward owner=dest hop=[2, 2] dir=forward stop=False
- s0203 [demo/flow] F26: Stateless outbound ordered rules · F26_return owner=nacl hop=[0, 0] dir=return stop=True
- s0204 [lecture/takeaway] Policy takeaway

## Ch18 Persistent storage — 12 scenes (9 demos)
- s0205 [lecture/hero] Persistent storage
- s0206 [demo/flow] F18: StorageClass delayed binding · F18_forward owner=pvc hop=[0, 0] dir=forward stop=False
- s0207 [demo/flow] F18: Scheduling selected AZ · F18_forward owner=sched hop=[0, 0] dir=forward stop=False
- s0208 [demo/flow] F18: Dedicated controller IAM · F18_sub1 owner=csi hop=[1, 1] dir=forward stop=False
- s0209 [demo/flow] F18: Create/attach volume API · F18_sub1 owner=ec2 hop=[0, 0] dir=forward stop=False
- s0210 [demo/flow] F18: NodePublish mount · F18_sub2 owner=node hop=[0, 0] dir=forward stop=False
- s0211 [demo/flow] F18: Bound/ready status · F18_return owner=pvc hop=[0, 0] dir=return stop=False
- s0212 [demo/flow] F18 exchange: CSI cloud API control · F18_sub1 owner=csi hop=[0, 1] dir=subflow stop=False
- s0213 [demo/flow] F18 exchange: Node mount · F18_sub2 owner=csi hop=[0, 0] dir=subflow stop=False
- s0214 [demo/flow] F27: PV nodeAffinity / CSI topology · F27_forward owner=sched hop=[0, 0] dir=forward stop=True
- s0215 [lecture/command] EBS lab
- s0216 [lecture/takeaway] Storage takeaway

## Ch19 Scaling and availability — 13 scenes (10 demos)
- s0217 [lecture/hero] Scaling and availability
- s0218 [demo/flow] F19: Metrics query · F19_forward owner=metrics hop=[0, 0] dir=forward stop=False
- s0219 [demo/flow] F19: Desired replica calculation · F19_forward owner=hpa hop=[0, 0] dir=forward stop=False
- s0220 [demo/flow] F19: Unschedulable resource assessment · F19_forward owner=sched hop=[1, 1] dir=forward stop=False
- s0221 [demo/flow] F19: Choose ONE capacity owner · F19_forward owner=scaler hop=[2, 2] dir=forward stop=False
- s0222 [demo/flow] F19: EC2 provisioning + bootstrap · F19_forward owner=node hop=[3, 3] dir=forward stop=False
- s0223 [demo/flow] F19: Readiness and EndpointSlice inclusion · F19_forward owner=pod hop=[4, 4] dir=forward stop=False
- s0224 [demo/flow] F20: Rolling update budget · F20_forward owner=deploy hop=[0, 0] dir=forward stop=False
- s0225 [demo/flow] F20: Startup then readiness · F20_forward owner=new hop=[0, 0] dir=forward stop=False
- s0226 [demo/flow] F20: Target registration/health · F20_forward owner=lb hop=[1, 1] dir=forward stop=False
- s0227 [demo/flow] F20: Termination and deregistration · F20_forward owner=old hop=[2, 2] dir=forward stop=False
- s0228 [lecture/command] HPA lab
- s0229 [lecture/takeaway] Scale takeaway

## Ch20 Observability — 5 scenes (0 demos)
- s0230 [lecture/hero] Observability
- s0231 [lecture/mechanism] Mechanism — pick the layer
- s0232 [lecture/lab] Worked diagnosis walkthrough
- s0233 [lecture/command] Diagnostics
- s0234 [lecture/takeaway] Observe takeaway

## Ch21 Failure lab practicum — 15 scenes (12 demos)
- s0235 [lecture/hero] Failure lab practicum
- s0236 [demo/flow] F22: IAM authentication succeeds · F22_forward owner=api hop=[0, 0] dir=forward stop=False
- s0237 [demo/flow] F22: RBAC/EKS access authorization · F22_forward owner=api hop=[0, 0] dir=forward stop=False
- s0238 [demo/flow] F22: 403 response on existing TLS session · F22_return owner=api hop=[0, 0] dir=return stop=True
- s0239 [demo/flow] F23: Scheduling successful · F23_forward owner=sched hop=[0, 0] dir=forward stop=False
- s0240 [demo/flow] F23: CNI ADD · F23_forward owner=kubelet hop=[0, 0] dir=forward stop=False
- s0241 [demo/flow] F23: IP/prefix allocation · F23_forward owner=ipamd hop=[1, 1] dir=forward stop=False
- s0242 [demo/flow] F23: Error events and retry · F23_return owner=kubelet hop=[0, 0] dir=return stop=True
- s0243 [demo/flow] F26: Source subnet local route · F26_forward owner=vpc hop=[0, 0] dir=forward stop=False
- s0244 [demo/flow] F26: Stateless inbound rule · F26_forward owner=nacl hop=[1, 1] dir=forward stop=False
- s0245 [demo/flow] F26: Response generated · F26_forward owner=dest hop=[2, 2] dir=forward stop=False
- s0246 [demo/flow] F26: Stateless outbound ordered rules · F26_return owner=nacl hop=[0, 0] dir=return stop=True
- s0247 [demo/flow] F27: PV nodeAffinity / CSI topology · F27_forward owner=sched hop=[0, 0] dir=forward stop=True
- s0248 [lecture/mechanism] Troubleshooting order
- s0249 [lecture/takeaway] Failure takeaway

## Ch22 Upgrade and release engineering — 19 scenes (10 demos)
- s0250 [lecture/hero] Upgrade and release engineering
- s0251 [lecture/mechanism] B3 — preparation before control-plane rollback
- s0252 [lecture/concept] F28 narrator beat
- s0253 [lecture/concept] F28 narrator beat
- s0254 [lecture/concept] F28 narrator beat
- s0255 [lecture/concept] F28 narrator beat
- s0256 [demo/flow] F28: Eligibility and rollback-readiness insights · F28_forward owner=gate hop=[0, 0] dir=forward stop=False
- s0257 [demo/flow] F28: Target-compatible worker preparation · F28_forward owner=nodes hop=[0, 0] dir=forward stop=False
- s0258 [demo/flow] F28: PRE-CP addon compatibility preparation · F28_forward owner=nodes hop=[0, 0] dir=forward stop=False
- s0259 [demo/flow] F28: EKS managed previous-minor rollback · F28_forward owner=cp hop=[1, 1] dir=forward stop=False
- s0260 [demo/flow] F28: Post-rollback validation · F28_forward owner=verify hop=[2, 2] dir=forward stop=False
- s0261 [demo/flow] F21: Compatibility and capacity gate · F21_forward owner=plan hop=[0, 0] dir=forward stop=False
- s0262 [demo/flow] F21: Managed control-plane update · F21_forward owner=cp hop=[0, 0] dir=forward stop=False
- s0263 [demo/flow] F21: Version-specific component compatibility · F21_forward owner=addons hop=[1, 1] dir=forward stop=False
- s0264 [demo/flow] F21: Managed nodegroup replacement · F21_forward owner=nodes hop=[2, 2] dir=forward stop=False
- s0265 [demo/flow] F21: Workload and network acceptance · F21_forward owner=test hop=[3, 3] dir=forward stop=False
- s0266 [lecture/command] Rollback command reference (authorized only)
- s0267 [lecture/command] Upgrade planning read-only
- s0268 [lecture/takeaway] Upgrade takeaway

## Ch23 Production security and cost — 7 scenes (4 demos)
- s0269 [lecture/hero] Production security and cost
- s0270 [demo/flow] F29: Backup consistency and keys · F29_forward owner=backup hop=[0, 0] dir=forward stop=False
- s0271 [demo/flow] F29: Independent recovery target · F29_forward owner=restore hop=[0, 0] dir=forward stop=False
- s0272 [demo/flow] F29: Correctness before DNS cutover · F29_forward owner=validate hop=[1, 1] dir=forward stop=False
- s0273 [demo/flow] F29: Ordered deletion gate · F29_forward owner=delete hop=[2, 2] dir=forward stop=False
- s0274 [lecture/concept] DR tabletop
- s0275 [lecture/takeaway] Sec/cost takeaway

## Ch24 Terraform progression — 7 scenes (0 demos)
- s0276 [lecture/hero] Terraform progression
- s0277 [lecture/mechanism] Prerequisites and ownership boundary
- s0278 [lecture/lab] Worked commands — init through plan
- s0279 [lecture/command] Terraform practice commands (no class apply)
- s0280 [lecture/mechanism] Phase boundary — AWS then Kubernetes
- s0281 [lecture/lab] Destroy and evidence
- s0282 [lecture/takeaway] Terraform takeaway

## Ch25 Capstone and teardown — 5 scenes (0 demos)
- s0283 [lecture/hero] Capstone and teardown
- s0284 [lecture/concept] Selected path recap
- s0285 [lecture/command] Teardown order
- s0286 [lecture/hero] Thank you
- s0287 [lecture/takeaway] Final hold
