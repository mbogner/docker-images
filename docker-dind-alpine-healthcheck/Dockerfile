# https://hub.docker.com/_/docker/tags?page=&page_size=&ordering=&name=dind-alpine
FROM docker:29.5.3-dind-alpine3.23
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"
HEALTHCHECK --interval=1s --timeout=1s --start-period=5s --retries=30 CMD docker info > /dev/null || exit 1