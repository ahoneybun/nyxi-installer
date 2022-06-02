{ config, pkgs, ... }: 

{
   # virt-manager
   virtualisation.libvirtd.enable = true;

   # Packages
   environment.systemPackages = 
           with pkgs; 
              [
               virt-manager
              ];

}
