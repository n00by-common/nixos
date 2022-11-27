{ config, pkgs, lib, my_pkgs, ... }:
let
  default_wine = (pkgs.wineWowPackages.full.override {
    wineRelease = "staging";
    mingwSupport = true;
  });
  wp = arch: prefix: wine: name: default_cmd: [
    (pkgs.writeShellScriptBin name ''
      export WINEARCH=${arch}
      export WINEPREFIX=${prefix}
      ${wine}/bin/wine cmd /c ${default_cmd}
    '')
    (pkgs.writeShellScriptBin "${name}-custom" ''
      export WINEARCH=${arch}
      export WINEPREFIX=${prefix}
      "$@"
    '')
  ];
in
{
  options.my_cfg.gamering = {
    enable = lib.mkEnableOption "Yooo";
  };

  config = lib.mkIf config.my_cfg.gamering.enable {
    environment.systemPackages = [
      # TODO: Dark mode by default
      (pkgs.polymc.override {
        msaClientID = import ../secret/multimc-client-secret.nix;
      })
      (pkgs.wineWowPackages.full.override {
        wineRelease = "staging";
        mingwSupport = true;
      })
      default_wine
      pkgs.winetricks
    ]
    ++ wp "win64" "/battle.net" default_wine "bnet" "C:\\\\users\\\\Public\\\\Desktop\\\\Battle.net.lnk"
    ;

    # This is hardcoded to use nixpkgs.steam and nixpkgs.steamPackages.steam, so that's why
    # we need the overlay below.
    programs.steam.enable = true;

    nixpkgs.overlays = [(final: prev: {
      steamPackages = prev.steamPackages // {
        steam = prev.steamPackages.steam.overrideAttrs(old: rec {
          patches = (old.patches or []) ++ [ ../patches/steam/steam-as-root.patch ];
        });
      };
    })];
  };
}
