{ config, pkgs, ... }: 

{
    # Import other configuration modules
    # (hardware-configuration.nix is autogenerated upon installation)
    # paths in nix expressions are always relative the file which defines them
    imports =
        [
            ./hardware-configuration.nix
        ];

    boot.loader = {
       systemd-boot.enable = true;
    };

    boot.initrd.luks.devices.crypted.device = "/dev/vda2";
    fileSystems."/".device = "/dev/mapper/crypt-root";

    # Name your host machine
    networking.hostName = "NixOS-VM"; 

    # Set your time zone.
    time.timeZone = "America/Denver";

    # Enter keyboard layout
    services.xserver.layout = "us";

    # Define user accounts
    users.extraUsers = 
        { 
            aaronh = 
            {
                home = "/home/aaronh";
                extraGroups = [ "wheel" "networkmanager" ];
                isNormalUser = true;
            };
        };
    
    # Install some packages
    environment.systemPackages = 
            with pkgs; 
            [
                thunderbird
                firefox
                fish
            ]; 
 
    # Enable the OpenSSH daemon
    services.openssh.enable = true;
    
    # GNOME
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # System 
    system.autoUpgrade.enable = true;
    system.autoUpgrade.allowReboot = true;

}
