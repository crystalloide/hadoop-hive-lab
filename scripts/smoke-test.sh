#!/usr/bin/env bash
set -euo pipefail
run_hql(){ beeline -u 'jdbc:hive2://hiveserver2:10000/default' --silent=true --showHeader=true --outputformat=tsv2 -e "$1"; }
echo '=== HDFS ==='
hdfs dfs -test -e /data/exemple_clients/clients.csv
hdfs dfs -test -e /apps/tez/tez.tar.gz
hdfs dfs -ls -h /apps/tez/tez.tar.gz
hdfs dfsadmin -report | grep -q 'Live datanodes'
echo 'OK HDFS + DataNode'
echo '=== YARN ==='
yarn node -list | grep -q RUNNING
echo 'OK YARN + NodeManager'
echo '=== Hive + Tez/YARN ==='
run_hql "SET hive.execution.engine=tez; SELECT ville, COUNT(*) AS nb_clients FROM formation.clients GROUP BY ville ORDER BY ville;"
echo 'OK Tez'
echo '=== Hive + MapReduce ==='
run_hql "SET hive.execution.engine=mr; SELECT ville, COUNT(*) AS nb_clients FROM formation.clients GROUP BY ville ORDER BY ville;"
echo 'OK MapReduce'
echo '=== LLAP registration ==='
for i in $(seq 1 30); do
  if run_hql "SET hive.llap.execution.mode=only; SET hive.execution.engine=tez; SELECT COUNT(*) FROM formation.clients;" >/tmp/llap.out 2>/tmp/llap.err; then
    cat /tmp/llap.out
    echo 'OK LLAP'
    echo '=== HANDLAB READY ==='
    exit 0
  fi
  sleep 5
done
cat /tmp/llap.err >&2
exit 1
