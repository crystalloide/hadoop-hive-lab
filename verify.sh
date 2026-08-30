#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
docker compose ps
echo
docker compose logs --no-log-prefix smoke-test || true
echo
echo 'HDFS:'
docker compose exec hadoop hdfs dfs -ls /apps/tez
echo
echo 'Hive/Tez:'
docker compose exec hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/default' -e 'SET hive.execution.engine; SET tez.lib.uris; SELECT 1;'
