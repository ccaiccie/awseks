#!/usr/bin/env python3
"""Local optional-budget checks, not an AWS client or permission grant."""
import hashlib,json,pathlib,re,sys
E=pathlib.Path('examples')
def read(n):return json.loads((E/n).read_text())
def stop(ok,why):
    if not ok:raise SystemExit('STOP: '+why)
mode=sys.argv[1]
if mode=='prepare':
    name=sys.argv[2]
    stop(bool(re.fullmatch('unit06a-alert-[0-9a-f]{32}',name)),'use fresh generated name')
    b=read('budget.local.json');n=read('budget-notifications.local.json')
    stop('REPLACE' not in json.dumps(n),'edit YOUR private subscriber copy first')
    stop(all(x['SubscriptionType']=='EMAIL' and '@' in x['Address']
        for v in n for x in v['Subscribers']),'review authorized email destination')
    b['BudgetName']=name
    (E/'budget.local.json').write_text(json.dumps(b,indent=2)+'\n')
elif mode=='identity':
    d=read('budget-identity.local.json');expected=sys.argv[2]
    stop(bool(re.fullmatch('[0-9]{12}',expected)),'twelve-digit intended account required')
    stop(d['Account']==expected and not d['Arn'].endswith(':root'),'wrong account/root')
elif mode=='absent':
    s=(E/'budget-probe.local.err').read_text()
    stop('An error occurred (NotFoundException)' in s,'read failed; NOT proof of absence')
elif mode=='record':
    account,profile,generation=sys.argv[2:]
    b=read('budget.local.json');name=b['BudgetName']
    stop(name=='unit06a-alert-'+generation,'name/generation mismatch')
    owner={'account':account,'profile':profile,'generation':generation,'name':name,
      'arn':'arn:aws:budgets::'+account+':budget/'+name,
      'budget':{k:b[k] for k in ['BudgetName','BudgetLimit','TimeUnit','BudgetType']}}
    with (E/'budget-owner.local.json').open('x') as f:json.dump(owner,f,indent=2)
elif mode=='field':
    key=sys.argv[2];stop(key in ['name','arn','generation'],'unsupported field')
    print(read('budget-owner.local.json')[key])
elif mode=='verify-owner':
    account,profile=sys.argv[2:];o=read('budget-owner.local.json')
    stop(o['account']==account and o['profile']==profile,'recorded owner/account differs')
    b=read('budget-readback.local.json')['Budget']
    stop(all(b.get(k)==v for k,v in o['budget'].items()),'budget differs from creation record')
    tags={v['Key']:v['Value'] for v in read('budget-tags.local.json')['ResourceTags']}
    stop(tags.get('EksClassOwner')=='unit06a' and
         tags.get('EksClassGeneration')==o['generation'],'live original generation tag differs')
else:raise SystemExit('STOP: unsupported local guard mode')
