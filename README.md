# Docker Images

This repository contains various docker image sources that are online on docker hub. See subfolders for information
about the single images.

Every folder with a build has a README.md that links to the specific repository on docker hub and there is also a link
to the github repository. Further all have a `build_*.sh` file to start a build. Every image has its own builder so they
can be run simultaneously. All build scripts share the common [_shared.sh](_shared.sh) script. Next to that there is
also a [download.sh](download.sh) script that allows to get files into a shared downloads folder.

-------

- docker hub: https://hub.docker.com/repositories/mbopm
- git: https://github.com/mbogner/docker-images