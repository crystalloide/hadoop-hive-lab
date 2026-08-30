# Handlab Hadoop + Hive + MapReduce + Tez + LLAP — V4

## Pourquoi la V3 échoue
Avec Hive 4.2.1, l'image embarque Tez 0.10.5. Le `DAGAppMaster` de Tez 0.10.5 lit directement `CONTAINER_ID`, `NM_HOST`, `NM_PORT` et `NM_HTTP_PORT` dans l'environnement YARN lorsqu'il est lancé avec `--session`. `TEZ_FRAMEWORK_MODE=STANDALONE_ZOOKEEPER` ne supprime pas cette lecture dans Tez 0.10.5. C'est exactement la cause du `containerIdStr is null` observé.

## Architecture V4
- Hadoop 3.4.1 : 1 NameNode, 1 DataNode, ResourceManager, NodeManager, JobHistoryServer
- Hive 4.2.1 + PostgreSQL 17
- Tez 0.10.5 : **ApplicationMaster lancé par YARN**, pas par un conteneur Docker autonome
- Tez est empaqueté depuis `/opt/tez` de l'image Hive puis déployé automatiquement dans HDFS `/apps/tez/tez.tar.gz`
- ZooKeeper 3.8.4 + LLAP daemon
- HiveServer2 utilise YARN pour Tez et ZooKeeper pour la découverte LLAP

Ce choix suit le modèle de déploiement Tez documenté : `tez.lib.uris` pointe vers une archive Tez placée dans HDFS, et le client ainsi que les containers utilisent la même version des bibliothèques. 

## Démarrage
Sous Linux/WSL2 :

```bash
bash reset.sh
bash start.sh
```

Le smoke-test exécute réellement :
1. une requête Hive avec Tez/YARN ;
2. la même requête avec MapReduce ;
3. la même requête avec LLAP.

Le démarrage est considéré comme réussi uniquement si ces trois exécutions aboutissent.

## Interfaces
- NameNode : http://localhost:9870
- ResourceManager : http://localhost:8088
- JobHistory : http://localhost:19888
- HiveServer2 : localhost:10000
