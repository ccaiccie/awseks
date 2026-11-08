"""web: the class greeting program.

Answers HTTP requests with the text in greeting.txt and appends one line
to visits.log for every greeting it serves (used to observe the
container's writable layer).
"""
import os
import signal
import sys
from datetime import datetime, timezone
from pathlib import Path

from flask import Flask

APP_DIR = Path(__file__).resolve().parent
GREETING_FILE = APP_DIR / "greeting.txt"
VISITS_LOG = APP_DIR / "visits.log"

# HOST decides which addresses the process listens on.
# 127.0.0.1 = only this computer (safe default when you run it directly).
# The Dockerfile sets HOST=0.0.0.0 so the process accepts connections that
# arrive on the container's own network interface.
HOST = os.environ.get("HOST", "127.0.0.1")
PORT = int(os.environ.get("PORT", "8080"))

app = Flask(__name__)


@app.get("/")
def greet():
    greeting = GREETING_FILE.read_text(encoding="utf-8-sig").strip()  # -sig: ignore a BOM some editors add
    stamp = datetime.now(timezone.utc).isoformat(timespec="seconds")
    with VISITS_LOG.open("a", encoding="utf-8") as log:
        log.write(stamp + "\n")
    print(f"served greeting at {stamp}", flush=True)
    return greeting + "\n"


@app.get("/visits")
def visits():
    count = 0
    if VISITS_LOG.exists():
        count = len(VISITS_LOG.read_text(encoding="utf-8").splitlines())
    return f"visits recorded in this filesystem: {count}\n"


if __name__ == "__main__":
    # Exit promptly when asked to stop (docker stop sends SIGTERM).
    # Inside a container this program is process 1, which would otherwise ignore it.
    signal.signal(signal.SIGTERM, lambda signum, frame: sys.exit(0))
    print(f"web process {os.getpid()} listening on {HOST}:{PORT}", flush=True)
    # Flask's built-in server is a local learning server, not a production server.
    # debug=False and use_reloader=False: no interactive debugger, one process.
    app.run(host=HOST, port=PORT, debug=False, use_reloader=False)
