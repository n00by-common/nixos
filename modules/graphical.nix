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
      pkgs.spotify-qt
      pkgs.tdesktop
      pkgs.xfce.ristretto
      pkgs.yt-dlp

      my_pkgs.discord
      my_pkgs.dmenu
      my_pkgs.sublime

      (pkgs.writeShellScriptBin "grab" ''
        ${pkgs.xfce.xfce4-screenshooter}/bin/xfce4-screenshooter -r -s ~/screenshots/$(date '+%F-%X').png
      '')

      (pkgs.writeShellScriptBin "scrot" ''
        ${pkgs.scrot}/bin/scrot -se 'mkdir -p ~/screenshots && mv $f ~/screenshots/' "$@"
      '')

      (pkgs.writeShellScriptBin "yt-launch" ''
        echo "$@" > /root/yt_log
        mpv "$@" >> /root/yt_log
      '')
    ];

    environment.sessionVariables = rec {
      "GTK_THEME" = "Adwaita:dark";
    };

    #services.pipewire = {
    #  enable = true;
    #  alsa.enable = true;
    #  alsa.support32Bit = true;
    #  pulse.enable = true;
    #  jack.enable = true;
    #};

    hardware.pulseaudio = {
      enable = true;
      systemWide = true;
      # Required for spotifyd
      extraConfig = ''
        unload-module module-native-protocol-unix
        load-module module-native-protocol-unix auth-anonymous=1
      '';
    };
    nixpkgs.config.pulseaudio = true;

    systemd.user.services.redshift = {
      description = "Redshift colour temperature adjuster";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.redshift}/bin/redshift -O 4000";
      };
    };

    networking.hosts = {
      "0.0.0.0" = ["apresolve.spotify.com"];
    };

    services.spotifyd = {
      enable = true;
      settings.global = let
        secret = import ../secret/spotify.nix;
      in {
        username = secret.username;
        password = secret.password;
        backend = "pulseaudio";
        bitrate = 320;

        device_name = "${config.networking.hostName}";
        device_type = "computer";
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
