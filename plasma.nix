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
                libsForQt5.ark
                libsForQt5.bismuth
                libsForQt5.full
                libsForQt5.kalendar
                libsForQt5.kate
                libsForQt5.kdeconnect-kde
                libsForQt5.kde-gtk-config
                libsForQt5.plasma-framework
                libsForQt5.plasma-nm
                libsForQt5.plasma-pa
                libsForQt5.sddm
            ];
}
