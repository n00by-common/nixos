 { config, pkgs, ... }:

let
  my_pkgs = import ../packages {};

in {
  imports = [ ];

  # Packages
  environment.systemPackages = with pkgs; [
    clang
    git
    gnumake
    pwntools
    qemu_full
    xorriso

    my_pkgs.zig
  ];

  # zsh + oh-my-zsh config
  programs.zsh = {
    shellAliases = {
      gap = "git add -p";
      gs = "git status";
    };
  };
}
