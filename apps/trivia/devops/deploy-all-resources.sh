# Copyright 2024 The Drasi Authors.
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

# Deploy Sources, then wait for them to be ready
drasi apply -f ./source-questions.yaml ./source-games.yaml
drasi wait -f ./source-questions.yaml ./source-games.yaml -t 180

# Deploy Continuous Queries, then wait for them to be ready
drasi apply -f ./queries.yaml
drasi wait -f ./queries.yaml -t 180

# Deploy Reactions, then wait for them to be ready
drasi apply -f ./reaction-signalr.yaml ./reaction-gremlin.yaml
drasi wait -f ./reaction-signalr.yaml ./reaction-gremlin.yaml -t 180