#!/bin/sh
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

## Create a k3d cluster
while ( ! kubectl cluster-info ); do
  # Docker takes a few seconds to initialize
  echo "Waiting for Docker to launch..."
  k3d cluster delete
  k3d cluster create -p '8081:80@loadbalancer' --k3s-arg '--disable=traefik@server:0'
  sleep 1
done

## Create Postgres service on k3d cluster and forward its port
kubectl apply -f ./resources/postgres.yaml
sleep 5
kubectl wait --for=condition=ready pod -l app=postgres --timeout=60s

## Install Drasi
drasi init

## Pre Pull Images to speed up the experience
docker pull drasidemo.azurecr.io/my-app:0.1
docker pull drasidemo.azurecr.io/my-app:0.2
docker pull drasidemo.azurecr.io/my-app:0.3
k3d image import drasidemo.azurecr.io/my-app:0.1
k3d image import drasidemo.azurecr.io/my-app:0.2
k3d image import drasidemo.azurecr.io/my-app:0.3