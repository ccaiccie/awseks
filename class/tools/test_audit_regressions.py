#!/usr/bin/env python3
"""Synthetic/local audit regression tests. Never import/run a shell lab or contact AWS."""
import copy,hashlib,importlib.util,json,pathlib,unittest,yaml
R=pathlib.Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('policy_agent',R/'labs/helpers/inspect_policy_agent.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)

def fixture():
 name='aws-eks-nodeagent';image='602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon/aws-network-policy-agent:v1.5.0'
 a={'addon':{'addonVersion':'vTEST-eksbuild.1','status':'ACTIVE','configurationValues':'{"enableNetworkPolicy":"true"}'}}
 schema={'configurationSchema':'{"properties":{"enableNetworkPolicy":{"type":"string"}}}'}
 ds={'metadata':{'uid':'ds1','generation':1},'spec':{'template':{'spec':{'containers':[{'name':name,'image':image,'args':['--enable-network-policy=true']}]}}},'status':{'desiredNumberScheduled':1,'observedGeneration':1,'numberReady':1,'updatedNumberScheduled':1}}
 pod={'metadata':{'name':'aws-node-test','ownerReferences':[{'uid':'ds1','controller':True}]},'spec':{'nodeName':'node-a','containers':[{'name':name,'image':image}]},'status':{'containerStatuses':[{'name':name,'ready':True,'state':{'running':{}},'imageID':'repo@sha256:synthetic'}]}}
 nodes={'items':[{'metadata':{'name':'node-a','labels':{'kubernetes.io/os':'linux'}},'status':{'conditions':[{'type':'Ready','status':'True'}]}}]}
 return [a,schema,ds,{'items':[pod]},nodes,'vTEST-eksbuild.1']

class PolicyAgentTests(unittest.TestCase):
 def test_documented_agent_name_is_discovered_by_image(self):self.assertEqual(m.inspect(*fixture())['container'],'aws-eks-nodeagent')
 def test_different_container_name_still_works(self):
  f=fixture()
  for c in [f[2]['spec']['template']['spec']['containers'][0],f[3]['items'][0]['spec']['containers'][0],f[3]['items'][0]['status']['containerStatuses'][0]]:c['name']='other-build-container-name'
  self.assertEqual(m.inspect(*f)['container'],'other-build-container-name')
 def reject(self,mutate):
  f=fixture();mutate(f)
  with self.assertRaises(AssertionError):m.inspect(*f)
 def test_false_enable_flag_rejected(self):self.reject(lambda f:f[2]['spec']['template']['spec']['containers'][0].update(args=['--enable-network-policy=false']))
 def test_missing_flag_rejected(self):self.reject(lambda f:f[2]['spec']['template']['spec']['containers'][0].update(args=[]))
 def test_unknown_image_rejected_even_if_name_matches(self):self.reject(lambda f:f[2]['spec']['template']['spec']['containers'][0].update(image='unknown:tag'))
 def test_pinned_build_drift_rejected(self):self.reject(lambda f:f[0]['addon'].update(addonVersion='another-build'))
 def test_addon_not_active_rejected(self):self.reject(lambda f:f[0]['addon'].update(status='DEGRADED'))
 def test_addon_not_enabled_rejected(self):self.reject(lambda f:f[0]['addon'].update(configurationValues='{}'))
 def test_schema_not_supported_rejected(self):self.reject(lambda f:f[1].update(configurationSchema='{}'))
 def test_ds_not_ready_rejected(self):self.reject(lambda f:f[2]['status'].update(numberReady=0))
 def test_container_not_ready_rejected(self):self.reject(lambda f:f[3]['items'][0]['status']['containerStatuses'][0].update(ready=False))
 def test_missing_owned_pod_rejected(self):self.reject(lambda f:f[3]['items'][0]['metadata'].update(ownerReferences=[]))
 def test_node_not_ready_rejected(self):self.reject(lambda f:f[4]['items'][0]['status'].update(conditions=[]))
 def test_gate_never_claims_enforcement(self):self.assertFalse(m.inspect(*fixture())['enforcementProven'])

class SourceRegressionTests(unittest.TestCase):
 def test_B1_namespace_real_apply_wait_before_namespaced_dryrun(self):
  s=(R/'labs/scripts/04-app.sh').read_text()
  self.assertLess(s.index('kubectl apply -f "$LAB_ROOT/manifests/namespace.yaml"'),s.index('kubectl wait --for=jsonpath='))
  self.assertLess(s.index('kubectl wait --for=jsonpath='),s.index('kubectl apply --dry-run=server'))
  self.assertFalse(any(d['kind']=='Namespace' for d in yaml.safe_load_all((R/'labs/manifests/app.yaml').read_text())))
  n=yaml.safe_load((R/'labs/manifests/namespace.yaml').read_text());self.assertEqual(n['metadata']['labels']['pod-security.kubernetes.io/enforce'],'restricted')
 def test_B2_controller_owned_fixture_and_distinct_equal_port_service(self):
  docs=list(yaml.safe_load_all((R/'labs/manifests/policy-fixture.yaml').read_text()));deploy={d['metadata']['name']:d for d in docs if d['kind']=='Deployment'}
  self.assertEqual(set(deploy),{'permitted-client','blocked-client','egress-sink'})
  self.assertFalse(any(d['kind']=='Pod' for d in docs))
  service=next(d for d in docs if d['kind']=='Service');port=service['spec']['ports'][0];self.assertEqual((port['port'],port['targetPort'],port['name']),(8080,8080,'http'))
  original=next(d for d in yaml.safe_load_all((R/'labs/manifests/app.yaml').read_text()) if d['kind']=='Service');self.assertEqual(original['spec']['ports'][0]['port'],80)
 def test_B2_separate_positives_and_negatives_exist(self):
  s=(R/'labs/scripts/15-client-tests.sh').read_text()
  for t in ['nslookup web-policy','baseline-permitted-sink.log','baseline-blocked-web.log','enforce-blocked-sink-control.log','negative "$BLOCKED" "$WEB_IP"','negative "$PERMITTED" "$SINK_IP"','policy-targets-baseline.json','cmp ']:self.assertIn(t,s)
 def test_B3_pre_cp_addon_preparation_and_variant_hints(self):
  f=next(s for s in json.loads((R/'FLOW-SCENARIOS.json').read_text())['scenarios'] if s['id']=='F28');steps=f['forwardProcessing'];cp=next(i for i,s in enumerate(steps) if s['actor']=='cp');addon=next(i for i,s in enumerate(steps) if s['decisionEngine']=='PRE-CP addon compatibility preparation');self.assertLess(addon,cp)
  self.assertIn('wait addon ACTIVE',steps[addon]['detail']);h=' '.join(f['narrationHints']);self.assertIn('Auto Mode',h);self.assertIn('Fargate',h)
 def test_independent_audit_unchanged(self):
  expected=(R/'sources/independent-audit-original.sha256').read_text().split()[0];self.assertEqual(hashlib.sha256((R/'INDEPENDENT-SOURCE-AUDIT.md').read_bytes()).hexdigest(),expected)

if __name__=='__main__':unittest.main(verbosity=2)
