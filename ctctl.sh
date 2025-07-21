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

sudo snap install go --classic

echo ">> Cloning and building app..."

# Clone and build the app
cd "$TMP_DIR"
git clone "$REPO_URL" app
cd app

#!/bin/bash

set -e

APP_NAME="ctctl"
INSTALL_DIR="$HOME/.local/bin"

echo "🔨 Building $APP_NAME..."
go build -o "$APP_NAME"

echo "📂 Creating install directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

echo "🚚 Moving binary to $INSTALL_DIR"
mv "$APP_NAME" "$INSTALL_DIR/"

# Ensure ~/.local/bin is in PATH
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
  echo "➕ Adding $INSTALL_DIR to PATH in ~/.bashrc"
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  echo "💡 Run: source ~/.bashrc or restart your terminal to apply changes."
else
  echo "✅ $INSTALL_DIR is already in PATH"
fi

echo "🚀 Installed! You can now run: $APP_NAME"
