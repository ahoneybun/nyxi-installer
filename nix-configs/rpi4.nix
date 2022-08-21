{ config, pkgs, lib, ... }:

let
  SSID = "Honeycutt-5G";
  SSIDpassword = "Frappe92";
  interface = "wlan0";
  hostname = "NixOS";
in {
  imports = ["${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/936e4649098d6a5e0762058cb7687be1b2d90550.tar.gz" }/raspberry-pi/4"];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
     hostName = "NixOS"; 
     networkmanager.enable = true;

    wireless = {
      enable = true;
      networks."${SSID}".psk = SSIDpassword;
      interfaces = [ interface ];
    };
  };

  # Set your time zone.
  time.timeZone = "America/Denver";

  environment.systemPackages = with pkgs; [ vim ];

  services.openssh.enable = true;

  # Define user accounts
    users.extraUsers.aaronh = {
            description = "Aaron Honeycutt";
            home = "/home/aaronh";
            extraGroups = [ "wheel" "networkmanager" "adm"];
            isNormalUser = true;
            hashedPassword = "$6$aAcbLtqiqzySifls$jdKMOQjoWITHD/dWNNZVUH/qNc6aoJ7v4zYofi0U7IJSVTbmOfChS3mzaJbp57AodjdPNKPrnrip8Nlh2Qanx.";
    };

  # Enable GPU acceleration
  hardware.raspberry-pi."4".fkms-3d.enable = true;

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
  };

  hardware.pulseaudio.enable = true;
}
