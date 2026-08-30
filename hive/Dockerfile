FROM apache/hive:4.2.1
USER root
RUN curl -fsSL https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.5/postgresql-42.7.5.jar -o /opt/hive/lib/postgresql.jar
RUN mkdir -p /hive_custom_conf
COPY conf/ /hive_custom_conf/
USER hive
