#!/bin/sh
# Copyright 2025 The Drasi Authors.
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

## Install Drasi CLI
curl -fsSL https://raw.githubusercontent.com/drasi-project/drasi-platform/main/cli/installers/install-drasi-cli.sh | /bin/bash

## Setting up locale since `node:18-bookworm` does not have it configured
apt-get update
apt-get install -y locales
sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen
locale-gen