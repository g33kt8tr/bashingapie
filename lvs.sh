#!/bin/bash

# Configurable variables
DISK="/dev/nvme0n1"             # Change this to your actual disk
PART="${DISK}p1"
VG_NAME="vg_data"
LV_NAME="lv_postgres"
LV_SIZE="10G"                  # Change to "100%FREE" to use all space
MOUNT_POINT="/mnt/postgres"
FS_TYPE="ext4"

echo "🚨 WARNING: This will erase all data on $DISK. Continue? (yes/no)"
read confirm
if [[ "$confirm" != "yes" ]]; then
  echo "Aborted."
  exit 1
fi

# Create GPT partition table and LVM partition
echo "🧱 Partitioning $DISK..."
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart primary 0% 100%
parted -s "$DISK" set 1 lvm on
sleep 1

# Create physical volume
echo "📦 Creating Physical Volume on $PART..."
pvcreate "$PART"

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
