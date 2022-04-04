{ config, pkgs, ... }:

let
  my_pkgs = import ./packages {};
  nixpkgs = import <nixpkgs> {};
in {
  environment.systemPackages = with pkgs; [
    discord
    evince
    firefox
    gnome.nautilus
    keepassxc
    liferea
    mpv
    pavucontrol
    sublime4
    tdesktop
    xfce.ristretto
    yt-dlp

    my_pkgs.dmenu
    my_pkgs.dwm
    my_pkgs.dwmstatus
    my_pkgs.st
  ];

  environment.sessionVariables = rec {
    "GTK_THEME" = "Adwaita:dark";
  };

  nixpkgs.config.pulseaudio = true;
  hardware.pulseaudio.enable = true;

  services.xserver = {
    enable = true;
    displayManager = {
      gdm.enable = true;
      defaultSession = "none+dwmwithstatus";
    };
    windowManager.session =
      [{ name = "dwmwithstatus";
        start =
          ''
            ${my_pkgs.dwmstatus}/bin/dwmstatus &
            ${my_pkgs.dwm}/bin/dwm &
            waitPID=$!
          '';
      }];
  };
}
