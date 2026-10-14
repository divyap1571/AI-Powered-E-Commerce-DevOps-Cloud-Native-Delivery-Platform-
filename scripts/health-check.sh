#!/usr/bin/env bash
set -euo pipefail

URL="${1:-http://localhost:8080}"

echo "Checking Nexvion application: $URL"

if curl --fail --silent --show-error "$URL" -o /dev/null; then
    echo "SUCCESS: Nexvion is responding."
else
    echo "ERROR: Nexvion health check failed."
    exit 1
fi
