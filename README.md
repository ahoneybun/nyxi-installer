# The NixOS Installer

This installer does the following at it's core:

- Partition the drive of your choice
- Encrypts the installation
- Installs a base of NixOS

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
curl https://gitlab.com/ahoneybun/arch-itect/-/raw/nix-os-/install.sh > install.sh; sh install.sh
```

The following will happen:

- Clear partition table for `/dev/***`.
- Creates a GPT partition table for `/dev/***`.
- Create a +512M EFI partiton at `/dev/***1`.
- Create a root partition at `/dev/***2`.
- Create a swap partition at `/dev/***3` with the choice to set it as the same size as the RAM.
- Install systemd-boot.

## After Installation ...

...

## Roadmap

- [ ] 
- [ ]

# Possible Ideas

- [ ] 
