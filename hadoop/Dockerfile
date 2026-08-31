FROM apache/hadoop:3.4.1
USER root
COPY conf/ /opt/hadoop/etc/hadoop/
RUN mkdir -p /data/nn /data/dn /data/yarn/local /data/yarn/logs /data/mr-history && chown -R hadoop:users /data
