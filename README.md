# The NixOS Installer

This installer is named after my doggo Onyxia.

At the core of this installer it does the following:

- Partition the drive of your choice
- Installs a base of NixOS (`configuration.nix`)
- Installs a DE/WM of your choice (currently supporting GNOME and Plasma)
- Installs needed packages (`programs.nix`)
- Installs needed packages for certain hardware 

nix files are from [this repo](https://gitlab.com/ahoneybun/nix-configs/) but that can be changed as needed.

Tested on the following drives:
- SATA 
- NVMe
- eMMC

Tested on the following architectures:
- x86_64 
- aarch64 

This sets the hashedPassword to my own so you will need to update it to match your own as well as the username. I created the hash with this command:

```
sudo mkpasswd -m sha-512
```

## Get Started

Prerequisites:

- Prepare an installation medium.
- Boot the live environment.
- Connect to internet.

## Connect to internet

```sh
> add_network
0
> set_network 0 ssid "myhomenetwork"
OK
> set_network 0 psk "mypassword"
OK
> set_network 0 key_mgmt WPA-PSK
OK
> enable_network 0
OK
```

https://nixos.org/manual/nixos/stable/index.html#sec-installation-booting-networking

## Start the installer

```sh
sh <(curl -L https://gitlab.com/ahoneybun/nyxi-installer/-/raw/main/install.sh)
```

The following will happen:

### x86_64 - main branch

- Clear partition table for `/dev/***`.
- Creates a GPT partition table for `/dev/***`.
- Creates a 1GB EFI partiton at `/dev/***1`.
- Creates a encrypted LVM at `/dev/***2`.
- Creates a swap partition in the LVM and sets it as the same size as the RAM for hibernation if requested.
- Creates a root partition in the LVM.
- Installs systemd-boot

### ARM64 (Pinebook Pro) - main-pbp branch

- Clear partition table for `/dev/***`. 
- Creates a GPT partition table for `/dev/***`.
- Creates a 1GB EFI partiton at `/dev/***1`.
- Creates a 4GB Swap partition at `/dev/***3`.
- Creates a root partition with the rest of the space at `/dev/***2`.
- Installs GRUB

## Roadmap

- [ ] Merge ARM64 and x86_64 together into one branch

# Possible Ideas

- [ ] Install nix-channels such as `nixos-hardware` and `home-manager` after install.
