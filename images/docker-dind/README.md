# Docker in Docker (Alpine)

All images are built from one Dockerfile with a shared `dind` stage:

| image                                  | tags                                                | content                                  |
|----------------------------------------|-----------------------------------------------------|------------------------------------------|
| `mbopm/docker-dind-alpine-healthcheck` | `29.10.1-dind-alpine3.24`, `dind-alpine`            | `docker:dind` with a healthcheck         |
| `mbopm/docker-dind-openjdk-alpine`     | `29.10.1-dind-alpine3.24-jdk21`                     | + Amazon Corretto JDK 21                 |
| `mbopm/docker-dind-openjdk-alpine`     | `29.10.1-dind-alpine3.24-jdk25`, `latest`           | + Amazon Corretto JDK 25                 |

The healthcheck runs `docker info`, so the container is healthy once the docker daemon answers.

## JDK images

Docker in docker plus the Corretto JDK of `mbopm/corretto:jdk<version>-alpine` (with its `JAVA_TOOL_OPTIONS`) and
`bash`. This way you can run testcontainers based tests inside the container without having to worry about how to get a
working docker environment. They are meant as build containers, not to run server applications.

Workdir and volume is `/workdir`, the entrypoint is cleared. To run a gradle build:

```dockerfile
FROM mbopm/docker-dind-openjdk-alpine:latest
COPY ./ ./
CMD dockerd-entrypoint.sh & ./gradlew build --no-daemon --stacktrace --info
```

The `dockerd-entrypoint.sh &` in front is important to have docker properly started for the tests. In all tests docker
was much faster than every gradle step that would rely on it, so that possible race condition was no problem.

The container needs `--privileged` like every docker in docker container.

----------
- docker hub: https://hub.docker.com/r/mbopm/docker-dind-alpine-healthcheck, https://hub.docker.com/r/mbopm/docker-dind-openjdk-alpine
- git: https://github.com/mbogner/docker-images
