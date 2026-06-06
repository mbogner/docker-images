#!/usr/bin/env bash
set -euo pipefail

USER="admin"
PASS="admin"
TOPIC="test/cluster"
MSG="hello-$(date +%s)"

echo "==> Node status (HTTP API)"
curl -fsS "http://127.0.0.1:8888/status.json" >/dev/null && echo "vernemq1: OK"
curl -fsS "http://127.0.0.1:8889/status.json" >/dev/null && echo "vernemq2: OK"

echo
echo "==> Cluster members (from vernemq1)"
docker exec vernemq1 vmq-admin cluster show

echo
echo "==> Pub/sub cross-node test"
echo "    sub on vernemq2 (port 1884), pub on vernemq1 (port 1883)"

tmp=$(mktemp)
docker run --rm --network vernemq_default eclipse-mosquitto:2 \
    mosquitto_sub -h vernemq2 -p 1883 -u "$USER" -P "$PASS" \
    -t "$TOPIC" -C 1 -W 10 > "$tmp" &
sub_pid=$!

sleep 2

docker run --rm --network vernemq_default eclipse-mosquitto:2 \
    mosquitto_pub -h vernemq1 -p 1883 -u "$USER" -P "$PASS" \
    -t "$TOPIC" -m "$MSG"

wait $sub_pid
received=$(cat "$tmp")
rm -f "$tmp"

if [ "$received" = "$MSG" ]; then
    echo "    OK: received '$received'"
else
    echo "    FAIL: expected '$MSG', got '$received'"
    exit 1
fi

echo
echo "==> Auth rejection test (wrong password)"
if docker run --rm --network vernemq_default eclipse-mosquitto:2 \
    mosquitto_pub -h vernemq1 -p 1883 -u "$USER" -P "wrong" \
    -t "$TOPIC" -m "should-fail" 2>/dev/null; then
    echo "    FAIL: bad creds accepted"
    exit 1
else
    echo "    OK: bad creds rejected"
fi

echo
echo "All tests passed."
