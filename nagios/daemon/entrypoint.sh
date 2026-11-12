#!/usr/bin/env bash
set -e

# set the email address of the default contact "nagiosadmin" (etc/objects/contacts.cfg)
CONTACTS_FILE=/opt/nagios/etc/objects/contacts.cfg
if [[ -n "$NAGIOSADMIN_EMAIL" ]]; then
  sed -i "/contact_name[[:space:]]\+nagiosadmin[[:space:]]/,/}/ s|^\([[:space:]]*email[[:space:]]*\)[^;]*|\1$NAGIOSADMIN_EMAIL |" "$CONTACTS_FILE"
  echo "set email of contact nagiosadmin to $NAGIOSADMIN_EMAIL"
fi

# load additional object configuration (hosts, services, commands, ...) from etc/conf.d/*.cfg
# done here and not at build time, so it also applies to an existing etc volume
CONF_DIR=/opt/nagios/etc/conf.d
MAIN_CONFIG_FILE=/opt/nagios/etc/nagios.cfg
mkdir -p "$CONF_DIR"
if ! grep -q "^cfg_dir=$CONF_DIR$" "$MAIN_CONFIG_FILE"; then
  printf '\n# additional configuration, added by the container entrypoint\ncfg_dir=%s\n' "$CONF_DIR" >> "$MAIN_CONFIG_FILE"
  echo "added cfg_dir=$CONF_DIR to $MAIN_CONFIG_FILE"
fi

# minutes within which all checks run for the first time after a start or reload (nagios default: 30)
if [[ -n "$MAX_CHECK_SPREAD" ]]; then
  sed -i -E "s/^max_(service|host)_check_spread=.*/max_\1_check_spread=$MAX_CHECK_SPREAD/" "$MAIN_CONFIG_FILE"
  echo "set max_service_check_spread and max_host_check_spread to $MAX_CHECK_SPREAD minutes"
fi

# the image ships without any hosts or services, nagios refuses to start without them
if ! compgen -G "$CONF_DIR/*.cfg" >/dev/null; then
  echo "no configuration found: mount a folder with *.cfg files defining hosts and services at $CONF_DIR" >&2
  exit 1
fi

exec "$@"
