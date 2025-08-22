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

echo "========================================="
echo "Dapr + Drasi Tutorial - Dev Reload"
echo "========================================="

echo "This script reloads all deployments to pull the latest images"
echo ""

# Delete and recreate all deployments to force image pull
echo "Reloading Products service..."
kubectl delete deployment products 2>/dev/null || true
kubectl apply -f services/products/k8s/deployment.yaml

echo "Reloading Customers service..."
kubectl delete deployment customers 2>/dev/null || true
kubectl apply -f services/customers/k8s/deployment.yaml

echo "Reloading Orders service..."
kubectl delete deployment orders 2>/dev/null || true
kubectl apply -f services/orders/k8s/deployment.yaml

echo "Reloading Reviews service..."
kubectl delete deployment reviews 2>/dev/null || true
kubectl apply -f services/reviews/k8s/deployment.yaml

echo "Reloading Catalogue service..."
kubectl delete deployment catalogue 2>/dev/null || true
kubectl apply -f services/catalogue/k8s/deployment.yaml

echo "Reloading Dashboard service..."
kubectl delete deployment dashboard 2>/dev/null || true
kubectl apply -f services/dashboard/k8s/deployment.yaml

echo "Reloading Notifications service..."
kubectl delete deployment notifications 2>/dev/null || true
kubectl apply -f services/notifications/k8s/deployment.yaml

echo "Waiting for all deployments to be ready..."
kubectl wait --for=condition=available deployment --all --timeout=300s

echo "Waiting for all pods to be ready..."
kubectl wait --for=condition=Ready pod --all --timeout=300s

echo ""
echo "========================================="
echo "Dev Reload Complete!"
echo "========================================="
echo ""
echo "All services have been reloaded with the latest images."