#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
echo '[1/3] Build Hadoop/Hive images'
docker compose build
echo '[2/3] Start stack'
docker compose up -d
echo '[3/3] Wait for smoke test'
for i in $(seq 1 120); do
  status=$(docker inspect -f '{{.State.Status}}' lab-smoke-test 2>/dev/null || true)
  if [ "$status" = exited ]; then
    code=$(docker inspect -f '{{.State.ExitCode}}' lab-smoke-test)
    docker compose logs --no-log-prefix smoke-test
    [ "$code" -eq 0 ] && { echo 'HANDLAB READY'; exit 0; }
    echo 'Smoke test FAILED' >&2
    docker compose ps
    exit 1
  fi
  sleep 5
done
echo 'Timeout' >&2
docker compose ps
exit 1
