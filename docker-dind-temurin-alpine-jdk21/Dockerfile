FROM docker:25.0.3-dind-alpine3.19 as builder
MAINTAINER Manuel Bogner <outrage_breath.0t@icloud.com>
WORKDIR /workdir
RUN wget -O /etc/apk/keys/adoptium.rsa.pub https://packages.adoptium.net/artifactory/api/security/keypair/public/repositories/apk && \
    echo 'https://packages.adoptium.net/artifactory/apk/alpine/main' >> /etc/apk/repositories && \
    apk add --no-cache temurin-21-jdk
ENTRYPOINT []
VOLUME /workdir
