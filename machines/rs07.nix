{ config, pkgs, ... }:

{
  imports =
    [
      ../hardware-configuration.nix
      ../purposes/common.nix
      ../purposes/dev.nix
      ../purposes/graphical.nix
      ../purposes/syncthing.nix
    ];

  time.timeZone = "Europe/Stockholm";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.syncthing.folders.fs = {
    enable = true;
    path = "/root/fs";
  };

  i18n.defaultLocale = "C.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };
  services.xserver.layout = "se";

  networking = {
    useDHCP = false;
    networkmanager.enable = true;
    hostName = "rs07-nixos";
    interfaces = {
      wlp0s20f3.useDHCP = true;
    };
  };

  # Wooo love myself some of this bs
  services.xserver.synaptics.enable = true;

  system.stateVersion = "21.11";
}

