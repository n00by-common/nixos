 { config, pkgs, ... }:

let
  my_pkgs = import ./packages {};

in {
  imports = [ ];

  # Packages
  environment.systemPackages = with pkgs; [
    git
    htop
    most
    neofetch
    nix-index
    oh-my-zsh
    pwntools
    ripgrep

    my_pkgs.killall
    my_pkgs.transfer
    my_pkgs.vim
    my_pkgs.zig
  ];

  nixpkgs.config.allowUnfree = true;

  # Make a root user with no password and zsh as default shell
  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    extraUsers.root = {
      hashedPassword = "";
      openssh.authorizedKeys.keyFiles = [
        pubkeys/orion
        pubkeys/it23
      ];
    };
  };

  # zsh + oh-my-zsh config
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -lha";
      gap = "git add -p";
      gs = "git status";
      switch = "nixos-rebuild switch";
    };
    ohMyZsh = {
      enable = true;
      plugins = ["git"];
      theme = "agnoster";
    };
  };
}
