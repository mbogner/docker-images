#!/bin/bash
#
# Copyright (c) 2023.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
set -e

# Format the storage only on first start. Later starts reuse the existing data (and its
# cluster id), so a random id generated on each start does not clash with the stored one.
LOG_DIRS=$(sed -n -e 's/^log\.dirs=//p' -e 's/^log\.dir=//p' "$KAFKA_KRAFT_CONFIG" | tail -n 1)
FIRST_LOG_DIR="${LOG_DIRS%%,*}"
if [[ -n "$FIRST_LOG_DIR" && -f "$FIRST_LOG_DIR/meta.properties" ]]; then
  echo "storage in $FIRST_LOG_DIR already formatted (cluster id $(sed -n 's/^cluster\.id=//p' "$FIRST_LOG_DIR/meta.properties"))"
else
  if [[ -z "${KAFKA_CLUSTER_ID:-}" ]]; then
    echo "WARNING: KAFKA_CLUSTER_ID was not set in env. creating a random id."
    KAFKA_CLUSTER_ID="$(bin/kafka-storage.sh random-uuid)"
    export KAFKA_CLUSTER_ID
    echo "WARNING: generated cluster id is $KAFKA_CLUSTER_ID"
  else
    echo "using cluster id $KAFKA_CLUSTER_ID"
  fi
  # A config with a static quorum (controller.quorum.voters) formats as is; Kafka 4's default
  # config uses a dynamic quorum, which needs --standalone for a single node.
  FORMAT_ARGS=()
  if ! grep -q '^controller\.quorum\.voters=' "$KAFKA_KRAFT_CONFIG"; then
    FORMAT_ARGS+=(--standalone)
  fi
  bin/kafka-storage.sh format -t "$KAFKA_CLUSTER_ID" -c "$KAFKA_KRAFT_CONFIG" "${FORMAT_ARGS[@]}"
fi

exec bin/kafka-server-start.sh "$KAFKA_KRAFT_CONFIG"
