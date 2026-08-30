FROM apache/hadoop:3.4.1
USER root
COPY conf/ /opt/hadoop/etc/hadoop/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && mkdir -p /data/nn /data/dn /data/yarn/local /data/yarn/logs /data/mr-history
ENTRYPOINT ["/entrypoint.sh"]
