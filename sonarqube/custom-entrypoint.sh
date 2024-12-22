#!/bin/bash
set -e
if [[ ! -f /opt/sonarqube/extensions/plugins/initialised ]]; then
  echo "copy default plugins"
  cp /opt/sonarqube/docker/plugins/*.jar /opt/sonarqube/extensions/plugins/
fi
touch /opt/sonarqube/extensions/plugins/initialised
/opt/sonarqube/docker/entrypoint.sh