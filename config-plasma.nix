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

    boot.initrd.luks.devices = {
       crypt-root = {
          device = "/dev/disk/by-label/luks";
          preLVM = true;
       };
    };

    # Name your host machine
    networking.hostName = "NixOS-VM"; 

    networking.networkmanager.enable = true;

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
                tilix
            ]; 
 
    # Enable the OpenSSH daemon
    services.openssh.enable = true;
    
    # Plasma
    services.xserver.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    # System 
    system.autoUpgrade.enable = true;
    system.autoUpgrade.allowReboot = true;

}
