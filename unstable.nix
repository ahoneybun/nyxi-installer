{ config, pkgs, ...}:

let
  unstable = import
    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/master)
    # reuse the current configuration
    { config = config.nixpkgs.config; };
in
{
  environment.systemPackages = with pkgs; [
    unstable.protonvpn-cli
    unstable.protonvpn-gui
  ];
}
