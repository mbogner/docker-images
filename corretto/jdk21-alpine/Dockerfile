FROM amazoncorretto:21-alpine
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"

RUN addgroup -g 1000 application \
 && adduser -D -u 1000 -G application -h /home/application -s /bin/sh application
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75 -XX:+ExitOnOutOfMemoryError -XX:-UseBASE64Intrinsics -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"

USER 1000:1000
WORKDIR /home/application
EXPOSE 8080
