{ config, pkgs, lib, my_pkgs, ... }:
{
  options.my_cfg.work.enable = lib.mkEnableOption "Treat as a work PC";

  config = lib.mkIf config.my_cfg.work.enable {
    # We need to be graphical for some of these
    my_cfg.graphical.enable = true;

    # Packages
    environment.systemPackages = [
      # for thunderbolt dock
      pkgs.thunderbolt pkgs.bolt

      # for locking computer from colleagues
      pkgs.slock

      pkgs.sqlitebrowser

      # for organizing lunch
      my_pkgs.teams

      my_pkgs.ida
      my_pkgs.ida64
      my_pkgs.pida
      my_pkgs.pida64
      (pkgs.writeShellScriptBin "ghidra" ''
        AWT_TOOLKIT=MToolkit ${pkgs.ghidra-bin}/bin/ghidra
      '')
      pkgs.cutter
      pkgs.radare2
    ];

    virtualisation.virtualbox.host.enable = true;
  };
}
