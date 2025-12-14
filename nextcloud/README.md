# Nextcloud

Simple way to run nextcloud within a single container. [docker-compose.yml](docker-compose.yml) shows how to run a local
test setup and [setup.sh](setup.sh) configured nextcloud without the use of any UI. It also creates two users: alice and
bob. The setup script can be run from within the container or by running [run-setup.sh](run-setup.sh) from outside.

----------

- docker hub https://hub.docker.com/repository/docker/mbopm/nextcloud
- git: https://github.com/mbogner/docker-images