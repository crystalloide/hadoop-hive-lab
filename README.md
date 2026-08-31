# Hadoop + Hive + Tez + LLAP Handlab V4

Stack pédagogique : Hadoop 3.4.1, Hive 4.2.1, Tez 0.10.5, PostgreSQL 17, ZooKeeper 3.8.4.

Architecture : 1 NameNode, 1 DataNode, 1 ResourceManager, 1 NodeManager, 1 HistoryServer, Hive Metastore, HiveServer2 et LLAP.

**Tez AM n'est PAS lancé comme conteneur Docker autonome.** Tez est déployé dans HDFS et les DAG Hive/Tez sont exécutés par YARN. Cela évite le problème de `containerIdStr` rencontré avec le lancement direct de `DAGAppMaster`.

LLAP est lancé comme daemon et découvert via ZooKeeper; HiveServer2 utilise les sessions Tez internes/YARN. Le test LLAP utilise `hive.llap.execution.mode=only` afin qu'un fallback silencieux ne puisse pas masquer un problème.


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

```bash
bash reset.sh
bash start.sh
```

## Vérification

```bash
bash verify.sh
```

Interfaces :
- NameNode: http://localhost:9870
- YARN: http://localhost:8088
- JobHistory: http://localhost:19888
- HiveServer2: localhost:10000
- HiveServer2 Web UI: http://localhost:10002
- LLAP: http://localhost:15001

## Important

Cette archive est conçue pour Docker Desktop/WSL2 ou Linux amd64. Elle n'est pas présentée comme testée sur un daemon Docker dans cet environnement de génération; le smoke-test est volontairement bloquant et doit afficher `HANDLAB READY` avant utilisation en formation.
