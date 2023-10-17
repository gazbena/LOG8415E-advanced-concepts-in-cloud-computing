#!/bin/bash

# Install usefull packages
sudo apt-get update
sudo apt-get install -y \
    fping \
    unzip \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker’s official GPG key:
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


# Install Docker engine, containerd, and Docker Compose.
sudo apt-get update
sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo docker run hello-world

# Unpack the FastAPI app
unzip /tmp/proxy_app.zip
cd proxy

# Deploy the docker container
sudo docker image build -t proxy:latest .
sudo docker run -t -d -v ~/.aws/:/root/.aws:ro --name proxy -p  8000:8000 proxy:latest
touch /tmp/finished-user-data