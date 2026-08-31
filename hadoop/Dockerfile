# =============================================================================
# Image cluster Hadoop 3.4.2 + Apache Tez 0.10.5
# Base : point de départ https://github.com/crystalloide/hadoop-tez-docker
# =============================================================================
FROM apache/hadoop:3.4.2

USER root

ENV TEZ_VERSION=0.10.5
ENV TEZ_HOME=/opt/tez

# Téléchargement et installation d'Apache Tez (même version que hive-conf/tez-site.xml
# et que la version bundlée par l'image Hive 4.1.0 utilisée pour Hive -> compatibilité garantie)
RUN curl -fSL "https://downloads.apache.org/tez/${TEZ_VERSION}/apache-tez-${TEZ_VERSION}-bin.tar.gz" \
        -o /tmp/tez.tar.gz \
    && mkdir -p ${TEZ_HOME} \
    && tar -xzf /tmp/tez.tar.gz -C ${TEZ_HOME} --strip-components=1 \
    # on conserve l'archive d'origine : c'est elle qui sera uploadée sur HDFS par tez-init.sh
    && cp /tmp/tez.tar.gz ${TEZ_HOME}/tez.tar.gz \
    && rm /tmp/tez.tar.gz \
    && chown -R hadoop:hadoop ${TEZ_HOME}

# tez-site.xml : nécessaire côté cluster pour que l'AM Tez lancé par YARN retrouve
# tez.lib.uris (le tarball déposé sur HDFS) et sache où trouver ses classes
COPY tez-site.xml /opt/hadoop/etc/hadoop/tez-site.xml

# Jars Tez dans le classpath Hadoop (indispensable pour le client "hadoop jar ... yarn-tez"
# et pour que les conteneurs YARN démarrés sur ce nœud voient les classes Tez)
RUN echo "export HADOOP_CLASSPATH=\${HADOOP_CLASSPATH}:${TEZ_HOME}/*:${TEZ_HOME}/lib/*" \
    >> /opt/hadoop/etc/hadoop/hadoop-env.sh \
    && chown hadoop:hadoop /opt/hadoop/etc/hadoop/tez-site.xml

USER hadoop
