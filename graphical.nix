{ config, pkgs, ... }:

let
  my_pkgs = import ./packages {};

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
    st
    sublime4
    tdesktop
    xfce.ristretto
    yt-dlp

    my_pkgs.dmenu
    my_pkgs.dwmstatus
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
      defaultSession = "none+dwm";
    };
    windowManager.dwm.enable = true;
  };

  nixpkgs.overlays = [(self: base: {
    dwm = base.dwm.overrideAttrs(old: {
      src = external/dwm;
    });
    st = base.st.overrideAttrs(old: {
      src = external/st;
      makeFlags = old.makeFlags ++ ["FONT=mono:pixelsize=16"];
    });
  })];
}

