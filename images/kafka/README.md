# Kafka KRaft + Kafka Connect

Both images are built from one Dockerfile per OS (`alpine/`, `ubuntu/`) with a shared Kafka stage, so they always
contain the same Kafka version:

| image                 | target    | tags                                                    |
|-----------------------|-----------|---------------------------------------------------------|
| `mbopm/kraft`         | `kraft`   | `alpine_<scala>-<kafka>` (+ `latest`), `ubuntu_<scala>-<kafka>` |
| `mbopm/kafka-connect` | `connect` | `alpine_<scala>-<kafka>` (+ `latest`), `ubuntu_<scala>-<kafka>` |

Base images: `mbopm/corretto:jre25-alpine` and `mbopm/openjdk:jre25-ubuntu`. Kafka lives in `/opt/kafka` (= workdir) and
runs as user `kafka` (1001:1001).

## mbopm/kraft

Kafka without zookeeper (KRaft, broker + controller).

- config: `$KAFKA_KRAFT_CONFIG` = `/opt/kafka/config/server.properties`. The default is Kafka's own config with
  `log.dirs=/data/kraft-combined-logs`, which is a volume. Mount your own config at that path for a cluster.
- on first start the storage is formatted with `$KAFKA_CLUSTER_ID` (a random id if unset; set it for a cluster). Configs
  with `controller.quorum.voters` (static quorum) are formatted as is, others with `--standalone`. Later starts reuse the
  existing data.

See `alpine/test/` for a 3 node cluster and https://github.com/mbogner/kafka-kraft2 for more examples.

## mbopm/kafka-connect

Kafka Connect in distributed mode, REST API on port `8083`.

- config: `$KAFKA_CONNECT_CONFIG` = `/opt/kafka/config/connect-distributed.properties`. Mount your own config at that
  path (the default connects to `localhost:9092`).
- includes the Debezium PostgreSQL connector (with the outbox `io.debezium.transforms.outbox.EventRouter` SMT) in
  `/opt/kafka/plugins`. `plugin.path=/opt/kafka/plugins` is set in both connect configs; keep it in your own config.
- standalone mode instead:

```yaml
command: ["bin/connect-standalone.sh", "/opt/kafka/config/connect-standalone.properties", "/config/connector.properties"]
```

Versions of Kafka and Debezium are pinned in `_shared.sh` (`KAFKA_SCALA_VERSION`, `KAFKA_VERSION`, `DEBEZIUM_VERSION`).

----------
- docker hub: https://hub.docker.com/r/mbopm/kraft, https://hub.docker.com/r/mbopm/kafka-connect
- git: https://github.com/mbogner/docker-images
