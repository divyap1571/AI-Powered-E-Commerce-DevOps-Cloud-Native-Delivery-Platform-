#!/usr/bin/env bash
set -u

PROJECT_DIR="$HOME/Nexvion"
LOG_FILE="$PROJECT_DIR/logs/web-incident.log"
REPORT_FILE="$PROJECT_DIR/reports/incident-report.txt"
LOCK_FILE="/tmp/nexvion-incident-check.lock"

exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

cd "$PROJECT_DIR" || exit 1

if ! docker inspect -f '{{.State.Running}}' nexvion-web 2>/dev/null | grep -qx true; then
  {
    echo "NEXVION INCIDENT ALERT"
    echo "Time: $(date -Is)"
    echo "CRITICAL: nexvion-web container is not running."
    echo "Recommended check: docker ps -a"
  } > "$REPORT_FILE"
  exit 1
fi

docker logs --since 5m --timestamps nexvion-web > "$LOG_FILE" 2>&1 || true
"$PROJECT_DIR/scripts/analyze-logs.sh" "$LOG_FILE" "$REPORT_FILE"
