# Figure out how much RAM the system has an set a variable
ramTotal=$(free -h | awk '/^Mem:/{print $2}'| awk -FG {'print$1'})

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
echo "Do you want Hibernation?"
echo "1) Yes"
echo "2) No"
read hibState

# Create EFI partition
sudo mkfs.fat -F32 -n EFI $efiName         

# Encrypt the root partition
sudo cryptsetup luksFormat -v -s 512 -h sha512 $rootName

# Open the encrypted root partition
sudo cryptsetup luksOpen $rootName crypt-root

sudo pvcreate /dev/mapper/crypt-root
sudo vgcreate lvm /dev/mapper/crypt-root

if [ $hibState = 1 ]; then
   sudo lvcreate -L "$ramTotal"G -n swap lvm

else

if [ $hibState = 2 ]; then
   sudo lvcreate -L 4G -n swap lvm

fi

fi

sudo lvcreate -l '100%FREE' -n root lvm

sudo btrfs filesystem label $rootName luks
# sudo cryptsetup config $rootName --label luks

sudo mkswap /dev/lvm/swap              # swap partition
sudo mkfs.btrfs -L root /dev/lvm/root  # /root partition

# 0. Mount the filesystems.
sudo swapon /dev/lvm/swap
sudo mount /dev/lvm/root /mnt

# Create Subvolumes
sudo btrfs subvolume create /mnt/@
sudo btrfs subvolume create /mnt/@home

# Unmount root
sudo umount /mnt

# Mount the subvolumes.
sudo mount -o noatime,commit=120,compress=zstd:10,subvol=@ /dev/lvm/root /mnt

sudo mkdir /mnt/home/
sudo mount -o noatime,commit=120,compress=zstd:10,subvol=@home /dev/lvm/root /mnt/home

# Mount the EFI partition.
sudo mkdir /mnt/boot/
sudo mount $efiName /mnt/boot

# Generate Nix configuration
sudo nixos-generate-config --root /mnt

# Coping over my config files
curl https://gitlab.com/ahoneybun/nyxi-installer/-/raw/main/plasma.nix > plasma.nix; sudo mv -f plasma.nix /mnt/etc/nixos/
curl https://gitlab.com/ahoneybun/nyxi-installer/-/raw/main/configuration.nix > configuration.nix; sudo mv -f configuration.nix /mnt/etc/nixos/

# Generate Nix configuration again for UUID's for LVM
# sudo nixos-generate-config --root /mnt

# Install
sudo nixos-install

# Start Setup section
# sudo -i
# curl https://gitlab.com/ahoneybun/nynx-installer/-/raw/main/setup.sh > /mnt/setup.sh

# Removed install script.
rm install.sh
