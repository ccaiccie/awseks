#!/usr/bin/env python3
"""Conservative live-observation gate, stdlib only. Inputs are operator-captured JSON.
This proves configuration/readiness prerequisites, NEVER actual packet enforcement.
No API or network calls are made by this parser.
"""
import json,pathlib,re,sys

def inspect(addon,schema,ds,pods,nodes,expected):
 a=addon['addon'];assert a['addonVersion']==expected,'Live CNI build differs from recorded pin; review compatibility before policy lab'
 assert a['status']=='ACTIVE','CNI addon not ACTIVE'
 cfg=json.loads(a.get('configurationValues') or '{}')
 assert str(cfg.get('enableNetworkPolicy','')).lower()=='true','CNI addon configuration does not explicitly enableNetworkPolicy'
 sc=json.loads(schema['configurationSchema']);assert 'enableNetworkPolicy' in json.dumps(sc),'Pinned addon schema does not expose reviewed enableNetworkPolicy field'
 candidates=[]
 for c in ds['spec']['template']['spec']['containers']:
  # Deliberately NOT a hardcoded container name. Unknown renamed/repackaged images STOP for review.
  image=c.get('image','');args=c.get('command',[])+c.get('args',[])
  if re.search(r'(?:^|/)aws-network-policy-agent(?=[:@]|$)',image):candidates.append((c,args))
 assert len(candidates)==1,'Cannot uniquely identify policy-agent from documented image; inspect exact pinned build, do not guess by name'
 c,args=candidates[0];flags=[]
 for i,arg in enumerate(args):
  if arg.startswith('--enable-network-policy='):flags.append(arg.split('=',1)[1].lower())
  elif arg=='--enable-network-policy':flags.append(args[i+1].lower() if i+1<len(args) else '')
 assert flags==['true'],'Policy-agent enable flag not explicitly and uniquely true; presence alone is insufficient'
 uid=ds['metadata']['uid'];status=ds['status'];desired=status.get('desiredNumberScheduled',0)
 assert desired>0 and status.get('observedGeneration',0)>=ds['metadata'].get('generation',1),'DaemonSet not observed/scheduled'
 assert status.get('numberReady')==desired and status.get('updatedNumberScheduled')==desired,'Not all policy-agent DaemonSet Pods updated/ready'
 owned=[p for p in pods['items'] if not p['metadata'].get('deletionTimestamp') and any(r.get('controller') and r.get('uid')==uid for r in p['metadata'].get('ownerReferences',[]))]
 assert len(owned)==desired,'DaemonSet owned Pod count differs from desired; wait for rollout'
 for p in owned:
  spec=[x for x in p['spec']['containers'] if x['name']==c['name']]
  assert len(spec)==1 and spec[0].get('image')==c['image'],'Pod agent image differs from rendered DaemonSet'
  sts=[x for x in p['status'].get('containerStatuses',[]) if x['name']==c['name']]
  assert len(sts)==1 and sts[0].get('ready') is True and sts[0].get('state',{}).get('running') is not None,'Agent container not ready/running'
  assert sts[0].get('imageID'),'Missing observed agent imageID'
 linux={n['metadata']['name'] for n in nodes['items'] if n['metadata'].get('labels',{}).get('kubernetes.io/os')=='linux'}
 assert all(any(c.get('type')=='Ready' and c.get('status')=='True' for c in n.get('status',{}).get('conditions',[])) for n in nodes['items'] if n['metadata']['name'] in linux),'A primary Linux node is not Ready'
 assert linux and linux=={p['spec']['nodeName'] for p in owned},'Primary Linux-node coverage differs; review unsupported/node-selector/taint variants'
 return {'gate':'CONFIGURATION_AND_READINESS_ONLY','addonVersion':expected,'container':c['name'],'image':c['image'],'enableFlags':flags,'pods':[p['metadata']['name'] for p in owned],'nodes':sorted(linux),'enforcementProven':False,'next':'Review managed PolicyEndpoint objects and agent evidence; run independent fresh-connection baseline/enforce tests. Never edit/delete PolicyEndpoints.'}

if __name__=='__main__':
 try:
  *paths,expected=sys.argv[1:];assert len(paths)==5
  print(json.dumps(inspect(*(json.loads(pathlib.Path(p).read_text()) for p in paths),expected),indent=2))
 except (AssertionError,KeyError,ValueError) as e:
  print(f'POLICY LIVE GATE STOP: {e}',file=sys.stderr);sys.exit(1)
