#!/bin/bash
set -e

# Variables
RKE2_TOKEN="my-shared-secret"
CONFIG_FILE="/etc/rancher/rke2/config.yaml"
KUBECONFIG_SRC="/etc/rancher/rke2/rke2.yaml"
KUBECONFIG_DEST="$HOME/.kube/config"

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

echo "🧰 Installing kubectl for arm64..."
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "⚙️ Installing RKE2..."
curl -sfL https://get.rke2.io | sudo sh -

echo "📄 Creating RKE2 config..."
sudo mkdir -p /etc/rancher/rke2
sudo tee $CONFIG_FILE > /dev/null <<EOF
token: ${RKE2_TOKEN}
tls-san:
  - 127.0.0.1
node-name: localhost-rke2
EOF

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
