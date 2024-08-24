# temurin-alpine-jre

Alpine latest with Eclipse Temurin JRE 21. This image is meant to be used to run JVM based applications. It includes a
user named `application` with home directory `/home/application` which is set as default.

Default exposed port is `8080` and the default file run on startup is named `app.jar` placed under `/home/application`.

Sample for building an application with testcontainers test:

```dockerfile
FROM mbopm/docker-dind-temurin-alpine:latest AS builder
COPY ./ ./
CMD dockerd-entrypoint.sh & \
    ./gradlew build --no-daemon --stacktrace --info

FROM mbopm/temurin-alpine-jre:latest
COPY --from=builder /workdir/app/build/libs/app.jar .
```

This example assumes your application is built in /workdir/app/build/libs and named app.jar. This isn't the default in a
typical gradle Java build. `app` was added as a subproject and the spring bootJar task was configured to name the 
resulting file `app.jar`.

The `builder` container is using docker-dind to support testcontainers. See the docker hub page of the build container
for further infos about it.

The runtime image then simply adds the application to the workdir of the image and the default name assumed for the jar
file is `app.jar`. So the container will simply run the jar file when started. Of course you could also simply mount the
jar file instead of creating a separate image.

## Docker Compose

Here a sample for how to use this image inside a docker compose file to run an application:

```yaml
services:
  app:
    image: mbopm/temurin-alpine-jre:latest
    volumes:
      - "./app.jar:/home/application/app.jar:ro"
    healthcheck:
      test: nc -z -v localhost 8080 || exit 1
      interval: 1s
      timeout: 5s
      retries: 10
    ports:
      - "127.0.0.1:8080:8080"
```

The sample assumes you have an app.jar file in the same directory as the docker compose file and that the application
listens to port 8080 when started.

----------
- docker hub: https://hub.docker.com/repository/docker/mbopm/temurin-alpine-jre
- git: https://github.com/mbogner/docker-images