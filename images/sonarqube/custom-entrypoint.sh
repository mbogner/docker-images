#!/bin/bash
set -e
PLUGINS=/opt/sonarqube/extensions/plugins

if [[ ! -d $PLUGINS ]]; then
  mkdir -p $PLUGINS
fi
if [[ ! -f $PLUGINS/initialised ]]; then
  echo "copy default plugins"

  cp /opt/sonarqube/docker/plugins/*.jar $PLUGINS
fi
touch $PLUGINS/initialised
/opt/sonarqube/docker/entrypoint.sh