# docker-dind-openjdk-alpine

Alpine latest with OpenJDK JDK 21 with docker in docker available. This way you can run testcontainers based
tests inside the container without having to worry about how to get a working docker environment. This image is meant as
build container for applications and not to run server applications inside.

To run a gradle build you can easily do something like this:

```dockerfile
FROM mbopm/docker-dind-openjdk-alpine-jdk21:latest
COPY ./ ./
CMD dockerd-entrypoint.sh & ./gradlew build --no-daemon --stacktrace --info
```

The `dockerd-entrypoint.sh &` in front is important to have docker properly started for the test. In all tests docker
was much faster than every gradle step that would rely on it. So that possible race condition was no problem in all
runs.