# The NixOS Installer

This installer does the following at it's core:

- Partition the drive of your choice
- Installs a base of NixOS
- Installs Plasma
- Installs needed packages

Tested on the following drives:
- SATA 
- M.2 NVMe

## Get Started

Prerequisites:

- Prepare an installation medium.
- Boot the live environment.
- Connect to internet.

## Connect to internet

https://nixos.org/manual/nixos/stable/index.html#sec-installation-booting-networking

## Start the installer

```
curl https://gitlab.com/ahoneybun/nixos-cli-installer/-/raw/nathaniel-btrfs/install.sh > install.sh; sh install.sh
```

The following will happen:

- Clear partition table for `/dev/***`.
- Creates a GPT partition table for `/dev/***`.
- Create a +512M EFI partiton at `/dev/***1`.
- Create a encrypted LVM at `/dev/***2`.
- Create a swap partition in the LVM with the choice to set it as the same size as the RAM.
- Create a root partition in the LVM.
- Install systemd-boot.

## After Installation ...

...

## Roadmap

- [ ]

# Possible Ideas

- [ ] 
