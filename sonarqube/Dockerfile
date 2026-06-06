# https://hub.docker.com/_/sonarqube
FROM sonarqube:26.5.0.122743-community
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"

# repeated to remember
EXPOSE 9000
VOLUME /opt/sonarqube/data
VOLUME /opt/sonarqube/logs
VOLUME /opt/sonarqube/extensions
VOLUME /opt/sonarqube/temp

COPY --chmod=755 ./custom-entrypoint.sh /opt/sonarqube/docker
COPY ./plugins/*.jar /opt/sonarqube/docker/plugins/
COPY ./sonar.properties /opt/sonarqube/conf/sonar.properties
COPY ./docker-healthcheck.sh /opt/sonarqube/docker/docker-healthcheck.sh
COPY ./web/sonarqube-webapp.zip /opt/sonarqube/docker/

USER 0
RUN apt update && apt install -y unzip && apt autoclean && rm -rf /var/lib/apt/lists/* && \
    unzip -o /opt/sonarqube/docker/sonarqube-webapp.zip -d /opt/sonarqube/web/ && \
    chmod -R 755 /opt/sonarqube/web && \
    chown -R 1000:0 /opt/sonarqube/web
USER 1000

HEALTHCHECK --interval=5s --timeout=5s --retries=10 --start-period=10s CMD /opt/sonarqube/docker/docker-healthcheck.sh
CMD ["/opt/sonarqube/docker/custom-entrypoint.sh"]