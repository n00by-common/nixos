{ system ? builtins.currentSystem }:

let
  pkgs = import <nixpkgs> { inherit system; };
in
rec {
  zig = import ./zig {
    inherit (pkgs) stdenv fetchurl;
  };

  dwm = import ./dwm {
    pkgs = pkgs;
    inherit (pkgs) stdenv xlibs;
  };

  dwmstatus = import ./dwmstatus {
    zig = zig;
    pkgs = pkgs;
    inherit (pkgs) stdenv xlibs;
  };

  dmenu = import ./dmenu {
    pkgs = pkgs;
    inherit (pkgs) stdenv xlibs;
  };

  st = import ./st {
    pkgs = pkgs;
    inherit (pkgs) stdenv xlibs pkg-config ncurses;
  };

  vim = pkgs.vim_configurable.customize {
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
  };

  killall = pkgs.writeShellScriptBin "killall" ''
    kill -9 `pidof "$@"`
  '';

  transfer = pkgs.writeShellScriptBin "transfer" ''
    if [ $# -eq 0 ];
      then echo "No arguments specified.\nUsage:\n  transfer <file|directory>\n  ... | transfer <file_name>">&2;
      return 1;
    fi;

    if tty -s; then
      file="$1";
      file_name=$(basename "$file");
      if [ ! -e "$file" ]; then
        echo "$file: No such file or directory">&2;
        return 1;
      fi;
      if [ -d "$file" ]; then
        file_name="$file_name.zip" ,;
        (cd "$file"&&zip -r -q - .)|curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name"|tee /dev/null;
      else
        cat "$file"|curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name"|tee /dev/null;
      fi;
    else
      file_name=$1;curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name"|tee /dev/null;
    fi;
  '';
}
