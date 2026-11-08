# Temporary sign-in and local profile selection

No sign-in was performed by the lesson builder. You perform these steps in your own terminal/browser. Ask your administrator for: approved sandbox 12-digit account ID, approved Region, role/profile method, MFA, and the read permissions in PERMISSIONS.md. Root is not a daily-work path. SCPs constrain member-account root too; management-account principals and service-linked roles are distinct exceptions. Do not create keys to bypass a permission denial.

## Path A — console credentials / aws login
Requires AWS CLI >=2.32.0, permission to sign into the console, and **SignInLocalDevelopmentAccess** on the IAM user/role/group. This grants local-development sign-in, not all EC2/EKS permissions. Your administrator supplies it; this lesson does not attach policies. Use your chosen named profile (example name below is local, not a secret):
```bash
aws login --profile eksclass-student --region us-west-2
aws sts get-caller-identity --profile eksclass-student --region us-west-2 --output json --no-cli-pager
```
Same two commands work in PowerShell. The login opens your browser. Choose the intended non-root account/role and complete MFA yourself. Never share the authorization code. Session lasts up to the principal session duration (maximum 12 hours) and needs re-login when expired. Recheck identity after every change.

## Path B instead — IAM Identity Center
Use your organization-provided values at each interactive prompt; do not guess a start URL, SSO Region, account or role.
```bash
aws configure sso --profile eksclass-student
aws sso login --profile eksclass-student
aws sts get-caller-identity --profile eksclass-student --region us-west-2 --output json --no-cli-pager
```
Same commands work in PowerShell. configure sso writes profile settings locally. sso login authenticates. Choose A OR B. Your actual profile/Region may differ; substitute consistently.

## Credentials versus Region precedence
Official order: command-line configuration options, environment, assume-role, web-identity role, IAM Identity Center, shared credentials file, custom process, config file, container credentials, EC2 instance profile. This is an overview, not permission to pass raw secrets on a command line. Explicit --profile behavior can disable the CLI environment credential provider; SDK/provider chains may differ. Prove the actual selected identity with STS and inspect masked `aws configure list --profile eksclass-student`. `--region` wins over AWS_REGION, AWS_DEFAULT_REGION and profile Region. `--profile` is a local selection, not a permission grant.

List only AWS environment variable NAMES, as shown in the lecture. Do not print credential values or inspect token/cache files. Clear only stale manually set key variables if unintended; never blindly remove container/role configuration used by an approved environment.

## Provider compatibility if aws login works but Terraform does not
Do not assume all SDK/provider releases support `login_session`. If the pinned provider cannot load the console-login profile, the AWS-documented bridge is a second local profile whose process command asks the AWS CLI for credentials. This is configuration text to add through your approved AWS profile editor, NOT a command to print credentials:
```ini
[profile eksclass-tf-read]
credential_process = aws configure export-credentials --profile eksclass-student --format process
region = us-west-2
```
Keep the existing logged-in eksclass-student profile unchanged. Set `aws_profile = "eksclass-tf-read"` in the private Terraform tfvars. The provider invokes this command; do NOT run it interactively, copy its output, commit it, or put returned keys in HCL. If you used Identity Center with a supported SSO profile, use that profile directly instead. Provider credential loading must still pass the expected-account guard. This bridge is a documented public configuration mechanism, not manual cache access.

## Exit
```bash
aws logout --profile eksclass-student
```
Only for console-login path. IAM Identity Center alternative: `aws sso logout` (all cached SSO sessions; consider other work). Neither deletes cloud resources or stops bills.
