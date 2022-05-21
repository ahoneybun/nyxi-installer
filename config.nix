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

    # Allow Unfree
    nixpkgs.config.allowUnfree = true;

    # Enable 32 Bit libraries for applications like Steam
    hardware.opengl.driSupport32Bit = true;

    # Name your host machine
    networking.hostName = "NixOS"; 
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "America/Denver";

    # Enter keyboard layout
    services.xserver.layout = "us";

    # Enable Flatpak
    xdg = {
       portal = {
          enable = true;
          extraPortals = with pkgs; [
             xdg-desktop-portal-wlr
             xdg-desktop-portal-kde
          ];
        };
    };

    services.flatpak.enable = true;

    # Enable fwupd
    services.fwupd.enable = true;

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
                firefox
                fish
                flatpak
                git
                libsForQt5.bismuth
                libsForQt5.kde-gtk-config
                libsForQt5.plasma-nm
                libsForQt5.plasma-pa
                libsForQt5.sddm
                steam
                thunderbird
            ]; 
 
    # Enable the OpenSSH daemon
    services.openssh.enable = true;
    
    # Plasma
    services.xserver.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    # Enable Pipewire
    security.rtkit.enable = true;
    services.pipewire = {
       enable = true;
       alsa.enable = true;
       alsa.support32Bit = true;
       pulse.enable = true;
    };

    # Enable Bluetooth
    hardware.bluetooth.enable = true;

    # Enable CUPS
    services.printing.enable = true;

    # System 
    system.autoUpgrade.enable = true;
    system.autoUpgrade.allowReboot = true;

}
