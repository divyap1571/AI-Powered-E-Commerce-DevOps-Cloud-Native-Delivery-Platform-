#!/usr/bin/env bash
set -u

PROJECT_DIR="$HOME/Nexvion"
LOG_FILE="$PROJECT_DIR/logs/web-incident.log"
REPORT_FILE="$PROJECT_DIR/reports/incident-report.txt"
LOCK_FILE="/tmp/nexvion-incident-check.lock"
HEALTH_URL="http://127.0.0.1:8080/"

exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

cd "$PROJECT_DIR" || exit 1
mkdir -p "$PROJECT_DIR/logs" "$PROJECT_DIR/reports"

if ! docker inspect -f '{{.State.Running}}' nexvion-web 2>/dev/null | grep -qx true; then
    {
        echo "NEXVION INCIDENT ALERT"
        echo "Time: $(date -Is)"
        echo "CRITICAL: nexvion-web container is not running."
        echo "Recommended check: docker ps -a"
    } > "$REPORT_FILE"
    exit 1
fi

HTTP_CODE=$(curl -sS -o /dev/null -w '%{http_code}' \
    --connect-timeout 5 --max-time 10 "$HEALTH_URL" 2>/dev/null || true)

if [ "$HTTP_CODE" != "200" ]; then
    {
        echo "NEXVION INCIDENT ALERT"
        echo "Time: $(date -Is)"
        echo "WARNING: Website health check failed."
        echo "URL: $HEALTH_URL"
        echo "HTTP status: ${HTTP_CODE:-unavailable}"
        echo "Recommended checks: docker ps; docker logs --since 15m nexvion-web"
    } > "$REPORT_FILE"
    exit 1
fi

docker logs --since 5m --timestamps nexvion-web > "$LOG_FILE" 2>&1 || true
"$PROJECT_DIR/scripts/analyze-logs.sh" "$LOG_FILE" "$REPORT_FILE"
