#!/usr/bin/env python3
"""LOCAL ONLY: syntax/schema/structure/geometry checks. Never invokes AWS or kubectl."""
import concurrent.futures,hashlib,json,pathlib,subprocess,sys,xml.etree.ElementTree as ET
import requests,yaml,jsonschema
R=pathlib.Path(__file__).resolve().parents[1]
report={'scope':'LOCAL STATIC ONLY; no AWS/account/API commands executed','checks':[],'warnings':[]}
def check(name,f):
 try:
  detail=f();report['checks'].append({'name':name,'status':'PASS','detail':detail})
 except Exception as e:report['checks'].append({'name':name,'status':'FAIL','detail':str(e)})
files=sorted((R/'labs/scripts').glob('*.sh'))
def bashsyntax():
 for p in files:subprocess.run(['bash','-n',str(p)],check=True,capture_output=True,text=True)
 return f'{len(files)} scripts parse; no script executed'
check('bash -n',bashsyntax)
def shellcheck():
 p=subprocess.run(['shellcheck','-S','warning',*[str(x) for x in files]],capture_output=True,text=True)
 assert p.returncode==0,p.stdout+p.stderr
 return f'{len(files)} scripts, warning severity or higher, no findings'
check('ShellCheck',shellcheck)
docs=[]
import re
for file in ['08-identity.sh','15-client-tests.sh']:
 text=(R/'labs/scripts'/file).read_text()
 matches=re.findall(r'<<YAML\n(.*?)\nYAML',text,re.S)
 for ix,body in enumerate(matches):
  for key,value in {'$AWSCLI_IMAGE':'public.ecr.aws/aws-cli/aws-cli@sha256:'+'a'*64,'$AWS_REGION':'us-west-2','$DEBUG_IMAGE':'busybox@sha256:'+'b'*64,'$client':'permitted-client'}.items():body=body.replace(key,value)
  docs.append((pathlib.Path(file+f':generated-{ix}'),yaml.safe_load(body)))

def yamlcheck():
 for p in sorted((R/'labs/manifests').glob('*.yaml')):
  for d in yaml.safe_load_all(p.read_text()):
   assert d and all(k in d for k in ['apiVersion','kind','metadata'])
   docs.append((p,d))
 names=[(d['apiVersion'],d['kind'],d['metadata'].get('namespace'),d['metadata']['name']) for _,d in docs]
 assert len(set(names))==len(names)
 return f'{len(docs)} YAML documents, unique object keys and basic structure'
check('YAML parse and object identity',yamlcheck)
SCHEMAS=R/'sources/k8s-schemas';SCHEMAS.mkdir(exist_ok=True)
def schema_for(d):
 api=d['apiVersion'];kind=d['kind'].lower()
 group,version=api.split('/') if '/' in api else ('',api)
 name=f'{kind}-{group.split(".")[0]+"-" if group else ""}{version}.json'
 return name

def fetch_schema(name):
 url=f'https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.36.0-standalone-strict/{name}'
 p=SCHEMAS/name
 if not p.exists():
  r=requests.get(url,timeout=30);r.raise_for_status();p.write_text(r.text)
 return name,json.loads(p.read_text()),url
schema_results={}
for n in sorted(set(schema_for(d) for _,d in docs)):
 try:schema_results[n]=fetch_schema(n)
 except Exception as e:report['warnings'].append(f'Schema unavailable for {n}: {e}')
def schemacheck():
 assert len(schema_results)==len(set(schema_for(d) for _,d in docs)), 'Not all chosen Kubernetes1.36 schemas available; no substitute version asserted'
 for p,d in docs:jsonschema.validate(d,schema_results[schema_for(d)][1])
 return f'{len(docs)} docs validated against strict standalone Kubernetes1.36.0-derived schemas (community schema mirror), NOT live API server'
check('Kubernetes1.36 strict schemas',schemacheck)
(SCHEMAS/'index.json').write_text(json.dumps([{'file':n,'url':v[2],'sha256':hashlib.sha256((SCHEMAS/n).read_bytes()).hexdigest()} for n,v in schema_results.items()],indent=2)+'\n')
model=json.loads((R/'FLOW-SCENARIOS.json').read_text())
def flowcheck():
 assert len(model['scenarios'])==29
 for s in model['scenarios']:
  nodes={n['id']:n for n in s['nodes']}
  for direction,key in [('forward','forwardVisits'),('return','returnVisits')]:
   assert all(x in nodes for x in s[key]);segs=s['hopSegments'][direction]
   assert len(segs)==max(0,len(s[key])-1)
   assert [(z['from'],z['to']) for z in segs]==list(zip(s[key],s[key][1:]))
  for step in s['forwardProcessing']+s['returnProcessing']:
   assert step['actor'] in nodes,(s['id'],step['actor'])
   if step['routeLookup']:
    r=step['routeLookup'];assert all(k in r for k in ['owner','association','lookupDestination','candidates','winner','reason'])
  if s['failure'] and s['failure'].get('direction')!='return':assert s['forwardVisits'][-1]==s['failure']['stopAt']
 return '29 distinct scenarios, forward/return ordering, stop actors and route ownership fields'
check('Scenario semantic structure',flowcheck)
def pointseg(a,b,rect,pad):
 x1,y1=a;x2,y2=b;x,y,w,h=rect
 # Ignore port contact for own endpoints elsewhere; this is unrelated object test only.
 if x1==x2:return x-pad<=x1<=x+w+pad and max(min(y1,y2),y-pad)<=min(max(y1,y2),y+h+pad)
 if y1==y2:return y-pad<=y1<=y+h+pad and max(min(x1,x2),x-pad)<=min(max(x1,x2),x+w+pad)
 raise ValueError('Non-orthogonal segment')
def geometry():
 count=0
 for s in model['scenarios']:
  nodes={n['id']:n for n in s['nodes']};segments=[z for k in ['forward','return'] for z in s['hopSegments'][k]]+[z for sf in s.get('subflows',[]) for z in sf['hopSegments']]
  for h in segments:
   count+=1;pts=h['waypoints']
   assert pts[0]==nodes[h['from']]['ports'][h['sourcePort']]
   assert pts[-1]==nodes[h['to']]['ports'][h['targetPort']]
   for x,y in pts:assert 20<=x<=1900 and 140<=y<620,(s['id'],x,y)
   for a,b in zip(pts,pts[1:]):
    for n in s['nodes']:
     if n['id'] in [h['from'],h['to']]:continue
     q=n['bounds'];assert not pointseg(a,b,(q['x'],q['y'],q['width'],q['height']),20),(s['id'],h['from'],h['to'],n['id'])
  assert all(n['bounds']['y']+n['bounds']['height']<=620 for n in nodes.values())
  assert s['contextBand']['y']>=660 and s['contextBand']['y']+s['contextBand']['height']<=930
 return f'{count} explicit orthogonal inter-device segments incl subflows; unrelated node bounds +20px clearance; topology bottom gap and 930px band bounds. Not full glyph/badge/arrowhead visual sign-off.'
check('Flow geometry',geometry)
def drawio():
 t=ET.parse(R/'diagrams/eks-scenarios.drawio');pages=t.findall('.//diagram');assert len(pages)==29+sum(len(s.get('subflows',[])) for s in model['scenarios'])
 for page in pages:
  cells=page.findall('.//mxCell');ids={c.attrib['id'] for c in cells};assert len(ids)==len(cells)
  for c in cells:
   for k in ['parent','source','target']:
    if k in c.attrib:assert c.attrib[k] in ids
 return f'{len(pages)} pages including explicit subflows, XML parses, unique IDs and valid source/target/parent refs; editor import NOT tested'
check('draw.io XML',drawio)
def svgs():
 for p in (R/'diagrams').glob('*.svg'):ET.parse(p)
 return f'{len(list((R/"diagrams").glob("*.svg")))} valid SVG XMLs'
check('SVG XML',svgs)
(R/'VALIDATION-RESULTS.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
sys.exit(1 if any(c['status']=='FAIL' for c in report['checks']) else 0)
