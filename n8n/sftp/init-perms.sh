#!/bin/sh
set -eu

# When /home/<user>/upload is a Docker volume, it can come up owned by root
# which makes SFTP uploads fail with "Permission denied".

mkdir -p /home/n8nftp/upload
chown -R 1000:1000 /home/n8nftp/upload
chmod -R u+rwX,go-rwx /home/n8nftp/upload
