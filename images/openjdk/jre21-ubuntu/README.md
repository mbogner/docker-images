# mbopm/openjdk:jre21-ubuntu

Tags: `mbopm/openjdk:jre21-ubuntu`

Base image with the headless OpenJDK JRE 21 (no GUI libraries) on Ubuntu 26.04 (`ubuntu:26.04`). Meant to run JVM based applications. Nothing else is installed on top of the base image and the JDK/JRE
package (no ssh, git, nodejs, ...), so derived images add what they need.

- runs as user `application` (1000:1000) with shell `/bin/sh` and home directory `/home/application` (= workdir)
- exposes port `8080`
- default command is `java -jar app.jar`
- sets `JAVA_TOOL_OPTIONS`, which java inside the container picks up:

```shell
JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75 -XX:+ExitOnOutOfMemoryError -XX:-UseBASE64Intrinsics -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"
```

All of these can be overridden in derived images.

## Usage

Copy your jar as `app.jar` into the workdir:

```dockerfile
FROM mbopm/openjdk:jre21-ubuntu
COPY build/libs/app.jar .
```

Or mount it with docker compose:

```yaml
services:
  app:
    image: mbopm/openjdk:jre21-ubuntu
    volumes:
      - "./app.jar:/home/application/app.jar:ro"
    ports:
      - "127.0.0.1:8080:8080"
```

To install more packages, switch to `root` and back:

```dockerfile
FROM mbopm/openjdk:jre21-ubuntu
USER root
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*
USER 1000:1000
```

----------
- docker hub: https://hub.docker.com/r/mbopm/openjdk
- git: https://github.com/mbogner/docker-images
