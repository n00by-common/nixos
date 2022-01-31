 { config, pkgs, ... }:

{
  imports = [ ];

  # Packages
  environment.systemPackages = with pkgs; [
    git oh-my-zsh
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
          nnoremap <C-t> :tabnew<CR>
          nnoremap <C-w> :q<CR>
          nnoremap <C-o> :tabe 
          nnoremap . :tabnext<CR>
          nnoremap , :tabprev<CR>
        '';
      }
    )
  ];

  # Make a root user with no password and zsh as default shell
  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    extraUsers.root.hashedPassword = "";
  };

  # zsh + oh-my-zsh config
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -lha";
      gap = "git add -p";
      switch = "nixos-rebuild switch";
    };
    ohMyZsh = {
      enable = true;
      plugins = ["git"];
      theme = "agnoster";
    };
  };
}
