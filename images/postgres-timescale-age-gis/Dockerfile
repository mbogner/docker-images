# ---------- vchord builder ----------
FROM tensorchord/vchord-scratch:pg18-v1.1.1 AS vchord

# ---------- age builder ----------
FROM timescale/timescaledb-ha:pg18 AS age

USER root

RUN apt update && apt install -y --no-install-recommends \
    git build-essential ca-certificates \
    postgresql-server-dev-18 \
    flex bison \
    libreadline-dev zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

RUN git clone --branch PG18 --depth 1 https://github.com/apache/age.git /tmp/age \
 && make -C /tmp/age PG_CONFIG=/usr/lib/postgresql/18/bin/pg_config install

# ---------- our image ----------
FROM timescale/timescaledb-ha:pg18

USER root

# AGE artifacts
COPY --from=age /usr/lib/postgresql/18/lib/age.so /usr/lib/postgresql/18/lib/
COPY --from=age /usr/share/postgresql/18/extension/age* /usr/share/postgresql/18/extension/

# VectorChord artifacts
COPY --from=vchord /usr/lib/postgresql/18/lib/vchord.so /usr/lib/postgresql/18/lib/
COPY --from=vchord /usr/share/postgresql/18/extension/vchord* /usr/share/postgresql/18/extension/

COPY init/ /docker-entrypoint-initdb.d/

USER postgres

CMD ["postgres", "-c", "timezone=UTC", "-c", "shared_preload_libraries=timescaledb,vchord"]