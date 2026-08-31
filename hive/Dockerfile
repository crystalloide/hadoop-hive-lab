# L'image officielle apache/hive:4.1.0 (base eclipse-temurin ubi9-minimal) n'installe
# pas `findutils` alors que son PROPRE entrypoint.sh utilise `find` pour appliquer
# HIVE_CUSTOM_CONF_DIR (mécanisme officiel utilisé par ce lab pour pointer Hive vers
# notre cluster HDFS/YARN/Tez). Sans ce paquet, `find` échoue silencieusement et
# TOUTE la configuration personnalisée (hive-conf/) est ignorée.
FROM apache/hive:4.1.0

USER root
RUN microdnf install -y findutils && microdnf clean all
USER hive
