{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot = {
    blacklistedKernelModules = [ "snd_pcsp" ];
    kernelPackages = pkgs.linuxPackages_latest;
    cleanTmpDir = true;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    supportedFilesystems = [
      "exfat"
    ];
  };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
    hostName = "aya";
    networkmanager.enable = true;

  };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };
  
  # nVidia driver
  hardware.opengl.driSupport32Bit = true;
  hardware.bluetooth.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  services = {

    openssh.enable = true;

    ntp.enable = true;
    nscd.enable = true;

    xserver = {
      videoDrivers = [ "nvidia" ];
      enable = true;
      layout = "us";

      xkbOptions = "compose:caps";
      xkbVariant = "dvp";

      synaptics.enable = true;

      windowManager.xmonad.enable = true;
      windowManager.xmonad.extraPackages = self: [ self.xmonad-contrib ];
      windowManager.xmonad.haskellPackages = pkgs.haskell.packages.ghc822;
      displayManager.defaultSession = "none+xmonad";

      displayManager.lightdm = {
        enable = true;
        extraSeatDefaults = ''
          greeter-show-manual-login=true
          greeter-hide-users=true
          allow-guest=false
        '';
      };

      displayManager.sessionCommands = ''
        ${pkgs.xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr
        ${pkgs.xscreensaver}/bin/xscreensaver -no-splash &
      '';
    };
  };

  users.extraGroups.vboxusers.members = [ "shana" ];

  programs.ssh.startAgent = true;
  programs.bash.enableCompletion = true;

  # Don't blind me
  systemd.services.redshift.restartIfChanged = false;

  time.timeZone = "America/Denver";

  # Users
  users.users.aaronh = {
    createHome = true;
    home = "/home/aaronh";
    description = "Aaron Honeycutt";
    extraGroups = [ "wheel" "audio" "video" "networkmanager" "docker" ];
    useDefaultShell = true;
    isNormalUser = true;
  };

  nixpkgs.system = "x86_64-linux";
  nixpkgs.config = {
    virtualbox.enableExtensionPack = true;
    pulseaudio = true;
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs;
    [ cacert
      cloc
      elfutils
      file
      firefox-devedition-bin
      fish
      git
      glib
      glxinfo
      gnupg
      gnutls
      # haskellPackages.apply-refact
      # haskellPackages.hasktags
      # haskellPackages.hlint
      htop
      jq
      mpv
      mupdf
      nano
      networkmanager
      nitrogen
      nmap
      openssl
      p7zip
      pavucontrol
      # pythonPackages.youtube-dl
      # rtorrent
      rxvt_unicode
      scrot
      sxiv
      unzip
      wget
      xlibs.xsetroot
      xscreensaver
      xsel
      zip
    ];

  fonts = {
    fontconfig.enable = true;
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      dejavu_fonts
      inconsolata
      source-han-sans-japanese
      source-han-sans-korean
      source-han-sans-simplified-chinese
      source-han-sans-traditional-chinese
      ubuntu_font_family
    ];
  };

  security.sudo.enable = true;

  nix = {
    package = pkgs.nixUnstable;
    trustedBinaryCaches = [
      "http://cache.nixos.org"
    ];

    binaryCaches = [
      "http://cache.nixos.org"
    ];

    gc.automatic = false;
    maxJobs = pkgs.lib.mkForce 6;
  };
}
