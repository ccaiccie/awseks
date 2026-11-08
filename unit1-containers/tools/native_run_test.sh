#!/bin/bash
# Native (no container) behaviour test of unit1/web in a throwaway copy. Usage: native_run_test.sh <python-with-flask>
set -u; PY=$1; T=$(mktemp -d); cp -r "$(dirname "$0")/../unit1/web/." "$T"; cd "$T" || exit 1
echo "== default HOST (direct run)"; "$PY" server.py > a.out 2>&1 & A=$!; sleep 2
ss -ltn | awk '$4 ~ /:8080$/ {print "listening:", $4}'
echo "GET / -> $(curl -sS http://127.0.0.1:8080/)"; echo "GET / -> $(curl -sS http://127.0.0.1:8080/)"
echo "GET /visits -> $(curl -sS http://127.0.0.1:8080/visits)"
printf 'Hello again from web\n' > greeting.txt; echo "after editing greeting.txt: $(curl -sS http://127.0.0.1:8080/)"
echo "== second process on same port (collision)"; timeout 10 "$PY" server.py > c.out 2>&1; echo "exit=$?: $(grep -m1 'in use' c.out)"
kill -TERM $A; wait $A; echo "SIGTERM -> exit $?"; echo "visits.log lines: $(wc -l < visits.log)"
echo "== HOST=0.0.0.0 (as set in the image)"; HOST=0.0.0.0 "$PY" server.py > b.out 2>&1 & B=$!; sleep 2
ss -ltn | awk '$4 ~ /:8080$/ {print "listening:", $4}'; grep -E 'Running on|listening on' b.out | sed 's/web process [0-9]*/web process <pid>/'
kill -TERM $B; wait $B; echo "SIGTERM -> exit $?"
echo "== start without flask (main python)"; python3 -c 'import flask' 2>/dev/null && echo "flask present in main python; skipped" || (python3 server.py 2>&1 | tail -1)
rm -rf "$T"
