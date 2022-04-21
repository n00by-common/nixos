{ pkgs
, config
}:
let
  addNoSandbox = command_name: package:
    if config.my_cfg.everything_as_root
    then (pkgs.writeShellScriptBin command_name "${package}/bin/${command_name} --no-sandbox")
    else package;
in rec {
  zig = import ./zig {
    inherit (pkgs) stdenv fetchurl;
  };

  dwm = import ./dwm {
    inherit pkgs st;
    inherit (pkgs) stdenv xlibs;
    font_size = config.my_cfg.graphical.wm_font_size;
  };

  dwmstatus = import ./dwmstatus {
    inherit zig pkgs;
    inherit (pkgs) stdenv xlibs;
    time_zone = config.time.timeZone;
    time_format = config.my_cfg.time_format;
    battery_path = config.my_cfg.battery_path;
  };

  dmenu = import ./dmenu {
    inherit pkgs;
    inherit (pkgs) stdenv xlibs;
  };

  ida_env = import ./ida {
    inherit pkgs;
    inherit (config.my_cfg.ida) installer password;
    inherit (pkgs) stdenv;
  };

  ida = pkgs.writeShellScriptBin "ida" ''
    exec ${ida_env}/bin/ida ${ida_env}/opt/idapro/ida "$@"
  '';

  ida64 = pkgs.writeShellScriptBin "ida64" ''
    exec ${ida_env}/bin/ida ${ida_env}/opt/idapro/ida64 "$@"
  '';

  st = import ./st {
    inherit pkgs;
    inherit (pkgs) stdenv xlibs pkg-config ncurses;
    font_size = config.my_cfg.graphical.terminal_font_size;
  };

  # Lutris gives a dismissable error box on startup when running as root, get rid of it
  lutris = (pkgs.lutris.override {
    lutris-unwrapped = pkgs.lutris-unwrapped.overrideAttrs (old: {
      patches = (old.patches or []) ++ [ ../patches/lutris/lutris-as-root.patch ];
    });
  });

  # Browser based packages that require `--no-sandbox` to run as root
  discord = addNoSandbox "discord" pkgs.discord;
  teams = addNoSandbox "teams" pkgs.teams;

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

  nix-locate = pkgs.writeShellScriptBin "nix-locate" ''
    ${pkgs.nix-index}/bin/nix-locate "$@" | ${pkgs.most}/bin/most
  '';

  killall = pkgs.writeShellScriptBin "killall" ''
    kill -9 `pidof "$@"`
  '';

  transfer = pkgs.writeShellScriptBin "transfer" ''
    if [ $# -eq 0 ]; then
      echo -e "No arguments specified.\nUsage:\n  transfer <file|directory>\n  ... | transfer <file_name>">&2;
      exit 1
    fi;

    if tty -s; then
      file="$1";
      file_name=$(basename "$file");
      if [ ! -e "$file" ]; then
        echo "$file: No such file or directory">&2;
        exit 1
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
