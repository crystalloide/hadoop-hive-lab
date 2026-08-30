#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo '[1/3] Building images...'
docker compose build

echo '[2/3] Starting cluster...'
docker compose up -d

echo '[3/3] Waiting for smoke test...'
for i in $(seq 1 60); do
  status=$(docker inspect -f '{{.State.Status}}' lab-smoke-test 2>/dev/null || true)
  if [ "$status" = "exited" ]; then
    code=$(docker inspect -f '{{.State.ExitCode}}' lab-smoke-test)
    docker compose logs --no-log-prefix smoke-test
    if [ "$code" -eq 0 ]; then
      echo 'Handlab READY.'
      exit 0
    fi
    echo 'Smoke test FAILED.' >&2
    exit 1
  fi
  sleep 5
done

echo 'Timeout while waiting for the handlab.' >&2
docker compose ps
exit 1
