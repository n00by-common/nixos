{ config, pkgs, lib, ... }:
let
  my_pkgs = import ../packages {inherit pkgs config;};
in
{
  imports = [
    ./dev.nix
    ./gamering.nix
    ./graphical.nix
    ./remotely-accessible.nix
    ./syncthing.nix
    ./work-shit.nix
  ];

  options.my_cfg = {
    everything_as_root = lib.mkOption {
      description = ''
        Set up everything that can to be run as root.
        Should not be changed once a system has been installed
      '';

      default = true;

      type = lib.types.bool;

      visible = true;
    };

    is_laptop = lib.mkEnableOption "";

    battery_path = lib.mkOption {
      description = "Path to the battery";

      default = null;
      defaultText = "Don't show battery status";

      type = lib.types.nullOr lib.types.str;

      visible = true;

      example = [
        "/sys/class/power_supply/BAT0"
        "/sys/class/power_supply/BAT1"
      ];
    };

    time_format = lib.mkOption {
      description = "Format string for time, same format as strftime()";

      default = null;
      defaultText = "Use the default time format string";

      type = lib.types.nullOr lib.types.str;

      visible = true;

      example = [
        "Week %V, %a %d %b %H:%M:%S %Y"
        "%H:%M:%S %Y"
      ];
    };

    ida =
      let
        secret = import ../secret/ida.nix {inherit pkgs;};
      in {
      enable = lib.mkEnableOption "Ida Pro";

      installer = lib.mkOption {
        description = "Installer file";
        default = secret.installer;

        type = lib.types.path;

        visible = true;
      };

      password = lib.mkOption {
        description = "Installer password";
        default = secret.password;

        type = lib.types.str;
        visible = true;
      };
    };

    pida = {
      enable = lib.mkEnableOption "Ida Pro";

      installer = lib.mkOption {
        description = "Installer file";
        default = null;

        type = lib.types.path;

        visible = true;
      };

      password = lib.mkOption {
        description = "Installer password";
        default = null;

        type = lib.types.str;
        visible = true;
      };
    };
  };

  config = {
    boot.kernel.sysctl = {
      "kernel.pid_max" = 4096;
    };
    # Args passed to all modules
    _module.args = {
      my_pkgs = my_pkgs;
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "hannesbredberg@gmail.com";
    };

    # Packages
    environment.systemPackages = [
      pkgs.binutils
      pkgs.htop
      pkgs.most
      pkgs.neofetch
      pkgs.oh-my-zsh
      pkgs.p7zip
      pkgs.ripgrep
      pkgs.unzip
      pkgs.wget
      pkgs.xxd

      my_pkgs.https-to-ssh
      my_pkgs.killall
      my_pkgs.transfer
      my_pkgs.vim
      my_pkgs.git-pretty-log

      my_pkgs.nix-index
      my_pkgs.nix-locate
    ]
    ++ (if config.my_cfg.ida.enable then [my_pkgs.ida my_pkgs.ida64] else [])
    ++ (if config.my_cfg.pida.enable then [my_pkgs.pida my_pkgs.pida64] else [])
    ;

    nixpkgs.config.allowUnfree = true;

    # Make a root user with no password and zsh as default shell
    users = {
      defaultUserShell = pkgs.zsh;
      mutableUsers = true;
      extraUsers.root = {
        hashedPassword = "";
        openssh.authorizedKeys.keyFiles = [
          ../pubkeys/orion
          ../pubkeys/it23
          ../pubkeys/rs07
          ../pubkeys/it34
        ];
      };
    };

    # zsh + oh-my-zsh config
    programs.zsh = {
      enable = true;
      shellAliases = {
        ll = "ls -lha";
        switch = "NIXOS_CONFIG=/etc/nixos/machines/${config.networking.hostName} nixos-rebuild switch";
      };
      ohMyZsh = {
        enable = true;
        plugins = ["git"];
        theme = "agnoster";
      };
    };
  };
}
