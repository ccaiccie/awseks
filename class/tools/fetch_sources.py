#!/usr/bin/env python3
"""Read-only public documentation snapshots. No cloud API/account access."""
import concurrent.futures,datetime,hashlib,json,pathlib,requests
from bs4 import BeautifulSoup
ROOT=pathlib.Path(__file__).resolve().parents[1]
E='https://docs.aws.amazon.com/eks/latest/userguide/'
items={
'S01':E+'kubernetes-versions.html','S02':E+'clusters.html','S03':E+'cluster-endpoint.html',
'S04':E+'network-reqs.html','S05':E+'sec-group-reqs.html','S06':E+'access-entries.html',
'S07':E+'create-kubeconfig.html','S08':E+'pod-networking.html','S09':E+'cni-increase-ip-addresses.html',
'S10':E+'cni-custom-network.html','S11':E+'security-groups-for-pods.html','S12':E+'cni-network-policy-configure.html',
'S13':E+'external-snat.html','S14':E+'private-clusters.html','S15':E+'pod-identities.html',
'S16':E+'pod-id-how-it-works.html','S17':E+'iam-roles-for-service-accounts.html','S18':E+'auto-networking.html',
'S19':E+'fargate.html','S20':E+'managed-node-groups.html','S21':E+'ebs-csi.html','S22':E+'efs-csi.html',
'S23':E+'update-cluster.html','S24':E+'control-plane-logs.html','S25':E+'managing-kube-proxy.html',
'S26':'https://kubernetes.io/docs/reference/networking/virtual-ips/',
'S27':'https://kubernetes.io/docs/concepts/services-networking/network-policies/',
'S28':'https://kubernetes.io/docs/concepts/services-networking/service/',
'S29':'https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/gateway/gateway/',
'S30':'https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/ingress/annotations/',
'S31':'https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/service/annotations/',
'S32':'https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/installation/',
'S33':'https://docs.aws.amazon.com/elasticloadbalancing/latest/network/edit-target-group-attributes.html',
'S34':'https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html',
'S35':'https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html',
'S36':'https://docs.aws.amazon.com/eks/latest/best-practices/cas.html',
'S37':'https://docs.aws.amazon.com/eks/latest/best-practices/karpenter.html',
'S38':'https://docs.aws.amazon.com/eks/latest/best-practices/cost-opt-networking.html',
'S39':'https://docs.aws.amazon.com/cli/latest/reference/eks/create-cluster.html',
'S40':'https://docs.aws.amazon.com/cli/latest/reference/eks/describe-cluster-versions.html',
'S41':'https://kubernetes.io/docs/concepts/workloads/controllers/deployment/',
'S42':'https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/',
'S43':'https://kubernetes.io/docs/concepts/storage/storage-classes/',
'S44':E+'cni-ipv6.html','S45':'https://docs.aws.amazon.com/eks/latest/best-practices/prefix-mode-linux.html',
'S46':E+'auto-configure-gateway-api.html','S47':'https://aws.amazon.com/eks/pricing/',
'S48':'https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html',
'S49':'https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/tag/v3.6.2',
'S50':E+'rollback-cluster.html',
'S51':'https://docs.aws.amazon.com/eks/latest/best-practices/security.html',
'S52':'https://docs.aws.amazon.com/eks/latest/best-practices/reliability.html',
'S53':E+'alternate-cni-plugins.html',
'S54':'https://kubernetes.io/docs/concepts/configuration/secret/',
'S55':'https://kubernetes.io/docs/concepts/architecture/',
'S56':'https://docs.aws.amazon.com/cli/latest/reference/eks/create-nodegroup.html',
'S67':E+'cni-network-policy.html','S68':'https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/master/aws-k8s-cni.yaml','S69':'https://kubernetes.io/docs/reference/using-api/api-concepts/',
'S60':E+'eks-architecture.html',
'S61':'https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/gateway/l7gateway/',
'S62':'https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-elb-load-balancer.html',
'S63':'https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html',
'S64':'https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html',
'S65':'https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html',
'S66':'https://docs.aws.amazon.com/cli/latest/reference/eks/describe-addon-configuration.html',
'S58':E+'pod-id-role.html','S59':E+'pod-id-abac.html',
'S57':'https://docs.aws.amazon.com/cli/latest/reference/eks/create-pod-identity-association.html',
}
def fetch(pair):
 i,u=pair
 try:
  r=requests.get(u,timeout=40);r.raise_for_status();r.encoding='utf-8'
  soup=BeautifulSoup(r.text,'html.parser');body=soup.find('main') or soup.find(id='main-content') or soup.body or soup
  for e in body(['script','style','nav','footer']): e.decompose()
  text=r.text if u.endswith('.yaml') else body.get_text('\n',strip=True)
  (ROOT/'sources'/f'{i}.txt').write_text(f'URL: {u}\nFetched: {datetime.datetime.now().astimezone().isoformat()}\n\n{text}\n')
  return {'id':i,'url':u,'status':r.status_code,'bytes':len(text),'sha256':hashlib.sha256(text.encode()).hexdigest(),'file':f'sources/{i}.txt'}
 except Exception as e:return {'id':i,'url':u,'error':str(e)}
with concurrent.futures.ThreadPoolExecutor(max_workers=10) as p: out=sorted(p.map(fetch,items.items()),key=lambda x:x['id'])
(ROOT/'sources/index.json').write_text(json.dumps(out,indent=2)+'\n')
for r in out:print(r['id'],r.get('bytes',r.get('error')))
