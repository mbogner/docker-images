# see https://www.nagios.org/download-access/open-source
NAGIOS_VERSION="4.5.14"
NAGIOS_PLUGIN_VERSION="2.5"

# see https://hub.docker.com/_/alpine
docker pull alpine:3

$DOWNLOADS_SCRIPT "https://go.nagios.org/get-core/$NAGIOS_VERSION" "nagios-$NAGIOS_VERSION.tgz"
cp "$DOWNLOADS_DIR/nagios-$NAGIOS_VERSION.tgz" ./nagios.tgz

$DOWNLOADS_SCRIPT "https://go.nagios.org/get-nagios-plugins-$NAGIOS_PLUGIN_VERSION.tar.gz" "nagios-plugins-$NAGIOS_PLUGIN_VERSION.tgz"
cp "$DOWNLOADS_DIR/nagios-plugins-$NAGIOS_PLUGIN_VERSION.tgz" ./nagios-plugins.tgz