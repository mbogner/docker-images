# https://hub.docker.com/_/eclipse-mosquitto
FROM eclipse-mosquitto:2
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"

COPY mosquitto.conf /mosquitto/config/mosquitto.conf
COPY docker-entrypoint.sh /

ENTRYPOINT ["sh", "./docker-entrypoint.sh"]

CMD ["/usr/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]
EXPOSE 1883/tcp
EXPOSE 8080/tcp

HEALTHCHECK --interval=1s --timeout=1s --retries=30 CMD netstat -tulpen | grep 1883 || exit 1
ENV MOSQUITTO_USERNAME=mqtt_user \
    MOSQUITTO_PASSWORD=mqtt_pass