{ pkgs
, config
}:
let
  addNoSandbox = command_name: package:
    if config.my_cfg.everything_as_root
    then (pkgs.writeShellScriptBin command_name "${package}/bin/${command_name} --no-sandbox")
    else package;
in rec {
  albion_env = import ./albion {
    inherit pkgs;
    inherit (pkgs) stdenv fetchurl;
  };

  albion = pkgs.writeShellScriptBin "albion" ''
    cp -r ${albion_env}/albion $HOME/albion
    export LD_LIBRARY_PATH=$HOME/albion/data/launcher
    export QT_QPA_PLATFORM_PLUGIN_PATH=$HOME/albion/data/launcher/plugins/platforms
    export QT_PLUGIN_PATH=$HOME/albion/data/launcher/plugins
    exec ${albion_env}/bin/albion $HOME/albion/data/Albion-Online "$@"
  '';

  zig = import ./zig {
    inherit pkgs;
    inherit (pkgs) stdenv fetchurl;
  };

  # zig = (pkgs.zig.override({
  #   llvmPackages = pkgs.llvmPackages_13;
  # })).overrideAttrs(old: {
  #   src = pkgs.fetchFromGitHub {
  #     owner = "ziglang";
  #     repo = "zig";
  #     rev = "c0ae9647f9656ea47c49ffd64443b7da73aeffc7";
  #     sha256 = "1w8jnf1ayhv2mlbnkdiy84jvjhq3w49d4j2bwghi86rxi9z5g69r";
  #   };
  # });

  #zig-master = (pkgs.zig.override({
  #  llvmPackages = pkgs.llvmPackages_13;
  #})).overrideAttrs(old: {
  #  src = pkgs.fetchFromGitHub {
  #    owner = "ziglang";
  #    repo = "zig";
  #    rev = "ee651c3cd358f40f60db0bbcd82ffde99aed9b88";
  #    sha256 = "14hdwmy41804v28xm1clb8zjdf66wsdc5003cfyryll0qqqnqq5f";
  #  };
  #});

  zig-master = (pkgs.stdenv.mkDerivation rec{
    name = "zig-${version}";
    version = "0.10.0-dev.4541+e67c756b9";
    src = pkgs.fetchurl {
      url = "https://ziglang.org/builds/zig-linux-x86_64-${version}.tar.xz";
      sha256 = "sha256-iup07iICHYAg2bYXtbvzwZsa3ZrNjvIIubXWYuf4jkE=";
    };
    sourceRoot = "./zig-linux-x86_64-${version}/";
    installPhase = ''
      mkdir -p $out/bin
      cp zig $out/bin/zig
      cp -r lib $out/lib
    '';
  });

  # zig-master = (pkgs.zig.override({
  #  llvmPackages = pkgs.llvmPackages_14;
  # })).overrideAttrs(old: {
  #  #src = /root/zig-master;
  #  src = pkgs.fetchFromGitHub {
  #    owner = "ziglang";
  #    repo = "zig";
  #    rev = "0d120fcb892d99417ee361adb79671c473f798ee";
  #    sha256 = "10ynpd6mcxvin9ys93hbnb32yqp6fvpma1daknsfj22k770214j0";
  #  };
  #  cmakeFlags = [
  #    "-DCMAKE_SKIP_BUILD_RPATH=ON"
  #    "-DZIG_STATIC_ZLIB=ON"
  #  ];
  # });

  binja = pkgs.stdenv.mkDerivation rec {
    name = "binary-ninja";
    buildInputs = with pkgs; [
      autoPatchelfHook
      makeWrapper
      unzip
      libGL
      stdenv.cc.cc.lib
      glib
      fontconfig
      xorg.libXi
      xorg.libXrender
      xorg.xcbutilwm
      xorg.xcbutilimage
      xorg.xcbutilkeysyms
      xorg.xcbutilrenderutil
      ncurses
      qt6.qtdeclarative
      qt6.qtbase
      libxkbcommon
      dbus
    ];
    src = pkgs.requireFile {
      name = "BinaryNinja-personal.zip";
      sha256 = "1fyc629vxnda6sap32nw5k3ikq1mjnaw6vzxgynj4hz86nf0xaik";
      message = ''
        Binary ninja not found!
      '';
    };

    buildPhase = ":";
    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/opt
      cp -r * $out/opt
      chmod +x $out/opt/binaryninja
      makeWrapper $out/opt/binaryninja \
            $out/bin/binaryninja \
            --prefix "QT_XKB_CONFIG_ROOT" ":" "${pkgs.xkeyboard_config}/share/X11/xkb"
    '';
  };

  dwm = import ./dwm {
    inherit pkgs st;
    inherit (pkgs) stdenv xorg;
    font_size = config.my_cfg.graphical.wm_font_size;
  };

  dwmstatus = import ./dwmstatus {
    inherit zig pkgs;
    inherit (pkgs) stdenv xorg;
    time_zone = config.time.timeZone;
    time_format = config.my_cfg.time_format;
    battery_path = config.my_cfg.battery_path;
  };

  dmenu = import ./dmenu {
    inherit pkgs;
    inherit (pkgs) stdenv xorg;
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

  pida_env = import ./ida/ida7.nix {
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
    inherit (pkgs) stdenv xorg pkg-config ncurses;
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

  xenia = import ./xenia {
    inherit (pkgs) fetchFromGitHub gtk3 llvmPackages_9 lz4 pkg-config python3 SDL2 vulkan-headers vulkan-loader;
  };

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

  git-pretty-log = pkgs.writeShellScriptBin "gpl" ''
    ${pkgs.git}/bin/git log --color --pretty='format:%C(auto)%h %C(red)%ai %C(blue)%an %C(white)%s' | ${pkgs.most}/bin/most
  '';
}
