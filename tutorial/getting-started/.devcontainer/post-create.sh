#!/bin/sh

## Create a k3d cluster
while ( ! kubectl cluster-info ); do
  # Docker takes a few seconds to initialize
  echo "Waiting for Docker to launch..."
  k3d cluster delete
  k3d cluster create -p '8081:80@loadbalancer' --k3s-arg '--disable=traefik@server:0'
  sleep 1
done

## Install Drasi
drasi init --version preview.1

## Install PostgreSQL CLI
sudo apt-get update
sudo apt-get install --no-install-recommends --assume-yes postgresql-client

## Install PostgreSQL on K3d
kubectl apply -f https://drasi.blob.core.windows.net/installs/drasi-postgres.yaml -n drasi-system
sleep 15
kubectl wait --for=condition=ready pod -l app=postgres -n drasi-system --timeout=60s