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

## Install Drasi with retry logic (up to 3 attempts)
max_attempts=3
attempt=1
while [ $attempt -le $max_attempts ]; do
  echo "Installing Drasi (attempt $attempt of $max_attempts)..."
  if drasi init; then
    echo "Drasi initialized successfully"
    break
  else
    if [ $attempt -eq $max_attempts ]; then
      echo "Failed to initialize Drasi after $max_attempts attempts"
      exit 1
    fi
    echo "Drasi init failed, retrying in 5 seconds..."
    sleep 5
    attempt=$((attempt + 1))
  fi
done

## Pre Pull Images to speed up the experience
docker pull drasidemo.azurecr.io/my-app:0.1
docker pull drasidemo.azurecr.io/my-app:0.2
docker pull drasidemo.azurecr.io/my-app:0.3
k3d image import drasidemo.azurecr.io/my-app:0.1
k3d image import drasidemo.azurecr.io/my-app:0.2
k3d image import drasidemo.azurecr.io/my-app:0.3