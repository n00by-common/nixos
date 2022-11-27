{ config, pkgs, lib, my_pkgs, ... }:
{
  imports = [ ];

  options.my_cfg.dev.enable = lib.mkEnableOption "Development enviroment";

  config = lib.mkIf config.my_cfg.dev.enable {
    # Packages
    environment.systemPackages = [
      pkgs.clang_12
      pkgs.gdb
      pkgs.gnumake
      pkgs.man-pages
      pkgs.man-pages-posix
      pkgs.qemu_full
      pkgs.xorriso
      pkgs.radare2
      pkgs.sublime-merge
      pkgs.cutter
      pkgs.llvmPackages_14.bintools
      (pkgs.python3.withPackages (python-packages: with python-packages; [
        pyserial
        pwntools
        tqdm
        xmodem
      ]))

      my_pkgs.zig

      (pkgs.writeShellScriptBin "zig-master" ''
        ${my_pkgs.zig-master}/bin/zig "$@"
      '')

      (pkgs.writeShellScriptBin "zig-soft-float" ''
        ${(pkgs.zig.override({
          llvmPackages = pkgs.llvmPackages_13;
        })).overrideAttrs(old: {
          src = pkgs.fetchFromGitHub {
            owner = "czapek1337";
            repo = "zig";
            rev = "914c034f025116e1db86598556ae2c37c96b21f6";
            sha256 = "1wqczzcymzcazz9fniqca83awldavyzqjh70x4s4n9l7jrhjd4l8";
          };
        })}/bin/zig "$@"
      '')
    ];

    programs.git = {
      enable = true;
      config = {
        init.defaultBranch = "master";
        http.cookieFile = "~/git_cookies.txt";
        core.editor = "${pkgs.vim}/bin/vim";
        merge.conflictstyle = "diff3";
        pull.rebase = "true";
        fetch.prune = "true";
        rebase.autostash = "true";

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
