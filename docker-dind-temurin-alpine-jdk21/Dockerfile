# https://hub.docker.com/_/docker/tags?page=&page_size=&ordering=&name=dind-alpine
FROM docker:27.1.2-dind-alpine3.20 AS builder
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"
WORKDIR /workdir
RUN wget -O /etc/apk/keys/adoptium.rsa.pub https://packages.adoptium.net/artifactory/api/security/keypair/public/repositories/apk && \
    echo 'https://packages.adoptium.net/artifactory/apk/alpine/main' >> /etc/apk/repositories && \
    apk add --no-cache temurin-21-jdk
ENTRYPOINT []
VOLUME /workdir
