# Kafka Connect with Debezium

`mbopm/kafka-connect` plus the Debezium PostgreSQL connector plugin (includes the Outbox Event
Router SMT `io.debezium.transforms.outbox.EventRouter`).

Plugin path: `/opt/kafka/plugins`. Set `plugin.path=/opt/kafka/plugins` in the Connect worker config.

The base image starts `connect-standalone.sh` with `$KAFKA_CONNECT_CONFIG`. For distributed mode
override the command, e.g.:

```yaml
command: ["bin/connect-distributed.sh", "/opt/kafka/config/connect-distributed.properties"]
```

Tag: `alpine_<scala>-<kafka>-<debezium>`, e.g. `alpine_2.13-4.3.1-3.7.0`.

----------
- docker hub: https://hub.docker.com/repository/docker/mbopm/kafka-connect-debezium
- git: https://github.com/mbogner/docker-images
