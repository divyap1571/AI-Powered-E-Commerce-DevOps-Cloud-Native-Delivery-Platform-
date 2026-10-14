#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "Building and starting Nexvion..."
docker compose up -d --build

echo "Waiting for container health check..."
for attempt in $(seq 1 12); do
    status="$(docker inspect --format='{{.State.Health.Status}}' nexvion-web 2>/dev/null || true)"

    if [[ "$status" == "healthy" ]]; then
        echo "SUCCESS: Nexvion is healthy."
        exit 0
    fi

    if [[ "$status" == "unhealthy" ]]; then
        echo "ERROR: Container is unhealthy."
        docker compose logs --tail 50 nexvion-web
        exit 1
    fi

    sleep 5
done

echo "ERROR: Health check timed out."
docker compose logs --tail 50 nexvion-web
exit 1
