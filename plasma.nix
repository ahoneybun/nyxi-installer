{ config, pkgs, ... }: 

{
    # Plasma
    services.xserver.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    # Install some packages
    environment.systemPackages = 
            with pkgs; 
            [
                libsForQt5.bismuth
                libsForQt5.kate
                libsForQt5.kde-gtk-config
                libsForQt5.plasma-nm
                libsForQt5.plasma-pa
                libsForQt5.sddm
            ];
}
