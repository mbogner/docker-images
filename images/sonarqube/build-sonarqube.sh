#!/usr/bin/env bash
set -euxo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../../_shared.sh

# https://github.com/insideapp-oss/sonar-apple/releases
APPLE_PLUGIN_VERSION="0.5.1"
$DOWNLOADS_SCRIPT "https://github.com/insideapp-oss/sonar-apple/releases/download/$APPLE_PLUGIN_VERSION/sonar-apple-plugin-$APPLE_PLUGIN_VERSION.jar" "sonar-apple-plugin-$APPLE_PLUGIN_VERSION.jar"

# https://github.com/dependency-check/dependency-check-sonar-plugin/releases
DEPENDENCY_CHECK_VERSION="6.0.0"
$DOWNLOADS_SCRIPT "https://github.com/dependency-check/dependency-check-sonar-plugin/releases/download/$DEPENDENCY_CHECK_VERSION/sonar-dependency-check-plugin-$DEPENDENCY_CHECK_VERSION.jar" "sonar-dependency-check-plugin-$DEPENDENCY_CHECK_VERSION.jar"

# https://github.com/sbaudoin/sonar-shellcheck/releases
SHELLCHECK_VERSION="2.5.0"
$DOWNLOADS_SCRIPT "https://github.com/sbaudoin/sonar-shellcheck/releases/download/v$SHELLCHECK_VERSION/sonar-shellcheck-plugin-$SHELLCHECK_VERSION.jar" "sonar-shellcheck-plugin-$SHELLCHECK_VERSION.jar"

# https://github.com/sbaudoin/sonar-yaml/releases
SONAR_YAML_VERSION="1.9.1"
$DOWNLOADS_SCRIPT "https://github.com/sbaudoin/sonar-yaml/releases/download/v$SONAR_YAML_VERSION/sonar-yaml-plugin-$SONAR_YAML_VERSION.jar" "sonar-yaml-plugin-$SONAR_YAML_VERSION.jar"

# https://github.com/mc1arke/sonarqube-community-branch-plugin/releases
BRANCH_PLUGIN_VERSION="26.10.0"
$DOWNLOADS_SCRIPT "https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/$BRANCH_PLUGIN_VERSION/sonarqube-community-branch-plugin-$BRANCH_PLUGIN_VERSION.jar" "sonarqube-community-branch-plugin-$BRANCH_PLUGIN_VERSION.jar"
$DOWNLOADS_SCRIPT "https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/$BRANCH_PLUGIN_VERSION/sonarqube-webapp.zip" "sonarqube-webapp-$BRANCH_PLUGIN_VERSION.zip"

rm -rf ./plugins ./web
mkdir ./plugins ./web

cp "$DOWNLOADS_DIR/sonar-apple-plugin-$APPLE_PLUGIN_VERSION.jar" plugins/sonar-apple-plugin.jar
cp "$DOWNLOADS_DIR/sonar-dependency-check-plugin-$DEPENDENCY_CHECK_VERSION.jar" plugins/sonar-dependency-check-plugin.jar
cp "$DOWNLOADS_DIR/sonar-shellcheck-plugin-$SHELLCHECK_VERSION.jar" plugins/sonar-shellcheck-plugin.jar
cp "$DOWNLOADS_DIR/sonar-yaml-plugin-$SONAR_YAML_VERSION.jar" plugins/sonar-yaml-plugin.jar
cp "$DOWNLOADS_DIR/sonarqube-community-branch-plugin-$BRANCH_PLUGIN_VERSION.jar" plugins/sonarqube-community-branch-plugin.jar
cp "$DOWNLOADS_DIR/sonarqube-webapp-$BRANCH_PLUGIN_VERSION.zip" web/sonarqube-webapp.zip

# https://hub.docker.com/_/sonarqube
SONAR_VERSION=26.10.0.133078-community
docker pull sonarqube:$SONAR_VERSION
build "sonarqube" "$PWD" "mbopm/sonarqube" "$SONAR_VERSION" "latest"
rm -rf ./plugins ./web
