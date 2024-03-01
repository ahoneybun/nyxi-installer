# Figure out how much RAM the system has 
# then sets it as a variable for hibernation support
ramTotal=$(free -h | awk '/^Mem:/{print $2}'| awk -FG {'print$1'})

# Step 1: Choosing the drive for the installation

## Detect and list the drives.
lsblk -f

## Choice the drive to use :
echo "----------"
echo "Which drive do we want to use for this installation?"
echo "For example /dev/sda or /dev/nvme0n1"
read driveName

## Download Disko file
cd /tmp
curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/partitions/luks-btrfs-subvolumes.nix -o /tmp/disko-config.nix

## Replace drive in Disko file
sudo sed -i "s#/dev/sda#$driveName#g" /tmp/disko-config.nix

# Step 2: Partitioning the drive used for the installation

## Run Disko to partition the disk
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko-config.nix

## Generate Nix configuration
sudo nixos-generate-config --no-filesystems --root /mnt
sudo mv /tmp/disko-config.nix /mnt/etc/nixos

## Downloads and places the predefinded generic flake to use
curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/flake.nix > flake.nix; sudo mv -f flake.nix /mnt/etc/nixos/
curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/configuration.nix > configuration.nix; sudo mv -f configuration.nix /mnt/etc/nixos/
curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/home.nix > home.nix; sudo mv -f home.nix /mnt/etc/nixos/

# Step 3: Choosing a predefined system flake file to use

cat << EOF

Which device are you installing to?
   1) Virtual Machine
   2) Galago Pro 3b (Garrus)
   3) Pinebook Pro (Jaal)
   4) nebula49 (Shepard)
   5) Homelab (EDI)
   0) Generic
EOF
read hostChoice

if [ $hostChoice = 1 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/hosts/vm.nix > vm.nix; sudo mv -f vm.nix /mnt/etc/nixos/
   sudo nixos-install --flake /mnt/etc/nixos#vm

elif [ $hostChoice = 2 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/hosts/x86_64/garrus/configuration.nix > garrus.nix; sudo mv -f garrus.nix /mnt/etc/nixos/
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/desktops/gnome.nix > gnome.nix; sudo mv -f gnome.nix /mnt/etc/nixos/
   sudo nixos-install --flake /mnt/etc/nixos#garrus
   
elif [ $hostChoice = 3 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/hosts/aarch64/jaal/configuration.nix > jaal.nix; sudo mv -f jaal.nix /mnt/etc/nixos/
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/desktops/gnome.nix > gnome.nix; sudo mv -f gnome.nix /mnt/etc/nixos/
   sudo nixos-install --flake /mnt/etc/nixos#jaal

elif [ $hostChoice = 4 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/hosts/x86_64/shepard/configuration.nix > shepard.nix; sudo mv -f shepard.nix /mnt/etc/nixos/
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/desktops/gnome.nix > gnome.nix; sudo mv -f gnome.nix /mnt/etc/nixos/
   sudo nixos-install --flake /mnt/etc/nixos#shepard

elif [ $hostChoice = 5 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/hosts/x86_64/EDI/configuration.nix > edi.nix; sudo mv -f edi.nix /mnt/etc/nixos/
   sudo nixos-install --flake /mnt/etc/nixos#EDI

elif [ $hostChoice = 6 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/hosts/x86_64/macbook-intel.nix > shepard.nix; sudo mv -f shepard.nix /mnt/etc/nixos/
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/desktops/gnome.nix > gnome.nix; sudo mv -f gnome.nix /mnt/etc/nixos/
   sudo nixos-install --flake /mnt/etc/nixos#macbook

elif [ $hostChoice = 0 ]; then
   curl https://gitlab.com/ahoneybun/nix-configs/-/raw/main/flake.nix > flake.nix; sudo mv -f flake.nix /mnt/etc/nixos/
   sudo nixos-install --flake /mnt/etc/nixos#nixos

fi
