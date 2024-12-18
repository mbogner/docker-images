# Mosquito

Easy way to get a local mosquito server up and running. It is configured with default credentials and a healthcheck.

Default credentials:

- MOSQUITTO_USERNAME: mqtt_user
- MOSQUITTO_PASSWORD: mqtt_pass

You can override those on container startup by setting the shown environment variables.

Next to the standard port 1883 it also exposes a websocket port on 8080.

## docker compose

```yaml
services:
  mosquito:
    image: mbopm/mosquito:2
    ports:
      - "127.0.0.1:1883:1883"
      - "127.0.0.1:8080:8080"
    volumes:
      - mosquito_data:/mosquitto/data:rw

volumes:
  mosquito_data:
```

----------

- docker hub https://hub.docker.com/repository/docker/mbopm/mosquito
- git: https://github.com/mbogner/docker-images