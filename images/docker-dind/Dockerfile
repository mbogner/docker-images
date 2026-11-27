# One Dockerfile for all docker-in-docker images:
#   --target dind   -> mbopm/docker-dind-alpine-healthcheck   (docker:dind + healthcheck)
#   --target jdk21  -> mbopm/docker-dind-openjdk-alpine:*-jdk21 (+ Corretto JDK 21 from mbopm/corretto:jdk21-alpine)
#   --target jdk25  -> mbopm/docker-dind-openjdk-alpine:*-jdk25 (+ Corretto JDK 25 from mbopm/corretto:jdk25-alpine)
# The JDK images depend on mbopm/corretto (see BUILD_FIRST in images/build.sh).
# Keep the versions in sync with build-docker-dind-alpine-healthcheck.sh.

# https://hub.docker.com/_/docker/tags?name=dind-alpine
FROM docker:29.10.1-dind-alpine3.24 AS dind
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"
HEALTHCHECK --interval=1s --timeout=1s --start-period=5s --retries=30 CMD docker info > /dev/null || exit 1

# ---------------------------------------------------------------------------------------------
# Shared part of the JDK images: a build container that runs testcontainers based tests.
# The Corretto JDK is copied from our corretto images; dind and corretto use the same Alpine
# release, so the binaries find the system libraries they were built against.
FROM dind AS java
# bash for build scripts; the rest are the libraries Corretto's Alpine package depends on
# (AWT/X11 and ALSA), as installed in amazoncorretto:*-alpine.
RUN apk add --no-cache bash alsa-lib libx11 libxext libxi libxrender libxtst
ENV LANG=C.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/default-jvm \
    PATH=$PATH:/usr/lib/jvm/default-jvm/bin \
    JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75 -XX:+ExitOnOutOfMemoryError -XX:-UseBASE64Intrinsics -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"
WORKDIR /workdir
ENTRYPOINT []
VOLUME /workdir

FROM java AS jdk21
COPY --from=mbopm/corretto:jdk21-alpine /usr/lib/jvm /usr/lib/jvm
RUN java -version

FROM java AS jdk25
COPY --from=mbopm/corretto:jdk25-alpine /usr/lib/jvm /usr/lib/jvm
RUN java -version
