# Figure out how much RAM the system has 
# then sets it as a variable for hibernation support
ramTotal=$(free -h | awk '/^Mem:/{print $2}'| awk -FG {'print$1'})

# Detect and list the drives.
lsblk -f

# Step 1: Choosing the drive for the installation

# Choice the drive to use :
echo "----------"
echo "Which drive do we want to use for this installation?"
read driveName

# Download Disko file
cd /tmp
curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/partitions/luks-btrfs-subvolumes.nix -o /tmp/disko-config.nix

# Replace drive in Disko file
sudo sed -i "s#/dev/sda#$driveName#g" /tmp/disko-config.nix

# Step 2: Partitioning the drive used for the installation

# Run Disko to partition the disk
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko-config.nix

# Generate Nix configuration
sudo nixos-generate-config --no-filesystems --root /mnt
sudo mv /tmp/disko-config.nix /mnt/etc/nixos

# Downloads and places the predefinded generic flake to use
curl https://gitlab.com/ahoneybun/nix-configs/-/raw/flake/flake.nix > flake.nix; sudo mv -f flake.nix /mnt/etc/nixos/
curl https://gitlab.com/ahoneybun/nix-configs/-/raw/flake/home.nix > home.nix; sudo mv -f home.nix /mnt/etc/nixos/

# Step 3: Choosing a predefined system flake file to use

cat << EOF

Which device are you installing to?
   1) Home Desktop - Shepard
   2) Galago Pro (galp3-b) - Garrus
   3) HP Omen (15-dh0015nr)
   4) Pinebook Pro - Jaal
   5) Thelio NVIDIA (thelio-b1)
   6) Darter Pro (darp9)
   7) Virtual Machine
   8) HP Dev One
   0) Generic
EOF
read deviceChoice

if [ $deviceChoice = 1 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/x86_64/shepard/configuration.nix > shepard.nix; sudo mv -f shepard.nix /mnt/etc/nixos
   sudo sed -i "11 i \           ./shepard.nix" /mnt/etc/nixos/configuration.nix

elif [ $deviceChoice = 2 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/x86_64/garrus/configuration.nix > garrus.nix; sudo mv -f garrus.nix /mnt/etc/nixos
   sudo sed -i "11 i \           ./garrus.nix" /mnt/etc/nixos/configuration.nix

elif [ $deviceChoice = 3 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/x86_64/hp-omen/configuration.nix > hp-omen.nix; sudo mv -f hp-omen.nix /mnt/etc/nixos
   sudo sed -i "11 i \           ./hp-omen.nix" /mnt/etc/nixos/configuration.nix 

elif [ $deviceChoice = 4 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/aarch64/jaal/pbp.nix > jaal.nix; sudo mv -f jaal.nix /mnt/etc/nixos/
   sudo sed -i "11 i \           ./jaal.nix" /mnt/etc/nixos/configuration.nix 

elif [ $deviceChoice = 5 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/x86_64/thelio-nvidia.nix > thelio-nvidia.nix; sudo mv -f thelio-nvidia.nix /mnt/etc/nixos
   sudo sed -i "11 i \           ./thelio-nvidia.nix" /mnt/etc/nixos/configuration.nix 

elif [ $deviceChoice = 6 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/systems/x86_64/darp9.nix > darp9.nix; sudo mv -f darp9.nix /mnt/etc/nixos/
   sudo sed -i "11 i \           ./darp9.nix" /mnt/etc/nixos/configuration.nix

elif [ $deviceChoice = 7 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/flake/systems/flake.nix > flake.nix; sudo mv -f flake.nix /mnt/etc/nixos/
   sudo nixos-install --flake /mnt/etc/nixos#nixos

elif [ $deviceChoice = 8 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/flake/systems/flake.nix > flake.nix; sudo mv -f flake.nix /mnt/etc/nixos/
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/desktops/gnome.nix > gnome.nix; sudo mv -f gnome.nix /mnt/etc/nixos/
   sudo nixos-install --flake /mnt/etc/nixos#dev-one

elif [ $deviceChoice = 0 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/flake/flake.nix > flake.nix; sudo mv -f flake.nix /mnt/etc/nixos/

   fi
