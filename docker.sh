#!/bin/bash

echo "--- 1. Creating Docker Volumes ---"
docker volume create portainer_data
docker volume create nextcloud_data
docker volume create webtop_data
docker volume create open-webui_data

echo "--- 2. Cleaning up old containers (if they exist) ---"
docker rm -f portainer nextcloud webtop open-webui 2>/dev/null || true

echo "--- 3. Starting Portainer ---"
# Accessible at https://<IP>:9443
docker run -d \
  --name portainer \
  --restart=always \
  -p 9443:9443 \
  -v /etc/localtime:/etc/localtime:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

echo "--- 4. Starting Nextcloud ---"
# Accessible at http://<IP>:8080
docker run -d \
  --name nextcloud \
  --restart=always \
  -p 8080:80 \
  -v nextcloud_data:/var/www/html \
  -v /home/ubuntu/Downloads:/mnt/host_downloads \
  -e SQLITE_DATABASE=nextcloud \
  nextcloud:latest

echo "--- 5. Starting Webtop (Ubuntu XFCE) ---"
# Accessible at http://<IP>:3000
docker run -d \
  --name webtop \
  --restart=unless-stopped \
  -p 3000:3000 \
  --security-opt seccomp=unconfined \
  --shm-size="1gb" \
  -e PUID=$(id -u) \
  -e PGID=$(id -g) \
  -e TZ=Etc/UTC \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v webtop_data:/config \
  lscr.io/linuxserver/webtop:ubuntu-xfce

echo "--- 6. Starting Open WebUI (for Ollama) ---"
# Accessible at http://<IP>:3001
# Note: --add-host allows the container to talk to Ollama running on the host machine
docker run -d \
  --name open-webui \
  --restart=always \
  -p 3001:8080 \
  --add-host=host.docker.internal:host-gateway \
  -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
  -v open-webui_data:/app/backend/data \
  ghcr.io/open-webui/open-webui:main

echo "--- All Containers Started ---"
docker ps
