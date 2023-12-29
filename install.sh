# Figure out how much RAM the system has 
# then sets it as a variable for hibernation support
ramTotal=$(free -h | awk '/^Mem:/{print $2}'| awk -FG {'print$1'})

# Set append for drive automation
APPEND=""

# Detect and list the drives.
lsblk -f

# Choice the drive to use :
# 1. 
echo "----------"
echo ""
echo "Which drive do we want to use for this installation?"
read driveName

# List the new partitions.
lsblk -f

if [[ "$driveName" == "/dev/nvme"* || "$driveName" == "/dev/mmcblk0"* ]]; then
  APPEND="p"
fi

efiName=${driveName}$APPEND
efiName+=1
rootName=${driveName}$APPEND
rootName+=2
swapName=${driveName}$APPEND
swapName+=3

# Download Disko file
cd /tmp
curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/partitions/simple-efi.nix -o /tmp/disko-config.nix

# Replace drive in Disko file
#sudo sed -i "s#/dev/vdb#$rootName#g" /tmp/disko-config.nix

# Run Disko to partition the disk
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko-config.nix

# Generate Nix configuration
#sudo nixos-generate-config --root /mnt

sudo nixos-generate-config --no-filesystems --root /mnt
sudo mv /tmp/disko-config.nix /mnt/etc/nixos

# Copy my base nix configs over
# Change the URL to match where you are hosting your .nix file(s).

echo "Default username and password are in the configuration.nix file"
echo "Password is hashed so it is not plaintext"

#curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/configuration.nix > configuration.nix; sudo mv -f configuration.nix /mnt/etc/nixos/
#curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/programs.nix > programs.nix; sudo mv -f programs.nix /mnt/etc/nixos/

echo ""
echo "Which device are you installing to?"
echo "1) Home Desktop - Shepard"
echo "2) Galago Pro (galp3-b) - Garrus"
echo "3) HP Omen (15-dh0015nr)"
echo "4) Pinebook Pro - Jaal"
echo "5) Thelio NVIDIA (thelio-b1)"
echo "6) Darter Pro (darp9)"
echo "7) Virtual Machine"
echo "0) None or N/A"
read deviceChoice

# Change the URL to match where you are hosting your system .nix file
# Update the second command to the file name that matches your system .nix file

if [ $deviceChoice = 1 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/x86_64/shepard/configuration.nix > shepard.nix; sudo mv -f shepard.nix /mnt/etc/nixos/
   sudo sed -i "11 i \           ./shepard.nix" /mnt/etc/nixos/configuration.nix

elif [ $deviceChoice = 2 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/x86_64/garrus/configuration.nix > garrus.nix; sudo mv -f garrus.nix /mnt/etc/nixos/
   sudo sed -i "11 i \           ./garrus.nix" /mnt/etc/nixos/configuration.nix

elif [ $deviceChoice = 3 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/x86_64/hp-omen.nix > hp-omen.nix; sudo mv -f hp-omen.nix /mnt/etc/nixos/
   sudo sed -i "11 i \           ./hp-omen.nix" /mnt/etc/nixos/configuration.nix 

elif [ $deviceChoice = 4 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/aarch64/jaal/pbp.nix > jaal.nix; sudo mv -f jaal.nix /mnt/etc/nixos/
   sudo sed -i "11 i \           ./jaal.nix" /mnt/etc/nixos/configuration.nix 

elif [ $deviceChoice = 5 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/x86_64/thelio-nvidia.nix > thelio-nvidia.nix; sudo mv -f thelio-nvidia.nix /mnt/etc/nixos/
   sudo sed -i "11 i \           ./thelio-nvidia.nix" /mnt/etc/nixos/configuration.nix 
   # Disable latest kernel for Thelio with NVIDIA GPU
   sudo sed -i "s/boot.kernelPackages/# boot.kernelPackages/g" /mnt/etc/nixos/configuration.nix

elif [ $deviceChoice = 6 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/x86_64/darp9.nix > darp9.nix; sudo mv -f darp9.nix /mnt/etc/nixos/
   sudo sed -i "11 i \           ./darp9.nix" /mnt/etc/nixos/configuration.nix

elif [ $deviceChoice = 7 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/vm.nix > configuration.nix; sudo mv -f configuration.nix /mnt/etc/nixos/
   sed -i 's#disko#"${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"#'  /mnt/etc/nixos/configuration.nix
   sudo sed -i "12 i \           ./disko-config.nix" /mnt/etc/nixos/configuration.nix
   
   ./disko-config.nix
fi

echo ""
echo "Which Desktop Environment do you want?"
echo "1) Plasma"
echo "2) GNOME"
echo "3) Pantheon"
echo "4) Sway"
echo "0) None or N/A"
read desktopChoice

# Change the URL to match where you are hosting your DE/WM .nix file
# Update the second command to the file name that matches your DE/WM .nix file

if [ $desktopChoice = 1 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/desktops/plasma.nix > plasma.nix; sudo mv -f plasma.nix /mnt/etc/nixos/
   sudo sed -i "10 i \           ./plasma.nix" /mnt/etc/nixos/configuration.nix

elif [ $desktopChoice = 2 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/desktops/gnome.nix > gnome.nix; sudo mv -f gnome.nix /mnt/etc/nixos/
   sudo sed -i "10 i \           ./gnome.nix" /mnt/etc/nixos/configuration.nix

elif [ $desktopChoice = 3 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/desktops/pantheon.nix > pantheon.nix; sudo mv -f pantheon.nix /mnt/etc/nixos/
   sudo sed -i "10 i \           ./pantheon.nix" /mnt/etc/nixos/configuration.nix

elif [ $desktopChoice = 4 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/desktops/sway.nix > sway.nix; sudo mv -f sway.nix /mnt/etc/nixos/
   sudo sed -i "10 i \           ./sway.nix" /mnt/etc/nixos/configuration.nix

fi

# Replace LUKS device
#sudo sed -i "s#/dev/sda#$rootName#g" /mnt/etc/nixos/configuration.nix

# Install
sudo nixos-install
