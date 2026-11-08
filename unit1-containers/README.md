# Hands-on practice companion

These are the files and steps a learner follows in their **own** environment while watching the class.
They use the same `web` greeting program as the lesson.

| Path | What it is |
|---|---|
| `unit1/web/` | The five real files: `server.py`, `greeting.txt`, `requirements.txt`, `Dockerfile`, `.dockerignore`. They are the single source of truth. |
| `unit1/HANDS-ON-UNIT1.md` | The ordered learner guide, Steps 0–9: checks → files → direct run → build → inspect → run → writable layer → rebuild → cleanup. Each step gives where to run it, why, the command, the expected output, what to observe, and recovery. |
| `unit1/HANDS-ON.template.md` | The guide's source. File contents are injected from `web/` by `tools/render_handson.py`, so the guide never drifts from the files. |
| `unit1/PRACTICE-BEATS.md` | Which lesson scene each practice step follows, and what the narrated practice scenes show. |
| `PROGRESSION-LATER-UNITS.md` | Draft practice plan for Units 2–8: Pods, Kubernetes, EKS. |
| `OPERATOR-REFERENCES.md` | Official docs used to write and check the steps. Operator/companion material only; not narrated. |
| `VERIFICATION-unit1.txt` | What was checked on the build box and what could not be, stated honestly. |
| `tools/` | `render_handson.py`, `verify_unit1.py`, `native_run_test.sh`. |

Scope of Unit 1 practice:

- Local only.
- No AWS, no cloud account, no cost.
- Downloads: the `python:3.12-slim` base image and Flask/Werkzeug, the first time.
- Docker Engine on Linux, or Docker Desktop on Windows/macOS (which provides a Linux VM), must be installed and running from Step 4.
- Python 3.12+ is needed only for the optional direct run (Steps 2–3).

Rebuild and recheck after editing any file in `unit1/web/`:
```bash
python3 tools/render_handson.py && python3 tools/verify_unit1.py /path/to/python-with-flask
```
