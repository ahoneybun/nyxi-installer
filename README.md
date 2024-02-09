# The NixOS Installer

This installer is named after my doggo Onyxia.

At the core of this installer it does the following:

- Partition the drive of your choice using Disko
- Uses `flake.nix` to set certain modules depending on the system like nixos-hardware for the Pinebook Pro
  - Uses home-manager to manage settings for GNOME (current desktop) and other applications for my user
- Installs a base of NixOS (`configuration.nix`)

nix files are from [this repo](https://gitlab.com/ahoneybun/nix-configs/) but that can be changed as needed.

Tested on the following drives:
- SATA 
- NVMe

Tested on the following architectures:
- x86_64 

This sets the hashedPassword to my own so you will need to update it to match your own as well as the username. I created the hash with this command:

```bash
mkpasswd -m sha-512
```
