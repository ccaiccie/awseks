# Complete C5 revised lecture → practice → Terraform map

Public baseline follow-along: https://github.com/ccaiccie/awseks/blob/189a683034edae19820ced02d2f11915b1fa0d81/units/unit06a/FOLLOW-ALONG.md
Public baseline map: https://github.com/ccaiccie/awseks/blob/189a683034edae19820ced02d2f11915b1fa0d81/units/unit06a/C4-LECTURE-PRACTICE-MAP.md
Public PR #4: https://github.com/ccaiccie/awseks/pull/4 (not merged; local amendment is links/provenance only).

Legacy map filename retained for existing README links. All scene instructions below are regenerated from CURRENT C5 source. Commands run on YOUR computer in extracted unit06a/. Examples are NOT current-account output. Choose your OS alternative. A contiguous scene page is part of its full source block; never omit prerequisite lines.

## r4t0000 — Welcome
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0001 — Your computer, your account, no creation yet
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
pwd
ls
```
Why / effect: Use your local terminal, not the AWS console search bar.
Example / verify: Confirm README.md, commands/, scripts/ and terraform/ are in this extracted folder.
On failure: If missing, navigate to the extracted unit06a folder before typing relative paths.

## r4t0002 — Your computer, your account, no creation yet
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
Get-Location
Get-ChildItem
```
Why / effect: Use your local terminal, not the AWS console search bar.
Example / verify: Confirm README.md, commands/, scripts/ and terraform/ are in this extracted folder.
On failure: If missing, navigate to the extracted unit06a folder before typing relative paths.

## r4t0003 — Your computer, your account, no creation yet
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws --version
```
Why / effect: LOCAL executable version check; no AWS account request or folder inventory.
Example / verify: EXAMPLE ONLY: aws-cli/2.39.6. Read YOUR installed version; use CLI v2.
On failure: Command not found: install approved AWS CLI for your OS, reopen terminal and check PATH.

## r4c0001 — Complete LOCAL verification helper · 1/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```python
#!/usr/bin/env python3
"""Local integrity check only: no AWS, install or hidden download."""
import hashlib,pathlib,re,sys
mode,name,checks=sys.argv[1:]
p=pathlib.Path(name)
actual=hashlib.sha256(p.read_bytes()).hexdigest()
text=pathlib.Path(checks).read_text().strip()
if mode=="sha256-list":
```
Why / effect: Read the full supplied local validation source before a caller uses it. This helper cannot install software.
Example / verify: Failure must return nonzero; every visible caller explicitly stops.
On failure: Never bypass a failed integrity/publisher check.
Complete block source: INSTALL.md#fence-1; visible contiguous lines [1, 8]

## r4c0002 — Complete LOCAL verification helper · 2/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```python
    rows=[x.split() for x in text.splitlines()]
    matches=[a for a,b in rows if b.lstrip("*")==p.name]
    if len(matches)!=1:raise SystemExit("STOP: no unique checksum entry")
    expected=matches[0]
elif mode=="sha256":expected=text
else:raise SystemExit("STOP: unknown verification mode")
if not re.fullmatch("[0-9a-fA-F]{64}",expected):
    raise SystemExit("STOP: malformed checksum")
```
Why / effect: Read the full supplied local validation source before a caller uses it. This helper cannot install software.
Example / verify: Failure must return nonzero; every visible caller explicitly stops.
On failure: Never bypass a failed integrity/publisher check.
Complete block source: INSTALL.md#fence-1; visible contiguous lines [9, 16]

## r4c0003 — Complete LOCAL verification helper · 3/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```python
if actual.lower()!=expected.lower():
    raise SystemExit("STOP: checksum mismatch")
print("Publisher HTTPS checksum matches; not independent signature proof")
```
Why / effect: Read the full supplied local validation source before a caller uses it. This helper cannot install software.
Example / verify: Failure must return nonzero; every visible caller explicitly stops.
On failure: Never bypass a failed integrity/publisher check.
Complete block source: INSTALL.md#fence-1; visible contiguous lines [17, 19]

## r4c0004 — Complete LOCAL verification helper
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```python
#!/usr/bin/env python3
"""Local macOS publisher check after pkgutil signature verification succeeds."""
import re,sys
text=sys.stdin.read()
if not re.search(r"Developer ID Installer: Amazon Web Services, Inc[.]? \([A-Z0-9]+\)",text):
    raise SystemExit("STOP: expected Amazon installer publisher not present")
print("Expected Amazon publisher identified; Gatekeeper must still succeed")
```
Why / effect: Read the full supplied local validation source before a caller uses it. This helper cannot install software.
Example / verify: Failure must return nonzero; every visible caller explicitly stops.
On failure: Never bypass a failed integrity/publisher check.
Complete block source: INSTALL.md#fence-2; visible contiguous lines [1, 7]

## r4c0005 — Linux only: authorized Ubuntu/Debian prerequisites
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
sudo apt-get update || exit 1
sudo apt-get install -y ca-certificates curl unzip python3 gnupg || exit 1
```
Why / effect: Package installation changes YOUR computer; organizational approval required. Other distributions use their supported package manager instead.
Example / verify: No AWS request. This block is Ubuntu/Debian only; never run both platform alternatives.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-3; visible contiguous lines [1, 2]

## r4c0006 — Linux: select your actual CPU, then download · 1/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
PracticeDir=$(pwd) || exit 1
[ -f "$PracticeDir/README.md" ] || exit 1
case "$(uname -m)" in
  x86_64) AwsArch="x86_64"; TfArch="amd64" ;;
  aarch64|arm64) AwsArch="aarch64"; TfArch="arm64" ;;
  *) printf '%s\n' 'STOP: unsupported CPU'; exit 1 ;;
esac
mkdir -p "$HOME/Downloads/unit06a-tools" || exit 1
```
Why / effect: Start in the actual extracted unit06a folder. uname identifies CPU; BOTH actual architecture variables are set before URL construction.
Example / verify: Expected local downloads only. x86_64 maps AWS x86_64/Terraform amd64; ARM maps aarch64/arm64. No blank architecture fallback.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-4; visible contiguous lines [1, 8]

## r4c0007 — Linux: select your actual CPU, then download · 2/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
cd "$HOME/Downloads/unit06a-tools" || exit 1
AwsBase="https://awscli.amazonaws.com"
AwsZip="awscli-exe-linux-${AwsArch}.zip"
curl --fail --location "$AwsBase/$AwsZip" --output awscliv2.zip || exit 1
curl --fail --location "$AwsBase/$AwsZip.sig" --output awscliv2.sig || exit 1
```
Why / effect: Start in the actual extracted unit06a folder. uname identifies CPU; BOTH actual architecture variables are set before URL construction.
Example / verify: Expected local downloads only. x86_64 maps AWS x86_64/Terraform amd64; ARM maps aarch64/arm64. No blank architecture fallback.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-4; visible contiguous lines [9, 13]

## r4c0008 — Linux: verify publisher BEFORE extraction · 1/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
KeyFile="$PracticeDir/examples/awscli-public-key.asc"
KeyInfo=$(gpg --show-keys --with-colons "$KeyFile") || exit 1
Fingerprint=$(printf '%s\n' "$KeyInfo" | awk -F: '$1=="fpr" {print $10;exit}')
ExpectedFingerprint="FB5DB77FD5C118B80511ADA8A6310ACC4672475C"
[ "$Fingerprint" = "$ExpectedFingerprint" ] || exit 1
gpg --import "$KeyFile" || exit 1
gpg --verify awscliv2.sig awscliv2.zip || exit 1
unzip awscliv2.zip || exit 1
```
Why / effect: Full official PUBLIC key is supplied; verify its fingerprint against AWS docs. A downloaded .sig is not itself verification. Failed signature explicitly prevents unzip/install.
Example / verify: Good signature plus published fingerprint; aws-cli/2.x after success. Missing GPG means ask IT, never skip verification.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-5; visible contiguous lines [1, 8]

## r4c0009 — Linux: verify publisher BEFORE extraction · 2/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
mkdir -p "$HOME/.local/bin" || exit 1
./aws/install --install-dir "$HOME/.local/aws-cli" \
  --bin-dir "$HOME/.local/bin" || exit 1
export PATH="$HOME/.local/bin:$PATH"
aws --version || exit 1
cd "$PracticeDir" || exit 1
```
Why / effect: Full official PUBLIC key is supplied; verify its fingerprint against AWS docs. A downloaded .sig is not itself verification. Failed signature explicitly prevents unzip/install.
Example / verify: Good signature plus published fingerprint; aws-cli/2.x after success. Missing GPG means ask IT, never skip verification.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-5; visible contiguous lines [9, 14]

## r4c0010 — Linux: complete Terraform checksum/install path · 1/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
PracticeDir=$(pwd) || exit 1
[ -f "$PracticeDir/README.md" ] || exit 1
case "$(uname -m)" in
  x86_64) TfArch="amd64" ;;
  aarch64|arm64) TfArch="arm64" ;;
  *) printf '%s\n' 'STOP: unsupported CPU'; exit 1 ;;
esac
TfVersion="1.13.5"
```
Why / effect: The complete selected CPU/OS archive name and checksum-list check precede any extraction. A real mismatch must stop before unzip, independent of set-e.
Example / verify: Terraform1.13.5 and Python3. HTTPS checksum match is not independent PGP verification; HashiCorp signed-checksum guidance remains in references.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-6; visible contiguous lines [1, 8]

## r4c0011 — Linux: complete Terraform checksum/install path · 2/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
TfFile="terraform_${TfVersion}_linux_${TfArch}.zip"
TfBase="https://releases.hashicorp.com/terraform/$TfVersion"
curl --fail --location "$TfBase/$TfFile" --output "$TfFile" || exit 1
curl --fail --location "$TfBase/terraform_${TfVersion}_SHA256SUMS" \
  --output terraform_SHA256SUMS || exit 1
python3 "$PracticeDir/scripts/verify_download.py" \
  sha256-list "$TfFile" terraform_SHA256SUMS || exit 1
unzip "$TfFile" terraform || exit 1
```
Why / effect: The complete selected CPU/OS archive name and checksum-list check precede any extraction. A real mismatch must stop before unzip, independent of set-e.
Example / verify: Terraform1.13.5 and Python3. HTTPS checksum match is not independent PGP verification; HashiCorp signed-checksum guidance remains in references.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-6; visible contiguous lines [9, 16]

## r4c0012 — Linux: complete Terraform checksum/install path · 3/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
mkdir -p "$HOME/.local/bin" || exit 1
install -m 0755 terraform "$HOME/.local/bin/terraform" || exit 1
export PATH="$HOME/.local/bin:$PATH"
terraform version || exit 1
python3 --version || exit 1
cd "$PracticeDir" || exit 1
```
Why / effect: The complete selected CPU/OS archive name and checksum-list check precede any extraction. A real mismatch must stop before unzip, independent of set-e.
Example / verify: Terraform1.13.5 and Python3. HTTPS checksum match is not independent PGP verification; HashiCorp signed-checksum guidance remains in references.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-6; visible contiguous lines [17, 22]

## r4c0013 — macOS: complete Terraform checksum/install path · 1/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
PracticeDir=$(pwd) || exit 1
[ -f "$PracticeDir/README.md" ] || exit 1
case "$(uname -m)" in
  x86_64) TfArch="amd64" ;;
  arm64) TfArch="arm64" ;;
  *) printf '%s\n' 'STOP: unsupported CPU'; exit 1 ;;
esac
mkdir -p "$HOME/Downloads/unit06a-tools" || exit 1
```
Why / effect: The complete selected CPU/OS archive name and checksum-list check precede any extraction. A real mismatch must stop before unzip, independent of set-e.
Example / verify: Terraform1.13.5 and Python3. HTTPS checksum match is not independent PGP verification; HashiCorp signed-checksum guidance remains in references.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-7; visible contiguous lines [1, 8]

## r4c0014 — macOS: complete Terraform checksum/install path · 2/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
cd "$HOME/Downloads/unit06a-tools" || exit 1
TfVersion="1.13.5"
TfFile="terraform_${TfVersion}_darwin_${TfArch}.zip"
TfBase="https://releases.hashicorp.com/terraform/$TfVersion"
curl --fail --location "$TfBase/$TfFile" --output "$TfFile" || exit 1
curl --fail --location "$TfBase/terraform_${TfVersion}_SHA256SUMS" \
  --output terraform_SHA256SUMS || exit 1
python3 "$PracticeDir/scripts/verify_download.py" \
```
Why / effect: The complete selected CPU/OS archive name and checksum-list check precede any extraction. A real mismatch must stop before unzip, independent of set-e.
Example / verify: Terraform1.13.5 and Python3. HTTPS checksum match is not independent PGP verification; HashiCorp signed-checksum guidance remains in references.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-7; visible contiguous lines [9, 16]

## r4c0015 — macOS: complete Terraform checksum/install path · 3/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
  sha256-list "$TfFile" terraform_SHA256SUMS || exit 1
unzip "$TfFile" terraform || exit 1
mkdir -p "$HOME/.local/bin" || exit 1
install -m 0755 terraform "$HOME/.local/bin/terraform" || exit 1
export PATH="$HOME/.local/bin:$PATH"
terraform version || exit 1
python3 --version || exit 1
cd "$PracticeDir" || exit 1
```
Why / effect: The complete selected CPU/OS archive name and checksum-list check precede any extraction. A real mismatch must stop before unzip, independent of set-e.
Example / verify: Terraform1.13.5 and Python3. HTTPS checksum match is not independent PGP verification; HashiCorp signed-checksum guidance remains in references.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-7; visible contiguous lines [17, 24]

## r4c0016 — macOS: verify package before opening Installer · 1/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
PracticeDir=$(pwd) || exit 1
[ -f "$PracticeDir/README.md" ] || exit 1
mkdir -p "$HOME/Downloads/unit06a-tools" || exit 1
cd "$HOME/Downloads/unit06a-tools" || exit 1
curl --fail --location https://awscli.amazonaws.com/AWSCLIV2.pkg \
  --output AWSCLIV2.pkg || exit 1
SignatureInfo=$(pkgutil --check-signature AWSCLIV2.pkg) || exit 1
printf '%s\n' "$SignatureInfo" | \
```
Why / effect: Native package signature AND Gatekeeper assessment must succeed before opening Installer; inspect Amazon publisher against AWS docs. Do not disable Gatekeeper.
Example / verify: Complete the normal approved installer, reopen Terminal/Bash and run aws --version. Mac commands are not Linux commands.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-8; visible contiguous lines [1, 8]

## r4c0017 — macOS: verify package before opening Installer · 2/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
  python3 "$PracticeDir/scripts/verify_macos_publisher.py" || exit 1
spctl --assess --type install AWSCLIV2.pkg || exit 1
# Signature, Amazon publisher and Gatekeeper must ALL pass before opening.
open AWSCLIV2.pkg || exit 1
cd "$PracticeDir" || exit 1
```
Why / effect: Native package signature AND Gatekeeper assessment must succeed before opening Installer; inspect Amazon publisher against AWS docs. Do not disable Gatekeeper.
Example / verify: Complete the normal approved installer, reopen Terminal/Bash and run aws --version. Mac commands are not Linux commands.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-8; visible contiguous lines [9, 13]

## r4c0018 — Windows x64 PowerShell7: publisher gate · 1/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
$ErrorActionPreference = "Stop"
$PracticeDir = (Get-Location).Path
if (-not (Test-Path "$PracticeDir/README.md")) { throw 'STOP: start in practice folder' }
New-Item -ItemType Directory -Force "$HOME/Downloads/unit06a-tools" | Out-Null
Set-Location "$HOME/Downloads/unit06a-tools"
Invoke-WebRequest https://awscli.amazonaws.com/AWSCLIV2.msi -OutFile AWSCLIV2.msi
$Signature = Get-AuthenticodeSignature .\AWSCLIV2.msi
$Publishers = @('Amazon Web Services, Inc.', 'Amazon.com Services LLC', 'Amazon.com, Inc.')
```
Why / effect: Invoke-WebRequest errors terminate; Valid signature alone is not enough: publisher must match approved Amazon identities. Check installer exit,3010 requests restart.
Example / verify: No AWS resource request. Reopen PowerShell for PATH; install approved Python3 normally if absent, then verify py -3 --version.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-9; visible contiguous lines [1, 8]

## r4c0019 — Windows x64 PowerShell7: publisher gate · 2/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
$Known = $Publishers | Where-Object { $Signature.SignerCertificate.Subject.Contains($_) }
if ($Signature.Status -ne 'Valid' -or -not $Known) { throw 'STOP: publisher/signature' }
$Process = Start-Process msiexec.exe -ArgumentList '/i AWSCLIV2.msi' -Wait -PassThru
if ($Process.ExitCode -notin @(0,3010)) { throw 'STOP: MSI installation failed' }
Set-Location $PracticeDir
```
Why / effect: Invoke-WebRequest errors terminate; Valid signature alone is not enough: publisher must match approved Amazon identities. Check installer exit,3010 requests restart.
Example / verify: No AWS resource request. Reopen PowerShell for PATH; install approved Python3 normally if absent, then verify py -3 --version.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-9; visible contiguous lines [9, 13]

## r4c0020 — Windows: complete Terraform portable install · 1/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
$ErrorActionPreference = "Stop"
$PracticeDir = (Get-Location).Path
if (-not (Test-Path "$PracticeDir/README.md")) { throw 'STOP: start in practice folder' }
$TfVersion = "1.13.5"
$TfFile = "terraform_${TfVersion}_windows_amd64.zip"
$TfBase = "https://releases.hashicorp.com/terraform/$TfVersion"
Invoke-WebRequest "$TfBase/$TfFile" -OutFile $TfFile
Invoke-WebRequest "$TfBase/terraform_${TfVersion}_SHA256SUMS" -OutFile terraform_SHA256SUMS
```
Why / effect: Windows uses amd64 portable ZIP; exact checksum check must succeed before Expand-Archive. Current session PATH only; never overwrite unrelated binaries.
Example / verify: Terraform1.13.5. Missing Python launcher or wrong path must stop; use approved Python installer, never bypass verification.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-10; visible contiguous lines [1, 8]

## r4c0021 — Windows: complete Terraform portable install · 2/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
py -3 "$PracticeDir/scripts/verify_download.py" sha256-list $TfFile terraform_SHA256SUMS
if ($LASTEXITCODE -ne 0) { throw 'STOP: checksum failed; no expansion' }
$TfBin = "$HOME/AppData/Local/unit06a-bin"
New-Item -ItemType Directory -Force $TfBin | Out-Null
Expand-Archive $TfFile -DestinationPath $TfBin
$env:PATH = "$TfBin;$env:PATH"
terraform version
if ($LASTEXITCODE -ne 0) { throw 'STOP: Terraform check failed' }
```
Why / effect: Windows uses amd64 portable ZIP; exact checksum check must succeed before Expand-Archive. Current session PATH only; never overwrite unrelated binaries.
Example / verify: Terraform1.13.5. Missing Python launcher or wrong path must stop; use approved Python installer, never bypass verification.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-10; visible contiguous lines [9, 16]

## r4c0022 — Windows: complete Terraform portable install · 3/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
Set-Location $PracticeDir
```
Why / effect: Windows uses amd64 portable ZIP; exact checksum check must succeed before Expand-Archive. Current session PATH only; never overwrite unrelated binaries.
Example / verify: Terraform1.13.5. Missing Python launcher or wrong path must stop; use approved Python installer, never bypass verification.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-10; visible contiguous lines [17, 17]

## r4c0023 — Linux: optional local kubectl preparation · 1/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
PracticeDir=$(pwd) || exit 1
[ -f "$PracticeDir/README.md" ] || exit 1
mkdir -p "$HOME/.local/bin" || exit 1
export PATH="$HOME/.local/bin:$PATH"
KubeVersion="REPLACE_WITH_RELEASED_COMPATIBLE_vVERSION"
[[ "$KubeVersion" =~ ^v1\.[0-9]+\.[0-9]+$ ]] || exit 1
case "$(uname -m)" in
  x86_64) KubeArch="amd64" ;;
```
Why / effect: Fill an actual released client version within one minor of the reviewed server. Full OS/CPU URL and checksum gate shown; Unit6A requires no cluster.
Example / verify: Local client version only. Do not assume latest is compatible; checksum/download failure prevents install.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-11; visible contiguous lines [1, 8]

## r4c0024 — Linux: optional local kubectl preparation · 2/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
  aarch64|arm64) KubeArch="arm64" ;;
  *) exit 1 ;;
esac
KubeBase="https://dl.k8s.io/release/$KubeVersion/bin/linux/$KubeArch"
curl --fail --location "$KubeBase/kubectl" --output kubectl || exit 1
curl --fail --location "$KubeBase/kubectl.sha256" --output kubectl.sha256 || exit 1
python3 "$PracticeDir/scripts/verify_download.py" \
  sha256 kubectl kubectl.sha256 || exit 1
```
Why / effect: Fill an actual released client version within one minor of the reviewed server. Full OS/CPU URL and checksum gate shown; Unit6A requires no cluster.
Example / verify: Local client version only. Do not assume latest is compatible; checksum/download failure prevents install.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-11; visible contiguous lines [9, 16]

## r4c0025 — Linux: optional local kubectl preparation · 3/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
install -m 0755 kubectl "$HOME/.local/bin/kubectl" || exit 1
kubectl version --client --output=yaml || exit 1
```
Why / effect: Fill an actual released client version within one minor of the reviewed server. Full OS/CPU URL and checksum gate shown; Unit6A requires no cluster.
Example / verify: Local client version only. Do not assume latest is compatible; checksum/download failure prevents install.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-11; visible contiguous lines [17, 18]

## r4c0026 — macOS: optional local kubectl preparation · 1/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
PracticeDir=$(pwd) || exit 1
[ -f "$PracticeDir/README.md" ] || exit 1
mkdir -p "$HOME/.local/bin" || exit 1
export PATH="$HOME/.local/bin:$PATH"
KubeVersion="REPLACE_WITH_RELEASED_COMPATIBLE_vVERSION"
[[ "$KubeVersion" =~ ^v1\.[0-9]+\.[0-9]+$ ]] || exit 1
case "$(uname -m)" in
  x86_64) KubeArch="amd64" ;;
```
Why / effect: Fill an actual released client version within one minor of the reviewed server. Full OS/CPU URL and checksum gate shown; Unit6A requires no cluster.
Example / verify: Local client version only. Do not assume latest is compatible; checksum/download failure prevents install.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-12; visible contiguous lines [1, 8]

## r4c0027 — macOS: optional local kubectl preparation · 2/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
  aarch64|arm64) KubeArch="arm64" ;;
  *) exit 1 ;;
esac
KubeBase="https://dl.k8s.io/release/$KubeVersion/bin/darwin/$KubeArch"
curl --fail --location "$KubeBase/kubectl" --output kubectl || exit 1
curl --fail --location "$KubeBase/kubectl.sha256" --output kubectl.sha256 || exit 1
python3 "$PracticeDir/scripts/verify_download.py" \
  sha256 kubectl kubectl.sha256 || exit 1
```
Why / effect: Fill an actual released client version within one minor of the reviewed server. Full OS/CPU URL and checksum gate shown; Unit6A requires no cluster.
Example / verify: Local client version only. Do not assume latest is compatible; checksum/download failure prevents install.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-12; visible contiguous lines [9, 16]

## r4c0028 — macOS: optional local kubectl preparation · 3/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
install -m 0755 kubectl "$HOME/.local/bin/kubectl" || exit 1
kubectl version --client --output=yaml || exit 1
```
Why / effect: Fill an actual released client version within one minor of the reviewed server. Full OS/CPU URL and checksum gate shown; Unit6A requires no cluster.
Example / verify: Local client version only. Do not assume latest is compatible; checksum/download failure prevents install.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-12; visible contiguous lines [17, 18]

## r4c0029 — Windows: optional local kubectl preparation · 1/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
$ErrorActionPreference = "Stop"
$PracticeDir = (Get-Location).Path
$TfBin = "$HOME/AppData/Local/unit06a-bin"
New-Item -ItemType Directory -Force $TfBin | Out-Null
$env:PATH = "$TfBin;$env:PATH"
$KubeVersion = "REPLACE_WITH_RELEASED_COMPATIBLE_vVERSION"
if ($KubeVersion -notmatch '^v1\.[0-9]+\.[0-9]+$') { throw 'STOP: fill actual version' }
$KubeBase = "https://dl.k8s.io/release/$KubeVersion/bin/windows/amd64"
```
Why / effect: Same checksum logic, Windows executable and PowerShell explicit native failure check. Preserve full path/flags, no inline secret material.
Example / verify: Local client version only; not Kubernetes reachability or permission.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-13; visible contiguous lines [1, 8]

## r4c0030 — Windows: optional local kubectl preparation · 2/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
Invoke-WebRequest "$KubeBase/kubectl.exe" -OutFile kubectl.exe
Invoke-WebRequest "$KubeBase/kubectl.exe.sha256" -OutFile kubectl.exe.sha256
py -3 "$PracticeDir/scripts/verify_download.py" sha256 kubectl.exe kubectl.exe.sha256
if ($LASTEXITCODE -ne 0) { throw 'STOP: checksum failed; no move/install' }
Move-Item kubectl.exe "$TfBin/kubectl.exe" -ErrorAction Stop
kubectl version --client --output=yaml
if ($LASTEXITCODE -ne 0) { throw 'STOP: client check failed' }
```
Why / effect: Same checksum logic, Windows executable and PowerShell explicit native failure check. Preserve full path/flags, no inline secret material.
Example / verify: Local client version only; not Kubernetes reachability or permission.
On failure: STOP on any download, verification or native failure. Do not run following extraction/install, disable TLS or bypass OS protections.
Complete block source: INSTALL.md#fence-13; visible contiguous lines [9, 15]

## r4t0019 — Return to the extracted practice folder
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
cd "$HOME/Downloads/unit06a"
pwd
ls
```
Why / effect: Example path only: replace with YOUR actual extracted unit06a folder.
Example / verify: pwd and ls must show README.md, scripts/ and terraform/.
On failure: No such directory or missing files: locate the extracted ZIP folder; do not continue in the installer folder.

## r4t0020 — Return to the extracted practice folder
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
Set-Location "$HOME/Downloads/unit06a"
Get-Location
Get-ChildItem
```
Why / effect: Example path only: replace with YOUR actual extracted unit06a folder.
Example / verify: Get-Location and Get-ChildItem must show README.md, scripts/ and terraform/.
On failure: Missing folder or files: correct the path before continuing. Installing a tool did not extract the student ZIP.

## r4t0021 — API and endpoint — define the words first
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0022 — Two different APIs, two different jobs
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0023 — Reaching an API is not permission to use it
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0024 — API request and response — after the definitions
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0025 — Public and private endpoints — what changes
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0026 — Why aws-auth exists — and why not every cluster needs it
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0027 — Service — a stable application front door
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0028 — Service range and CIDR — separate from VPC addresses
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0029 — port versus targetPort — before tracing traffic
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0030 — Service flow · request toward the ready Pod
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4c-service-return — Service flow · the separate return path
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0031 — Choose once, check overlap, never rewrite an existing cluster
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0032 — Terraform before the first command
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0033 — State, plan and apply are different
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0034 — Read tool versions, not cluster state
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws --version
```
Why / effect: LOCAL executable version check; no AWS account request or folder inventory.
Example / verify: EXAMPLE ONLY: aws-cli/2.39.6. Read YOUR installed version; use CLI v2.
On failure: Command not found: install approved AWS CLI for your OS, reopen terminal and check PATH.

## r4t0035 — Read tool versions, not cluster state
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
terraform version
python3 --version
kubectl version --client --output=yaml
```
Why / effect: All version checks are local; kubectl --client does not contact Kubernetes.
Example / verify: CLI v2; Terraform 1.13.5 tested; Python 3; match kubectl to later cluster within one minor.
On failure: Command not found: install approved tool, reopen terminal or fix approved user PATH.

## r4t0036 — Read tool versions, not cluster state
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
terraform version
py -3 --version
kubectl version --client --output=yaml
```
Why / effect: All version checks are local; kubectl --client does not contact Kubernetes.
Example / verify: CLI v2; Terraform 1.13.5 tested; Python 3; match kubectl to later cluster within one minor.
On failure: Command not found: install approved tool, reopen terminal or fix approved user PATH.

## r4t0037 — Set deliberate profile and Region
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
AwsProfile="REPLACE_WITH_YOUR_PROFILE"
Region="us-west-2"
ExpectedAccount="REPLACE_WITH_12_DIGITS"
export AWS_PAGER=""
export AWS_CLI_AUTO_PROMPT=off
```
Why / effect: Replace profile/account; choose your approved Region. These variables belong to this terminal.
Example / verify: EXAMPLE: profile=eksclass-student; region=us-west-2. Source columns show where these masked settings came from.
On failure: Profile not found: configure the approved temporary sign-in method; never paste keys into files.

## r4t0038 — Set deliberate profile and Region
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$AwsProfile = "REPLACE_WITH_YOUR_PROFILE"
$Region = "us-west-2"
$ExpectedAccount = "REPLACE_WITH_12_DIGITS"
$env:AWS_PAGER = ""
$env:AWS_CLI_AUTO_PROMPT = "off"
```
Why / effect: Replace profile/account; choose your approved Region. These variables belong to this terminal.
Example / verify: EXAMPLE: profile=eksclass-student; region=us-west-2. Source columns show where these masked settings came from.
On failure: Profile not found: configure the approved temporary sign-in method; never paste keys into files.

## r4t0039 — Set deliberate profile and Region
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws configure list-profiles
```
Why / effect: List local configured profile NAMES; this does not authenticate or query AWS.
Example / verify: LOCAL profile names, one per line, for example eksclass-student; NO credential-source columns.
On failure: Profile not found: configure the approved temporary sign-in method; never paste keys into files.

## r4t0040 — Set deliberate profile and Region
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws configure list --profile "$AwsProfile"
```
Why / effect: LOCAL masked configuration/source inspection, not an environment-name listing.
Example / verify: Masked Value / Type / Location rows for profile, access_key, secret_key and region; inspect YOUR source, then prove identity with STS.
On failure: Profile not found: configure the approved temporary sign-in method; never paste keys into files.

## r4t0041 — Choose one temporary sign-in path
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws login --profile "$AwsProfile" --region "$Region"
```
Why / effect: Choose console login OR Identity Center. Non-root temporary principal, with MFA.
Example / verify: aws login needs CLI >=2.32.0 and SignInLocalDevelopmentAccess; Identity Center uses your organization details.
On failure: No sign-in permission? Ask your administrator; do not create long-term keys or switch to root.

## r4t0042 — Choose one temporary sign-in path
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws configure sso --profile "$AwsProfile"
```
Why / effect: LOCAL CONFIG WRITE + interactive Identity Center setup: use organization-provided SSO session/start URL, SSO Region, account and role; choose this sign-in alternative only.
Example / verify: Interactive organization choices and a named profile saved in your local AWS config. No EKS infrastructure is created. Never publish config/session files or authorization codes.
On failure: Missing organization assignment/start details? Ask your administrator. This SSO path does NOT require the separate aws login console-login policy; never fall back to root/long-term keys.

## r4t0043 — Choose one temporary sign-in path
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws sso login --profile "$AwsProfile"
```
Why / effect: AUTHENTICATION: sign into the Identity Center profile already configured; creates/refreshes a LOCAL temporary SSO session, not EKS resources.
Example / verify: Successful SSO login message/session refresh; then separately verify caller identity/account. No account JSON is returned by this login command itself.
On failure: Expired/denied organization assignment or failed browser sign-in? Stop and ask the administrator; do not treat the separate aws login prerequisite as an SSO requirement.

## r4t0044 — Read identity and stop on the wrong account
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json \
  --no-cli-pager
```
Why / effect: AWS READ: prove actual caller identity selected by these credentials.
Example / verify: Account, Arn and UserId (or selected Account text) identify YOUR caller. Illustrative account 111122223333 must NOT replace the independently approved expected account.
On failure: Wrong account or root principal: stop. Expired session: reauthenticate the intended profile.

## r4t0044-ps — Read identity and stop on the wrong account · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json `
  --no-cli-pager
```
Why / effect: AWS READ: prove actual caller identity selected by these credentials.
Example / verify: Account, Arn and UserId (or selected Account text) identify YOUR caller. Illustrative account 111122223333 must NOT replace the independently approved expected account.
On failure: Wrong account or root principal: stop. Expired session: reauthenticate the intended profile.

## r4t0045 — Read identity and stop on the wrong account
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
ActualAccount=$(aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" \
  --query Account --output text --no-cli-pager) || exit 1
if [ "$ActualAccount" != "$ExpectedAccount" ]; then printf '%s
' 'STOP: wrong account'; exit 1; fi
```
Why / effect: AWS READ: prove actual caller identity selected by these credentials.
Example / verify: Account, Arn and UserId (or selected Account text) identify YOUR caller. Illustrative account 111122223333 must NOT replace the independently approved expected account.
On failure: Wrong account or root principal: stop. Expired session: reauthenticate the intended profile.

## r4t0046 — Read identity and stop on the wrong account
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$ActualAccount = aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" `
  --query Account --output text --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw "Identity request failed" }
if ($ActualAccount -ne $ExpectedAccount) { throw "STOP: wrong account" }
```
Why / effect: AWS READ: prove actual caller identity selected by these credentials.
Example / verify: Account, Arn and UserId (or selected Account text) identify YOUR caller. Illustrative account 111122223333 must NOT replace the independently approved expected account.
On failure: Wrong account or root principal: stop. Expired session: reauthenticate the intended profile.

## r4t0047 — Understand the command and every flag
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --query Account \
  --output text --no-cli-pager
```
Why / effect: AWS READ: prove actual caller identity selected by these credentials.
Example / verify: Account, Arn and UserId (or selected Account text) identify YOUR caller. Illustrative account 111122223333 must NOT replace the independently approved expected account.
On failure: --query selects response data; --output formats it. Neither changes permissions or makes a denied API succeed.

## r4t0047-ps — Understand the command and every flag · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --query Account `
  --output text --no-cli-pager
```
Why / effect: AWS READ: prove actual caller identity selected by these credentials.
Example / verify: Account, Arn and UserId (or selected Account text) identify YOUR caller. Illustrative account 111122223333 must NOT replace the independently approved expected account.
On failure: --query selects response data; --output formats it. Neither changes permissions or makes a denied API succeed.

## r4t0048 — What you will be able to do after this unit
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0049 — Why plan before you create
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0050 — Inventory potential costs without a cost-estimate promise
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws eks list-clusters --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
```
Why / effect: AWS READ: inventory regional existing clusters; no cluster is created.
Example / verify: clusters is a list of names in THIS Region; illustrative empty response {"clusters":[]}. Skip name-based reads unless an authorized existing cluster is selected.
On failure: Empty or denied inventory does not prove zero spend. Logout/closing a terminal does not stop charges.

## r4t0051 — Inventory potential costs without a cost-estimate promise
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-nat-gateways --profile "$AwsProfile" --region "$Region" --query \
  'NatGateways[].{ID:NatGatewayId,State:State,Subnet:SubnetId}' --output table \
  --no-cli-pager
```
Why / effect: AWS READ: inventory actual NAT gateway state and placement; the gateway is billable if present.
Example / verify: EXAMPLE SHAPE ONLY: selected table columns ID, State and Subnet. Inspect actual values; an empty result is not a complete zero-cost bill.
On failure: Empty or denied inventory does not prove zero spend. Logout/closing a terminal does not stop charges.

## r4t0051-ps — Inventory potential costs without a cost-estimate promise · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-nat-gateways --profile "$AwsProfile" --region "$Region" --query `
  'NatGateways[].{ID:NatGatewayId,State:State,Subnet:SubnetId}' --output table `
  --no-cli-pager
```
Why / effect: AWS READ: inventory actual NAT gateway state and placement; the gateway is billable if present.
Example / verify: EXAMPLE SHAPE ONLY: selected table columns ID, State and Subnet. Inspect actual values; an empty result is not a complete zero-cost bill.
On failure: Empty or denied inventory does not prove zero spend. Logout/closing a terminal does not stop charges.

## r4t0052 — Inventory potential costs without a cost-estimate promise
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-addresses --profile "$AwsProfile" --region "$Region" --output json \
  --no-cli-pager
```
Why / effect: AWS READ: inventory allocated public IPv4 addresses; this does not release anything.
Example / verify: Addresses entries contain AllocationId/PublicIp and possible AssociationId. Empty Addresses=[] is illustrative only; unused public IPv4 can still cost money.
On failure: Empty or denied inventory does not prove zero spend. Logout/closing a terminal does not stop charges.

## r4t0052-ps — Inventory potential costs without a cost-estimate promise · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-addresses --profile "$AwsProfile" --region "$Region" --output json `
  --no-cli-pager
```
Why / effect: AWS READ: inventory allocated public IPv4 addresses; this does not release anything.
Example / verify: Addresses entries contain AllocationId/PublicIp and possible AssociationId. Empty Addresses=[] is illustrative only; unused public IPv4 can still cost money.
On failure: Empty or denied inventory does not prove zero spend. Logout/closing a terminal does not stop charges.

## r4t0053 — Inventory potential costs without a cost-estimate promise
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-volumes --profile "$AwsProfile" --region "$Region" --output json \
  --no-cli-pager
```
Why / effect: AWS READ: inventory EBS volumes, not a complete billing report.
Example / verify: Volumes records include VolumeId, State, Size, VolumeType and Attachments. An available unattached volume may still be billable; do not delete unknown volumes.
On failure: Empty or denied inventory does not prove zero spend. Logout/closing a terminal does not stop charges.

## r4t0053-ps — Inventory potential costs without a cost-estimate promise · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-volumes --profile "$AwsProfile" --region "$Region" --output json `
  --no-cli-pager
```
Why / effect: AWS READ: inventory EBS volumes, not a complete billing report.
Example / verify: Volumes records include VolumeId, State, Size, VolumeType and Attachments. An available unattached volume may still be billable; do not delete unknown volumes.
On failure: Empty or denied inventory does not prove zero spend. Logout/closing a terminal does not stop charges.

## r4t0054 — Account, Region and Availability Zones
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0055 — Read account-visible Availability Zones
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-availability-zones --profile "$AwsProfile" --region "$Region" --filters \
  Name=zone-type,Values=availability-zone --query \
  'AvailabilityZones[].{Name:ZoneName,ID:ZoneId,State:State,OptIn:OptInStatus}' --output \
  table --no-cli-pager
```
Why / effect: --filters limits normal AZs; --query displays zone names, IDs and state.
Example / verify: ILLUSTRATIVE: us-west-2a / usw2-az2 / available. Record YOUR name/ID pairs and check EKS AZ exclusions.
On failure: available is a zone state, not proof of instance capacity. Read denial: ask for the exact action.

## r4t0055-ps — Read account-visible Availability Zones · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-availability-zones --profile "$AwsProfile" --region "$Region" --filters `
  Name=zone-type,Values=availability-zone --query `
  'AvailabilityZones[].{Name:ZoneName,ID:ZoneId,State:State,OptIn:OptInStatus}' --output `
  table --no-cli-pager
```
Why / effect: --filters limits normal AZs; --query displays zone names, IDs and state.
Example / verify: ILLUSTRATIVE: us-west-2a / usw2-az2 / available. Record YOUR name/ID pairs and check EKS AZ exclusions.
On failure: available is a zone state, not proof of instance capacity. Read denial: ask for the exact action.

## r4t0056 — Offered is not the same as available
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0057 — Read offered types and ENI limits
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
InstanceType="m6i.large"
```
Why / effect: Offerings show where a type is sold; type details show its interface/address limits.
Example / verify: Illustrative m6i.large limits: 3 ENIs, 10 IPv4 per ENI. Check your actual readout.
On failure: No launch/quota/capacity guarantee. Classic maxPods math is not valid for every networking mode.

## r4t0058 — Read offered types and ENI limits
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$InstanceType = "m6i.large"
```
Why / effect: Offerings show where a type is sold; type details show its interface/address limits.
Example / verify: Illustrative m6i.large limits: 3 ENIs, 10 IPv4 per ENI. Check your actual readout.
On failure: No launch/quota/capacity guarantee. Classic maxPods math is not valid for every networking mode.

## r4t0059 — Read offered types and ENI limits
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-instance-type-offerings --profile "$AwsProfile" --region "$Region" \
  --location-type availability-zone --filters "Name=instance-type,Values=$InstanceType" \
  --output table --no-cli-pager
```
Why / effect: AWS READ: check where the selected instance type is offered; inspect ENI limits separately.
Example / verify: InstanceTypeOfferings records contain InstanceType, LocationType and Location; an offered type in an AZ is NOT a live capacity reservation or ENI/IP limit.
On failure: No launch/quota/capacity guarantee. Classic maxPods math is not valid for every networking mode.

## r4t0059-ps — Read offered types and ENI limits · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-instance-type-offerings --profile "$AwsProfile" --region "$Region" `
  --location-type availability-zone --filters "Name=instance-type,Values=$InstanceType" `
  --output table --no-cli-pager
```
Why / effect: AWS READ: check where the selected instance type is offered; inspect ENI limits separately.
Example / verify: InstanceTypeOfferings records contain InstanceType, LocationType and Location; an offered type in an AZ is NOT a live capacity reservation or ENI/IP limit.
On failure: No launch/quota/capacity guarantee. Classic maxPods math is not valid for every networking mode.

## r4t0060 — Read offered types and ENI limits
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
QueryText='InstanceTypes[].{Type:InstanceType,'
QueryText+='ENIs:NetworkInfo.MaximumNetworkInterfaces,'
QueryText+='IPv4PerENI:NetworkInfo.Ipv4AddressesPerInterface}'
aws ec2 describe-instance-types --profile "$AwsProfile" --region "$Region" \
  --instance-types "$InstanceType" --query "$QueryText" --output table --no-cli-pager
```
Why / effect: AWS READ: inspect per-instance network-interface/address limits, not currently free subnet addresses.
Example / verify: Selected table columns Type, ENIs and IPv4PerENI come from NetworkInfo. Example m6i.large: 3 and 10; read YOUR actual output and separate EKS max-Pod/network configuration.
On failure: No launch/quota/capacity guarantee. Classic maxPods math is not valid for every networking mode.

## r4t0060-ps — Read offered types and ENI limits · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$QueryText = 'InstanceTypes[].{Type:InstanceType,'
$QueryText += 'ENIs:NetworkInfo.MaximumNetworkInterfaces,'
$QueryText += 'IPv4PerENI:NetworkInfo.Ipv4AddressesPerInterface}'
aws ec2 describe-instance-types --profile "$AwsProfile" --region "$Region" `
  --instance-types "$InstanceType" --query "$QueryText" --output table --no-cli-pager
```
Why / effect: AWS READ: inspect per-instance network-interface/address limits, not currently free subnet addresses.
Example / verify: Selected table columns Type, ENIs and IPv4PerENI come from NetworkInfo. Example m6i.large: 3 and 10; read YOUR actual output and separate EKS max-Pod/network configuration.
On failure: No launch/quota/capacity guarantee. Classic maxPods math is not valid for every networking mode.

## r4t0061 — Who are you, to AWS?
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0062 — Temporary credentials, not permanent keys
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0063 — Which credentials win
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0064 — Inspect credential sources without revealing keys
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
python3 -c 'import os; print("\n".join(sorted(k for k in os.environ if k.startswith("AWS_"))))' || exit 1
```
Why / effect: List environment variable NAMES only; inspect masked source, then verify STS.
Example / verify: EXAMPLE NAMES ONLY: AWS_PROFILE, AWS_REGION. Prove the actual selected account with STS.
On failure: Clear only unintended manual key variables in this shell; do not inspect token/cache files.

## r4t0065 — Inspect credential sources without revealing keys
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
Get-ChildItem Env:AWS_* | Select-Object -ExpandProperty Name
```
Why / effect: List environment variable NAMES only; inspect masked source, then verify STS.
Example / verify: EXAMPLE NAMES ONLY: AWS_PROFILE, AWS_REGION. Prove the actual selected account with STS.
On failure: Clear only unintended manual key variables in this shell; do not inspect token/cache files.

## r4t0066 — Inspect credential sources without revealing keys
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws configure list --profile "$AwsProfile"
```
Why / effect: LOCAL masked configuration/source inspection, not an environment-name listing.
Example / verify: Masked Value / Type / Location rows for profile, access_key, secret_key and region; inspect YOUR source, then prove identity with STS.
On failure: Clear only unintended manual key variables in this shell; do not inspect token/cache files.

## r4t0067 — Inspect credential sources without revealing keys
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
# Only if stale manual environment keys are unintended in this shell:
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN
```
Why / effect: List environment variable NAMES only; inspect masked source, then verify STS.
Example / verify: EXAMPLE NAMES ONLY: AWS_PROFILE, AWS_REGION. Prove the actual selected account with STS.
On failure: Clear only unintended manual key variables in this shell; do not inspect token/cache files.

## r4t0068 — Inspect credential sources without revealing keys
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
# Only if stale manual environment keys are unintended in this shell:
Remove-Item Env:AWS_ACCESS_KEY_ID,Env:AWS_SECRET_ACCESS_KEY,Env:AWS_SESSION_TOKEN,Env:AWS_SECURITY_TOKEN -ErrorAction SilentlyContinue
```
Why / effect: List environment variable NAMES only; inspect masked source, then verify STS.
Example / verify: EXAMPLE NAMES ONLY: AWS_PROFILE, AWS_REGION. Prove the actual selected account with STS.
On failure: Clear only unintended manual key variables in this shell; do not inspect token/cache files.

## r4t0069 — Inspect credential sources without revealing keys
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json \
  --no-cli-pager
```
Why / effect: AWS READ: prove actual caller identity selected by these credentials.
Example / verify: Account, Arn and UserId (or selected Account text) identify YOUR caller. Illustrative account 111122223333 must NOT replace the independently approved expected account.
On failure: Clear only unintended manual key variables in this shell; do not inspect token/cache files.

## r4t0069-ps — Inspect credential sources without revealing keys · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json `
  --no-cli-pager
```
Why / effect: AWS READ: prove actual caller identity selected by these credentials.
Example / verify: Account, Arn and UserId (or selected Account text) identify YOUR caller. Illustrative account 111122223333 must NOT replace the independently approved expected account.
On failure: Clear only unintended manual key variables in this shell; do not inspect token/cache files.

## r4t0070 — Settings that make scripts predictable
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0071 — Permissions: exactly what each step needs
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0072 — Verify read permissions without pretending to prove deployment rights
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-availability-zones --profile "$AwsProfile" --region "$Region" --output \
  json --no-cli-pager
```
Why / effect: Real read success tests that read only. IAM simulation is optional and incomplete.
Example / verify: EXAMPLE ONLY: AvailabilityZones contains ZoneName, ZoneId and State=available. Match YOUR selected Region; this successful read proves only this read permission.
On failure: Member-account root is SCP-restricted. Do not attach AdministratorAccess or weaken controls to bypass denial.

## r4t0072-ps — Verify read permissions without pretending to prove deployment rights · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-availability-zones --profile "$AwsProfile" --region "$Region" --output `
  json --no-cli-pager
```
Why / effect: Real read success tests that read only. IAM simulation is optional and incomplete.
Example / verify: EXAMPLE ONLY: AvailabilityZones contains ZoneName, ZoneId and State=available. Match YOUR selected Region; this successful read proves only this read permission.
On failure: Member-account root is SCP-restricted. Do not attach AdministratorAccess or weaken controls to bypass denial.

## r4t0073 — Verify read permissions without pretending to prove deployment rights
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws eks describe-cluster-versions --profile "$AwsProfile" --region "$Region" \
  --version-status STANDARD_SUPPORT --output json --no-cli-pager
```
Why / effect: Real read success tests that read only. IAM simulation is optional and incomplete.
Example / verify: EXAMPLE ONLY: clusterVersions includes clusterVersion and versionStatus=STANDARD_SUPPORT. Choose an actual currently returned version, not an invented supported version or an IAM policy-simulation decision.
On failure: Member-account root is SCP-restricted. Do not attach AdministratorAccess or weaken controls to bypass denial.

## r4t0073-ps — Verify read permissions without pretending to prove deployment rights · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws eks describe-cluster-versions --profile "$AwsProfile" --region "$Region" `
  --version-status STANDARD_SUPPORT --output json --no-cli-pager
```
Why / effect: Real read success tests that read only. IAM simulation is optional and incomplete.
Example / verify: EXAMPLE ONLY: clusterVersions includes clusterVersion and versionStatus=STANDARD_SUPPORT. Choose an actual currently returned version, not an invented supported version or an IAM policy-simulation decision.
On failure: Member-account root is SCP-restricted. Do not attach AdministratorAccess or weaken controls to bypass denial.

## r4t0074 — Verify read permissions without pretending to prove deployment rights
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
# OPTIONAL administrator-assisted IAM policy simulation: replace with IAM role ARN, NOT STS session ARN
PolicySourceArn="REPLACE_WITH_IAM_ROLE_ARN"
```
Why / effect: Real read success tests that read only. IAM simulation is optional and incomplete.
Example / verify: ILLUSTRATIVE simulation: EvalDecision=allowed. This is not a live deployment authorization certificate.
On failure: Member-account root is SCP-restricted. Do not attach AdministratorAccess or weaken controls to bypass denial.

## r4t0075 — Verify read permissions without pretending to prove deployment rights
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
# OPTIONAL administrator-assisted simulation; use the IAM role ARN, NOT an STS session ARN
$PolicySourceArn = "REPLACE_WITH_IAM_ROLE_ARN"
```
Why / effect: Real read success tests that read only. IAM simulation is optional and incomplete.
Example / verify: ILLUSTRATIVE simulation: EvalDecision=allowed. This is not a live deployment authorization certificate.
On failure: Member-account root is SCP-restricted. Do not attach AdministratorAccess or weaken controls to bypass denial.

## r4t0076 — Verify read permissions without pretending to prove deployment rights
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws iam simulate-principal-policy --profile "$AwsProfile" --region "$Region" \
  --policy-source-arn "$PolicySourceArn" --action-names ec2:DescribeSubnets \
  eks:DescribeClusterVersions --output json --no-cli-pager
```
Why / effect: Real read success tests that read only. IAM simulation is optional and incomplete.
Example / verify: ILLUSTRATIVE simulation: EvalDecision=allowed. This is not a live deployment authorization certificate.
On failure: Member-account root is SCP-restricted. Do not attach AdministratorAccess or weaken controls to bypass denial.

## r4t0076-ps — Verify read permissions without pretending to prove deployment rights · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws iam simulate-principal-policy --profile "$AwsProfile" --region "$Region" `
  --policy-source-arn "$PolicySourceArn" --action-names ec2:DescribeSubnets `
  eks:DescribeClusterVersions --output json --no-cli-pager
```
Why / effect: Real read success tests that read only. IAM simulation is optional and incomplete.
Example / verify: ILLUSTRATIVE simulation: EvalDecision=allowed. This is not a live deployment authorization certificate.
On failure: Member-account root is SCP-restricted. Do not attach AdministratorAccess or weaken controls to bypass denial.

## r4t0077 — Keeping secrets out of files
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0078 — Knowledge check
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0079 — Answer: stop, and find out who you are
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0080 — Your toolchain
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0081 — Choosing the Kubernetes version on build day
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0082 — Read EKS support and add-on compatibility
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
QueryText='clusterVersions[].{Version:clusterVersion,Status:versionStatus,'
QueryText+='EndStandard:endOfStandardSupportDate}'
aws eks describe-cluster-versions --profile "$AwsProfile" --region "$Region" \
  --version-status STANDARD_SUPPORT --query "$QueryText" --output table --no-cli-pager
```
Why / effect: Read standard support lifecycle first; set K8sVersion from your reviewed result.
Example / verify: EXAMPLE SHAPE: Version=1.xx, Status=STANDARD_SUPPORT, EndStandard=example date. Read actual values before choosing.
On failure: No version is hard-coded as current. Unknown API/option: update supported AWS CLI v2.

## r4t0082-ps — Read EKS support and add-on compatibility · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$QueryText = 'clusterVersions[].{Version:clusterVersion,Status:versionStatus,'
$QueryText += 'EndStandard:endOfStandardSupportDate}'
aws eks describe-cluster-versions --profile "$AwsProfile" --region "$Region" `
  --version-status STANDARD_SUPPORT --query "$QueryText" --output table --no-cli-pager
```
Why / effect: Read standard support lifecycle first; set K8sVersion from your reviewed result.
Example / verify: EXAMPLE SHAPE: Version=1.xx, Status=STANDARD_SUPPORT, EndStandard=example date. Read actual values before choosing.
On failure: No version is hard-coded as current. Unknown API/option: update supported AWS CLI v2.

## r4t0083 — Read EKS support and add-on compatibility
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
K8sVersion="REPLACE_FROM_VERSION_READOUT"
```
Why / effect: Read standard support lifecycle first; set K8sVersion from your reviewed result.
Example / verify: EXAMPLE SHAPE: Version=1.xx, Status=STANDARD_SUPPORT, EndStandard=example date. Read actual values before choosing.
On failure: No version is hard-coded as current. Unknown API/option: update supported AWS CLI v2.

## r4t0084 — Read EKS support and add-on compatibility
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$K8sVersion = "REPLACE_FROM_VERSION_READOUT"
```
Why / effect: Read standard support lifecycle first; set K8sVersion from your reviewed result.
Example / verify: EXAMPLE SHAPE: Version=1.xx, Status=STANDARD_SUPPORT, EndStandard=example date. Read actual values before choosing.
On failure: No version is hard-coded as current. Unknown API/option: update supported AWS CLI v2.

## r4t0085 — Read EKS support and add-on compatibility
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws eks describe-addon-versions --profile "$AwsProfile" --region "$Region" \
  --kubernetes-version "$K8sVersion" --addon-name vpc-cni --output json --no-cli-pager
```
Why / effect: AWS READ: discover compatible add-on releases for the selected Kubernetes version.
Example / verify: addons[] contains addonName and addonVersions[], including addonVersion, architecture and compatibilities. Inspect the chosen cluster-version compatibility/defaultVersion, not EKS end-of-support rows.
On failure: No version is hard-coded as current. Unknown API/option: update supported AWS CLI v2.

## r4t0085-ps — Read EKS support and add-on compatibility · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws eks describe-addon-versions --profile "$AwsProfile" --region "$Region" `
  --kubernetes-version "$K8sVersion" --addon-name vpc-cni --output json --no-cli-pager
```
Why / effect: AWS READ: discover compatible add-on releases for the selected Kubernetes version.
Example / verify: addons[] contains addonName and addonVersions[], including addonVersion, architecture and compatibilities. Inspect the chosen cluster-version compatibility/defaultVersion, not EKS end-of-support rows.
On failure: No version is hard-coded as current. Unknown API/option: update supported AWS CLI v2.

## r4t0086 — What costs money in Unit 6B
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0087 — What does not stop the bill
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0088 — A budget alert is not a spending limit
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0089 — Read a budget and its alert subscribers
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws budgets describe-budgets --profile "$AwsProfile" --region us-east-1 --account-id \
  "$ExpectedAccount" --output json --no-cli-pager
```
Why / effect: AWS READ: list existing monitoring budgets only.
Example / verify: Budgets[] includes BudgetName, BudgetLimit and TimeUnit. The budget threshold/subscriber is a SEPARATE notification/subscriber read; an alert is never a spending cap.
On failure: Not found before optional creation is normal. Do not modify/delete a pre-existing shared budget.

## r4t0089-ps — Read a budget and its alert subscribers · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws budgets describe-budgets --profile "$AwsProfile" --region us-east-1 --account-id `
  "$ExpectedAccount" --output json --no-cli-pager
```
Why / effect: AWS READ: list existing monitoring budgets only.
Example / verify: Budgets[] includes BudgetName, BudgetLimit and TimeUnit. The budget threshold/subscriber is a SEPARATE notification/subscriber read; an alert is never a spending cap.
On failure: Not found before optional creation is normal. Do not modify/delete a pre-existing shared budget.

## r4t0090 — Read a budget and its alert subscribers
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
BudgetName="unit06a-learning-alert"
```
Why / effect: Commercial AWS Budgets endpoint us-east-1; explicit account ID and dedicated budget name.
Example / verify: ILLUSTRATIVE: 10 USD MONTHLY; ACTUAL >80% email threshold. This is not a spending cap.
On failure: Not found before optional creation is normal. Do not modify/delete a pre-existing shared budget.

## r4t0091 — Read a budget and its alert subscribers
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$BudgetName = "unit06a-learning-alert"
```
Why / effect: Commercial AWS Budgets endpoint us-east-1; explicit account ID and dedicated budget name.
Example / verify: ILLUSTRATIVE: 10 USD MONTHLY; ACTUAL >80% email threshold. This is not a spending cap.
On failure: Not found before optional creation is normal. Do not modify/delete a pre-existing shared budget.

## r4t0092 — Read a budget and its alert subscribers
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws budgets describe-notifications-for-budget --profile "$AwsProfile" --region us-east-1 \
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" --output json \
  --no-cli-pager
```
Why / effect: AWS READ: inspect configured alert trigger conditions, not another creation.
Example / verify: Notifications[] contains NotificationType, ComparisonOperator, Threshold and ThresholdType, for example ACTUAL GREATER_THAN 80 PERCENTAGE. This is not the subscriber email list.
On failure: Not found before optional creation is normal. Do not modify/delete a pre-existing shared budget.

## r4t0092-ps — Read a budget and its alert subscribers · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws budgets describe-notifications-for-budget --profile "$AwsProfile" --region us-east-1 `
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" --output json `
  --no-cli-pager
```
Why / effect: AWS READ: inspect configured alert trigger conditions, not another creation.
Example / verify: Notifications[] contains NotificationType, ComparisonOperator, Threshold and ThresholdType, for example ACTUAL GREATER_THAN 80 PERCENTAGE. This is not the subscriber email list.
On failure: Not found before optional creation is normal. Do not modify/delete a pre-existing shared budget.

## r4t0093 — COST_ACK, an end time and a cleanup plan
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0094 — Rehearse account, cost and end-time guards
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
CostAck="NO"
EndTime="REPLACE_WITH_FUTURE_ISO8601_WITH_OFFSET"
python3 scripts/check_guard.py --expected-account "$ExpectedAccount" --actual-account "$ActualAccount" --cost-ack "$CostAck" --end-time "$EndTime"
```
Why / effect: Local Python gate: approved account, exact cost acknowledgment and future ISO8601 end time.
Example / verify: Default CostAck=NO must STOP. This does not create a scheduler, deletion timer or spending cap.
On failure: Wrong account, missing acknowledgment, expired/ambiguous/beyond-eight-hours end time: stop deliberately.

## r4t0095 — Rehearse account, cost and end-time guards
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$CostAck = "NO"
$EndTime = "REPLACE_WITH_FUTURE_ISO8601_WITH_OFFSET"
py -3 scripts/check_guard.py --expected-account "$ExpectedAccount" --actual-account "$ActualAccount" --cost-ack "$CostAck" --end-time "$EndTime"
if ($LASTEXITCODE -ne 0) { throw "STOP: local guard failed" }
```
Why / effect: Local Python gate: approved account, exact cost acknowledgment and future ISO8601 end time.
Example / verify: Default CostAck=NO must STOP. This does not create a scheduler, deletion timer or spending cap.
On failure: Wrong account, missing acknowledgment, expired/ambiguous/beyond-eight-hours end time: stop deliberately.

## r4t0096 — Knowledge check
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0097 — Answer: the alert arrived, the bill kept growing
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0098 — ALB means Application Load Balancer
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0099 — How an ALB is used with EKS
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0100 — ALB reachability, security and FREE subnet capacity
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0101 — ALB means Application Load Balancer: inspect its web-routing path
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
QueryText='LoadBalancers[].{Name:LoadBalancerName,Arn:LoadBalancerArn,'
QueryText+='Type:Type,Scheme:Scheme,State:State.Code,'
QueryText+='Subnets:AvailabilityZones[].SubnetId}'
aws elbv2 describe-load-balancers --profile "$AwsProfile" --region "$Region" --query \
  "$QueryText" --output json --no-cli-pager
```
Why / effect: AWS READ: inventory frontend load-balancer identity and placement.
Example / verify: EXAMPLE SHAPE ONLY: Name, Arn, Type, Scheme, State and Subnets. Type=application identifies ALB; inspect actual scheme/subnet placement. DNS name and security groups require an unprojected or separately selected read, not a claim they appear here.
On failure: No authorized ALB? Skip. Requires the matching elasticloadbalancing:Describe permissions.

## r4t0101-ps — ALB means Application Load Balancer: inspect its web-routing path · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$QueryText = 'LoadBalancers[].{Name:LoadBalancerName,Arn:LoadBalancerArn,'
$QueryText += 'Type:Type,Scheme:Scheme,State:State.Code,'
$QueryText += 'Subnets:AvailabilityZones[].SubnetId}'
aws elbv2 describe-load-balancers --profile "$AwsProfile" --region "$Region" --query `
  "$QueryText" --output json --no-cli-pager
```
Why / effect: AWS READ: inventory frontend load-balancer identity and placement.
Example / verify: EXAMPLE SHAPE ONLY: Name, Arn, Type, Scheme, State and Subnets. Type=application identifies ALB; inspect actual scheme/subnet placement. DNS name and security groups require an unprojected or separately selected read, not a claim they appear here.
On failure: No authorized ALB? Skip. Requires the matching elasticloadbalancing:Describe permissions.

## r4t0102 — ALB means Application Load Balancer: inspect its web-routing path
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
# Continue ONLY if an authorized existing Type=application load balancer exists:
LoadBalancerArn="REPLACE_FROM_EXISTING_ALB_READOUT"
```
Why / effect: Existing ALB only: listener → rule → target group → target health. No creation.
Example / verify: ILLUSTRATIVE: Type=application; listener HTTPS/443; host/path rule → target group; target health includes reason.
On failure: No authorized ALB? Skip. Requires the matching elasticloadbalancing:Describe permissions.

## r4t0103 — ALB means Application Load Balancer: inspect its web-routing path
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
# Continue ONLY if an authorized existing Type=application load balancer exists:
$LoadBalancerArn = "REPLACE_FROM_EXISTING_ALB_READOUT"
```
Why / effect: Existing ALB only: listener → rule → target group → target health. No creation.
Example / verify: ILLUSTRATIVE: Type=application; listener HTTPS/443; host/path rule → target group; target health includes reason.
On failure: No authorized ALB? Skip. Requires the matching elasticloadbalancing:Describe permissions.

## r4t0104 — ALB means Application Load Balancer: inspect its web-routing path
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws elbv2 describe-listeners --profile "$AwsProfile" --region "$Region" \
  --load-balancer-arn "$LoadBalancerArn" --output json --no-cli-pager
```
Why / effect: AWS READ: identify frontend listener protocol/port/default action.
Example / verify: Listeners contains ListenerArn, Port, Protocol and DefaultActions. Example HTTPS/443 is illustrative; it is not the target-health response.
On failure: No authorized ALB? Skip. Requires the matching elasticloadbalancing:Describe permissions.

## r4t0104-ps — ALB means Application Load Balancer: inspect its web-routing path · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws elbv2 describe-listeners --profile "$AwsProfile" --region "$Region" `
  --load-balancer-arn "$LoadBalancerArn" --output json --no-cli-pager
```
Why / effect: AWS READ: identify frontend listener protocol/port/default action.
Example / verify: Listeners contains ListenerArn, Port, Protocol and DefaultActions. Example HTTPS/443 is illustrative; it is not the target-health response.
On failure: No authorized ALB? Skip. Requires the matching elasticloadbalancing:Describe permissions.

## r4t0105 — ALB means Application Load Balancer: inspect its web-routing path
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
ListenerArn="REPLACE_FROM_LISTENER_READOUT"
```
Why / effect: Existing ALB only: listener → rule → target group → target health. No creation.
Example / verify: ILLUSTRATIVE: Type=application; listener HTTPS/443; host/path rule → target group; target health includes reason.
On failure: No authorized ALB? Skip. Requires the matching elasticloadbalancing:Describe permissions.

## r4t0106 — ALB means Application Load Balancer: inspect its web-routing path
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$ListenerArn = "REPLACE_FROM_LISTENER_READOUT"
```
Why / effect: Existing ALB only: listener → rule → target group → target health. No creation.
Example / verify: ILLUSTRATIVE: Type=application; listener HTTPS/443; host/path rule → target group; target health includes reason.
On failure: No authorized ALB? Skip. Requires the matching elasticloadbalancing:Describe permissions.

## r4t0107 — ALB means Application Load Balancer: inspect its web-routing path
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws elbv2 describe-rules --profile "$AwsProfile" --region "$Region" --listener-arn \
  "$ListenerArn" --output json --no-cli-pager
```
Why / effect: AWS READ: inspect listener-rule selection of a target group.
Example / verify: Rules contains Priority, Conditions and Actions; evaluate host/path conditions and target-group forwarding action. No target-health verdict appears here.
On failure: No authorized ALB? Skip. Requires the matching elasticloadbalancing:Describe permissions.

## r4t0107-ps — ALB means Application Load Balancer: inspect its web-routing path · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws elbv2 describe-rules --profile "$AwsProfile" --region "$Region" --listener-arn `
  "$ListenerArn" --output json --no-cli-pager
```
Why / effect: AWS READ: inspect listener-rule selection of a target group.
Example / verify: Rules contains Priority, Conditions and Actions; evaluate host/path conditions and target-group forwarding action. No target-health verdict appears here.
On failure: No authorized ALB? Skip. Requires the matching elasticloadbalancing:Describe permissions.

## r4t0108 — ALB means Application Load Balancer: inspect its web-routing path
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws elbv2 describe-target-groups --profile "$AwsProfile" --region "$Region" \
  --load-balancer-arn "$LoadBalancerArn" --output json --no-cli-pager
```
Why / effect: AWS READ: inspect backend target mode/listener and health-check configuration.
Example / verify: TargetGroups contains TargetGroupArn, TargetType, Protocol, Port and HealthCheck settings; instance versus ip changes the backend path.
On failure: No authorized ALB? Skip. Requires the matching elasticloadbalancing:Describe permissions.

## r4t0108-ps — ALB means Application Load Balancer: inspect its web-routing path · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws elbv2 describe-target-groups --profile "$AwsProfile" --region "$Region" `
  --load-balancer-arn "$LoadBalancerArn" --output json --no-cli-pager
```
Why / effect: AWS READ: inspect backend target mode/listener and health-check configuration.
Example / verify: TargetGroups contains TargetGroupArn, TargetType, Protocol, Port and HealthCheck settings; instance versus ip changes the backend path.
On failure: No authorized ALB? Skip. Requires the matching elasticloadbalancing:Describe permissions.

## r4t0109 — ALB means Application Load Balancer: inspect its web-routing path
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
TargetGroupArn="REPLACE_FROM_TARGET_GROUP_READOUT"
```
Why / effect: Existing ALB only: listener → rule → target group → target health. No creation.
Example / verify: ILLUSTRATIVE: Type=application; listener HTTPS/443; host/path rule → target group; target health includes reason.
On failure: No authorized ALB? Skip. Requires the matching elasticloadbalancing:Describe permissions.

## r4t0110 — ALB means Application Load Balancer: inspect its web-routing path
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$TargetGroupArn = "REPLACE_FROM_TARGET_GROUP_READOUT"
```
Why / effect: Existing ALB only: listener → rule → target group → target health. No creation.
Example / verify: ILLUSTRATIVE: Type=application; listener HTTPS/443; host/path rule → target group; target health includes reason.
On failure: No authorized ALB? Skip. Requires the matching elasticloadbalancing:Describe permissions.

## r4t0111 — ALB means Application Load Balancer: inspect its web-routing path
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws elbv2 describe-target-health --profile "$AwsProfile" --region "$Region" \
  --target-group-arn "$TargetGroupArn" --output json --no-cli-pager
```
Why / effect: AWS READ: inspect registered target health; correlate failed health checks with backend rules/listener.
Example / verify: TargetHealthDescriptions contains Target Id/Port and TargetHealth State/Reason/Description. Healthy is YOUR observed state only if actually returned.
On failure: No authorized ALB? Skip. Requires the matching elasticloadbalancing:Describe permissions.

## r4t0111-ps — ALB means Application Load Balancer: inspect its web-routing path · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws elbv2 describe-target-health --profile "$AwsProfile" --region "$Region" `
  --target-group-arn "$TargetGroupArn" --output json --no-cli-pager
```
Why / effect: AWS READ: inspect registered target health; correlate failed health checks with backend rules/listener.
Example / verify: TargetHealthDescriptions contains Target Id/Port and TargetHealth State/Reason/Description. Healthy is YOUR observed state only if actually returned.
On failure: No authorized ALB? Skip. Requires the matching elasticloadbalancing:Describe permissions.

## r4t0112 — One owner for every resource
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0113 — Separate read-only observation from resource ownership
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
terraform -chdir=terraform/offline state list
terraform -chdir=terraform/read-only state list
```
Why / effect: -chdir selects the exact separate project. state list reads local saved state only.
Example / verify: EXAMPLE after data-only apply: data.aws_caller_identity.current. No local state before apply is normal.
On failure: No state yet is normal. Never import CLI lab objects here or run blind terraform destroy.

## r4t0114 — Terraform read-only · versions.tf · final contiguous lines
Save/read complete file terraform/read-only/versions.tf

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
Why / effect: Complete file in Save/read complete file terraform/read-only/versions.tf; final 9 contiguous lines, no orphan-brace page
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0116 — Terraform read-only · variables.tf · 1/5
Save/read complete file terraform/read-only/variables.tf

```hcl
variable "aws_profile" {
  description = "Name of YOUR existing temporary-credential profile, never an access key."
  type        = string
  validation {
    condition     = length(trimspace(var.aws_profile)) > 0
    error_message = "Supply your named profile."
  }
}
```
Why / effect: Complete terraform/read-only/variables.tf · contiguous lines 1–8
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0117 — Terraform read-only · variables.tf · 2/5
Save/read complete file terraform/read-only/variables.tf

```hcl
variable "aws_region" {
  description = "Your approved AWS Region, for example us-west-2."
  type        = string
}
variable "expected_account_id" {
  description = "Your approved twelve-digit AWS account ID. Provider refuses a different account."
  type        = string
```
Why / effect: Complete terraform/read-only/variables.tf · contiguous lines 9–15
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0118 — Terraform read-only · variables.tf · 3/5
Save/read complete file terraform/read-only/variables.tf

```hcl
  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_account_id))
    error_message = "Supply exactly twelve digits."
  }
}
variable "instance_type" {
  description = "Read characteristics/offering only, never launch."
  type        = string
```
Why / effect: Complete terraform/read-only/variables.tf · contiguous lines 16–23
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0119 — Terraform read-only · variables.tf · 4/5
Save/read complete file terraform/read-only/variables.tf

```hcl
  default     = "m6i.large"
}
variable "kubernetes_version" {
  description = "Optional exact version chosen from your standard-support readout. null skips the add-on query."
  type        = string
  default     = null
}
```
Why / effect: Complete terraform/read-only/variables.tf · contiguous lines 24–30
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0120 — Terraform read-only · variables.tf · 5/5
Save/read complete file terraform/read-only/variables.tf

```hcl
variable "existing_subnet_ids" {
  description = "Optional existing subnet IDs in this account/Region. Leave empty before Unit 6B."
  type        = set(string)
  default     = []
}
```
Why / effect: Complete terraform/read-only/variables.tf · contiguous lines 31–35
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0121 — Terraform read-only · terraform.tfvars.example · 1/3
Save/read complete file terraform/read-only/terraform.tfvars.example

```hcl
# Replace REPLACE values before plan. Example account number below is NOT yours.
aws_profile         = "REPLACE_WITH_YOUR_PROFILE"
aws_region          = "us-west-2"
expected_account_id = "000000000000"
instance_type       = "m6i.large"
kubernetes_version  = null
existing_subnet_ids  = []

```
Why / effect: Complete terraform/read-only/terraform.tfvars.example · contiguous lines 1–7
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0122 — Terraform read-only · terraform.tfvars.example · 2/3
Save/read complete file terraform/read-only/terraform.tfvars.example

```hcl
# OPTIONAL selected existing objects only; [] is valid before Unit 6B.
existing_vpc_ids              = []
existing_route_table_ids      = []
existing_nat_gateway_ids      = []
existing_internet_gateway_ids = []
existing_cluster_names        = []

# Optional existing ALB chain, selected from authorized readouts only.
```
Why / effect: Complete terraform/read-only/terraform.tfvars.example · contiguous lines 8–15
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0123 — Terraform read-only · terraform.tfvars.example · 3/3
Save/read complete file terraform/read-only/terraform.tfvars.example

```hcl
existing_load_balancer_arns = []
existing_listener_arns = []
existing_listener_rule_arns = []
existing_target_group_arns = []
```
Why / effect: Complete terraform/read-only/terraform.tfvars.example · contiguous lines 16–19
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0124 — Terraform read-only · main.tf · 1/6
Save/read complete file terraform/read-only/main.tf

```hcl
# Data-only configuration. There is deliberately NO resource block.
provider "aws" {
  profile             = var.aws_profile
  region              = var.aws_region
  allowed_account_ids = [var.expected_account_id]
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
```
Why / effect: Complete terraform/read-only/main.tf · contiguous lines 1–8
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0125 — Terraform read-only · main.tf · 2/6
Save/read complete file terraform/read-only/main.tf

```hcl
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}
data "aws_eks_cluster_versions" "standard" {
```
Why / effect: Complete terraform/read-only/main.tf · contiguous lines 9–16
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0126 — Terraform read-only · main.tf · 3/6
Save/read complete file terraform/read-only/main.tf

```hcl
  version_status = "STANDARD_SUPPORT"
}
data "aws_eks_addon_version" "vpc_cni" {
  count              = var.kubernetes_version == null ? 0 : 1
  addon_name         = "vpc-cni"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}
```
Why / effect: Complete terraform/read-only/main.tf · contiguous lines 17–24
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0127 — Terraform read-only · main.tf · 4/6
Save/read complete file terraform/read-only/main.tf

```hcl
data "aws_ec2_instance_type" "node" {
  instance_type = var.instance_type
}
data "aws_ec2_instance_type_offerings" "node" {
  location_type = "availability-zone"
  filter {
    name   = "instance-type"
    values = [var.instance_type]
```
Why / effect: Complete terraform/read-only/main.tf · contiguous lines 25–32
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0128 — Terraform read-only · main.tf · 5/6
Save/read complete file terraform/read-only/main.tf

```hcl
  }
}
data "aws_subnet" "existing" {
  for_each = var.existing_subnet_ids
  id       = each.value
}
locals {
  # EC2 limits, not a Kubernetes scheduler promise.
```
Why / effect: Complete terraform/read-only/main.tf · contiguous lines 33–40
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0129 — Terraform read-only · main.tf · 6/6
Save/read complete file terraform/read-only/main.tf

```hcl
  classic_max_pods = data.aws_ec2_instance_type.node.maximum_network_interfaces * (data.aws_ec2_instance_type.node.maximum_ipv4_addresses_per_interface - 1) + 2
}
```
Why / effect: Complete terraform/read-only/main.tf · contiguous lines 41–42
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0130 — Terraform read-only · observations.tf · 1/12
Save/read complete file terraform/read-only/observations.tf

```hcl
# OPTIONAL existing infrastructure observations. Empty sets skip these lookups.
# IDs/names must come from authorized CLI readouts in this account and Region.
variable "existing_vpc_ids" {
  type    = set(string)
  default = []
}
variable "existing_route_table_ids" {
  type    = set(string)
```
Why / effect: Complete terraform/read-only/observations.tf · contiguous lines 1–8
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0131 — Terraform read-only · observations.tf · 2/12
Save/read complete file terraform/read-only/observations.tf

```hcl
  default = []
}
variable "existing_nat_gateway_ids" {
  type    = set(string)
  default = []
}
variable "existing_internet_gateway_ids" {
  type    = set(string)
```
Why / effect: Complete terraform/read-only/observations.tf · contiguous lines 9–16
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0132 — Terraform read-only · observations.tf · 3/12
Save/read complete file terraform/read-only/observations.tf

```hcl
  default = []
}
variable "existing_cluster_names" {
  type    = set(string)
  default = []
}
data "aws_vpc" "existing" {
  for_each = var.existing_vpc_ids
```
Why / effect: Complete terraform/read-only/observations.tf · contiguous lines 17–24
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0133 — Terraform read-only · observations.tf · 4/12
Save/read complete file terraform/read-only/observations.tf

```hcl
  id       = each.value
}
data "aws_route_table" "existing" {
  for_each       = var.existing_route_table_ids
  route_table_id = each.value
}
data "aws_nat_gateway" "existing" {
  for_each = var.existing_nat_gateway_ids
```
Why / effect: Complete terraform/read-only/observations.tf · contiguous lines 25–32
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0134 — Terraform read-only · observations.tf · 5/12
Save/read complete file terraform/read-only/observations.tf

```hcl
  id       = each.value
}
data "aws_internet_gateway" "existing" {
  for_each            = var.existing_internet_gateway_ids
  internet_gateway_id = each.value
}
data "aws_eks_cluster" "existing" {
  for_each = var.existing_cluster_names
```
Why / effect: Complete terraform/read-only/observations.tf · contiguous lines 33–40
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0135 — Terraform read-only · observations.tf · 6/12
Save/read complete file terraform/read-only/observations.tf

```hcl
  name     = each.value
}
output "vpc_observations" {
  value = { for id, v in data.aws_vpc.existing : id => {
    cidr             = v.cidr_block
    all_cidrs        = v.cidr_block_associations
    dns_support      = v.enable_dns_support
    dns_hostnames    = v.enable_dns_hostnames
```
Why / effect: Complete terraform/read-only/observations.tf · contiguous lines 41–48
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0136 — Terraform read-only · observations.tf · 7/12
Save/read complete file terraform/read-only/observations.tf

```hcl
    main_route_table = v.main_route_table_id
  } }
}
output "route_table_observations" {
  description = "Real associated subnet/table/route observations; CLI is still needed for per-route State and packet LPM reasoning."
  value = { for id, r in data.aws_route_table.existing : id => {
    vpc          = r.vpc_id
```
Why / effect: Complete terraform/read-only/observations.tf · contiguous lines 49–55
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0137 — Terraform read-only · observations.tf · 8/12
Save/read complete file terraform/read-only/observations.tf

```hcl
    associations = r.associations
    routes       = r.routes
  } }
}
output "nat_observations" {
  value = { for id, n in data.aws_nat_gateway.existing : id => {
    state        = n.state
    vpc          = n.vpc_id
```
Why / effect: Complete terraform/read-only/observations.tf · contiguous lines 56–63
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0138 — Terraform read-only · observations.tf · 9/12
Save/read complete file terraform/read-only/observations.tf

```hcl
    subnet       = n.subnet_id
    connectivity = n.connectivity_type
    private_ip   = n.private_ip
    public_ip    = n.public_ip
  } }
}
output "internet_gateway_observations" {
  value = { for id, g in data.aws_internet_gateway.existing : id => {
```
Why / effect: Complete terraform/read-only/observations.tf · contiguous lines 64–71
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0139 — Terraform read-only · observations.tf · 10/12
Save/read complete file terraform/read-only/observations.tf

```hcl
    attachments = g.attachments
  } }
}
output "cluster_observations" {
  description = "Private account metadata; no authentication token or credentials are requested."
  value = { for name, c in data.aws_eks_cluster.existing : name => {
    api_endpoint    = c.endpoint
```
Why / effect: Complete terraform/read-only/observations.tf · contiguous lines 72–78
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0140 — Terraform read-only · observations.tf · final contiguous lines
Save/read complete file terraform/read-only/observations.tf

```hcl
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
Why / effect: Complete file in Save/read complete file terraform/read-only/observations.tf; final 9 contiguous lines, no orphan-brace page
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0142 — Terraform read-only · load-balancer-observations.tf · 1/7
Save/read complete file terraform/read-only/load-balancer-observations.tf

```hcl
# Optional EXISTING load balancer chain; default empty sets make no such reads.
variable "existing_load_balancer_arns" {
  type    = set(string)
  default = []
}
variable "existing_listener_arns" {
  type    = set(string)
  default = []
```
Why / effect: Complete terraform/read-only/load-balancer-observations.tf · contiguous lines 1–8
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0143 — Terraform read-only · load-balancer-observations.tf · 2/7
Save/read complete file terraform/read-only/load-balancer-observations.tf

```hcl
}
variable "existing_listener_rule_arns" {
  type    = set(string)
  default = []
}
variable "existing_target_group_arns" {
  type    = set(string)
  default = []
```
Why / effect: Complete terraform/read-only/load-balancer-observations.tf · contiguous lines 9–16
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0144 — Terraform read-only · load-balancer-observations.tf · 3/7
Save/read complete file terraform/read-only/load-balancer-observations.tf

```hcl
}
data "aws_lb" "existing" {
  for_each = var.existing_load_balancer_arns
  arn      = each.value
}
data "aws_lb_listener" "existing" {
  for_each = var.existing_listener_arns
  arn      = each.value
```
Why / effect: Complete terraform/read-only/load-balancer-observations.tf · contiguous lines 17–24
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0145 — Terraform read-only · load-balancer-observations.tf · 4/7
Save/read complete file terraform/read-only/load-balancer-observations.tf

```hcl
}
data "aws_lb_listener_rule" "existing" {
  for_each = var.existing_listener_rule_arns
  arn      = each.value
}
data "aws_lb_target_group" "existing" {
  for_each = var.existing_target_group_arns
  arn      = each.value
```
Why / effect: Complete terraform/read-only/load-balancer-observations.tf · contiguous lines 25–32
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0146 — Terraform read-only · load-balancer-observations.tf · 5/7
Save/read complete file terraform/read-only/load-balancer-observations.tf

```hcl
}
output "load_balancer_observations" {
  value = { for arn, l in data.aws_lb.existing : arn => { dns = l.dns_name, type = l.load_balancer_type, internal = l.internal, vpc = l.vpc_id, subnets = l.subnets, security_groups = l.security_groups } }
}
output "listener_observations" {
```
Why / effect: Complete terraform/read-only/load-balancer-observations.tf · contiguous lines 33–37
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0147 — Terraform read-only · load-balancer-observations.tf · 6/7
Save/read complete file terraform/read-only/load-balancer-observations.tf

```hcl
  value = { for arn, l in data.aws_lb_listener.existing : arn => { load_balancer = l.load_balancer_arn, protocol = l.protocol, port = l.port, default_action_types = [for a in l.default_action : a.type] } }
}
output "listener_rule_observations" {
  value = { for arn, r in data.aws_lb_listener_rule.existing : arn => { listener = r.listener_arn, priority = r.priority, conditions = r.condition, action_types = [for a in r.action : a.type] } }
```
Why / effect: Complete terraform/read-only/load-balancer-observations.tf · contiguous lines 38–41
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0148 — Terraform read-only · load-balancer-observations.tf · 7/7
Save/read complete file terraform/read-only/load-balancer-observations.tf

```hcl
}
output "target_group_observations" {
  value       = { for arn, t in data.aws_lb_target_group.existing : arn => { protocol = t.protocol, port = t.port, target_type = t.target_type, vpc = t.vpc_id, health_check = t.health_check } }
  description = "Health-check policy, NOT live per-target health. Use CLI describe-target-health for actual target state/reason. State/plan and listener auth configuration remain private."
}
```
Why / effect: Complete terraform/read-only/load-balancer-observations.tf · contiguous lines 42–46
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0149 — Terraform read-only · outputs.tf · 1/6
Save/read complete file terraform/read-only/outputs.tf

```hcl
output "identity" {
  description = "Account/ARN metadata; do not publish your local state or outputs."
  value = {
    account_id = data.aws_caller_identity.current.account_id
    arn        = data.aws_caller_identity.current.arn
    region     = data.aws_region.current.region
  }
}
```
Why / effect: Complete terraform/read-only/outputs.tf · contiguous lines 1–8
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0150 — Terraform read-only · outputs.tf · 2/6
Save/read complete file terraform/read-only/outputs.tf

```hcl
output "eks_standard_versions" {
  value = data.aws_eks_cluster_versions.standard.cluster_versions
}
output "vpc_cni_latest_compatible_version" {
  description = "Optional latest compatible version, NOT a guarantee of suitability for your architecture/configuration."
  value       = try(data.aws_eks_addon_version.vpc_cni[0].version, null)
}
```
Why / effect: Complete terraform/read-only/outputs.tf · contiguous lines 9–15
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0151 — Terraform read-only · outputs.tf · 3/6
Save/read complete file terraform/read-only/outputs.tf

```hcl
output "availability_zones" {
  value = {
    names = data.aws_availability_zones.available.names
    ids   = data.aws_availability_zones.available.zone_ids
  }
}
output "instance_type_observation" {
  value = {
```
Why / effect: Complete terraform/read-only/outputs.tf · contiguous lines 16–23
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0152 — Terraform read-only · outputs.tf · 4/6
Save/read complete file terraform/read-only/outputs.tf

```hcl
    type             = var.instance_type
    offered_in       = data.aws_ec2_instance_type_offerings.node.locations
    maximum_enis     = data.aws_ec2_instance_type.node.maximum_network_interfaces
    ipv4_per_eni     = data.aws_ec2_instance_type.node.maximum_ipv4_addresses_per_interface
    classic_max_pods = local.classic_max_pods
    warning          = "Offered does NOT prove spare capacity; no launch was attempted. Secondary-IP mode only."
  }
```
Why / effect: Complete terraform/read-only/outputs.tf · contiguous lines 24–30
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0153 — Terraform read-only · outputs.tf · 5/6
Save/read complete file terraform/read-only/outputs.tf

```hcl
}
output "existing_subnets" {
  value = {
    for id, subnet in data.aws_subnet.existing : id => {
      cidr      = subnet.cidr_block
      az        = subnet.availability_zone
      vpc       = subnet.vpc_id
      free_ipv4 = subnet.available_ip_address_count
```
Why / effect: Complete terraform/read-only/outputs.tf · contiguous lines 31–38
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0154 — Terraform read-only · outputs.tf · 6/6
Save/read complete file terraform/read-only/outputs.tf

```hcl
    }
  }
  description = "Point-in-time subnet address observations, not reserved future capacity."
}
```
Why / effect: Complete terraform/read-only/outputs.tf · contiguous lines 39–42
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0155 — Prepare private Terraform inputs
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
cp terraform/read-only/terraform.tfvars.example terraform/read-only/terraform.tfvars
```
Why / effect: Provider 6.21.0 reads AWS. Account guard must match your intended account before plan.
Example / verify: No resources: plan reads; optional apply writes LOCAL state/outputs and creates no AWS infrastructure.
On failure: Do not commit state/plans/private tfvars. Unsupported login_session: documented process-profile bridge, not copied keys.

## r4t0156 — Prepare private Terraform inputs
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
Copy-Item terraform/read-only/terraform.tfvars.example terraform/read-only/terraform.tfvars
```
Why / effect: Provider 6.21.0 reads AWS. Account guard must match your intended account before plan.
Example / verify: No resources: plan reads; optional apply writes LOCAL state/outputs and creates no AWS infrastructure.
On failure: Do not commit state/plans/private tfvars. Unsupported login_session: documented process-profile bridge, not copied keys.

## r4t0157 — Terraform read-only · workflow
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
terraform -chdir=terraform/read-only init -backend=false -input=false
terraform -chdir=terraform/read-only fmt -check
terraform -chdir=terraform/read-only validate
terraform -chdir=terraform/read-only plan -input=false -out=observations.tfplan
# Optional: reviewed data-only plan writes LOCAL state; no AWS resources created
terraform -chdir=terraform/read-only apply -input=false observations.tfplan
terraform -chdir=terraform/read-only output -json
```
Why / effect: Provider 6.21.0 reads AWS. Account guard must match your intended account before plan.
Example / verify: No resources: plan reads; optional apply writes LOCAL state/outputs and creates no AWS infrastructure.
On failure: Do not commit state/plans/private tfvars. Unsupported login_session: documented process-profile bridge, not copied keys.

## r4t0158 — Optional profile compatibility bridge
Save/read complete file approved AWS profile configuration

```text
[profile eksclass-tf-read]
credential_process = aws configure export-credentials --profile eksclass-student \
  --format process
region = us-west-2
```
Why / effect: LOCAL credential-process integration; the provider consumes sensitive process output, not shell-copyable credentials.
Example / verify: Credential-process JSON is consumed privately by the provider; never display, capture in lecture, paste into reports or commit it. No sample credential values are taught.
On failure: Never print, paste, commit or inspect cached temporary credentials.

## r4t0159 — Guards that stop instead of guessing
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0160 — Addresses in one minute
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0161 — Inspect VPCs, subnets and ENI address owners
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-vpcs --profile "$AwsProfile" --region "$Region" --query \
  'Vpcs[].{ID:VpcId,CIDR:CidrBlock,OtherCIDRs:CidrBlockAssociationSet}' --output json \
  --no-cli-pager
```
Why / effect: AWS READ: inventory VPC address pools; do not infer subnet availability from VPC size.
Example / verify: Selected ID, CIDR and OtherCIDRs describe VPC CIDR associations. No subnet Free count is returned here; check attached secondary CIDRs too.
On failure: Empty inventory before Unit 6B is normal. Never delete service-owned ENIs to free addresses.

## r4t0161-ps — Inspect VPCs, subnets and ENI address owners · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-vpcs --profile "$AwsProfile" --region "$Region" --query `
  'Vpcs[].{ID:VpcId,CIDR:CidrBlock,OtherCIDRs:CidrBlockAssociationSet}' --output json `
  --no-cli-pager
```
Why / effect: AWS READ: inventory VPC address pools; do not infer subnet availability from VPC size.
Example / verify: Selected ID, CIDR and OtherCIDRs describe VPC CIDR associations. No subnet Free count is returned here; check attached secondary CIDRs too.
On failure: Empty inventory before Unit 6B is normal. Never delete service-owned ENIs to free addresses.

## r4t0162 — Inspect VPCs, subnets and ENI address owners
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
VpcId="REPLACE_WITH_EXISTING_VPC_ID"
```
Why / effect: Select only a real authorized VpcId from the first readout; otherwise skip scoped reads.
Example / verify: DESIGN EXAMPLE: private-a 10.42.16.0/20; 4091 usable BEFORE allocations. Current Free is a separate observation.
On failure: Empty inventory before Unit 6B is normal. Never delete service-owned ENIs to free addresses.

## r4t0163 — Inspect VPCs, subnets and ENI address owners
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$VpcId = "REPLACE_WITH_EXISTING_VPC_ID"
```
Why / effect: Select only a real authorized VpcId from the first readout; otherwise skip scoped reads.
Example / verify: DESIGN EXAMPLE: private-a 10.42.16.0/20; 4091 usable BEFORE allocations. Current Free is a separate observation.
On failure: Empty inventory before Unit 6B is normal. Never delete service-owned ENIs to free addresses.

## r4t0164 — Inspect VPCs, subnets and ENI address owners
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --filters \
  "Name=vpc-id,Values=$VpcId" --query \
  'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' \
  --output table --no-cli-pager
```
Why / effect: AWS READ: inspect actual subnet placement and remaining free IPv4 addresses.
Example / verify: Selected table ID, CIDR, AZ and Free means AvailableIpAddressCount NOW. Example 4091 is theoretical usable /20 capacity before allocations, NOT a claimed live Free value.
On failure: Empty inventory before Unit 6B is normal. Never delete service-owned ENIs to free addresses.

## r4t0164-ps — Inspect VPCs, subnets and ENI address owners · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --filters `
  "Name=vpc-id,Values=$VpcId" --query `
  'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' `
  --output table --no-cli-pager
```
Why / effect: AWS READ: inspect actual subnet placement and remaining free IPv4 addresses.
Example / verify: Selected table ID, CIDR, AZ and Free means AvailableIpAddressCount NOW. Example 4091 is theoretical usable /20 capacity before allocations, NOT a claimed live Free value.
On failure: Empty inventory before Unit 6B is normal. Never delete service-owned ENIs to free addresses.

## r4t0165 — Inspect VPCs, subnets and ENI address owners
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
QueryText='NetworkInterfaces[].{ID:NetworkInterfaceId,Subnet:SubnetId,'
QueryText+='Type:InterfaceType,IPs:PrivateIpAddresses,Description:Description}'
aws ec2 describe-network-interfaces --profile "$AwsProfile" --region "$Region" --filters \
  "Name=vpc-id,Values=$VpcId" --query "$QueryText" --output json --no-cli-pager
```
Why / effect: AWS READ: identify actual interface/address consumers and subnet attachment.
Example / verify: Selected ID, Subnet, Type, IPs and Description identify ENIs and attached private addresses; additional SG inspection is separate. No synthetic NACL permit/deny decision is returned.
On failure: Empty inventory before Unit 6B is normal. Never delete service-owned ENIs to free addresses.

## r4t0165-ps — Inspect VPCs, subnets and ENI address owners · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$QueryText = 'NetworkInterfaces[].{ID:NetworkInterfaceId,Subnet:SubnetId,'
$QueryText += 'Type:InterfaceType,IPs:PrivateIpAddresses,Description:Description}'
aws ec2 describe-network-interfaces --profile "$AwsProfile" --region "$Region" --filters `
  "Name=vpc-id,Values=$VpcId" --query "$QueryText" --output json --no-cli-pager
```
Why / effect: AWS READ: identify actual interface/address consumers and subnet attachment.
Example / verify: Selected ID, Subnet, Type, IPs and Description identify ENIs and attached private addresses; additional SG inspection is separate. No synthetic NACL permit/deny decision is returned.
On failure: Empty inventory before Unit 6B is normal. Never delete service-owned ENIs to free addresses.

## r4t0166 — Every address, and who owns it
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0167 — The planned network
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0168 — Five addresses you cannot use
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0169 — Read live free IPv4 in one existing subnet
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --subnet-ids \
  "$SubnetId" --query \
  'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' \
  --output table --no-cli-pager
```
Why / effect: AWS READ: inspect actual subnet placement and remaining free IPv4 addresses.
Example / verify: Selected table ID, CIDR, AZ and Free means AvailableIpAddressCount NOW. Example 4091 is theoretical usable /20 capacity before allocations, NOT a claimed live Free value.
On failure: No existing subnet? Skip the read. Wrong account/Region/ID must not trigger subnet creation here.

## r4t0169-ps — Read live free IPv4 in one existing subnet · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --subnet-ids `
  "$SubnetId" --query `
  'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' `
  --output table --no-cli-pager
```
Why / effect: AWS READ: inspect actual subnet placement and remaining free IPv4 addresses.
Example / verify: Selected table ID, CIDR, AZ and Free means AvailableIpAddressCount NOW. Example 4091 is theoretical usable /20 capacity before allocations, NOT a claimed live Free value.
On failure: No existing subnet? Skip the read. Wrong account/Region/ID must not trigger subnet creation here.

## r4t0170 — Calculate reserved space and test the small-subnet failure
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/20
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/24
```
Why / effect: Illustration: 4 nodes × 3 ENIs × 10 IPs = 120; other reservations = 23; total = 143.
Example / verify: /20: 4091 usable, 3948 remaining. /24: 251 usable; 143 exceeds illustrative 50% planning limit.
On failure: The 50% policy is not an AWS rule. This model is secondary-IP mode, not prefix delegation or scheduler proof.

## r4t0171 — Calculate reserved space and test the small-subnet failure
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/20
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --private 10.42.16.0/24
```
Why / effect: Illustration: 4 nodes × 3 ENIs × 10 IPs = 120; other reservations = 23; total = 143.
Example / verify: /20: 4091 usable, 3948 remaining. /24: 251 usable; 143 exceeds illustrative 50% planning limit.
On failure: The 50% policy is not an AWS rule. This model is secondary-IP mode, not prefix delegation or scheduler proof.

## r4t0172 — Terraform offline · versions.tf · 1/1
Save/read complete file terraform/offline/versions.tf

```hcl
terraform {
  required_version = ">= 1.13.5, < 2.0.0"
}
```
Why / effect: Complete terraform/offline/versions.tf · contiguous lines 1–3
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0173 — Terraform offline · variables.tf · 1/8
Save/read complete file terraform/offline/variables.tf

```hcl
variable "vpc_cidr" {
  description = "Illustrative IPv4 /16; use only an approved non-overlapping RFC1918 range."
  type        = string
  default     = "10.42.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr)) && can(regex("/16$", var.vpc_cidr))
    error_message = "This teaching calculator requires a valid IPv4 /16."
  }
```
Why / effect: Complete terraform/offline/variables.tf · contiguous lines 1–8
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0174 — Terraform offline · variables.tf · 2/8
Save/read complete file terraform/offline/variables.tf

```hcl
}
variable "service_cidr" {
  description = "Illustrative Kubernetes virtual Service range, not a VPC subnet. Verify overlap with scripts/network_checks.py."
  type        = string
  default     = "172.20.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.service_cidr))
```
Why / effect: Complete terraform/offline/variables.tf · contiguous lines 9–15
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0175 — Terraform offline · variables.tf · 3/8
Save/read complete file terraform/offline/variables.tf

```hcl
    error_message = "Supply a valid IPv4 CIDR, then check EKS size/private-range/overlap requirements with Python."
  }
}
variable "nodes_per_az" {
  description = "Maximum steady nodes in each AZ, not desired cluster total."
  type        = number
  default     = 2
```
Why / effect: Complete terraform/offline/variables.tf · contiguous lines 16–22
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0176 — Terraform offline · variables.tf · 4/8
Save/read complete file terraform/offline/variables.tf

```hcl
  validation {
    condition     = var.nodes_per_az >= 0 && floor(var.nodes_per_az) == var.nodes_per_az
    error_message = "Use a non-negative integer."
  }
}
variable "surge_per_az" {
  description = "Additional nodes during replacement, illustrative reservation."
  type        = number
```
Why / effect: Complete terraform/offline/variables.tf · contiguous lines 23–30
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0177 — Terraform offline · variables.tf · 5/8
Save/read complete file terraform/offline/variables.tf

```hcl
  default     = 2
  validation {
    condition     = var.surge_per_az >= 0 && floor(var.surge_per_az) == var.surge_per_az
    error_message = "Use a non-negative integer."
  }
}
variable "enis_per_node" {
```
Why / effect: Complete terraform/offline/variables.tf · contiguous lines 31–37
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0178 — Terraform offline · variables.tf · 6/8
Save/read complete file terraform/offline/variables.tf

```hcl
  description = "Illustrative m6i.large limit; read actual EC2 type limits before using a different type."
  type        = number
  default     = 3
  validation {
    condition     = var.enis_per_node >= 1 && floor(var.enis_per_node) == var.enis_per_node
    error_message = "Use a positive integer."
  }
```
Why / effect: Complete terraform/offline/variables.tf · contiguous lines 38–44
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0179 — Terraform offline · variables.tf · 7/8
Save/read complete file terraform/offline/variables.tf

```hcl
}
variable "ipv4_per_eni" {
  description = "Includes primary IPv4; this calculator models secondary-IP mode, NOT prefix delegation."
  type        = number
  default     = 10
  validation {
    condition     = var.ipv4_per_eni >= 1 && floor(var.ipv4_per_eni) == var.ipv4_per_eni
```
Why / effect: Complete terraform/offline/variables.tf · contiguous lines 45–51
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0180 — Terraform offline · variables.tf · 8/8
Save/read complete file terraform/offline/variables.tf

```hcl
    error_message = "Use a positive integer."
  }
}
```
Why / effect: Complete terraform/offline/variables.tf · contiguous lines 52–54
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0181 — Terraform offline · terraform.tfvars.example · 1/1
Save/read complete file terraform/offline/terraform.tfvars.example

```hcl
vpc_cidr       = "10.42.0.0/16"
service_cidr   = "172.20.0.0/16"
nodes_per_az   = 2
surge_per_az   = 2
enis_per_node = 3
ipv4_per_eni  = 10
```
Why / effect: Complete terraform/offline/terraform.tfvars.example · contiguous lines 1–6
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0182 — Terraform offline · main.tf · 1/3
Save/read complete file terraform/offline/main.tf

```hcl
# Pure calculations: no provider, AWS credentials or managed resources.
locals {
  subnets = {
    public_a  = cidrsubnet(var.vpc_cidr, 8, 0)
    public_b  = cidrsubnet(var.vpc_cidr, 8, 1)
    private_a = cidrsubnet(var.vpc_cidr, 4, 1)
    private_b = cidrsubnet(var.vpc_cidr, 4, 2)
  }
```
Why / effect: Complete terraform/offline/main.tf · contiguous lines 1–8
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0183 — Terraform offline · main.tf · 2/3
Save/read complete file terraform/offline/main.tf

```hcl
  usable_private_ipv4 = pow(2, 32 - 20) - 5
  other_reservations = {
    cluster_enis         = 4
    upgrade_cluster_enis = 4
    alb_headroom         = 8
    nlb_address          = 1
    endpoint_enis        = 6
  }
```
Why / effect: Complete terraform/offline/main.tf · contiguous lines 9–16
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0184 — Terraform offline · main.tf · 3/3
Save/read complete file terraform/offline/main.tf

```hcl
  node_ipv4_reservation = (var.nodes_per_az + var.surge_per_az) * var.enis_per_node * var.ipv4_per_eni
  planned_ipv4          = local.node_ipv4_reservation + sum(values(local.other_reservations))
  remaining_ipv4        = local.usable_private_ipv4 - local.planned_ipv4
  classic_max_pods      = var.enis_per_node * (var.ipv4_per_eni - 1) + 2
  planned_percent       = 100 * local.planned_ipv4 / local.usable_private_ipv4
}
```
Why / effect: Complete terraform/offline/main.tf · contiguous lines 17–22
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0185 — Terraform offline · outputs.tf · 1/3
Save/read complete file terraform/offline/outputs.tf

```hcl
output "address_plan" {
  description = "Illustrative design only; no subnets created."
  value = {
    vpc_cidr     = var.vpc_cidr
    service_cidr = var.service_cidr
    subnets      = local.subnets
  }
}
```
Why / effect: Complete terraform/offline/outputs.tf · contiguous lines 1–8
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0186 — Terraform offline · outputs.tf · 2/3
Save/read complete file terraform/offline/outputs.tf

```hcl
output "capacity_per_private_subnet" {
  value = {
    usable_ipv4        = local.usable_private_ipv4
    node_reservation   = local.node_ipv4_reservation
    other_reservations = local.other_reservations
    total_planned      = local.planned_ipv4
    remaining          = local.remaining_ipv4
    planned_percent    = local.planned_percent
```
Why / effect: Complete terraform/offline/outputs.tf · contiguous lines 9–16
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0187 — Terraform offline · outputs.tf · 3/3
Save/read complete file terraform/offline/outputs.tf

```hcl
    below_course_50pct = local.planned_percent <= 50
    classic_max_pods   = local.classic_max_pods
    mode               = "Illustrative secondary-IP mode; not a scheduler guarantee or prefix-delegation formula"
  }
}
```
Why / effect: Complete terraform/offline/outputs.tf · contiguous lines 17–21
Example / verify: Read ALL pages of this file. Full copyable file is supplied; no omitted blocks or invented attributes.
On failure: Do not execute a displayed fragment as a whole project. Keep edited inputs, plans and state private.

## r4t0188 — Terraform offline · workflow
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
terraform -chdir=terraform/offline init -backend=false -input=false
terraform -chdir=terraform/offline fmt -check
terraform -chdir=terraform/offline validate
terraform -chdir=terraform/offline plan -input=false -out=offline.tfplan
# Optional LOCAL state/output write, no AWS calls or AWS resources:
terraform -chdir=terraform/offline apply -input=false offline.tfplan
terraform -chdir=terraform/offline output -json
```
Why / effect: No provider, no credentials, no AWS calls; only complete local calculations.
Example / verify: Plan: outputs only. Optional apply writes LOCAL state; then output can read saved values.
On failure: If plan shows resource actions, stop: wrong folder/configuration. Validation is not production design proof.

## r4t0189 — A capacity calculation, worked
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0190 — The same calculation, too small
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0191 — The Service range is not in the VPC
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0192 — Validate Service range and distinguish virtual forwarding
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --destination 172.20.0.10
# Deliberate failure, offline only:
python3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 10.42.0.0/16
```
Why / effect: Service IPv4 range: RFC1918, /12 through /24, nonoverlapping with VPC/connected networks.
Example / verify: EXPECTED local overlap test: STOP. VPC default match is NOT a recommendation to send ClusterIP to NAT.
On failure: Deliberate overlap must STOP. Check central IPAM too; the local test is not organization-wide proof.

## r4t0193 — Validate Service range and distinguish virtual forwarding
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 172.20.0.0/16 --destination 172.20.0.10
# Deliberate failure, offline only:
py -3 scripts/network_checks.py --vpc 10.42.0.0/16 --service 10.42.0.0/16
```
Why / effect: Service IPv4 range: RFC1918, /12 through /24, nonoverlapping with VPC/connected networks.
Example / verify: EXPECTED local overlap test: STOP. VPC default match is NOT a recommendation to send ClusterIP to NAT.
On failure: Deliberate overlap must STOP. Check central IPAM too; the local test is not organization-wide proof.

## r4t0194 — Routes: the most specific one wins
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0195 — Read actual subnet association and winning route candidates
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
SubnetId="REPLACE_WITH_EXISTING_SUBNET_ID"
```
Why / effect: Read explicit subnet association; if absent, inspect the VPC main table.
Example / verify: ILLUSTRATIVE: 10.42.33.7 → local /16; 203.0.113.80 → default NAT. Read real association/route state separately.
On failure: Empty explicit association is not missing routes. Inspect blackhole/targets; do not add routes here.

## r4t0196 — Read actual subnet association and winning route candidates
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$SubnetId = "REPLACE_WITH_EXISTING_SUBNET_ID"
```
Why / effect: Read explicit subnet association; if absent, inspect the VPC main table.
Example / verify: ILLUSTRATIVE: 10.42.33.7 → local /16; 203.0.113.80 → default NAT. Read real association/route state separately.
On failure: Empty explicit association is not missing routes. Inspect blackhole/targets; do not add routes here.

## r4t0197 — Read actual subnet association and winning route candidates
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters \
  "Name=association.subnet-id,Values=$SubnetId" --output json --no-cli-pager
```
Why / effect: AWS READ: inspect actual owning route-table associations, route targets and blackhole/active state.
Example / verify: RouteTables contains Associations and Routes with destination prefixes, targets and State. Find the associated subnet/main table before longest-prefix lookup; a route row is not a reachability test.
On failure: Empty explicit association is not missing routes. Inspect blackhole/targets; do not add routes here.

## r4t0197-ps — Read actual subnet association and winning route candidates · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters `
  "Name=association.subnet-id,Values=$SubnetId" --output json --no-cli-pager
```
Why / effect: AWS READ: inspect actual owning route-table associations, route targets and blackhole/active state.
Example / verify: RouteTables contains Associations and Routes with destination prefixes, targets and State. Find the associated subnet/main table before longest-prefix lookup; a route row is not a reachability test.
On failure: Empty explicit association is not missing routes. Inspect blackhole/targets; do not add routes here.

## r4t0198 — Read actual subnet association and winning route candidates
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters \
  "Name=vpc-id,Values=$VpcId" Name=association.main,Values=true --output json \
  --no-cli-pager
```
Why / effect: AWS READ: inspect actual owning route-table associations, route targets and blackhole/active state.
Example / verify: RouteTables contains Associations and Routes with destination prefixes, targets and State. Find the associated subnet/main table before longest-prefix lookup; a route row is not a reachability test.
On failure: Empty explicit association is not missing routes. Inspect blackhole/targets; do not add routes here.

## r4t0198-ps — Read actual subnet association and winning route candidates · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters `
  "Name=vpc-id,Values=$VpcId" Name=association.main,Values=true --output json `
  --no-cli-pager
```
Why / effect: AWS READ: inspect actual owning route-table associations, route targets and blackhole/active state.
Example / verify: RouteTables contains Associations and Routes with destination prefixes, targets and State. Find the associated subnet/main table before longest-prefix lookup; a route row is not a reachability test.
On failure: Empty explicit association is not missing routes. Inspect blackhole/targets; do not add routes here.

## r4t0199 — Read actual subnet association and winning route candidates
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
python3 scripts/network_checks.py --destination 10.42.33.7
python3 scripts/network_checks.py --destination 203.0.113.80
```
Why / effect: Read explicit subnet association; if absent, inspect the VPC main table.
Example / verify: ILLUSTRATIVE: 10.42.33.7 → local /16; 203.0.113.80 → default NAT. Read real association/route state separately.
On failure: Empty explicit association is not missing routes. Inspect blackhole/targets; do not add routes here.

## r4t0200 — Read actual subnet association and winning route candidates
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
py -3 scripts/network_checks.py --destination 10.42.33.7
py -3 scripts/network_checks.py --destination 203.0.113.80
```
Why / effect: Read explicit subnet association; if absent, inspect the VPC main table.
Example / verify: ILLUSTRATIVE: 10.42.33.7 → local /16; 203.0.113.80 → default NAT. Read real association/route state separately.
On failure: Empty explicit association is not missing routes. Inspect blackhole/targets; do not add routes here.

## r4t0201 — Two NAT gateways, one per zone
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0202 — Verify NAT placement, IGW and per-AZ route targets
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
QueryText='NatGateways[].{ID:NatGatewayId,State:State,Subnet:SubnetId,'
QueryText+='Type:ConnectivityType,Addresses:NatGatewayAddresses}'
aws ec2 describe-nat-gateways --profile "$AwsProfile" --region "$Region" --filter \
  "Name=vpc-id,Values=$VpcId" --query "$QueryText" --output json --no-cli-pager
```
Why / effect: AWS READ ONLY: inventory NAT state, subnet placement and connectivity type in this selected VPC; no gateway or route is created.
Example / verify: ILLUSTRATIVE SHAPE: array of ID, State, Subnet, Type and Addresses. Type distinguishes public/private NAT; Addresses is address evidence, NOT a route-table decision. Empty results do not prove zero billing.
On failure: Read denial/wrong Region/VPC stops interpretation. Compare actual NAT IDs with separately read route tables; do not allocate a gateway to repair an empty result.

## r4t0202-ps — Verify NAT placement, IGW and per-AZ route targets · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$QueryText = 'NatGateways[].{ID:NatGatewayId,State:State,Subnet:SubnetId,'
$QueryText += 'Type:ConnectivityType,Addresses:NatGatewayAddresses}'
aws ec2 describe-nat-gateways --profile "$AwsProfile" --region "$Region" --filter `
  "Name=vpc-id,Values=$VpcId" --query "$QueryText" --output json --no-cli-pager
```
Why / effect: AWS READ ONLY: inventory NAT state, subnet placement and connectivity type in this selected VPC; no gateway or route is created.
Example / verify: ILLUSTRATIVE SHAPE: array of ID, State, Subnet, Type and Addresses. Type distinguishes public/private NAT; Addresses is address evidence, NOT a route-table decision. Empty results do not prove zero billing.
On failure: Read denial/wrong Region/VPC stops interpretation. Compare actual NAT IDs with separately read route tables; do not allocate a gateway to repair an empty result.

## r4t0203 — Verify NAT placement, IGW and per-AZ route targets
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-internet-gateways --profile "$AwsProfile" --region "$Region" --filters \
  "Name=attachment.vpc-id,Values=$VpcId" --output json --no-cli-pager
```
Why / effect: AWS READ: verify internet-gateway attachment to the intended VPC.
Example / verify: InternetGateways[].Attachments identifies VpcId and attachment State. A correct attachment alone does not prove the public subnet has a default route.
On failure: describe-nat-gateways uses --filter. Do not allocate a new billable gateway to fix an empty read.

## r4t0203-ps — Verify NAT placement, IGW and per-AZ route targets · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-internet-gateways --profile "$AwsProfile" --region "$Region" --filters `
  "Name=attachment.vpc-id,Values=$VpcId" --output json --no-cli-pager
```
Why / effect: AWS READ: verify internet-gateway attachment to the intended VPC.
Example / verify: InternetGateways[].Attachments identifies VpcId and attachment State. A correct attachment alone does not prove the public subnet has a default route.
On failure: describe-nat-gateways uses --filter. Do not allocate a new billable gateway to fix an empty read.

## r4t0204 — Verify NAT placement, IGW and per-AZ route targets
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --filters \
  "Name=vpc-id,Values=$VpcId" --query \
  'Subnets[].{ID:SubnetId,AZ:AvailabilityZone,CIDR:CidrBlock}' --output table \
  --no-cli-pager
```
Why / effect: AWS READ: inspect selected subnet IDs, Availability Zones and CIDRs to correlate NAT placement and route targets. The separate earlier free-IP query checks capacity.
Example / verify: EXAMPLE SHAPE ONLY: ID, AZ and CIDR, NOT Free. Join NAT subnet identifier to the actual zone, then compare route targets. Use the separate earlier free-IP query for capacity.
On failure: Wrong Region/VPC, ec2:DescribeSubnets denial or malformed --filters? Stop and investigate. Do not allocate a billable gateway to fix an empty read.

## r4t0204-ps — Verify NAT placement, IGW and per-AZ route targets · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --filters `
  "Name=vpc-id,Values=$VpcId" --query `
  'Subnets[].{ID:SubnetId,AZ:AvailabilityZone,CIDR:CidrBlock}' --output table `
  --no-cli-pager
```
Why / effect: AWS READ: inspect selected subnet IDs, Availability Zones and CIDRs to correlate NAT placement and route targets. The separate earlier free-IP query checks capacity.
Example / verify: EXAMPLE SHAPE ONLY: ID, AZ and CIDR, NOT Free. Join NAT subnet identifier to the actual zone, then compare route targets. Use the separate earlier free-IP query for capacity.
On failure: Wrong Region/VPC, ec2:DescribeSubnets denial or malformed --filters? Stop and investigate. Do not allocate a billable gateway to fix an empty read.

## r4t0205 — Security groups and network ACLs
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0206 — Read SG and NACL rules including return ports
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-security-groups --profile "$AwsProfile" --region "$Region" --filters \
  "Name=vpc-id,Values=$VpcId" --output json --no-cli-pager
```
Why / effect: AWS READ: inspect stateful SG rules separately from routes, NACLs and application listeners.
Example / verify: SecurityGroups includes IpPermissions and IpPermissionsEgress with protocol, port and source/destination ranges or group references. This is configuration, NOT an evaluated packet verdict.
On failure: Stateful SG tracking does not override NACL deny. Do not open all inbound ports as a shortcut.

## r4t0206-ps — Read SG and NACL rules including return ports · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-security-groups --profile "$AwsProfile" --region "$Region" --filters `
  "Name=vpc-id,Values=$VpcId" --output json --no-cli-pager
```
Why / effect: AWS READ: inspect stateful SG rules separately from routes, NACLs and application listeners.
Example / verify: SecurityGroups includes IpPermissions and IpPermissionsEgress with protocol, port and source/destination ranges or group references. This is configuration, NOT an evaluated packet verdict.
On failure: Stateful SG tracking does not override NACL deny. Do not open all inbound ports as a shortcut.

## r4t0207 — Read SG and NACL rules including return ports
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-network-acls --profile "$AwsProfile" --region "$Region" --filters \
  "Name=association.subnet-id,Values=$SubnetId" --output json --no-cli-pager
```
Why / effect: AWS READ: inspect stateless subnet ACL configuration; responses need their return-direction rules.
Example / verify: NetworkAcls includes subnet Associations and Entries: RuleNumber, Egress, Protocol, RuleAction, CIDR and relevant port ranges. Evaluate ordered rules in BOTH directions.
On failure: Stateful SG tracking does not override NACL deny. Do not open all inbound ports as a shortcut.

## r4t0207-ps — Read SG and NACL rules including return ports · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-network-acls --profile "$AwsProfile" --region "$Region" --filters `
  "Name=association.subnet-id,Values=$SubnetId" --output json --no-cli-pager
```
Why / effect: AWS READ: inspect stateless subnet ACL configuration; responses need their return-direction rules.
Example / verify: NetworkAcls includes subnet Associations and Entries: RuleNumber, Egress, Protocol, RuleAction, CIDR and relevant port ranges. Evaluate ordered rules in BOTH directions.
On failure: Stateful SG tracking does not override NACL deny. Do not open all inbound ports as a shortcut.

## r4t0208 — Read SG and NACL rules including return ports
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-network-interfaces --profile "$AwsProfile" --region "$Region" --filters \
  "Name=subnet-id,Values=$SubnetId" --query \
  'NetworkInterfaces[].{ENI:NetworkInterfaceId,Groups:Groups}' --output json \
  --no-cli-pager
```
Why / effect: AWS READ: identify actual interface/address consumers and subnet attachment.
Example / verify: EXAMPLE SHAPE ONLY: ENI identifier plus attached Groups. Match actual group identifiers to the SG read. This query does not return private-address inventory or evaluate a packet verdict.
On failure: Stateful SG tracking does not override NACL deny. Do not open all inbound ports as a shortcut.

## r4t0208-ps — Read SG and NACL rules including return ports · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-network-interfaces --profile "$AwsProfile" --region "$Region" --filters `
  "Name=subnet-id,Values=$SubnetId" --query `
  'NetworkInterfaces[].{ENI:NetworkInterfaceId,Groups:Groups}' --output json `
  --no-cli-pager
```
Why / effect: AWS READ: identify actual interface/address consumers and subnet attachment.
Example / verify: EXAMPLE SHAPE ONLY: ENI identifier plus attached Groups. Match actual group identifiers to the SG read. This query does not return private-address inventory or evaluate a packet verdict.
On failure: Stateful SG tracking does not override NACL deny. Do not open all inbound ports as a shortcut.

## r4t0209 — Knowledge check
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0210 — Answer: there is nothing to route to
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0211 — Follow along without creating a cluster
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0212 — Practice · prove your local tools
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0213 — Practice · defend the intended account
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0214 — Practice · trigger guards deliberately
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0215 — Practice · change one capacity variable
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0216 — Practice · explain the winning route
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0217 — Practice · diagnose a denied reply
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0218 — Optional: sign in, then read-only checks
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0219 — Optional existing cluster/add-on readout, no creation
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws eks list-clusters --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
```
Why / effect: AWS READ: inventory regional existing clusters; no cluster is created.
Example / verify: clusters is a list of names in THIS Region; illustrative empty response {"clusters":[]}. Skip name-based reads unless an authorized existing cluster is selected.
On failure: ResourceNotFound or read denial is not a reason to create a cluster or install an add-on in this unit.

## r4t0220 — Optional existing cluster/add-on readout, no creation
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
ClusterName="REPLACE_WITH_AUTHORIZED_EXISTING_CLUSTER"
```
Why / effect: No existing authorized cluster? Stop after list-clusters and record not present.
Example / verify: EMPTY-SANDBOX EXAMPLE: clusters=[]. Skip later reads unless a real authorized cluster exists.
On failure: ResourceNotFound or read denial is not a reason to create a cluster or install an add-on in this unit.

## r4t0221 — Optional existing cluster/add-on readout, no creation
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$ClusterName = "REPLACE_WITH_AUTHORIZED_EXISTING_CLUSTER"
```
Why / effect: No existing authorized cluster? Stop after list-clusters and record not present.
Example / verify: EMPTY-SANDBOX EXAMPLE: clusters=[]. Skip later reads unless a real authorized cluster exists.
On failure: ResourceNotFound or read denial is not a reason to create a cluster or install an add-on in this unit.

## r4t0222 — Optional existing cluster/add-on readout, no creation
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
QueryText='cluster.{Name:name,Version:version,Status:status,'
QueryText+='Network:resourcesVpcConfig,Service:kubernetesNetworkConfig,'
QueryText+='Support:upgradePolicy}'
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name \
  "$ClusterName" --query "$QueryText" --output json --no-cli-pager
```
Why / effect: No existing authorized cluster? Stop after list-clusters and record not present.
Example / verify: Selected Name, Version, Status, Network, Service and Support describe THIS existing cluster. This is not clusters=[] inventory output; no creation or configuration change occurs.
On failure: ResourceNotFound or read denial is not a reason to create a cluster or install an add-on in this unit.

## r4t0222-ps — Optional existing cluster/add-on readout, no creation · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$QueryText = 'cluster.{Name:name,Version:version,Status:status,'
$QueryText += 'Network:resourcesVpcConfig,Service:kubernetesNetworkConfig,'
$QueryText += 'Support:upgradePolicy}'
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name `
  "$ClusterName" --query "$QueryText" --output json --no-cli-pager
```
Why / effect: No existing authorized cluster? Stop after list-clusters and record not present.
Example / verify: Selected Name, Version, Status, Network, Service and Support describe THIS existing cluster. This is not clusters=[] inventory output; no creation or configuration change occurs.
On failure: ResourceNotFound or read denial is not a reason to create a cluster or install an add-on in this unit.

## r4t0223 — Optional existing cluster/add-on readout, no creation
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws eks list-addons --profile "$AwsProfile" --region "$Region" --cluster-name \
  "$ClusterName" --output json --no-cli-pager
```
Why / effect: AWS READ: list managed add-ons on the selected authorized existing cluster.
Example / verify: addons is a list of managed add-on names, for example ["vpc-cni"]. Empty cluster inventory is NOT a valid describe-addon response.
On failure: ResourceNotFound or read denial is not a reason to create a cluster or install an add-on in this unit.

## r4t0223-ps — Optional existing cluster/add-on readout, no creation · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws eks list-addons --profile "$AwsProfile" --region "$Region" --cluster-name `
  "$ClusterName" --output json --no-cli-pager
```
Why / effect: AWS READ: list managed add-ons on the selected authorized existing cluster.
Example / verify: addons is a list of managed add-on names, for example ["vpc-cni"]. Empty cluster inventory is NOT a valid describe-addon response.
On failure: ResourceNotFound or read denial is not a reason to create a cluster or install an add-on in this unit.

## r4t0224 — Optional existing cluster/add-on readout, no creation
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws eks describe-addon --profile "$AwsProfile" --region "$Region" --cluster-name \
  "$ClusterName" --addon-name vpc-cni --output json --no-cli-pager
```
Why / effect: AWS READ: inspect one actual managed add-on release/status/issues.
Example / verify: addon includes addonName, addonVersion, status, health.issues and configurationValues. Check YOUR actual release and health; no cluster creation happens.
On failure: ResourceNotFound or read denial is not a reason to create a cluster or install an add-on in this unit.

## r4t0224-ps — Optional existing cluster/add-on readout, no creation · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws eks describe-addon --profile "$AwsProfile" --region "$Region" --cluster-name `
  "$ClusterName" --addon-name vpc-cni --output json --no-cli-pager
```
Why / effect: AWS READ: inspect one actual managed add-on release/status/issues.
Example / verify: addon includes addonName, addonVersion, status, health.issues and configurationValues. Check YOUR actual release and health; no cluster creation happens.
On failure: ResourceNotFound or read denial is not a reason to create a cluster or install an add-on in this unit.

## r4t0225 — Select the existing cluster
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
ClusterName="REPLACE_FROM_AUTHORIZED_EXISTING_CLUSTER_LIST"
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: Examples: endpoint https://EXAMPLE.invalid; Service CIDR 172.20.0.0/16. Read YOUR values, do not change them to match.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0226 — Select the existing cluster
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$ClusterName = "REPLACE_FROM_AUTHORIZED_EXISTING_CLUSTER_LIST"
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: Examples: endpoint https://EXAMPLE.invalid; Service CIDR 172.20.0.0/16. Read YOUR values, do not change them to match.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0227 — Read actual cluster API / Service pool
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name \
  "$ClusterName" --query 'cluster.endpoint' --output text --no-cli-pager
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: Text output is YOUR Kubernetes HTTPS API URL. Illustrative only: https://EXAMPLE.invalid. AWS describe permission does not imply kubectl access.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0227-ps — Read actual cluster API / Service pool · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name `
  "$ClusterName" --query 'cluster.endpoint' --output text --no-cli-pager
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: Text output is YOUR Kubernetes HTTPS API URL. Illustrative only: https://EXAMPLE.invalid. AWS describe permission does not imply kubectl access.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0228 — Read actual cluster API / Service pool
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
QueryText='cluster.resourcesVpcConfig.{Public:endpointPublicAccess,'
QueryText+='Private:endpointPrivateAccess,PublicCIDRs:publicAccessCidrs,'
QueryText+='ClusterSG:clusterSecurityGroupId}'
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name \
  "$ClusterName" --query "$QueryText" --output json --no-cli-pager
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: Selected Public, Private, PublicCIDRs and ClusterSG report API reachability controls. Public access is not anonymous; private routing/SG and authentication/authorization remain separate.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0228-ps — Read actual cluster API / Service pool · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$QueryText = 'cluster.resourcesVpcConfig.{Public:endpointPublicAccess,'
$QueryText += 'Private:endpointPrivateAccess,PublicCIDRs:publicAccessCidrs,'
$QueryText += 'ClusterSG:clusterSecurityGroupId}'
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name `
  "$ClusterName" --query "$QueryText" --output json --no-cli-pager
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: Selected Public, Private, PublicCIDRs and ClusterSG report API reachability controls. Public access is not anonymous; private routing/SG and authentication/authorization remain separate.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0229 — Read actual cluster API / Service pool
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name \
  "$ClusterName" --query 'cluster.kubernetesNetworkConfig.serviceIpv4Cidr' --output text \
  --no-cli-pager
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: EXAMPLE ONLY: text 172.20.0.0/16 is the actual cluster Service pool if returned. Do not change an existing cluster to match. Membership helper separately compares the actual Service IP.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0229-ps — Read actual cluster API / Service pool · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name `
  "$ClusterName" --query 'cluster.kubernetesNetworkConfig.serviceIpv4Cidr' --output text `
  --no-cli-pager
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: EXAMPLE ONLY: text 172.20.0.0/16 is the actual cluster Service pool if returned. Do not change an existing cluster to match. Membership helper separately compares the actual Service IP.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0230 — Read actual cluster API / Service pool
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws eks update-kubeconfig --profile "$AwsProfile" --region "$Region" --name \
  "$ClusterName" --kubeconfig ./private-observation-kubeconfig.yaml --alias \
  unit06a-observe
```
Why / effect: AWS describe read plus LOCAL kubeconfig-file mutation; no cluster-configuration mutation.
Example / verify: Writes/merges the specifically selected PRIVATE local kubeconfig and context. This does not create/update an AWS cluster or grant Kubernetes access. Inspect only context/server, never raw credential dumps.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0230-ps — Read actual cluster API / Service pool · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws eks update-kubeconfig --profile "$AwsProfile" --region "$Region" --name `
  "$ClusterName" --kubeconfig ./private-observation-kubeconfig.yaml --alias `
  unit06a-observe
```
Why / effect: AWS describe read plus LOCAL kubeconfig-file mutation; no cluster-configuration mutation.
Example / verify: Writes/merges the specifically selected PRIVATE local kubeconfig and context. This does not create/update an AWS cluster or grant Kubernetes access. Inspect only context/server, never raw credential dumps.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0231 — Observe cluster objects without creating them
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe \
  config view --minify --output 'jsonpath={.clusters[0].cluster.server}'
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: OUTPUT SHAPE: only the selected local kubeconfig server URL, without raw credentials. Compare with actual EKS endpoint. This local read does not query the cluster or return Service CIDR.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0231-ps — Observe cluster objects without creating them · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe `
  config view --minify --output 'jsonpath={.clusters[0].cluster.server}'
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: OUTPUT SHAPE: only the selected local kubeconfig server URL, without raw credentials. Compare with actual EKS endpoint. This local read does not query the cluster or return Service CIDR.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0232 — Observe cluster objects without creating them
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe get \
  pods --all-namespaces --output wide
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: OUTPUT SHAPE: actual Pod rows with namespace, readiness/status and wide placement/address fields, or an explicit empty/failed result. No Pod creation; AWS describe success does not grant Kubernetes list permission.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0232-ps — Observe cluster objects without creating them · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe get `
  pods --all-namespaces --output wide
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: OUTPUT SHAPE: actual Pod rows with namespace, readiness/status and wide placement/address fields, or an explicit empty/failed result. No Pod creation; AWS describe success does not grant Kubernetes list permission.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0233 — Observe cluster objects without creating them
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe get \
  services --all-namespaces --output wide
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: OUTPUT SHAPE: Service rows identifying namespace/name, type, ClusterIP and ports, plus client-version-dependent wide fields. Headless None/ExternalName are exceptions; these are not physical ENI allocations.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0233-ps — Observe cluster objects without creating them · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe get `
  services --all-namespaces --output wide
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: OUTPUT SHAPE: Service rows identifying namespace/name, type, ClusterIP and ports, plus client-version-dependent wide fields. Headless None/ExternalName are exceptions; these are not physical ENI allocations.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0234 — Choose namespace and Service
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
Namespace="REPLACE_FROM_AUTHORIZED_SERVICE_LIST"
ServiceName="REPLACE_FROM_AUTHORIZED_SERVICE_LIST"

```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: Examples: endpoint https://EXAMPLE.invalid; Service CIDR 172.20.0.0/16. Read YOUR values, do not change them to match.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0235 — Choose namespace and Service
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
$Namespace = "REPLACE_FROM_AUTHORIZED_SERVICE_LIST"
$ServiceName = "REPLACE_FROM_AUTHORIZED_SERVICE_LIST"

```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: Examples: endpoint https://EXAMPLE.invalid; Service CIDR 172.20.0.0/16. Read YOUR values, do not change them to match.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0236 — Verify Service address and ready endpoints
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe \
  --namespace "$Namespace" describe service "$ServiceName"
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: OUTPUT SHAPE: the selected Service description, including selector, type, port/targetPort and related endpoint/event details as available. Read actual output; no application or load balancer is created.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0236-ps — Verify Service address and ready endpoints · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe `
  --namespace "$Namespace" describe service "$ServiceName"
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: OUTPUT SHAPE: the selected Service description, including selector, type, port/targetPort and related endpoint/event details as available. Read actual output; no application or load balancer is created.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0237 — Verify Service address and ready endpoints
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe \
  --namespace "$Namespace" get service "$ServiceName" --output \
  'jsonpath={.spec.clusterIP}'
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: OUTPUT SHAPE: actual selected ordinary Service ClusterIP scalar, for example illustrative 172.20.50.10. It is NOT Service CIDR or Pod IP. Interpret None/empty/non-ordinary Service exceptions before numeric membership checking.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0237-ps — Verify Service address and ready endpoints · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe `
  --namespace "$Namespace" get service "$ServiceName" --output `
  'jsonpath={.spec.clusterIP}'
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: OUTPUT SHAPE: actual selected ordinary Service ClusterIP scalar, for example illustrative 172.20.50.10. It is NOT Service CIDR or Pod IP. Interpret None/empty/non-ordinary Service exceptions before numeric membership checking.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0238 — Verify Service address and ready endpoints
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe \
  --namespace "$Namespace" get endpointslices --selector \
  "kubernetes.io/service-name=$ServiceName" --output yaml
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: OUTPUT SHAPE: selected EndpointSlice YAML, with endpoint addresses, conditions.ready and ports when present. Correlate namespace/Service-name selector and ready Pod backend; this is not a ClusterIP VPC route.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0238-ps — Verify Service address and ready endpoints · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe `
  --namespace "$Namespace" get endpointslices --selector `
  "kubernetes.io/service-name=$ServiceName" --output yaml
```
Why / effect: Optional existing cluster only; exact profile/Region/name selected earlier. No cluster or Service creation.
Example / verify: OUTPUT SHAPE: selected EndpointSlice YAML, with endpoint addresses, conditions.ready and ports when present. Correlate namespace/Service-name selector and ready Pod backend; this is not a ClusterIP VPC route.
On failure: No cluster/authorization: SKIP. AWS metadata access does not imply network reachability or Kubernetes RBAC access.

## r4t0239 — Read actual cluster authentication mode
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name \
  "$ClusterName" --query 'cluster.accessConfig' --output json --no-cli-pager
```
Why / effect: Existing authorized cluster + dedicated private kubeconfig only. Run reviewed commands one at a time.
Example / verify: accessConfig contains authenticationMode and bootstrapClusterCreatorAdminPermissions; actual API / API_AND_CONFIG_MAP / CONFIG_MAP determines the mechanism, not a permission grant.
On failure: Forbidden/AccessDenied means stop. Missing aws-auth may be normal in API-only mode; do not create/edit it.

## r4t0239-ps — Read actual cluster authentication mode · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name `
  "$ClusterName" --query 'cluster.accessConfig' --output json --no-cli-pager
```
Why / effect: Existing authorized cluster + dedicated private kubeconfig only. Run reviewed commands one at a time.
Example / verify: accessConfig contains authenticationMode and bootstrapClusterCreatorAdminPermissions; actual API / API_AND_CONFIG_MAP / CONFIG_MAP determines the mechanism, not a permission grant.
On failure: Forbidden/AccessDenied means stop. Missing aws-auth may be normal in API-only mode; do not create/edit it.

## r4t0240 — Optional legacy map READ — never edit
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe \
  --namespace kube-system get configmap aws-auth --output yaml
```
Why / effect: Existing authorized cluster + dedicated private kubeconfig only. Run reviewed commands one at a time.
Example / verify: OUTPUT SHAPE: actual kube-system/aws-auth ConfigMap metadata/data only if this mechanism is relevant AND you have authorized read access. API-only absence can be normal; Forbidden is not absence. No mapping is edited.
On failure: Forbidden/AccessDenied means stop. Missing aws-auth may be normal in API-only mode; do not create/edit it.

## r4t0240-ps — Optional legacy map READ — never edit · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context unit06a-observe `
  --namespace kube-system get configmap aws-auth --output yaml
```
Why / effect: Existing authorized cluster + dedicated private kubeconfig only. Run reviewed commands one at a time.
Example / verify: OUTPUT SHAPE: actual kube-system/aws-auth ConfigMap metadata/data only if this mechanism is relevant AND you have authorized read access. API-only absence can be normal; Forbidden is not absence. No mapping is edited.
On failure: Forbidden/AccessDenied means stop. Missing aws-auth may be normal in API-only mode; do not create/edit it.

## r4t0241 — Verify actual ServiceIP pool membership
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
ServiceCidr=$(aws eks describe-cluster --profile "$AwsProfile" --region "$Region" --name \
  "$ClusterName" --query 'cluster.kubernetesNetworkConfig.serviceIpv4Cidr' --output text \
  --no-cli-pager) || exit 1
ServiceIp=$(kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context \
  unit06a-observe --namespace "$Namespace" get service "$ServiceName" --output \
  'jsonpath={.spec.clusterIP}') || exit 1
python3 scripts/service_membership.py "$ServiceCidr" "$ServiceIp"
```
Why / effect: Two authorized read APIs, then a LOCAL numeric comparison; no AWS/Kubernetes mutation. Requires the selected existing cluster and dedicated private kubeconfig.
Example / verify: Final example shape: ClusterIP 172.20.50.10 in actual Service pool 172.20.0.0/16: True. Illustrative only. Outside/invalid exits nonzero; headless/ExternalName prints SKIP, not numeric proof.
On failure: Stop if either native read fails. Invalid/outside values stop locally. True proves numeric pool membership ONLY, not reachability, readiness, or permission.

## r4c0062 — Verify actual ServiceIP pool membership · 1/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
$ServiceCidr = aws eks describe-cluster --profile "$AwsProfile" --region "$Region" `
  --name "$ClusterName" --query 'cluster.kubernetesNetworkConfig.serviceIpv4Cidr' `
  --output text --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw "STOP: Service pool read failed" }
$ServiceIp = kubectl --kubeconfig ./private-observation-kubeconfig.yaml --context `
  unit06a-observe --namespace "$Namespace" get service "$ServiceName" --output `
  'jsonpath={.spec.clusterIP}'
if ($LASTEXITCODE -ne 0) { throw "STOP: Service read failed" }
```
Why / effect: AWS READ + Kubernetes READ: capture actual ServiceCidr and ServiceIp into PowerShell variables. Each native status is checked separately; no mutation.
Example / verify: The successful read values are CAPTURED, not printed as a comparison here: actual cluster Service pool and selected Service .spec.clusterIP. The following local-helper page prints the result.
On failure: Either AWS/Kubernetes denial, missing approved object or native failure throws STOP. No authenticationMode is queried; do not substitute a stale/failed response.
Complete block source: r4t0242-complete-source; visible contiguous lines [1, 8]

## r4c0063 — Verify actual ServiceIP pool membership · 2/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
py -3 scripts/service_membership.py "$ServiceCidr" "$ServiceIp"
if ($LASTEXITCODE -ne 0) { throw "STOP: Service membership check failed" }
```
Why / effect: LOCAL COMPARISON ONLY: Python checks the two successfully captured values. This page makes NO AWS or Kubernetes request and no cloud mutation.
Example / verify: Example: ClusterIP 172.20.50.10 in actual Service pool 172.20.0.0/16: True. Outside/invalid exits nonzero. Empty/None prints headless/ExternalName SKIP: not numeric membership proof.
On failure: The native failure check throws on invalid/outside/helper failure. True is numeric membership ONLY, not health or network delivery. SKIP requires checking the actual Service type.
Complete block source: r4t0242-complete-source; visible contiguous lines [9, 10]

## r4t0243 — Read VPC DNS · enableDnsSupport
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-vpc-attribute --profile "$AwsProfile" --region "$Region" --vpc-id \
  "$VpcId" --attribute enableDnsSupport --output json --no-cli-pager
```
Why / effect: AWS READ ONLY: inspect this one VPC DNS attribute using the approved VpcId; no mutation.
Example / verify: ILLUSTRATIVE JSON SHAPE: VpcId plus EnableDnsSupport.Value. For the intended EKS network, inspect this actual Value for true; the other DNS attribute requires its separate read.
On failure: ec2:DescribeVpcAttribute denied/wrong account/Region/ID? Stop. False requires network-owner review, not changing a shared VPC.

## r4t0243-ps — Read VPC DNS · enableDnsSupport · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-vpc-attribute --profile "$AwsProfile" --region "$Region" --vpc-id `
  "$VpcId" --attribute enableDnsSupport --output json --no-cli-pager
```
Why / effect: AWS READ ONLY: inspect this one VPC DNS attribute using the approved VpcId; no mutation.
Example / verify: ILLUSTRATIVE JSON SHAPE: VpcId plus EnableDnsSupport.Value. For the intended EKS network, inspect this actual Value for true; the other DNS attribute requires its separate read.
On failure: ec2:DescribeVpcAttribute denied/wrong account/Region/ID? Stop. False requires network-owner review, not changing a shared VPC.

## r4t0244 — Read VPC DNS · enableDnsHostnames
Terminal on YOUR computer · current directory: extracted unit06a/

```bash
aws ec2 describe-vpc-attribute --profile "$AwsProfile" --region "$Region" --vpc-id \
  "$VpcId" --attribute enableDnsHostnames --output json --no-cli-pager
```
Why / effect: AWS READ ONLY: inspect this one VPC DNS attribute using the approved VpcId; no mutation.
Example / verify: ILLUSTRATIVE JSON SHAPE: VpcId plus EnableDnsHostnames.Value. For the intended EKS network, inspect this actual Value for true; the other DNS attribute requires its separate read.
On failure: ec2:DescribeVpcAttribute denied/wrong account/Region/ID? Stop. False requires network-owner review, not changing a shared VPC.

## r4t0244-ps — Read VPC DNS · enableDnsHostnames · PowerShell alternative
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws ec2 describe-vpc-attribute --profile "$AwsProfile" --region "$Region" --vpc-id `
  "$VpcId" --attribute enableDnsHostnames --output json --no-cli-pager
```
Why / effect: AWS READ ONLY: inspect this one VPC DNS attribute using the approved VpcId; no mutation.
Example / verify: ILLUSTRATIVE JSON SHAPE: VpcId plus EnableDnsHostnames.Value. For the intended EKS network, inspect this actual Value for true; the other DNS attribute requires its separate read.
On failure: ec2:DescribeVpcAttribute denied/wrong account/Region/ID? Stop. False requires network-owner review, not changing a shared VPC.

## r4t0245 — Optional dedicated budget · review before mutation
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4c0064 — Optional budget · budget.json · 1 · 1/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```text
{
  "BudgetName": "unit06a-learning-alert",
  "BudgetLimit": {
    "Amount": "10",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST",
```
Why / effect: Dedicated monitoring budget only; amount and threshold are illustrative.
Example / verify: Full local JSON supplied; file:// avoids shell-specific inline JSON quoting.
On failure: Do not change/delete a shared budget. Keep BudgetAck=NO unless explicitly approved.
Complete block source: r4t0246-complete-source; visible contiguous lines [1, 8]

## r4c0065 — Optional budget · budget.json · 1 · 2/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```text
  "CostTypes": {
    "IncludeTax": true,
    "IncludeSubscription": true,
    "UseBlended": false
  },
  "CostFilters": {}
}
```
Why / effect: Dedicated monitoring budget only; amount and threshold are illustrative.
Example / verify: Full local JSON supplied; file:// avoids shell-specific inline JSON quoting.
On failure: Do not change/delete a shared budget. Keep BudgetAck=NO unless explicitly approved.
Complete block source: r4t0246-complete-source; visible contiguous lines [9, 15]

## r4t0247 — Optional budget · budget-notifications.json · 1
Save/read complete file examples/budget-notifications.json

```text
[
  {
    "Notification": {
      "NotificationType": "ACTUAL",
      "ComparisonOperator": "GREATER_THAN",
      "Threshold": 80,
      "ThresholdType": "PERCENTAGE"
    },
```
Why / effect: Dedicated monitoring budget only; amount and threshold are illustrative.
Example / verify: Full local JSON supplied; file:// avoids shell-specific inline JSON quoting.
On failure: Do not change/delete a shared budget. Keep BudgetAck=NO unless explicitly approved.

## r4t0248 — Optional budget · budget-notifications.json · 2
Save/read complete file examples/budget-notifications.json

```text
    "Subscribers": [
      {"SubscriptionType": "EMAIL", "Address": "REPLACE_WITH_YOUR_EMAIL"}
    ]
  }
]
```
Why / effect: Dedicated monitoring budget only; amount and threshold are illustrative.
Example / verify: Full local JSON supplied; file:// avoids shell-specific inline JSON quoting.
On failure: Do not change/delete a shared budget. Keep BudgetAck=NO unless explicitly approved.

## r4t0249 — Optional budget · budget-notification-query.json · 1
Save/read complete file examples/budget-notification-query.json

```text
{
  "NotificationType": "ACTUAL",
  "ComparisonOperator": "GREATER_THAN",
  "Threshold": 80,
  "ThresholdType": "PERCENTAGE"
}
```
Why / effect: Dedicated monitoring budget only; amount and threshold are illustrative.
Example / verify: Full local JSON supplied; file:// avoids shell-specific inline JSON quoting.
On failure: Do not change/delete a shared budget. Keep BudgetAck=NO unless explicitly approved.

## r4c0031 — Complete optional-budget LOCAL guard · 1/6
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```python
#!/usr/bin/env python3
"""Local optional-budget checks, not an AWS client or permission grant."""
import hashlib,json,pathlib,re,sys
E=pathlib.Path('examples')
def read(n):return json.loads((E/n).read_text())
def stop(ok,why):
    if not ok:raise SystemExit('STOP: '+why)
mode=sys.argv[1]
```
Why / effect: Read the entire local helper source: explicit account, absence and original-owner checks. It makes no AWS call.
Example / verify: Default path remains observation only; optional budget creation/deletion requires separate authorization.
On failure: Never manufacture or overwrite an owner record to adopt an existing budget.
Complete block source: OPTIONAL-BUDGET.md#fence-1; visible contiguous lines [1, 8]

## r4c0032 — Complete optional-budget LOCAL guard · 2/6
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```python
if mode=='prepare':
    name=sys.argv[2]
    stop(bool(re.fullmatch('unit06a-alert-[0-9a-f]{32}',name)),'use fresh generated name')
    b=read('budget.local.json');n=read('budget-notifications.local.json')
    stop('REPLACE' not in json.dumps(n),'edit YOUR private subscriber copy first')
    stop(all(x['SubscriptionType']=='EMAIL' and '@' in x['Address']
        for v in n for x in v['Subscribers']),'review authorized email destination')
    b['BudgetName']=name
```
Why / effect: Read the entire local helper source: explicit account, absence and original-owner checks. It makes no AWS call.
Example / verify: Default path remains observation only; optional budget creation/deletion requires separate authorization.
On failure: Never manufacture or overwrite an owner record to adopt an existing budget.
Complete block source: OPTIONAL-BUDGET.md#fence-1; visible contiguous lines [9, 16]

## r4c0033 — Complete optional-budget LOCAL guard · 3/6
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```python
    (E/'budget.local.json').write_text(json.dumps(b,indent=2)+'\n')
elif mode=='identity':
    d=read('budget-identity.local.json');expected=sys.argv[2]
    stop(bool(re.fullmatch('[0-9]{12}',expected)),'twelve-digit intended account required')
    stop(d['Account']==expected and not d['Arn'].endswith(':root'),'wrong account/root')
elif mode=='absent':
    s=(E/'budget-probe.local.err').read_text()
    stop('An error occurred (NotFoundException)' in s,'read failed; NOT proof of absence')
```
Why / effect: Read the entire local helper source: explicit account, absence and original-owner checks. It makes no AWS call.
Example / verify: Default path remains observation only; optional budget creation/deletion requires separate authorization.
On failure: Never manufacture or overwrite an owner record to adopt an existing budget.
Complete block source: OPTIONAL-BUDGET.md#fence-1; visible contiguous lines [17, 24]

## r4c0034 — Complete optional-budget LOCAL guard · 4/6
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```python
elif mode=='record':
    account,profile,generation=sys.argv[2:]
    b=read('budget.local.json');name=b['BudgetName']
    stop(name=='unit06a-alert-'+generation,'name/generation mismatch')
    owner={'account':account,'profile':profile,'generation':generation,'name':name,
      'arn':'arn:aws:budgets::'+account+':budget/'+name,
      'budget':{k:b[k] for k in ['BudgetName','BudgetLimit','TimeUnit','BudgetType']}}
    with (E/'budget-owner.local.json').open('x') as f:json.dump(owner,f,indent=2)
```
Why / effect: Read the entire local helper source: explicit account, absence and original-owner checks. It makes no AWS call.
Example / verify: Default path remains observation only; optional budget creation/deletion requires separate authorization.
On failure: Never manufacture or overwrite an owner record to adopt an existing budget.
Complete block source: OPTIONAL-BUDGET.md#fence-1; visible contiguous lines [25, 32]

## r4c0035 — Complete optional-budget LOCAL guard · 5/6
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```python
elif mode=='field':
    key=sys.argv[2];stop(key in ['name','arn','generation'],'unsupported field')
    print(read('budget-owner.local.json')[key])
elif mode=='verify-owner':
    account,profile=sys.argv[2:];o=read('budget-owner.local.json')
    stop(o['account']==account and o['profile']==profile,'recorded owner/account differs')
    b=read('budget-readback.local.json')['Budget']
    stop(all(b.get(k)==v for k,v in o['budget'].items()),'budget differs from creation record')
```
Why / effect: Read the entire local helper source: explicit account, absence and original-owner checks. It makes no AWS call.
Example / verify: Default path remains observation only; optional budget creation/deletion requires separate authorization.
On failure: Never manufacture or overwrite an owner record to adopt an existing budget.
Complete block source: OPTIONAL-BUDGET.md#fence-1; visible contiguous lines [33, 40]

## r4c0036 — Complete optional-budget LOCAL guard · 6/6
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```python
    tags={v['Key']:v['Value'] for v in read('budget-tags.local.json')['ResourceTags']}
    stop(tags.get('EksClassOwner')=='unit06a' and
         tags.get('EksClassGeneration')==o['generation'],'live original generation tag differs')
else:raise SystemExit('STOP: unsupported local guard mode')
```
Why / effect: Read the entire local helper source: explicit account, absence and original-owner checks. It makes no AWS call.
Example / verify: Default path remains observation only; optional budget creation/deletion requires separate authorization.
On failure: Never manufacture or overwrite an owner record to adopt an existing budget.
Complete block source: OPTIONAL-BUDGET.md#fence-1; visible contiguous lines [41, 44]

## r4c0037 — Private copies, exact fresh name, explicit acknowledgment · 1/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
BudgetAck="NO"
[ "$BudgetAck" = "YES_CREATE_MY_DEDICATED_ALERT" ] || exit 1
[ ! -e examples/budget-owner.local.json ] || exit 1
cp examples/budget.json examples/budget.local.json || exit 1
cp examples/budget-notifications.json \
  examples/budget-notifications.local.json || exit 1
BudgetGeneration=$(python3 -c 'import uuid;print(uuid.uuid4().hex)') || exit 1
BudgetName="unit06a-alert-$BudgetGeneration"
```
Why / effect: Only YOUR authorized subscriber destination in ignored local JSON; bind the actual generated name to BudgetName before any creation.
Example / verify: Default NO stops. Successful preparation changes local files only; do not commit email/account metadata.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-2; visible contiguous lines [1, 8]

## r4c0038 — Private copies, exact fresh name, explicit acknowledgment · 2/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
# Edit ONLY the private notifications copy: replace YOUR email marker locally.
python3 scripts/budget_guard.py prepare "$BudgetName" || exit 1
```
Why / effect: Only YOUR authorized subscriber destination in ignored local JSON; bind the actual generated name to BudgetName before any creation.
Example / verify: Default NO stops. Successful preparation changes local files only; do not commit email/account metadata.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-2; visible contiguous lines [9, 10]

## r4c0039 — Fresh intended-account/non-root guard
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" \
  --output json --no-cli-pager > examples/budget-identity.local.json || exit 1
python3 scripts/budget_guard.py identity "$ExpectedAccount" || exit 1
```
Why / effect: Immediately prove the profile still selects the intended sandbox. A successful different-account response is a STOP, not a new expected-account value.
Example / verify: Identity JSON Account equals independently approved ExpectedAccount; no root principal.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-3; visible contiguous lines [1, 3]

## r4c0040 — Existing name versus failed read
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

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
Why / effect: ONLY a specific NotFoundException allows the fresh optional creation to continue. Existing budget, AccessDenied, timeout or malformed result STOP.
Example / verify: NotFound is the expected fresh-name probe outcome. Never delete/recreate a collision.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-4; visible contiguous lines [1, 8]

## r4c0041 — Authorized budget creation and write-once owner record
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

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
Why / effect: AWS MUTATION: create one monitoring-only budget with original generation tag; then record ownership ONLY after successful create. No Terraform co-owner.
Example / verify: Create may return empty stdout. That is not verification; next readback must match original name/config/generation.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-5; visible contiguous lines [1, 8]

## r4c0042 — Read actual budget, tags, notification and subscriber · 1/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
aws budgets describe-budget --profile "$AwsProfile" --region us-east-1 \
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" \
  --output json --no-cli-pager > examples/budget-readback.local.json || exit 1
aws budgets list-tags-for-resource --profile "$AwsProfile" --region us-east-1 \
  --resource-arn "$BudgetArn" --output json --no-cli-pager \
  > examples/budget-tags.local.json || exit 1
python3 scripts/budget_guard.py verify-owner "$ExpectedAccount" "$AwsProfile" || exit 1
aws budgets describe-notifications-for-budget --profile "$AwsProfile" \
```
Why / effect: AWS READS, not another mutation. Compare actual settings and original generation; keep the returned email/account information private.
Example / verify: Illustrative USD10 MONTHLY ACTUAL80% threshold; YOUR privately read configuration must agree. Delivery may lag; no cap or automatic cleanup.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-6; visible contiguous lines [1, 8]

## r4c0043 — Read actual budget, tags, notification and subscriber · 2/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
  --region us-east-1 --account-id "$ExpectedAccount" \
  --budget-name "$BudgetName" --output json --no-cli-pager || exit 1
aws budgets describe-subscribers-for-notification --profile "$AwsProfile" \
  --region us-east-1 --account-id "$ExpectedAccount" --budget-name "$BudgetName" \
  --notification file://examples/budget-notification-query.json \
  --output json --no-cli-pager || exit 1
```
Why / effect: AWS READS, not another mutation. Compare actual settings and original generation; keep the returned email/account information private.
Example / verify: Illustrative USD10 MONTHLY ACTUAL80% threshold; YOUR privately read configuration must agree. Delivery may lag; no cap or automatic cleanup.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-6; visible contiguous lines [9, 14]

## r4c0044 — Before deletion: recorded ownership AND fresh identity · 1/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
BudgetDeleteAck="NO"
[ "$BudgetDeleteAck" = "YES_DELETE_ONLY_MY_RECORDED_ALERT" ] || exit 1
BudgetName=$(python3 scripts/budget_guard.py field name) || exit 1
BudgetArn=$(python3 scripts/budget_guard.py field arn) || exit 1

aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" \
  --output json --no-cli-pager > examples/budget-identity.local.json || exit 1
python3 scripts/budget_guard.py identity "$ExpectedAccount" || exit 1
```
Why / effect: Choose explicit deletion acknowledgment, load only the original owned name/ARN, recheck account and current original-generation tags immediately before delete.
Example / verify: No valid original record, mismatch, unreadable tags or wrong account means STOP; never adopt a same-name replacement.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-7; visible contiguous lines [1, 8]

## r4c0045 — Before deletion: recorded ownership AND fresh identity · 2/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash

aws budgets describe-budget --profile "$AwsProfile" --region us-east-1 \
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" \
  --output json --no-cli-pager > examples/budget-readback.local.json || exit 1
aws budgets list-tags-for-resource --profile "$AwsProfile" --region us-east-1 \
  --resource-arn "$BudgetArn" --output json --no-cli-pager \
  > examples/budget-tags.local.json || exit 1
python3 scripts/budget_guard.py verify-owner "$ExpectedAccount" "$AwsProfile" || exit 1
```
Why / effect: Choose explicit deletion acknowledgment, load only the original owned name/ARN, recheck account and current original-generation tags immediately before delete.
Example / verify: No valid original record, mismatch, unreadable tags or wrong account means STOP; never adopt a same-name replacement.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-7; visible contiguous lines [9, 16]

## r4c0046 — Delete only original owned alert; verify specific absence · 1/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
aws budgets delete-budget --profile "$AwsProfile" --region us-east-1 \
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" --no-cli-pager || exit 1
if aws budgets describe-budget --profile "$AwsProfile" --region us-east-1 \
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" \
  --output json --no-cli-pager > examples/budget-probe.local.json \
  2> examples/budget-probe.local.err; then
  printf '%s\n' 'STOP: budget still returned; inspect before claiming deletion'; exit 1
else
```
Why / effect: AWS MUTATION only after the preceding adjacent checks. Delete-budget removes a monitoring object, not infrastructure and not spend.
Example / verify: Specific NotFoundException for this budget is expected afterward. Denied/failed read is NOT successful deletion.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-8; visible contiguous lines [1, 8]

## r4c0047 — Delete only original owned alert; verify specific absence · 2/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```bash
  python3 scripts/budget_guard.py absent || exit 1
fi
```
Why / effect: AWS MUTATION only after the preceding adjacent checks. Delete-budget removes a monitoring object, not infrastructure and not spend.
Example / verify: Specific NotFoundException for this budget is expected afterward. Denied/failed read is NOT successful deletion.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-8; visible contiguous lines [9, 10]

## r4c0048 — Private copies, exact fresh name, explicit acknowledgment · 1/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
$ErrorActionPreference = "Stop"
$BudgetAck = "NO"
if ($BudgetAck -ne "YES_CREATE_MY_DEDICATED_ALERT") { throw 'STOP: not approved' }
if (Test-Path examples/budget-owner.local.json) { throw 'STOP: existing owner record' }
Copy-Item examples/budget.json examples/budget.local.json -ErrorAction Stop
Copy-Item examples/budget-notifications.json `
  examples/budget-notifications.local.json -ErrorAction Stop
$BudgetGeneration = [guid]::NewGuid().ToString('N')
```
Why / effect: Only YOUR authorized subscriber destination in ignored local JSON; bind the actual generated name to BudgetName before any creation.
Example / verify: Default NO stops. Successful preparation changes local files only; do not commit email/account metadata.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-9; visible contiguous lines [1, 8]

## r4c0049 — Private copies, exact fresh name, explicit acknowledgment · 2/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
$BudgetName = "unit06a-alert-$BudgetGeneration"
# Edit ONLY the private notifications copy: replace YOUR email marker locally.
py -3 scripts/budget_guard.py prepare "$BudgetName"
if ($LASTEXITCODE -ne 0) { throw 'STOP: private JSON validation failed' }
```
Why / effect: Only YOUR authorized subscriber destination in ignored local JSON; bind the actual generated name to BudgetName before any creation.
Example / verify: Default NO stops. Successful preparation changes local files only; do not commit email/account metadata.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-9; visible contiguous lines [9, 12]

## r4c0050 — Fresh intended-account/non-root guard
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" `
  --output json --no-cli-pager > examples/budget-identity.local.json
if ($LASTEXITCODE -ne 0) { throw 'STOP: fresh identity read failed' }
py -3 scripts/budget_guard.py identity "$ExpectedAccount"
if ($LASTEXITCODE -ne 0) { throw 'STOP: intended account/root guard failed' }
```
Why / effect: Immediately prove the profile still selects the intended sandbox. A successful different-account response is a STOP, not a new expected-account value.
Example / verify: Identity JSON Account equals independently approved ExpectedAccount; no root principal.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-10; visible contiguous lines [1, 5]

## r4c0051 — Existing name versus failed read
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
aws budgets describe-budget --profile "$AwsProfile" --region us-east-1 `
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" `
  --output json --no-cli-pager > examples/budget-probe.local.json `
  2> examples/budget-probe.local.err
if ($LASTEXITCODE -eq 0) { throw 'STOP: existing budget; never adopt it' }
py -3 scripts/budget_guard.py absent
if ($LASTEXITCODE -ne 0) { throw 'STOP: read failure is not absence' }
```
Why / effect: ONLY a specific NotFoundException allows the fresh optional creation to continue. Existing budget, AccessDenied, timeout or malformed result STOP.
Example / verify: NotFound is the expected fresh-name probe outcome. Never delete/recreate a collision.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-11; visible contiguous lines [1, 7]

## r4c0052 — Authorized budget creation and write-once owner record · 1/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
aws budgets create-budget --profile "$AwsProfile" --region us-east-1 `
  --account-id "$ExpectedAccount" --budget file://examples/budget.local.json `
  --notifications-with-subscribers file://examples/budget-notifications.local.json `
  --resource-tags Key=EksClassOwner,Value=unit06a `
  "Key=EksClassGeneration,Value=$BudgetGeneration" --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw 'STOP: creation failed; no owner record written' }
py -3 scripts/budget_guard.py record `
  "$ExpectedAccount" "$AwsProfile" "$BudgetGeneration"
```
Why / effect: AWS MUTATION: create one monitoring-only budget with original generation tag; then record ownership ONLY after successful create. No Terraform co-owner.
Example / verify: Create may return empty stdout. That is not verification; next readback must match original name/config/generation.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-12; visible contiguous lines [1, 8]

## r4c0053 — Authorized budget creation and write-once owner record · 2/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
if ($LASTEXITCODE -ne 0) { throw 'STOP: keep evidence; ownership recording failed' }
$BudgetArn = py -3 scripts/budget_guard.py field arn
if ($LASTEXITCODE -ne 0) { throw 'STOP: owner record read failed' }
```
Why / effect: AWS MUTATION: create one monitoring-only budget with original generation tag; then record ownership ONLY after successful create. No Terraform co-owner.
Example / verify: Create may return empty stdout. That is not verification; next readback must match original name/config/generation.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-12; visible contiguous lines [9, 11]

## r4c0054 — Read actual budget, tags, notification and subscriber · 1/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
aws budgets describe-budget --profile "$AwsProfile" --region us-east-1 `
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" `
  --output json --no-cli-pager > examples/budget-readback.local.json
if ($LASTEXITCODE -ne 0) { throw 'STOP: readback failed' }
aws budgets list-tags-for-resource --profile "$AwsProfile" --region us-east-1 `
  --resource-arn "$BudgetArn" --output json --no-cli-pager `
  > examples/budget-tags.local.json
if ($LASTEXITCODE -ne 0) { throw 'STOP: live generation tags unreadable' }
```
Why / effect: AWS READS, not another mutation. Compare actual settings and original generation; keep the returned email/account information private.
Example / verify: Illustrative USD10 MONTHLY ACTUAL80% threshold; YOUR privately read configuration must agree. Delivery may lag; no cap or automatic cleanup.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-13; visible contiguous lines [1, 8]

## r4c0055 — Read actual budget, tags, notification and subscriber · 2/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
py -3 scripts/budget_guard.py verify-owner "$ExpectedAccount" "$AwsProfile"
if ($LASTEXITCODE -ne 0) { throw 'STOP: original ownership differs' }
aws budgets describe-notifications-for-budget --profile "$AwsProfile" `
  --region us-east-1 --account-id "$ExpectedAccount" `
  --budget-name "$BudgetName" --output json --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw 'STOP: notification read failed' }
aws budgets describe-subscribers-for-notification --profile "$AwsProfile" `
  --region us-east-1 --account-id "$ExpectedAccount" --budget-name "$BudgetName" `
```
Why / effect: AWS READS, not another mutation. Compare actual settings and original generation; keep the returned email/account information private.
Example / verify: Illustrative USD10 MONTHLY ACTUAL80% threshold; YOUR privately read configuration must agree. Delivery may lag; no cap or automatic cleanup.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-13; visible contiguous lines [9, 16]

## r4c0056 — Read actual budget, tags, notification and subscriber · 3/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
  --notification file://examples/budget-notification-query.json `
  --output json --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw 'STOP: subscriber read failed' }
```
Why / effect: AWS READS, not another mutation. Compare actual settings and original generation; keep the returned email/account information private.
Example / verify: Illustrative USD10 MONTHLY ACTUAL80% threshold; YOUR privately read configuration must agree. Delivery may lag; no cap or automatic cleanup.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-13; visible contiguous lines [17, 19]

## r4c0057 — Before deletion: recorded ownership AND fresh identity · 1/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
$ErrorActionPreference = "Stop"
$BudgetDeleteAck = "NO"
if ($BudgetDeleteAck -ne "YES_DELETE_ONLY_MY_RECORDED_ALERT") { throw 'STOP: not approved' }
$BudgetName = py -3 scripts/budget_guard.py field name
if ($LASTEXITCODE -ne 0) { throw 'STOP: no original name record' }
$BudgetArn = py -3 scripts/budget_guard.py field arn
if ($LASTEXITCODE -ne 0) { throw 'STOP: no original ARN record' }

```
Why / effect: Choose explicit deletion acknowledgment, load only the original owned name/ARN, recheck account and current original-generation tags immediately before delete.
Example / verify: No valid original record, mismatch, unreadable tags or wrong account means STOP; never adopt a same-name replacement.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-14; visible contiguous lines [1, 8]

## r4c0058 — Before deletion: recorded ownership AND fresh identity · 2/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" `
  --output json --no-cli-pager > examples/budget-identity.local.json
if ($LASTEXITCODE -ne 0) { throw 'STOP: fresh identity read failed' }
py -3 scripts/budget_guard.py identity "$ExpectedAccount"
if ($LASTEXITCODE -ne 0) { throw 'STOP: intended account/root guard failed' }

aws budgets describe-budget --profile "$AwsProfile" --region us-east-1 `
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" `
```
Why / effect: Choose explicit deletion acknowledgment, load only the original owned name/ARN, recheck account and current original-generation tags immediately before delete.
Example / verify: No valid original record, mismatch, unreadable tags or wrong account means STOP; never adopt a same-name replacement.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-14; visible contiguous lines [9, 16]

## r4c0059 — Before deletion: recorded ownership AND fresh identity · 3/3
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
  --output json --no-cli-pager > examples/budget-readback.local.json
if ($LASTEXITCODE -ne 0) { throw 'STOP: readback failed' }
aws budgets list-tags-for-resource --profile "$AwsProfile" --region us-east-1 `
  --resource-arn "$BudgetArn" --output json --no-cli-pager `
  > examples/budget-tags.local.json
if ($LASTEXITCODE -ne 0) { throw 'STOP: live generation tags unreadable' }
py -3 scripts/budget_guard.py verify-owner "$ExpectedAccount" "$AwsProfile"
if ($LASTEXITCODE -ne 0) { throw 'STOP: original ownership differs' }
```
Why / effect: Choose explicit deletion acknowledgment, load only the original owned name/ARN, recheck account and current original-generation tags immediately before delete.
Example / verify: No valid original record, mismatch, unreadable tags or wrong account means STOP; never adopt a same-name replacement.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-14; visible contiguous lines [17, 24]

## r4c0060 — Delete only original owned alert; verify specific absence · 1/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
aws budgets delete-budget --profile "$AwsProfile" --region us-east-1 `
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw 'STOP: deletion request failed' }
aws budgets describe-budget --profile "$AwsProfile" --region us-east-1 `
  --account-id "$ExpectedAccount" --budget-name "$BudgetName" `
  --output json --no-cli-pager > examples/budget-probe.local.json `
  2> examples/budget-probe.local.err
if ($LASTEXITCODE -eq 0) { throw 'STOP: budget still returned' }
```
Why / effect: AWS MUTATION only after the preceding adjacent checks. Delete-budget removes a monitoring object, not infrastructure and not spend.
Example / verify: Specific NotFoundException for this budget is expected afterward. Denied/failed read is NOT successful deletion.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-15; visible contiguous lines [1, 8]

## r4c0061 — Delete only original owned alert; verify specific absence · 2/2
Terminal on YOUR computer · START in extracted unit06a/ · directory changes shown explicitly

```powershell
py -3 scripts/budget_guard.py absent
if ($LASTEXITCODE -ne 0) { throw 'STOP: failed read is NOT proof of deletion' }
```
Why / effect: AWS MUTATION only after the preceding adjacent checks. Delete-budget removes a monitoring object, not infrastructure and not spend.
Example / verify: Specific NotFoundException for this budget is expected afterward. Denied/failed read is NOT successful deletion.
On failure: Any denied/failed read, wrong account, collision, changed ownership, file/native error or ambiguous absence must STOP before the next mutation.
Complete block source: OPTIONAL-BUDGET.md#fence-15; visible contiguous lines [9, 10]

## r4t0256 — Your private worksheet for Unit 6B
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0257 — Troubleshoot evidence, not assumptions
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0258 — Practice: clean up, and keep what Unit 6B needs
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0259 — Finish without deleting another owner's resources
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws logout --profile "$AwsProfile"
```
Why / effect: LOCAL sign-out, not resource cleanup.
Example / verify: Removes the selected AWS-login local session; cloud resources and charges are unchanged.
On failure: Never delete discovered objects or blindly destroy state. Optional budget cleanup requires recorded ownership.

## r4t0260 — Finish without deleting another owner's resources
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
aws sso logout
```
Why / effect: LOCAL cached SSO-session logout, not per-resource cleanup.
Example / verify: Removes cached IAM Identity Center sessions; other profiles sharing those cached sessions can be affected. No AWS resources are removed.
On failure: Never delete discovered objects or blindly destroy state. Optional budget cleanup requires recorded ownership.

## r4t0261 — Finish without deleting another owner's resources
Terminal on YOUR computer · current directory: extracted unit06a/

```powershell
# Local state inventory; no cloud deletion:
terraform -chdir=terraform/offline state list
terraform -chdir=terraform/read-only state list
```
Why / effect: Default path created no cloud infrastructure. Choose only the logout method you used.
Example / verify: Logout removes local sessions, not AWS resources. Data-only local state cleanup is NOT cloud deletion.
On failure: Never delete discovered objects or blindly destroy state. Optional budget cleanup requires recorded ownership.

## r4t0262 — Unit summary · ready means understood
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.

## r4t0263 — Thank you
Matching practice: API-SERVICE-FOUNDATIONS.md / FOLLOW-ALONG.md / NETWORK-VERIFY.md; real data observations in terraform/read-only/, local capacity in terraform/offline/. No invented Terraform effective-permission or datapath evaluator.
