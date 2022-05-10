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

  zig-master = (pkgs.zig.override({
    llvmPackages = pkgs.llvmPackages_13;
  })).overrideAttrs(old: {
    src = pkgs.fetchFromGitHub {
      owner = "ziglang";
      repo = "zig";
      rev = "ea3f5905f0635d0c0cb3983ba5ca6c92859e9d81";
      sha256 = "0xhrm96mrpkmzr7zg8cb14l2xaicq48mnqc2f4akmzz0zn7ssrjh";
    };
  });

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

  pida_env = import ./ida {
    inherit pkgs;
    inherit (config.my_cfg.pida) installer password;
    inherit (pkgs) stdenv;
  };

  pida = pkgs.writeShellScriptBin "pida" ''
    exec ${pida_env}/bin/ida ${pida_env}/opt/idapro/ida "$@"
  '';

  pida64 = pkgs.writeShellScriptBin "pida64" ''
    exec ${pida_env}/bin/ida ${pida_env}/opt/idapro/ida64 "$@"
  '';

  st = import ./st {
    inherit pkgs;
    inherit (pkgs) stdenv xlibs pkg-config ncurses;
    font_size = config.my_cfg.graphical.terminal_font_size;
  };

  #sublime = import ./sublime {
  #  inherit pkgs;
  #  subl = pkgs.sublime4;
  #};

  sublime = pkgs.sublime4;

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

  nix-index = pkgs.writeShellScriptBin "nix-index" ''
    ${pkgs.nix-index}/bin/nix-index "$@"
  '';

  killall = pkgs.writeShellScriptBin "killall" ''
    kill -9 `pidof "$@"`
  '';

  https-to-ssh = pkgs.writeShellScriptBin "https-to-ssh" ''
    REPO_URL=`git remote -v | grep -m1 '^origin' | sed -Ene's#.*(https://[^[:space:]]*).*#\1#p'`
    if [ -z "$REPO_URL" ]; then
      echo "-- ERROR:  Could not identify Repo url."
      echo "   It is possible this repo is already using SSH instead of HTTPS."
      exit
    fi

    USER=`echo $REPO_URL | sed -Ene's#https://github.com/([^/]*)/(.*).git#\1#p'`
    if [ -z "$USER" ]; then
      echo "-- ERROR:  Could not identify User."
      exit
    fi

    REPO=`echo $REPO_URL | sed -Ene's#https://github.com/([^/]*)/(.*).git#\2#p'`
    if [ -z "$REPO" ]; then
      echo "-- ERROR:  Could not identify Repo."
      exit
    fi

    NEW_URL="git@github.com:$USER/$REPO.git"
    echo "Changing repo url from "
    echo "  '$REPO_URL'"
    echo "      to "
    echo "  '$NEW_URL'"
    echo ""

    CHANGE_CMD="git remote set-url origin $NEW_URL"
    `$CHANGE_CMD`

    echo "Success"
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
