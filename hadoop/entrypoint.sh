#!/usr/bin/env bash
set -euo pipefail

mkdir -p /data/nn /data/dn /data/yarn/local /data/yarn/logs /data/mr-history /data/tmp
chown -R hadoop:users /data

if [ ! -f /data/nn/current/VERSION ]; then
  su -s /bin/bash hadoop -c 'hdfs namenode -format -force -nonInteractive'
fi

su -s /bin/bash hadoop -c 'hdfs --daemon start namenode'
su -s /bin/bash hadoop -c 'hdfs --daemon start datanode'
su -s /bin/bash hadoop -c 'yarn --daemon start resourcemanager'
su -s /bin/bash hadoop -c 'yarn --daemon start nodemanager'
su -s /bin/bash hadoop -c 'mapred --daemon start historyserver'

echo 'Hadoop daemons started.'
trap 'su -s /bin/bash hadoop -c "mapred --daemon stop historyserver || true"; su -s /bin/bash hadoop -c "yarn --daemon stop nodemanager || true"; su -s /bin/bash hadoop -c "yarn --daemon stop resourcemanager || true"; su -s /bin/bash hadoop -c "hdfs --daemon stop datanode || true"; su -s /bin/bash hadoop -c "hdfs --daemon stop namenode || true"' TERM INT EXIT
while true; do sleep 3600; done
