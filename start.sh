#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo '[1/4] Building custom Hadoop image...'
docker compose build hadoop

echo '[2/4] Starting stack...'
docker compose up -d

echo '[3/4] Waiting for validation...'
for i in $(seq 1 90); do
  status=$(docker inspect -f '{{.State.Status}}' lab-smoke-test 2>/dev/null || true)
  if [ "$status" = "exited" ]; then
    code=$(docker inspect -f '{{.State.ExitCode}}' lab-smoke-test)
    docker compose logs --no-log-prefix smoke-test
    if [ "$code" -eq 0 ]; then
      echo '[4/4] Handlab READY.'
      exit 0
    fi
    echo 'Smoke test FAILED.' >&2
    docker compose ps
    exit 1
  fi
  sleep 5
done

echo 'Timeout while waiting for validation.' >&2
docker compose ps
exit 1
