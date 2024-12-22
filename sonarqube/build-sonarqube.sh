#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 98
source ../_shared.sh || exit 99

# https://github.com/insideapp-oss/sonar-apple/releases
APPLE_PLUGIN_VERSION="0.5.0"
# https://github.com/dependency-check/dependency-check-sonar-plugin/releases
DEPENDENCY_CHECK_VERSION="5.0.0"
# https://github.com/sbaudoin/sonar-shellcheck/releases
SHELLCHECK_VERSION="2.5.0"
# https://github.com/sbaudoin/sonar-yaml/releases
SONAR_YAML_VERSION="1.9.1"
# https://github.com/willemsrb/sonar-jdepend-plugin/releases
JDEPEND_VERSION="1.1.1"
# https://github.com/mc1arke/sonarqube-community-branch-plugin/releases
BRANCH_PLUGIN_VERSION="1.23.0"

../download.sh "https://github.com/insideapp-oss/sonar-apple/releases/download/$APPLE_PLUGIN_VERSION/sonar-apple-plugin-$APPLE_PLUGIN_VERSION.jar" "sonar-apple-plugin.jar" || exit 97
../download.sh "https://github.com/dependency-check/dependency-check-sonar-plugin/releases/download/$DEPENDENCY_CHECK_VERSION/sonar-dependency-check-plugin-$DEPENDENCY_CHECK_VERSION.jar" "sonar-dependency-check-plugin.jar" || exit 97
../download.sh "https://github.com/sbaudoin/sonar-shellcheck/releases/download/v$SHELLCHECK_VERSION/sonar-shellcheck-plugin-$SHELLCHECK_VERSION.jar" "sonar-shellcheck-plugin.jar" || exit 97
../download.sh "https://github.com/sbaudoin/sonar-yaml/releases/download/v$SONAR_YAML_VERSION/sonar-yaml-plugin-$SONAR_YAML_VERSION.jar" "sonar-yaml-plugin.jar" || exit 97
../download.sh "https://github.com/willemsrb/sonar-jdepend-plugin/releases/download/sonar-jdepend-plugin-$JDEPEND_VERSION/sonar-jdepend-plugin-$JDEPEND_VERSION.jar" "sonar-jdepend-plugin.jar" || exit 97
../download.sh "https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/$BRANCH_PLUGIN_VERSION/sonarqube-community-branch-plugin-$BRANCH_PLUGIN_VERSION.jar" "sonarqube-community-branch-plugin.jar" || exit 97

rm -rf ./plugins
mkdir ./plugins

cp ../downloads/sonar-apple-plugin.jar plugins/. || exit 96
cp ../downloads/sonar-dependency-check-plugin.jar plugins/. || exit 96
cp ../downloads/sonar-shellcheck-plugin.jar plugins/. || exit 96
cp ../downloads/sonar-yaml-plugin.jar plugins/. || exit 96
cp ../downloads/sonar-jdepend-plugin.jar plugins/. || exit 96
cp ../downloads/sonarqube-community-branch-plugin.jar plugins/. || exit 96

docker pull sonarqube:lts-community
build "sonarqube" "$PWD" "mbopm/sonarqube" "community" "latest"
rm -rf ./plugins