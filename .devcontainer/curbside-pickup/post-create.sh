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
# See the License for the specific language governing permissions andls
# limitations under the License.

## Create a k3d cluster
while ( ! kubectl cluster-info ); do
  # Docker takes a few seconds to initialize
  echo "Waiting for Docker to launch..."
  k3d cluster delete
  k3d cluster create -p '8081:80@loadbalancer' --k3s-arg '--disable=traefik@server:0'
  sleep 1
done

echo "Setting up PostgreSQL for Retail Ops data storage..."
kubectl apply -f /workspaces/learning/apps/curbside-pickup/retail-ops/postgres-database.yaml

echo "Waiting for PostgreSQL to become ready..."
kubectl wait --for=condition=ready pod -l app=postgres --timeout=300s

echo "Setting up MySQL for Physical Ops data storage..."
kubectl apply -f /workspaces/learning/apps/curbside-pickup/physical-ops/mysql-database.yaml

echo "Waiting for MySQL to become ready..."
kubectl wait --for=condition=ready pod -l app=mysql --timeout=300s

echo "Installing Drasi..."
drasi init

echo "Setup complete. You can now run your application."
