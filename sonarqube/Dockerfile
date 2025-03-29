# https://hub.docker.com/_/sonarqube
FROM sonarqube:25.3.0.104237-community
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

HEALTHCHECK --interval=5s --timeout=5s --retries=10 --start-period=10s CMD /opt/sonarqube/docker/docker-healthcheck.sh
ENTRYPOINT ["/opt/sonarqube/docker/custom-entrypoint.sh"]