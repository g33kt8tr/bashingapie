#!/bin/bash

# === Configuration ===
DEVICE="/dev/nvme0n1"     # Replace this with the correct disk or partition
MOUNT_POINT="/mnt/data1"
FS_TYPE="xfs"             # You can change to ext4 if you prefer

# === Ensure script is run as root ===
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root"
  exit 1
fi

# === Create the mount point ===
echo "📁 Creating mount point: $MOUNT_POINT"
mkdir -p "$MOUNT_POINT"

# === Format the device if needed ===
FS_EXISTS=$(blkid -o value -s TYPE "$DEVICE")
if [ -z "$FS_EXISTS" ]; then
  echo "💾 Formatting $DEVICE as $FS_TYPE"
  mkfs."$FS_TYPE" "$DEVICE"
else
  echo "ℹ️  $DEVICE already has a filesystem: $FS_EXISTS"
fi

# === Get the UUID of the device ===
UUID=$(blkid -s UUID -o value "$DEVICE")
if [ -z "$UUID" ]; then
  echo "❌ Failed to retrieve UUID for $DEVICE"
  exit 1
fi

# === Backup fstab and add entry if needed ===
echo "🔐 Backing up /etc/fstab to /etc/fstab.bak"
cp /etc/fstab /etc/fstab.bak

if ! grep -q "$UUID" /etc/fstab; then
  echo "📝 Adding UUID=$UUID to /etc/fstab"
  echo "UUID=$UUID $MOUNT_POINT $FS_TYPE defaults 0 2" >> /etc/fstab
else
  echo "✅ Entry already exists in /etc/fstab"
fi

# === Mount the disk ===
echo "📦 Mounting all filesystems"
mount -a

# === Verify ===
echo "✅ Mounted disks:"
df -h | grep "$MOUNT_POINT"
