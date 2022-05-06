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
sudo cryptsetup luksFormat -v -s 512 -h sha512 $rootName

# Open the encrypted root partition
sudo cryptsetup luksOpen $rootName crypt-root

sudo mkfs.fat -F32 -n EFI $efiName            # EFI partition
sudo mkfs.ext4 -L root /dev/mapper/crypt-root # /   partition
sudo mkswap -L swap $swapName                 # swap partition

# 0. Mount the filesystems.
sudo mount /dev/disk/by-label/root /mnt
sudo swapon $swapName

# 1. Create directory to mount EFI partition.
sudo mkdir /mnt/boot/

# 2.Mount the EFI partition.
sudo mount $efiName /mnt/boot

# Generate Nix configuration
sudo nixos-generate-config --root /mnt

curl https://gitlab.com/ahoneybun/nixos-cli-installer/-/raw/main/config-gnome.nix > configuration.nix; sudo mv -f configuration.nix /mnt/etc/nixos/

# Install
sudo nixos-install

# Enter into installed OS
sudo mount -o bind /dev /mnt/dev
sudo mount -o bind /proc /mnt/proc
sudo mount -o bind /sys /mnt/sys
sudo chroot /mnt /nix/var/nix/profiles/system/activate
sudo chroot /mnt /run/current-system/sw/bin/bash

# Set password for user
passwd aaronh

# Exit chroot
exit

# Removed downloaded script.
rm install.sh

# Unmount all filesystems & reboot.
umount -a
reboot

