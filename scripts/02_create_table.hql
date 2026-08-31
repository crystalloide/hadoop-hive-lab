-- Atelier — Étape 2 : création de la table Hive externe
CREATE EXTERNAL TABLE IF NOT EXISTS clients (
  id_client STRING,
  nom       STRING,
  age       INT,
  ville     STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hadoop/exemple_clients'
TBLPROPERTIES ("skip.header.line.count"="1");

SELECT * FROM clients LIMIT 5;
