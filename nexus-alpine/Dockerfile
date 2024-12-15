FROM mbopm/openjdk-alpine-jre:jre17
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"

USER root
RUN apk add --no-cache curl && \
    curl -L https://download.sonatype.com/nexus/3/nexus-3.74.0-05-unix.tar.gz --output nexus.tar.gz && \
    tar -xf nexus.tar.gz && \
    rm -f nexus.tar.gz && \
    mv nexus* nexus && \
    chown -R application:application /home/application

USER application
ENV INSTALL4J_JAVA_HOME=/usr/lib/jvm/java-17-openjdk \
    NEXUS_HOME=/home/application/nexus \
    SONATYPE_WORK=/home/application/sonatype-work \
    NEXUS_SECRETS_KEY_FILE=/home/application/nexus.secrets.json
CMD ["/home/application/nexus/bin/nexus", "run"]
EXPOSE 8081
VOLUME /home/application/sonatype-work