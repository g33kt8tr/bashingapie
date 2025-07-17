#!/bin/bash
set -e

# Variables
RKE2_TOKEN="my-shared-secret"
CONFIG_FILE="/etc/rancher/rke2/config.yaml"
KUBECONFIG_SRC="/etc/rancher/rke2/rke2.yaml"
KUBECONFIG_DEST="$HOME/.kube/config"


echo "🧹 Uninstalling RKE2 (Rancher)..."

# Stop RKE2 services
sudo systemctl stop rke2-server || true
sudo systemctl disable rke2-server || true
sudo systemctl stop rke2-agent || true
sudo systemctl disable rke2-agent || true

# Remove binaries and symlinks
sudo rm -f /usr/local/bin/rke2*
sudo rm -f /usr/bin/rke2*

# Remove systemd units and config
sudo rm -rf /etc/systemd/system/rke2-*.service
sudo rm -rf /etc/rancher
sudo rm -rf /etc/rke2
sudo rm -rf /var/lib/rancher
sudo rm -rf /var/lib/kubelet
sudo rm -rf /var/lib/rke2
sudo rm -rf /var/lib/etcd

# Optional: Remove kubeconfig
sudo rm -f $HOME/.kube/config
sudo rm -f /etc/rancher/rke2/rke2.yaml


echo "🧹 Removing old Docker versions (if any)..."
sudo systemctl stop docker || true
sudo apt-get purge -y docker docker-engine docker.io containerd runc docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || true
sudo apt-get autoremove -y
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

echo "📦 Updating system and installing dependencies..."
sudo apt-get update
sudo apt-get install -y curl ca-certificates gnupg lsb-release

echo "🐳 Installing Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "📄 Creating RKE2 config..."
sudo mkdir -p /etc/rancher/rke2
sudo tee $CONFIG_FILE > /dev/null <<EOF
token: ${RKE2_TOKEN}
tls-san:
  - rancher.localhost
  - 127.0.0.1
node-name: localhost-rke2
EOF


echo "⚙️ Installing RKE2..."
curl -sfL https://get.rke2.io | sudo sh -


echo "🚀 Enabling and starting RKE2 server..."
sudo systemctl enable rke2-server.service
sudo systemctl start rke2-server.service

echo "⏳ Waiting for kubeconfig to be created..."
while [ ! -f "$KUBECONFIG_SRC" ]; do
  sleep 2
done

echo "📁 Setting up local kubeconfig..."
mkdir -p "$HOME/.kube"
sudo cp "$KUBECONFIG_SRC" "$KUBECONFIG_DEST"
sudo chown "$(id -u):$(id -g)" "$KUBECONFIG_DEST"

echo "✅ RKE2 setup complete. Test with:"
echo "   kubectl get nodes"

# 1. Install OpenSSH server
echo "Installing OpenSSH server..."
apt-get update && apt-get install -y openssh-server

# 2. Enable password authentication
CONFIG_FILE="/etc/ssh/sshd_config.d/50-cloud-init.conf"
echo "Modifying SSH configuration to enable password authentication..."
if grep -q "^PasswordAuthentication" "$CONFIG_FILE"; then
  sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' "$CONFIG_FILE"
else
  echo "PasswordAuthentication yes" >> "$CONFIG_FILE"
fi

# 3. Restart SSH service
echo "Restarting SSH service..."
systemctl restart ssh

