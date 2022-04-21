{ config, pkgs, lib, my_pkgs, ... }:
{
  options.my_cfg.graphical = {
    enable = lib.mkEnableOption "Bloat that uses the mouse n shiet";
    wm_font_size = lib.mkOption { type = lib.types.int; };
    terminal_font_size = lib.mkOption { type = lib.types.int; };
  };

  config = lib.mkIf config.my_cfg.graphical.enable {
    environment.systemPackages = [
      pkgs.evince
      pkgs.firefox
      pkgs.gnome.nautilus
      pkgs.keepassxc
      pkgs.liferea
      pkgs.mpv
      pkgs.pavucontrol
      pkgs.sublime4
      pkgs.tdesktop
      pkgs.xfce.ristretto
      pkgs.yt-dlp

      my_pkgs.discord
      my_pkgs.dmenu
    ];

    environment.sessionVariables = rec {
      "GTK_THEME" = "Adwaita:dark";
    };

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    systemd.user.services.redshift = {
      description = "Redshift colour temperature adjuster";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.redshift}/bin/redshift -O 4000";
      };
    };

    services.xserver = {
      enable = true;
      displayManager = {
        gdm.enable = true;
        defaultSession = "none+dwmwithstatus";
      };
      windowManager.session =
        [{ name = "dwmwithstatus";
          start = ''
            ${my_pkgs.dwmstatus}/bin/dwmstatus &
            ${my_pkgs.dwm}/bin/dwm &
            waitPID=$!
          '';
        }];
    };
  };
}
