# This file is used to partition, mount and install arch linux on UEFI systems.

# Default keyboard layout is US.
# To change layout :
# 1. Use `localectl list-keymaps` to display liste of keymaps.
# 2. Use  `loadkeys [keymap]` to set keyboard layout.
#    ex : `loadkeys de-latin1` to set a german keyboard layout.

# Check if system is booted in UEFI mode.
if [ ! -d "/sys/firmware/efi/efivars" ] 
then
    # If not, then exit installer.
    echo "[Error!] System is not booted in UEFI mode. Please boot in UEFI mode & try again."
    exit 9999
fi

# Figure out how much RAM the system has an set a variable
# ramTotal=$(grep MemTotal /proc/meminfo | awk '{print $2 / 1024 / 1024}')
ramTotal=$(free | awk '/^Mem:/{print $2 / 1024 / 1024}'  | awk -F. {'print$1'})

# Update system clock.
# timedatectl set-ntp true

# Load kernel modules
# modprobe dm-crypt
# modprobe dm-mod

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
echo "-$ramTotal"G # Set Max RAM as last sector.
# echo -4096M  # Set -4096 as last sector.
echo n       # Create new partition (for swap).
echo         # Set default partition number.
echo         # Set default first sector.
echo         # Set default last sector (rest of the disk).
echo t       # Change partition type.
echo 1       # Pick first partition.
echo 1       # Change first partition to EFI system.
echo t       # Change partition type.
echo 3       # Pick third partition.
echo 19      # Change third partition to Linux swap.
echo w       # write changes. 
) | sudo fdisk $driveName -w always -W always

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

echo ""
echo "Which is the swap partition?"
read swapName

# Encrypt the root partition
# sudo cryptsetup luksFormat -v -s 512 -h sha512 $rootName

# Open the encrypted root partition
# sudo cryptsetup luksOpen $rootName crypt-root

sudo mkfs.fat -F32 -n EFI $efiName # EFI partition
sudo mkfs.ext4 -L root $rootName # /   partition
sudo mkswap -L swap $swapName # swap partition

# 0. Mount the filesystems.
sudo mount $rootName /mnt
sudo swapon $swapName

# 1. Create directory to mount EFI partition.
sudo mkdir /mnt/boot/

# 2.Mount the EFI partition.
sudo mount $efiName /mnt/boot

# Generate Nix configuration
sudo nixos-generate-config --root /mnt

# Edit Language and Time Zone
sed -i 's/# time.timeZone = "Europe/Amsterdam"/time.timeZone = "America/Denver"/g' /mnt/etc/nixos/configuration.nix
sed -i 's/# i18n.defaultLocalte = "en_US.UTF=8"/i18n.defaultLocalte = "en_US.UTF=8"/g' /mnt/etc/nixos/configuration.nix
sed -i 's/# console = {/console = {/g' /mnt/etc/nixos/configuration.nix
sed -i 's/# font = "Lat2-Terminus16";/font = "Lat2-Terminus16";/g' /mnt/etc/nixos/configuration.nix
sed -i 's/# keyMap/keyMap = {/g' /mnt/etc/nixos/configuration.nix

# Generate fstab file.
# genfstab -U /mnt >> /mnt/etc/fstab

# Install
sudo nixos-install

# Fetch script for `arch-chroot`.
# curl https://gitlab.com/ahoneybun/arch-itect/-/raw/main/setup.sh > /mnt/setup.sh

# Change root into the new system & run script.
#arch-chroot /mnt sh setup.sh

# Removed downloaded script.
rm install.sh

# Unmount all filesystems & reboot.
# umount -a
# reboot

