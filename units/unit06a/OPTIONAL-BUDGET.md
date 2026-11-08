# Optional dedicated monitoring-only budget — NOT a cap

Skip unless authorized. No operation was executed by the builder. Choose ONE shell, follow all blocks in order. Default acknowledgments NO stop on purpose; change only after approval. Requires approved Budgets create/read/tag/delete permissions (including create resource-tags and list-tags-for-resource); ask your administrator, do not expand your own permissions. Commercial AWS endpoint us-east-1, not a partition-generic promise. Budget example USD10 monthly and ACTUAL80% is illustrative. Alerts can lag and cannot stop AWS resources. No budget actions, no Terraform owner. Never commit edited subscriber/account/ownership JSON or error files. Keep private write-once evidence if creation partially succeeds; do not manufacture ownership after a failed create.

Complete local guard source, shipped at scripts/budget_guard.py; visible before use. It validates JSON and original recorded ownership, makes NO AWS calls and grants NO permission.

```python
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
```

## Private copies, exact fresh name, explicit acknowledgment — Bash
Only YOUR authorized subscriber destination in ignored local JSON; bind the actual generated name to BudgetName before any creation.

```bash
BudgetAck="NO"
[ "$BudgetAck" = "YES_CREATE_MY_DEDICATED_ALERT" ] || exit 1
[ ! -e examples/budget-owner.local.json ] || exit 1
cp examples/budget.json examples/budget.local.json || exit 1
cp examples/budget-notifications.json \
  examples/budget-notifications.local.json || exit 1
BudgetGeneration=$(python3 -c 'import uuid;print(uuid.uuid4().hex)') || exit 1
BudgetName="unit06a-alert-$BudgetGeneration"
# Edit ONLY the private notifications copy: replace YOUR email marker locally.
python3 scripts/budget_guard.py prepare "$BudgetName" || exit 1
```
Default NO stops. Successful preparation changes local files only; do not commit email/account metadata.

## Fresh intended-account/non-root guard — Bash
Immediately prove the profile still selects the intended sandbox. A successful different-account response is a STOP, not a new expected-account value.

```bash
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" \
  --output json --no-cli-pager > examples/budget-identity.local.json || exit 1
python3 scripts/budget_guard.py identity "$ExpectedAccount" || exit 1
```
Identity JSON Account equals independently approved ExpectedAccount; no root principal.

## Existing name versus failed read — Bash
ONLY a specific NotFoundException allows the fresh optional creation to continue. Existing budget, AccessDenied, timeout or malformed result STOP.

```bash
if aws budgets describe-budget --profile "$AwsProfile" --region us-east-1 \
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" \
  --output json --no-cli-pager > examples/budget-probe.local.json \
  2> examples/budget-probe.local.err; then
  printf '%s\n' 'STOP: budget already exists; never adopt or replace it'; exit 1
else
  python3 scripts/budget_guard.py absent || exit 1
fi
```
NotFound is the expected fresh-name probe outcome. Never delete/recreate a collision.

## Authorized budget creation and write-once owner record — Bash
AWS MUTATION: create one monitoring-only budget with original generation tag; then record ownership ONLY after successful create. No Terraform co-owner.

```bash
aws budgets create-budget --profile "$AwsProfile" --region us-east-1 \
  --account-id "$ExpectedAccount" --budget file://examples/budget.local.json \
  --notifications-with-subscribers file://examples/budget-notifications.local.json \
  --resource-tags Key=EksClassOwner,Value=unit06a \
  "Key=EksClassGeneration,Value=$BudgetGeneration" --no-cli-pager || exit 1
python3 scripts/budget_guard.py record \
  "$ExpectedAccount" "$AwsProfile" "$BudgetGeneration" || exit 1
BudgetArn=$(python3 scripts/budget_guard.py field arn) || exit 1
```
Create may return empty stdout. That is not verification; next readback must match original name/config/generation.

## Read actual budget, tags, notification and subscriber — Bash
AWS READS, not another mutation. Compare actual settings and original generation; keep the returned email/account information private.

```bash
aws budgets describe-budget --profile "$AwsProfile" --region us-east-1 \
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" \
  --output json --no-cli-pager > examples/budget-readback.local.json || exit 1
aws budgets list-tags-for-resource --profile "$AwsProfile" --region us-east-1 \
  --resource-arn "$BudgetArn" --output json --no-cli-pager \
  > examples/budget-tags.local.json || exit 1
python3 scripts/budget_guard.py verify-owner "$ExpectedAccount" "$AwsProfile" || exit 1
aws budgets describe-notifications-for-budget --profile "$AwsProfile" \
  --region us-east-1 --account-id "$ExpectedAccount" \
  --budget-name "$BudgetName" --output json --no-cli-pager || exit 1
aws budgets describe-subscribers-for-notification --profile "$AwsProfile" \
  --region us-east-1 --account-id "$ExpectedAccount" --budget-name "$BudgetName" \
  --notification file://examples/budget-notification-query.json \
  --output json --no-cli-pager || exit 1
```
Illustrative USD10 MONTHLY ACTUAL80% threshold; YOUR privately read configuration must agree. Delivery may lag; no cap or automatic cleanup.

## Before deletion: recorded ownership AND fresh identity — Bash
Choose explicit deletion acknowledgment, load only the original owned name/ARN, recheck account and current original-generation tags immediately before delete.

```bash
BudgetDeleteAck="NO"
[ "$BudgetDeleteAck" = "YES_DELETE_ONLY_MY_RECORDED_ALERT" ] || exit 1
BudgetName=$(python3 scripts/budget_guard.py field name) || exit 1
BudgetArn=$(python3 scripts/budget_guard.py field arn) || exit 1

aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" \
  --output json --no-cli-pager > examples/budget-identity.local.json || exit 1
python3 scripts/budget_guard.py identity "$ExpectedAccount" || exit 1

aws budgets describe-budget --profile "$AwsProfile" --region us-east-1 \
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" \
  --output json --no-cli-pager > examples/budget-readback.local.json || exit 1
aws budgets list-tags-for-resource --profile "$AwsProfile" --region us-east-1 \
  --resource-arn "$BudgetArn" --output json --no-cli-pager \
  > examples/budget-tags.local.json || exit 1
python3 scripts/budget_guard.py verify-owner "$ExpectedAccount" "$AwsProfile" || exit 1
```
No valid original record, mismatch, unreadable tags or wrong account means STOP; never adopt a same-name replacement.

## Delete only original owned alert; verify specific absence — Bash
AWS MUTATION only after the preceding adjacent checks. Delete-budget removes a monitoring object, not infrastructure and not spend.

```bash
aws budgets delete-budget --profile "$AwsProfile" --region us-east-1 \
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" --no-cli-pager || exit 1
if aws budgets describe-budget --profile "$AwsProfile" --region us-east-1 \
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" \
  --output json --no-cli-pager > examples/budget-probe.local.json \
  2> examples/budget-probe.local.err; then
  printf '%s\n' 'STOP: budget still returned; inspect before claiming deletion'; exit 1
else
  python3 scripts/budget_guard.py absent || exit 1
fi
```
Specific NotFoundException for this budget is expected afterward. Denied/failed read is NOT successful deletion.

## Private copies, exact fresh name, explicit acknowledgment — PowerShell
Only YOUR authorized subscriber destination in ignored local JSON; bind the actual generated name to BudgetName before any creation.

```powershell
$ErrorActionPreference = "Stop"
$BudgetAck = "NO"
if ($BudgetAck -ne "YES_CREATE_MY_DEDICATED_ALERT") { throw 'STOP: not approved' }
if (Test-Path examples/budget-owner.local.json) { throw 'STOP: existing owner record' }
Copy-Item examples/budget.json examples/budget.local.json -ErrorAction Stop
Copy-Item examples/budget-notifications.json `
  examples/budget-notifications.local.json -ErrorAction Stop
$BudgetGeneration = [guid]::NewGuid().ToString('N')
$BudgetName = "unit06a-alert-$BudgetGeneration"
# Edit ONLY the private notifications copy: replace YOUR email marker locally.
py -3 scripts/budget_guard.py prepare "$BudgetName"
if ($LASTEXITCODE -ne 0) { throw 'STOP: private JSON validation failed' }
```
Default NO stops. Successful preparation changes local files only; do not commit email/account metadata.

## Fresh intended-account/non-root guard — PowerShell
Immediately prove the profile still selects the intended sandbox. A successful different-account response is a STOP, not a new expected-account value.

```powershell
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" `
  --output json --no-cli-pager > examples/budget-identity.local.json
if ($LASTEXITCODE -ne 0) { throw 'STOP: fresh identity read failed' }
py -3 scripts/budget_guard.py identity "$ExpectedAccount"
if ($LASTEXITCODE -ne 0) { throw 'STOP: intended account/root guard failed' }
```
Identity JSON Account equals independently approved ExpectedAccount; no root principal.

## Existing name versus failed read — PowerShell
ONLY a specific NotFoundException allows the fresh optional creation to continue. Existing budget, AccessDenied, timeout or malformed result STOP.

```powershell
aws budgets describe-budget --profile "$AwsProfile" --region us-east-1 `
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" `
  --output json --no-cli-pager > examples/budget-probe.local.json `
  2> examples/budget-probe.local.err
if ($LASTEXITCODE -eq 0) { throw 'STOP: existing budget; never adopt it' }
py -3 scripts/budget_guard.py absent
if ($LASTEXITCODE -ne 0) { throw 'STOP: read failure is not absence' }
```
NotFound is the expected fresh-name probe outcome. Never delete/recreate a collision.

## Authorized budget creation and write-once owner record — PowerShell
AWS MUTATION: create one monitoring-only budget with original generation tag; then record ownership ONLY after successful create. No Terraform co-owner.

```powershell
aws budgets create-budget --profile "$AwsProfile" --region us-east-1 `
  --account-id "$ExpectedAccount" --budget file://examples/budget.local.json `
  --notifications-with-subscribers file://examples/budget-notifications.local.json `
  --resource-tags Key=EksClassOwner,Value=unit06a `
  "Key=EksClassGeneration,Value=$BudgetGeneration" --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw 'STOP: creation failed; no owner record written' }
py -3 scripts/budget_guard.py record `
  "$ExpectedAccount" "$AwsProfile" "$BudgetGeneration"
if ($LASTEXITCODE -ne 0) { throw 'STOP: keep evidence; ownership recording failed' }
$BudgetArn = py -3 scripts/budget_guard.py field arn
if ($LASTEXITCODE -ne 0) { throw 'STOP: owner record read failed' }
```
Create may return empty stdout. That is not verification; next readback must match original name/config/generation.

## Read actual budget, tags, notification and subscriber — PowerShell
AWS READS, not another mutation. Compare actual settings and original generation; keep the returned email/account information private.

```powershell
aws budgets describe-budget --profile "$AwsProfile" --region us-east-1 `
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" `
  --output json --no-cli-pager > examples/budget-readback.local.json
if ($LASTEXITCODE -ne 0) { throw 'STOP: readback failed' }
aws budgets list-tags-for-resource --profile "$AwsProfile" --region us-east-1 `
  --resource-arn "$BudgetArn" --output json --no-cli-pager `
  > examples/budget-tags.local.json
if ($LASTEXITCODE -ne 0) { throw 'STOP: live generation tags unreadable' }
py -3 scripts/budget_guard.py verify-owner "$ExpectedAccount" "$AwsProfile"
if ($LASTEXITCODE -ne 0) { throw 'STOP: original ownership differs' }
aws budgets describe-notifications-for-budget --profile "$AwsProfile" `
  --region us-east-1 --account-id "$ExpectedAccount" `
  --budget-name "$BudgetName" --output json --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw 'STOP: notification read failed' }
aws budgets describe-subscribers-for-notification --profile "$AwsProfile" `
  --region us-east-1 --account-id "$ExpectedAccount" --budget-name "$BudgetName" `
  --notification file://examples/budget-notification-query.json `
  --output json --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw 'STOP: subscriber read failed' }
```
Illustrative USD10 MONTHLY ACTUAL80% threshold; YOUR privately read configuration must agree. Delivery may lag; no cap or automatic cleanup.

## Before deletion: recorded ownership AND fresh identity — PowerShell
Choose explicit deletion acknowledgment, load only the original owned name/ARN, recheck account and current original-generation tags immediately before delete.

```powershell
$ErrorActionPreference = "Stop"
$BudgetDeleteAck = "NO"
if ($BudgetDeleteAck -ne "YES_DELETE_ONLY_MY_RECORDED_ALERT") { throw 'STOP: not approved' }
$BudgetName = py -3 scripts/budget_guard.py field name
if ($LASTEXITCODE -ne 0) { throw 'STOP: no original name record' }
$BudgetArn = py -3 scripts/budget_guard.py field arn
if ($LASTEXITCODE -ne 0) { throw 'STOP: no original ARN record' }

aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" `
  --output json --no-cli-pager > examples/budget-identity.local.json
if ($LASTEXITCODE -ne 0) { throw 'STOP: fresh identity read failed' }
py -3 scripts/budget_guard.py identity "$ExpectedAccount"
if ($LASTEXITCODE -ne 0) { throw 'STOP: intended account/root guard failed' }

aws budgets describe-budget --profile "$AwsProfile" --region us-east-1 `
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" `
  --output json --no-cli-pager > examples/budget-readback.local.json
if ($LASTEXITCODE -ne 0) { throw 'STOP: readback failed' }
aws budgets list-tags-for-resource --profile "$AwsProfile" --region us-east-1 `
  --resource-arn "$BudgetArn" --output json --no-cli-pager `
  > examples/budget-tags.local.json
if ($LASTEXITCODE -ne 0) { throw 'STOP: live generation tags unreadable' }
py -3 scripts/budget_guard.py verify-owner "$ExpectedAccount" "$AwsProfile"
if ($LASTEXITCODE -ne 0) { throw 'STOP: original ownership differs' }
```
No valid original record, mismatch, unreadable tags or wrong account means STOP; never adopt a same-name replacement.

## Delete only original owned alert; verify specific absence — PowerShell
AWS MUTATION only after the preceding adjacent checks. Delete-budget removes a monitoring object, not infrastructure and not spend.

```powershell
aws budgets delete-budget --profile "$AwsProfile" --region us-east-1 `
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw 'STOP: deletion request failed' }
aws budgets describe-budget --profile "$AwsProfile" --region us-east-1 `
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" `
  --output json --no-cli-pager > examples/budget-probe.local.json `
  2> examples/budget-probe.local.err
if ($LASTEXITCODE -eq 0) { throw 'STOP: budget still returned' }
py -3 scripts/budget_guard.py absent
if ($LASTEXITCODE -ne 0) { throw 'STOP: failed read is NOT proof of deletion' }
```
Specific NotFoundException for this budget is expected afterward. Denied/failed read is NOT successful deletion.

Official CLI source: https://docs.aws.amazon.com/cli/latest/reference/budgets/create-budget.html ; https://docs.aws.amazon.com/cli/latest/reference/budgets/list-tags-for-resource.html . Live resource tags supplement the local original-record check; they are not an IAM boundary or proof against an administrator deliberately impersonating an owner.
