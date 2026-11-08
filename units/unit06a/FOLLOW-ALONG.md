# Unit 6A r4 — follow along on YOUR computer


All sample outputs below are illustrative, not measurements of your AWS account. Default: offline calculations + optional authorized AWS reads. No cluster/VPC/NAT/node creation. Optional budget creation is separately gated.


Start with README.md, INSTALL.md and AUTH.md. Read each explanation before typing. Commands are complete, not shell prompts. Bash and PowerShell differ in variable assignment, local environment/removal, copying and Python launcher; AWS CLI argument syntax is otherwise the same. Do not paste both authentication paths.


## Shared terminal setup
An account is the billing/security boundary. A Region is an AWS geography. A local profile is a name for authentication configuration, not an AWS account or permission grant.

```bash
AwsProfile="REPLACE_WITH_YOUR_PROFILE"
Region="us-west-2"
ExpectedAccount="REPLACE_WITH_12_DIGITS"
export AWS_PAGER=""
export AWS_CLI_AUTO_PROMPT=off
aws configure list-profiles
aws configure list --profile "$AwsProfile"
```

```powershell
$AwsProfile = "REPLACE_WITH_YOUR_PROFILE"
$Region = "us-west-2"
$ExpectedAccount = "REPLACE_WITH_12_DIGITS"
$env:AWS_PAGER = ""
$env:AWS_CLI_AUTO_PROMPT = "off"
aws configure list-profiles
aws configure list --profile "$AwsProfile"
```


## Terraform before first use
Terraform reads all .tf files in one directory. A variable is an input; locals are calculations; outputs expose results; a data block reads existing AWS information; a resource block would own a lifecycle. There are NO resource blocks here. A provider is the API plugin, not an AWS account. State stores results and ownership; even data-only state can contain private account metadata. plan in the read-only project authenticates and reads AWS; optional apply writes LOCAL state/outputs and creates NO AWS resources. output requires saved state. Projects have separate state. Never copy state or credentials to GitHub.


## Lecture-by-lecture assignments


### s0000 · Welcome


#### Your computer, your account, no creation yet (`orientation`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Open Terminal on macOS/Linux and choose Bash; open PowerShell on Windows. These are commands for YOUR computer, not an EC2 shell, a Kubernetes Pod or the AWS console search bar. Extract the practice ZIP to a private folder first.

**Bash (macOS/Linux):**
```bash
pwd
ls
aws --version
```

**PowerShell (Windows):**
```powershell
Get-Location
Get-ChildItem
aws --version
```

**Flags / values:** pwd/Get-Location show your current local folder; ls/Get-ChildItem list its files. No AWS account request is made by --version.

**Illustrative output, never current-account evidence:**
```text
EXAMPLE: .../unit06a ; commands, scripts, terraform ; aws-cli/2.39.6
```

**Verify before continuing:** Your folder contains README.md, FOLLOW-ALONG.md, commands/, scripts/ and terraform/. Do not copy a leading dollar or prompt symbol.

**Likely errors / safe response:** Command not found: install the tool using INSTALL.md, close and reopen the terminal so PATH refreshes.

**Matching Terraform / intentional CLI-only boundary:** Terraform introduction and two complete projects are provided; CLI and Terraform read the same facts without taking ownership of infrastructure.

**Practice:** Identify your shell and current folder; open README.md in a text editor.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0001 · What you will be able to do after this unit


#### Set deliberate profile and Region (`settings`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. An account is the billing/security boundary. A Region is an AWS geography. A local profile is a name for authentication configuration, not an AWS account or permission grant.

**Bash (macOS/Linux):**
```bash
AwsProfile="REPLACE_WITH_YOUR_PROFILE"
Region="us-west-2"
ExpectedAccount="REPLACE_WITH_12_DIGITS"
export AWS_PAGER=""
export AWS_CLI_AUTO_PROMPT=off
aws configure list-profiles
aws configure list --profile "$AwsProfile"
```

**PowerShell (Windows):**
```powershell
$AwsProfile = "REPLACE_WITH_YOUR_PROFILE"
$Region = "us-west-2"
$ExpectedAccount = "REPLACE_WITH_12_DIGITS"
$env:AWS_PAGER = ""
$env:AWS_CLI_AUTO_PROMPT = "off"
aws configure list-profiles
aws configure list --profile "$AwsProfile"
```

**Flags / values:** Replace profile with an approved sandbox profile name, and ExpectedAccount with the approved 12-digit account ID obtained from your administrator/account menu, not simply whatever STS returns. us-west-2 is illustrative: choose your approved Region. Variables live only in this terminal. configure list shows masked credential values and where settings came from; do not share it publicly.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: profile eksclass-student (manual); region us-west-2 (config-file). No credentials are reproduced here.
```

**Verify before continuing:** Confirm the exact profile name in list-profiles; the explicit --region on later commands wins over environment/default profile Region.

**Likely errors / safe response:** Profile not found: create it using ONE authentication path. Never repair this by pasting permanent keys into course files.

**Matching Terraform / intentional CLI-only boundary:** read-only/variables.tf supplies aws_profile, aws_region, expected_account_id; allowed_account_ids rejects the wrong account.

**Practice:** Fill your profile, approved account and Region in a private worksheet. Do not publish that worksheet.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Read tool versions, not cluster state (`tools`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. CLI >=2.32.0 is required for aws login. Tested Terraform binary is 1.13.5, pinned provider 6.21.0; not a claim of latest versions. Match kubectl within one minor of the cluster version when you actually build in Unit 6B.

**Bash (macOS/Linux):**
```bash
aws --version
terraform version
python3 --version
kubectl version --client --output=yaml
```

**PowerShell (Windows):**
```powershell
aws --version
terraform version
py -3 --version
kubectl version --client --output=yaml
```

**Flags / values:** All four version checks are local. --client avoids contacting a Kubernetes API. Python 3 uses standard library only for these exercises; Windows uses py -3 (or python if that is your confirmed Python 3 launcher). jq is not required by the r4 commands.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: aws-cli/2.39.6; Terraform v1.13.5; Python 3.x; kubectl client v1.xx.x. These are examples, not your machine state.
```

**Verify before continuing:** Use INSTALL.md for OS-specific commands. Do not run kubectl get nodes against a random existing context to test installation.

**Likely errors / safe response:** Command not found: reopen terminal after install/PATH change. Windows Store Python alias is not proof Python is installed. AWS CLI v1 lacks newer APIs.

**Matching Terraform / intentional CLI-only boundary:** Terraform is a local declarative configuration tool: .tf files describe reads/calculations or managed resources; its provider is an API plugin; state records observations/ownership. Our first project is offline, second data-only.

**Practice:** Read each local version and record it privately, then explain Terraform/provider/state in your own words.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0002 · Why plan before you create


#### Read identity and stop on the wrong account (`identity`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Account must equal your approved account. An assumed-role ARN describes the temporary session, not an IAM role ARN you may put into simulate-principal-policy. STS identity does not prove permission to read EC2/EKS or create anything.

**Bash (macOS/Linux):**
```bash
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
ActualAccount=$(aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --query Account --output text --no-cli-pager) || exit 1
if [ "$ActualAccount" != "$ExpectedAccount" ]; then printf '%s
' 'STOP: wrong account'; exit 1; fi
```

**PowerShell (Windows):**
```powershell
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
$ActualAccount = aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --query Account --output text --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw "Identity request failed" }
if ($ActualAccount -ne $ExpectedAccount) { throw "STOP: wrong account" }
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --query Account extracts only the account field using JMESPath. Bash $? and PowerShell $LASTEXITCODE are native-process exit codes; PowerShell does not throw automatically on every aws failure.

**Illustrative output, never current-account evidence:**
```text
{"UserId":"EXAMPLE","Account":"111122223333","Arn":"arn:aws:sts::111122223333:assumed-role/LabRole/ExampleSession"} (ILLUSTRATIVE ONLY)
```

**Verify before continuing:** Compare Account manually AND execute the guard. STOP on an ARN ending :root: use an approved temporary non-root principal for daily work.

**Likely errors / safe response:** ExpiredToken/SSO token expired: sign in again to the intended profile. AccessDenied for another API is not fixed by STS succeeding.

**Matching Terraform / intentional CLI-only boundary:** data.aws_caller_identity.current and provider allowed_account_ids; no IAM policy is changed.

**Practice:** Compare Account and ARN; explain why identity success is not authorization for EKS.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Inventory potential costs without a cost-estimate promise (`cost`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. EKS control plane, nodes, NAT hours/data, public IPv4, load balancers, disks and logs can accrue charges. Stopping a terminal/Pod or logging out does not delete them. No inventory here proves a complete account-wide bill or current prices. Check the official pricing URLs and Billing before Unit 6B.

**Bash (macOS/Linux):**
```bash
aws eks list-clusters --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws ec2 describe-nat-gateways --profile "$AwsProfile" --region "$Region" --query 'NatGateways[].{ID:NatGatewayId,State:State,Subnet:SubnetId}' --output table --no-cli-pager
aws ec2 describe-addresses --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws ec2 describe-volumes --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws eks list-clusters --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws ec2 describe-nat-gateways --profile "$AwsProfile" --region "$Region" --query 'NatGateways[].{ID:NatGatewayId,State:State,Subnet:SubnetId}' --output table --no-cli-pager
aws ec2 describe-addresses --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws ec2 describe-volumes --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. list-clusters lists names in one Region, not a bill. describe-addresses lists Elastic IPs, not every chargeable public IPv4. describe-volumes shows EBS volumes, including unattached ones.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE EMPTY SANDBOX: {"clusters":[]}, {"Addresses":[]}, {"Volumes":[]}. Empty is not claimed for your account.
```

**Verify before continuing:** Confirm Region and ownership tags before interpreting inventory; never delete resources simply because they appear. Check other Regions/services and Billing with your admin.

**Likely errors / safe response:** Billing permissions and payer/account scope differ. AccessDenied to billing is not proof no costs exist.

**Matching Terraform / intentional CLI-only boundary:** This r4 Terraform creates no AWS infrastructure and is not a price engine. Budget is CLI-only optional to keep Terraform ownership separate.

**Practice:** List potential Unit 6B charge categories and name which continue after logout.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0003 · Account, Region and Availability Zones


#### Read account-visible Availability Zones (`az`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Two different zone names/IDs in your account are needed for the planned design. AZ name-to-physical-zone mapping can differ by account; AZ IDs identify the physical zone consistently. available is a zone state, not proof of spare capacity for your chosen instance type.

**Bash (macOS/Linux):**
```bash
aws ec2 describe-availability-zones --profile "$AwsProfile" --region "$Region" --filters Name=zone-type,Values=availability-zone --query 'AvailabilityZones[].{Name:ZoneName,ID:ZoneId,State:State,OptIn:OptInStatus}' --output table --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws ec2 describe-availability-zones --profile "$AwsProfile" --region "$Region" --filters Name=zone-type,Values=availability-zone --query 'AvailabilityZones[].{Name:ZoneName,ID:ZoneId,State:State,OptIn:OptInStatus}' --output table --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --filters uses EC2 server-side Name/Values syntax; zone-type excludes Local/Wavelength Zones for this exercise. --query maps returned fields into readable columns.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: us-west-2a | usw2-az2 | available | opt-in-not-required. Your mapping may differ.
```

**Verify before continuing:** Confirm at least two normal available AZs. Record name and ID pairs, not just a and b suffixes.

**Likely errors / safe response:** UnauthorizedOperation: ask for ec2:DescribeAvailabilityZones. Invalid endpoint: check your approved Region and connectivity.

**Matching Terraform / intentional CLI-only boundary:** data.aws_availability_zones.available, names and zone_ids; do not invent a physical-zone mapping.

**Practice:** Write two actual AZ name/ID pairs from your account; label any example pair as illustrative.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0004 · Offered is not the same as available


#### Read offered types and ENI limits (`offerings`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. An offered type is sold in a zone; the readout does not guarantee On-Demand/Spot capacity, quota, architecture suitability or a successful launch. No instances are launched here. Prefix delegation/custom networking use different calculations.

**Bash (macOS/Linux):**
```bash
InstanceType="m6i.large"
aws ec2 describe-instance-type-offerings --profile "$AwsProfile" --region "$Region" --location-type availability-zone --filters "Name=instance-type,Values=$InstanceType" --output table --no-cli-pager
aws ec2 describe-instance-types --profile "$AwsProfile" --region "$Region" --instance-types "$InstanceType" --query 'InstanceTypes[].{Type:InstanceType,ENIs:NetworkInfo.MaximumNetworkInterfaces,IPv4PerENI:NetworkInfo.Ipv4AddressesPerInterface}' --output table --no-cli-pager
```

**PowerShell (Windows):**
```powershell
$InstanceType = "m6i.large"
aws ec2 describe-instance-type-offerings --profile "$AwsProfile" --region "$Region" --location-type availability-zone --filters "Name=instance-type,Values=$InstanceType" --output table --no-cli-pager
aws ec2 describe-instance-types --profile "$AwsProfile" --region "$Region" --instance-types "$InstanceType" --query 'InstanceTypes[].{Type:InstanceType,ENIs:NetworkInfo.MaximumNetworkInterfaces,IPv4PerENI:NetworkInfo.Ipv4AddressesPerInterface}' --output table --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --location-type availability-zone returns offers by AZ name; --instance-types selects a specific instance family/size. MaximumNetworkInterfaces is not the number of ENIs currently attached to a node.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE m6i.large: ENIs=3, IPv4PerENI=10. Classic secondary-IP formula gives 3*(10-1)+2=29 maxPods before applicable bootstrap caps/settings.
```

**Verify before continuing:** Compare offering Locations with your two chosen AZs; compare limits with the worksheet, and do not apply the classic formula to prefix mode.

**Likely errors / safe response:** Empty offering list: pick another approved type/Region with the administrator, not an unapproved larger expensive type. Unknown instance: check spelling and Region.

**Matching Terraform / intentional CLI-only boundary:** data.aws_ec2_instance_type and aws_ec2_instance_type_offerings; exact supported maximum_network_interfaces/maximum_ipv4_addresses_per_interface attributes.

**Practice:** Calculate classic maxPods from your actual type limits; explain why IP capacity still does not prove node scheduling capacity.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0005 · Who are you, to AWS?


#### Read identity and stop on the wrong account (`identity`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Account must equal your approved account. An assumed-role ARN describes the temporary session, not an IAM role ARN you may put into simulate-principal-policy. STS identity does not prove permission to read EC2/EKS or create anything.

**Bash (macOS/Linux):**
```bash
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
ActualAccount=$(aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --query Account --output text --no-cli-pager) || exit 1
if [ "$ActualAccount" != "$ExpectedAccount" ]; then printf '%s
' 'STOP: wrong account'; exit 1; fi
```

**PowerShell (Windows):**
```powershell
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
$ActualAccount = aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --query Account --output text --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw "Identity request failed" }
if ($ActualAccount -ne $ExpectedAccount) { throw "STOP: wrong account" }
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --query Account extracts only the account field using JMESPath. Bash $? and PowerShell $LASTEXITCODE are native-process exit codes; PowerShell does not throw automatically on every aws failure.

**Illustrative output, never current-account evidence:**
```text
{"UserId":"EXAMPLE","Account":"111122223333","Arn":"arn:aws:sts::111122223333:assumed-role/LabRole/ExampleSession"} (ILLUSTRATIVE ONLY)
```

**Verify before continuing:** Compare Account manually AND execute the guard. STOP on an ARN ending :root: use an approved temporary non-root principal for daily work.

**Likely errors / safe response:** ExpiredToken/SSO token expired: sign in again to the intended profile. AccessDenied for another API is not fixed by STS succeeding.

**Matching Terraform / intentional CLI-only boundary:** data.aws_caller_identity.current and provider allowed_account_ids; no IAM policy is changed.

**Practice:** Compare Account and ARN; explain why identity success is not authorization for EKS.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0006 · Temporary credentials, not permanent keys


#### Choose one temporary sign-in path (`auth`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Ask your administrator for a sandbox account, approved role, MFA, and permissions before signing in. aws login requires CLI >=2.32.0 and SignInLocalDevelopmentAccess for IAM users/roles/groups. IAM Identity Center uses its own configure sso/login path. Even though aws login supports root, root is not a daily-work recommendation.

**Bash (macOS/Linux):**
```bash
# PATH A: CLI 2.32.0+; approved non-root principal with SignInLocalDevelopmentAccess
aws login --profile "$AwsProfile" --region "$Region"
# PATH B instead: IAM Identity Center; use your organization-provided values interactively
aws configure sso --profile "$AwsProfile"
aws sso login --profile "$AwsProfile"
```

**PowerShell (Windows):**
```powershell
# PATH A: CLI 2.32.0+; approved non-root principal with SignInLocalDevelopmentAccess
aws login --profile "$AwsProfile" --region "$Region"
# PATH B instead: IAM Identity Center; use your organization-provided values interactively
aws configure sso --profile "$AwsProfile"
aws sso login --profile "$AwsProfile"
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. aws configure sso writes local profile configuration and asks for your organization SSO session/start URL/SSO Region/account/role. aws login and sso login open your browser. Use ONE path, not both sequentially. Do not type passwords into lesson files.

**Illustrative output, never current-account evidence:**
```text
EXAMPLE: browser sign-in completed, then sts get-caller-identity returns the intended account. No real login result is claimed.
```

**Verify before continuing:** Run the identity command after sign-in. Have the administrator verify required sign-in policy if aws login is denied; do not attach AdministratorAccess to yourself.

**Likely errors / safe response:** Unknown command login: update CLI v2. Browser unavailable: use documented aws login --remote only on an approved device; never post the authorization code. SSO needs the organization-provided configuration, not guessed values.

**Matching Terraform / intentional CLI-only boundary:** The provider reads the same named profile. If the pinned provider SDK does not support login_session, use the documented credential_process bridge in AUTH.md; never export secrets into .tfvars.

**Practice:** Choose A or B with your administrator. Record only the profile name and authentication method.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0007 · Which credentials win


#### Inspect credential sources without revealing keys (`precedence`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. CLI and provider chains consider explicit configuration, environment and supported profile providers. Profile selection is not a promise that every inherited environment variable is ignored by every SDK. Never print env/printenv wholesale or aws configure export-credentials to the screen.

**Bash (macOS/Linux):**
```bash
python3 -c 'import os; print("\n".join(sorted(k for k in os.environ if k.startswith("AWS_"))))' || exit 1
aws configure list --profile "$AwsProfile"
# Only if stale manual environment keys are unintended in this shell:
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
Get-ChildItem Env:AWS_* | Select-Object -ExpandProperty Name
aws configure list --profile "$AwsProfile"
# Only if stale manual environment keys are unintended in this shell:
Remove-Item Env:AWS_ACCESS_KEY_ID,Env:AWS_SECRET_ACCESS_KEY,Env:AWS_SESSION_TOKEN,Env:AWS_SECURITY_TOKEN -ErrorAction SilentlyContinue
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
```

**Flags / values:** List environment variable NAMES only. unset/Remove-Item affect this terminal process, not stored profiles. Do not remove deliberate role/container/credential_process settings blindly. AWS_REGION outranks AWS_DEFAULT_REGION/profile Region; --region wins over both. A named --profile changes provider resolution behavior, so inspect configure list and verify STS rather than assuming a simplistic universal precedence diagram.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE NAMES ONLY: AWS_DEFAULT_REGION, AWS_PROFILE. No secret values.
```

**Verify before continuing:** Re-run configure list and STS after clearing ONLY unintended manual key variables. SDK/provider support and AWS CLI provider resolution are not identical.

**Likely errors / safe response:** Wrong account remains: confirm profile role/source_profile/SSO configuration with administrator; do not read cache/token files for troubleshooting.

**Matching Terraform / intentional CLI-only boundary:** Provider profile + allowed_account_ids give explicit selection and rejection, not a guarantee of permissions. Credentials never belong in Terraform files.

**Practice:** List names only and explain how you would detect a stale credential source without revealing it.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0008 · Settings that make scripts predictable


#### Set deliberate profile and Region (`settings`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. An account is the billing/security boundary. A Region is an AWS geography. A local profile is a name for authentication configuration, not an AWS account or permission grant.

**Bash (macOS/Linux):**
```bash
AwsProfile="REPLACE_WITH_YOUR_PROFILE"
Region="us-west-2"
ExpectedAccount="REPLACE_WITH_12_DIGITS"
export AWS_PAGER=""
export AWS_CLI_AUTO_PROMPT=off
aws configure list-profiles
aws configure list --profile "$AwsProfile"
```

**PowerShell (Windows):**
```powershell
$AwsProfile = "REPLACE_WITH_YOUR_PROFILE"
$Region = "us-west-2"
$ExpectedAccount = "REPLACE_WITH_12_DIGITS"
$env:AWS_PAGER = ""
$env:AWS_CLI_AUTO_PROMPT = "off"
aws configure list-profiles
aws configure list --profile "$AwsProfile"
```

**Flags / values:** Replace profile with an approved sandbox profile name, and ExpectedAccount with the approved 12-digit account ID obtained from your administrator/account menu, not simply whatever STS returns. us-west-2 is illustrative: choose your approved Region. Variables live only in this terminal. configure list shows masked credential values and where settings came from; do not share it publicly.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: profile eksclass-student (manual); region us-west-2 (config-file). No credentials are reproduced here.
```

**Verify before continuing:** Confirm the exact profile name in list-profiles; the explicit --region on later commands wins over environment/default profile Region.

**Likely errors / safe response:** Profile not found: create it using ONE authentication path. Never repair this by pasting permanent keys into course files.

**Matching Terraform / intentional CLI-only boundary:** read-only/variables.tf supplies aws_profile, aws_region, expected_account_id; allowed_account_ids rejects the wrong account.

**Practice:** Fill your profile, approved account and Region in a private worksheet. Do not publish that worksheet.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0009 · Permissions: exactly what each step needs


#### Verify read permissions without pretending to prove deployment rights (`permissions`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Read-only API success tests that exact read action only. Simulation has limitations: session policies, SCPs, resource policies, permission boundaries and missing condition context can alter real results. SCPs restrict member accounts including their root user; not management-account principals; service-linked roles are exempt. AdministratorAccess is not a bypass for member-account SCP restrictions.

**Bash (macOS/Linux):**
```bash
aws ec2 describe-availability-zones --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws eks describe-cluster-versions --profile "$AwsProfile" --region "$Region" --version-status STANDARD_SUPPORT --output json --no-cli-pager
# OPTIONAL administrator-assisted IAM policy simulation: replace with IAM role ARN, NOT STS session ARN
PolicySourceArn="REPLACE_WITH_IAM_ROLE_ARN"
aws iam simulate-principal-policy --profile "$AwsProfile" --region "$Region" --policy-source-arn "$PolicySourceArn" --action-names ec2:DescribeSubnets eks:DescribeClusterVersions --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws ec2 describe-availability-zones --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws eks describe-cluster-versions --profile "$AwsProfile" --region "$Region" --version-status STANDARD_SUPPORT --output json --no-cli-pager
# OPTIONAL administrator-assisted simulation; use the IAM role ARN, NOT an STS session ARN
$PolicySourceArn = "REPLACE_WITH_IAM_ROLE_ARN"
aws iam simulate-principal-policy --profile "$AwsProfile" --region "$Region" --policy-source-arn "$PolicySourceArn" --action-names ec2:DescribeSubnets eks:DescribeClusterVersions --output json --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --policy-source-arn selects an existing IAM role/user whose policies an authorized administrator can simulate; --action-names lists the API permissions being evaluated. iam:SimulatePrincipalPolicy is a separate permission and is optional here.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE simulation: EvalActionName=ec2:DescribeSubnets, EvalDecision=allowed. This is not a live deployment authorization certificate.
```

**Verify before continuing:** Keep an action-by-action permission ledger in PERMISSIONS.md. Unit 6B separately checks create/trust/PassRole permissions; this unit does not test by creating anything.

**Likely errors / safe response:** AccessDenied/UnauthorizedOperation: preserve action name/request ID privately and ask admin to inspect identity/boundary/session/SCP context. Do not switch to root or weaken policies.

**Matching Terraform / intentional CLI-only boundary:** No built-in Terraform evaluator proves effective IAM permissions. Data lookups test their API calls only; IAM simulation remains an optional CLI diagnostic.

**Practice:** Mark each read action pass/denied/not attempted. Explain why an allowed simulation can still fail in reality.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0010 · Keeping secrets out of files


#### Inspect credential sources without revealing keys (`precedence`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. CLI and provider chains consider explicit configuration, environment and supported profile providers. Profile selection is not a promise that every inherited environment variable is ignored by every SDK. Never print env/printenv wholesale or aws configure export-credentials to the screen.

**Bash (macOS/Linux):**
```bash
python3 -c 'import os; print("\n".join(sorted(k for k in os.environ if k.startswith("AWS_"))))' || exit 1
aws configure list --profile "$AwsProfile"
# Only if stale manual environment keys are unintended in this shell:
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
Get-ChildItem Env:AWS_* | Select-Object -ExpandProperty Name
aws configure list --profile "$AwsProfile"
# Only if stale manual environment keys are unintended in this shell:
Remove-Item Env:AWS_ACCESS_KEY_ID,Env:AWS_SECRET_ACCESS_KEY,Env:AWS_SESSION_TOKEN,Env:AWS_SECURITY_TOKEN -ErrorAction SilentlyContinue
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
```

**Flags / values:** List environment variable NAMES only. unset/Remove-Item affect this terminal process, not stored profiles. Do not remove deliberate role/container/credential_process settings blindly. AWS_REGION outranks AWS_DEFAULT_REGION/profile Region; --region wins over both. A named --profile changes provider resolution behavior, so inspect configure list and verify STS rather than assuming a simplistic universal precedence diagram.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE NAMES ONLY: AWS_DEFAULT_REGION, AWS_PROFILE. No secret values.
```

**Verify before continuing:** Re-run configure list and STS after clearing ONLY unintended manual key variables. SDK/provider support and AWS CLI provider resolution are not identical.

**Likely errors / safe response:** Wrong account remains: confirm profile role/source_profile/SSO configuration with administrator; do not read cache/token files for troubleshooting.

**Matching Terraform / intentional CLI-only boundary:** Provider profile + allowed_account_ids give explicit selection and rejection, not a guarantee of permissions. Credentials never belong in Terraform files.

**Practice:** List names only and explain how you would detect a stale credential source without revealing it.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0011 · Knowledge check


#### Read identity and stop on the wrong account (`identity`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Account must equal your approved account. An assumed-role ARN describes the temporary session, not an IAM role ARN you may put into simulate-principal-policy. STS identity does not prove permission to read EC2/EKS or create anything.

**Bash (macOS/Linux):**
```bash
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
ActualAccount=$(aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --query Account --output text --no-cli-pager) || exit 1
if [ "$ActualAccount" != "$ExpectedAccount" ]; then printf '%s
' 'STOP: wrong account'; exit 1; fi
```

**PowerShell (Windows):**
```powershell
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
$ActualAccount = aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --query Account --output text --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw "Identity request failed" }
if ($ActualAccount -ne $ExpectedAccount) { throw "STOP: wrong account" }
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --query Account extracts only the account field using JMESPath. Bash $? and PowerShell $LASTEXITCODE are native-process exit codes; PowerShell does not throw automatically on every aws failure.

**Illustrative output, never current-account evidence:**
```text
{"UserId":"EXAMPLE","Account":"111122223333","Arn":"arn:aws:sts::111122223333:assumed-role/LabRole/ExampleSession"} (ILLUSTRATIVE ONLY)
```

**Verify before continuing:** Compare Account manually AND execute the guard. STOP on an ARN ending :root: use an approved temporary non-root principal for daily work.

**Likely errors / safe response:** ExpiredToken/SSO token expired: sign in again to the intended profile. AccessDenied for another API is not fixed by STS succeeding.

**Matching Terraform / intentional CLI-only boundary:** data.aws_caller_identity.current and provider allowed_account_ids; no IAM policy is changed.

**Practice:** Compare Account and ARN; explain why identity success is not authorization for EKS.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0012 · Answer: stop, and find out who you are


#### Read identity and stop on the wrong account (`identity`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Account must equal your approved account. An assumed-role ARN describes the temporary session, not an IAM role ARN you may put into simulate-principal-policy. STS identity does not prove permission to read EC2/EKS or create anything.

**Bash (macOS/Linux):**
```bash
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
ActualAccount=$(aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --query Account --output text --no-cli-pager) || exit 1
if [ "$ActualAccount" != "$ExpectedAccount" ]; then printf '%s
' 'STOP: wrong account'; exit 1; fi
```

**PowerShell (Windows):**
```powershell
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
$ActualAccount = aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --query Account --output text --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw "Identity request failed" }
if ($ActualAccount -ne $ExpectedAccount) { throw "STOP: wrong account" }
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --query Account extracts only the account field using JMESPath. Bash $? and PowerShell $LASTEXITCODE are native-process exit codes; PowerShell does not throw automatically on every aws failure.

**Illustrative output, never current-account evidence:**
```text
{"UserId":"EXAMPLE","Account":"111122223333","Arn":"arn:aws:sts::111122223333:assumed-role/LabRole/ExampleSession"} (ILLUSTRATIVE ONLY)
```

**Verify before continuing:** Compare Account manually AND execute the guard. STOP on an ARN ending :root: use an approved temporary non-root principal for daily work.

**Likely errors / safe response:** ExpiredToken/SSO token expired: sign in again to the intended profile. AccessDenied for another API is not fixed by STS succeeding.

**Matching Terraform / intentional CLI-only boundary:** data.aws_caller_identity.current and provider allowed_account_ids; no IAM policy is changed.

**Practice:** Compare Account and ARN; explain why identity success is not authorization for EKS.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0013 · Your toolchain


#### Read tool versions, not cluster state (`tools`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. CLI >=2.32.0 is required for aws login. Tested Terraform binary is 1.13.5, pinned provider 6.21.0; not a claim of latest versions. Match kubectl within one minor of the cluster version when you actually build in Unit 6B.

**Bash (macOS/Linux):**
```bash
aws --version
terraform version
python3 --version
kubectl version --client --output=yaml
```

**PowerShell (Windows):**
```powershell
aws --version
terraform version
py -3 --version
kubectl version --client --output=yaml
```

**Flags / values:** All four version checks are local. --client avoids contacting a Kubernetes API. Python 3 uses standard library only for these exercises; Windows uses py -3 (or python if that is your confirmed Python 3 launcher). jq is not required by the r4 commands.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: aws-cli/2.39.6; Terraform v1.13.5; Python 3.x; kubectl client v1.xx.x. These are examples, not your machine state.
```

**Verify before continuing:** Use INSTALL.md for OS-specific commands. Do not run kubectl get nodes against a random existing context to test installation.

**Likely errors / safe response:** Command not found: reopen terminal after install/PATH change. Windows Store Python alias is not proof Python is installed. AWS CLI v1 lacks newer APIs.

**Matching Terraform / intentional CLI-only boundary:** Terraform is a local declarative configuration tool: .tf files describe reads/calculations or managed resources; its provider is an API plugin; state records observations/ownership. Our first project is offline, second data-only.

**Practice:** Read each local version and record it privately, then explain Terraform/provider/state in your own words.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Run complete offline Terraform project (`tf-offline`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Read Terraform before using it: variables are typed inputs; locals are named calculations; outputs are values to display; .tfvars supplies non-secret inputs; a provider is an API plugin. This project needs no provider or credentials. All .tf files in the directory combine into one configuration. The complete files are below, not omitted fragments.

**Bash (macOS/Linux):**
```bash
terraform -chdir=terraform/offline init -backend=false -input=false
terraform -chdir=terraform/offline fmt -check
terraform -chdir=terraform/offline validate
terraform -chdir=terraform/offline plan -input=false -out=offline.tfplan
# Optional LOCAL state/output write, no AWS calls or AWS resources:
terraform -chdir=terraform/offline apply -input=false offline.tfplan
terraform -chdir=terraform/offline output -json
```

**PowerShell (Windows):**
```powershell
terraform -chdir=terraform/offline init -backend=false -input=false
terraform -chdir=terraform/offline fmt -check
terraform -chdir=terraform/offline validate
terraform -chdir=terraform/offline plan -input=false -out=offline.tfplan
# Optional LOCAL state/output write, no AWS calls or AWS resources:
terraform -chdir=terraform/offline apply -input=false offline.tfplan
terraform -chdir=terraform/offline output -json
```

**Flags / values:** -backend=false skips backend initialization; no backend block exists, so state is local. init prepares the folder; fmt checks formatting; validate checks configuration syntax/types, NOT account correctness; plan previews changes and -out saves a LOCAL plan in the selected project. Applying that reviewed plan writes local state/outputs only. output reads saved state; it is empty until apply.

**Illustrative output, never current-account evidence:**
```text
OFFLINE expected: Changes to Outputs; 4091 usable, 143 planned, 3948 remaining, classic maxPods 29. No resource create/update/delete actions.
```

**Verify before continuing:** Inspect plan: only output changes, no resource actions. If you see a resource, stop: wrong folder or modified files. Optional apply is only to persist outputs. You may skip it and inspect the plan instead.

**Likely errors / safe response:** No configuration files: wrong -chdir/current folder. No outputs: state has not been written yet. Validation success does not prove nonoverlap/production capacity.

**Matching Terraform / intentional CLI-only boundary:** All files in terraform/offline/ are complete; terraform.tfvars.example is optional because defaults are safe illustrations. Never put account secrets in variables.

**Practice:** Explain each command then compare saved output to the Python calculator; no need for authenticated AWS access.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0014 · Choosing the Kubernetes version on build day


#### Read EKS support and add-on compatibility (`versions`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Choose a version on build day, check support end and add-ons. No EKS version is hard-coded as currently available in r4. Existing cluster/add-on readout is separate and optional: no cluster is required to list supported versions.

**Bash (macOS/Linux):**
```bash
aws eks describe-cluster-versions --profile "$AwsProfile" --region "$Region" --version-status STANDARD_SUPPORT --query 'clusterVersions[].{Version:clusterVersion,Status:versionStatus,EndStandard:endOfStandardSupportDate}' --output table --no-cli-pager
K8sVersion="REPLACE_FROM_VERSION_READOUT"
aws eks describe-addon-versions --profile "$AwsProfile" --region "$Region" --kubernetes-version "$K8sVersion" --addon-name vpc-cni --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws eks describe-cluster-versions --profile "$AwsProfile" --region "$Region" --version-status STANDARD_SUPPORT --query 'clusterVersions[].{Version:clusterVersion,Status:versionStatus,EndStandard:endOfStandardSupportDate}' --output table --no-cli-pager
$K8sVersion = "REPLACE_FROM_VERSION_READOUT"
aws eks describe-addon-versions --profile "$AwsProfile" --region "$Region" --kubernetes-version "$K8sVersion" --addon-name vpc-cni --output json --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --version-status STANDARD_SUPPORT filters supported standard versions using the current non-deprecated field. --kubernetes-version is a version you choose after reading the first output; --addon-name selects vpc-cni. Inspect compatibilities/defaultVersion/architecture rather than sorting add-on version strings lexically.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE SHAPE: {"clusterVersions":[{"clusterVersion":"1.xx","versionStatus":"STANDARD_SUPPORT","endOfStandardSupportDate":"EXAMPLE_DATE"}]}; version/date are not real choices.
```

**Verify before continuing:** Record chosen supported version and VPC CNI compatible version privately; repeat describe-addon-versions for coredns and kube-proxy by replacing only addon-name.

**Likely errors / safe response:** Unknown operation/option: update AWS CLI v2. Empty compatibility list: do not guess a version; inspect Region/version/add-on and ask admin.

**Matching Terraform / intentional CLI-only boundary:** Verified pinned provider supports data.aws_eks_cluster_versions.standard with version_status STANDARD_SUPPORT and full lifecycle fields. Optional data.aws_eks_addon_version.vpc_cni reads one latest compatible version only when kubernetes_version is supplied; CLI still exposes full compatibility/architecture detail.

**Practice:** Read the support dates and compatible add-on architectures. Do not create a cluster just to discover versions.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0015 · What costs money in Unit 6B


#### Inventory potential costs without a cost-estimate promise (`cost`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. EKS control plane, nodes, NAT hours/data, public IPv4, load balancers, disks and logs can accrue charges. Stopping a terminal/Pod or logging out does not delete them. No inventory here proves a complete account-wide bill or current prices. Check the official pricing URLs and Billing before Unit 6B.

**Bash (macOS/Linux):**
```bash
aws eks list-clusters --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws ec2 describe-nat-gateways --profile "$AwsProfile" --region "$Region" --query 'NatGateways[].{ID:NatGatewayId,State:State,Subnet:SubnetId}' --output table --no-cli-pager
aws ec2 describe-addresses --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws ec2 describe-volumes --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws eks list-clusters --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws ec2 describe-nat-gateways --profile "$AwsProfile" --region "$Region" --query 'NatGateways[].{ID:NatGatewayId,State:State,Subnet:SubnetId}' --output table --no-cli-pager
aws ec2 describe-addresses --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws ec2 describe-volumes --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. list-clusters lists names in one Region, not a bill. describe-addresses lists Elastic IPs, not every chargeable public IPv4. describe-volumes shows EBS volumes, including unattached ones.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE EMPTY SANDBOX: {"clusters":[]}, {"Addresses":[]}, {"Volumes":[]}. Empty is not claimed for your account.
```

**Verify before continuing:** Confirm Region and ownership tags before interpreting inventory; never delete resources simply because they appear. Check other Regions/services and Billing with your admin.

**Likely errors / safe response:** Billing permissions and payer/account scope differ. AccessDenied to billing is not proof no costs exist.

**Matching Terraform / intentional CLI-only boundary:** This r4 Terraform creates no AWS infrastructure and is not a price engine. Budget is CLI-only optional to keep Terraform ownership separate.

**Practice:** List potential Unit 6B charge categories and name which continue after logout.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0016 · What does not stop the bill


#### Inventory potential costs without a cost-estimate promise (`cost`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. EKS control plane, nodes, NAT hours/data, public IPv4, load balancers, disks and logs can accrue charges. Stopping a terminal/Pod or logging out does not delete them. No inventory here proves a complete account-wide bill or current prices. Check the official pricing URLs and Billing before Unit 6B.

**Bash (macOS/Linux):**
```bash
aws eks list-clusters --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws ec2 describe-nat-gateways --profile "$AwsProfile" --region "$Region" --query 'NatGateways[].{ID:NatGatewayId,State:State,Subnet:SubnetId}' --output table --no-cli-pager
aws ec2 describe-addresses --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws ec2 describe-volumes --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws eks list-clusters --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws ec2 describe-nat-gateways --profile "$AwsProfile" --region "$Region" --query 'NatGateways[].{ID:NatGatewayId,State:State,Subnet:SubnetId}' --output table --no-cli-pager
aws ec2 describe-addresses --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws ec2 describe-volumes --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. list-clusters lists names in one Region, not a bill. describe-addresses lists Elastic IPs, not every chargeable public IPv4. describe-volumes shows EBS volumes, including unattached ones.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE EMPTY SANDBOX: {"clusters":[]}, {"Addresses":[]}, {"Volumes":[]}. Empty is not claimed for your account.
```

**Verify before continuing:** Confirm Region and ownership tags before interpreting inventory; never delete resources simply because they appear. Check other Regions/services and Billing with your admin.

**Likely errors / safe response:** Billing permissions and payer/account scope differ. AccessDenied to billing is not proof no costs exist.

**Matching Terraform / intentional CLI-only boundary:** This r4 Terraform creates no AWS infrastructure and is not a price engine. Budget is CLI-only optional to keep Terraform ownership separate.

**Practice:** List potential Unit 6B charge categories and name which continue after logout.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0017 · A budget alert is not a spending limit


#### Read a budget and its alert subscribers (`budget`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Budgets data/alerts can be delayed; a notification-only budget does not delete anything and does not impose a spending limit. Optional creation is isolated in OPTIONAL-BUDGET.md and requires deliberate approval. The monitoring budget is different from action-enabled budgets, whose pricing must be checked.

**Bash (macOS/Linux):**
```bash
aws budgets describe-budgets --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --output json --no-cli-pager
BudgetName="unit06a-learning-alert"
aws budgets describe-notifications-for-budget --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --budget-name "$BudgetName" --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws budgets describe-budgets --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --output json --no-cli-pager
$BudgetName = "unit06a-learning-alert"
aws budgets describe-notifications-for-budget --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --budget-name "$BudgetName" --output json --no-cli-pager
```

**Flags / values:** AWS Budgets account ID is explicit; us-east-1 is the commercial-partition Budgets endpoint for these examples, not the deployment Region. Stop and use partition-specific documentation if using GovCloud/China. --budget-name must be an existing name you own or are authorized to inspect.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: BudgetLimit.Amount="10", Unit="USD"; notification threshold 80 percent ACTUAL. This is not a hard $10 cap.
```

**Verify before continuing:** Read the notifications and use describe-subscribers-for-notification as shown in OPTIONAL-BUDGET.md; verify delivery to your own address. Never publicly share subscriber output.

**Likely errors / safe response:** NotFoundException before optional creation is expected; no permission or email subscriber must be invented. AccessDenied: ask for budgets:ViewBudget.

**Matching Terraform / intentional CLI-only boundary:** CLI-only in this lesson; no aws_budgets_budget resource is included, preventing two owners. A future Terraform budget would require its own explicit ownership/state path.

**Practice:** Explain why receiving an alert at 80 percent does not stop spend at 100 percent.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0018 · COST_ACK, an end time and a cleanup plan


#### Rehearse account, cost and end-time guards (`guard`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. First predict the stop, then run it. Unit 6A never uses this guard to create anything. Unit 6B must use its own explicit reviewed owner/cleanup procedure immediately before billable operations.

**Bash (macOS/Linux):**
```bash
CostAck="NO"
EndTime="REPLACE_WITH_FUTURE_ISO8601_WITH_OFFSET"
python3 scripts/check_guard.py --expected-account "$ExpectedAccount" --actual-account "$ActualAccount" --cost-ack "$CostAck" --end-time "$EndTime"
```

**PowerShell (Windows):**
```powershell
$CostAck = "NO"
$EndTime = "REPLACE_WITH_FUTURE_ISO8601_WITH_OFFSET"
py -3 scripts/check_guard.py --expected-account "$ExpectedAccount" --actual-account "$ActualAccount" --cost-ack "$CostAck" --end-time "$EndTime"
if ($LASTEXITCODE -ne 0) { throw "STOP: local guard failed" }
```

**Flags / values:** The local script checks equality against your intended account, the exact acknowledgment I_ACCEPT_BILLABLE_RESOURCES_IN_UNIT6B, and an ISO8601 timestamp with offset within the next eight hours. It is not a scheduled cleanup service. Leave CostAck=NO in Unit 6A.

**Illustrative output, never current-account evidence:**
```text
EXPECTED REHEARSAL: STOP: cost not acknowledged. Example format only: 2026-11-08T16:00:00-08:00 (PST); choose a genuinely future timestamp when you run it.
```

**Verify before continuing:** Test with a deliberately different actual account and expired end time separately using synthetic local values. No AWS request is made by this script.

**Likely errors / safe response:** Invalid timestamp: include -08:00 or the applicable local offset, not an ambiguous abbreviation. End time beyond eight hours fails deliberately.

**Matching Terraform / intentional CLI-only boundary:** No Terraform cost-cap/end-time function exists here. Local guard is a CLI/Python rehearsal, not an AWS enforcement mechanism or Terraform lifecycle guarantee.

**Practice:** Trigger wrong-account, missing-cost-ack and expired-time stops with synthetic values; keep CostAck NO afterward.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0019 · Knowledge check


#### Read a budget and its alert subscribers (`budget`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Budgets data/alerts can be delayed; a notification-only budget does not delete anything and does not impose a spending limit. Optional creation is isolated in OPTIONAL-BUDGET.md and requires deliberate approval. The monitoring budget is different from action-enabled budgets, whose pricing must be checked.

**Bash (macOS/Linux):**
```bash
aws budgets describe-budgets --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --output json --no-cli-pager
BudgetName="unit06a-learning-alert"
aws budgets describe-notifications-for-budget --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --budget-name "$BudgetName" --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws budgets describe-budgets --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --output json --no-cli-pager
$BudgetName = "unit06a-learning-alert"
aws budgets describe-notifications-for-budget --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --budget-name "$BudgetName" --output json --no-cli-pager
```

**Flags / values:** AWS Budgets account ID is explicit; us-east-1 is the commercial-partition Budgets endpoint for these examples, not the deployment Region. Stop and use partition-specific documentation if using GovCloud/China. --budget-name must be an existing name you own or are authorized to inspect.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: BudgetLimit.Amount="10", Unit="USD"; notification threshold 80 percent ACTUAL. This is not a hard $10 cap.
```

**Verify before continuing:** Read the notifications and use describe-subscribers-for-notification as shown in OPTIONAL-BUDGET.md; verify delivery to your own address. Never publicly share subscriber output.

**Likely errors / safe response:** NotFoundException before optional creation is expected; no permission or email subscriber must be invented. AccessDenied: ask for budgets:ViewBudget.

**Matching Terraform / intentional CLI-only boundary:** CLI-only in this lesson; no aws_budgets_budget resource is included, preventing two owners. A future Terraform budget would require its own explicit ownership/state path.

**Practice:** Explain why receiving an alert at 80 percent does not stop spend at 100 percent.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0020 · Answer: the alert arrived, the bill kept growing


#### Read a budget and its alert subscribers (`budget`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Budgets data/alerts can be delayed; a notification-only budget does not delete anything and does not impose a spending limit. Optional creation is isolated in OPTIONAL-BUDGET.md and requires deliberate approval. The monitoring budget is different from action-enabled budgets, whose pricing must be checked.

**Bash (macOS/Linux):**
```bash
aws budgets describe-budgets --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --output json --no-cli-pager
BudgetName="unit06a-learning-alert"
aws budgets describe-notifications-for-budget --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --budget-name "$BudgetName" --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws budgets describe-budgets --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --output json --no-cli-pager
$BudgetName = "unit06a-learning-alert"
aws budgets describe-notifications-for-budget --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --budget-name "$BudgetName" --output json --no-cli-pager
```

**Flags / values:** AWS Budgets account ID is explicit; us-east-1 is the commercial-partition Budgets endpoint for these examples, not the deployment Region. Stop and use partition-specific documentation if using GovCloud/China. --budget-name must be an existing name you own or are authorized to inspect.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: BudgetLimit.Amount="10", Unit="USD"; notification threshold 80 percent ACTUAL. This is not a hard $10 cap.
```

**Verify before continuing:** Read the notifications and use describe-subscribers-for-notification as shown in OPTIONAL-BUDGET.md; verify delivery to your own address. Never publicly share subscriber output.

**Likely errors / safe response:** NotFoundException before optional creation is expected; no permission or email subscriber must be invented. AccessDenied: ask for budgets:ViewBudget.

**Matching Terraform / intentional CLI-only boundary:** CLI-only in this lesson; no aws_budgets_budget resource is included, preventing two owners. A future Terraform budget would require its own explicit ownership/state path.

**Practice:** Explain why receiving an alert at 80 percent does not stop spend at 100 percent.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0021 · One owner for every resource


#### Separate read-only observation from resource ownership (`ownership`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. One owner per resource: Unit 6B CLI creates its own named infrastructure; a future full Terraform build is an alternative owner in a separate namespace and state. These r4 Terraform projects only calculate/read and never adopt or delete Unit 6B resources.

**Bash (macOS/Linux):**
```bash
terraform -chdir=terraform/offline state list
terraform -chdir=terraform/read-only state list
```

**PowerShell (Windows):**
```powershell
terraform -chdir=terraform/offline state list
terraform -chdir=terraform/read-only state list
```

**Flags / values:** -chdir selects the exact local project folder before running the subcommand. state list reads existing local state only; before any apply, a no-state message is normal. It does not fetch the cloud inventory.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: offline has no managed resource entries; data-only state may contain data.aws_caller_identity.current after its optional apply.
```

**Verify before continuing:** Open the .tf files and verify no resource/module/import blocks. Separate offline/ and read-only/ directories mean separate state. Do not import Unit 6B CLI resources here.

**Likely errors / safe response:** No state file found is expected before apply. Never run terraform destroy as an unexplained cleanup shortcut or point these projects at another backend.

**Matching Terraform / intentional CLI-only boundary:** Data blocks observe; resource blocks would manage lifecycle. init does not create infrastructure; plan may call AWS APIs; data-only apply writes local state/outputs but creates no AWS resources.

**Practice:** Explain which tool owns each prospective Unit 6B resource and why this data-only project owns none.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Run data-only Terraform reads in your account (`tf-read`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Choose the CLI view or this declarative read view. They may both read safely because neither manages resources here. A future billable Terraform create path must be an ALTERNATIVE owner, never a second owner of the CLI infrastructure.

**Bash (macOS/Linux):**
```bash
cp terraform/read-only/terraform.tfvars.example terraform/read-only/terraform.tfvars
# EDIT that copy in your text editor: profile, Region and intended account ID
terraform -chdir=terraform/read-only init -backend=false -input=false
terraform -chdir=terraform/read-only fmt -check
terraform -chdir=terraform/read-only validate
terraform -chdir=terraform/read-only plan -input=false -out=observations.tfplan
# Optional: reviewed data-only plan writes LOCAL state; no AWS resources created
terraform -chdir=terraform/read-only apply -input=false observations.tfplan
terraform -chdir=terraform/read-only output -json
```

**PowerShell (Windows):**
```powershell
Copy-Item terraform/read-only/terraform.tfvars.example terraform/read-only/terraform.tfvars
# EDIT that copy in your text editor: profile, Region and intended account ID
terraform -chdir=terraform/read-only init -backend=false -input=false
terraform -chdir=terraform/read-only fmt -check
terraform -chdir=terraform/read-only validate
terraform -chdir=terraform/read-only plan -input=false -out=observations.tfplan
# Optional reviewed data-only plan writes LOCAL state; no AWS resources created
terraform -chdir=terraform/read-only apply -input=false observations.tfplan
terraform -chdir=terraform/read-only output -json
```

**Flags / values:** Unlike the offline project, plan and optional apply authenticate and issue AWS read API calls. init downloads hashicorp/aws 6.21.0 and writes .terraform.lock.hcl; that lock is safe to commit, not .terraform/ or state. Set allowed_account_ids through expected_account_id before plan. -backend=false is not a universal no-state/no-network mode.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE PLAN SHAPE: data.aws_caller_identity.current: Read complete; output identity.account_id matches YOUR expected account; availability_zones contains YOUR zone names/IDs. No real account plan was run by us.
```

**Verify before continuing:** Verify there are no resource/module/import blocks and no infrastructure actions in plan. Leave existing_subnet_ids=[] if none exists. Optional apply persists observations in local state; output reads it and may become stale until next reviewed refresh.

**Likely errors / safe response:** Unsupported login_session in provider: use AUTH.md credential_process bridge after aws login. Wrong account: provider rejects; fix selection, do not remove the guard. Missing profile placeholders fail before continuing.

**Matching Terraform / intentional CLI-only boundary:** Complete read-only provider/versions/variables/data/locals/output files included. CLI-only facts are explicitly mapped; no fake HCL effective-permissions, costs or free-IP attributes.

**Practice:** First finish the CLI identity/AZ/type reads, then compare only authorized data-only plan observations. Do not run authenticated plan on someone else's machine.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0022 · Guards that stop instead of guessing


#### Rehearse account, cost and end-time guards (`guard`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. First predict the stop, then run it. Unit 6A never uses this guard to create anything. Unit 6B must use its own explicit reviewed owner/cleanup procedure immediately before billable operations.

**Bash (macOS/Linux):**
```bash
CostAck="NO"
EndTime="REPLACE_WITH_FUTURE_ISO8601_WITH_OFFSET"
python3 scripts/check_guard.py --expected-account "$ExpectedAccount" --actual-account "$ActualAccount" --cost-ack "$CostAck" --end-time "$EndTime"
```

**PowerShell (Windows):**
```powershell
$CostAck = "NO"
$EndTime = "REPLACE_WITH_FUTURE_ISO8601_WITH_OFFSET"
py -3 scripts/check_guard.py --expected-account "$ExpectedAccount" --actual-account "$ActualAccount" --cost-ack "$CostAck" --end-time "$EndTime"
if ($LASTEXITCODE -ne 0) { throw "STOP: local guard failed" }
```

**Flags / values:** The local script checks equality against your intended account, the exact acknowledgment I_ACCEPT_BILLABLE_RESOURCES_IN_UNIT6B, and an ISO8601 timestamp with offset within the next eight hours. It is not a scheduled cleanup service. Leave CostAck=NO in Unit 6A.

**Illustrative output, never current-account evidence:**
```text
EXPECTED REHEARSAL: STOP: cost not acknowledged. Example format only: 2026-11-08T16:00:00-08:00 (PST); choose a genuinely future timestamp when you run it.
```

**Verify before continuing:** Test with a deliberately different actual account and expired end time separately using synthetic local values. No AWS request is made by this script.

**Likely errors / safe response:** Invalid timestamp: include -08:00 or the applicable local offset, not an ambiguous abbreviation. End time beyond eight hours fails deliberately.

**Matching Terraform / intentional CLI-only boundary:** No Terraform cost-cap/end-time function exists here. Local guard is a CLI/Python rehearsal, not an AWS enforcement mechanism or Terraform lifecycle guarantee.

**Practice:** Trigger wrong-account, missing-cost-ack and expired-time stops with synthetic values; keep CostAck NO afterward.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0023 · Addresses in one minute


#### Inspect VPCs, subnets and ENI address owners (`addresses`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. VPC CIDRs contain subnet ranges. Nodes, Pods in secondary-IP mode, EKS cluster ENIs, endpoints and load balancers consume addresses. An unused new-plan CIDR is not an existing VPC ID. No need to create anything merely to inspect it.

**Bash (macOS/Linux):**
```bash
aws ec2 describe-vpcs --profile "$AwsProfile" --region "$Region" --query 'Vpcs[].{ID:VpcId,CIDR:CidrBlock,OtherCIDRs:CidrBlockAssociationSet}' --output json --no-cli-pager
VpcId="REPLACE_WITH_EXISTING_VPC_ID"
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' --output table --no-cli-pager
aws ec2 describe-network-interfaces --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --query 'NetworkInterfaces[].{ID:NetworkInterfaceId,Subnet:SubnetId,Type:InterfaceType,IPs:PrivateIpAddresses,Description:Description}' --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws ec2 describe-vpcs --profile "$AwsProfile" --region "$Region" --query 'Vpcs[].{ID:VpcId,CIDR:CidrBlock,OtherCIDRs:CidrBlockAssociationSet}' --output json --no-cli-pager
$VpcId = "REPLACE_WITH_EXISTING_VPC_ID"
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' --output table --no-cli-pager
aws ec2 describe-network-interfaces --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --query 'NetworkInterfaces[].{ID:NetworkInterfaceId,Subnet:SubnetId,Type:InterfaceType,IPs:PrivateIpAddresses,Description:Description}' --output json --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. Get an existing VpcId from the FIRST readout only if you are authorized to inspect it. Otherwise skip the filtered reads. vpc-id filters scope the returned objects; AvailableIpAddressCount is a momentary free count, not total subnet size.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE DESIGN, NOT ACCOUNT OUTPUT: private-a 10.42.16.0/20 has 4096 total, 4091 usable before allocations. Existing Free may be smaller.
```

**Verify before continuing:** Match each ENI to subnet/type/description/attachment; available addresses change with allocations. Never detach/delete service-owned ENIs to make room.

**Likely errors / safe response:** Empty list: Region/filter may be wrong or no existing resources; record not present, not failed. InvalidVpcID.NotFound: verify account/Region/ID, do not create one here.

**Matching Terraform / intentional CLI-only boundary:** Optional aws_vpc.existing reads VPC CIDRs, DNS flags and main route table; aws_subnet.existing reads subnet CIDR/AZ/VPC/free IPs. available_ip_address_count matches CLI AvailableIpAddressCount. Supply selected existing IDs only; empty sets skip observations.

**Practice:** Draw a two-AZ address-owner ledger. If no authorized VPC exists, use only the illustrative offline calculator.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0024 · Every address, and who owns it


#### Inspect VPCs, subnets and ENI address owners (`addresses`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. VPC CIDRs contain subnet ranges. Nodes, Pods in secondary-IP mode, EKS cluster ENIs, endpoints and load balancers consume addresses. An unused new-plan CIDR is not an existing VPC ID. No need to create anything merely to inspect it.

**Bash (macOS/Linux):**
```bash
aws ec2 describe-vpcs --profile "$AwsProfile" --region "$Region" --query 'Vpcs[].{ID:VpcId,CIDR:CidrBlock,OtherCIDRs:CidrBlockAssociationSet}' --output json --no-cli-pager
VpcId="REPLACE_WITH_EXISTING_VPC_ID"
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' --output table --no-cli-pager
aws ec2 describe-network-interfaces --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --query 'NetworkInterfaces[].{ID:NetworkInterfaceId,Subnet:SubnetId,Type:InterfaceType,IPs:PrivateIpAddresses,Description:Description}' --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws ec2 describe-vpcs --profile "$AwsProfile" --region "$Region" --query 'Vpcs[].{ID:VpcId,CIDR:CidrBlock,OtherCIDRs:CidrBlockAssociationSet}' --output json --no-cli-pager
$VpcId = "REPLACE_WITH_EXISTING_VPC_ID"
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' --output table --no-cli-pager
aws ec2 describe-network-interfaces --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --query 'NetworkInterfaces[].{ID:NetworkInterfaceId,Subnet:SubnetId,Type:InterfaceType,IPs:PrivateIpAddresses,Description:Description}' --output json --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. Get an existing VpcId from the FIRST readout only if you are authorized to inspect it. Otherwise skip the filtered reads. vpc-id filters scope the returned objects; AvailableIpAddressCount is a momentary free count, not total subnet size.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE DESIGN, NOT ACCOUNT OUTPUT: private-a 10.42.16.0/20 has 4096 total, 4091 usable before allocations. Existing Free may be smaller.
```

**Verify before continuing:** Match each ENI to subnet/type/description/attachment; available addresses change with allocations. Never detach/delete service-owned ENIs to make room.

**Likely errors / safe response:** Empty list: Region/filter may be wrong or no existing resources; record not present, not failed. InvalidVpcID.NotFound: verify account/Region/ID, do not create one here.

**Matching Terraform / intentional CLI-only boundary:** Optional aws_vpc.existing reads VPC CIDRs, DNS flags and main route table; aws_subnet.existing reads subnet CIDR/AZ/VPC/free IPs. available_ip_address_count matches CLI AvailableIpAddressCount. Supply selected existing IDs only; empty sets skip observations.

**Practice:** Draw a two-AZ address-owner ledger. If no authorized VPC exists, use only the illustrative offline calculator.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### ALB means Application Load Balancer: inspect its web-routing path (`alb`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. ALB stands for Application Load Balancer. It is a layer-seven HTTP/HTTPS entry point: listener accepts requests, priority-ordered rules select a target group using conditions such as host/path, and target-group health checks guide target routing. All-unhealthy registered targets can cause fail-open: health checks are not a security boundary. In EKS an appropriately configured AWS Load Balancer Controller can reconcile an ALB from Ingress; IP target mode uses Pod IP targets, instance mode uses node/NodePort targets. These are alternative modes. Unit12 teaches creation/exposure. Reserve subnet room for ALB scaling here; no ALB is created.

**Bash (macOS/Linux):**
```bash
aws elbv2 describe-load-balancers --profile "$AwsProfile" --region "$Region" --query 'LoadBalancers[].{Name:LoadBalancerName,Arn:LoadBalancerArn,Type:Type,Scheme:Scheme,State:State.Code,Subnets:AvailabilityZones[].SubnetId}' --output json --no-cli-pager
# Continue ONLY if an authorized existing Type=application load balancer exists:
LoadBalancerArn="REPLACE_FROM_EXISTING_ALB_READOUT"
aws elbv2 describe-listeners --profile "$AwsProfile" --region "$Region" --load-balancer-arn "$LoadBalancerArn" --output json --no-cli-pager
ListenerArn="REPLACE_FROM_LISTENER_READOUT"
aws elbv2 describe-rules --profile "$AwsProfile" --region "$Region" --listener-arn "$ListenerArn" --output json --no-cli-pager
aws elbv2 describe-target-groups --profile "$AwsProfile" --region "$Region" --load-balancer-arn "$LoadBalancerArn" --output json --no-cli-pager
TargetGroupArn="REPLACE_FROM_TARGET_GROUP_READOUT"
aws elbv2 describe-target-health --profile "$AwsProfile" --region "$Region" --target-group-arn "$TargetGroupArn" --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws elbv2 describe-load-balancers --profile "$AwsProfile" --region "$Region" --query 'LoadBalancers[].{Name:LoadBalancerName,Arn:LoadBalancerArn,Type:Type,Scheme:Scheme,State:State.Code,Subnets:AvailabilityZones[].SubnetId}' --output json --no-cli-pager
# Continue ONLY if an authorized existing Type=application load balancer exists:
$LoadBalancerArn = "REPLACE_FROM_EXISTING_ALB_READOUT"
aws elbv2 describe-listeners --profile "$AwsProfile" --region "$Region" --load-balancer-arn "$LoadBalancerArn" --output json --no-cli-pager
$ListenerArn = "REPLACE_FROM_LISTENER_READOUT"
aws elbv2 describe-rules --profile "$AwsProfile" --region "$Region" --listener-arn "$ListenerArn" --output json --no-cli-pager
aws elbv2 describe-target-groups --profile "$AwsProfile" --region "$Region" --load-balancer-arn "$LoadBalancerArn" --output json --no-cli-pager
$TargetGroupArn = "REPLACE_FROM_TARGET_GROUP_READOUT"
aws elbv2 describe-target-health --profile "$AwsProfile" --region "$Region" --target-group-arn "$TargetGroupArn" --output json --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. elbv2 is the AWS CLI namespace for ALB/NLB APIs. --load-balancer-arn, --listener-arn and --target-group-arn select EXISTING objects from prior readouts. Type=application identifies ALB. Read protocol/port, rules priority/conditions/actions, target type, port/protocol and health state/reason. No AWS read result is fabricated.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: Type=application; Scheme=internet-facing or internal; listener HTTPS/443; host/path rule forwards to target group; TargetHealth.State healthy/unhealthy. These are shapes, not your account state.
```

**Verify before continuing:** Follow existing ALB -> listener -> rule -> target group -> target health. No ALB/authorization? Skip subsequent reads; do not create one to populate a tutorial. An ALB listener/rule is not a VPC route-table entry.

**Likely errors / safe response:** AccessDenied: ask for the relevant elasticloadbalancing:Describe action. Missing/wrong ARN: verify account/Region and prior readout. Unhealthy requires reason-code/backend-path diagnosis, not opening all inbound ports.

**Matching Terraform / intentional CLI-only boundary:** Terraform offline local.other_reservations.alb_headroom reserves eight addresses in the illustration. No aws_lb resource is included: actual ALB/controller creation is later and must have a single owner. Optional load-balancer-observations.tf has real aws_lb, aws_lb_listener, aws_lb_listener_rule and aws_lb_target_group data+outputs for selected existing ARNs. Target-group health_check is policy, NOT current registered-target health. Actual describe-target-health remains CLI-only; no fake routing or health evaluator.

**Practice:** Explain ALB in plain language and trace the web request through listener, host/path rule and target group. If authorized ALB exists, inspect it read-only; otherwise label the flow illustrative.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0025 · The planned network


#### Inspect VPCs, subnets and ENI address owners (`addresses`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. VPC CIDRs contain subnet ranges. Nodes, Pods in secondary-IP mode, EKS cluster ENIs, endpoints and load balancers consume addresses. An unused new-plan CIDR is not an existing VPC ID. No need to create anything merely to inspect it.

**Bash (macOS/Linux):**
```bash
aws ec2 describe-vpcs --profile "$AwsProfile" --region "$Region" --query 'Vpcs[].{ID:VpcId,CIDR:CidrBlock,OtherCIDRs:CidrBlockAssociationSet}' --output json --no-cli-pager
VpcId="REPLACE_WITH_EXISTING_VPC_ID"
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' --output table --no-cli-pager
aws ec2 describe-network-interfaces --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --query 'NetworkInterfaces[].{ID:NetworkInterfaceId,Subnet:SubnetId,Type:InterfaceType,IPs:PrivateIpAddresses,Description:Description}' --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws ec2 describe-vpcs --profile "$AwsProfile" --region "$Region" --query 'Vpcs[].{ID:VpcId,CIDR:CidrBlock,OtherCIDRs:CidrBlockAssociationSet}' --output json --no-cli-pager
$VpcId = "REPLACE_WITH_EXISTING_VPC_ID"
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' --output table --no-cli-pager
aws ec2 describe-network-interfaces --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --query 'NetworkInterfaces[].{ID:NetworkInterfaceId,Subnet:SubnetId,Type:InterfaceType,IPs:PrivateIpAddresses,Description:Description}' --output json --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. Get an existing VpcId from the FIRST readout only if you are authorized to inspect it. Otherwise skip the filtered reads. vpc-id filters scope the returned objects; AvailableIpAddressCount is a momentary free count, not total subnet size.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE DESIGN, NOT ACCOUNT OUTPUT: private-a 10.42.16.0/20 has 4096 total, 4091 usable before allocations. Existing Free may be smaller.
```

**Verify before continuing:** Match each ENI to subnet/type/description/attachment; available addresses change with allocations. Never detach/delete service-owned ENIs to make room.

**Likely errors / safe response:** Empty list: Region/filter may be wrong or no existing resources; record not present, not failed. InvalidVpcID.NotFound: verify account/Region/ID, do not create one here.

**Matching Terraform / intentional CLI-only boundary:** Optional aws_vpc.existing reads VPC CIDRs, DNS flags and main route table; aws_subnet.existing reads subnet CIDR/AZ/VPC/free IPs. available_ip_address_count matches CLI AvailableIpAddressCount. Supply selected existing IDs only; empty sets skip observations.

**Practice:** Draw a two-AZ address-owner ledger. If no authorized VPC exists, use only the illustrative offline calculator.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Read actual subnet association and winning route candidates (`routing`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Start at the actual source subnet owning the table. Longest matching prefix wins; inspect blackhole state and target validity. Return packets use their own source-subnet table. A correct route alone does not prove SG/NACL/DNS/service health or Internet connectivity.

**Bash (macOS/Linux):**
```bash
SubnetId="REPLACE_WITH_EXISTING_SUBNET_ID"
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters "Name=association.subnet-id,Values=$SubnetId" --output json --no-cli-pager
# If no explicit association was returned, consult this VPC main table:
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" Name=association.main,Values=true --output json --no-cli-pager
python3 scripts/network_checks.py --destination 10.42.33.7
python3 scripts/network_checks.py --destination 203.0.113.80
```

**PowerShell (Windows):**
```powershell
$SubnetId = "REPLACE_WITH_EXISTING_SUBNET_ID"
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters "Name=association.subnet-id,Values=$SubnetId" --output json --no-cli-pager
# If no explicit association was returned, consult this VPC main table:
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" Name=association.main,Values=true --output json --no-cli-pager
py -3 scripts/network_checks.py --destination 10.42.33.7
py -3 scripts/network_checks.py --destination 203.0.113.80
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. association.subnet-id finds EXPLICIT subnet associations; empty does NOT mean no routes. association.main,true plus VPC filter finds the inherited main table. Read Routes destination, target and State, and Associations owner before looking up a packet.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: owner private-a table; candidates 10.42.0.0/16->local and 0.0.0.0/0->nat-a; destination 10.42.33.7 chooses /16; 203.0.113.80 chooses /0. Documentation address is not a real reachable test host.
```

**Verify before continuing:** Write owner/table/destination/candidate prefixes/winner/next hop for forward AND return. Do not infer an association from a route-table name tag.

**Likely errors / safe response:** Empty explicit query: check main table. Blackhole route: investigate target with owner; no route mutations belong in this unit. Do not automatically add 0.0.0.0/0.

**Matching Terraform / intentional CLI-only boundary:** data.aws_route_table.existing reads selected existing route_table_ids, VPC, associations and routes. It does not compute a packet winner or expose every CLI per-route State field. CLI plus explicit source/destination reasoning still verifies LPM and blackhole state; no invented packet-tracer function.

**Practice:** For one private subnet read its real table or main fallback; if absent use the labelled design. Explain both forward and return decisions.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0026 · Five addresses you cannot use


#### Read live free IPv4 in one existing subnet (`subnet-free`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Total usable equals total IPv4 minus AWS five reservations. Current free is smaller when addresses are allocated. Subtract planned future growth conservatively from actual free, avoiding double-counting allocations already present. If no authorized subnet exists yet, skip this read and use the labelled design only.

**Bash (macOS/Linux):**
```bash
# Only after selecting an authorized EXISTING SubnetId from the subnet list:
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --subnet-ids "$SubnetId" --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' --output table --no-cli-pager
```

**PowerShell (Windows):**
```powershell
# Only after selecting an authorized EXISTING SubnetId from the subnet list:
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --subnet-ids "$SubnetId" --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' --output table --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --subnet-ids selects the real subnet ID you read earlier, not a CIDR or a planned name. Free is AvailableIpAddressCount now; --query changes display only.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE SHAPE: subnet-EXAMPLE | 10.42.16.0/20 | us-west-2a | free count from YOUR account. No free count is fabricated.
```

**Verify before continuing:** Compare actual CIDR/AZ/free with planned control-plane/node/upgrade/endpoints/LB needs. EKS cluster subnet minimum six free, sixteen recommended, is not total workload capacity.

**Likely errors / safe response:** InvalidSubnetID.NotFound: wrong account/Region/ID; do not create a subnet for the example. A successful point-in-time read cannot reserve future IPs.

**Matching Terraform / intentional CLI-only boundary:** data.aws_subnet.existing[id].available_ip_address_count is verified in pinned provider 6.21.0. existing_subnet_ids=[] skips these reads until a real authorized subnet exists.

**Practice:** Read one real free-IP count or record skipped/no existing subnet, then distinguish usable, allocated, free and planned reservation.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Calculate reserved space and test the small-subnet failure (`capacity`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. AWS reserves the first four and last IPv4 of every subnet. Reserve addresses for warm pools/upgrades/endpoints/load balancers, not just running Pods. Fifty percent headroom is a teaching policy, not an AWS mandatory subnet rule.

**Bash (macOS/Linux):**
```bash
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/20
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/24
```

**PowerShell (Windows):**
```powershell
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/20
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/24
```

**Flags / values:** All CIDRs are deliberate examples. --private chooses the subnet to calculate; no AWS calls. /20: 2^(32-20)-5=4091 usable; node reservation (2 steady+2 surge)*3 ENIs*10 IPv4=120; other reservations 4+4+8+1+6=23; total 143. /24 has 251 usable: 143/251 exceeds the illustrative 50 percent planning limit.

**Illustrative output, never current-account evidence:**
```text
OFFLINE EXAMPLE: /20 planned=143 remaining=3948 pass_50_percent_headroom=true; /24 planned=143 remaining=108 pass=false and exits STOP. The older legacy small fixture has DIFFERENT node inputs, so its 503 count is not this example.
```

**Verify before continuing:** Compare Terraform offline capacity_per_private_subnet output with the Python arithmetic. Read actual EC2 limits before changing instance type; prefix delegation needs contiguous prefixes and a different model.

**Likely errors / safe response:** CIDR has host bits set: supply the network boundary. Negative remaining or failed headroom: redesign, not override a guard. Neither calculator checks CPU/RAM/quotas or all production workloads.

**Matching Terraform / intentional CLI-only boundary:** offline/main.tf local CIDR/capacity calculations; actual type limits are read separately in the read-only project. No AWS resources or API access needed for arithmetic.

**Practice:** Calculate /20 and /24 by hand; explain that /24 fails the chosen headroom policy even though 143 is less than 251.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0027 · A capacity calculation, worked


#### Read offered types and ENI limits (`offerings`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. An offered type is sold in a zone; the readout does not guarantee On-Demand/Spot capacity, quota, architecture suitability or a successful launch. No instances are launched here. Prefix delegation/custom networking use different calculations.

**Bash (macOS/Linux):**
```bash
InstanceType="m6i.large"
aws ec2 describe-instance-type-offerings --profile "$AwsProfile" --region "$Region" --location-type availability-zone --filters "Name=instance-type,Values=$InstanceType" --output table --no-cli-pager
aws ec2 describe-instance-types --profile "$AwsProfile" --region "$Region" --instance-types "$InstanceType" --query 'InstanceTypes[].{Type:InstanceType,ENIs:NetworkInfo.MaximumNetworkInterfaces,IPv4PerENI:NetworkInfo.Ipv4AddressesPerInterface}' --output table --no-cli-pager
```

**PowerShell (Windows):**
```powershell
$InstanceType = "m6i.large"
aws ec2 describe-instance-type-offerings --profile "$AwsProfile" --region "$Region" --location-type availability-zone --filters "Name=instance-type,Values=$InstanceType" --output table --no-cli-pager
aws ec2 describe-instance-types --profile "$AwsProfile" --region "$Region" --instance-types "$InstanceType" --query 'InstanceTypes[].{Type:InstanceType,ENIs:NetworkInfo.MaximumNetworkInterfaces,IPv4PerENI:NetworkInfo.Ipv4AddressesPerInterface}' --output table --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --location-type availability-zone returns offers by AZ name; --instance-types selects a specific instance family/size. MaximumNetworkInterfaces is not the number of ENIs currently attached to a node.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE m6i.large: ENIs=3, IPv4PerENI=10. Classic secondary-IP formula gives 3*(10-1)+2=29 maxPods before applicable bootstrap caps/settings.
```

**Verify before continuing:** Compare offering Locations with your two chosen AZs; compare limits with the worksheet, and do not apply the classic formula to prefix mode.

**Likely errors / safe response:** Empty offering list: pick another approved type/Region with the administrator, not an unapproved larger expensive type. Unknown instance: check spelling and Region.

**Matching Terraform / intentional CLI-only boundary:** data.aws_ec2_instance_type and aws_ec2_instance_type_offerings; exact supported maximum_network_interfaces/maximum_ipv4_addresses_per_interface attributes.

**Practice:** Calculate classic maxPods from your actual type limits; explain why IP capacity still does not prove node scheduling capacity.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Read live free IPv4 in one existing subnet (`subnet-free`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Total usable equals total IPv4 minus AWS five reservations. Current free is smaller when addresses are allocated. Subtract planned future growth conservatively from actual free, avoiding double-counting allocations already present. If no authorized subnet exists yet, skip this read and use the labelled design only.

**Bash (macOS/Linux):**
```bash
# Only after selecting an authorized EXISTING SubnetId from the subnet list:
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --subnet-ids "$SubnetId" --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' --output table --no-cli-pager
```

**PowerShell (Windows):**
```powershell
# Only after selecting an authorized EXISTING SubnetId from the subnet list:
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --subnet-ids "$SubnetId" --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' --output table --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --subnet-ids selects the real subnet ID you read earlier, not a CIDR or a planned name. Free is AvailableIpAddressCount now; --query changes display only.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE SHAPE: subnet-EXAMPLE | 10.42.16.0/20 | us-west-2a | free count from YOUR account. No free count is fabricated.
```

**Verify before continuing:** Compare actual CIDR/AZ/free with planned control-plane/node/upgrade/endpoints/LB needs. EKS cluster subnet minimum six free, sixteen recommended, is not total workload capacity.

**Likely errors / safe response:** InvalidSubnetID.NotFound: wrong account/Region/ID; do not create a subnet for the example. A successful point-in-time read cannot reserve future IPs.

**Matching Terraform / intentional CLI-only boundary:** data.aws_subnet.existing[id].available_ip_address_count is verified in pinned provider 6.21.0. existing_subnet_ids=[] skips these reads until a real authorized subnet exists.

**Practice:** Read one real free-IP count or record skipped/no existing subnet, then distinguish usable, allocated, free and planned reservation.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Calculate reserved space and test the small-subnet failure (`capacity`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. AWS reserves the first four and last IPv4 of every subnet. Reserve addresses for warm pools/upgrades/endpoints/load balancers, not just running Pods. Fifty percent headroom is a teaching policy, not an AWS mandatory subnet rule.

**Bash (macOS/Linux):**
```bash
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/20
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/24
```

**PowerShell (Windows):**
```powershell
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/20
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/24
```

**Flags / values:** All CIDRs are deliberate examples. --private chooses the subnet to calculate; no AWS calls. /20: 2^(32-20)-5=4091 usable; node reservation (2 steady+2 surge)*3 ENIs*10 IPv4=120; other reservations 4+4+8+1+6=23; total 143. /24 has 251 usable: 143/251 exceeds the illustrative 50 percent planning limit.

**Illustrative output, never current-account evidence:**
```text
OFFLINE EXAMPLE: /20 planned=143 remaining=3948 pass_50_percent_headroom=true; /24 planned=143 remaining=108 pass=false and exits STOP. The older legacy small fixture has DIFFERENT node inputs, so its 503 count is not this example.
```

**Verify before continuing:** Compare Terraform offline capacity_per_private_subnet output with the Python arithmetic. Read actual EC2 limits before changing instance type; prefix delegation needs contiguous prefixes and a different model.

**Likely errors / safe response:** CIDR has host bits set: supply the network boundary. Negative remaining or failed headroom: redesign, not override a guard. Neither calculator checks CPU/RAM/quotas or all production workloads.

**Matching Terraform / intentional CLI-only boundary:** offline/main.tf local CIDR/capacity calculations; actual type limits are read separately in the read-only project. No AWS resources or API access needed for arithmetic.

**Practice:** Calculate /20 and /24 by hand; explain that /24 fails the chosen headroom policy even though 143 is less than 251.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0028 · The same calculation, too small


#### Read live free IPv4 in one existing subnet (`subnet-free`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Total usable equals total IPv4 minus AWS five reservations. Current free is smaller when addresses are allocated. Subtract planned future growth conservatively from actual free, avoiding double-counting allocations already present. If no authorized subnet exists yet, skip this read and use the labelled design only.

**Bash (macOS/Linux):**
```bash
# Only after selecting an authorized EXISTING SubnetId from the subnet list:
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --subnet-ids "$SubnetId" --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' --output table --no-cli-pager
```

**PowerShell (Windows):**
```powershell
# Only after selecting an authorized EXISTING SubnetId from the subnet list:
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --subnet-ids "$SubnetId" --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' --output table --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --subnet-ids selects the real subnet ID you read earlier, not a CIDR or a planned name. Free is AvailableIpAddressCount now; --query changes display only.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE SHAPE: subnet-EXAMPLE | 10.42.16.0/20 | us-west-2a | free count from YOUR account. No free count is fabricated.
```

**Verify before continuing:** Compare actual CIDR/AZ/free with planned control-plane/node/upgrade/endpoints/LB needs. EKS cluster subnet minimum six free, sixteen recommended, is not total workload capacity.

**Likely errors / safe response:** InvalidSubnetID.NotFound: wrong account/Region/ID; do not create a subnet for the example. A successful point-in-time read cannot reserve future IPs.

**Matching Terraform / intentional CLI-only boundary:** data.aws_subnet.existing[id].available_ip_address_count is verified in pinned provider 6.21.0. existing_subnet_ids=[] skips these reads until a real authorized subnet exists.

**Practice:** Read one real free-IP count or record skipped/no existing subnet, then distinguish usable, allocated, free and planned reservation.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Calculate reserved space and test the small-subnet failure (`capacity`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. AWS reserves the first four and last IPv4 of every subnet. Reserve addresses for warm pools/upgrades/endpoints/load balancers, not just running Pods. Fifty percent headroom is a teaching policy, not an AWS mandatory subnet rule.

**Bash (macOS/Linux):**
```bash
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/20
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/24
```

**PowerShell (Windows):**
```powershell
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/20
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/24
```

**Flags / values:** All CIDRs are deliberate examples. --private chooses the subnet to calculate; no AWS calls. /20: 2^(32-20)-5=4091 usable; node reservation (2 steady+2 surge)*3 ENIs*10 IPv4=120; other reservations 4+4+8+1+6=23; total 143. /24 has 251 usable: 143/251 exceeds the illustrative 50 percent planning limit.

**Illustrative output, never current-account evidence:**
```text
OFFLINE EXAMPLE: /20 planned=143 remaining=3948 pass_50_percent_headroom=true; /24 planned=143 remaining=108 pass=false and exits STOP. The older legacy small fixture has DIFFERENT node inputs, so its 503 count is not this example.
```

**Verify before continuing:** Compare Terraform offline capacity_per_private_subnet output with the Python arithmetic. Read actual EC2 limits before changing instance type; prefix delegation needs contiguous prefixes and a different model.

**Likely errors / safe response:** CIDR has host bits set: supply the network boundary. Negative remaining or failed headroom: redesign, not override a guard. Neither calculator checks CPU/RAM/quotas or all production workloads.

**Matching Terraform / intentional CLI-only boundary:** offline/main.tf local CIDR/capacity calculations; actual type limits are read separately in the read-only project. No AWS resources or API access needed for arithmetic.

**Practice:** Calculate /20 and /24 by hand; explain that /24 fails the chosen headroom policy even though 143 is less than 251.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0029 · The Service range is not in the VPC


#### Validate Service range and distinguish virtual forwarding (`service`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. ClusterIP is virtual Kubernetes service addressing. Kubernetes service forwarding handles it on nodes; adding a VPC route is not how a Service is created. A VPC-only route lookup hitting default does not imply ClusterIP traffic should go to NAT. Also check VPN/on-prem/peered ranges externally; this calculator only checks ranges passed to it.

**Bash (macOS/Linux):**
```bash
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --destination 172.20.0.10
# Deliberate failure, offline only:
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 10.42.0.0/16
```

**PowerShell (Windows):**
```powershell
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --destination 172.20.0.10
# Deliberate failure, offline only:
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 10.42.0.0/16
```

**Flags / values:** --service checks an RFC1918 /12 through /24 IPv4 range, non-overlapping the example VPC. --destination chooses a lookup address in a deliberately VPC-only route model. This is not a Linux/Kubernetes service implementation simulation.

**Illustrative output, never current-account evidence:**
```text
OFFLINE: overlap invocation exits STOP. 172.20.0.10 matches the illustrative VPC default, NOT a special VPC Service route.
```

**Verify before continuing:** Compare VPC/subnet/service ranges and your organization-wide IPAM plan; existing cluster actual range can be read with the optional cluster command.

**Likely errors / safe response:** Do not change the Service range of an existing cluster to fix a planning mistake; IPv4 Service range is chosen at cluster creation. No fake Terraform cidroverlaps function is used.

**Matching Terraform / intentional CLI-only boundary:** Terraform offline outputs carry the illustrative service_cidr; Python performs RFC1918/range/overlap validation. Terraform has no invented cidroverlaps/cidrcontains call in these files.

**Practice:** Explain why a Service CIDR must not overlap and why no NAT route creates a Service.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Optional existing cluster/add-on readout, no creation (`cluster`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. This is an AWS EKS service API read, not kubectl access to the Kubernetes API. Existing clusters may have self-managed add-ons; absence from list-addons does not prove the corresponding component is absent from Kubernetes.

**Bash (macOS/Linux):**
```bash
aws eks list-clusters --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
ClusterName="REPLACE_WITH_AUTHORIZED_EXISTING_CLUSTER"
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.{Name:name,Version:version,Status:status,Network:resourcesVpcConfig,Service:kubernetesNetworkConfig,Support:upgradePolicy}' --output json --no-cli-pager
aws eks list-addons --profile "$AwsProfile" --region "$Region" --cluster-name "$ClusterName" --output json --no-cli-pager
aws eks describe-addon --profile "$AwsProfile" --region "$Region" --cluster-name "$ClusterName" --addon-name vpc-cni --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws eks list-clusters --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
$ClusterName = "REPLACE_WITH_AUTHORIZED_EXISTING_CLUSTER"
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.{Name:name,Version:version,Status:status,Network:resourcesVpcConfig,Service:kubernetesNetworkConfig,Support:upgradePolicy}' --output json --no-cli-pager
aws eks list-addons --profile "$AwsProfile" --region "$Region" --cluster-name "$ClusterName" --output json --no-cli-pager
aws eks describe-addon --profile "$AwsProfile" --region "$Region" --cluster-name "$ClusterName" --addon-name vpc-cni --output json --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --name selects an existing cluster for describe-cluster, --cluster-name selects it for add-on operations. Read the list first; skip subsequent commands when no authorized cluster exists.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE empty sandbox: {"clusters":[]}. That is a successful discovery result, not an instruction to create a cluster.
```

**Verify before continuing:** Compare actual Service CIDR/subnet IDs/SGs with your worksheet only if you have an existing authorized cluster. No update-kubeconfig or mutation is required.

**Likely errors / safe response:** ResourceNotFoundException: wrong Region/name or no managed addon. Skip rather than install. AccessDenied: request only appropriate read permission.

**Matching Terraform / intentional CLI-only boundary:** data.aws_eks_cluster.existing reads only explicitly selected existing_cluster_names; empty set skips. Outputs show actual version/status/VPC/Service network/support/log settings. No cluster is fabricated, created or imported, and no auth token is requested.

**Practice:** If list is empty write not present; if authorized existing cluster, record its Service CIDR and managed add-on version privately.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0030 · Routes: the most specific one wins


#### Read actual subnet association and winning route candidates (`routing`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Start at the actual source subnet owning the table. Longest matching prefix wins; inspect blackhole state and target validity. Return packets use their own source-subnet table. A correct route alone does not prove SG/NACL/DNS/service health or Internet connectivity.

**Bash (macOS/Linux):**
```bash
SubnetId="REPLACE_WITH_EXISTING_SUBNET_ID"
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters "Name=association.subnet-id,Values=$SubnetId" --output json --no-cli-pager
# If no explicit association was returned, consult this VPC main table:
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" Name=association.main,Values=true --output json --no-cli-pager
python3 scripts/network_checks.py --destination 10.42.33.7
python3 scripts/network_checks.py --destination 203.0.113.80
```

**PowerShell (Windows):**
```powershell
$SubnetId = "REPLACE_WITH_EXISTING_SUBNET_ID"
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters "Name=association.subnet-id,Values=$SubnetId" --output json --no-cli-pager
# If no explicit association was returned, consult this VPC main table:
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" Name=association.main,Values=true --output json --no-cli-pager
py -3 scripts/network_checks.py --destination 10.42.33.7
py -3 scripts/network_checks.py --destination 203.0.113.80
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. association.subnet-id finds EXPLICIT subnet associations; empty does NOT mean no routes. association.main,true plus VPC filter finds the inherited main table. Read Routes destination, target and State, and Associations owner before looking up a packet.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: owner private-a table; candidates 10.42.0.0/16->local and 0.0.0.0/0->nat-a; destination 10.42.33.7 chooses /16; 203.0.113.80 chooses /0. Documentation address is not a real reachable test host.
```

**Verify before continuing:** Write owner/table/destination/candidate prefixes/winner/next hop for forward AND return. Do not infer an association from a route-table name tag.

**Likely errors / safe response:** Empty explicit query: check main table. Blackhole route: investigate target with owner; no route mutations belong in this unit. Do not automatically add 0.0.0.0/0.

**Matching Terraform / intentional CLI-only boundary:** data.aws_route_table.existing reads selected existing route_table_ids, VPC, associations and routes. It does not compute a packet winner or expose every CLI per-route State field. CLI plus explicit source/destination reasoning still verifies LPM and blackhole state; no invented packet-tracer function.

**Practice:** For one private subnet read its real table or main fallback; if absent use the labelled design. Explain both forward and return decisions.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0031 · Two NAT gateways, one per zone


#### Verify NAT placement, IGW and per-AZ route targets (`nat`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. One per AZ is the course zonal-NAT design, not a guarantee every NAT product/architecture works this way. Public NAT translates egress; an IGW is not itself a NAT-gateway replacement for private nodes. Cross-AZ paths have resilience and potential transfer-cost implications.

**Bash (macOS/Linux):**
```bash
aws ec2 describe-nat-gateways --profile "$AwsProfile" --region "$Region" --filter "Name=vpc-id,Values=$VpcId" --query 'NatGateways[].{ID:NatGatewayId,State:State,Subnet:SubnetId,Type:ConnectivityType,Addresses:NatGatewayAddresses}' --output json --no-cli-pager
aws ec2 describe-internet-gateways --profile "$AwsProfile" --region "$Region" --filters "Name=attachment.vpc-id,Values=$VpcId" --output json --no-cli-pager
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --query 'Subnets[].{ID:SubnetId,AZ:AvailabilityZone,CIDR:CidrBlock}' --output table --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws ec2 describe-nat-gateways --profile "$AwsProfile" --region "$Region" --filter "Name=vpc-id,Values=$VpcId" --query 'NatGateways[].{ID:NatGatewayId,State:State,Subnet:SubnetId,Type:ConnectivityType,Addresses:NatGatewayAddresses}' --output json --no-cli-pager
aws ec2 describe-internet-gateways --profile "$AwsProfile" --region "$Region" --filters "Name=attachment.vpc-id,Values=$VpcId" --output json --no-cli-pager
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --query 'Subnets[].{ID:SubnetId,AZ:AvailabilityZone,CIDR:CidrBlock}' --output table --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. describe-nat-gateways uses singular --filter; other EC2 operations here use --filters. Map each NAT SubnetId to subnet AZ, and match private-table NatGatewayId to its intended AZ. Public NAT needs a public subnet path to an attached IGW.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE DESIGN: private-a /0->nat-a in public-a; private-b /0->nat-b in public-b; public /0->igw. No NAT created or observed by us.
```

**Verify before continuing:** Combine NAT state/subnet/AZ, private route target and public subnet table default->IGW; inspect the same dependencies on return. Do not claim connectivity from one healthy field.

**Likely errors / safe response:** Empty list is expected before Unit 6B. Pending/failed/deleted NAT or wrong AZ: diagnose with owner, do not allocate a new billable gateway here.

**Matching Terraform / intentional CLI-only boundary:** data.aws_nat_gateway.existing reads selected existing IDs/state/subnet/addresses; data.aws_internet_gateway.existing reads attachment metadata. Combine with aws_subnet AZ and aws_route_table associations/routes. No resource blocks: Terraform observes, never creates/adopts gateways here.

**Practice:** Trace private node -> its table -> NAT in same AZ -> public subnet table -> IGW; describe the reverse translations.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0032 · Security groups and network ACLs


#### Read SG and NACL rules including return ports (`filters`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Security groups are stateful allow-only filters and return traffic for tracked flows is allowed. NACLs are stateless ordered allow/deny; first matching numbered rule wins separately in/out. Evaluate source/destination CIDR and the destination port in the direction at this subnet, accounting for translation. Do not open all inbound ports to fix an assumed problem.

**Bash (macOS/Linux):**
```bash
aws ec2 describe-security-groups --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --output json --no-cli-pager
aws ec2 describe-network-acls --profile "$AwsProfile" --region "$Region" --filters "Name=association.subnet-id,Values=$SubnetId" --output json --no-cli-pager
aws ec2 describe-network-interfaces --profile "$AwsProfile" --region "$Region" --filters "Name=subnet-id,Values=$SubnetId" --query 'NetworkInterfaces[].{ENI:NetworkInterfaceId,Groups:Groups}' --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws ec2 describe-security-groups --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --output json --no-cli-pager
aws ec2 describe-network-acls --profile "$AwsProfile" --region "$Region" --filters "Name=association.subnet-id,Values=$SubnetId" --output json --no-cli-pager
aws ec2 describe-network-interfaces --profile "$AwsProfile" --region "$Region" --filters "Name=subnet-id,Values=$SubnetId" --query 'NetworkInterfaces[].{ENI:NetworkInterfaceId,Groups:Groups}' --output json --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. SG output contains IpPermissions and IpPermissionsEgress; ENI Groups identifies which SGs actually apply. NACL Entries contain RuleNumber, Egress (direction), Protocol, action and PortRange. Associations tell which subnet uses the NACL.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE TCP: client 10.42.16.21:40312 -> server 203.0.113.80:443; reply destination port 40312. NACL inbound allow only 443 misses the reply and falls to implicit deny.
```

**Verify before continuing:** Check actual ENI SG attachment and subnet NACL association, not any SG/NACL with a convenient name. Compare ephemeral ranges for actual client/NAT use rather than assuming all Linux uses the same range.

**Likely errors / safe response:** A correct route and SG do not override a NACL deny. Read-only inspection does not capture packets; use the offline filter example until later hands-on networking units.

**Matching Terraform / intentional CLI-only boundary:** CLI-only rule inspection and offline simulation in this unit. No invented Terraform packet-tracer or SG state evaluator; no security-rule resource ownership.

**Practice:** Find the first matching NACL return rule for destination port 40312 and explain what happens if it is absent.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0033 · Knowledge check


#### Validate Service range and distinguish virtual forwarding (`service`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. ClusterIP is virtual Kubernetes service addressing. Kubernetes service forwarding handles it on nodes; adding a VPC route is not how a Service is created. A VPC-only route lookup hitting default does not imply ClusterIP traffic should go to NAT. Also check VPN/on-prem/peered ranges externally; this calculator only checks ranges passed to it.

**Bash (macOS/Linux):**
```bash
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --destination 172.20.0.10
# Deliberate failure, offline only:
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 10.42.0.0/16
```

**PowerShell (Windows):**
```powershell
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --destination 172.20.0.10
# Deliberate failure, offline only:
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 10.42.0.0/16
```

**Flags / values:** --service checks an RFC1918 /12 through /24 IPv4 range, non-overlapping the example VPC. --destination chooses a lookup address in a deliberately VPC-only route model. This is not a Linux/Kubernetes service implementation simulation.

**Illustrative output, never current-account evidence:**
```text
OFFLINE: overlap invocation exits STOP. 172.20.0.10 matches the illustrative VPC default, NOT a special VPC Service route.
```

**Verify before continuing:** Compare VPC/subnet/service ranges and your organization-wide IPAM plan; existing cluster actual range can be read with the optional cluster command.

**Likely errors / safe response:** Do not change the Service range of an existing cluster to fix a planning mistake; IPv4 Service range is chosen at cluster creation. No fake Terraform cidroverlaps function is used.

**Matching Terraform / intentional CLI-only boundary:** Terraform offline outputs carry the illustrative service_cidr; Python performs RFC1918/range/overlap validation. Terraform has no invented cidroverlaps/cidrcontains call in these files.

**Practice:** Explain why a Service CIDR must not overlap and why no NAT route creates a Service.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0034 · Answer: there is nothing to route to


#### Validate Service range and distinguish virtual forwarding (`service`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. ClusterIP is virtual Kubernetes service addressing. Kubernetes service forwarding handles it on nodes; adding a VPC route is not how a Service is created. A VPC-only route lookup hitting default does not imply ClusterIP traffic should go to NAT. Also check VPN/on-prem/peered ranges externally; this calculator only checks ranges passed to it.

**Bash (macOS/Linux):**
```bash
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --destination 172.20.0.10
# Deliberate failure, offline only:
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 10.42.0.0/16
```

**PowerShell (Windows):**
```powershell
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --destination 172.20.0.10
# Deliberate failure, offline only:
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 10.42.0.0/16
```

**Flags / values:** --service checks an RFC1918 /12 through /24 IPv4 range, non-overlapping the example VPC. --destination chooses a lookup address in a deliberately VPC-only route model. This is not a Linux/Kubernetes service implementation simulation.

**Illustrative output, never current-account evidence:**
```text
OFFLINE: overlap invocation exits STOP. 172.20.0.10 matches the illustrative VPC default, NOT a special VPC Service route.
```

**Verify before continuing:** Compare VPC/subnet/service ranges and your organization-wide IPAM plan; existing cluster actual range can be read with the optional cluster command.

**Likely errors / safe response:** Do not change the Service range of an existing cluster to fix a planning mistake; IPv4 Service range is chosen at cluster creation. No fake Terraform cidroverlaps function is used.

**Matching Terraform / intentional CLI-only boundary:** Terraform offline outputs carry the illustrative service_cidr; Python performs RFC1918/range/overlap validation. Terraform has no invented cidroverlaps/cidrcontains call in these files.

**Practice:** Explain why a Service CIDR must not overlap and why no NAT route creates a Service.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0035 · Practice: what you will check, and what you will not create


#### Your computer, your account, no creation yet (`orientation`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Open Terminal on macOS/Linux and choose Bash; open PowerShell on Windows. These are commands for YOUR computer, not an EC2 shell, a Kubernetes Pod or the AWS console search bar. Extract the practice ZIP to a private folder first.

**Bash (macOS/Linux):**
```bash
pwd
ls
aws --version
```

**PowerShell (Windows):**
```powershell
Get-Location
Get-ChildItem
aws --version
```

**Flags / values:** pwd/Get-Location show your current local folder; ls/Get-ChildItem list its files. No AWS account request is made by --version.

**Illustrative output, never current-account evidence:**
```text
EXAMPLE: .../unit06a ; commands, scripts, terraform ; aws-cli/2.39.6
```

**Verify before continuing:** Your folder contains README.md, FOLLOW-ALONG.md, commands/, scripts/ and terraform/. Do not copy a leading dollar or prompt symbol.

**Likely errors / safe response:** Command not found: install the tool using INSTALL.md, close and reopen the terminal so PATH refreshes.

**Matching Terraform / intentional CLI-only boundary:** Terraform introduction and two complete projects are provided; CLI and Terraform read the same facts without taking ownership of infrastructure.

**Practice:** Identify your shell and current folder; open README.md in a text editor.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0036 · Practice: check your tools


#### Read tool versions, not cluster state (`tools`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. CLI >=2.32.0 is required for aws login. Tested Terraform binary is 1.13.5, pinned provider 6.21.0; not a claim of latest versions. Match kubectl within one minor of the cluster version when you actually build in Unit 6B.

**Bash (macOS/Linux):**
```bash
aws --version
terraform version
python3 --version
kubectl version --client --output=yaml
```

**PowerShell (Windows):**
```powershell
aws --version
terraform version
py -3 --version
kubectl version --client --output=yaml
```

**Flags / values:** All four version checks are local. --client avoids contacting a Kubernetes API. Python 3 uses standard library only for these exercises; Windows uses py -3 (or python if that is your confirmed Python 3 launcher). jq is not required by the r4 commands.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: aws-cli/2.39.6; Terraform v1.13.5; Python 3.x; kubectl client v1.xx.x. These are examples, not your machine state.
```

**Verify before continuing:** Use INSTALL.md for OS-specific commands. Do not run kubectl get nodes against a random existing context to test installation.

**Likely errors / safe response:** Command not found: reopen terminal after install/PATH change. Windows Store Python alias is not proof Python is installed. AWS CLI v1 lacks newer APIs.

**Matching Terraform / intentional CLI-only boundary:** Terraform is a local declarative configuration tool: .tf files describe reads/calculations or managed resources; its provider is an API plugin; state records observations/ownership. Our first project is offline, second data-only.

**Practice:** Read each local version and record it privately, then explain Terraform/provider/state in your own words.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0037 · Practice: config.env and the first preflight


#### Set deliberate profile and Region (`settings`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. An account is the billing/security boundary. A Region is an AWS geography. A local profile is a name for authentication configuration, not an AWS account or permission grant.

**Bash (macOS/Linux):**
```bash
AwsProfile="REPLACE_WITH_YOUR_PROFILE"
Region="us-west-2"
ExpectedAccount="REPLACE_WITH_12_DIGITS"
export AWS_PAGER=""
export AWS_CLI_AUTO_PROMPT=off
aws configure list-profiles
aws configure list --profile "$AwsProfile"
```

**PowerShell (Windows):**
```powershell
$AwsProfile = "REPLACE_WITH_YOUR_PROFILE"
$Region = "us-west-2"
$ExpectedAccount = "REPLACE_WITH_12_DIGITS"
$env:AWS_PAGER = ""
$env:AWS_CLI_AUTO_PROMPT = "off"
aws configure list-profiles
aws configure list --profile "$AwsProfile"
```

**Flags / values:** Replace profile with an approved sandbox profile name, and ExpectedAccount with the approved 12-digit account ID obtained from your administrator/account menu, not simply whatever STS returns. us-west-2 is illustrative: choose your approved Region. Variables live only in this terminal. configure list shows masked credential values and where settings came from; do not share it publicly.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: profile eksclass-student (manual); region us-west-2 (config-file). No credentials are reproduced here.
```

**Verify before continuing:** Confirm the exact profile name in list-profiles; the explicit --region on later commands wins over environment/default profile Region.

**Likely errors / safe response:** Profile not found: create it using ONE authentication path. Never repair this by pasting permanent keys into course files.

**Matching Terraform / intentional CLI-only boundary:** read-only/variables.tf supplies aws_profile, aws_region, expected_account_id; allowed_account_ids rejects the wrong account.

**Practice:** Fill your profile, approved account and Region in a private worksheet. Do not publish that worksheet.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Read identity and stop on the wrong account (`identity`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Account must equal your approved account. An assumed-role ARN describes the temporary session, not an IAM role ARN you may put into simulate-principal-policy. STS identity does not prove permission to read EC2/EKS or create anything.

**Bash (macOS/Linux):**
```bash
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
ActualAccount=$(aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --query Account --output text --no-cli-pager) || exit 1
if [ "$ActualAccount" != "$ExpectedAccount" ]; then printf '%s
' 'STOP: wrong account'; exit 1; fi
```

**PowerShell (Windows):**
```powershell
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
$ActualAccount = aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --query Account --output text --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw "Identity request failed" }
if ($ActualAccount -ne $ExpectedAccount) { throw "STOP: wrong account" }
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --query Account extracts only the account field using JMESPath. Bash $? and PowerShell $LASTEXITCODE are native-process exit codes; PowerShell does not throw automatically on every aws failure.

**Illustrative output, never current-account evidence:**
```text
{"UserId":"EXAMPLE","Account":"111122223333","Arn":"arn:aws:sts::111122223333:assumed-role/LabRole/ExampleSession"} (ILLUSTRATIVE ONLY)
```

**Verify before continuing:** Compare Account manually AND execute the guard. STOP on an ARN ending :root: use an approved temporary non-root principal for daily work.

**Likely errors / safe response:** ExpiredToken/SSO token expired: sign in again to the intended profile. AccessDenied for another API is not fixed by STS succeeding.

**Matching Terraform / intentional CLI-only boundary:** data.aws_caller_identity.current and provider allowed_account_ids; no IAM policy is changed.

**Practice:** Compare Account and ARN; explain why identity success is not authorization for EKS.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0038 · Practice: trigger two guards on purpose


#### Rehearse account, cost and end-time guards (`guard`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. First predict the stop, then run it. Unit 6A never uses this guard to create anything. Unit 6B must use its own explicit reviewed owner/cleanup procedure immediately before billable operations.

**Bash (macOS/Linux):**
```bash
CostAck="NO"
EndTime="REPLACE_WITH_FUTURE_ISO8601_WITH_OFFSET"
python3 scripts/check_guard.py --expected-account "$ExpectedAccount" --actual-account "$ActualAccount" --cost-ack "$CostAck" --end-time "$EndTime"
```

**PowerShell (Windows):**
```powershell
$CostAck = "NO"
$EndTime = "REPLACE_WITH_FUTURE_ISO8601_WITH_OFFSET"
py -3 scripts/check_guard.py --expected-account "$ExpectedAccount" --actual-account "$ActualAccount" --cost-ack "$CostAck" --end-time "$EndTime"
if ($LASTEXITCODE -ne 0) { throw "STOP: local guard failed" }
```

**Flags / values:** The local script checks equality against your intended account, the exact acknowledgment I_ACCEPT_BILLABLE_RESOURCES_IN_UNIT6B, and an ISO8601 timestamp with offset within the next eight hours. It is not a scheduled cleanup service. Leave CostAck=NO in Unit 6A.

**Illustrative output, never current-account evidence:**
```text
EXPECTED REHEARSAL: STOP: cost not acknowledged. Example format only: 2026-11-08T16:00:00-08:00 (PST); choose a genuinely future timestamp when you run it.
```

**Verify before continuing:** Test with a deliberately different actual account and expired end time separately using synthetic local values. No AWS request is made by this script.

**Likely errors / safe response:** Invalid timestamp: include -08:00 or the applicable local offset, not an ambiguous abbreviation. End time beyond eight hours fails deliberately.

**Matching Terraform / intentional CLI-only boundary:** No Terraform cost-cap/end-time function exists here. Local guard is a CLI/Python rehearsal, not an AWS enforcement mechanism or Terraform lifecycle guarantee.

**Practice:** Trigger wrong-account, missing-cost-ack and expired-time stops with synthetic values; keep CostAck NO afterward.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0039 · Practice: is the network big enough?


#### Read live free IPv4 in one existing subnet (`subnet-free`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Total usable equals total IPv4 minus AWS five reservations. Current free is smaller when addresses are allocated. Subtract planned future growth conservatively from actual free, avoiding double-counting allocations already present. If no authorized subnet exists yet, skip this read and use the labelled design only.

**Bash (macOS/Linux):**
```bash
# Only after selecting an authorized EXISTING SubnetId from the subnet list:
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --subnet-ids "$SubnetId" --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' --output table --no-cli-pager
```

**PowerShell (Windows):**
```powershell
# Only after selecting an authorized EXISTING SubnetId from the subnet list:
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --subnet-ids "$SubnetId" --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' --output table --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --subnet-ids selects the real subnet ID you read earlier, not a CIDR or a planned name. Free is AvailableIpAddressCount now; --query changes display only.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE SHAPE: subnet-EXAMPLE | 10.42.16.0/20 | us-west-2a | free count from YOUR account. No free count is fabricated.
```

**Verify before continuing:** Compare actual CIDR/AZ/free with planned control-plane/node/upgrade/endpoints/LB needs. EKS cluster subnet minimum six free, sixteen recommended, is not total workload capacity.

**Likely errors / safe response:** InvalidSubnetID.NotFound: wrong account/Region/ID; do not create a subnet for the example. A successful point-in-time read cannot reserve future IPs.

**Matching Terraform / intentional CLI-only boundary:** data.aws_subnet.existing[id].available_ip_address_count is verified in pinned provider 6.21.0. existing_subnet_ids=[] skips these reads until a real authorized subnet exists.

**Practice:** Read one real free-IP count or record skipped/no existing subnet, then distinguish usable, allocated, free and planned reservation.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Calculate reserved space and test the small-subnet failure (`capacity`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. AWS reserves the first four and last IPv4 of every subnet. Reserve addresses for warm pools/upgrades/endpoints/load balancers, not just running Pods. Fifty percent headroom is a teaching policy, not an AWS mandatory subnet rule.

**Bash (macOS/Linux):**
```bash
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/20
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/24
```

**PowerShell (Windows):**
```powershell
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/20
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/24
```

**Flags / values:** All CIDRs are deliberate examples. --private chooses the subnet to calculate; no AWS calls. /20: 2^(32-20)-5=4091 usable; node reservation (2 steady+2 surge)*3 ENIs*10 IPv4=120; other reservations 4+4+8+1+6=23; total 143. /24 has 251 usable: 143/251 exceeds the illustrative 50 percent planning limit.

**Illustrative output, never current-account evidence:**
```text
OFFLINE EXAMPLE: /20 planned=143 remaining=3948 pass_50_percent_headroom=true; /24 planned=143 remaining=108 pass=false and exits STOP. The older legacy small fixture has DIFFERENT node inputs, so its 503 count is not this example.
```

**Verify before continuing:** Compare Terraform offline capacity_per_private_subnet output with the Python arithmetic. Read actual EC2 limits before changing instance type; prefix delegation needs contiguous prefixes and a different model.

**Likely errors / safe response:** CIDR has host bits set: supply the network boundary. Negative remaining or failed headroom: redesign, not override a guard. Neither calculator checks CPU/RAM/quotas or all production workloads.

**Matching Terraform / intentional CLI-only boundary:** offline/main.tf local CIDR/capacity calculations; actual type limits are read separately in the read-only project. No AWS resources or API access needed for arithmetic.

**Practice:** Calculate /20 and /24 by hand; explain that /24 fails the chosen headroom policy even though 143 is less than 251.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Run complete offline Terraform project (`tf-offline`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Read Terraform before using it: variables are typed inputs; locals are named calculations; outputs are values to display; .tfvars supplies non-secret inputs; a provider is an API plugin. This project needs no provider or credentials. All .tf files in the directory combine into one configuration. The complete files are below, not omitted fragments.

**Bash (macOS/Linux):**
```bash
terraform -chdir=terraform/offline init -backend=false -input=false
terraform -chdir=terraform/offline fmt -check
terraform -chdir=terraform/offline validate
terraform -chdir=terraform/offline plan -input=false -out=offline.tfplan
# Optional LOCAL state/output write, no AWS calls or AWS resources:
terraform -chdir=terraform/offline apply -input=false offline.tfplan
terraform -chdir=terraform/offline output -json
```

**PowerShell (Windows):**
```powershell
terraform -chdir=terraform/offline init -backend=false -input=false
terraform -chdir=terraform/offline fmt -check
terraform -chdir=terraform/offline validate
terraform -chdir=terraform/offline plan -input=false -out=offline.tfplan
# Optional LOCAL state/output write, no AWS calls or AWS resources:
terraform -chdir=terraform/offline apply -input=false offline.tfplan
terraform -chdir=terraform/offline output -json
```

**Flags / values:** -backend=false skips backend initialization; no backend block exists, so state is local. init prepares the folder; fmt checks formatting; validate checks configuration syntax/types, NOT account correctness; plan previews changes and -out saves a LOCAL plan in the selected project. Applying that reviewed plan writes local state/outputs only. output reads saved state; it is empty until apply.

**Illustrative output, never current-account evidence:**
```text
OFFLINE expected: Changes to Outputs; 4091 usable, 143 planned, 3948 remaining, classic maxPods 29. No resource create/update/delete actions.
```

**Verify before continuing:** Inspect plan: only output changes, no resource actions. If you see a resource, stop: wrong folder or modified files. Optional apply is only to persist outputs. You may skip it and inspect the plan instead.

**Likely errors / safe response:** No configuration files: wrong -chdir/current folder. No outputs: state has not been written yet. Validation success does not prove nonoverlap/production capacity.

**Matching Terraform / intentional CLI-only boundary:** All files in terraform/offline/ are complete; terraform.tfvars.example is optional because defaults are safe illustrations. Never put account secrets in variables.

**Practice:** Explain each command then compare saved output to the Python calculator; no need for authenticated AWS access.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0040 · Practice: overlaps and routes


#### Validate Service range and distinguish virtual forwarding (`service`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. ClusterIP is virtual Kubernetes service addressing. Kubernetes service forwarding handles it on nodes; adding a VPC route is not how a Service is created. A VPC-only route lookup hitting default does not imply ClusterIP traffic should go to NAT. Also check VPN/on-prem/peered ranges externally; this calculator only checks ranges passed to it.

**Bash (macOS/Linux):**
```bash
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --destination 172.20.0.10
# Deliberate failure, offline only:
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 10.42.0.0/16
```

**PowerShell (Windows):**
```powershell
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --destination 172.20.0.10
# Deliberate failure, offline only:
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 10.42.0.0/16
```

**Flags / values:** --service checks an RFC1918 /12 through /24 IPv4 range, non-overlapping the example VPC. --destination chooses a lookup address in a deliberately VPC-only route model. This is not a Linux/Kubernetes service implementation simulation.

**Illustrative output, never current-account evidence:**
```text
OFFLINE: overlap invocation exits STOP. 172.20.0.10 matches the illustrative VPC default, NOT a special VPC Service route.
```

**Verify before continuing:** Compare VPC/subnet/service ranges and your organization-wide IPAM plan; existing cluster actual range can be read with the optional cluster command.

**Likely errors / safe response:** Do not change the Service range of an existing cluster to fix a planning mistake; IPv4 Service range is chosen at cluster creation. No fake Terraform cidroverlaps function is used.

**Matching Terraform / intentional CLI-only boundary:** Terraform offline outputs carry the illustrative service_cidr; Python performs RFC1918/range/overlap validation. Terraform has no invented cidroverlaps/cidrcontains call in these files.

**Practice:** Explain why a Service CIDR must not overlap and why no NAT route creates a Service.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Read actual subnet association and winning route candidates (`routing`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Start at the actual source subnet owning the table. Longest matching prefix wins; inspect blackhole state and target validity. Return packets use their own source-subnet table. A correct route alone does not prove SG/NACL/DNS/service health or Internet connectivity.

**Bash (macOS/Linux):**
```bash
SubnetId="REPLACE_WITH_EXISTING_SUBNET_ID"
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters "Name=association.subnet-id,Values=$SubnetId" --output json --no-cli-pager
# If no explicit association was returned, consult this VPC main table:
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" Name=association.main,Values=true --output json --no-cli-pager
python3 scripts/network_checks.py --destination 10.42.33.7
python3 scripts/network_checks.py --destination 203.0.113.80
```

**PowerShell (Windows):**
```powershell
$SubnetId = "REPLACE_WITH_EXISTING_SUBNET_ID"
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters "Name=association.subnet-id,Values=$SubnetId" --output json --no-cli-pager
# If no explicit association was returned, consult this VPC main table:
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" Name=association.main,Values=true --output json --no-cli-pager
py -3 scripts/network_checks.py --destination 10.42.33.7
py -3 scripts/network_checks.py --destination 203.0.113.80
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. association.subnet-id finds EXPLICIT subnet associations; empty does NOT mean no routes. association.main,true plus VPC filter finds the inherited main table. Read Routes destination, target and State, and Associations owner before looking up a packet.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: owner private-a table; candidates 10.42.0.0/16->local and 0.0.0.0/0->nat-a; destination 10.42.33.7 chooses /16; 203.0.113.80 chooses /0. Documentation address is not a real reachable test host.
```

**Verify before continuing:** Write owner/table/destination/candidate prefixes/winner/next hop for forward AND return. Do not infer an association from a route-table name tag.

**Likely errors / safe response:** Empty explicit query: check main table. Blackhole route: investigate target with owner; no route mutations belong in this unit. Do not automatically add 0.0.0.0/0.

**Matching Terraform / intentional CLI-only boundary:** data.aws_route_table.existing reads selected existing route_table_ids, VPC, associations and routes. It does not compute a packet winner or expose every CLI per-route State field. CLI plus explicit source/destination reasoning still verifies LPM and blackhole state; no invented packet-tracer function.

**Practice:** For one private subnet read its real table or main fallback; if absent use the labelled design. Explain both forward and return decisions.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0041 · Practice: a stateless filter drops a reply


#### Read SG and NACL rules including return ports (`filters`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Security groups are stateful allow-only filters and return traffic for tracked flows is allowed. NACLs are stateless ordered allow/deny; first matching numbered rule wins separately in/out. Evaluate source/destination CIDR and the destination port in the direction at this subnet, accounting for translation. Do not open all inbound ports to fix an assumed problem.

**Bash (macOS/Linux):**
```bash
aws ec2 describe-security-groups --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --output json --no-cli-pager
aws ec2 describe-network-acls --profile "$AwsProfile" --region "$Region" --filters "Name=association.subnet-id,Values=$SubnetId" --output json --no-cli-pager
aws ec2 describe-network-interfaces --profile "$AwsProfile" --region "$Region" --filters "Name=subnet-id,Values=$SubnetId" --query 'NetworkInterfaces[].{ENI:NetworkInterfaceId,Groups:Groups}' --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws ec2 describe-security-groups --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --output json --no-cli-pager
aws ec2 describe-network-acls --profile "$AwsProfile" --region "$Region" --filters "Name=association.subnet-id,Values=$SubnetId" --output json --no-cli-pager
aws ec2 describe-network-interfaces --profile "$AwsProfile" --region "$Region" --filters "Name=subnet-id,Values=$SubnetId" --query 'NetworkInterfaces[].{ENI:NetworkInterfaceId,Groups:Groups}' --output json --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. SG output contains IpPermissions and IpPermissionsEgress; ENI Groups identifies which SGs actually apply. NACL Entries contain RuleNumber, Egress (direction), Protocol, action and PortRange. Associations tell which subnet uses the NACL.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE TCP: client 10.42.16.21:40312 -> server 203.0.113.80:443; reply destination port 40312. NACL inbound allow only 443 misses the reply and falls to implicit deny.
```

**Verify before continuing:** Check actual ENI SG attachment and subnet NACL association, not any SG/NACL with a convenient name. Compare ephemeral ranges for actual client/NAT use rather than assuming all Linux uses the same range.

**Likely errors / safe response:** A correct route and SG do not override a NACL deny. Read-only inspection does not capture packets; use the offline filter example until later hands-on networking units.

**Matching Terraform / intentional CLI-only boundary:** CLI-only rule inspection and offline simulation in this unit. No invented Terraform packet-tracer or SG state evaluator; no security-rule resource ownership.

**Practice:** Find the first matching NACL return rule for destination port 40312 and explain what happens if it is absent.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0042 · Optional: sign in, then read-only checks


#### Choose one temporary sign-in path (`auth`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Ask your administrator for a sandbox account, approved role, MFA, and permissions before signing in. aws login requires CLI >=2.32.0 and SignInLocalDevelopmentAccess for IAM users/roles/groups. IAM Identity Center uses its own configure sso/login path. Even though aws login supports root, root is not a daily-work recommendation.

**Bash (macOS/Linux):**
```bash
# PATH A: CLI 2.32.0+; approved non-root principal with SignInLocalDevelopmentAccess
aws login --profile "$AwsProfile" --region "$Region"
# PATH B instead: IAM Identity Center; use your organization-provided values interactively
aws configure sso --profile "$AwsProfile"
aws sso login --profile "$AwsProfile"
```

**PowerShell (Windows):**
```powershell
# PATH A: CLI 2.32.0+; approved non-root principal with SignInLocalDevelopmentAccess
aws login --profile "$AwsProfile" --region "$Region"
# PATH B instead: IAM Identity Center; use your organization-provided values interactively
aws configure sso --profile "$AwsProfile"
aws sso login --profile "$AwsProfile"
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. aws configure sso writes local profile configuration and asks for your organization SSO session/start URL/SSO Region/account/role. aws login and sso login open your browser. Use ONE path, not both sequentially. Do not type passwords into lesson files.

**Illustrative output, never current-account evidence:**
```text
EXAMPLE: browser sign-in completed, then sts get-caller-identity returns the intended account. No real login result is claimed.
```

**Verify before continuing:** Run the identity command after sign-in. Have the administrator verify required sign-in policy if aws login is denied; do not attach AdministratorAccess to yourself.

**Likely errors / safe response:** Unknown command login: update CLI v2. Browser unavailable: use documented aws login --remote only on an approved device; never post the authorization code. SSO needs the organization-provided configuration, not guessed values.

**Matching Terraform / intentional CLI-only boundary:** The provider reads the same named profile. If the pinned provider SDK does not support login_session, use the documented credential_process bridge in AUTH.md; never export secrets into .tfvars.

**Practice:** Choose A or B with your administrator. Record only the profile name and authentication method.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Read account-visible Availability Zones (`az`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Two different zone names/IDs in your account are needed for the planned design. AZ name-to-physical-zone mapping can differ by account; AZ IDs identify the physical zone consistently. available is a zone state, not proof of spare capacity for your chosen instance type.

**Bash (macOS/Linux):**
```bash
aws ec2 describe-availability-zones --profile "$AwsProfile" --region "$Region" --filters Name=zone-type,Values=availability-zone --query 'AvailabilityZones[].{Name:ZoneName,ID:ZoneId,State:State,OptIn:OptInStatus}' --output table --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws ec2 describe-availability-zones --profile "$AwsProfile" --region "$Region" --filters Name=zone-type,Values=availability-zone --query 'AvailabilityZones[].{Name:ZoneName,ID:ZoneId,State:State,OptIn:OptInStatus}' --output table --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --filters uses EC2 server-side Name/Values syntax; zone-type excludes Local/Wavelength Zones for this exercise. --query maps returned fields into readable columns.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: us-west-2a | usw2-az2 | available | opt-in-not-required. Your mapping may differ.
```

**Verify before continuing:** Confirm at least two normal available AZs. Record name and ID pairs, not just a and b suffixes.

**Likely errors / safe response:** UnauthorizedOperation: ask for ec2:DescribeAvailabilityZones. Invalid endpoint: check your approved Region and connectivity.

**Matching Terraform / intentional CLI-only boundary:** data.aws_availability_zones.available, names and zone_ids; do not invent a physical-zone mapping.

**Practice:** Write two actual AZ name/ID pairs from your account; label any example pair as illustrative.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Read EKS support and add-on compatibility (`versions`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Choose a version on build day, check support end and add-ons. No EKS version is hard-coded as currently available in r4. Existing cluster/add-on readout is separate and optional: no cluster is required to list supported versions.

**Bash (macOS/Linux):**
```bash
aws eks describe-cluster-versions --profile "$AwsProfile" --region "$Region" --version-status STANDARD_SUPPORT --query 'clusterVersions[].{Version:clusterVersion,Status:versionStatus,EndStandard:endOfStandardSupportDate}' --output table --no-cli-pager
K8sVersion="REPLACE_FROM_VERSION_READOUT"
aws eks describe-addon-versions --profile "$AwsProfile" --region "$Region" --kubernetes-version "$K8sVersion" --addon-name vpc-cni --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws eks describe-cluster-versions --profile "$AwsProfile" --region "$Region" --version-status STANDARD_SUPPORT --query 'clusterVersions[].{Version:clusterVersion,Status:versionStatus,EndStandard:endOfStandardSupportDate}' --output table --no-cli-pager
$K8sVersion = "REPLACE_FROM_VERSION_READOUT"
aws eks describe-addon-versions --profile "$AwsProfile" --region "$Region" --kubernetes-version "$K8sVersion" --addon-name vpc-cni --output json --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --version-status STANDARD_SUPPORT filters supported standard versions using the current non-deprecated field. --kubernetes-version is a version you choose after reading the first output; --addon-name selects vpc-cni. Inspect compatibilities/defaultVersion/architecture rather than sorting add-on version strings lexically.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE SHAPE: {"clusterVersions":[{"clusterVersion":"1.xx","versionStatus":"STANDARD_SUPPORT","endOfStandardSupportDate":"EXAMPLE_DATE"}]}; version/date are not real choices.
```

**Verify before continuing:** Record chosen supported version and VPC CNI compatible version privately; repeat describe-addon-versions for coredns and kube-proxy by replacing only addon-name.

**Likely errors / safe response:** Unknown operation/option: update AWS CLI v2. Empty compatibility list: do not guess a version; inspect Region/version/add-on and ask admin.

**Matching Terraform / intentional CLI-only boundary:** Verified pinned provider supports data.aws_eks_cluster_versions.standard with version_status STANDARD_SUPPORT and full lifecycle fields. Optional data.aws_eks_addon_version.vpc_cni reads one latest compatible version only when kubernetes_version is supplied; CLI still exposes full compatibility/architecture detail.

**Practice:** Read the support dates and compatible add-on architectures. Do not create a cluster just to discover versions.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Read offered types and ENI limits (`offerings`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. An offered type is sold in a zone; the readout does not guarantee On-Demand/Spot capacity, quota, architecture suitability or a successful launch. No instances are launched here. Prefix delegation/custom networking use different calculations.

**Bash (macOS/Linux):**
```bash
InstanceType="m6i.large"
aws ec2 describe-instance-type-offerings --profile "$AwsProfile" --region "$Region" --location-type availability-zone --filters "Name=instance-type,Values=$InstanceType" --output table --no-cli-pager
aws ec2 describe-instance-types --profile "$AwsProfile" --region "$Region" --instance-types "$InstanceType" --query 'InstanceTypes[].{Type:InstanceType,ENIs:NetworkInfo.MaximumNetworkInterfaces,IPv4PerENI:NetworkInfo.Ipv4AddressesPerInterface}' --output table --no-cli-pager
```

**PowerShell (Windows):**
```powershell
$InstanceType = "m6i.large"
aws ec2 describe-instance-type-offerings --profile "$AwsProfile" --region "$Region" --location-type availability-zone --filters "Name=instance-type,Values=$InstanceType" --output table --no-cli-pager
aws ec2 describe-instance-types --profile "$AwsProfile" --region "$Region" --instance-types "$InstanceType" --query 'InstanceTypes[].{Type:InstanceType,ENIs:NetworkInfo.MaximumNetworkInterfaces,IPv4PerENI:NetworkInfo.Ipv4AddressesPerInterface}' --output table --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --location-type availability-zone returns offers by AZ name; --instance-types selects a specific instance family/size. MaximumNetworkInterfaces is not the number of ENIs currently attached to a node.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE m6i.large: ENIs=3, IPv4PerENI=10. Classic secondary-IP formula gives 3*(10-1)+2=29 maxPods before applicable bootstrap caps/settings.
```

**Verify before continuing:** Compare offering Locations with your two chosen AZs; compare limits with the worksheet, and do not apply the classic formula to prefix mode.

**Likely errors / safe response:** Empty offering list: pick another approved type/Region with the administrator, not an unapproved larger expensive type. Unknown instance: check spelling and Region.

**Matching Terraform / intentional CLI-only boundary:** data.aws_ec2_instance_type and aws_ec2_instance_type_offerings; exact supported maximum_network_interfaces/maximum_ipv4_addresses_per_interface attributes.

**Practice:** Calculate classic maxPods from your actual type limits; explain why IP capacity still does not prove node scheduling capacity.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Run data-only Terraform reads in your account (`tf-read`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Choose the CLI view or this declarative read view. They may both read safely because neither manages resources here. A future billable Terraform create path must be an ALTERNATIVE owner, never a second owner of the CLI infrastructure.

**Bash (macOS/Linux):**
```bash
cp terraform/read-only/terraform.tfvars.example terraform/read-only/terraform.tfvars
# EDIT that copy in your text editor: profile, Region and intended account ID
terraform -chdir=terraform/read-only init -backend=false -input=false
terraform -chdir=terraform/read-only fmt -check
terraform -chdir=terraform/read-only validate
terraform -chdir=terraform/read-only plan -input=false -out=observations.tfplan
# Optional: reviewed data-only plan writes LOCAL state; no AWS resources created
terraform -chdir=terraform/read-only apply -input=false observations.tfplan
terraform -chdir=terraform/read-only output -json
```

**PowerShell (Windows):**
```powershell
Copy-Item terraform/read-only/terraform.tfvars.example terraform/read-only/terraform.tfvars
# EDIT that copy in your text editor: profile, Region and intended account ID
terraform -chdir=terraform/read-only init -backend=false -input=false
terraform -chdir=terraform/read-only fmt -check
terraform -chdir=terraform/read-only validate
terraform -chdir=terraform/read-only plan -input=false -out=observations.tfplan
# Optional reviewed data-only plan writes LOCAL state; no AWS resources created
terraform -chdir=terraform/read-only apply -input=false observations.tfplan
terraform -chdir=terraform/read-only output -json
```

**Flags / values:** Unlike the offline project, plan and optional apply authenticate and issue AWS read API calls. init downloads hashicorp/aws 6.21.0 and writes .terraform.lock.hcl; that lock is safe to commit, not .terraform/ or state. Set allowed_account_ids through expected_account_id before plan. -backend=false is not a universal no-state/no-network mode.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE PLAN SHAPE: data.aws_caller_identity.current: Read complete; output identity.account_id matches YOUR expected account; availability_zones contains YOUR zone names/IDs. No real account plan was run by us.
```

**Verify before continuing:** Verify there are no resource/module/import blocks and no infrastructure actions in plan. Leave existing_subnet_ids=[] if none exists. Optional apply persists observations in local state; output reads it and may become stale until next reviewed refresh.

**Likely errors / safe response:** Unsupported login_session in provider: use AUTH.md credential_process bridge after aws login. Wrong account: provider rejects; fix selection, do not remove the guard. Missing profile placeholders fail before continuing.

**Matching Terraform / intentional CLI-only boundary:** Complete read-only provider/versions/variables/data/locals/output files included. CLI-only facts are explicitly mapped; no fake HCL effective-permissions, costs or free-IP attributes.

**Practice:** First finish the CLI identity/AZ/type reads, then compare only authorized data-only plan observations. Do not run authenticated plan on someone else's machine.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0043 · Optional: a budget alert, set up the safe way


#### Read a budget and its alert subscribers (`budget`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Budgets data/alerts can be delayed; a notification-only budget does not delete anything and does not impose a spending limit. Optional creation is isolated in OPTIONAL-BUDGET.md and requires deliberate approval. The monitoring budget is different from action-enabled budgets, whose pricing must be checked.

**Bash (macOS/Linux):**
```bash
aws budgets describe-budgets --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --output json --no-cli-pager
BudgetName="unit06a-learning-alert"
aws budgets describe-notifications-for-budget --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --budget-name "$BudgetName" --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws budgets describe-budgets --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --output json --no-cli-pager
$BudgetName = "unit06a-learning-alert"
aws budgets describe-notifications-for-budget --profile "$AwsProfile" --region us-east-1 --account-id "$ExpectedAccount" --budget-name "$BudgetName" --output json --no-cli-pager
```

**Flags / values:** AWS Budgets account ID is explicit; us-east-1 is the commercial-partition Budgets endpoint for these examples, not the deployment Region. Stop and use partition-specific documentation if using GovCloud/China. --budget-name must be an existing name you own or are authorized to inspect.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: BudgetLimit.Amount="10", Unit="USD"; notification threshold 80 percent ACTUAL. This is not a hard $10 cap.
```

**Verify before continuing:** Read the notifications and use describe-subscribers-for-notification as shown in OPTIONAL-BUDGET.md; verify delivery to your own address. Never publicly share subscriber output.

**Likely errors / safe response:** NotFoundException before optional creation is expected; no permission or email subscriber must be invented. AccessDenied: ask for budgets:ViewBudget.

**Matching Terraform / intentional CLI-only boundary:** CLI-only in this lesson; no aws_budgets_budget resource is included, preventing two owners. A future Terraform budget would require its own explicit ownership/state path.

**Practice:** Explain why receiving an alert at 80 percent does not stop spend at 100 percent.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0044 · Worksheet: decisions before Unit 6B


#### Set deliberate profile and Region (`settings`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. An account is the billing/security boundary. A Region is an AWS geography. A local profile is a name for authentication configuration, not an AWS account or permission grant.

**Bash (macOS/Linux):**
```bash
AwsProfile="REPLACE_WITH_YOUR_PROFILE"
Region="us-west-2"
ExpectedAccount="REPLACE_WITH_12_DIGITS"
export AWS_PAGER=""
export AWS_CLI_AUTO_PROMPT=off
aws configure list-profiles
aws configure list --profile "$AwsProfile"
```

**PowerShell (Windows):**
```powershell
$AwsProfile = "REPLACE_WITH_YOUR_PROFILE"
$Region = "us-west-2"
$ExpectedAccount = "REPLACE_WITH_12_DIGITS"
$env:AWS_PAGER = ""
$env:AWS_CLI_AUTO_PROMPT = "off"
aws configure list-profiles
aws configure list --profile "$AwsProfile"
```

**Flags / values:** Replace profile with an approved sandbox profile name, and ExpectedAccount with the approved 12-digit account ID obtained from your administrator/account menu, not simply whatever STS returns. us-west-2 is illustrative: choose your approved Region. Variables live only in this terminal. configure list shows masked credential values and where settings came from; do not share it publicly.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: profile eksclass-student (manual); region us-west-2 (config-file). No credentials are reproduced here.
```

**Verify before continuing:** Confirm the exact profile name in list-profiles; the explicit --region on later commands wins over environment/default profile Region.

**Likely errors / safe response:** Profile not found: create it using ONE authentication path. Never repair this by pasting permanent keys into course files.

**Matching Terraform / intentional CLI-only boundary:** read-only/variables.tf supplies aws_profile, aws_region, expected_account_id; allowed_account_ids rejects the wrong account.

**Practice:** Fill your profile, approved account and Region in a private worksheet. Do not publish that worksheet.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Calculate reserved space and test the small-subnet failure (`capacity`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. AWS reserves the first four and last IPv4 of every subnet. Reserve addresses for warm pools/upgrades/endpoints/load balancers, not just running Pods. Fifty percent headroom is a teaching policy, not an AWS mandatory subnet rule.

**Bash (macOS/Linux):**
```bash
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/20
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/24
```

**PowerShell (Windows):**
```powershell
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/20
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/24
```

**Flags / values:** All CIDRs are deliberate examples. --private chooses the subnet to calculate; no AWS calls. /20: 2^(32-20)-5=4091 usable; node reservation (2 steady+2 surge)*3 ENIs*10 IPv4=120; other reservations 4+4+8+1+6=23; total 143. /24 has 251 usable: 143/251 exceeds the illustrative 50 percent planning limit.

**Illustrative output, never current-account evidence:**
```text
OFFLINE EXAMPLE: /20 planned=143 remaining=3948 pass_50_percent_headroom=true; /24 planned=143 remaining=108 pass=false and exits STOP. The older legacy small fixture has DIFFERENT node inputs, so its 503 count is not this example.
```

**Verify before continuing:** Compare Terraform offline capacity_per_private_subnet output with the Python arithmetic. Read actual EC2 limits before changing instance type; prefix delegation needs contiguous prefixes and a different model.

**Likely errors / safe response:** CIDR has host bits set: supply the network boundary. Negative remaining or failed headroom: redesign, not override a guard. Neither calculator checks CPU/RAM/quotas or all production workloads.

**Matching Terraform / intentional CLI-only boundary:** offline/main.tf local CIDR/capacity calculations; actual type limits are read separately in the read-only project. No AWS resources or API access needed for arithmetic.

**Practice:** Calculate /20 and /24 by hand; explain that /24 fails the chosen headroom policy even though 143 is less than 251.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Read EKS support and add-on compatibility (`versions`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Choose a version on build day, check support end and add-ons. No EKS version is hard-coded as currently available in r4. Existing cluster/add-on readout is separate and optional: no cluster is required to list supported versions.

**Bash (macOS/Linux):**
```bash
aws eks describe-cluster-versions --profile "$AwsProfile" --region "$Region" --version-status STANDARD_SUPPORT --query 'clusterVersions[].{Version:clusterVersion,Status:versionStatus,EndStandard:endOfStandardSupportDate}' --output table --no-cli-pager
K8sVersion="REPLACE_FROM_VERSION_READOUT"
aws eks describe-addon-versions --profile "$AwsProfile" --region "$Region" --kubernetes-version "$K8sVersion" --addon-name vpc-cni --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws eks describe-cluster-versions --profile "$AwsProfile" --region "$Region" --version-status STANDARD_SUPPORT --query 'clusterVersions[].{Version:clusterVersion,Status:versionStatus,EndStandard:endOfStandardSupportDate}' --output table --no-cli-pager
$K8sVersion = "REPLACE_FROM_VERSION_READOUT"
aws eks describe-addon-versions --profile "$AwsProfile" --region "$Region" --kubernetes-version "$K8sVersion" --addon-name vpc-cni --output json --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --version-status STANDARD_SUPPORT filters supported standard versions using the current non-deprecated field. --kubernetes-version is a version you choose after reading the first output; --addon-name selects vpc-cni. Inspect compatibilities/defaultVersion/architecture rather than sorting add-on version strings lexically.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE SHAPE: {"clusterVersions":[{"clusterVersion":"1.xx","versionStatus":"STANDARD_SUPPORT","endOfStandardSupportDate":"EXAMPLE_DATE"}]}; version/date are not real choices.
```

**Verify before continuing:** Record chosen supported version and VPC CNI compatible version privately; repeat describe-addon-versions for coredns and kube-proxy by replacing only addon-name.

**Likely errors / safe response:** Unknown operation/option: update AWS CLI v2. Empty compatibility list: do not guess a version; inspect Region/version/add-on and ask admin.

**Matching Terraform / intentional CLI-only boundary:** Verified pinned provider supports data.aws_eks_cluster_versions.standard with version_status STANDARD_SUPPORT and full lifecycle fields. Optional data.aws_eks_addon_version.vpc_cni reads one latest compatible version only when kubernetes_version is supplied; CLI still exposes full compatibility/architecture detail.

**Practice:** Read the support dates and compatible add-on architectures. Do not create a cluster just to discover versions.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0045 · Troubleshooting


#### Verify read permissions without pretending to prove deployment rights (`permissions`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Read-only API success tests that exact read action only. Simulation has limitations: session policies, SCPs, resource policies, permission boundaries and missing condition context can alter real results. SCPs restrict member accounts including their root user; not management-account principals; service-linked roles are exempt. AdministratorAccess is not a bypass for member-account SCP restrictions.

**Bash (macOS/Linux):**
```bash
aws ec2 describe-availability-zones --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws eks describe-cluster-versions --profile "$AwsProfile" --region "$Region" --version-status STANDARD_SUPPORT --output json --no-cli-pager
# OPTIONAL administrator-assisted IAM policy simulation: replace with IAM role ARN, NOT STS session ARN
PolicySourceArn="REPLACE_WITH_IAM_ROLE_ARN"
aws iam simulate-principal-policy --profile "$AwsProfile" --region "$Region" --policy-source-arn "$PolicySourceArn" --action-names ec2:DescribeSubnets eks:DescribeClusterVersions --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
aws ec2 describe-availability-zones --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws eks describe-cluster-versions --profile "$AwsProfile" --region "$Region" --version-status STANDARD_SUPPORT --output json --no-cli-pager
# OPTIONAL administrator-assisted simulation; use the IAM role ARN, NOT an STS session ARN
$PolicySourceArn = "REPLACE_WITH_IAM_ROLE_ARN"
aws iam simulate-principal-policy --profile "$AwsProfile" --region "$Region" --policy-source-arn "$PolicySourceArn" --action-names ec2:DescribeSubnets eks:DescribeClusterVersions --output json --no-cli-pager
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --policy-source-arn selects an existing IAM role/user whose policies an authorized administrator can simulate; --action-names lists the API permissions being evaluated. iam:SimulatePrincipalPolicy is a separate permission and is optional here.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE simulation: EvalActionName=ec2:DescribeSubnets, EvalDecision=allowed. This is not a live deployment authorization certificate.
```

**Verify before continuing:** Keep an action-by-action permission ledger in PERMISSIONS.md. Unit 6B separately checks create/trust/PassRole permissions; this unit does not test by creating anything.

**Likely errors / safe response:** AccessDenied/UnauthorizedOperation: preserve action name/request ID privately and ask admin to inspect identity/boundary/session/SCP context. Do not switch to root or weaken policies.

**Matching Terraform / intentional CLI-only boundary:** No built-in Terraform evaluator proves effective IAM permissions. Data lookups test their API calls only; IAM simulation remains an optional CLI diagnostic.

**Practice:** Mark each read action pass/denied/not attempted. Explain why an allowed simulation can still fail in reality.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Inspect credential sources without revealing keys (`precedence`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. CLI and provider chains consider explicit configuration, environment and supported profile providers. Profile selection is not a promise that every inherited environment variable is ignored by every SDK. Never print env/printenv wholesale or aws configure export-credentials to the screen.

**Bash (macOS/Linux):**
```bash
python3 -c 'import os; print("\n".join(sorted(k for k in os.environ if k.startswith("AWS_"))))' || exit 1
aws configure list --profile "$AwsProfile"
# Only if stale manual environment keys are unintended in this shell:
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
```

**PowerShell (Windows):**
```powershell
Get-ChildItem Env:AWS_* | Select-Object -ExpandProperty Name
aws configure list --profile "$AwsProfile"
# Only if stale manual environment keys are unintended in this shell:
Remove-Item Env:AWS_ACCESS_KEY_ID,Env:AWS_SECRET_ACCESS_KEY,Env:AWS_SESSION_TOKEN,Env:AWS_SECURITY_TOKEN -ErrorAction SilentlyContinue
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
```

**Flags / values:** List environment variable NAMES only. unset/Remove-Item affect this terminal process, not stored profiles. Do not remove deliberate role/container/credential_process settings blindly. AWS_REGION outranks AWS_DEFAULT_REGION/profile Region; --region wins over both. A named --profile changes provider resolution behavior, so inspect configure list and verify STS rather than assuming a simplistic universal precedence diagram.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE NAMES ONLY: AWS_DEFAULT_REGION, AWS_PROFILE. No secret values.
```

**Verify before continuing:** Re-run configure list and STS after clearing ONLY unintended manual key variables. SDK/provider support and AWS CLI provider resolution are not identical.

**Likely errors / safe response:** Wrong account remains: confirm profile role/source_profile/SSO configuration with administrator; do not read cache/token files for troubleshooting.

**Matching Terraform / intentional CLI-only boundary:** Provider profile + allowed_account_ids give explicit selection and rejection, not a guarantee of permissions. Credentials never belong in Terraform files.

**Practice:** List names only and explain how you would detect a stale credential source without revealing it.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0046 · Practice: clean up, and keep what Unit 6B needs


#### Finish without deleting another owner's resources (`cleanup`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Keep private worksheet for Unit 6B; remove/discard local plan/state files only after confirming these exact isolated folders contain no managed resources. Never blind terraform destroy. Deleting local state is not cloud cleanup and must never be taught as cleanup for a managed-resource project.

**Bash (macOS/Linux):**
```bash
# Choose ONLY the logout matching the method you used:
aws logout --profile "$AwsProfile"
# IAM Identity Center alternative, affects all cached SSO sessions:
aws sso logout
# Local state inventory; no cloud deletion:
terraform -chdir=terraform/offline state list
terraform -chdir=terraform/read-only state list
```

**PowerShell (Windows):**
```powershell
# Choose ONLY the logout matching the method you used:
aws logout --profile "$AwsProfile"
# IAM Identity Center alternative, affects all cached SSO sessions:
aws sso logout
# Local state inventory; no cloud deletion:
terraform -chdir=terraform/offline state list
terraform -chdir=terraform/read-only state list
```

**Flags / values:** aws logout clears the selected console-login profile cache. aws sso logout clears cached SSO tokens/credentials across profiles, so coordinate if other work uses them. Logging out changes local authentication, not AWS resources. state list is local inventory only.

**Illustrative output, never current-account evidence:**
```text
EXPECTED: default path created no AWS resources to delete. Optional budget ownership is tracked separately; its delete command is in OPTIONAL-BUDGET.md, never run against an existing shared budget.
```

**Verify before continuing:** Use CLEANUP.md exact optional local file removal commands after closing Terraform. Keep versioned HCL and lock file. No resource should be deleted in AWS on the default Unit 6A path.

**Likely errors / safe response:** Do not delete a VPC/ENI/EIP discovered by inventory: it may belong to another team. If you created something outside this lesson, identify its owner and authorized cleanup plan first.

**Matching Terraform / intentional CLI-only boundary:** No managed AWS resource exists in these projects, so terraform destroy is unnecessary and intentionally not included. Future alternative Terraform builds require their own reviewed destroy/dependency procedure.

**Practice:** State exactly which files/optional budget you created; explain why logout does not stop cloud charges.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0047 · Unit summary


#### Read identity and stop on the wrong account (`identity`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Account must equal your approved account. An assumed-role ARN describes the temporary session, not an IAM role ARN you may put into simulate-principal-policy. STS identity does not prove permission to read EC2/EKS or create anything.

**Bash (macOS/Linux):**
```bash
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
ActualAccount=$(aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --query Account --output text --no-cli-pager) || exit 1
if [ "$ActualAccount" != "$ExpectedAccount" ]; then printf '%s
' 'STOP: wrong account'; exit 1; fi
```

**PowerShell (Windows):**
```powershell
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
$ActualAccount = aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --query Account --output text --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw "Identity request failed" }
if ($ActualAccount -ne $ExpectedAccount) { throw "STOP: wrong account" }
```

**Flags / values:** --profile selects your named local credentials; --region explicitly selects the regional endpoint (STS identity itself is account-wide); --output chooses JSON/table/text; --no-cli-pager prevents an interactive pager. --query Account extracts only the account field using JMESPath. Bash $? and PowerShell $LASTEXITCODE are native-process exit codes; PowerShell does not throw automatically on every aws failure.

**Illustrative output, never current-account evidence:**
```text
{"UserId":"EXAMPLE","Account":"111122223333","Arn":"arn:aws:sts::111122223333:assumed-role/LabRole/ExampleSession"} (ILLUSTRATIVE ONLY)
```

**Verify before continuing:** Compare Account manually AND execute the guard. STOP on an ARN ending :root: use an approved temporary non-root principal for daily work.

**Likely errors / safe response:** ExpiredToken/SSO token expired: sign in again to the intended profile. AccessDenied for another API is not fixed by STS succeeding.

**Matching Terraform / intentional CLI-only boundary:** data.aws_caller_identity.current and provider allowed_account_ids; no IAM policy is changed.

**Practice:** Compare Account and ARN; explain why identity success is not authorization for EKS.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Separate read-only observation from resource ownership (`ownership`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. One owner per resource: Unit 6B CLI creates its own named infrastructure; a future full Terraform build is an alternative owner in a separate namespace and state. These r4 Terraform projects only calculate/read and never adopt or delete Unit 6B resources.

**Bash (macOS/Linux):**
```bash
terraform -chdir=terraform/offline state list
terraform -chdir=terraform/read-only state list
```

**PowerShell (Windows):**
```powershell
terraform -chdir=terraform/offline state list
terraform -chdir=terraform/read-only state list
```

**Flags / values:** -chdir selects the exact local project folder before running the subcommand. state list reads existing local state only; before any apply, a no-state message is normal. It does not fetch the cloud inventory.

**Illustrative output, never current-account evidence:**
```text
ILLUSTRATIVE: offline has no managed resource entries; data-only state may contain data.aws_caller_identity.current after its optional apply.
```

**Verify before continuing:** Open the .tf files and verify no resource/module/import blocks. Separate offline/ and read-only/ directories mean separate state. Do not import Unit 6B CLI resources here.

**Likely errors / safe response:** No state file found is expected before apply. Never run terraform destroy as an unexplained cleanup shortcut or point these projects at another backend.

**Matching Terraform / intentional CLI-only boundary:** Data blocks observe; resource blocks would manage lifecycle. init does not create infrastructure; plan may call AWS APIs; data-only apply writes local state/outputs but creates no AWS resources.

**Practice:** Explain which tool owns each prospective Unit 6B resource and why this data-only project owns none.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


#### Finish without deleting another owner's resources (`cleanup`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Keep private worksheet for Unit 6B; remove/discard local plan/state files only after confirming these exact isolated folders contain no managed resources. Never blind terraform destroy. Deleting local state is not cloud cleanup and must never be taught as cleanup for a managed-resource project.

**Bash (macOS/Linux):**
```bash
# Choose ONLY the logout matching the method you used:
aws logout --profile "$AwsProfile"
# IAM Identity Center alternative, affects all cached SSO sessions:
aws sso logout
# Local state inventory; no cloud deletion:
terraform -chdir=terraform/offline state list
terraform -chdir=terraform/read-only state list
```

**PowerShell (Windows):**
```powershell
# Choose ONLY the logout matching the method you used:
aws logout --profile "$AwsProfile"
# IAM Identity Center alternative, affects all cached SSO sessions:
aws sso logout
# Local state inventory; no cloud deletion:
terraform -chdir=terraform/offline state list
terraform -chdir=terraform/read-only state list
```

**Flags / values:** aws logout clears the selected console-login profile cache. aws sso logout clears cached SSO tokens/credentials across profiles, so coordinate if other work uses them. Logging out changes local authentication, not AWS resources. state list is local inventory only.

**Illustrative output, never current-account evidence:**
```text
EXPECTED: default path created no AWS resources to delete. Optional budget ownership is tracked separately; its delete command is in OPTIONAL-BUDGET.md, never run against an existing shared budget.
```

**Verify before continuing:** Use CLEANUP.md exact optional local file removal commands after closing Terraform. Keep versioned HCL and lock file. No resource should be deleted in AWS on the default Unit 6A path.

**Likely errors / safe response:** Do not delete a VPC/ENI/EIP discovered by inventory: it may belong to another team. If you created something outside this lesson, identify its owner and authorized cleanup plan first.

**Matching Terraform / intentional CLI-only boundary:** No managed AWS resource exists in these projects, so terraform destroy is unnecessary and intentionally not included. Future alternative Terraform builds require their own reviewed destroy/dependency procedure.

**Practice:** State exactly which files/optional budget you created; explain why logout does not stop cloud charges.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


### s0048 · Thank you


#### Your computer, your account, no creation yet (`orientation`)

**Where / before typing:** Terminal on YOUR computer, current folder `unit06a/`. Open Terminal on macOS/Linux and choose Bash; open PowerShell on Windows. These are commands for YOUR computer, not an EC2 shell, a Kubernetes Pod or the AWS console search bar. Extract the practice ZIP to a private folder first.

**Bash (macOS/Linux):**
```bash
pwd
ls
aws --version
```

**PowerShell (Windows):**
```powershell
Get-Location
Get-ChildItem
aws --version
```

**Flags / values:** pwd/Get-Location show your current local folder; ls/Get-ChildItem list its files. No AWS account request is made by --version.

**Illustrative output, never current-account evidence:**
```text
EXAMPLE: .../unit06a ; commands, scripts, terraform ; aws-cli/2.39.6
```

**Verify before continuing:** Your folder contains README.md, FOLLOW-ALONG.md, commands/, scripts/ and terraform/. Do not copy a leading dollar or prompt symbol.

**Likely errors / safe response:** Command not found: install the tool using INSTALL.md, close and reopen the terminal so PATH refreshes.

**Matching Terraform / intentional CLI-only boundary:** Terraform introduction and two complete projects are provided; CLI and Terraform read the same facts without taking ownership of infrastructure.

**Practice:** Identify your shell and current folder; open README.md in a text editor.

**Cleanup / ownership:** These default commands create no AWS infrastructure. They may write local login/configuration/state files when explicitly noted. Follow CLEANUP.md; never delete discovered resources. Budget creation is optional and separately documented.


## Complete Terraform files — no omitted blocks
Read each complete file here and in the matching project directory. Explanations are followed by init/fmt/validate/plan workflow in the matching lecture sections above.


### `terraform/offline/main.tf`
```hcl
# Pure calculations: no provider, AWS credentials or managed resources.
locals {
  subnets = {
    public_a  = cidrsubnet(var.vpc_cidr, 8, 0)
    public_b  = cidrsubnet(var.vpc_cidr, 8, 1)
    private_a = cidrsubnet(var.vpc_cidr, 4, 1)
    private_b = cidrsubnet(var.vpc_cidr, 4, 2)
  }
  usable_private_ipv4 = pow(2, 32 - 20) - 5
  other_reservations = {
    cluster_enis         = 4
    upgrade_cluster_enis = 4
    alb_headroom         = 8
    nlb_address          = 1
    endpoint_enis        = 6
  }
  node_ipv4_reservation = (var.nodes_per_az + var.surge_per_az) * var.enis_per_node * var.ipv4_per_eni
  planned_ipv4          = local.node_ipv4_reservation + sum(values(local.other_reservations))
  remaining_ipv4        = local.usable_private_ipv4 - local.planned_ipv4
  classic_max_pods      = var.enis_per_node * (var.ipv4_per_eni - 1) + 2
  planned_percent       = 100 * local.planned_ipv4 / local.usable_private_ipv4
}
```


### `terraform/offline/outputs.tf`
```hcl
output "address_plan" {
  description = "Illustrative design only; no subnets created."
  value = {
    vpc_cidr     = var.vpc_cidr
    service_cidr = var.service_cidr
    subnets      = local.subnets
  }
}
output "capacity_per_private_subnet" {
  value = {
    usable_ipv4        = local.usable_private_ipv4
    node_reservation   = local.node_ipv4_reservation
    other_reservations = local.other_reservations
    total_planned      = local.planned_ipv4
    remaining          = local.remaining_ipv4
    planned_percent    = local.planned_percent
    below_course_50pct = local.planned_percent <= 50
    classic_max_pods   = local.classic_max_pods
    mode               = "Illustrative secondary-IP mode; not a scheduler guarantee or prefix-delegation formula"
  }
}
```


### `terraform/offline/terraform.tfvars.example`
```hcl
vpc_cidr       = "10.42.0.0/16"
service_cidr   = "172.20.0.0/16"
nodes_per_az   = 2
surge_per_az   = 2
enis_per_node = 3
ipv4_per_eni  = 10
```


### `terraform/offline/variables.tf`
```hcl
variable "vpc_cidr" {
  description = "Illustrative IPv4 /16; use only an approved non-overlapping RFC1918 range."
  type        = string
  default     = "10.42.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr)) && can(regex("/16$", var.vpc_cidr))
    error_message = "This teaching calculator requires a valid IPv4 /16."
  }
}
variable "service_cidr" {
  description = "Illustrative Kubernetes virtual Service range, not a VPC subnet. Verify overlap with scripts/network_checks.py."
  type        = string
  default     = "172.20.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.service_cidr))
    error_message = "Supply a valid IPv4 CIDR, then check EKS size/private-range/overlap requirements with Python."
  }
}
variable "nodes_per_az" {
  description = "Maximum steady nodes in each AZ, not desired cluster total."
  type        = number
  default     = 2
  validation {
    condition     = var.nodes_per_az >= 0 && floor(var.nodes_per_az) == var.nodes_per_az
    error_message = "Use a non-negative integer."
  }
}
variable "surge_per_az" {
  description = "Additional nodes during replacement, illustrative reservation."
  type        = number
  default     = 2
  validation {
    condition     = var.surge_per_az >= 0 && floor(var.surge_per_az) == var.surge_per_az
    error_message = "Use a non-negative integer."
  }
}
variable "enis_per_node" {
  description = "Illustrative m6i.large limit; read actual EC2 type limits before using a different type."
  type        = number
  default     = 3
  validation {
    condition     = var.enis_per_node >= 1 && floor(var.enis_per_node) == var.enis_per_node
    error_message = "Use a positive integer."
  }
}
variable "ipv4_per_eni" {
  description = "Includes primary IPv4; this calculator models secondary-IP mode, NOT prefix delegation."
  type        = number
  default     = 10
  validation {
    condition     = var.ipv4_per_eni >= 1 && floor(var.ipv4_per_eni) == var.ipv4_per_eni
    error_message = "Use a positive integer."
  }
}
```


### `terraform/offline/versions.tf`
```hcl
terraform {
  required_version = ">= 1.13.5, < 2.0.0"
}
```


### `terraform/read-only/load-balancer-observations.tf`
```hcl
# Optional EXISTING load balancer chain; default empty sets make no such reads.
variable "existing_load_balancer_arns" {
  type    = set(string)
  default = []
}
variable "existing_listener_arns" {
  type    = set(string)
  default = []
}
variable "existing_listener_rule_arns" {
  type    = set(string)
  default = []
}
variable "existing_target_group_arns" {
  type    = set(string)
  default = []
}
data "aws_lb" "existing" {
  for_each = var.existing_load_balancer_arns
  arn      = each.value
}
data "aws_lb_listener" "existing" {
  for_each = var.existing_listener_arns
  arn      = each.value
}
data "aws_lb_listener_rule" "existing" {
  for_each = var.existing_listener_rule_arns
  arn      = each.value
}
data "aws_lb_target_group" "existing" {
  for_each = var.existing_target_group_arns
  arn      = each.value
}
output "load_balancer_observations" {
  value = { for arn, l in data.aws_lb.existing : arn => { dns = l.dns_name, type = l.load_balancer_type, internal = l.internal, vpc = l.vpc_id, subnets = l.subnets, security_groups = l.security_groups } }
}
output "listener_observations" {
  value = { for arn, l in data.aws_lb_listener.existing : arn => { load_balancer = l.load_balancer_arn, protocol = l.protocol, port = l.port, default_action_types = [for a in l.default_action : a.type] } }
}
output "listener_rule_observations" {
  value = { for arn, r in data.aws_lb_listener_rule.existing : arn => { listener = r.listener_arn, priority = r.priority, conditions = r.condition, action_types = [for a in r.action : a.type] } }
}
output "target_group_observations" {
  value       = { for arn, t in data.aws_lb_target_group.existing : arn => { protocol = t.protocol, port = t.port, target_type = t.target_type, vpc = t.vpc_id, health_check = t.health_check } }
  description = "Health-check policy, NOT live per-target health. Use CLI describe-target-health for actual target state/reason. State/plan and listener auth configuration remain private."
}
```


### `terraform/read-only/main.tf`
```hcl
# Data-only configuration. There is deliberately NO resource block.
provider "aws" {
  profile             = var.aws_profile
  region              = var.aws_region
  allowed_account_ids = [var.expected_account_id]
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}
data "aws_eks_cluster_versions" "standard" {
  version_status = "STANDARD_SUPPORT"
}
data "aws_eks_addon_version" "vpc_cni" {
  count              = var.kubernetes_version == null ? 0 : 1
  addon_name         = "vpc-cni"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}
data "aws_ec2_instance_type" "node" {
  instance_type = var.instance_type
}
data "aws_ec2_instance_type_offerings" "node" {
  location_type = "availability-zone"
  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
}
data "aws_subnet" "existing" {
  for_each = var.existing_subnet_ids
  id       = each.value
}
locals {
  # EC2 limits, not a Kubernetes scheduler promise.
  classic_max_pods = data.aws_ec2_instance_type.node.maximum_network_interfaces * (data.aws_ec2_instance_type.node.maximum_ipv4_addresses_per_interface - 1) + 2
}
```


### `terraform/read-only/observations.tf`
```hcl
# OPTIONAL existing infrastructure observations. Empty sets skip these lookups.
# IDs/names must come from authorized CLI readouts in this account and Region.
variable "existing_vpc_ids" {
  type    = set(string)
  default = []
}
variable "existing_route_table_ids" {
  type    = set(string)
  default = []
}
variable "existing_nat_gateway_ids" {
  type    = set(string)
  default = []
}
variable "existing_internet_gateway_ids" {
  type    = set(string)
  default = []
}
variable "existing_cluster_names" {
  type    = set(string)
  default = []
}
data "aws_vpc" "existing" {
  for_each = var.existing_vpc_ids
  id       = each.value
}
data "aws_route_table" "existing" {
  for_each       = var.existing_route_table_ids
  route_table_id = each.value
}
data "aws_nat_gateway" "existing" {
  for_each = var.existing_nat_gateway_ids
  id       = each.value
}
data "aws_internet_gateway" "existing" {
  for_each            = var.existing_internet_gateway_ids
  internet_gateway_id = each.value
}
data "aws_eks_cluster" "existing" {
  for_each = var.existing_cluster_names
  name     = each.value
}
output "vpc_observations" {
  value = { for id, v in data.aws_vpc.existing : id => {
    cidr             = v.cidr_block
    all_cidrs        = v.cidr_block_associations
    dns_support      = v.enable_dns_support
    dns_hostnames    = v.enable_dns_hostnames
    main_route_table = v.main_route_table_id
  } }
}
output "route_table_observations" {
  description = "Real associated subnet/table/route observations; CLI is still needed for per-route State and packet LPM reasoning."
  value = { for id, r in data.aws_route_table.existing : id => {
    vpc          = r.vpc_id
    associations = r.associations
    routes       = r.routes
  } }
}
output "nat_observations" {
  value = { for id, n in data.aws_nat_gateway.existing : id => {
    state        = n.state
    vpc          = n.vpc_id
    subnet       = n.subnet_id
    connectivity = n.connectivity_type
    private_ip   = n.private_ip
    public_ip    = n.public_ip
  } }
}
output "internet_gateway_observations" {
  value = { for id, g in data.aws_internet_gateway.existing : id => {
    attachments = g.attachments
  } }
}
output "cluster_observations" {
  description = "Private account metadata; no authentication token or credentials are requested."
  value = { for name, c in data.aws_eks_cluster.existing : name => {
    api_endpoint    = c.endpoint
    authentication  = c.access_config
    version         = c.version
    status          = c.status
    vpc             = c.vpc_config
    service_network = c.kubernetes_network_config
    support         = c.upgrade_policy
    enabled_logs    = c.enabled_cluster_log_types
  } }
}
```


### `terraform/read-only/outputs.tf`
```hcl
output "identity" {
  description = "Account/ARN metadata; do not publish your local state or outputs."
  value = {
    account_id = data.aws_caller_identity.current.account_id
    arn        = data.aws_caller_identity.current.arn
    region     = data.aws_region.current.region
  }
}
output "eks_standard_versions" {
  value = data.aws_eks_cluster_versions.standard.cluster_versions
}
output "vpc_cni_latest_compatible_version" {
  description = "Optional latest compatible version, NOT a guarantee of suitability for your architecture/configuration."
  value       = try(data.aws_eks_addon_version.vpc_cni[0].version, null)
}
output "availability_zones" {
  value = {
    names = data.aws_availability_zones.available.names
    ids   = data.aws_availability_zones.available.zone_ids
  }
}
output "instance_type_observation" {
  value = {
    type             = var.instance_type
    offered_in       = data.aws_ec2_instance_type_offerings.node.locations
    maximum_enis     = data.aws_ec2_instance_type.node.maximum_network_interfaces
    ipv4_per_eni     = data.aws_ec2_instance_type.node.maximum_ipv4_addresses_per_interface
    classic_max_pods = local.classic_max_pods
    warning          = "Offered does NOT prove spare capacity; no launch was attempted. Secondary-IP mode only."
  }
}
output "existing_subnets" {
  value = {
    for id, subnet in data.aws_subnet.existing : id => {
      cidr      = subnet.cidr_block
      az        = subnet.availability_zone
      vpc       = subnet.vpc_id
      free_ipv4 = subnet.available_ip_address_count
    }
  }
  description = "Point-in-time subnet address observations, not reserved future capacity."
}
```


### `terraform/read-only/terraform.tfvars.example`
```hcl
# Replace REPLACE values before plan. Example account number below is NOT yours.
aws_profile         = "REPLACE_WITH_YOUR_PROFILE"
aws_region          = "us-west-2"
expected_account_id = "000000000000"
instance_type       = "m6i.large"
kubernetes_version  = null
existing_subnet_ids  = []

# OPTIONAL selected existing objects only; [] is valid before Unit 6B.
existing_vpc_ids              = []
existing_route_table_ids      = []
existing_nat_gateway_ids      = []
existing_internet_gateway_ids = []
existing_cluster_names        = []

# Optional existing ALB chain, selected from authorized readouts only.
existing_load_balancer_arns = []
existing_listener_arns = []
existing_listener_rule_arns = []
existing_target_group_arns = []
```


### `terraform/read-only/variables.tf`
```hcl
variable "aws_profile" {
  description = "Name of YOUR existing temporary-credential profile, never an access key."
  type        = string
  validation {
    condition     = length(trimspace(var.aws_profile)) > 0
    error_message = "Supply your named profile."
  }
}
variable "aws_region" {
  description = "Your approved AWS Region, for example us-west-2."
  type        = string
}
variable "expected_account_id" {
  description = "Your approved twelve-digit AWS account ID. Provider refuses a different account."
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_account_id))
    error_message = "Supply exactly twelve digits."
  }
}
variable "instance_type" {
  description = "Read characteristics/offering only, never launch."
  type        = string
  default     = "m6i.large"
}
variable "kubernetes_version" {
  description = "Optional exact version chosen from your standard-support readout. null skips the add-on query."
  type        = string
  default     = null
}
variable "existing_subnet_ids" {
  description = "Optional existing subnet IDs in this account/Region. Leave empty before Unit 6B."
  type        = set(string)
  default     = []
}
```


### `terraform/read-only/versions.tf`
```hcl
terraform {
  required_version = ">= 1.13.5, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.21.0"
    }
  }
}
```


# API endpoint and Service range — understand before using the terms

Start in the extracted unit06a folder on YOUR computer. This guide supplements the visible narrated foundation scenes, not a replacement for them. All address/URL/output examples below are illustrative, not your account. Do not create anything just to populate an observation.

## API and two endpoints
API = Application Programming Interface: software makes a defined request and receives a response. An endpoint is the network address accepting those requests. AWS EKS management API (`aws eks describe-cluster`, AWS Terraform provider) manages cloud cluster metadata. The returned HTTPS Kubernetes API server endpoint is used by kubectl / Kubernetes providers to inspect or change cluster objects. It is NOT your public application URL.

DNS resolves the name; TCP443 and routing/security controls permit a connection; TLS validates the server and encrypts it; authentication identifies the caller; authorization permits or refuses an operation. IAM = AWS Identity and Access Management. An EKS access entry can connect that principal to cluster access; Kubernetes RBAC = role-based access control for object operations. Existing legacy access mappings may also be in use; do not change them in Unit6A. Public/private means reachability, not anonymous permission. Public CIDRs govern public access; cluster security group controls the private API path. A security group is an attached stateful traffic allow-list. Private endpoint needs VPC/connected-network reachability and DNS. Do not open all sources or disable TLS verification to pass a tutorial.

A get-Pods request is a read of permitted API objects; apply writes desired state and controllers reconcile it. The API server is not proxying ordinary application traffic for every request.

## Service, virtual address and range
A Pod is a running application unit whose IP can change when replaced. A Service provides a stable application front door while selected backend Pods change. For an ordinary ClusterIP Service, DNS resolves its Service name to a virtual ClusterIP. CIDR = Classless Inter-Domain Routing; /16 fixes the first16 address bits and describes a pool, not a port or interface.

Illustrative VPC10.42.0.0/16 holds node/Pod subnet addresses in the ordinary VPC-CNI mode. Separate Service pool172.20.0.0/16 holds virtual Service addresses, NOT ENI allocations. In this worked example, Service172.20.50.10 port80 forwards to ready Pod10.42.16.21 targetPort8080. `port` is client-facing; `targetPort` is where the backend application listens. DNS web.shop.svc.cluster.local → virtual172.20.50.10:80 → node Service rules select a ready endpoint and translate/forward → Pod10.42.16.21:8080 → corresponding return connection/reverse translation where applicable. kube-proxy or the installed datapath equivalent implements this, not a VPC NAT gateway, static Service-CIDR VPC route, physical ClusterIP ENI, or control-plane proxy per web request. Readiness is not an absolute application-health guarantee.

Headless (`clusterIP: None`) has no allocated ClusterIP; ExternalName returns a DNS alias. Not every Service gets such an IP. Keep VPC, Pod, on-prem, peered and planned connected ranges nonoverlapping and consult IPAM. EKS custom IPv4 Service CIDR must be private RFC1918, /12 through /24, nonoverlapping with VPC CIDRs, and is fixed at creation. Changing an existing Terraform cluster's creation-only Service-range setting can replace the cluster. NEVER change an existing cluster simply to match an example. Unit6A only observes/calculates. Unit6B's separate complete creation root will set `kubernetes_network_config { service_ipv4_cidr = var.service_ipv4_cidr }` at FIRST creation, with an immutable/replacement warning; this is not a fragment to paste into this read-only project.

## Full read commands — choose your shell
First complete AUTH.md: select approved AwsProfile/Region/ExpectedAccount, prove non-root intended identity, and obtain both AWS describe permission AND already-authorized Kubernetes reads. No existing cluster? Stop and use the labelled offline example. Do not create access entries, clusters, Services or workloads here.

Bash assignment and AWS reads:
```bash
# OPTIONAL: only an existing authorized cluster; otherwise skip all these reads.
ClusterName="REPLACE_FROM_AUTHORIZED_EXISTING_CLUSTER_LIST"
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.endpoint' --output text --no-cli-pager
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.resourcesVpcConfig.{Public:endpointPublicAccess,Private:endpointPrivateAccess,PublicCIDRs:publicAccessCidrs,ClusterSG:clusterSecurityGroupId}' --output json --no-cli-pager
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.kubernetesNetworkConfig.serviceIpv4Cidr' --output text --no-cli-pager
# Only with existing Kubernetes read authorization; this writes a SEPARATE LOCAL kubeconfig.
aws eks update-kubeconfig --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --kubeconfig ./private-observation-kubeconfig.yaml --alias unit06a-observe
```
PowerShell alternative (same AWS operation arguments):
```powershell
# OPTIONAL: only an existing authorized cluster; otherwise skip all these reads.
$ClusterName = "REPLACE_FROM_AUTHORIZED_EXISTING_CLUSTER_LIST"
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.endpoint' --output text --no-cli-pager
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.resourcesVpcConfig.{Public:endpointPublicAccess,Private:endpointPrivateAccess,PublicCIDRs:publicAccessCidrs,ClusterSG:clusterSecurityGroupId}' --output json --no-cli-pager
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.kubernetesNetworkConfig.serviceIpv4Cidr' --output text --no-cli-pager
# Only with existing Kubernetes read authorization; this writes a SEPARATE LOCAL kubeconfig.
aws eks update-kubeconfig --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --kubeconfig ./private-observation-kubeconfig.yaml --alias unit06a-observe
```

`update-kubeconfig` is an OPTIONAL LOCAL FILE WRITE, not a cloud mutation or access grant. It may fail on missing AWS describe permission. Keep the dedicated file private; commands never overwrite your default kubeconfig. Replacing our file path with a shared configuration is not needed. After every native command in PowerShell inspect `$LASTEXITCODE`; stop on nonzero. Do not continue from a failed identity/update step. Use only the selected context/file below. Do not use `--raw` or print complete credential configuration.

Shared Bash/PowerShell reads:
```bash
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe config view --minify --output 'jsonpath={.clusters[0].cluster.server}'
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe get pods --all-namespaces --output wide
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe get services --all-namespaces --output wide
```
Choose actual names, not an invented example:
```bash
Namespace="REPLACE_FROM_AUTHORIZED_SERVICE_LIST"
ServiceName="REPLACE_FROM_AUTHORIZED_SERVICE_LIST"
```
```powershell
$Namespace = "REPLACE_FROM_AUTHORIZED_SERVICE_LIST"
$ServiceName = "REPLACE_FROM_AUTHORIZED_SERVICE_LIST"
```
Shared read-only object checks:
```bash
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe --namespace "$Namespace" describe service "$ServiceName"
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe --namespace "$Namespace" get service "$ServiceName" --output 'jsonpath={.spec.clusterIP}'
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe --namespace "$Namespace" get endpointslices --selector "kubernetes.io/service-name=$ServiceName" --output yaml
```

Examples only: endpoint `https://EXAMPLE.invalid` is NOT a working cluster. Pods table could show `shop web-abc 1/1 Running ... 10.42.16.21 node-a`; Service could show `shop web ClusterIP 172.20.50.10 <none> 80/TCP`; description could show `Port:80/TCP`, `TargetPort:8080/TCP`; EndpointSlice could contain `addresses:[10.42.16.21]`, `conditions: {ready:true}`, `ports:[{port:8080,protocol:TCP}]`. Record YOUR readout. Match ServiceIP membership to the actual Service pool and the endpoint IP/port to the actual backend. Kubernetes RBAC Forbidden is different from AWS AccessDenied, expired login, TLS certificate failure, DNS failure or a network timeout. Ask for the narrow approved read; do not bypass validation or give yourself administrator access.

CLI/API boundary: the pinned AWS provider observes `data.aws_eks_cluster.existing` with endpoint and kubernetes_network_config outputs. It does not query Kubernetes Services/EndpointSlices through fake AWS data fields. Those are Kubernetes API reads; a future Kubernetes provider is a separate configured/authorized client, not introduced into this data-only AWS root. No apply/create in these commands.

Safe cleanup: no cloud object was created by this procedure. Remove ONLY your separately created local kubeconfig file when no longer needed (Bash `rm ./private-observation-kubeconfig.yaml`; PowerShell `Remove-Item ./private-observation-kubeconfig.yaml`) after confirming it is the file this procedure wrote. Do not remove default/shared kubeconfig, delete discovered Services or change endpoint configuration. Logging out does not delete cloud resources.

Existing course repository: https://github.com/ccaiccie/awseks — use supplied local Unit6A package; exact matching practice URL pending authorized publication/verification.

## ALB causal security and placement carry-forward
ALB = Application Load Balancer, an HTTP/HTTPS frontend. Internet-facing vs internal describes how clients reach the FRONTEND, not whether backends are secure. Verify DNS/routing and listener permission on the ALB security group, then independently permit the ALB security group at applicable backend target/node/Pod ENI security groups on BOTH the application and configured health-check ports. IP targets do not bypass applicable Pod/ENI SGs. Instance mode reaches NodePort and then the Pod-forwarding path. At least8 AVAILABLE addresses in EACH selected ALB subnet and /27 or larger are capacity prerequisites, not exactly8 allocated ENIs/IPs. Check the actual chosen subnets: internet-facing frontend placement normally public, internal frontend private per design. The offline private-subnet example assumes internal-ALB planning headroom; do not blindly treat that8 as current consumption in every private subnet. Deep deployment remains Unit12. Full existing-object CLI and optional pinned-provider ALB/listener/rule/target-group data are supplied; live per-target health remains CLI-only.

## Why aws-auth, and when NOT to use it
A ConfigMap is a Kubernetes object for named configuration. Deprecated legacy aws-auth maps IAM principal identifiers to Kubernetes usernames/groups, historically including nodes; it is NOT credentials and not blanket administrator permission. EKS access entries are recommended. Actual authenticationMode CONFIG_MAP/API_AND_CONFIG_MAP/API determines supported paths. RBAC or configured EKS access policies authorize operations. API-only need not have aws-auth. Read only when authorized/relevant; never create/edit it here.
```bash
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.accessConfig' --output json --no-cli-pager
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe --namespace kube-system get configmap aws-auth --output yaml
```
The first command reads AWS metadata. Only in a relevant legacy mode and with existing Kubernetes permission run the second. Output is private principal/group metadata, not a working sample to apply. NotFound may be normal; Forbidden is authorization failure. Do not paste roles into a map to fix a tutorial.

## Actual ServiceIP membership — choose ONE shell
These capture ACTUAL successful readouts in the explicitly selected context, then compare locally; no creation or apply. Complete script is supplied. Stop on failure, and inspect Service type for headless/ExternalName skips.
```bash
ServiceCidr=$(aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.kubernetesNetworkConfig.serviceIpv4Cidr' --output text --no-cli-pager) || exit 1
ServiceIp=$(kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe --namespace "$Namespace" get service "$ServiceName" --output 'jsonpath={.spec.clusterIP}') || exit 1
python3 scripts/service_membership.py "$ServiceCidr" "$ServiceIp"
```
```powershell
$ServiceCidr = aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name "$ClusterName" --query 'cluster.kubernetesNetworkConfig.serviceIpv4Cidr' --output text --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw "STOP: Service pool read failed" }
$ServiceIp = kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe --namespace "$Namespace" get service "$ServiceName" --output 'jsonpath={.spec.clusterIP}'
if ($LASTEXITCODE -ne 0) { throw "STOP: Service read failed" }
py -3 scripts/service_membership.py "$ServiceCidr" "$ServiceIp"
if ($LASTEXITCODE -ne 0) { throw "STOP: Service membership check failed" }
```

The genuine pinned data.aws_eks_cluster.existing output also includes endpoint and access_config (authentication mode and creator-bootstrap flag). These observe the same existing settings as AWS describe-cluster; they do not grant access or change bootstrap permissions.
