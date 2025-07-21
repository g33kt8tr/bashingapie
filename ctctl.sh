#!/bin/bash

set -e

REPO_URL="https://git.cagan.tech/Cagan_Tech/ctctl.git"
INSTALL_DIR="$HOME/.local/bin"
APP_NAME="ctctl"
TMP_DIR="$(mktemp -d)"
GO_VERSION="1.22.4"

# Ensure ~/.local/bin is in PATH
export PATH="$INSTALL_DIR:$PATH"
mkdir -p "$INSTALL_DIR"

echo ">> Checking dependencies..."

# Check for curl
if ! command -v curl >/dev/null; then
    echo "curl is required. Install it and try again."
    exit 1
fi

# Check for git
if ! command -v git >/dev/null; then
    echo "Installing Git..."
    sudo apt update && sudo apt install -y git
fi

# Check for Go
if ! command -v go >/dev/null; then
    echo "Installing Go $GO_VERSION..."
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; fi
    if [ "$ARCH" = "aarch64" ]; then ARCH="arm64"; fi
    curl -LO "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-${ARCH}.tar.gz"
    echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.bashrc"
    echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.profile"
    export PATH=$PATH:/usr/local/go/bin
fi

echo ">> Cloning and building app..."

# Clone and build the app
cd "$TMP_DIR"
git clone "$REPO_URL" app
cd app

go mod tidy
go build -o "$INSTALL_DIR/$APP_NAME" main.go

echo "✅ Installed $APP_NAME to $INSTALL_DIR"
echo "🔁 Make sure $INSTALL_DIR is in your PATH."

# Clean up
rm -rf "$TMP_DIR"

# Run the app
echo "🚀 Launching app..."
exec "$INSTALL_DIR/$APP_NAME"
