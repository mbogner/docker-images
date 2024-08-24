FROM mbopm/temurin-alpine-jre:jre21
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"
USER root

ADD kafka.tgz /opt/
RUN ln -s /opt/kafka_* /opt/kafka

COPY script/* /opt/kafka/

ENV KAFKA_HOME=/opt/kafka \
    KAFKA_CONNECT_CONFIG=/opt/kafka/config/connect.properties
WORKDIR /opt/kafka

RUN apk add --no-cache bash &&\
    adduser -D -h /opt/kafka -s /bin/bash kafka kafka && \
    chown -R kafka:kafka /opt/kafka* && \
    chmod +x /opt/kafka/*.sh

USER kafka
CMD ["/opt/kafka/start.sh"]
VOLUME /data/kraft-combined-logs
EXPOSE 8083
