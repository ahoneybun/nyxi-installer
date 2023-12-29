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

# Download Disko file
cd /tmp
curl https://gitlab.com/ahoneybun/nix-configs/-/raw/disko/partitions/luks-btrfs-subvolumes.nix -o /tmp/disko-config.nix

# Replace drive in Disko file
sudo sed -i "s#/dev/sda#$driveName#g" /tmp/disko-config.nix

# Run Disko to partition the disk
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko-config.nix

# Generate Nix configuration
sudo nixos-generate-config --no-filesystems --root /mnt
sudo mv /tmp/disko-config.nix /mnt/etc/nixos

# Copy my base nix configs over
# Change the URL to match where you are hosting your .nix file(s).

echo "Default username and password are in the configuration.nix file"
echo "Password is hashed so it is not plaintext"

curl https://gitlab.com/ahoneybun/nix-configs/-/raw/disko/configuration.nix > configuration.nix; sudo mv -f configuration.nix /mnt/etc/nixos/
#curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/programs.nix > programs.nix; sudo mv -f programs.nix /mnt/etc/nixos/

cat << EOF

Which device are you installing to?
   1) Home Desktop - Shepard
   2) Galago Pro (galp3-b) - Garrus
   3) HP Omen (15-dh0015nr)
   4) Pinebook Pro - Jaal
   5) Thelio NVIDIA (thelio-b1)
   6) Darter Pro (darp9)
   7) Virtual Machine
   0) None or N/A
EOF
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
   sudo sed -i 's#disko#"${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"#'  /mnt/etc/nixos/configuration.nix
   sudo sed -i "10 i \           ./disko-config.nix" /mnt/etc/nixos/configuration.nix
   sudo sed -i "11 i \           ./thelio-nvidia.nix" /mnt/etc/nixos/configuration.nix 
   # Disable latest kernel for Thelio with NVIDIA GPU
   sudo sed -i "s/boot.kernelPackages/# boot.kernelPackages/g" /mnt/etc/nixos/configuration.nix

elif [ $deviceChoice = 6 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/x86_64/darp9.nix > darp9.nix; sudo mv -f darp9.nix /mnt/etc/nixos/
   sudo sed -i "11 i \           ./darp9.nix" /mnt/etc/nixos/configuration.nix

elif [ $deviceChoice = 7 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/disko/systems/vm.nix > configuration.nix; sudo mv -f configuration.nix /mnt/etc/nixos/
   sudo sed -i 's#disko#"${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"#'  /mnt/etc/nixos/configuration.nix
   sudo sed -i "10 i \           ./disko-config.nix" /mnt/etc/nixos/configuration.nix
   fi

cat << EOF

Which Desktop Environment do you want?
   1) Plasma
   2) GNOME
   3) Pantheon
   4) Sway
   0) None or N/A
EOF
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
