#!/usr/bin/env bash

LOG_FILE="${1:-logs/web-incident.log}"
REPORT_FILE="${2:-reports/incident-report.txt}"

if [ ! -f "$LOG_FILE" ]; then
  echo "Log file not found: $LOG_FILE"
  exit 1
fi

mkdir -p "$(dirname "$REPORT_FILE")"

{
  echo "NEXVION INCIDENT ANALYSIS"
  echo "Generated: $(date -Is)"
  echo "Log file: $LOG_FILE"
  echo

  echo "=== HTTP STATUS SUMMARY ==="
  grep -oE '" [0-9]{3} ' "$LOG_FILE" |
    awk '{count[$2]++} END {for (code in count) print code, count[code]}' |
    sort || true
  echo

  echo "=== HTTP 5xx ERRORS ==="
  if grep -E '" 5[0-9]{2} ' "$LOG_FILE"; then
    echo "Investigate server errors and upstream services."
  else
    echo "No HTTP 5xx responses found."
  fi
  echo

  echo "=== HTTP 4xx ERRORS ==="
  if grep -E '" 4[0-9]{2} ' "$LOG_FILE"; then
    echo "Investigate requested paths and permissions."
  else
    echo "No HTTP 4xx responses found."
  fi
  echo

  echo "=== ERROR KEYWORDS ==="
  if grep -Ei 'error|exception|fatal|timeout|connection refused|out of memory|oom' "$LOG_FILE"; then
    echo "Review matching lines above."
  else
    echo "No common error keywords found."
  fi
  echo

  echo "=== RECOMMENDED CHECKS ==="
  echo "1. docker ps"
  echo "2. docker logs --since 15m nexvion-web"
  echo "3. curl -I http://127.0.0.1:8080/"
  echo
  echo "Note: This is rule-based analysis, not an AI model diagnosis."
} > "$REPORT_FILE"

echo "Analysis complete: $REPORT_FILE"
