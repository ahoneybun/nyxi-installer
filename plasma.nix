{ config, pkgs, ... }: 

{
     # Allow Unfree
    nixpkgs.config.allowUnfree = true;

    # Enable 32 Bit libraries for applications like Steam
    hardware.opengl.driSupport32Bit = true;

    # Plasma
    services.xserver.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    # Install some packages
    environment.systemPackages = 
            with pkgs; 
            [
                libsForQt5.bismuth
                libsForQt5.kde-gtk-config
                libsForQt5.plasma-nm
                libsForQt5.plasma-pa
                libsForQt5.sddm
            ];
}
