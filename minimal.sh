# 1. System Updates
sudo apt update && sudo apt upgrade -y

# 2. Install Core Tools (Python 3.11, Docker, Cockpit, Tailscale)
sudo apt install -y docker.io cockpit python3.11-venv python3-pip git ncdu jq
curl -fsSL https://tailscale.com/install.sh | sh

# 3. Open the Firewall (As per your history lines 22-26)
sudo iptables -P INPUT ACCEPT
sudo iptables -F
sudo netfilter-persistent save

# 4. Install CasaOS (The Dashboard)
curl -fsSL https://get.casaos.io | sudo bash




curl -fsSL https://ollama.com/install.sh | sh
# Enable remote access (History line 524)
sudo mkdir -p /etc/systemd/system/ollama.service.d/
echo -e "[Service]\nEnvironment=\"OLLAMA_HOST=0.0.0.0\"\nEnvironment=\"OLLAMA_ORIGINS=*\"" | sudo tee /etc/systemd/system/ollama.service.d/override.conf
sudo systemctl daemon-reload && sudo systemctl restart ollama

# Pull your preferred models
ollama pull deepseek-r1:1.5b
ollama pull qwen2.5-coder:7b
ollama pull gemma2:2b
