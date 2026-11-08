# Unit 1 practice beats: where each practice step sits in the lesson

The revised sample, **v5.2.4-sample-unit1-r2**, narrates these beats as their own scenes,
each placed right after the concept it practices. `HANDS-ON-UNIT1.md` holds the full detail
for each beat: Windows variants, expected output, recovery and cleanup.

| Lesson concept scene (r2) | Practice scene (r2) | Guide step | Commands shown on screen | What the learner observes |
|---|---|---|---|---|
| s0002 example files · s0003 inside server.py | **s0004 Practice: make the web folder** | 0–1 | `python3 --version`, `curl --version`, `mkdir web`, `cd web`, `ls -A` | five files on disk; nothing running |
| s0005 files → process (Python = language runtime) | **s0006 Practice: run it directly** | 2 | `python3 -m venv .venv`, `.venv/bin/python -m pip install -r requirements.txt`, `.venv/bin/python server.py`, `curl http://127.0.0.1:8080/`, Ctrl+C | a PID, a listening port, `Hello from web`; stop it to free 8080 |
| s0008 why copying is not enough | (inside s0008 narration) | 3 | `python3 server.py` with the main Python | `ModuleNotFoundError: No module named 'flask'` |
| s0010 Dockerfile · s0011 docker build | **s0012 Practice: build and inspect** | 0 (Docker check), 4–5 | `docker version`, `docker build -t web:1.0 .`, `docker image ls web`, `docker image inspect --format '{{.Config.Cmd}}' web:1.0`, `docker image history web:1.0` | client vs server/engine; one step per Dockerfile line; cached rebuild; stored start settings; layers; nothing running |
| s0014 container start · s0015 container vs VM (Docker Desktop's Linux VM) | **s0016 Practice: run the container** | 6 | `docker run -d --name web1 -p 127.0.0.1:8080:8080 web:1.0`, `curl`, `docker ps`, `docker logs web1`, `docker exec web1 cat /etc/hostname` | two ports, two jobs (listener `0.0.0.0:8080` inside, published `127.0.0.1:8080` outside); PID 1 inside; own hostname |
| s0017 writable layer | **s0018 Practice: watch the writable layer** | 7 | `docker exec web1 cat /app/visits.log`, `docker stop/start web1`, `docker ps -a`, `docker rm web1`, `docker run … web2`, `docker exec web2 cat /app/visits.log` | file kept across stop/start; gone in a new container |
| (COPY snapshot, s0010) | **s0019 Practice: change the greeting, then clean up** | 8–9 | edit `greeting.txt`, `curl`, `docker build -t web:1.1 .`, `docker rm -f web2`, `docker run … web3 … web:1.1`, `docker rm -f web3`, `docker image rm web:1.0 web:1.1` | image is a snapshot; change = new image + new container; targeted cleanup only |
| s0020 knowledge check | — | — | — | uses only objects the learner just handled: web1 after stop/start (yes), web2 after rm + new run (no) |

Not practiced in Unit 1, on purpose:
- registry push/pull. ECR needs an AWS account; the practice starts in Unit 6, after costs are taught.
- resource limits. `docker update` is an optional extra in guide Step 6.
- Kubernetes. Unit 2 practice, see `../PROGRESSION-LATER-UNITS.md`.
