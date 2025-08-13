# === Configuration ===
DEVICE="/mnt/data"  # Replace with your actual device or partition
MOUNT_POINT="/mnt/data/postgres"
FS_TYPE="ext4"

# === Ensure script is run as root ===
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root"
  exit 1
fi

# === Create mount point directory ===
echo "📁 Creating mount point: $MOUNT_POINT"
mkdir -p "$MOUNT_POINT"

# === Format the device if not already formatted ===
FS_EXISTS=$(blkid -o value -s TYPE "$DEVICE")
if [ -z "$FS_EXISTS" ]; then
  echo "💾 Formatting $DEVICE as $FS_TYPE"
  mkfs."$FS_TYPE" "$DEVICE"
else
  echo "ℹ️  Device $DEVICE already has a filesystem: $FS_EXISTS"
fi

# === Get the UUID of the device ===
UUID=$(blkid -s UUID -o value "$DEVICE")
if [ -z "$UUID" ]; then
  echo "❌ Failed to get UUID for $DEVICE"
  exit 1
fi

# === Backup /etc/fstab and add entry if not present ===
echo "🔐 Backing up /etc/fstab to /etc/fstab.bak"
cp /etc/fstab /etc/fstab.bak

if ! grep -q "$UUID" /etc/fstab; then
  echo "📝 Adding mount entry to /etc/fstab"
 sudo  echo "UUID=$UUID $MOUNT_POINT $FS_TYPE defaults 0 2" >> /etc/fstab
else
  echo "✅ UUID already present in /etc/fstab"
fi

# === Mount the filesystem ===
echo "📦 Mounting all filesystems"
mount -a

# === Final check ===
echo "📂 Mounted volumes:"
df -h | grep "$MOUNT_POINT"
