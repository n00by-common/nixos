{ config, pkgs, ... }:

{
  imports = [ ];

  environment.systemPackages = with pkgs; [
    firefox st dmenu
  ];

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

