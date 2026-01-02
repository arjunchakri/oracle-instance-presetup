#!/bin/bash
set -e

# --- Configuration ---
REPO_DIR="$HOME/oracle-instance-presetup"
DOCKER_DIR="$REPO_DIR/docker"

echo "=== 1. System Updates & Basic Tools ==="
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git apt-transport-https ca-certificates software-properties-common

echo "=== 2. Disable Firewall (Oracle Default) ==="
# Warning: This opens all ports. Ensure Oracle Cloud Security List is configured correctly.
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -F
sudo iptables -X
# Make firewall changes persistent
sudo DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent netfilter-persistent
sudo netfilter-persistent save

echo "=== 3. Install Docker ==="
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
else
    echo "Docker already installed."
fi

echo "=== 4. Install Cockpit ==="
sudo apt install -y cockpit
sudo systemctl enable --now cockpit.socket

echo "=== 5. Install Ollama ==="
if ! command -v ollama &> /dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo "Ollama already installed."
fi

echo "=== 6. Security Setup ==="
echo "Set a password for the current user ($USER):"
sudo passwd $USER

echo "=== 7. Start Containers ==="
# Ensure we are running compose from the correct directory
if [ -d "$DOCKER_DIR" ]; then
    cd "$DOCKER_DIR"
    sudo docker compose up -d
else
    echo "Error: Docker directory not found at $DOCKER_DIR"
fi

echo "=== SETUP COMPLETE ==="
echo "Cockpit:   https://$(curl -s ifconfig.me):9090"
echo "Portainer: https://$(curl -s ifconfig.me):9443"
echo "Nextcloud: http://$(curl -s ifconfig.me):8080"
echo "Webtop:    http://$(curl -s ifconfig.me):3000"
