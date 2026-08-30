#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
docker compose ps
echo
echo 'Smoke-test logs:'
docker compose logs --no-log-prefix smoke-test 2>/dev/null || true
