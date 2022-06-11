{ config, pkgs, ... }: 

{
   # virt-manager
   virtualisation.libvirtd.enable = true;

   # Packages
   environment.systemPackages = 
           with pkgs; 
              [
               discord
               libreoffice-fresh
               slack
               virt-manager
              ];

   programs.fish.enable = true;

   users.users.aaronh = {   
      shell = pkgs.fish;
  };
}
