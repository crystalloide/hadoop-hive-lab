#!/bin/bash
# Atelier — Étape 4 : comparaison des moteurs d'exécution Hive
# À exécuter DEPUIS LA MACHINE HÔTE (pas besoin de faire docker exec soi-même) :
#   bash scripts/benchmark_engines.sh
#
# Lance la même requête (COUNT(*) par ville sur la table `clients`) avec
# MapReduce puis Tez, chronomètre chaque exécution, et ajoute LLAP
# automatiquement si le profil bonus est démarré (--profile llap).
set -euo pipefail

QUERY="SELECT ville, COUNT(*) AS nb_clients FROM clients GROUP BY ville;"
HS2_MAIN="hiveserver2"
HS2_LLAP="hiveserver2-llap"

run_query () {
  local container="$1" ; local engine_sql="$2" ; local label="$3"
  echo ""
  echo "----- ${label} -----"
  local start end
  start=$(date +%s.%N)
  docker exec -i "${container}" beeline \
    -u 'jdbc:hive2://localhost:10000/default' \
    --showHeader=true --silent=true \
    -e "${engine_sql} ${QUERY}"
  end=$(date +%s.%N)
  awk -v s="$start" -v e="$end" -v l="$label" 'BEGIN{printf "Temps %-28s : %.1f s\n", l, e-s}'
}

if ! docker ps --format '{{.Names}}' | grep -qx "${HS2_MAIN}"; then
  echo "Le conteneur ${HS2_MAIN} n'est pas démarré (docker compose up -d ?)."
  exit 1
fi

run_query "${HS2_MAIN}" "SET hive.execution.engine=mr;"  "MapReduce (mr)"
run_query "${HS2_MAIN}" "SET hive.execution.engine=tez;" "Tez (tez, défaut)"

if docker ps --format '{{.Names}}' | grep -qx "${HS2_LLAP}"; then
  run_query "${HS2_LLAP}" "SET hive.execution.engine=tez; SET hive.llap.execution.mode=all;" "Tez + LLAP (bonus)"
else
  echo ""
  echo "(bonus LLAP non démarré — voir README, section 'Bonus LLAP' :"
  echo " docker compose --profile llap up -d)"
fi

echo ""
echo "Les temps incluent le démarrage de l'AM / de la session, dominant sur un aussi petit jeu de données :"
echo "c'est justement cet écart de démarrage que l'atelier vous fait observer entre MapReduce et Tez."
