# Figure out how much RAM the system has an set a variable
# ramTotal=$(grep MemTotal /proc/meminfo | awk '{print $2 / 1024 / 1024}')
ramTotal=$(free | awk '/^Mem:/{print $2 / 1024 / 1024}'  | awk -F. {'print$1'})

# Detect and list the drives.
lsblk -f

# Choice the drive to use :
# 1. 
echo "----------"
echo ""
echo "Which drive do we want to use for this installation?"
read driveName

(
echo g       # Create new GPT partition table
echo n       # Create new partition (for EFI).
echo         # Set default partition number.
echo         # Set default first sector.
echo +512M   # Set +512M as last sector.
echo n       # Create new partition (for root).
echo         # Set default partition number.
echo         # Set default first sector.
echo n       # Create new partition (for swap).
echo         # Set default partition number.
echo         # Set default first sector.
echo         # Set default last sector (rest of the disk).
echo t       # Change partition type.
echo 1       # Pick first partition.
echo 1       # Change first partition to EFI system.
echo w       # write changes. 
) | sudo fdisk $driveName -w always -W always

# Move to root
sudo -i 

# List the new partitions.
lsblk -f

# Format the partitions :
echo "----------"
echo ""
echo "Which is the EFI partition?"
read efiName

echo ""
echo "Which is the root partition?"
read rootName

# Create EFI partition
mkfs.fat -F32 -n EFI $efiName         

# Encrypt the root partition
cryptsetup luksFormat -v -s 512 -h sha512 $rootName

# Open the encrypted root partition
cryptsetup luksOpen $rootName crypt-root

pvcreate /dev/mapper/crypt-root
vgcreate lvm /dev/mapper/crypt-root

lvcreate --size $ramTotal --name swap lvm
lvcreate --extents 100%FREE --name root lvm

cryptsetup config $rootName --label luks

mkswap /dev/lvm/swap              # swap partition
mkfs.btrfs -L root /dev/lvm/root  # /root partition

# 0. Mount the filesystems.
swapon /dev/lvm/swap
mount /dev/lvm/root /mnt

# Create Subvolumes
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home

# Unmount root
umount /mnt

# Mount the subvolumes.
mount -o noatime,commit=120,compress=zstd:10,space_cache,subvol=@ /dev/lvm/root /mnt

mkdir /mnt/home/
mount -o noatime,commit=120,compress=zstd:10,space_cache,subvol=@home /dev/lvm/root /mnt/home

# Mount the EFI partition.
mkdir /mnt/boot/
mount $efiName /mnt/boot

# Generate Nix configuration
nixos-generate-config --root /mnt

curl https://gitlab.com/ahoneybun/nixos-cli-installer/-/raw/nathaniel-btrfs/config-plasma.nix > configuration.nix; sudo mv -f configuration.nix /mnt/etc/nixos/

# Install
nixos-install

# Start Setup section
curl https://gitlab.com/ahoneybun/nixos-cli-installer/-/raw/nathaniel-btrfs/setup.sh > /mntsetup.sh

# Enter into installed OS
mount -o bind /dev /mnt/dev
mount -o bind /proc /mnt/proc
mount -o bind /sys /mnt/sys
chroot /mnt /nix/var/nix/profiles/system/activate
chroot /mnt /run/current-system/sw/bin/bash setup.sh

# Removed install script.
rm install.sh

# Remove setup script
rm setup.sh
