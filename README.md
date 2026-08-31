# Atelier Hadoop : MapReduce, Tez et LLAP avec Docker Compose

Ce dépôt contient un environnement Docker Compose clé en main pour réaliser l'atelier Hadoop (HDFS, Hive, moteurs MapReduce, Tez et LLAP). 

## 1. Préparation de l'environnement

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

Créez un dossier pour votre projet (ex: `hadoop-hive-lab`) et placez-y les fichiers suivants.

### Le jeu de données de test (`clients.csv`)
Créez un fichier `clients.csv` :
```csv
id_client,nom,age,ville
1,Dupont,34,Paris
2,Martin,28,Lyon
3,Durand,45,Paris
4,Lefebvre,52,Marseille
5,Moreau,23,Lyon
```

### Le fichier de configuration (`hadoop.env`)
```env
CORE_CONF_fs_defaultFS=hdfs://namenode:9000
CORE_CONF_hadoop_http_staticuser_user=root
CORE_CONF_hadoop_proxyuser_hue_hosts=*
CORE_CONF_hadoop_proxyuser_hue_groups=*
HDFS_CONF_dfs_webhdfs_enabled=true
HDFS_CONF_dfs_permissions_enabled=false
YARN_CONF_yarn_nodemanager_resource_memory__mb=2048
YARN_CONF_yarn_scheduler_maximum__allocation__mb=2048
```

### Le fichier `docker-compose.yml`
```yaml
services:
  namenode:
    image: bde2020/hadoop-namenode:2.0.0-hadoop3.2.1-java8
    container_name: namenode
    ports:
      - "9870:9870"
      - "9000:9000"
    environment:
      - CLUSTER_NAME=test
    env_file:
      - ./hadoop.env
    volumes:
      - ./clients.csv:/tmp/clients.csv

  datanode:
    image: bde2020/hadoop-datanode:2.0.0-hadoop3.2.1-java8
    container_name: datanode
    environment:
      SERVICE_PRECONDITION: "namenode:9870"
    env_file:
      - ./hadoop.env

  resourcemanager:
    image: bde2020/hadoop-resourcemanager:2.0.0-hadoop3.2.1-java8
    container_name: resourcemanager
    environment:
      SERVICE_PRECONDITION: "namenode:9000 namenode:9870 datanode:9864"
    env_file:
      - ./hadoop.env

  nodemanager:
    image: bde2020/hadoop-nodemanager:2.0.0-hadoop3.2.1-java8
    container_name: nodemanager
    environment:
      SERVICE_PRECONDITION: "namenode:9000 namenode:9870 datanode:9864 resourcemanager:8088"
    env_file:
      - ./hadoop.env

  hive-server:
    image: bde2020/hive:2.3.2-postgresql-metastore
    container_name: hive-server
    environment:
      - HADOOP_CORE_SITE_OZONE_ENABLED=true
      - SERVICE_PRECONDITION=hive-metastore:9083
      - HIVE_SITE_CONF_hive_execution_engine=tez
      - HIVE_SITE_CONF_hive_llap_execution_mode=all
    ports:
      - "10000:10000"
      - "10002:10002"
    volumes:
      - ./clients.csv:/tmp/clients.csv

  hive-metastore:
    image: bde2020/hive:2.3.2-postgresql-metastore
    container_name: hive-metastore
    environment:
      - SERVICE_PRECONDITION=namenode:9870 datanode:9864 hive-metastore-postgresql:5432
    command: /opt/hive/bin/hive --service metastore
    ports:
      - "9083:9083"

  hive-metastore-postgresql:
    image: bde2020/hive-metastore-postgresql:2.3.0
    container_name: hive-metastore-postgresql
```

## 2. Démarrage de l'environnement

1. Dans votre terminal, lancez le cluster :
   ```bash
   docker compose up -d
   ```
2. Patientez (1 à 2 minutes) pour que les services YARN et Hive s'initialisent.

## 3. Déroulement de l'Atelier

### Étape 1 – Chargement sur HDFS
Entrez dans le conteneur du NameNode :
```bash
docker exec -it namenode bash
```
Jouez les commandes HDFS :
```bash
hdfs dfs -mkdir -p /user/hadoop/exemple_clients
hdfs dfs -chmod 775 /user/hadoop/exemple_clients
hdfs dfs -put /tmp/clients.csv /user/hadoop/exemple_clients/
hdfs dfs -ls /user/hadoop/exemple_clients
exit
```

### Étape 2 – Création de la table Hive externe
Connectez-vous au serveur Hive :
```bash
docker exec -it hive-server bash
hive
```
Dans l'invite Hive, exécutez :
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
LOCATION '/user/hadoop/exemple_clients' 
TBLPROPERTIES("skip.header.line.count"="1");
```

### Étape 3 & 4 – Requête HiveQL et Comparaison des Moteurs

**Test avec MapReduce (déprécié, pour comparaison) :**
```sql
SET hive.execution.engine=mr;
SELECT ville, COUNT(*) AS nb_clients FROM clients GROUP BY ville;
```
*Temps attendu : ~30 à 60 secondes.*

**Test avec Tez (moteur par défaut) :**
```sql
SET hive.execution.engine=tez;
SELECT ville, COUNT(*) AS nb_clients FROM clients GROUP BY ville;
```
*Temps attendu : ~5 à 10 secondes (évite l'écriture sur disque des étapes intermédiaires).*

**Test avec LLAP :**
```sql
SET hive.execution.engine=tez;
SET hive.llap.execution.mode=all;
SELECT ville, COUNT(*) AS nb_clients FROM clients GROUP BY ville;
```
*Note : En environnement de production correctement taillé, LLAP offre un temps de réponse quasi immédiat (< 2 secondes).*
