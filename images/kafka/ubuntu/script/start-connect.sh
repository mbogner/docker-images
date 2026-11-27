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

# distributed mode by default. For a single standalone worker set
# KAFKA_CONNECT_CONFIG=/opt/kafka/config/connect-standalone.properties and override the command
# with: bin/connect-standalone.sh "$KAFKA_CONNECT_CONFIG" <connector.properties>...
exec bin/connect-distributed.sh "$KAFKA_CONNECT_CONFIG"
