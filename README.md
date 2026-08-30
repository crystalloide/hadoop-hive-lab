# Handlab Hadoop + Hive + MapReduce + Tez + LLAP — V4

## Architecture 
- Hadoop 3.4.1 : 1 NameNode, 1 DataNode, ResourceManager, NodeManager, JobHistoryServer
- Hive 4.2.1 + PostgreSQL 17
- Tez 0.10.5 : **ApplicationMaster lancé par YARN**, pas par un conteneur Docker autonome
- Tez est empaqueté depuis `/opt/tez` de l'image Hive puis déployé automatiquement dans HDFS `/apps/tez/tez.tar.gz`
- ZooKeeper 3.8.4 + LLAP daemon
- HiveServer2 utilise YARN pour Tez et ZooKeeper pour la découverte LLAP

Ce choix suit le modèle de déploiement Tez documenté : `tez.lib.uris` pointe vers une archive Tez placée dans HDFS, et le client ainsi que les containers utilisent la même version des bibliothèques. 

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

## Démarrage
Sous Linux/WSL2 :

## Réinitialisation complète

```bash
bash reset.sh
```

```bash
bash start.sh
```

`reset.sh` supprime également les volumes Docker du lab.


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
