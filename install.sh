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
echo -4G     # Set -4G as last sector.
echo n       # Create new partition (for root).
echo         # Set default partition number.
echo         # Set default first sector.
echo         # Set last sector.
echo t       # Change partition type.
echo 1       # Pick first partition.
echo 1       # Change first partition to EFI system.
echo t       # Change partition type.
echo 3       # Pick the last partition. 
echo 19      # Change last partition to Swap.
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

# Create EFI partition
sudo mkfs.fat -F32 -n EFI $efiName       

sudo mkswap $swapName      # swap partition
sudo mkfs.btrfs -L root $rootName  # /root partition

# Mount the filesystems.
sudo swapon $swapName
sudo mount $rootName /mnt

# Create Subvolumes
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home

# Unmount root
sudo umount /mnt

# Mount the subvolumes.
mount -o noatime,commit=120,compress=zstd:10,subvol=@ /dev/lvm/root /mnt
mkdir /mnt/home
mount -o noatime,commit=120,compress=zstd:10,subvol=@home /dev/lvm/root /mnt/home

# Mount the EFI partition.
mount --mkdir $efiName /mnt/boot/

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
echo "3) Pantheon"
echo "0) None or N/A"
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
echo "2) Galago Pro (galp3-b)"
echo "3) Galago Pro (galp4)"
echo "4) HP Omen (15-dh0015nr)"
echo "5) Pinebook Pro"
echo "0) None or N/A"
read deviceChoice

# Change the URL to match where you are hosting your system .nix file
# Update the second command to the file name that matches your system .nix file

if [ $deviceChoice = 1 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/oryp6.nix > oryp6.nix; sudo mv -f oryp6.nix /mnt/etc/nixos/
   sudo sed -i "11 i \           ./oryp6.nix" /mnt/etc/nixos/configuration.nix 
else

if [ $deviceChoice = 2 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/galp3-b.nix > galp3-b.nix; sudo mv -f galp3-b.nix /mnt/etc/nixos/
   sudo sed -i "11 i \           ./galp3-b.nix" /mnt/etc/nixos/configuration.nix 
fi

if [ $deviceChoice = 3 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/galp4.nix > galp4.nix; sudo mv -f galp4.nix /mnt/etc/nixos/
   sudo sed -i "11 i \           ./galp4.nix" /mnt/etc/nixos/configuration.nix 
fi

if [ $deviceChoice = 4 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/hp-omen.nix > hp-omen.nix; sudo mv -f hp-omen.nix /mnt/etc/nixos/
   sudo sed -i "11 i \           ./hp-omen.nix" /mnt/etc/nixos/configuration.nix 
fi

if [ $deviceChoice = 5 ]; then
   #curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/pinebook-pro.nix > configuration.nix; sudo mv -f configuration.nix /mnt/etc/nixos/
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/pbp.nix > pbp.nix; sudo mv -f pbp.nix /mnt/etc/nixos/
   sudo sed -i "11 i \           ./pbp.nix" /mnt/etc/nixos/configuration.nix 
fi

fi

# Install
sudo nixos-install
