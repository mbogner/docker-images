FROM amazoncorretto:25-al2023
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"

RUN dnf install -y shadow-utils \
 && groupadd -g 1000 application \
 && useradd -u 1000 -g application -m -d /home/application -s /bin/sh application \
 && dnf remove -y shadow-utils \
 && dnf clean all \
 && rm -rf /var/cache/dnf
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75 -XX:+ExitOnOutOfMemoryError -XX:-UseBASE64Intrinsics -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"

USER 1000:1000
WORKDIR /home/application
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
