#!/bin/bash
# =============================================================================
# init-tez.sh — Initialisation automatique de Tez sur HDFS
# Exécuté une seule fois au 1er lancement par le service "tez-init"
# =============================================================================
set -e

export HADOOP_HOME=/opt/hadoop
export PATH=${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:$PATH
export JAVA_HOME=${JAVA_HOME:-"$(dirname "$(dirname "$(readlink -f "$(which java)")")")"}

HDFS_TEZ_PATH="/apps/tez/tez.tar.gz"
LOCAL_TEZ_ARCHIVE="/opt/tez/tez.tar.gz"
MAX_RETRIES=72   # 72 x 5s = 6 minutes max
RETRY=0

# -----------------------------------------------------------------------------
# 1. Attente que le NameNode sorte du safe mode
# -----------------------------------------------------------------------------
echo "================================================================"
echo " Tez-Init : attente de la disponibilité du NameNode HDFS..."
echo "================================================================"

until hdfs dfsadmin -safemode get 2>/dev/null | grep -q "Safe mode is OFF"; do
  RETRY=$((RETRY + 1))
  if [ "${RETRY}" -ge "${MAX_RETRIES}" ]; then
    echo "ERREUR : timeout — le NameNode n'est pas sorti du safe mode après $((MAX_RETRIES * 5))s"
    exit 1
  fi
  echo "  -> safe mode encore actif, tentative ${RETRY}/${MAX_RETRIES} (attente 5s)..."
  sleep 5
done

echo "  OK - HDFS disponible (safe mode OFF)"

# -----------------------------------------------------------------------------
# 2. Création des répertoires HDFS nécessaires (Tez + espace de l'atelier)
# -----------------------------------------------------------------------------
echo ""
echo "Création des répertoires HDFS..."

# /tmp lui-même doit être ouvert en écriture (convention HDFS standard,
# comme le /tmp local d'Unix) : le moteur MapReduce classique (hive.execution.
# engine=mr) y crée directement son répertoire de staging
# (/tmp/hadoop-yarn/staging/<utilisateur>/.staging) au premier job soumis.
# Sans ce chmod sur /tmp lui-même (les sous-dossiers ci-dessous ne suffisent
# pas), Hive plante avec "Permission denied: user=hive, access=WRITE,
# inode=\"/tmp\"" dès qu'on bascule sur ce moteur.
hdfs dfs -chmod 1777 /tmp

hdfs dfs -mkdir -p /apps/tez
hdfs dfs -mkdir -p /tmp/tez/staging
hdfs dfs -chmod -R 1777 /tmp/tez
hdfs dfs -chmod 755 /apps/tez

# Répertoires attendus par Hive (warehouse + scratch) et par l'atelier (exemple_clients)
# NB : le chmod porte sur /user/hive (pas seulement /user/hive/warehouse) car
# c'est aussi le "home HDFS" de l'utilisateur "hive" (celui sous lequel tourne
# HiveServer2) : Tez y crée son propre sous-répertoire de jars de session.
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -chmod -R 1777 /user/hive
hdfs dfs -mkdir -p /tmp/hive
hdfs dfs -chmod -R 1777 /tmp/hive
hdfs dfs -mkdir -p /user/hadoop
hdfs dfs -chmod 775 /user/hadoop
hdfs dfs -mkdir -p /tmp/logs
hdfs dfs -chmod -R 1777 /tmp/logs

echo "  OK - répertoires créés (/apps/tez, /tmp/tez/staging, /user/hive/warehouse, /user/hadoop, /tmp/logs)"

# -----------------------------------------------------------------------------
# 3. Upload du tarball Tez sur HDFS (idempotent)
# -----------------------------------------------------------------------------
echo ""
if hdfs dfs -test -f "${HDFS_TEZ_PATH}" 2>/dev/null; then
  echo "  OK - Tez déjà présent sur HDFS (${HDFS_TEZ_PATH}), aucun upload nécessaire."
else
  echo "Upload de Tez vers HDFS : ${HDFS_TEZ_PATH}"
  hdfs dfs -put "${LOCAL_TEZ_ARCHIVE}" "${HDFS_TEZ_PATH}"
  echo "  OK - upload terminé"
fi

HDFS_SIZE=$(hdfs dfs -du -s "${HDFS_TEZ_PATH}" 2>/dev/null | awk '{print $1}')
LOCAL_SIZE=$(stat -c%s "${LOCAL_TEZ_ARCHIVE}" 2>/dev/null || echo "0")
echo "  -> taille locale  : ${LOCAL_SIZE} octets"
echo "  -> taille sur HDFS: ${HDFS_SIZE} octets"

echo ""
echo "================================================================"
echo " Tez-Init : TERMINÉ avec succès !"
echo " Le cluster Hadoop est prêt (HDFS + YARN + Tez)."
echo "================================================================"
