# Handlab Hadoop MapReduce + Hive/Tez + LLAP

Environnement pédagogique Docker Compose, volontairement compact :

- 1 conteneur Hadoop qui joue les rôles NameNode + DataNode + ResourceManager + NodeManager + JobHistoryServer ;
- Hive 4.2.1 ;
- Hadoop 3.4.1 ;
- Tez 0.10.5 ;
- PostgreSQL pour le Metastore ;
- ZooKeeper + Tez AM externe + 1 LLAP daemon ;
- Beeline / HiveServer2 exposé sur `localhost:10000`.

Les versions Hadoop 3.4.1 / Tez 0.10.5 sont volontairement alignées avec la matrice de compatibilité publiée par Apache pour Hive 4.2.x. Hive 4.2.1 est la version utilisée par le projet au moment de la préparation de ce handlab.

## 1. Pré-requis

Docker Desktop récent ou Docker Engine + Docker Compose v2.

Prévoir idéalement 6 à 8 Go de RAM pour Docker. Pour un poste avec 4 Go, réduire les paramètres mémoire YARN/LLAP avant le démarrage.

## 2. Démarrage

On récupère le projet en local : 

```bash
cd ~
git clone https://github.com/crystalloide/hadoop-hive-lab
cd hadoop-hive-lab
```    

#### Affichage du répertoire courant : 
```bash
    pwd
```

```bash
docker compose build
docker compose up -d
```

Suivre le démarrage :

```bash
docker compose ps
docker compose logs -f hiveserver2
```

Le service `smoke-test` doit terminer avec :

```text
=== Smoke test OK ===
```

## 3. Vérification manuelle

```bash
docker compose exec hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/default'
```

Puis :

```sql
SET hive.execution.engine;
SET tez.lib.uris;
SELECT 1;
```

Pour vérifier HDFS :

```bash
docker compose exec hadoop hdfs dfs -ls /
docker compose exec hadoop hdfs dfs -ls /apps/tez
```

## 4. TP de l'Atelier 3

Le support demande notamment de créer `/user/hadoop/exemple_clients`, d'y charger `clients.csv`, puis de créer une table Hive externe et de comparer MapReduce, Tez et LLAP. Voir le document de TP fourni avec la formation. fileciteturn0file0L12-L24

### Charger le CSV

```bash
docker compose exec hadoop hdfs dfs -mkdir -p /user/hadoop/exemple_clients
docker compose cp clients.csv hadoop:/tmp/clients.csv
docker compose exec hadoop hdfs dfs -put -f /tmp/clients.csv /user/hadoop/exemple_clients/
```

### Ouvrir Hive

```bash
docker compose exec hiveserver2 beeline -u 'jdbc:hive2://localhost:10000/default'
```

### Table externe

```sql
CREATE EXTERNAL TABLE clients (
  id_client STRING,
  nom STRING,
  age INT,
  ville STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 'hdfs://hadoop:8020/user/hadoop/exemple_clients'
TBLPROPERTIES ('skip.header.line.count'='1');
```

### Requête de référence

```sql
SELECT ville, COUNT(*) AS nb_clients
FROM clients
GROUP BY ville;
```

### Comparaison des moteurs

MapReduce, pour comparaison uniquement :

```sql
SET hive.execution.engine=mr;
SELECT ville, COUNT(*) FROM clients GROUP BY ville;
```

Tez :

```sql
SET hive.execution.engine=tez;
SELECT ville, COUNT(*) FROM clients GROUP BY ville;
```

LLAP :

```sql
SET hive.execution.engine=tez;
SET hive.llap.execution.mode=only;
SELECT ville, COUNT(*) FROM clients GROUP BY ville;
```

`only` est utilisé dans le handlab afin que l'exercice échoue explicitement si LLAP n'est pas disponible, au lieu de retomber silencieusement sur un conteneur Tez classique.

## 5. Interfaces Web

- NameNode : http://localhost:9870
- ResourceManager : http://localhost:8088
- JobHistoryServer : http://localhost:19888
- HiveServer2 : http://localhost:10002

## 6. Nettoyage complet

```bash
docker compose down -v --remove-orphans
```

Cela supprime également les volumes HDFS, PostgreSQL, ZooKeeper et Hive.

## 7. Important pour le formateur

Ce cluster est destiné à un TP mono-machine et non à une démonstration d'architecture de production. Il privilégie la reproductibilité et la lisibilité : un seul NameNode et un seul DataNode, mais les rôles YARN nécessaires à MapReduce sont présents. LLAP est volontairement limité à un daemon et un exécuteur afin de rester utilisable sur un PC de formation.
