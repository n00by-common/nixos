# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  display-setup = ''
    LEFT='DP-0'
    CENTER='DP-2'
    RIGHT='HDMI-0'
    ${pkgs.xorg.xrandr}/bin/xrandr --output $CENTER --primary --output $LEFT --left-of $CENTER --output $RIGHT --right-of $CENTER
  '';
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules
    ];

  my_cfg = {
    dev.enable = true;
    syncthing.enable = true;
    remotely-accessible.enable = true;
    gamering.enable = true;

    graphical = {
      enable = true;
      wm_font_size = 10;
      terminal_font_size = 32;
    };

    ida = import ../../secret/ida.nix {inherit pkgs;};
    pida = import ../../secret/pida.nix {inherit pkgs;};
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.firewall.allowedTCPPorts = [80 443];
  services.nginx = {
    enable = true;
    virtualHosts."gurrasnurra.se" = {
      enableACME = true;
      forceSSL = true;
      root = "/zpool/gurrasnurra/public_html";
    };
  };

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

  services.xserver.displayManager.setupCommands = display-setup;
  services.xserver.displayManager.sessionCommands = display-setup;
}

