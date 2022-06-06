# The NixOS Installer

This installer is named after my doggo Onyxia.

At the core of this installer it does the following:

- Partition the drive of your choice
- Installs a base of NixOS
- Installs Plasma
- Installs needed packages

Files:

- `configuration.nix` : This is the main file for the base system including some applications that I use
- `plasma.nix` : This file is for the desktop, login manager and other KDE applications

Tested on the following drives:
- SATA 
- NVMe

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

https://nixos.org/manual/nixos/stable/index.html#sec-installation-booting-networking

## Start the installer

```
curl https://gitlab.com/ahoneybun/nixos-cli-installer/-/raw/main/install.sh > install.sh; sh install.sh
```

The following will happen:

- Clear partition table for `/dev/***`.
- Creates a GPT partition table for `/dev/***`.
- Create a +512M EFI partiton at `/dev/***1`.
- Create a encrypted LVM at `/dev/***2`.
- Create a swap partition in the LVM and sets it as the same size as the RAM for hibernation if requested.
- Create a root partition in the LVM.
- Install systemd-boot.

## After Installation ...

...

## Roadmap

- [ ]

# Possible Ideas

- [ ] 
