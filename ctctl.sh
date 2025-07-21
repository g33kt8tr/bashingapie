#!/bin/bash
set -e

REPO_URL="https://git.cagan.tech/Cagan_Tech/ctctl.git"
APP_NAME="ctctl"
INSTALL_DIR="$HOME/.local/bin"
TMP_DIR="$(mktemp -d)"

echo "📥 Cloning $APP_NAME repo..."
git clone "$REPO_URL" "$TMP_DIR/app"

echo "🔨 Building $APP_NAME..."
cd "$TMP_DIR/app"
go build -o "$APP_NAME"

echo "📂 Creating install directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

echo "🚚 Moving binary to $INSTALL_DIR"
mv "$APP_NAME" "$INSTALL_DIR/"

# Check if INSTALL_DIR is in PATH, add if missing
if ! grep -q "$INSTALL_DIR" "$HOME/.bashrc"; then
  echo "➕ Adding $INSTALL_DIR to PATH in ~/.bashrc"
  echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.bashrc"
fi

# Add INSTALL_DIR to PATH for current session
export PATH="$INSTALL_DIR:$PATH"

echo "✅ $APP_NAME installed successfully!"
echo "💡 Please run 'source ~/.bashrc' or restart your terminal to update your PATH."
