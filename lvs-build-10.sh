#!/bin/bash

# Configurable variables
DISK="/dev/nvme0n1"             # Change this to your actual disk
PART="${DISK}p1"
VG_NAME="vg_build"
LV_NAME="lv_build"
LV_SIZE="10G"                  # Change to "100%FREE" to use all space
MOUNT_POINT="/mnt/build"
FS_TYPE="ext4"

# Create volume group
echo "🗂️  Creating Volume Group $VG_NAME..."
vgcreate "$VG_NAME" "$PART"

# Create logical volume
echo "📁 Creating Logical Volume $LV_NAME..."
lvcreate -L "$LV_SIZE" -n "$LV_NAME" "$VG_NAME"

# Format logical volume
echo "🧽 Formatting with $FS_TYPE..."
mkfs."$FS_TYPE" "/dev/$VG_NAME/$LV_NAME"

# Create mount point and mount
echo "📂 Mounting to $MOUNT_POINT..."
mkdir -p "$MOUNT_POINT"
mount "/dev/$VG_NAME/$LV_NAME" "$MOUNT_POINT"

# Add to /etc/fstab
UUID=$(blkid -s UUID -o value "/dev/$VG_NAME/$LV_NAME")
echo "UUID=$UUID  $MOUNT_POINT  $FS_TYPE  defaults  0  2" | sudo tee -a /etc/fstab

echo "✅ Done. Volume mounted at $MOUNT_POINT and added to fstab."
