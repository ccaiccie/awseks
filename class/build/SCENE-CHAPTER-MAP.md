# Scene–chapter map (v5.1)

Generated from pinned `build/class-data.json` + `build/narration-plan.json`.

- Version: **v5.1**
- Scenes: **335** · Demos: **215** · Lectures: **120**
- Chapters: **26** · Unique audio clips: **276**
- Scheduled duration: **2:09:55** (7795.372 s)
- Pinned HTML sha256: `a23d6854e93cd4fbb22acded84766b9ae67c6ec159417791f21901ec5d3b7058`
- Canonical drawio: `diagrams/EKS-Masterclass-v5.1-Lecture-and-Flow.drawio` sha256 `6e73873cc031bf0d84202a45798a1aea6bf966fdc7ffe28f3e20624c46135b23`

## Ch00 Orientation and safety — 9 scenes (0 demos)
- Timing: audio=205.920s · scheduled=220.520s · indices [0,9)

- s0000 [lecture/hero] Welcome · clip=`42accea73c63cf57`
- s0001 [lecture/concept] Managed service is not free · clip=`2b96e14b1953c113`
- s0002 [lecture/mechanism] Architecture map · clip=`ddc328509a5d52f4`
- s0003 [lecture/concept] CLI versus Terraform ownership · clip=`50cc34702047f758`
- s0004 [lecture/command] Cost and create discipline preview · clip=`37e93a67f3cb9e6b`
- s0005 [lecture/command] Preflight before create (eksclass-cli) · clip=`3c3f89aa98211d14`
- s0006 [lecture/question] Why closing the laptop does not stop billing · clip=`a65989d1a045b236`
- s0007 [lecture/takeaway] Why closing the laptop does not stop billing — answer · clip=`c1e1c55609510011`
- s0008 [lecture/takeaway] Orientation takeaway · clip=`b9ff4c1fb23e3e6f`

## Ch01 Linux and networks foundations — 16 scenes (10 demos)
- Timing: audio=405.456s · scheduled=424.656s · indices [9,25)

- s0009 [lecture/hero] Linux and networks foundations · clip=`f53676df0ee4f5e7`
- s0010 [lecture/mechanism] Longest-prefix matching · clip=`ca8c33e37069ea2d`
- s0011 [lecture/concept] Security group versus network ACL · clip=`cd4cf182e248d124`
- s0012 [demo/flow] F04: Pod network namespace default route · F04_forward owner=a hop=[0, 0] dir=forward stop=False · clip=`bfc07ca8072e46ef`
- s0013 [demo/flow] F04: Linux FIB local Pod route · F04_forward owner=host hop=[0, 0] dir=forward stop=False · clip=`5ef6163a19134f25`
- s0014 [demo/flow] F04: Network policy + socket accept · F04_forward owner=c hop=[1, 1] dir=forward stop=False · clip=`24dc1b179c400549`
- s0015 [demo/flow] F04: Linux FIB local Pod route · F04_return owner=host hop=[0, 0] dir=return stop=False · clip=`773f0cc080646b15`
- s0016 [demo/flow] F04: Terminal return delivery · F04_return owner=a hop=[1, 1] dir=return stop=False · clip=`1188424fba25d3c1`
- s0017 [demo/flow] F05: Node ENI / CNI forwarding · F05_forward owner=a hop=[0, 0] dir=forward stop=False · clip=`3ce1c3af5437ff5d`
- s0018 [demo/flow] F05: Subnet route lookup · F05_forward owner=vpc hop=[0, 0] dir=forward stop=False · clip=`4b9ca278c8df9ad1`
- s0019 [demo/flow] F05: ENI SG / subnet NACL / Pod policy · F05_forward owner=b hop=[1, 1] dir=forward stop=False · clip=`f954b124bddb33c1`
- s0020 [demo/flow] F05: Subnet route lookup · F05_return owner=vpc hop=[0, 0] dir=return stop=False · clip=`35db21870ded25ab`
- s0021 [demo/flow] F05: Stateful return + host Pod route · F05_return owner=a hop=[1, 1] dir=return stop=False · clip=`86db5cde10bf4eb4`
- s0022 [lecture/question] Winning prefix for Pod B · clip=`098ed75362fff75f`
- s0023 [lecture/takeaway] Winning prefix for Pod B — answer · clip=`7d79c2df3fadb7f6`
- s0024 [lecture/takeaway] Linux nets takeaway · clip=`2b9bce36dc383959`

## Ch02 Images to containers — 12 scenes (9 demos)
- Timing: audio=205.968s · scheduled=214.668s · indices [25,37)

- s0025 [lecture/hero] Images to containers · clip=`154f5c2cba9de391`
- s0026 [lecture/concept] Tag versus digest and pull path · clip=`8fb00d315bba9f95`
- s0027 [demo/flow] F03: Kubernetes object submission · F03_forward owner=client hop=[0, 0] dir=forward stop=False · clip=`aa46a9e913636d2b`
- s0028 [demo/flow] F03: Desired-state persistence · F03_forward owner=api hop=[0, 0] dir=forward stop=False · clip=`892b0a7349c58c91`
- s0029 [demo/flow] F03: Terminal return delivery · F03_return owner=client hop=[0, 0] dir=return stop=False · clip=`3d8150d1dae1442a`
- s0030 [demo/flow] F03: Deployment watch and object writes · F03_sub1 owner=sched hop=[0, 0] dir=subflow stop=False · clip=`64cc4b5380ab2a68`
- s0031 [demo/flow] F03: Deployment watch and object writes · F03_sub1 owner=api hop=[1, 1] dir=subflow stop=False · clip=`0957b3883fb18547`
- s0032 [demo/flow] F03: Registry image bytes · F03_sub3 owner=registry hop=[0, 0] dir=subflow stop=False · clip=`3685a5e83640053e`
- s0033 [demo/flow] F03: Registry image bytes · F03_sub3 owner=node hop=[1, 1] dir=subflow stop=False · clip=`5c995423e0614acd`
- s0034 [demo/flow] F03: API watch delivers Pod spec to kubelet · F03_sub2 owner=node hop=[0, 0] dir=subflow stop=False · clip=`69349aee6b33d166`
- s0035 [demo/flow] F03: Node reports readiness status to API · F03_sub2 owner=node hop=[1, 1] dir=subflow stop=False · clip=`36433814bb2b7c3b`
- s0036 [lecture/takeaway] Images takeaway · clip=`db5102d5862fb15c`

## Ch03 Kubernetes object model — 14 scenes (9 demos)
- Timing: audio=214.056s · scheduled=231.756s · indices [37,51)

- s0037 [lecture/hero] Kubernetes object model · clip=`95747409bc130d5d`
- s0038 [lecture/mechanism] Reconciliation is asynchronous · clip=`a9fd26697dc34c4d`
- s0039 [demo/flow] F03: Kubernetes object submission · F03_forward owner=client hop=[0, 0] dir=forward stop=False · clip=`aa46a9e913636d2b`
- s0040 [demo/flow] F03: Desired-state persistence · F03_forward owner=api hop=[0, 0] dir=forward stop=False · clip=`892b0a7349c58c91`
- s0041 [demo/flow] F03: Terminal return delivery · F03_return owner=client hop=[0, 0] dir=return stop=False · clip=`3d8150d1dae1442a`
- s0042 [demo/flow] F03: Deployment watch and object writes · F03_sub1 owner=sched hop=[0, 0] dir=subflow stop=False · clip=`64cc4b5380ab2a68`
- s0043 [demo/flow] F03: Deployment watch and object writes · F03_sub1 owner=api hop=[1, 1] dir=subflow stop=False · clip=`0957b3883fb18547`
- s0044 [demo/flow] F03: Registry image bytes · F03_sub3 owner=registry hop=[0, 0] dir=subflow stop=False · clip=`3685a5e83640053e`
- s0045 [demo/flow] F03: Registry image bytes · F03_sub3 owner=node hop=[1, 1] dir=subflow stop=False · clip=`5c995423e0614acd`
- s0046 [demo/flow] F03: API watch delivers Pod spec to kubelet · F03_sub2 owner=node hop=[0, 0] dir=subflow stop=False · clip=`69349aee6b33d166`
- s0047 [demo/flow] F03: Node reports readiness status to API · F03_sub2 owner=node hop=[1, 1] dir=subflow stop=False · clip=`36433814bb2b7c3b`
- s0048 [lecture/question] Delete one Pod · clip=`b8ba98a4ebbc8295`
- s0049 [lecture/takeaway] Delete one Pod — answer · clip=`2adab4a62d987d78`
- s0050 [lecture/takeaway] Object model takeaway · clip=`baf4b8794b148d01`

## Ch04 Config and lifecycle — 6 scenes (0 demos)
- Timing: audio=186.552s · scheduled=191.352s · indices [51,57)

- s0051 [lecture/hero] Config and lifecycle · clip=`87d5ac777f97e810`
- s0052 [lecture/mechanism] Mechanism — config projection · clip=`a636db8741183a03`
- s0053 [lecture/mechanism] Probes and drain · clip=`d3cb46ebcea4897f`
- s0054 [lecture/lab] Observable check — rollout and probes · clip=`a3157f9c3d65a8cb`
- s0055 [lecture/command] Lifecycle lab pointers · clip=`7d4a5f70afe3ac38`
- s0056 [lecture/takeaway] Config takeaway · clip=`2a0c26b4fe357021`

## Ch05 EKS architecture — 4 scenes (0 demos)
- Timing: audio=137.400s · scheduled=140.600s · indices [57,61)

- s0057 [lecture/hero] EKS architecture · clip=`5934b6eda714f8b2`
- s0058 [lecture/mechanism] Mechanism — shared responsibility · clip=`e2d542dfef8febef`
- s0059 [lecture/lab] Worked example — describe the cluster boundary · clip=`1db52dc54f4e46a3`
- s0060 [lecture/takeaway] Architecture takeaway · clip=`c2431e51cde2e939`

## Ch06 Compute choice — 3 scenes (0 demos)
- Timing: audio=40.992s · scheduled=43.392s · indices [61,64)

- s0061 [lecture/hero] Compute choice · clip=`d3bfa41cdf483d92`
- s0062 [lecture/mechanism] Variant matrix · clip=`1eb7bfeafcfcd03c`
- s0063 [lecture/takeaway] Compute takeaway · clip=`ad2922e47b07a248`

## Ch07 Plan VPC and IP budgets — 20 scenes (16 demos)
- Timing: audio=522.600s · scheduled=537.000s · indices [64,84)

- s0064 [lecture/hero] Plan VPC and IP budgets · clip=`bca4c04309dde3f1`
- s0065 [lecture/mechanism] Public versus private is routing · clip=`8d13c478dc250cc4`
- s0066 [lecture/command] Build teaching VPC (eksclass-cli) · clip=`56066383320cc80b`
- s0067 [demo/flow] F05: Node ENI / CNI forwarding · F05_forward owner=a hop=[0, 0] dir=forward stop=False · clip=`3ce1c3af5437ff5d`
- s0068 [demo/flow] F05: Subnet route lookup · F05_forward owner=vpc hop=[0, 0] dir=forward stop=False · clip=`4b9ca278c8df9ad1`
- s0069 [demo/flow] F05: ENI SG / subnet NACL / Pod policy · F05_forward owner=b hop=[1, 1] dir=forward stop=False · clip=`f954b124bddb33c1`
- s0070 [demo/flow] F05: Subnet route lookup · F05_return owner=vpc hop=[0, 0] dir=return stop=False · clip=`35db21870ded25ab`
- s0071 [demo/flow] F05: Stateful return + host Pod route · F05_return owner=a hop=[1, 1] dir=return stop=False · clip=`86db5cde10bf4eb4`
- s0072 [demo/flow] F12: Default CNI off-VPC SNAT · F12_forward owner=node hop=[0, 0] dir=forward stop=False · clip=`251bab020d16770f`
- s0073 [demo/flow] F12: Private A subnet route lookup · F12_forward owner=node hop=[0, 0] dir=forward stop=False · clip=`a5bb4b61c22447c6`
- s0074 [demo/flow] F12: Stateful NAT translation · F12_forward owner=nat hop=[1, 1] dir=forward stop=False · clip=`efb6038498317b29`
- s0075 [demo/flow] F12: Public subnet route lookup · F12_forward owner=nat hop=[1, 1] dir=forward stop=False · clip=`4b64a226549ab4ce`
- s0076 [demo/flow] F12: EIP address mapping · F12_forward owner=igw hop=[2, 2] dir=forward stop=False · clip=`87aafd21afb604d1`
- s0077 [demo/flow] F12: Terminal delivery to destination · F12_forward owner=peer hop=[3, 3] dir=forward stop=False · clip=`36cfe5a1ba9df0bd`
- s0078 [demo/flow] F12: Reverse EIP mapping · F12_return owner=igw hop=[0, 0] dir=return stop=False · clip=`2896b3f235e9e53d`
- s0079 [demo/flow] F12: NAT connection-state reverse translation · F12_return owner=nat hop=[1, 1] dir=return stop=False · clip=`c8412c100cf449a9`
- s0080 [demo/flow] F12: Public subnet local route to node · F12_return owner=nat hop=[1, 1] dir=return stop=False · clip=`9d3e9c272e1ba2e8`
- s0081 [demo/flow] F12: Reverse CNI SNAT + host delivery · F12_return owner=node hop=[2, 2] dir=return stop=False · clip=`eaad0d2ec5a44a79`
- s0082 [demo/flow] F12: Terminal return delivery · F12_return owner=pod hop=[3, 3] dir=return stop=False · clip=`46909c2a277da6bc`
- s0083 [lecture/takeaway] VPC plan takeaway · clip=`fdcddb2dc7cc957a`

## Ch08 Build Standard cluster — 16 scenes (13 demos)
- Timing: audio=318.984s · scheduled=330.484s · indices [84,100)

- s0084 [lecture/hero] Build Standard cluster · clip=`c9b3a85aa8632295`
- s0085 [lecture/command] Create cluster and node group · clip=`f0f67578a63e1f95`
- s0086 [demo/flow] F01: Local SigV4 token signing + TLS · F01_forward owner=client hop=[0, 0] dir=forward stop=False · clip=`141e047974976bc6`
- s0087 [demo/flow] F01: Endpoint public CIDR admission · F01_forward owner=api hop=[0, 0] dir=forward stop=False · clip=`9ce3c41d17eb9f9d`
- s0088 [demo/flow] F01: IAM authentication then authorization · F01_forward owner=api hop=[0, 0] dir=forward stop=False · clip=`77802132c98f11da`
- s0089 [demo/flow] F01: API response · F01_return owner=api hop=[0, 0] dir=return stop=False · clip=`1847fb7ca4ccf614`
- s0090 [demo/flow] F03: Kubernetes object submission · F03_forward owner=client hop=[0, 0] dir=forward stop=False · clip=`aa46a9e913636d2b`
- s0091 [demo/flow] F03: Desired-state persistence · F03_forward owner=api hop=[0, 0] dir=forward stop=False · clip=`892b0a7349c58c91`
- s0092 [demo/flow] F03: Terminal return delivery · F03_return owner=client hop=[0, 0] dir=return stop=False · clip=`3d8150d1dae1442a`
- s0093 [demo/flow] F03: Deployment watch and object writes · F03_sub1 owner=sched hop=[0, 0] dir=subflow stop=False · clip=`64cc4b5380ab2a68`
- s0094 [demo/flow] F03: Deployment watch and object writes · F03_sub1 owner=api hop=[1, 1] dir=subflow stop=False · clip=`0957b3883fb18547`
- s0095 [demo/flow] F03: Registry image bytes · F03_sub3 owner=registry hop=[0, 0] dir=subflow stop=False · clip=`3685a5e83640053e`
- s0096 [demo/flow] F03: Registry image bytes · F03_sub3 owner=node hop=[1, 1] dir=subflow stop=False · clip=`5c995423e0614acd`
- s0097 [demo/flow] F03: API watch delivers Pod spec to kubelet · F03_sub2 owner=node hop=[0, 0] dir=subflow stop=False · clip=`69349aee6b33d166`
- s0098 [demo/flow] F03: Node reports readiness status to API · F03_sub2 owner=node hop=[1, 1] dir=subflow stop=False · clip=`36433814bb2b7c3b`
- s0099 [lecture/takeaway] Build takeaway · clip=`75d21d65cf9ec6aa`

## Ch09 Human access — 17 scenes (12 demos)
- Timing: audio=372.480s · scheduled=392.280s · indices [100,117)

- s0100 [lecture/hero] Human access · clip=`5097968b0203e485`
- s0101 [lecture/command] Access entry and kubeconfig · clip=`ae859461012dc254`
- s0102 [demo/flow] F01: Local SigV4 token signing + TLS · F01_forward owner=client hop=[0, 0] dir=forward stop=False · clip=`141e047974976bc6`
- s0103 [demo/flow] F01: Endpoint public CIDR admission · F01_forward owner=api hop=[0, 0] dir=forward stop=False · clip=`9ce3c41d17eb9f9d`
- s0104 [demo/flow] F01: IAM authentication then authorization · F01_forward owner=api hop=[0, 0] dir=forward stop=False · clip=`77802132c98f11da`
- s0105 [demo/flow] F01: API response · F01_return owner=api hop=[0, 0] dir=return stop=False · clip=`1847fb7ca4ccf614`
- s0106 [demo/flow] F02: Private DNS resolution · F02_forward owner=runner hop=[0, 0] dir=forward stop=False · clip=`23fca2e5c5311e55`
- s0107 [demo/flow] F02: VPC subnet route lookup · F02_forward owner=vpc hop=[0, 0] dir=forward stop=False · clip=`0b9bf734e4d74a40`
- s0108 [demo/flow] F02: Cluster SG then IAM/RBAC · F02_forward owner=api hop=[1, 1] dir=forward stop=False · clip=`a4bf71ad53e7eebf`
- s0109 [demo/flow] F02: VPC subnet route lookup · F02_return owner=vpc hop=[0, 0] dir=return stop=False · clip=`245983da45a37634`
- s0110 [demo/flow] F02: Terminal return delivery · F02_return owner=runner hop=[1, 1] dir=return stop=False · clip=`8659ae1aa23ce6f2`
- s0111 [demo/flow] F22: IAM authentication succeeds · F22_forward owner=api hop=[0, 0] dir=forward stop=False · clip=`96366eefd226094d`
- s0112 [demo/flow] F22: RBAC/EKS access authorization · F22_forward owner=api hop=[0, 0] dir=forward stop=False · clip=`2a0c7df51f93f6ff`
- s0113 [demo/flow] F22: 403 response on existing TLS session · F22_return owner=api hop=[0, 0] dir=return stop=True · clip=`4d6de9740f516541`
- s0114 [lecture/question] Namespace viewer · clip=`6e73ea5cc451a888`
- s0115 [lecture/takeaway] Namespace viewer — answer · clip=`cc7bd40be37b48f7`
- s0116 [lecture/takeaway] Access takeaway · clip=`c55312a07040430d`

## Ch10 VPC CNI deep mechanics — 7 scenes (4 demos)
- Timing: audio=92.808s · scheduled=98.008s · indices [117,124)

- s0117 [lecture/hero] VPC CNI deep mechanics · clip=`be1bc1284f5c5c71`
- s0118 [demo/flow] F23: Scheduling successful · F23_forward owner=sched hop=[0, 0] dir=forward stop=False · clip=`c64c070384af7c26`
- s0119 [demo/flow] F23: CNI ADD · F23_forward owner=kubelet hop=[0, 0] dir=forward stop=False · clip=`f2df8dcc3264ca5a`
- s0120 [demo/flow] F23: IP/prefix allocation · F23_forward owner=ipamd hop=[1, 1] dir=forward stop=False · clip=`34db3078b01bebe0`
- s0121 [demo/flow] F23: Error events and retry · F23_return owner=kubelet hop=[0, 0] dir=return stop=True · clip=`97ef0597f9f70f6d`
- s0122 [lecture/command] Observe CNI · clip=`ff29fc12f364e90e`
- s0123 [lecture/takeaway] CNI takeaway · clip=`8bcae00ce3f6d89e`

## Ch11 Service discovery and proxying — 18 scenes (15 demos)
- Timing: audio=430.512s · scheduled=443.412s · indices [124,142)

- s0124 [lecture/hero] Service discovery and proxying · clip=`fb13230dade22ccd`
- s0125 [demo/flow] F06: Kubernetes Service DNAT · F06_forward owner=proxy hop=[0, 0] dir=forward stop=False · clip=`5f5f2d57e086b269`
- s0126 [demo/flow] F06: DNS zone/cache lookup · F06_forward owner=dns hop=[1, 1] dir=forward stop=False · clip=`7deee95d50f5a269`
- s0127 [demo/flow] F06: Conntrack reverse Service DNAT · F06_return owner=proxy hop=[0, 0] dir=return stop=False · clip=`2c9e7ae9f10a0643`
- s0128 [demo/flow] F06: Terminal return delivery · F06_return owner=a hop=[1, 1] dir=return stop=False · clip=`ce1b91d90c44db60`
- s0129 [demo/flow] F07: Service/EndpointSlice backend selection + DNAT · F07_forward owner=proxy hop=[0, 0] dir=forward stop=False · clip=`262438e5978b67f6`
- s0130 [demo/flow] F07: Private A subnet route lookup AFTER DNAT · F07_forward owner=vpc hop=[1, 1] dir=forward stop=False · clip=`d1786ead5019953f`
- s0131 [demo/flow] F07: Pod ingress policy then application · F07_forward owner=b hop=[2, 2] dir=forward stop=False · clip=`32dc8a25c9d4cc29`
- s0132 [demo/flow] F07: Private B subnet route lookup · F07_return owner=vpc hop=[0, 0] dir=return stop=False · clip=`546769f571bcc9ed`
- s0133 [demo/flow] F07: Conntrack reverse DNAT · F07_return owner=proxy hop=[1, 1] dir=return stop=False · clip=`712e95a1f4793323`
- s0134 [demo/flow] F07: Terminal return delivery · F07_return owner=a hop=[2, 2] dir=return stop=False · clip=`ce1b91d90c44db60`
- s0135 [demo/flow] F08: Service DNAT · F08_forward owner=host hop=[0, 0] dir=forward stop=False · clip=`9e4a6cff96103807`
- s0136 [demo/flow] F08: Linux local Pod route · F08_forward owner=host hop=[0, 0] dir=forward stop=False · clip=`12465c6f49e73a07`
- s0137 [demo/flow] F08: Terminal delivery to destination · F08_forward owner=c hop=[1, 1] dir=forward stop=False · clip=`0715446e99b4a5a5`
- s0138 [demo/flow] F08: Reverse conntrack · F08_return owner=host hop=[0, 0] dir=return stop=False · clip=`5e48f363730b17b4`
- s0139 [demo/flow] F08: Terminal return delivery · F08_return owner=a hop=[1, 1] dir=return stop=False · clip=`1188424fba25d3c1`
- s0140 [lecture/mechanism] Ordinary DNAT versus policy fixture ports · clip=`45d7eb1614f4e52e`
- s0141 [lecture/takeaway] Services takeaway · clip=`c4b1ffee173607e0`

## Ch12 Four identity boundaries — 17 scenes (12 demos)
- Timing: audio=322.512s · scheduled=334.912s · indices [142,159)

- s0142 [lecture/hero] Four identity boundaries · clip=`f62be707107dff9e`
- s0143 [lecture/mechanism] Pod Identity versus IRSA · clip=`abd704b877fa5ad6`
- s0144 [demo/flow] F14: SDK container-credential provider · F14_forward owner=pod hop=[0, 0] dir=forward stop=False · clip=`2878a847904b5b10`
- s0145 [demo/flow] F14: Node-authorized EKS Auth request · F14_forward owner=agent hop=[0, 0] dir=forward stop=False · clip=`a49eed65b32abf8e`
- s0146 [demo/flow] F14: Association + service role trust + tags · F14_forward owner=auth hop=[1, 1] dir=forward stop=False · clip=`c7969f311b1dcec4`
- s0147 [demo/flow] F14: Credential response via agent · F14_return owner=agent hop=[0, 0] dir=return stop=False · clip=`2f12dfc5a2ad40e2`
- s0148 [demo/flow] F14: Credentials delivered to Pod · F14_return owner=pod hop=[1, 1] dir=return stop=False · clip=`39e8ac705cc02234`
- s0149 [demo/flow] F14: Signed application request (outbound) · F14_sub1 owner=aws hop=[0, 0] dir=subflow stop=False · clip=`166de252c81de2dd`
- s0150 [demo/flow] F14: Signed application response (return) · F14_sub1 owner=pod hop=[1, 1] dir=subflow stop=False · clip=`ef8084a3b40a5cba`
- s0151 [demo/flow] F15: WebIdentity SDK provider · F15_forward owner=pod hop=[0, 0] dir=forward stop=False · clip=`93f574c5217f2ed0`
- s0152 [demo/flow] F15: AssumeRoleWithWebIdentity trust validation · F15_forward owner=sts hop=[0, 0] dir=forward stop=False · clip=`2b29c37706c1cf5f`
- s0153 [demo/flow] F15: STS credential response to Pod · F15_return owner=pod hop=[0, 0] dir=return stop=False · clip=`bf2e1ec29a42cc0c`
- s0154 [demo/flow] F15: Signed application request (outbound) · F15_sub1 owner=aws hop=[0, 0] dir=subflow stop=False · clip=`bfeef6e806697750`
- s0155 [demo/flow] F15: Signed application response (return) · F15_sub1 owner=pod hop=[1, 1] dir=subflow stop=False · clip=`8c343ba829fc7224`
- s0156 [lecture/command] Identity lab pointer · clip=`7d3a6e6b3d2452c6`
- s0157 [lecture/command] Workload identity lab · clip=`4cdb164dbd47d89a`
- s0158 [lecture/takeaway] Identity takeaway · clip=`a98dab748ce2a0c3`

## Ch13 Pod egress and private AWS — 25 scenes (22 demos)
- Timing: audio=735.528s · scheduled=753.328s · indices [159,184)

- s0159 [lecture/hero] Pod egress and private AWS · clip=`d3fca34733d96859`
- s0160 [demo/flow] F12: Default CNI off-VPC SNAT · F12_forward owner=node hop=[0, 0] dir=forward stop=False · clip=`251bab020d16770f`
- s0161 [demo/flow] F12: Private A subnet route lookup · F12_forward owner=node hop=[0, 0] dir=forward stop=False · clip=`a5bb4b61c22447c6`
- s0162 [demo/flow] F12: Stateful NAT translation · F12_forward owner=nat hop=[1, 1] dir=forward stop=False · clip=`efb6038498317b29`
- s0163 [demo/flow] F12: Public subnet route lookup · F12_forward owner=nat hop=[1, 1] dir=forward stop=False · clip=`4b64a226549ab4ce`
- s0164 [demo/flow] F12: EIP address mapping · F12_forward owner=igw hop=[2, 2] dir=forward stop=False · clip=`87aafd21afb604d1`
- s0165 [demo/flow] F12: Terminal delivery to destination · F12_forward owner=peer hop=[3, 3] dir=forward stop=False · clip=`36cfe5a1ba9df0bd`
- s0166 [demo/flow] F12: Reverse EIP mapping · F12_return owner=igw hop=[0, 0] dir=return stop=False · clip=`2896b3f235e9e53d`
- s0167 [demo/flow] F12: NAT connection-state reverse translation · F12_return owner=nat hop=[1, 1] dir=return stop=False · clip=`c8412c100cf449a9`
- s0168 [demo/flow] F12: Public subnet local route to node · F12_return owner=nat hop=[1, 1] dir=return stop=False · clip=`9d3e9c272e1ba2e8`
- s0169 [demo/flow] F12: Reverse CNI SNAT + host delivery · F12_return owner=node hop=[2, 2] dir=return stop=False · clip=`eaad0d2ec5a44a79`
- s0170 [demo/flow] F12: Terminal return delivery · F12_return owner=pod hop=[3, 3] dir=return stop=False · clip=`46909c2a277da6bc`
- s0171 [demo/flow] F13: Private DNS · F13_forward owner=pod hop=[0, 0] dir=forward stop=False · clip=`d211c1f75649ff9d`
- s0172 [demo/flow] F13: Private A subnet route lookup · F13_forward owner=vpc hop=[0, 0] dir=forward stop=False · clip=`48c92e25234927c0`
- s0173 [demo/flow] F13: Endpoint SG + endpoint policy + IAM · F13_forward owner=vpce hop=[1, 1] dir=forward stop=False · clip=`ca200d5637b897f0`
- s0174 [demo/flow] F13: Separate ECR/S3 layer subflow · F13_forward owner=aws hop=[2, 2] dir=forward stop=False · clip=`6ca88f213600f8cb`
- s0175 [demo/flow] F13: ECR S3 layer download (separate connection) · F13_sub1 owner=vpc hop=[0, 0] dir=subflow stop=False · clip=`c57ae5a3acd71bdf`
- s0176 [demo/flow] F13: ECR S3 layer download (separate connection) · F13_sub1 owner=aws hop=[1, 1] dir=subflow stop=False · clip=`45af3fb321de0a84`
- s0177 [demo/flow] F13: ECR S3 layer download (separate connection) · F13_sub1 owner=vpc hop=[2, 2] dir=subflow stop=False · clip=`2957a504c35e497c`
- s0178 [demo/flow] F13: ECR S3 layer download (separate connection) · F13_sub1 owner=pod hop=[3, 3] dir=subflow stop=False · clip=`8a0de5d8f8769512`
- s0179 [demo/flow] F13: Terminal return delivery · F13_return owner=vpce hop=[0, 0] dir=return stop=False · clip=`1cb38b4af9165aa0`
- s0180 [demo/flow] F13: Endpoint subnet return local route · F13_return owner=vpc hop=[1, 1] dir=return stop=False · clip=`56c2b374e50f0849`
- s0181 [demo/flow] F13: Terminal return delivery · F13_return owner=pod hop=[2, 2] dir=return stop=False · clip=`50de82917990e197`
- s0182 [lecture/command] Optional private endpoints · clip=`a1e6c931b4e18fe6`
- s0183 [lecture/takeaway] Egress takeaway · clip=`58dba4c3301daccf`

## Ch14 Expose applications — 18 scenes (14 demos)
- Timing: audio=471.840s · scheduled=484.840s · indices [184,202)

- s0184 [lecture/hero] Expose applications · clip=`80af4c4805f404d8`
- s0185 [demo/flow] F09: TLS termination and L7 rule/healthy target selection · F09_forward owner=alb hop=[0, 0] dir=forward stop=False · clip=`a996daaefc950838`
- s0186 [demo/flow] F09: ALB subnet route lookup · F09_forward owner=vpc hop=[1, 1] dir=forward stop=False · clip=`dec56aa910ff67c1`
- s0187 [demo/flow] F09: Terminal delivery to destination · F09_forward owner=pod hop=[2, 2] dir=forward stop=False · clip=`7146bc53b52da61b`
- s0188 [demo/flow] F09: Backend subnet route lookup · F09_return owner=vpc hop=[0, 0] dir=return stop=False · clip=`5bd9636c703eefd1`
- s0189 [demo/flow] F09: Proxy backend response onto client TLS connection · F09_return owner=alb hop=[1, 1] dir=return stop=False · clip=`c76179d8a5672552`
- s0190 [demo/flow] F09: Terminal return delivery · F09_return owner=client hop=[2, 2] dir=return stop=False · clip=`425e7829a23c30bb`
- s0191 [demo/flow] F10: ALB subnet route lookup · F10_forward owner=vpcA hop=[0, 0] dir=forward stop=False · clip=`5d1b235b0fb12c51`
- s0192 [demo/flow] F10: NodePort DNAT and external Cluster masquerade · F10_forward owner=node hop=[1, 1] dir=forward stop=False · clip=`f7278bdf60a0c248`
- s0193 [demo/flow] F10: Node subnet route lookup · F10_forward owner=vpcB hop=[2, 2] dir=forward stop=False · clip=`7f33593590cc2221`
- s0194 [demo/flow] F10: Terminal delivery to destination · F10_forward owner=pod hop=[3, 3] dir=forward stop=False · clip=`f5409cd7517f50fa`
- s0195 [demo/flow] F10: PodB subnet route lookup · F10_return owner=vpcB hop=[0, 0] dir=return stop=False · clip=`11ba2897d75609c4`
- s0196 [demo/flow] F10: Reverse conntrack DNAT/SNAT · F10_return owner=node hop=[1, 1] dir=return stop=False · clip=`cd98623554fbb8e6`
- s0197 [demo/flow] F10: NodeA route to ALB · F10_return owner=vpcA hop=[2, 2] dir=return stop=False · clip=`77563bf07306cd4b`
- s0198 [demo/flow] F10: Terminal return delivery · F10_return owner=alb hop=[3, 3] dir=return stop=False · clip=`7acdda66ef295983`
- s0199 [lecture/command] Deploy app first (04-app, B1 namespace order) · clip=`1b4e03a987eea44a`
- s0200 [lecture/command] Install LBC and internal LBs (after 04-app) · clip=`c696a00f1c82f386`
- s0201 [lecture/takeaway] Expose takeaway · clip=`dd068227c078f5ee`

## Ch15 NLB and Gateway API — 22 scenes (19 demos)
- Timing: audio=447.384s · scheduled=463.084s · indices [202,224)

- s0202 [lecture/hero] NLB and Gateway API · clip=`227479faf5dc35a7`
- s0203 [demo/flow] F11: L4 healthy target selection + source/destination translation · F11_forward owner=nlb hop=[0, 0] dir=forward stop=False · clip=`5ec2f6611f6e45b3`
- s0204 [demo/flow] F11: LB subnet route lookup · F11_forward owner=vpc hop=[1, 1] dir=forward stop=False · clip=`0c87931522ba9390`
- s0205 [demo/flow] F11: Terminal delivery to destination · F11_forward owner=pod hop=[2, 2] dir=forward stop=False · clip=`7146bc53b52da61b`
- s0206 [demo/flow] F11: Backend subnet route lookup · F11_return owner=vpc hop=[0, 0] dir=return stop=False · clip=`cb521a51a82734ff`
- s0207 [demo/flow] F11: Reverse flow mapping · F11_return owner=nlb hop=[1, 1] dir=return stop=False · clip=`595bf3749d9d21ba`
- s0208 [demo/flow] F11: Terminal return delivery · F11_return owner=client hop=[2, 2] dir=return stop=False · clip=`1b1376e08dc1a3f4`
- s0209 [demo/flow] F24: Frontend-to-instance tuple mapping · F24_forward owner=nlb hop=[0, 0] dir=forward stop=False · clip=`9917c4126e3e0c2f`
- s0210 [demo/flow] F24: NLB target selection preserving client IPv4 · F24_forward owner=nlb hop=[0, 0] dir=forward stop=False · clip=`db33f57a6289b745`
- s0211 [demo/flow] F24: NLB subnet route to node target · F24_forward owner=nlb hop=[0, 0] dir=forward stop=False · clip=`98771f88d322223e`
- s0212 [demo/flow] F24: Local NodePort DNAT, no remote-node forward · F24_forward owner=node hop=[1, 1] dir=forward stop=False · clip=`52db74459ac64b4c`
- s0213 [demo/flow] F24: Application socket · F24_forward owner=pod hop=[2, 2] dir=forward stop=False · clip=`e88f999daa971889`
- s0214 [demo/flow] F24: Reverse NodePort mapping · F24_return owner=node hop=[0, 0] dir=return stop=False · clip=`c64b5e8f6557af1b`
- s0215 [demo/flow] F24: LB return flow mapping · F24_return owner=nlb hop=[1, 1] dir=return stop=False · clip=`700adad2162396ce`
- s0216 [demo/flow] F24: Terminal return delivery · F24_return owner=client hop=[2, 2] dir=return stop=False · clip=`1b1376e08dc1a3f4`
- s0217 [demo/flow] F25: Resource attachment / ReferenceGrant validation · F25_forward owner=route hop=[0, 0] dir=forward stop=False · clip=`f907ad70740c3318`
- s0218 [demo/flow] F25: IAM-authorized reconciliation · F25_forward owner=ctrl hop=[0, 0] dir=forward stop=False · clip=`221265cb80817d80`
- s0219 [demo/flow] F25: Listener/target provisioning · F25_forward owner=elb hop=[1, 1] dir=forward stop=False · clip=`d3069ba041e6ea62`
- s0220 [demo/flow] F25: Target health · F25_forward owner=target hop=[2, 2] dir=forward stop=False · clip=`ec4b05355d16544e`
- s0221 [demo/flow] F25: Accepted / ResolvedRefs / Programmed status · F25_return owner=ctrl hop=[0, 0] dir=return stop=False · clip=`639703d744c32d2b`
- s0222 [lecture/concept] Guided Gateway note · clip=`58a2756204d56e9c`
- s0223 [lecture/takeaway] NLB/Gateway takeaway · clip=`5be43d92efa16e99`

## Ch16 DNS and TLS operations — 5 scenes (0 demos)
- Timing: audio=154.440s · scheduled=158.440s · indices [224,229)

- s0224 [lecture/hero] DNS and TLS operations · clip=`4383af1d2cb6d602`
- s0225 [lecture/mechanism] Mechanism — resolver and certificate chain · clip=`043197a96ce95409`
- s0226 [lecture/lab] Worked example — owned domain procedure · clip=`49f7c64df2c6de89`
- s0227 [lecture/command] DNS/TLS observation (no unowned writes) · clip=`cd42c512700763e7`
- s0228 [lecture/takeaway] DNS/TLS takeaway · clip=`dacaaa546e1a53e9`

## Ch17 East-west security — 17 scenes (11 demos)
- Timing: audio=545.088s · scheduled=557.588s · indices [229,246)

- s0229 [lecture/hero] East-west security · clip=`6c2264fba30e3ebb`
- s0230 [lecture/mechanism] V1 — discover the real agent · clip=`1395c93500a46087`
- s0231 [lecture/command] Policy agent discovery commands · clip=`1395c93500a46087`
- s0232 [lecture/mechanism] B2/V2 — fixture semantics · clip=`69e5066221901930`
- s0233 [lecture/command] Policy baseline → apply → enforce · clip=`69e5066221901930`
- s0234 [demo/flow] F16: Source subnet VPC route lookup · F16_forward owner=vpc hop=[0, 0] dir=forward stop=False · clip=`90c24e8f0075993a`
- s0235 [demo/flow] F16: Destination ingress NetworkPolicy · F16_forward owner=dest hop=[1, 1] dir=forward stop=True · clip=`b7df28d49d0876b7`
- s0236 [demo/flow] F17: Source egress allow union · F17_forward owner=client hop=[0, 0] dir=forward stop=False · clip=`dfc9a62d39894680`
- s0237 [demo/flow] F17: Subnet route lookup · F17_forward owner=vpc hop=[0, 0] dir=forward stop=False · clip=`4b9ca278c8df9ad1`
- s0238 [demo/flow] F17: Destination ingress allow union · F17_forward owner=web hop=[1, 1] dir=forward stop=False · clip=`0119bb22c222e732`
- s0239 [demo/flow] F17: Reverse route and established policy state · F17_return owner=vpc hop=[0, 0] dir=return stop=False · clip=`c310a409310d61c9`
- s0240 [demo/flow] F17: Terminal return delivery · F17_return owner=client hop=[1, 1] dir=return stop=False · clip=`da0c1a1be1d33c4a`
- s0241 [demo/flow] F26: Source subnet local route · F26_forward owner=vpc hop=[0, 0] dir=forward stop=False · clip=`b7d8ded48d57502c`
- s0242 [demo/flow] F26: Stateless inbound rule · F26_forward owner=nacl hop=[1, 1] dir=forward stop=False · clip=`8554042664ec4a5e`
- s0243 [demo/flow] F26: Response generated · F26_forward owner=dest hop=[2, 2] dir=forward stop=False · clip=`01c8287e5aafe262`
- s0244 [demo/flow] F26: Stateless outbound ordered rules · F26_return owner=nacl hop=[0, 0] dir=return stop=True · clip=`d8d2a04ff5200cf3`
- s0245 [lecture/takeaway] Policy takeaway · clip=`3dd70982e882b59e`

## Ch18 Persistent storage — 11 scenes (8 demos)
- Timing: audio=182.856s · scheduled=190.856s · indices [246,257)

- s0246 [lecture/hero] Persistent storage · clip=`a159e980683ed956`
- s0247 [demo/flow] F18: StorageClass delayed binding · F18_forward owner=pvc hop=[0, 0] dir=forward stop=False · clip=`d15fc58b113bc9e9`
- s0248 [demo/flow] F18: Scheduling selected AZ · F18_forward owner=sched hop=[0, 0] dir=forward stop=False · clip=`a19d811f72183de0`
- s0249 [demo/flow] F18: Bound/ready status · F18_return owner=pvc hop=[0, 0] dir=return stop=False · clip=`33eb0ffe781e24fa`
- s0250 [demo/flow] F18: CSI cloud API control · F18_sub1 owner=ec2 hop=[0, 0] dir=subflow stop=False · clip=`34a1758fc597d08c`
- s0251 [demo/flow] F18: CSI cloud API control · F18_sub1 owner=csi hop=[1, 1] dir=subflow stop=False · clip=`0ba9db6083d385e5`
- s0252 [demo/flow] F18: Node mount · F18_sub2 owner=csi hop=[0, 0] dir=subflow stop=False · clip=`bf22cd1be2c5c9e2`
- s0253 [demo/flow] F27: PV nodeAffinity / CSI topology · F27_forward owner=sched hop=[0, 0] dir=forward stop=True · clip=`1e7596224b85488d`
- s0254 [demo/flow] F27: Pending event / repair choices · F27_return owner=pod hop=[0, 0] dir=return stop=False · clip=`31674b78097bb5a2`
- s0255 [lecture/command] EBS lab · clip=`7074433c2cc50af5`
- s0256 [lecture/takeaway] Storage takeaway · clip=`edd0db5002adc27f`

## Ch19 Scaling and availability — 15 scenes (12 demos)
- Timing: audio=181.392s · scheduled=192.192s · indices [257,272)

- s0257 [lecture/hero] Scaling and availability · clip=`6b1eb2308dbbbe91`
- s0258 [demo/flow] F19: Metrics query · F19_forward owner=metrics hop=[0, 0] dir=forward stop=False · clip=`8b77f13b6d62ae1f`
- s0259 [demo/flow] F19: Desired replica calculation · F19_forward owner=hpa hop=[0, 0] dir=forward stop=False · clip=`c3795bc2cb13afa2`
- s0260 [demo/flow] F19: Unschedulable resource assessment · F19_forward owner=sched hop=[1, 1] dir=forward stop=False · clip=`f7fd5b2c94be3f99`
- s0261 [demo/flow] F19: Choose ONE capacity owner · F19_forward owner=scaler hop=[2, 2] dir=forward stop=False · clip=`043b58761d142c02`
- s0262 [demo/flow] F19: EC2 provisioning + bootstrap · F19_forward owner=node hop=[3, 3] dir=forward stop=False · clip=`162b68f87084fbcc`
- s0263 [demo/flow] F19: Readiness and EndpointSlice inclusion · F19_forward owner=pod hop=[4, 4] dir=forward stop=False · clip=`5b1ca9bc9a6b31d7`
- s0264 [demo/flow] F19: Observed metrics stabilize · F19_return owner=hpa hop=[0, 0] dir=return stop=False · clip=`ec34170cca99ea37`
- s0265 [demo/flow] F20: Rolling update budget · F20_forward owner=deploy hop=[0, 0] dir=forward stop=False · clip=`1f9b3884df8db224`
- s0266 [demo/flow] F20: Startup then readiness · F20_forward owner=new hop=[0, 0] dir=forward stop=False · clip=`61442f1fc9117a23`
- s0267 [demo/flow] F20: Target registration/health · F20_forward owner=lb hop=[1, 1] dir=forward stop=False · clip=`f80e617a82ee460e`
- s0268 [demo/flow] F20: Termination and deregistration · F20_forward owner=old hop=[2, 2] dir=forward stop=False · clip=`34586d71f0a611bc`
- s0269 [demo/flow] F20: Rollout observed generation · F20_return owner=deploy hop=[0, 0] dir=return stop=False · clip=`0af51555ef28da50`
- s0270 [lecture/command] HPA lab · clip=`14ae0a4ea1c38585`
- s0271 [lecture/takeaway] Scale takeaway · clip=`a8c0e585f7c314ee`

## Ch20 Observability — 5 scenes (0 demos)
- Timing: audio=151.968s · scheduled=155.968s · indices [272,277)

- s0272 [lecture/hero] Observability · clip=`25e97e1786cf04b2`
- s0273 [lecture/mechanism] Mechanism — pick the layer · clip=`64e75fb783fc578b`
- s0274 [lecture/lab] Worked diagnosis walkthrough · clip=`561904a7edcd4ea7`
- s0275 [lecture/command] Diagnostics · clip=`e838e6a2a64507af`
- s0276 [lecture/takeaway] Observe takeaway · clip=`d2d44fff16fbf9f1`

## Ch21 Failure lab practicum — 16 scenes (13 demos)
- Timing: audio=335.448s · scheduled=346.948s · indices [277,293)

- s0277 [lecture/hero] Failure lab practicum · clip=`6e100e462c48eb94`
- s0278 [demo/flow] F22: IAM authentication succeeds · F22_forward owner=api hop=[0, 0] dir=forward stop=False · clip=`96366eefd226094d`
- s0279 [demo/flow] F22: RBAC/EKS access authorization · F22_forward owner=api hop=[0, 0] dir=forward stop=False · clip=`2a0c7df51f93f6ff`
- s0280 [demo/flow] F22: 403 response on existing TLS session · F22_return owner=api hop=[0, 0] dir=return stop=True · clip=`4d6de9740f516541`
- s0281 [demo/flow] F23: Scheduling successful · F23_forward owner=sched hop=[0, 0] dir=forward stop=False · clip=`c64c070384af7c26`
- s0282 [demo/flow] F23: CNI ADD · F23_forward owner=kubelet hop=[0, 0] dir=forward stop=False · clip=`f2df8dcc3264ca5a`
- s0283 [demo/flow] F23: IP/prefix allocation · F23_forward owner=ipamd hop=[1, 1] dir=forward stop=False · clip=`34db3078b01bebe0`
- s0284 [demo/flow] F23: Error events and retry · F23_return owner=kubelet hop=[0, 0] dir=return stop=True · clip=`97ef0597f9f70f6d`
- s0285 [demo/flow] F26: Source subnet local route · F26_forward owner=vpc hop=[0, 0] dir=forward stop=False · clip=`b7d8ded48d57502c`
- s0286 [demo/flow] F26: Stateless inbound rule · F26_forward owner=nacl hop=[1, 1] dir=forward stop=False · clip=`8554042664ec4a5e`
- s0287 [demo/flow] F26: Response generated · F26_forward owner=dest hop=[2, 2] dir=forward stop=False · clip=`01c8287e5aafe262`
- s0288 [demo/flow] F26: Stateless outbound ordered rules · F26_return owner=nacl hop=[0, 0] dir=return stop=True · clip=`d8d2a04ff5200cf3`
- s0289 [demo/flow] F27: PV nodeAffinity / CSI topology · F27_forward owner=sched hop=[0, 0] dir=forward stop=True · clip=`1e7596224b85488d`
- s0290 [demo/flow] F27: Pending event / repair choices · F27_return owner=pod hop=[0, 0] dir=return stop=False · clip=`31674b78097bb5a2`
- s0291 [lecture/mechanism] Troubleshooting order · clip=`3107c2474f0907f9`
- s0292 [lecture/takeaway] Failure takeaway · clip=`77981a08d57ef099`

## Ch22 Upgrade and release engineering — 21 scenes (12 demos)
- Timing: audio=436.128s · scheduled=451.728s · indices [293,314)

- s0293 [lecture/hero] Upgrade and release engineering · clip=`d300bb9b2c241a9a`
- s0294 [lecture/mechanism] B3 — preparation before control-plane rollback · clip=`d0c550c010d2e75a`
- s0295 [lecture/concept] F28 narrator beat · clip=`69bec7194fdf35ed`
- s0296 [lecture/concept] F28 narrator beat · clip=`6d7ad27341056216`
- s0297 [lecture/concept] F28 narrator beat · clip=`fcc92c9f7d817d71`
- s0298 [lecture/concept] F28 narrator beat · clip=`f883d11d0d8cd436`
- s0299 [demo/flow] F28: Eligibility and rollback-readiness insights · F28_forward owner=gate hop=[0, 0] dir=forward stop=False · clip=`3bac756af5af71c1`
- s0300 [demo/flow] F28: Target-compatible worker preparation · F28_forward owner=nodes hop=[0, 0] dir=forward stop=False · clip=`85719361a9bc0cd3`
- s0301 [demo/flow] F28: PRE-CP addon compatibility preparation · F28_forward owner=nodes hop=[0, 0] dir=forward stop=False · clip=`f0ea510e5193ab85`
- s0302 [demo/flow] F28: EKS managed previous-minor rollback · F28_forward owner=cp hop=[1, 1] dir=forward stop=False · clip=`7e874e4879a08493`
- s0303 [demo/flow] F28: Post-rollback validation · F28_forward owner=verify hop=[2, 2] dir=forward stop=False · clip=`0a1a7cab1722b3f2`
- s0304 [demo/flow] F28: Recorded recovery decision · F28_return owner=gate hop=[0, 0] dir=return stop=False · clip=`397b157bb4f242d6`
- s0305 [demo/flow] F21: Compatibility and capacity gate · F21_forward owner=plan hop=[0, 0] dir=forward stop=False · clip=`18c7950bba8339ae`
- s0306 [demo/flow] F21: Managed control-plane update · F21_forward owner=cp hop=[0, 0] dir=forward stop=False · clip=`76f22e0e7dba693b`
- s0307 [demo/flow] F21: Version-specific component compatibility · F21_forward owner=addons hop=[1, 1] dir=forward stop=False · clip=`1ff6c76c2e340a21`
- s0308 [demo/flow] F21: Managed nodegroup replacement · F21_forward owner=nodes hop=[2, 2] dir=forward stop=False · clip=`6a587f3ebd943b77`
- s0309 [demo/flow] F21: Workload and network acceptance · F21_forward owner=test hop=[3, 3] dir=forward stop=False · clip=`81fe734ddc1faa86`
- s0310 [demo/flow] F21: Outcome / rollback decision · F21_return owner=plan hop=[0, 0] dir=return stop=False · clip=`9b872bc498777a45`
- s0311 [lecture/command] Rollback command reference (authorized only) · clip=`d0c550c010d2e75a`
- s0312 [lecture/command] Upgrade planning read-only · clip=`70ca089bf5b8d4c6`
- s0313 [lecture/takeaway] Upgrade takeaway · clip=`a34237ddee3c2d13`

## Ch23 Production security and cost — 7 scenes (4 demos)
- Timing: audio=107.184s · scheduled=112.384s · indices [314,321)

- s0314 [lecture/hero] Production security and cost · clip=`95222a44c5516043`
- s0315 [demo/flow] F29: Backup consistency and keys · F29_forward owner=backup hop=[0, 0] dir=forward stop=False · clip=`a38bcd2bcba021e9`
- s0316 [demo/flow] F29: Independent recovery target · F29_forward owner=restore hop=[0, 0] dir=forward stop=False · clip=`f006668aa8f103e0`
- s0317 [demo/flow] F29: Correctness before DNS cutover · F29_forward owner=validate hop=[1, 1] dir=forward stop=False · clip=`392803b846f19c83`
- s0318 [demo/flow] F29: Ordered deletion gate · F29_forward owner=delete hop=[2, 2] dir=forward stop=False · clip=`7e9e3a2958e5d732`
- s0319 [lecture/concept] DR tabletop · clip=`96df4e4168de4fdb`
- s0320 [lecture/takeaway] Sec/cost takeaway · clip=`baf23b38b57f24e9`

## Ch24 Terraform progression — 9 scenes (0 demos)
- Timing: audio=240.984s · scheduled=248.184s · indices [321,330)

- s0321 [lecture/hero] Terraform progression · clip=`9652aec7eaf53c9f`
- s0322 [lecture/mechanism] Prerequisites and ownership boundary · clip=`769be9b5136d41e7`
- s0323 [lecture/lab] Worked commands — init through plan · clip=`303ace03a401a8cd`
- s0324 [lecture/command] Terraform tools and versions · clip=`b7f061ebd4b385b4`
- s0325 [lecture/command] Terraform init fmt validate plan · clip=`623a8879d250d397`
- s0326 [lecture/command] Terraform apply and outputs (authorized sandbox only) · clip=`76a4788581c9f34d`
- s0327 [lecture/mechanism] Phase boundary — AWS then Kubernetes · clip=`7674bf3bf49f49d6`
- s0328 [lecture/lab] Destroy and evidence · clip=`4db872502f84512d`
- s0329 [lecture/takeaway] Terraform takeaway · clip=`1e0252a6df8e9ff6`

## Ch25 Capstone and teardown — 5 scenes (0 demos)
- Timing: audio=72.792s · scheduled=76.792s · indices [330,335)

- s0330 [lecture/hero] Capstone and teardown · clip=`b19f3e8b1b5162fb`
- s0331 [lecture/concept] Selected path recap · clip=`a47ce30dc4503ffc`
- s0332 [lecture/command] Teardown order · clip=`724fcfd762319c53`
- s0333 [lecture/hero] Thank you · clip=`767f1fe0b92e1030`
- s0334 [lecture/takeaway] Final hold · clip=`2579ddb19794fec4`

