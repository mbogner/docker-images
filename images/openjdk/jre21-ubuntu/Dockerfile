FROM ubuntu:26.04
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"

# ubuntu:26.04 ships user "ubuntu" with UID 1000 - remove it so "application" gets 1000:1000.
RUN userdel -r ubuntu \
 && groupadd -g 1000 application \
 && useradd -u 1000 -g application -m -d /home/application -s /bin/sh application \
 && apt-get update \
 && apt-get install -y --no-install-recommends openjdk-21-jre-headless \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75 -XX:+ExitOnOutOfMemoryError -XX:-UseBASE64Intrinsics -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"

USER 1000:1000
WORKDIR /home/application
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
