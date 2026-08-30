#!/usr/bin/env bash
set -euo pipefail
run_hql() { beeline -u 'jdbc:hive2://hiveserver2:10000/default' --silent=true --showHeader=true --outputformat=tsv2 -e "$1"; }
wait_for() { local label="$1"; shift; for i in $(seq 1 60); do if "$@" >/dev/null 2>&1; then echo "OK: $label"; return 0; fi; sleep 3; done; echo "FAILED: $label" >&2; return 1; }
echo '=== 1. HDFS ==='
hdfs dfs -test -e /data/exemple_clients/clients.csv
hdfs dfs -test -e /apps/tez/tez.tar.gz
hdfs dfs -test -e /user/hive/warehouse/formation.db/clients
hdfs dfs -ls -h /apps/tez/tez.tar.gz
echo '=== 2. Tez deployment ==='
echo 'OK: Tez archive present in HDFS'
echo '=== 3. Hive + Tez on YARN ==='
run_hql "SET hive.execution.engine=tez; SELECT ville, COUNT(*) AS nb_clients FROM formation.clients GROUP BY ville ORDER BY ville;"
echo '=== 4. Hive + MapReduce ==='
run_hql "SET hive.execution.engine=mr; SELECT ville, COUNT(*) AS nb_clients FROM formation.clients GROUP BY ville ORDER BY ville;"
echo '=== 5. Hive + LLAP ==='
run_hql "SET hive.execution.engine=tez; SET hive.llap.execution.mode=only; SELECT ville, COUNT(*) AS nb_clients FROM formation.clients GROUP BY ville ORDER BY ville;"
echo '=== HANDLAB READY: HDFS + MapReduce + Tez/YARN + LLAP ==='
