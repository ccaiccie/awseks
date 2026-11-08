"""Render unit1/HANDS-ON-UNIT1.md from the template and the real files in unit1/web (single source of truth)."""
from pathlib import Path
P = Path(__file__).resolve().parents[1] / 'unit1'
W = P / 'web'
ORDER = ['server.py', 'greeting.txt', 'requirements.txt', 'Dockerfile', '.dockerignore']
t = (P / 'HANDS-ON.template.md').read_text()
files = {n: (W / n).read_text() for n in ORDER}
for n, c in files.items():
    assert c.endswith('\n') and 'EOF' not in c and "'@" not in c
    t = t.replace('{{%s}}' % n, c.rstrip('\n'))
bash = []
ps = []
for n, c in files.items():
    bash.append("```bash\ncat > %s <<'EOF'\n%sEOF\n```" % (n, c))
    ps.append("```powershell\n@'\n%s'@ | Set-Content -Encoding ascii -Path %s\n```" % (c, n))
t = t.replace('{{bash-create}}', '\n'.join(bash)).replace('{{ps-create}}', '\n'.join(ps))
assert '{{' not in t.replace("'{{.Config", '').replace("'{{.Id", ''), 'unreplaced placeholder'
(P / 'HANDS-ON-UNIT1.md').write_text(t)
print('wrote', P / 'HANDS-ON-UNIT1.md', len(t.splitlines()), 'lines')
