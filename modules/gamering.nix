{ config, pkgs, lib, my_pkgs, ... }:
{
  options.my_cfg.gamering = {
    enable = lib.mkEnableOption "Yooo";
  };

  config = lib.mkIf config.my_cfg.gamering.enable {
    environment.systemPackages = [
      # TODO: Dark mode by default
      pkgs.multimc

      my_pkgs.lutris
    ];

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
