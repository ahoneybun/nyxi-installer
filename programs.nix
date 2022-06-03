{ config, pkgs, ... }: 

{
   # virt-manager
   virtualisation.libvirtd.enable = true;

   # Packages
   environment.systemPackages = 
           with pkgs; 
              [
               discord
               slack
               virt-manager
              ];

}
