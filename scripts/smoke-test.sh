#!/usr/bin/env bash
set -euo pipefail

echo '=== Hadoop/HDFS ==='
hdfs dfs -ls /
hdfs dfs -test -e /apps/tez/tez.tar.gz

echo '=== Hive / Tez ==='
beeline -u 'jdbc:hive2://hiveserver2:10000/default' --silent=true --showHeader=true --outputformat=tsv2 <<'SQL'
SET hive.execution.engine;
SET tez.lib.uris;
SELECT 1 AS tez_smoke_test;
SQL

echo '=== Smoke test OK ==='
