#!/bin/bash

set -e

REPO_URL="https://git.cagan.tech/Cagan_Tech/ctctl.git"
APP_NAME="ctctl"
INSTALL_DIR="$HOME/.local/bin"
TMP_DIR="$(mktemp -d)"
GO_VERSION="1.22.4"

echo "🔧 Checking dependencies..."

# Ensure .local/bin exists
mkdir -p "$INSTALL_DIR"

# Ensure ~/.local/bin is in PATH for future sessions
if ! grep -q "$INSTALL_DIR" "$HOME/.bashrc"; then
  echo "➕ Adding $INSTALL_DIR to PATH in ~/.bashrc"
  echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.bashrc"
fi

# Add to current session PATH
export PATH="$INSTALL_DIR:$PATH"

# Check for curl
if ! command -v curl >/dev/null; then
  echo "❌ curl is required. Please install it and rerun the script."
  exit 1
fi

# Check for git
if ! command -v git >/dev/null; then
  echo "📦 Installing git..."
  sudo apt update && sudo apt install -y git
fi

# Check for go
if ! command -v go >/dev/null; then
  echo "📦 Installing Go $GO_VERSION..."
  wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf /tmp/go.tar.gz
  export PATH="/usr/local/go/bin:$PATH"
  echo 'export PATH="/usr/local/go/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo "🚀 Cloning and building $APP_NAME..."
cd "$TMP_DIR"
git clone "$REPO_URL" app
cd app

echo "🔨 Building $APP_NAME..."
go build -o "$APP_NAME"

echo "📂 Installing to $INSTALL_DIR"
mv "$APP_NAME" "$INSTALL_DIR/"

echo "✅ Installed! You can now run: $APP_NAME"
echo "💡 You may need to run: source ~/.bashrc or restart your terminal."
