# Unit 1 hands-on: from web files to a running container (local only, no AWS)

You follow the same `web` program the lesson uses. Everything runs on your own computer.
Nothing here touches AWS and nothing here costs money. The only downloads are the Python
base image and the Flask library, the first time you build or install.

Outputs below are marked **Expected**. They show what you should see. Exact IDs, sizes,
times and process numbers will differ on your computer.

How to read each step:

- **Where:** the folder your terminal must be in.
- **Why:** what the command is for, and what each flag means.
- **Run:** the command. Copy it exactly. One command per box.
- **Expected:** what a good result looks like.
- **Observe:** the one thing this step proves.
- **If it fails:** the usual causes, in the order to check them.

---

## Step 0. What you need, and how to check it

You need four things. You do not need all of them for every step.

| Need | Used from | Why |
|---|---|---|
| A terminal | Step 1 | You type commands into it. |
| Python 3.12 or newer | Step 2 (direct run) | Python is the program that reads `server.py` and carries out its instructions. |
| curl | Step 2 onward | Sends a web request from the terminal, so you can see the raw answer. |
| Docker, installed **and running** | Step 4 onward | Builds the image and runs the container. |
| Internet access, the first time | Steps 2 and 4 | Downloads Flask and the `python:3.12-slim` base image. Later runs reuse local copies. |

### Which terminal

| Your computer | Use | Notes |
|---|---|---|
| macOS | Terminal app (zsh) | Commands in the **macOS / Linux** boxes. |
| Linux | Your terminal (bash) | Commands in the **macOS / Linux** boxes. |
| Windows 10/11 | **PowerShell** | Commands in the **Windows PowerShell** boxes. Do not use the old `cmd` window. Avoid Git Bash for the `docker exec` steps: it rewrites paths such as `/app`. |

Every command in this guide fits on one line, so line-continuation characters
(`\` in bash, `` ` `` in PowerShell) are never needed.

### Check Python

macOS / Linux:
```bash
python3 --version
```
Windows PowerShell:
```powershell
py --version
```
**Expected:** `Python 3.12.x` or newer (3.13 is fine).
**If it fails:** `command not found` or `not recognized` means Python is not installed or not on your PATH.
You can skip the direct run (Steps 2 and 3) and continue at Step 4. The container brings its own Python.

### Check curl

macOS / Linux:
```bash
curl --version
```
Windows PowerShell:
```powershell
curl.exe --version
```
**Expected:** a first line that starts with `curl 8.` (any recent version is fine).
**Why `curl.exe` on Windows:** in Windows PowerShell 5.1, `curl` is a nickname for a different command
(`Invoke-WebRequest`). Typing `curl.exe` always runs the real curl, which is included with Windows 10/11.

### Check Docker (do this before Step 4)

What Docker needs, in plain terms. Our image is a **Linux** container image, built for your computer's
CPU type. It needs a **Linux kernel** to run.

- **Linux computer:** install Docker Engine. Containers share your computer's own Linux kernel.
- **Windows or macOS:** install Docker Desktop. It starts a small **Linux virtual machine** in the background,
  and Docker Engine runs inside it. Your containers share *that VM's* Linux kernel, not the Windows or macOS kernel.
  - On Windows this uses WSL 2. Hardware virtualization must be enabled.
  - On a Mac, Docker Desktop picks the right Linux VM for Apple silicon or Intel.
  - Docker Desktop is free for some uses and paid for others. Check Docker's current subscription terms if you use it at work.

Run:
```bash
docker version
```
(Same command in PowerShell.)

**Expected:** two sections, `Client:` and `Server:`. The Server section names the engine, for example
`Engine:` with a version number. On Docker Desktop the Server `OS/Arch` says `linux/amd64` or `linux/arm64`,
even on Windows or a Mac. That is the Linux VM's kernel you will share.

**Observe:** `Client` is the `docker` command you type. `Server` is the engine that actually builds and runs.
They are two separate programs, and the client only sends it requests.

**If it fails:**
- `docker: command not found` / `not recognized`: Docker is not installed.
- The Client section prints, then an error such as
  `Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?`
  (Linux/macOS) or `error during connect ... dockerDesktopLinuxEngine` (Windows):
  the client works, but the engine is not running. Start Docker Desktop and wait until it says it is running.
  On Linux, start the service: `sudo systemctl start docker`.
- `permission denied while trying to connect to the Docker daemon socket` (Linux): your user may not use the engine.
  Either put `sudo` in front of each `docker` command, or follow Docker's Linux post-install guide.
  That guide adds you to the `docker` group. Membership in that group is equivalent to administrator (root)
  access on that computer, so only do it on a machine you control.

---

## Step 1. Create the folder and the four files

**Where:** any folder you use for practice, for example your home folder.

**Why:** these files are the "program stored as files" from the lesson. Nothing runs yet.

macOS / Linux, and Windows PowerShell (the same two commands work in both):
```bash
mkdir web
```
```bash
cd web
```
**Expected:** no output from `mkdir`. After `cd`, your prompt shows you are inside `web`.
**If it fails:** `File exists` / `already exists`: you already have a `web` folder.
Use it if it is from this exercise, or pick a new name such as `web-practice` and use that everywhere.

Now create the files **inside `web`**. The simplest way is to open a plain-text editor
(VS Code, TextEdit in plain-text mode, Notepad), paste each content below, and save it with exactly that name.
On Windows, make sure Notepad does not add `.txt` to `server.py` or `Dockerfile`.
`Dockerfile` has **no** extension.

Files 1 to 3 are needed from Step 2. Files 4 and 5 are needed from Step 4.
You can create them all now.

### File 1: `server.py`, the program

What it does, in four actions:
1. It loads the **Flask** library. Flask is code someone else wrote that understands web (HTTP) requests.
2. When a request for `/` arrives, it reads `greeting.txt` and sends that text back.
3. For every greeting, it appends one timestamp line to `visits.log` in its own folder.
   Step 7 uses this file to show which data survives a container restart.
4. It listens on port 8080 at the address in `HOST`.
   With no setting, `HOST` is `127.0.0.1`, meaning "only this computer".
   The Dockerfile sets it to `0.0.0.0`; Step 6 explains why.

The interactive debugger and auto-reloader are switched off. Flask's built-in server is a
**local learning server**, not something to run in production.

```python
{{server.py}}
```

### File 2: `greeting.txt`, the configuration

```text
{{greeting.txt}}
```

### File 3: `requirements.txt`, the libraries the program needs

```text
{{requirements.txt}}
```
`==` pins exact versions, so you get the same library code every time.
Flask needs Werkzeug, so it is pinned too. The versions were current stable releases when this guide was written.

### File 4: `Dockerfile`, the recipe for the image

```dockerfile
{{Dockerfile}}
```

### File 5: `.dockerignore`, files the build must not copy

```text
{{.dockerignore}}
```
Why: Step 2 creates `visits.log` and `.venv` on your computer. Neither belongs in the image.
On some systems the file explorer hides names that start with a dot. The terminal shows them.

### Optional: create the files from the terminal instead of an editor

macOS / Linux (bash or zsh). Each block writes one file; paste the whole block.
`<<'EOF'` means "everything until the line `EOF` is the file content, typed literally":
{{bash-create}}

Windows PowerShell. `@' ... '@` is a literal block of text; `-Encoding ascii` writes plain text with no hidden marker bytes:
{{ps-create}}

### Check the folder

macOS / Linux:
```bash
ls -A
```
Windows PowerShell:
```powershell
Get-ChildItem -Force -Name
```
**Expected:** exactly these five names, in any order:
```text
.dockerignore
Dockerfile
greeting.txt
requirements.txt
server.py
```
**Observe:** these are only files on a disk. Nothing is answering anyone yet.

---

## Step 2. Run the program directly (no container yet)

*Matches the lesson scene "From files to a running process".* Skip to Step 4 if you do not have Python.

**Where:** inside `web`.

**Why:** you will see a program become a **process**.
**Python** is the *language runtime*, an installed program that reads `server.py` and carries out its instructions.
That is a different thing from the *container runtime* you meet later.
**pip** is Python's package installer: it downloads the libraries listed in `requirements.txt`.

We install Flask into a **virtual environment**, a private folder `.venv` with its own copy of Python and libraries.
That way nothing is installed into your computer's main Python.

1. Create the virtual environment. `-m venv` means "run Python's built-in venv module". `.venv` is the folder it creates.

   macOS / Linux:
   ```bash
   python3 -m venv .venv
   ```
   Windows PowerShell:
   ```powershell
   py -m venv .venv
   ```
   **Expected:** no output. A new `.venv` folder exists.

2. Install the libraries into it. We call the venv's own Python directly, so no "activate" step is needed.
   `-m pip` runs pip with that Python. `install -r requirements.txt` means "install everything listed in this file".

   macOS / Linux:
   ```bash
   .venv/bin/python -m pip install -r requirements.txt
   ```
   Windows PowerShell:
   ```powershell
   .venv\Scripts\python.exe -m pip install -r requirements.txt
   ```
   **Expected:** lines such as `Collecting flask==3.1.3`, ending with `Successfully installed ... flask-3.1.3 ... werkzeug-3.1.9`.
   **If it fails:** `Could not find a version` or a network error usually means no internet access, or a proxy.
   Fix the network and repeat the same command.

3. Start the program. The terminal stays busy while the process runs; that is normal.

   macOS / Linux:
   ```bash
   .venv/bin/python server.py
   ```
   Windows PowerShell:
   ```powershell
   .venv\Scripts\python.exe server.py
   ```
   **Expected (labels to look for):**
   ```text
   web process 41270 listening on 127.0.0.1:8080
    * Serving Flask app 'server'
    * Debug mode: off
   WARNING: This is a development server. Do not use it in a production deployment. ...
    * Running on http://127.0.0.1:8080
   Press CTRL+C to quit
   ```
   **Observe:** the number after `web process` is the **process ID (PID)** the operating system gave it.
   The warning is expected; it is Flask reminding you this is a learning server.
   **If it fails:** `Address already in use` / `Port 8080 is in use by another program`: something else already
   listens on port 8080. Find and stop it, or use another port for this step only:
   macOS / Linux `PORT=8081 .venv/bin/python server.py`; PowerShell `$env:PORT="8081"` and then the start command again.
   Every later `8080` in Steps 2 and 3 then becomes `8081`.

4. Open a **second** terminal window, go into the same `web` folder, and send a request.

   macOS / Linux:
   ```bash
   curl http://127.0.0.1:8080/
   ```
   Windows PowerShell:
   ```powershell
   curl.exe http://127.0.0.1:8080/
   ```
   **Expected:**
   ```text
   Hello from web
   ```
   In the **first** terminal, a new line appears: `served greeting at ...`, followed by a request line ending in `"GET / HTTP/1.1" 200 -`.
   **Observe:** a running process read `greeting.txt` and answered over the network. `200` is HTTP for "OK".
   Ask it how many visits it recorded:
   ```bash
   curl http://127.0.0.1:8080/visits
   ```
   (PowerShell: `curl.exe http://127.0.0.1:8080/visits`)
   **Expected:** `visits recorded in this filesystem: 1`
   **If it fails:** `Connection refused` / `Failed to connect` means no process is listening.
   Check the first terminal: did the server start, or did it print an error?

5. Change the greeting while the process runs. Edit `greeting.txt` to say `Hello again from web`, save it, and repeat the curl.
   **Expected:** `Hello again from web`.
   **Observe:** the program reads the file on each request, so a direct run sees file changes immediately.
   Remember this for Step 8, where a container behaves differently.
   Change the file back to `Hello from web` and save it.

6. **Stop the process.** Click in the first terminal and press **Ctrl+C**.
   **Expected:** the prompt returns.
   **Observe:** the process is gone, and the port is free again. The files, including `visits.log`, are still on disk.
   **Important:** stop it now. Step 6 publishes the container on the same port 8080,
   and a process still listening there would make the container fail to start.

## Step 3. See "works on my machine" for yourself (optional, 1 minute)

*Matches "Why copying the files is not enough".*

**Where:** inside `web`. Run the program with your computer's **main** Python, which does not have Flask installed:

macOS / Linux:
```bash
python3 server.py
```
Windows PowerShell:
```powershell
py server.py
```
**Expected:**
```text
Traceback (most recent call last):
  ...
ModuleNotFoundError: No module named 'flask'
```
**Observe:** the program file is identical; only its surroundings changed. This is the problem images solve.
(If it starts instead, Flask happens to be installed in your main Python. Press Ctrl+C. The point still stands.)

---

## Step 4. Build the image

*Matches "The Dockerfile" and "docker build".* Do the Docker check in Step 0 first.

**Where:** inside `web`. The `Dockerfile` must be in this folder.

**Why:** `docker build` reads the Dockerfile, runs each step, and saves the result as an image.
- `-t web:1.0` sets the **tag**: the name `web` with label `1.0`.
- The final `.` is the **build context**: "this folder". The build may only copy files from here,
  minus anything listed in `.dockerignore`.

```bash
docker build -t web:1.0 .
```
**Expected (labels to look for; the exact layout depends on your Docker version):**
```text
[+] Building ...
 => [internal] load build definition from Dockerfile
 => [1/5] FROM docker.io/library/python:3.12-slim@sha256:...
 => [2/5] WORKDIR /app
 => [3/5] COPY requirements.txt .
 => [4/5] RUN pip install --no-cache-dir -r requirements.txt
 => [5/5] COPY server.py greeting.txt ./
 => exporting to image
 => => naming to docker.io/library/web:1.0
```
The first build downloads the base image and Flask, so it takes longer. Run the same command again:
every step should say `CACHED` and finish in seconds.
**Observe:** each numbered step is one Dockerfile line, in order. `ENV`, `EXPOSE` and `CMD` record settings but add no files.

**If it fails:**
- `failed to read dockerfile` / `open Dockerfile: no such file`: you are not in the `web` folder,
  or the file is named `Dockerfile.txt`. Check with the folder listing from Step 1.
- `"/server.py": not found` during a COPY step: that file is missing from the folder, or misspelled.
- A pip error at step 4/5, or a timeout pulling `python:3.12-slim`: network or proxy problem. Fix it and rebuild.
  Already finished steps are reused.
- `Cannot connect to the Docker daemon`: go back to the Docker check in Step 0.

## Step 5. Look at the image you built

**Where:** any folder. These commands only read.

1. List it:
   ```bash
   docker image ls web
   ```
   **Expected:** one row for repository `web`, tag `1.0`, an image ID, and a size of roughly a hundred-plus MB.
   Column names vary slightly between Docker versions.
   **Observe:** the image exists, but nothing is running. An image is stored data.

2. Read the start settings stored in it. `inspect` prints the image's details; `--format` picks one field.
   Use the single quotes exactly as shown, in both shells.
   ```bash
   docker image inspect --format '{{.Config.Cmd}}' web:1.0
   ```
   **Expected:** `[python server.py]`
   ```bash
   docker image inspect --format '{{.Config.ExposedPorts}}' web:1.0
   ```
   **Expected:** `map[8080/tcp:{}]`
   **Observe:** the start command and the documented port are settings saved inside the image. EXPOSE only *records* 8080.
   It does not publish anything and does not make the program listen.

3. See the layers:
   ```bash
   docker image history web:1.0
   ```
   **Expected:** one row per Dockerfile step, newest at the top.
   Look for the `COPY server.py greeting.txt ./` row and the `RUN pip install` row, the library layer, which is several MB.
   The rows at the bottom come from the base image.

4. The image's own fingerprint:
   ```bash
   docker image inspect --format '{{.Id}}' web:1.0
   ```
   **Expected:** `sha256:` followed by 64 hex characters.
   **Observe:** this is the **image ID**, a fingerprint computed from the image's content on *your* computer.
   A registry identifies a pushed image by a **digest**, also a `sha256:` fingerprint. You will see the digest the registry reports when we push, in a later unit.
   Depending on how your Docker stores images, the local ID may or may not equal that digest, so do not rely on it. You do not need to pin anything yet.

---

## Step 6. Run the container and request it

*Matches "What happens when a container starts" and "Run the container".* Make sure Step 2's direct run is stopped.

**Two different ports, two different jobs.** This is the part network engineers usually want stated precisely:

- **Inside the container**, the program must *listen*. A container has its own network view, with its own loopback.
  If the program listened only on `127.0.0.1`, it would accept connections from inside the container only.
  Traffic you forward from your computer arrives on the container's own interface, so the Dockerfile sets
  `HOST=0.0.0.0`, meaning "listen on all of this container's interfaces", port 8080.
- **On your computer**, `-p` *publishes* a port: Docker forwards connections that arrive on a host port to the container's port.
  `-p 127.0.0.1:8080:8080` reads as **host address : host port : container port**.
  We bind the host side to `127.0.0.1` so only your own computer can reach this learning server.
  Plain `-p 8080:8080` would publish it on **all** of your computer's addresses, so other machines on your network could reach it.
- `EXPOSE 8080` in the Dockerfile does neither of these. It is documentation.

The flags:
- `-d`: run in the background and give your terminal back.
- `--name web1`: a name to use in later commands instead of the long ID.
- `-p 127.0.0.1:8080:8080`: publish, as explained above.
- `web:1.0`: the image to start from.

```bash
docker run -d --name web1 -p 127.0.0.1:8080:8080 web:1.0
```
**Expected:** one long hexadecimal line. That is the new container's ID.

**If it fails:**
- `Bind for 127.0.0.1:8080 failed: port is already allocated`, or `... address already in use`:
  something on your computer already uses port 8080. Often it is Step 2's process, which is still running,
  or an earlier container. Check with `docker ps`. Stop the direct run with Ctrl+C.
  Or keep the container port and change only the host port:
  `docker rm web1` (removes the failed container), then
  `docker run -d --name web1 -p 127.0.0.1:8081:8080 web:1.0`, and use `8081` in the curl commands.
- `Conflict. The container name "/web1" is already in use`: a container with that name exists from an earlier try.
  Look at it with `docker ps -a`. If you do not need it, remove that one container: `docker rm -f web1`.
  Then run again. Do not use broad clean-up commands such as `docker system prune`; they delete other work too.

Send a request (PowerShell: `curl.exe`):
```bash
curl http://127.0.0.1:8080/
```
**Expected:** `Hello from web`
**Observe:** same answer as the direct run. This time the process runs from the image's files, inside a container.

**If it fails** (connection refused or reset): check that the container is still running (`docker ps`) and read its output (`docker logs web1`).

List running containers:
```bash
docker ps
```
**Expected:** a row with `NAMES` `web1`, `IMAGE` `web:1.0`, `STATUS` `Up ...`, and `PORTS` `127.0.0.1:8080->8080/tcp`.
**Observe:** the `PORTS` column is exactly the host-to-container forwarding you asked for.

Read what the process printed:
```bash
docker logs web1
```
**Expected:** `web process 1 listening on 0.0.0.0:8080`, the Flask lines including `Running on all addresses (0.0.0.0)`, then `served greeting at ...` and a request line.
**Observe:** inside the container the program is **process 1**. The container has its own process view (a *namespace*).
On your computer, the same process has a different, ordinary PID.
The lines `Running on http://127.0.0.1:8080` and `Running on http://172.17.0.x:8080` list the container's *own* addresses (its loopback and its interface), not your computer's.

Ask the container its hostname. `docker exec` runs one extra command inside an existing, running container; `cat` prints a file:
```bash
docker exec web1 cat /etc/hostname
```
**Expected:** a 12-character ID, the start of the container ID, not your computer's name.
**Observe:** another part of the restricted view: the container has its own hostname.

About resource limits: this container has **no** CPU or memory limits, because we did not ask for any.
Limits apply only when you set them. As an optional extra, apply some to the running container and look:
```bash
docker update --cpus 0.5 --memory 256m --memory-swap 256m web1
```
```bash
docker stats --no-stream web1
```
**Expected:** `docker update` prints `web1`. `docker stats` shows a `MEM USAGE / LIMIT` column with `/ 256MiB`.
(Some Linux setups print a warning that limits are unsupported. That is a host setting; skip this extra.)

---

## Step 7. Stop/start versus remove/recreate: watch the writable layer

*Matches "The writable layer is temporary".*

Our program appends a line to `/app/visits.log` for each greeting. Inside a container, that file lands in the
container's **writable layer**, not in the image.

1. Make two visits, then read the file from inside the container (PowerShell: `curl.exe`):
   ```bash
   curl http://127.0.0.1:8080/
   ```
   ```bash
   curl http://127.0.0.1:8080/
   ```
   ```bash
   docker exec web1 cat /app/visits.log
   ```
   **Expected:** one timestamp line per visit so far: the visits from Step 6 plus these two.
   `cat` prints a file's contents.

2. Stop the container. Its process ends; the container and its writable layer stay.
   ```bash
   docker stop web1
   ```
   **Expected:** `web1`, within a second or two. Docker asks the process to exit (signal SIGTERM); our program handles it and exits.
   A program that ignored it would be force-stopped after 10 seconds.
   ```bash
   docker ps -a
   ```
   `-a` means "all containers, including stopped ones".
   **Expected:** `web1` with `STATUS` `Exited (0) ...`. Plain `docker ps` would not show it.

3. Start the **same** container again and read the file:
   ```bash
   docker start web1
   ```
   ```bash
   docker exec web1 cat /app/visits.log
   ```
   **Expected:** the same lines as before. **Observe:** stop and start kept the writable layer.

4. Remove the container, then create a **new** one from the same image:
   ```bash
   docker stop web1
   ```
   ```bash
   docker rm web1
   ```
   ```bash
   docker run -d --name web2 -p 127.0.0.1:8080:8080 web:1.0
   ```
   ```bash
   docker exec web2 cat /app/visits.log
   ```
   **Expected:** `cat: /app/visits.log: No such file or directory`. That error is the lesson.
   **Observe:** `web2` started with a fresh, empty writable layer on top of the unchanged image.
   The old visits were deleted with `web1`. Never keep data you care about only inside a container;
   a later unit shows volumes, which keep data outside it.

## Step 8. Change the greeting: the image is a snapshot

*Matches the note in the summary: COPY took a copy at build time.*

1. Edit `greeting.txt` on your computer to say `Hello from web 1.1` and save it. Then request the running container:
   ```bash
   curl http://127.0.0.1:8080/
   ```
   **Expected:** still `Hello from web`.
   **Observe:** the container reads `/app/greeting.txt` from the image, which was copied at build time.
   Editing your folder changes nothing inside an image that already exists. Compare Step 2.5.

2. Build a new image with a new tag. **Where:** inside `web`.
   ```bash
   docker build -t web:1.1 .
   ```
   **Expected:** steps 1 to 4 say `CACHED`; only the last `COPY` step runs again.
   **Observe:** only the top layer changed. The base and library layers are reused.

3. Replace the container: remove the old one, run a new one from `web:1.1`.
   ```bash
   docker rm -f web2
   ```
   (`-f` stops and removes in one step.)
   ```bash
   docker run -d --name web3 -p 127.0.0.1:8080:8080 web:1.1
   ```
   ```bash
   curl http://127.0.0.1:8080/
   ```
   **Expected:** `Hello from web 1.1`
   **Observe:** to change what a container runs, you build a new image and start a new container from it.
   Kubernetes automates exactly this replacement in later units.

---

## Step 9. Clean up only what this exercise created

Remove the container:
```bash
docker rm -f web3
```
Remove the two images (optional; keeping them costs only disk space):
```bash
docker image rm web:1.0 web:1.1
```
Optional: remove the downloaded base image too. Other projects may use it.
```bash
docker image rm python:3.12-slim
```
Check that nothing from this exercise is left:
```bash
docker ps -a
```
**Expected:** no `web1`, `web2` or `web3` rows.
```bash
docker image ls web
```
**Expected:** no `web` rows.

The `web` folder, including `.venv` and `visits.log`, is ordinary files. Keep it for Unit 2, or delete the folder.

Do not use `docker system prune` or `docker image prune -a` for this. They remove everything unused on your computer,
not just this exercise.

---

## Common problems at a glance

| You see | Step | Most likely cause | Do this |
|---|---|---|---|
| `Cannot connect to the Docker daemon` / `error during connect` | 0, 4+ | Engine not running | Start Docker Desktop, or `sudo systemctl start docker` on Linux, then `docker version` |
| `permission denied ... docker.sock` | 0, 4+ | Linux user not allowed to use the engine | Use `sudo docker ...`, or Docker's post-install steps (root-equivalent group) |
| `failed to read dockerfile` | 4 | Wrong folder, or file named `Dockerfile.txt` | `cd` into `web`; list files |
| `"/greeting.txt": not found` | 4 | File missing or misspelled | Compare with the Step 1 listing |
| pip / pull timeout | 2, 4 | No internet or proxy | Fix network; repeat the same command |
| `ModuleNotFoundError: No module named 'flask'` | 2 | Used main Python instead of `.venv`'s | Use the `.venv` path shown in Step 2 (this is expected in Step 3) |
| `port is already allocated` / `address already in use` | 2, 6 | Direct run or another container still on 8080 | Ctrl+C the direct run; `docker ps`; or change the **host** port only |
| `container name "/web1" is already in use` | 6 | Leftover from an earlier try | `docker ps -a`, then `docker rm -f web1` if you do not need it |
| `curl: (7) Failed to connect` | 2, 6 | Nothing listening | Direct run: check terminal 1. Container: `docker ps`, `docker logs web1` |
| Container shows `Exited (1)` in `docker ps -a` | 6 | Program crashed at start | `docker logs web1` shows the Python error |
| `curl` prints HTML or asks for `-Uri` | Windows | PowerShell's `curl` nickname | Type `curl.exe` |
