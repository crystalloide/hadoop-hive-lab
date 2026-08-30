# Handlab Hadoop + Hive 4.2.1 + MapReduce + Tez + LLAP

Environnement pédagogique Docker Compose avec :

- Hadoop 3.4.1 : 1 NameNode + 1 DataNode + YARN ResourceManager + NodeManager
- MapReduce sur YARN
- Hive 4.2.1 / HiveServer2 / Metastore PostgreSQL 17
- Tez 0.10.5 fourni dans l'image officielle Apache Hive
- Tez AM en mode STANDALONE_ZOOKEEPER
- 1 daemon LLAP
- ZooKeeper 3.8.4


## Pré-requis :

On récupère le projet en local : 

```bash
cd ~
sudo rm -Rf hadoop-hive-lab
git clone https://github.com/crystalloide/hadoop-hive-lab
cd hadoop-hive-lab
```    

Affichage du répertoire courant : 

```bash
pwd
```

```bash
chmod +x *.sh
```


## Démarrage

Sous Linux / WSL2 :

```bash
bash start.sh
```

Le script attend la réussite du smoke-test. Il ne suffit pas que les conteneurs soient `Up` : le test exécute réellement Hive avec Tez, MapReduce et LLAP.

Si les permissions des scripts ont été perdues lors de l'extraction ZIP, `bash start.sh` fonctionne sans chmod.

## Réinitialisation complète

```bash
bash reset.sh
```

```bash
bash start.sh
```

`reset.sh` supprime également les volumes Docker du lab.


## Accès

- NameNode UI : http://localhost:9870
- YARN UI : http://localhost:8088
- JobHistory : http://localhost:19888
- HiveServer2 : localhost:10000
- HiveServer2 Web UI : http://localhost:10002

Connexion Beeline :

    docker compose exec hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/default'

## Données du TP

Le fichier `clients.csv` est automatiquement chargé dans :

    /data/exemple_clients/clients.csv

La table Hive est créée dans la base `formation` :

    formation.clients

Exemple :

    SELECT ville, COUNT(*) AS nb_clients
    FROM formation.clients
    GROUP BY ville;

## Comparaison des moteurs

MapReduce :

    SET hive.execution.engine=mr;

Tez :

    SET hive.execution.engine=tez;

LLAP :

    SET hive.execution.engine=tez;
    SET hive.llap.execution.mode=only;

Le mode `only` est volontairement utilisé dans le smoke-test : si LLAP n'est pas réellement disponible, le test échoue au lieu de masquer le problème.

## Pourquoi cette V3 est différente de la V2

Le conteneur `tezam` utilise le mécanisme fourni par l'image officielle Apache Hive pour `TEZ_FRAMEWORK_MODE=STANDALONE_ZOOKEEPER`. Il ne définit plus artificiellement `CONTAINER_ID`, `NM_HOST`, `NM_PORT` ou `NM_HTTP_PORT`.

Cette architecture reprend le modèle Docker LLAP actuellement présent dans le dépôt Apache Hive : ZooKeeper, Tez AM standalone et daemon LLAP sont des services séparés et l'image `apache/hive` est utilisée directement.

## Pré-requis conseillés

- Docker Desktop + WSL2 ou Docker Engine Linux
- 8 Go RAM minimum ; 12 Go recommandés
- 10 Go d'espace disque disponible
- connexion Internet au premier lancement pour récupérer les images Docker

## Diagnostic

    docker compose ps
    docker compose logs tezam
    docker compose logs llapdaemon
    docker compose logs hiveserver2
    docker compose logs smoke-test
