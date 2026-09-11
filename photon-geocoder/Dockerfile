FROM mbopm/openjdk-alpine-jdk:latest
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"

# base image sets workdir to /home/application
COPY photon.jar .

EXPOSE 2322/tcp
ENTRYPOINT ["java", "-jar", "photon.jar"]
CMD ["serve"]

HEALTHCHECK \
    --interval=10s \
    --timeout=2s \
    --start-period=10s \
    --retries=6 \
    CMD nc -z 127.0.0.1 2322 || exit 1
