#!/bin/bash
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

set -e

echo "Creating K3d cluster..."
# Delete existing cluster if it exists
k3d cluster delete devcluster 2>/dev/null || true
k3d cluster create devcluster --port "80:80@loadbalancer"

echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=ready node --all --timeout=60s

echo "Deploying PostgreSQL for Retail Operations..."
kubectl apply -f retail-ops/k8s/postgres-database.yaml

echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres --timeout=120s

echo "Deploying MySQL for Physical Operations..."
kubectl apply -f physical-ops/k8s/mysql-database.yaml

echo "Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql --timeout=120s

echo "Deploying dashboard applications (no DB dependencies)..."
kubectl apply -f delivery-dashboard/k8s/deployment.yaml
kubectl apply -f delay-dashboard/k8s/deployment.yaml
kubectl apply -f demo/k8s/deployment.yaml

echo "Waiting for dashboard deployments to be ready..."
kubectl wait --for=condition=available deployment/delivery-dashboard deployment/delay-dashboard deployment/demo --timeout=120s

echo "Deploying backend applications (with DB dependencies)..."
kubectl apply -f physical-ops/k8s/deployment.yaml
kubectl apply -f retail-ops/k8s/deployment.yaml

echo "Waiting for all deployments to be ready..."
kubectl wait --for=condition=available deployment --all --timeout=300s

echo "Initializing Drasi..."
drasi init

echo "Setup complete! Applications are available at:"
echo "  Demo (All Apps): http://localhost/"
echo "  Physical Operations: http://localhost/physical-ops"
echo "  Retail Operations: http://localhost/retail-ops"
echo "  Delivery Dashboard: http://localhost/delivery-dashboard"
echo "  Delay Dashboard: http://localhost/delay-dashboard"