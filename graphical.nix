{ config, pkgs, ... }:

{
  imports = [ ];

  environment.systemPackages = with pkgs; [
    firefox st dmenu tdesktop sublime4 xfce.ristretto
    evince gnome.nautilus mpv liferea yt-dlp pavucontrol
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
    dmenu = base.dmenu.overrideAttrs(old: {
      src = external/dmenu;
    });
    st = base.st.overrideAttrs(old: {
      src = external/st;
      makeFlags = old.makeFlags ++ ["FONT=mono:pixelsize=16"];
    });
  })];
}

