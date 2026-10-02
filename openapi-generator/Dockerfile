# https://hub.docker.com/_/node
FROM node:26-alpine
RUN npm install -g @openapitools/openapi-generator-cli &&\
    apk add --no-cache openjdk25-jre
ENTRYPOINT ["/usr/local/bin/openapi-generator-cli"]
CMD ["version"]