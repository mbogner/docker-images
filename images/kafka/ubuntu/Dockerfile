# One Dockerfile for both Kafka images. They share the Kafka layer and one download, and
# neither needs the other to be pushed first:
#   --target kraft    -> mbopm/kraft          (KRaft broker + controller)
#   --target connect  -> mbopm/kafka-connect  (Kafka Connect, distributed, with Debezium PostgreSQL)

FROM mbopm/openjdk:jre25-ubuntu AS kafka
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"
USER root

ADD kafka.tgz /opt/
RUN ln -s /opt/kafka_* /opt/kafka
COPY script/ /opt/kafka/

# nc for healthchecks. kafka keeps UID/GID 1001 of the earlier alpine images.
RUN apt-get update \
 && apt-get install -y --no-install-recommends netcat-traditional \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && groupadd -g 1001 kafka \
 && useradd -u 1001 -g kafka -M -d /opt/kafka -s /bin/bash kafka \
 && chmod +x /opt/kafka/*.sh \
 && chown -R kafka:kafka /opt/kafka_*
ENV KAFKA_HOME=/opt/kafka
WORKDIR /opt/kafka

# ---------------------------------------------------------------------------------------------
FROM kafka AS kraft
# Kafka's combined broker + controller config, with the data in the volume instead of /tmp.
RUN sed -i 's|^log.dirs=.*|log.dirs=/data/kraft-combined-logs|' /opt/kafka/config/server.properties \
 && grep -q '^log.dirs=/data/kraft-combined-logs$' /opt/kafka/config/server.properties \
 && mkdir -p /data/kraft-combined-logs \
 && chown kafka:kafka /data/kraft-combined-logs
ENV KAFKA_KRAFT_CONFIG=/opt/kafka/config/server.properties
USER kafka
VOLUME /data/kraft-combined-logs
CMD ["/opt/kafka/start-kraft.sh"]

# ---------------------------------------------------------------------------------------------
FROM kafka AS connect
# Debezium PostgreSQL connector (incl. the outbox EventRouter SMT), found via plugin.path.
ADD debezium-connector-postgres.tar.gz /opt/kafka/plugins/
RUN printf '\nplugin.path=/opt/kafka/plugins\n' \
      | tee -a /opt/kafka/config/connect-distributed.properties /opt/kafka/config/connect-standalone.properties >/dev/null
ENV KAFKA_CONNECT_CONFIG=/opt/kafka/config/connect-distributed.properties
USER kafka
EXPOSE 8083
CMD ["/opt/kafka/start-connect.sh"]
