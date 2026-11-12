#!/usr/bin/env bash
# sends the mail body read from stdin via msmtp, configured by environment variables
# usage: <body> | nagios-send-mail "<subject>" <recipient>
#
# SMTP_HOST      smtp server, required
# SMTP_TLS       off | starttls | tls (default: starttls)
# SMTP_PORT      default: 25 for off, 587 for starttls, 465 for tls
# SMTP_FROM      sender address (default: nagios@<hostname>)
# SMTP_USER      enables authentication when set
# SMTP_PASSWORD  password for SMTP_USER
set -e

SUBJECT=$1
RECIPIENT=$2

if [[ -z "$SMTP_HOST" ]]; then
  echo "SMTP_HOST is not set, cannot send mail to $RECIPIENT" >&2
  exit 1
fi

case "${SMTP_TLS:-starttls}" in
  off)      ARGS=(--tls=off);                      DEFAULT_PORT=25 ;;
  starttls) ARGS=(--tls=on --tls-starttls=on);     DEFAULT_PORT=587 ;;
  tls)      ARGS=(--tls=on --tls-starttls=off);    DEFAULT_PORT=465 ;;
  *)        echo "invalid SMTP_TLS: $SMTP_TLS (expected off, starttls or tls)" >&2; exit 1 ;;
esac

ARGS+=(--host="$SMTP_HOST" --port="${SMTP_PORT:-$DEFAULT_PORT}" --from="${SMTP_FROM:-nagios@$(hostname)}")

if [[ -n "$SMTP_USER" ]]; then
  # msmtp refuses to pick a plain text method without TLS, so request it explicitly
  # passwordeval keeps the password out of the process list
  [[ "${SMTP_TLS:-starttls}" == "off" ]] && AUTH=plain || AUTH=on
  ARGS+=(--auth="$AUTH" --user="$SMTP_USER" --passwordeval='printf "%s\n" "$SMTP_PASSWORD"')
else
  ARGS+=(--auth=off)
fi

{
  printf 'Subject: %s\nTo: %s\n\n' "$SUBJECT" "$RECIPIENT"
  cat
} | msmtp "${ARGS[@]}" -- "$RECIPIENT"
