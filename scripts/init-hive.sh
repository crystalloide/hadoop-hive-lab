#!/usr/bin/env bash
set -euo pipefail

beeline -u 'jdbc:hive2://hiveserver2:10000/default' --silent=true <<'SQL'
CREATE DATABASE IF NOT EXISTS formation;
USE formation;
DROP TABLE IF EXISTS clients;
CREATE EXTERNAL TABLE clients (
  id_client STRING,
  nom STRING,
  age INT,
  ville STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 'hdfs://hadoop:8020/data/exemple_clients'
TBLPROPERTIES ('skip.header.line.count'='1');
SELECT COUNT(*) FROM clients;
SQL

echo 'Hive bootstrap OK.'
