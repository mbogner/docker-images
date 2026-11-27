# One Dockerfile for both Kafka images. They share the Kafka layer and one download, and
# neither needs the other to be pushed first:
#   --target kraft    -> mbopm/kraft          (KRaft broker + controller)
#   --target connect  -> mbopm/kafka-connect  (Kafka Connect, distributed, with Debezium PostgreSQL)

FROM mbopm/corretto:jre25-alpine AS kafka
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"
USER root

ADD kafka.tgz /opt/
RUN ln -s /opt/kafka_* /opt/kafka
COPY script/ /opt/kafka/

# bash: the Kafka scripts in bin/ need it. nc for healthchecks comes with busybox.
# kafka keeps UID/GID 1001 of the earlier images, so existing data volumes stay readable.
RUN apk add --no-cache bash \
 && addgroup -g 1001 kafka \
 && adduser -D -H -u 1001 -G kafka -h /opt/kafka -s /bin/bash kafka \
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
