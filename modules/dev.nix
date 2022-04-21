{ config, pkgs, lib, my_pkgs, ... }:
{
  imports = [ ];

  options.my_cfg.dev.enable = lib.mkEnableOption "Development enviroment";

  config = lib.mkIf config.my_cfg.dev.enable {
    # Packages
    environment.systemPackages = [
      pkgs.clang
      pkgs.gnumake
      pkgs.man-pages
      pkgs.man-pages-posix
      pkgs.pwntools
      pkgs.qemu_full
      pkgs.xorriso

      my_pkgs.zig
    ];

    programs.git = {
      enable = true;
      config = {
        init.defaultBranch = "master";
        http.cookieFile = "~/git_cookies.txt";
        user = {
          name = "Hannes Bredberg";
          email = "hannesbredberg@gmail.com";
        };
      };
    };

    documentation.dev.enable = true;

    # zsh + oh-my-zsh config
    programs.zsh = {
      shellAliases = {
        gap = "git add -p";
        gs = "git status";
      };
    };
  };
}
