{ config, pkgs, ... }:
{
  imports = [ ../modules ../hardware-configuration.nix ];

  my_cfg = {
    dev.enable = true;
    work.enable = true;
    syncthing.enable = true;

    graphical = {
      enable = true;
      wm_font_size = 20;
      terminal_font_size = 32;
    };

    battery_path = "/sys/class/power_supply/BAT0";

    ida = import ../secret/ida.nix {inherit pkgs;};
  };

  # Display switching
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "laptop" ''
      xrandr --output eDP-1 --mode 3840x2160 --output DP-1-1 --off --output DP-1-2 --off
    '')

    (pkgs.writeShellScriptBin "work-dock" ''
      xrandr --output eDP-1 --off --output DP-1-1 --mode 1920x1080 --left-of DP-1-2 --output DP-1-2 --mode 1920x1080
    '')

    (pkgs.writeShellScriptBin "tv" ''
      xrandr --output eDP-1 --mode 3840x2160 --output DP-3 --mode 3840x2160 --same-as eDP-1
    '')
  ];

  time.timeZone = "Europe/Stockholm";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  i18n.defaultLocale = "C.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };
  services.xserver.layout = "se";

  networking = {
    networkmanager.enable = true;
    hostName = "rs07";
  };

  # Wooo love myself some of this bs
  services.xserver.synaptics.enable = true;

  system.stateVersion = "21.11";
}

