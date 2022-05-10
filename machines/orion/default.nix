# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules
    ];

  my_cfg = {
    dev.enable = true;
    syncthing.enable = true;
    remotely-accessible.enable = true;

    graphical = {
      enable = true;
      wm_font_size = 10;
      terminal_font_size = 32;
    };
  };

  boot.loader.grub.device = "/dev/md126";
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;

  networking.hostName = "orion";
  networking.hostId = "69696969"; # for zfs

  i18n.defaultLocale = "C.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };
  services.xserver.layout = "se";

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;

  hardware.video.hidpi.enable = true;

  system.stateVersion = "21.11";
}

