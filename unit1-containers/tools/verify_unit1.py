"""No-Docker, no-AWS checks for the Unit 1 companion. Writes VERIFICATION-unit1.txt."""
import re, subprocess, tempfile, filecmp, os, sys, shutil, time, urllib.request, json
from pathlib import Path
P = Path(__file__).resolve().parents[1]; U = P / 'unit1'; W = U / 'web'
md = (U / 'HANDS-ON-UNIT1.md').read_text()
out = []
def log(x): print(x); out.append(x)
blocks = re.findall(r'```(\w+)\n(.*?)```', md, re.S)
bash = [b for k, b in blocks if k == 'bash']; ps = [b for k, b in blocks if k == 'powershell']
log(f'code blocks: bash={len(bash)} powershell={len(ps)} total={len(blocks)}')
# 1. bash file-creation blocks reproduce the exact files
creates = [b for b in bash if "<<'EOF'" in b]
with tempfile.TemporaryDirectory() as d:
    for b in creates: subprocess.run(['bash', '-c', b], cwd=d, check=True)
    names = sorted(os.listdir(d)); same = all(filecmp.cmp(Path(d)/n, W/n, shallow=False) for n in names)
    log(f'bash heredoc creation: {len(creates)} blocks -> {names}; byte-identical to web/: {same}')
    assert same and len(names) == 5
# 2. PowerShell blocks reproduce content (text-level check; pwsh unavailable here)
ok = True
for b in ps:
    m = re.match(r"@'\n(.*)\n'@ \| Set-Content -Encoding ascii -Path (\S+)\n", b, re.S)
    if m: ok &= (m.group(1) + '\n') == (W / m.group(2)).read_text()
log(f'PowerShell here-string blocks match files (text check, not executed): {ok}; pwsh available: {bool(shutil.which("pwsh"))}')
# 3. shellcheck every bash block (docker/curl commands are only parsed, never executed)
sc = shutil.which('shellcheck')
if sc:
    script = '#!/bin/bash\n' + '\n'.join(bash)
    r = subprocess.run([sc, '-s', 'bash', '-e', 'SC2034,SC2164', '-'], input=script, text=True, capture_output=True)
    log(f'shellcheck on {len(bash)} bash blocks (SC2164 cd-guard excluded: commands are typed interactively): exit {r.returncode}' + ('' if r.returncode == 0 else '\n' + r.stdout[:3000]))
# 4. all practice files ASCII, server compiles
for n in os.listdir(W):
    (W / n).read_bytes().decode('ascii')
log('all web/ files pure ASCII: True')
py = sys.argv[1] if len(sys.argv) > 1 else sys.executable
r = subprocess.run([py, '-c', 'import py_compile,sys; py_compile.compile(sys.argv[1], cfile="/tmp/_srv.pyc", doraise=True)', str(W / 'server.py')]); log(f'server.py compiles: {r.returncode == 0}')
# 5. Dockerfile structural check (no engine available): instruction list + every COPY source exists
ins = [l.split()[0] for l in (W / 'Dockerfile').read_text().splitlines() if l.strip() and not l.startswith('#')]
log(f'Dockerfile instructions: {ins}')
for l in (W / 'Dockerfile').read_text().splitlines():
    if l.startswith('COPY '):
        srcs = l.split()[1:-1]; assert all((W / s).exists() for s in srcs), l
        if len(srcs) > 1: assert l.split()[-1].endswith('/'), 'multi-source COPY dest must end with /'
log('COPY sources exist; multi-source COPY destination ends with /: True')
ign = [x for x in (W / '.dockerignore').read_text().splitlines() if x and not x.startswith('#')]
log(f'.dockerignore excludes: {ign}; none of the COPY sources ignored: {not any(x in ("server.py","greeting.txt","requirements.txt") for x in ign)}')
(P / 'VERIFICATION-unit1.txt').write_text('\n'.join(out) + '\n')
