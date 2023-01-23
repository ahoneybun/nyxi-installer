# Figure out how much RAM the system has 
# then sets it as a variable for hibernation support
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
echo +1G     # Set +1G as last sector.
echo n       # Create new partition (for root).
echo         # Set default partition number.
echo         # Set default first sector.
echo         # Set last sector.
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

# sudo btrfs filesystem label $rootName luks
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

# Copy my base nix configs over
# Change the URL to match where you are hosting your .nix file(s).

echo "Default username and password are in the configuration.nix file"
echo "Password is hashed so it is not plaintext"

curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/configuration.nix > configuration.nix; sudo mv -f configuration.nix /mnt/etc/nixos/
curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/programs.nix > programs.nix; sudo mv -f programs.nix /mnt/etc/nixos/

echo ""
echo "Which Desktop Environment do you want?"
echo "1) Plasma"
echo "2) GNOME"
read desktopChoice

# Change the URL to match where you are hosting your DE/WM .nix file
# Update the second command to the file name that matches your DE/WM .nix file

if [ $desktopChoice = 1 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/desktops/plasma.nix > plasma.nix; sudo mv -f plasma.nix /mnt/etc/nixos/
   sudo sed -i "10 i \           ./plasma.nix" /mnt/etc/nixos/configuration.nix
else

if [ $desktopChoice = 2 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/desktops/gnome.nix > gnome.nix; sudo mv -f gnome.nix /mnt/etc/nixos/
   sudo sed -i "10 i \           ./gnome.nix" /mnt/etc/nixos/configuration.nix
fi

if [ $desktopChoice = 3 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/desktops/pantheon.nix > pantheon.nix; sudo mv -f pantheon.nix /mnt/etc/nixos/
   sudo sed -i "10 i \           ./pantheon.nix" /mnt/etc/nixos/configuration.nix
fi

fi

echo ""
echo "Which device are you installing to?"
echo "1) Oryx Pro (oryp6)"
echo "2) HP Omen (15-dh0015nr)"
echo "0) None or N/A"
read deviceChoice

# Change the URL to match where you are hosting your system .nix file
# Update the second command to the file name that matches your system .nix file

if [ $deviceChoice = 1 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/oryp6.nix > oryp6.nix; sudo mv -f oryp6.nix /mnt/etc/nixos/
   sudo sed -i "10 i \           ./oryp6.nix" /mnt/etc/nixos/configuration.nix 
else

if [ $deviceChoice = 2 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/hp-omen.nix > hp-omen.nix; sudo mv -f hp-omen.nix /mnt/etc/nixos/
   sudo sed -i "11 i \           ./hp-omen.nix" /mnt/etc/nixos/configuration.nix 
fi

fi

# Replace LUKS device with correct partition
sudo sed -i "s|/dev/disk/by-label/luks|$rootName|g" /mnt/etc/nixos/configuration.nix

# Install
sudo nixos-install
