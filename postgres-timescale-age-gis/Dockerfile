# ---------- builder ----------
FROM timescale/timescaledb-ha:pg18 AS builder

USER root

RUN apt update && apt install -y --no-install-recommends \
    git build-essential ca-certificates \
    postgresql-server-dev-18 \
    flex bison \
    libreadline-dev zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

RUN git clone --branch PG18 --depth 1 https://github.com/apache/age.git /tmp/age \
 && make -C /tmp/age PG_CONFIG=/usr/lib/postgresql/18/bin/pg_config install

# ---------- final ----------
FROM timescale/timescaledb-ha:pg18

USER root

# copy installed AGE artifacts from builder
COPY --from=builder /usr/lib/postgresql/18/lib/age.so /usr/lib/postgresql/18/lib/
COPY --from=builder /usr/share/postgresql/18/extension/age* /usr/share/postgresql/18/extension/

COPY init/ /docker-entrypoint-initdb.d/

USER postgres