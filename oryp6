{ config, pkgs, ... }: 

{
    # NVIDIA
    services.xserver.videoDrivers = [ "nvidia" ];   
    hardware.opengl.enable = true;
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Allow Unfree
    nixpkgs.config.allowUnfree = true;
}
