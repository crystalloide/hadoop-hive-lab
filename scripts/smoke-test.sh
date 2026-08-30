#!/usr/bin/env bash
set -euo pipefail

run_hql() {
  beeline -u 'jdbc:hive2://hiveserver2:10000/default' --silent=true --showHeader=true --outputformat=tsv2 -e "$1"
}

wait_for() {
  local label="$1"; shift
  for i in $(seq 1 40); do
    if "$@" >/dev/null 2>&1; then echo "OK: $label"; return 0; fi
    sleep 3
  done
  echo "FAILED: $label" >&2
  return 1
}

echo '=== 1. HDFS ==='
hdfs dfs -test -e /data/exemple_clients/clients.csv
hdfs dfs -test -e /user/hive/warehouse/formation.db/clients
hdfs dfs -ls /data/exemple_clients

echo '=== 2. Tez installation ==='
[ -d /opt/tez ]
[ -f /opt/tez/lib/tez-dag-0.10.5.jar ]
echo "OK: Tez $(basename /opt/tez/lib/tez-dag-*.jar | sed 's/tez-dag-//;s/.jar//') present in Hive image"

wait_for 'Tez AM RPC' bash -c 'echo > /dev/tcp/tezam/15100'
wait_for 'LLAP web endpoint' bash -c 'echo > /dev/tcp/llapdaemon/15001'

 echo '=== 3. Hive + Tez ==='
run_hql "SET hive.execution.engine=tez; SELECT ville, COUNT(*) AS nb_clients FROM formation.clients GROUP BY ville ORDER BY ville;"

 echo '=== 4. Hive + MapReduce ==='
run_hql "SET hive.execution.engine=mr; SELECT ville, COUNT(*) AS nb_clients FROM formation.clients GROUP BY ville ORDER BY ville;"

 echo '=== 5. Hive + LLAP ==='
run_hql "SET hive.execution.engine=tez; SET hive.llap.execution.mode=only; SELECT ville, COUNT(*) AS nb_clients FROM formation.clients GROUP BY ville ORDER BY ville;"

echo '=== HANDLAB READY: HDFS + MapReduce + Tez + LLAP ==='
