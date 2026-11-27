#!/usr/bin/env bash
set -e

# create the login for the web interface on first start
# the default cgi.cfg grants full access to the user "nagiosadmin"
HTPASSWD_FILE=/opt/nagios/etc/htpasswd.users
if [[ ! -s "$HTPASSWD_FILE" ]]; then
  if [[ -z "$NAGIOSADMIN_PASSWORD" ]]; then
    echo "$HTPASSWD_FILE is missing: set NAGIOSADMIN_PASSWORD to create it" >&2
    exit 1
  fi
  echo "nagiosadmin:$(mkpasswd -m sha512 "$NAGIOSADMIN_PASSWORD")" > "$HTPASSWD_FILE"
  echo "created $HTPASSWD_FILE for user nagiosadmin"
fi

exec "$@"
