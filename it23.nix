{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./common.nix
      ./graphical.nix
      ./syncthing.nix
      ./purposes/dev.nix
    ];

  time.timeZone = "Europe/Stockholm";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.syncthing.folders.fs = {
    enable = true;
    path = "/root/fs";
  };

  networking = {
    useDHCP = false;
    networkmanager.enable = true;
    hostName = "it23-nixos";
    interfaces = {
      eno1.useDHCP = true;
      wlp2s0.useDHCP = true;
    };
  };

  # Wooo love myself some of this bs
  services.xserver.synaptics.enable = true;

  system.stateVersion = "21.11";
}

