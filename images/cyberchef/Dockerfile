FROM alpine:3 AS unzipper
RUN apk add --no-cache unzip
# https://github.com/gchq/CyberChef - see latest release
ARG CYBERCHEF_VERSION=11.6.0
ADD https://github.com/gchq/CyberChef/releases/download/v11.6.0/CyberChef_f464d62c7c943cda9749a765932a7548ba9bfb16.zip /data/
RUN mkdir /data/out && unzip /data/CyberChef_f464d62c7c943cda9749a765932a7548ba9bfb16.zip -d /data/out/

FROM nginx:alpine
LABEL org.opencontainers.image.authors="clayey-radios-0j@icloud.com"
ENV CYBERCHEF_VERSION=11.6.0
RUN rm -rf /usr/share/nginx/html/*
COPY --from=unzipper /data/out/ /usr/share/nginx/html/
RUN ln -s /usr/share/nginx/html/CyberChef_v$CYBERCHEF_VERSION.html /usr/share/nginx/html/index.html
EXPOSE 80