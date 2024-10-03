#!/bin/sh

# Install kubectl
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly
sudo apt-get update
sudo apt-get install -y kubectl

## Install PostgreSQL CLI
sudo apt-get install --no-install-recommends --assume-yes postgresql-client

## Install Drasi CLI
curl -fsSL https://raw.githubusercontent.com/drasi-project/drasi-platform/main/cli/installers/install-drasi-cli.sh | /bin/bash 
