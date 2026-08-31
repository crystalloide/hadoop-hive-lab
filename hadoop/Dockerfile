# =============================================================================
# Image cluster Hadoop 3.4.2 + Apache Tez 0.10.5
# Base : point de départ https://github.com/crystalloide/hadoop-tez-docker
# =============================================================================
FROM apache/hadoop:3.4.2

USER root

# -----------------------------------------------------------------------------
# JDK 11 pour les démons Hadoop (namenode/datanode/resourcemanager/nodemanager)
# et pour les conteneurs YARN qu'ils lancent (AM Tez, tasks).
#
# L'image officielle apache/hive (JDK17+) ajoute automatiquement des options
# JVM --add-opens=... en soumettant un job Tez. Le JDK 8 par défaut de cette
# image ne reconnaît pas cette syntaxe ("Unrecognized option: --add-opens"),
# et le conteneur de l'AM Tez plante immédiatement au lancement. Bug connu,
# non réglable côté configuration Hive/Tez — voir HIVE-29015 :
# https://issues.apache.org/jira/browse/HIVE-29015
# Le rapporteur du ticket confirme lui-même que passer Hadoop en JDK 9+ (il a
# testé JDK 17) résout le problème ; JDK 11 convient tout autant (Hadoop
# 3.3+/3.4.x le supporte officiellement en exécution).
#
# Installé ici par téléchargement direct (Eclipse Temurin / Adoptium),
# PAS via yum : cette image est basée sur CentOS 7, dont les dépôts
# "os"/"updates" pour cette version précise (7.6.1810) ont disparu des
# miroirs publics depuis la fin de vie de CentOS 7 (juin 2024) — `yum
# install` y échoue désormais de façon quasi systématique (mirrorlist.
# centos.org ne répond plus, et les miroirs de secours n'ont plus ce point
# de version). Le téléchargement direct d'une archive (même principe que
# pour Tez juste après) contourne complètement ce problème.
# -----------------------------------------------------------------------------
ENV JAVA11_HOME=/opt/jdk11
RUN mkdir -p ${JAVA11_HOME} \
    && curl -fSL "https://api.adoptium.net/v3/binary/latest/11/ga/linux/x64/jdk/hotspot/normal/eclipse" \
        -o /tmp/jdk11.tar.gz \
    && tar -xzf /tmp/jdk11.tar.gz -C ${JAVA11_HOME} --strip-components=1 \
    && rm /tmp/jdk11.tar.gz \
    && test -x "${JAVA11_HOME}/bin/java" || { \
         echo "ERREUR : ${JAVA11_HOME}/bin/java introuvable après extraction. Contenu de ${JAVA11_HOME} :"; \
         find "${JAVA11_HOME}"; \
         exit 1; \
       }
RUN { \
      echo "export JAVA_HOME=${JAVA11_HOME}"; \
      echo "export PATH=\${JAVA_HOME}/bin:\${PATH}"; \
    } >> /opt/hadoop/etc/hadoop/hadoop-env.sh

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
