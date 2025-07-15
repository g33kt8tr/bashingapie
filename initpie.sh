if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo $0"
  exit 1
fi

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

# 4. Prompt user for new hostname
read -rp "Enter new hostname: " NEW_HOSTNAME

# 5. Change the hostname
echo "Setting hostname to '$NEW_HOSTNAME'..."
hostnamectl set-hostname "$NEW_HOSTNAME"

# Optional: Update /etc/hosts to reflect new hostname
if grep -q "127.0.1.1" /etc/hosts; then
  sed -i "s/127.0.1.1.*/127.0.1.1\t$NEW_HOSTNAME/" /etc/hosts
else
  echo -e "127.0.1.1\t$NEW_HOSTNAME" >> /etc/hosts
fi

echo "Setup complete. It's recommended to reboot the system."
