#!/bin/bash
set -euo pipefail

# Run a command as www-data (supports heredoc/<<< because it forwards stdin)
as_www() {
  # usage: as_www "php occ status"
  su -s /bin/sh www-data -c "$*" || exit 1
}

# fully automated setup
as_www "php occ maintenance:install \
  --database pgsql \
  --database-host postgres \
  --database-name db \
  --database-user admin \
  --database-pass 's3cr3t' \
  --admin-user admin \
  --admin-pass '!12345Tgb!' \
  --data-dir /var/www/nextcloud/data"

#######################################
# Config
as_www "php occ config:system:set trusted_domains 0 --value 'localhost'"
as_www "php occ config:system:set trusted_domains 1 --value 'nextcloud'"
as_www "php occ config:system:set overwrite.cli.url --value 'http://localhost:8080'"
as_www "php occ config:system:set maintenance_window_start --type integer --value 1"

# empty skeleton -> no data for new users
as_www "php occ config:system:set skeletondirectory --value ''"

#######################################
# DB setup
as_www "php occ db:add-missing-indices"
as_www "php occ maintenance:repair --include-expensive"

#######################################
# Redis
as_www "php occ config:system:set memcache.local --value '\OC\Memcache\APCu'"
as_www "php occ config:system:set memcache.distributed --value '\OC\Memcache\Redis'"
as_www "php occ config:system:set memcache.locking --value '\OC\Memcache\Redis'"

as_www "php occ config:system:set redis host --value 'valkey'"
as_www "php occ config:system:set redis port --type integer --value 6379"
as_www "php occ config:system:set redis timeout --type float --value 1.5"

#######################################
# Mail (Mailpit SMTP)
as_www "php occ config:system:set mail_smtpmode --value 'smtp'"
as_www "php occ config:system:set mail_smtphost --value 'mail'"
as_www "php occ config:system:set mail_smtpport --type integer --value 1025"

# Auth
as_www "php occ config:system:set mail_smtpauth --type boolean --value true"
as_www "php occ config:system:set mail_smtpname --value 'smtp'"
as_www "php occ config:system:set mail_smtppassword --value 'pass123'"

# No TLS for Mailpit (local dev)
as_www "php occ config:system:set mail_smtpsecure --value ''"

# Defaults for outgoing mails
as_www "php occ config:system:set mail_from_address --value 'nextcloud'"
as_www "php occ config:system:set mail_domain --value 'local.test'"

#######################################
# test users (<<< works because as_www forwards stdin)
su -s /bin/sh www-data -c "php occ group:add group1"
as_www "php occ user:add alice --email alice@example.com --group group1 --generate-password"
as_www "php occ user:add bob --email bob@example.com --group group1 --generate-password"

#######################################
echo "all done"