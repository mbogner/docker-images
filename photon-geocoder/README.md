# Photon Geocoder

Map search and reverse geocoder.

Releases are found under https://github.com/komoot/photon/releases. \
Map material can be downloaded under https://download1.graphhopper.com/public/.

It is required to mount the defined volume `/home/application/photon_data` with a prepared database from the map server
listed above. For example latest Austrian map data can be downloaded
from https://download1.graphhopper.com/public/europe/austria/photon-db-austria-master-latest.tar.bz2. The archive
contains a `photon_data` folder which directly can be mounted as the required volume.

```yaml
  photon-geocoder:
    image: mbopm/photon-geocoder:latest
    ports:
      - "127.0.0.1:8080:8080"
    volumes:
      - "./photon_data:/home/application/photon_data:rw"
```

See the [Dockerfile](Dockerfile) for infos about how entrypoint and command are configured.

## Samples

Sample query when running:

- Location: http://localhost:2322/api?q=Wien
- Reverse: http://localhost:2322/reverse?lon=16.3725042&lat=48.2083537

----------

## Links:

- docker hub https://hub.docker.com/repository/docker/mbopm/photon-geocoder
- git: https://github.com/mbogner/docker-images