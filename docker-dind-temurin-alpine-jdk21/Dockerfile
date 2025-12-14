FROM mbopm/docker-dind-alpine-healthcheck:29.1.3-dind-alpine3.23
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"
WORKDIR /workdir
RUN wget -O /etc/apk/keys/adoptium.rsa.pub https://packages.adoptium.net/artifactory/api/security/keypair/public/repositories/apk && \
    echo 'https://packages.adoptium.net/artifactory/apk/alpine/main' >> /etc/apk/repositories && \
    apk add --no-cache temurin-21-jdk
ENTRYPOINT []
VOLUME /workdir
