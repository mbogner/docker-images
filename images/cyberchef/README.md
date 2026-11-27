# Cyberchef

Cyberchef instance hosted with nginx.

## Docker Compose

You can use docker-compose to start the container. Create a file named docker-compose.yml and run docker compose up -d
in the same directory. -d will detach your command and won't require your shell to stay open.

```yaml
services:
  cyberchef:
    image: mbopm/cyberchef:latest
    ports:
      - "127.0.0.1:8080:80"
```

----------

- docker hub: https://hub.docker.com/repository/docker/mbopm/cyberchef
- git: https://github.com/mbogner/docker-images