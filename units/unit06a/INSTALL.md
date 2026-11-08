# Install on YOUR computer — complete selected OS path, explicit failure gates

Choose only your real OS/CPU; do not run every alternative. Downloads/installers change local files and require organizational approval. No installation was performed by the builder. Start in extracted unit06a; PracticeDir preserves that actual path. Python3 and GPG prerequisite installation must follow your approved OS installer. Windows requires PowerShell7; native exits are checked explicitly. Open Terminal and select Bash on macOS. Existing managed installs: ask IT/update correctly rather than overwriting or disabling protections.

## Complete LOCAL verification helper — shown before use
The full source below is shipped at scripts/verify_download.py. It reads only downloaded files, raises an error on mismatch and cannot install anything. Every caller explicitly stops on its failure; no assumed set-e.

```python
#!/usr/bin/env python3
"""Local integrity check only: no AWS, install or hidden download."""
import hashlib,pathlib,re,sys
mode,name,checks=sys.argv[1:]
p=pathlib.Path(name)
actual=hashlib.sha256(p.read_bytes()).hexdigest()
text=pathlib.Path(checks).read_text().strip()
if mode=="sha256-list":
    rows=[x.split() for x in text.splitlines()]
    matches=[a for a,b in rows if b.lstrip("*")==p.name]
    if len(matches)!=1:raise SystemExit("STOP: no unique checksum entry")
    expected=matches[0]
elif mode=="sha256":expected=text
else:raise SystemExit("STOP: unknown verification mode")
if not re.fullmatch("[0-9a-fA-F]{64}",expected):
    raise SystemExit("STOP: malformed checksum")
if actual.lower()!=expected.lower():
    raise SystemExit("STOP: checksum mismatch")
print("Publisher HTTPS checksum matches; not independent signature proof")
```

Complete macOS publisher helper, scripts/verify_macos_publisher.py:

```python
#!/usr/bin/env python3
"""Local macOS publisher check after pkgutil signature verification succeeds."""
import re,sys
text=sys.stdin.read()
if not re.search(r"Developer ID Installer: Amazon Web Services, Inc[.]? \([A-Z0-9]+\)",text):
    raise SystemExit("STOP: expected Amazon installer publisher not present")
print("Expected Amazon publisher identified; Gatekeeper must still succeed")
```

## Linux only: authorized Ubuntu/Debian prerequisites
Package installation changes YOUR computer; organizational approval required. Other distributions use their supported package manager instead.

```bash
sudo apt-get update || exit 1
sudo apt-get install -y ca-certificates curl unzip python3 gnupg || exit 1
```
No AWS request. This block is Ubuntu/Debian only; never run both platform alternatives.

## Linux: select your actual CPU, then download
Start in the actual extracted unit06a folder. uname identifies CPU; BOTH actual architecture variables are set before URL construction.

```bash
PracticeDir=$(pwd) || exit 1
[ -f "$PracticeDir/README.md" ] || exit 1
case "$(uname -m)" in
  x86_64) AwsArch="x86_64"; TfArch="amd64" ;;
  aarch64|arm64) AwsArch="aarch64"; TfArch="arm64" ;;
  *) printf '%s\n' 'STOP: unsupported CPU'; exit 1 ;;
esac
mkdir -p "$HOME/Downloads/unit06a-tools" || exit 1
cd "$HOME/Downloads/unit06a-tools" || exit 1
AwsBase="https://awscli.amazonaws.com"
AwsZip="awscli-exe-linux-${AwsArch}.zip"
curl --fail --location "$AwsBase/$AwsZip" --output awscliv2.zip || exit 1
curl --fail --location "$AwsBase/$AwsZip.sig" --output awscliv2.sig || exit 1
```
Expected local downloads only. x86_64 maps AWS x86_64/Terraform amd64; ARM maps aarch64/arm64. No blank architecture fallback.

## Linux: verify publisher BEFORE extraction
Full official PUBLIC key is supplied; verify its fingerprint against AWS docs. A downloaded .sig is not itself verification. Failed signature explicitly prevents unzip/install.

```bash
KeyFile="$PracticeDir/examples/awscli-public-key.asc"
KeyInfo=$(gpg --show-keys --with-colons "$KeyFile") || exit 1
Fingerprint=$(printf '%s\n' "$KeyInfo" | awk -F: '$1=="fpr" {print $10;exit}')
ExpectedFingerprint="FB5DB77FD5C118B80511ADA8A6310ACC4672475C"
[ "$Fingerprint" = "$ExpectedFingerprint" ] || exit 1
gpg --import "$KeyFile" || exit 1
gpg --verify awscliv2.sig awscliv2.zip || exit 1
unzip awscliv2.zip || exit 1
mkdir -p "$HOME/.local/bin" || exit 1
./aws/install --install-dir "$HOME/.local/aws-cli" \
  --bin-dir "$HOME/.local/bin" || exit 1
export PATH="$HOME/.local/bin:$PATH"
aws --version || exit 1
cd "$PracticeDir" || exit 1
```
Good signature plus published fingerprint; aws-cli/2.x after success. Missing GPG means ask IT, never skip verification.

## Linux: complete Terraform checksum/install path
The complete selected CPU/OS archive name and checksum-list check precede any extraction. A real mismatch must stop before unzip, independent of set-e.

```bash
PracticeDir=$(pwd) || exit 1
[ -f "$PracticeDir/README.md" ] || exit 1
case "$(uname -m)" in
  x86_64) TfArch="amd64" ;;
  aarch64|arm64) TfArch="arm64" ;;
  *) printf '%s\n' 'STOP: unsupported CPU'; exit 1 ;;
esac
TfVersion="1.13.5"
TfFile="terraform_${TfVersion}_linux_${TfArch}.zip"
TfBase="https://releases.hashicorp.com/terraform/$TfVersion"
curl --fail --location "$TfBase/$TfFile" --output "$TfFile" || exit 1
curl --fail --location "$TfBase/terraform_${TfVersion}_SHA256SUMS" \
  --output terraform_SHA256SUMS || exit 1
python3 "$PracticeDir/scripts/verify_download.py" \
  sha256-list "$TfFile" terraform_SHA256SUMS || exit 1
unzip "$TfFile" terraform || exit 1
mkdir -p "$HOME/.local/bin" || exit 1
install -m 0755 terraform "$HOME/.local/bin/terraform" || exit 1
export PATH="$HOME/.local/bin:$PATH"
terraform version || exit 1
python3 --version || exit 1
cd "$PracticeDir" || exit 1
```
Terraform1.13.5 and Python3. HTTPS checksum match is not independent PGP verification; HashiCorp signed-checksum guidance remains in references.

## macOS: complete Terraform checksum/install path
The complete selected CPU/OS archive name and checksum-list check precede any extraction. A real mismatch must stop before unzip, independent of set-e.

```bash
PracticeDir=$(pwd) || exit 1
[ -f "$PracticeDir/README.md" ] || exit 1
case "$(uname -m)" in
  x86_64) TfArch="amd64" ;;
  arm64) TfArch="arm64" ;;
  *) printf '%s\n' 'STOP: unsupported CPU'; exit 1 ;;
esac
mkdir -p "$HOME/Downloads/unit06a-tools" || exit 1
cd "$HOME/Downloads/unit06a-tools" || exit 1
TfVersion="1.13.5"
TfFile="terraform_${TfVersion}_darwin_${TfArch}.zip"
TfBase="https://releases.hashicorp.com/terraform/$TfVersion"
curl --fail --location "$TfBase/$TfFile" --output "$TfFile" || exit 1
curl --fail --location "$TfBase/terraform_${TfVersion}_SHA256SUMS" \
  --output terraform_SHA256SUMS || exit 1
python3 "$PracticeDir/scripts/verify_download.py" \
  sha256-list "$TfFile" terraform_SHA256SUMS || exit 1
unzip "$TfFile" terraform || exit 1
mkdir -p "$HOME/.local/bin" || exit 1
install -m 0755 terraform "$HOME/.local/bin/terraform" || exit 1
export PATH="$HOME/.local/bin:$PATH"
terraform version || exit 1
python3 --version || exit 1
cd "$PracticeDir" || exit 1
```
Terraform1.13.5 and Python3. HTTPS checksum match is not independent PGP verification; HashiCorp signed-checksum guidance remains in references.

## macOS: verify package before opening Installer
Native package signature AND Gatekeeper assessment must succeed before opening Installer; inspect Amazon publisher against AWS docs. Do not disable Gatekeeper.

```bash
PracticeDir=$(pwd) || exit 1
[ -f "$PracticeDir/README.md" ] || exit 1
mkdir -p "$HOME/Downloads/unit06a-tools" || exit 1
cd "$HOME/Downloads/unit06a-tools" || exit 1
curl --fail --location https://awscli.amazonaws.com/AWSCLIV2.pkg \
  --output AWSCLIV2.pkg || exit 1
SignatureInfo=$(pkgutil --check-signature AWSCLIV2.pkg) || exit 1
printf '%s\n' "$SignatureInfo" | \
  python3 "$PracticeDir/scripts/verify_macos_publisher.py" || exit 1
spctl --assess --type install AWSCLIV2.pkg || exit 1
# Signature, Amazon publisher and Gatekeeper must ALL pass before opening.
open AWSCLIV2.pkg || exit 1
cd "$PracticeDir" || exit 1
```
Complete the normal approved installer, reopen Terminal/Bash and run aws --version. Mac commands are not Linux commands.

## Windows x64 PowerShell7: publisher gate
Invoke-WebRequest errors terminate; Valid signature alone is not enough: publisher must match approved Amazon identities. Check installer exit,3010 requests restart.

```powershell
$ErrorActionPreference = "Stop"
$PracticeDir = (Get-Location).Path
if (-not (Test-Path "$PracticeDir/README.md")) { throw 'STOP: start in practice folder' }
New-Item -ItemType Directory -Force "$HOME/Downloads/unit06a-tools" | Out-Null
Set-Location "$HOME/Downloads/unit06a-tools"
Invoke-WebRequest https://awscli.amazonaws.com/AWSCLIV2.msi -OutFile AWSCLIV2.msi
$Signature = Get-AuthenticodeSignature .\AWSCLIV2.msi
$Publishers = @('Amazon Web Services, Inc.', 'Amazon.com Services LLC', 'Amazon.com, Inc.')
$Known = $Publishers | Where-Object { $Signature.SignerCertificate.Subject.Contains($_) }
if ($Signature.Status -ne 'Valid' -or -not $Known) { throw 'STOP: publisher/signature' }
$Process = Start-Process msiexec.exe -ArgumentList '/i AWSCLIV2.msi' -Wait -PassThru
if ($Process.ExitCode -notin @(0,3010)) { throw 'STOP: MSI installation failed' }
Set-Location $PracticeDir
```
No AWS resource request. Reopen PowerShell for PATH; install approved Python3 normally if absent, then verify py -3 --version.

## Windows: complete Terraform portable install
Windows uses amd64 portable ZIP; exact checksum check must succeed before Expand-Archive. Current session PATH only; never overwrite unrelated binaries.

```powershell
$ErrorActionPreference = "Stop"
$PracticeDir = (Get-Location).Path
if (-not (Test-Path "$PracticeDir/README.md")) { throw 'STOP: start in practice folder' }
$TfVersion = "1.13.5"
$TfFile = "terraform_${TfVersion}_windows_amd64.zip"
$TfBase = "https://releases.hashicorp.com/terraform/$TfVersion"
Invoke-WebRequest "$TfBase/$TfFile" -OutFile $TfFile
Invoke-WebRequest "$TfBase/terraform_${TfVersion}_SHA256SUMS" -OutFile terraform_SHA256SUMS
py -3 "$PracticeDir/scripts/verify_download.py" sha256-list $TfFile terraform_SHA256SUMS
if ($LASTEXITCODE -ne 0) { throw 'STOP: checksum failed; no expansion' }
$TfBin = "$HOME/AppData/Local/unit06a-bin"
New-Item -ItemType Directory -Force $TfBin | Out-Null
Expand-Archive $TfFile -DestinationPath $TfBin
$env:PATH = "$TfBin;$env:PATH"
terraform version
if ($LASTEXITCODE -ne 0) { throw 'STOP: Terraform check failed' }
Set-Location $PracticeDir
```
Terraform1.13.5. Missing Python launcher or wrong path must stop; use approved Python installer, never bypass verification.

## Linux: optional local kubectl preparation
Fill an actual released client version within one minor of the reviewed server. Full OS/CPU URL and checksum gate shown; Unit6A requires no cluster.

```bash
PracticeDir=$(pwd) || exit 1
[ -f "$PracticeDir/README.md" ] || exit 1
mkdir -p "$HOME/.local/bin" || exit 1
export PATH="$HOME/.local/bin:$PATH"
KubeVersion="REPLACE_WITH_RELEASED_COMPATIBLE_vVERSION"
[[ "$KubeVersion" =~ ^v1\.[0-9]+\.[0-9]+$ ]] || exit 1
case "$(uname -m)" in
  x86_64) KubeArch="amd64" ;;
  aarch64|arm64) KubeArch="arm64" ;;
  *) exit 1 ;;
esac
KubeBase="https://dl.k8s.io/release/$KubeVersion/bin/linux/$KubeArch"
curl --fail --location "$KubeBase/kubectl" --output kubectl || exit 1
curl --fail --location "$KubeBase/kubectl.sha256" --output kubectl.sha256 || exit 1
python3 "$PracticeDir/scripts/verify_download.py" \
  sha256 kubectl kubectl.sha256 || exit 1
install -m 0755 kubectl "$HOME/.local/bin/kubectl" || exit 1
kubectl version --client --output=yaml || exit 1
```
Local client version only. Do not assume latest is compatible; checksum/download failure prevents install.

## macOS: optional local kubectl preparation
Fill an actual released client version within one minor of the reviewed server. Full OS/CPU URL and checksum gate shown; Unit6A requires no cluster.

```bash
PracticeDir=$(pwd) || exit 1
[ -f "$PracticeDir/README.md" ] || exit 1
mkdir -p "$HOME/.local/bin" || exit 1
export PATH="$HOME/.local/bin:$PATH"
KubeVersion="REPLACE_WITH_RELEASED_COMPATIBLE_vVERSION"
[[ "$KubeVersion" =~ ^v1\.[0-9]+\.[0-9]+$ ]] || exit 1
case "$(uname -m)" in
  x86_64) KubeArch="amd64" ;;
  aarch64|arm64) KubeArch="arm64" ;;
  *) exit 1 ;;
esac
KubeBase="https://dl.k8s.io/release/$KubeVersion/bin/darwin/$KubeArch"
curl --fail --location "$KubeBase/kubectl" --output kubectl || exit 1
curl --fail --location "$KubeBase/kubectl.sha256" --output kubectl.sha256 || exit 1
python3 "$PracticeDir/scripts/verify_download.py" \
  sha256 kubectl kubectl.sha256 || exit 1
install -m 0755 kubectl "$HOME/.local/bin/kubectl" || exit 1
kubectl version --client --output=yaml || exit 1
```
Local client version only. Do not assume latest is compatible; checksum/download failure prevents install.

## Windows: optional local kubectl preparation
Same checksum logic, Windows executable and PowerShell explicit native failure check. Preserve full path/flags, no inline secret material.

```powershell
$ErrorActionPreference = "Stop"
$PracticeDir = (Get-Location).Path
$TfBin = "$HOME/AppData/Local/unit06a-bin"
New-Item -ItemType Directory -Force $TfBin | Out-Null
$env:PATH = "$TfBin;$env:PATH"
$KubeVersion = "REPLACE_WITH_RELEASED_COMPATIBLE_vVERSION"
if ($KubeVersion -notmatch '^v1\.[0-9]+\.[0-9]+$') { throw 'STOP: fill actual version' }
$KubeBase = "https://dl.k8s.io/release/$KubeVersion/bin/windows/amd64"
Invoke-WebRequest "$KubeBase/kubectl.exe" -OutFile kubectl.exe
Invoke-WebRequest "$KubeBase/kubectl.exe.sha256" -OutFile kubectl.exe.sha256
py -3 "$PracticeDir/scripts/verify_download.py" sha256 kubectl.exe kubectl.exe.sha256
if ($LASTEXITCODE -ne 0) { throw 'STOP: checksum failed; no move/install' }
Move-Item kubectl.exe "$TfBin/kubectl.exe" -ErrorAction Stop
kubectl version --client --output=yaml
if ($LASTEXITCODE -ne 0) { throw 'STOP: client check failed' }
```
Local client version only; not Kubernetes reachability or permission.

Official references: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html ; https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli ; https://kubernetes.io/docs/tasks/tools/ . Verify the supplied PUBLIC AWS key fingerprint against the AWS page. HTTPS checksums are not an independent signature proof; follow HashiCorp signed-checksum guidance for stronger provenance. No private keys/credentials are distributed. Return to PracticeDir after installing; never paste terminal commands into the AWS console search bar.
