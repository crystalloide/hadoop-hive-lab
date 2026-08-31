#!/usr/bin/env bash
set -euo pipefail
docker compose ps
echo '--- Tez ---'
docker compose logs --tail=30 tez-init
echo '--- LLAP ---'
docker compose logs --tail=50 llapdaemon
