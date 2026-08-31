#!/bin/bash
# Atelier — Étape 1 : chargement des données sur HDFS
# À exécuter DANS le conteneur namenode :
#   docker exec namenode bash /opt/scripts/01_prepare_hdfs.sh
set -e

hdfs dfs -mkdir -p /user/hadoop/exemple_clients
hdfs dfs -chmod 775 /user/hadoop/exemple_clients
hdfs dfs -put -f /opt/data/clients.csv /user/hadoop/exemple_clients/
hdfs dfs -ls /user/hadoop/exemple_clients

echo ""
echo "OK - clients.csv chargé sur HDFS dans /user/hadoop/exemple_clients"
