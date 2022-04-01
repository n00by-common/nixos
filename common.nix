 { config, pkgs, ... }:

{
  imports = [ ];

  # Packages
  environment.systemPackages = with pkgs; [
    git htop oh-my-zsh nix-index most neofetch
    (
      with import <nixpkgs> {};
      
      vim_configurable.customize {
        name = "vim";
        vimrcConfig.customRC = ''
          syntax enable
          if has("autocmd")
            au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
          endif
          set backspace=indent,eol,start
          set number
          set ruler
          nnoremap <C-t> :tabnew<CR>
          nnoremap <C-w> :q<CR>
          nnoremap <C-o> :tabe 
          nnoremap <C-s> :w<CR>
          nnoremap . :tabnext<CR>
          nnoremap , :tabprev<CR>
        '';
      }
    )
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
      transfer = "/etc/nixos/transfer.sh";
      killall = "/etc/nixos/killall.sh";
    };
    ohMyZsh = {
      enable = true;
      plugins = ["git"];
      theme = "agnoster";
    };
  };
}
