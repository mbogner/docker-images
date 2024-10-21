FROM alpine:3
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"
RUN apk add --no-cache \
        bash \
        openjdk21-jdk \
        openssh \
        && \
    adduser -D -h /home/application -s /bin/bash application application
USER application
WORKDIR /home/application
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]