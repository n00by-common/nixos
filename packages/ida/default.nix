{ stdenv
, pkgs
, installer
, password
, python ? pkgs.python38
}:
let
  multiPkgs = _: [
    pkgs.xorg.libX11
    pkgs.xorg.libxcb
    pkgs.xorg.xcbutilwm
    pkgs.xorg.xcbutilimage
    pkgs.xorg.xcbutilkeysyms
    pkgs.xorg.xcbutilrenderutil
    pkgs.xorg.libSM
    pkgs.xorg.libICE

    pkgs.libxkbcommon

    pkgs.dbus_daemon.lib

    python
    pkgs.libGL
    pkgs.zlib
    pkgs.glib
    pkgs.fontconfig
    pkgs.freetype

    stdenv.cc.cc.lib
  ];
  rpath = pkgs.lib.makeLibraryPath (multiPkgs {inherit pkgs;});
  env = pkgs.buildFHSUserEnv rec {
    name = "ida";
    inherit multiPkgs;
    runScript = pkgs.writeScript "ida" "exec -- \"$@\"";
  };
in stdenv.mkDerivation rec {
  name = "ida";

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    echo "Patching ida installer"
    mkdir -p $out
    cp ${installer} $out/ida.run
    chmod +w $out/ida.run # For patching
    patchelf \
      --set-interpreter "$(cat ${stdenv.cc}/nix-support/dynamic-linker)" \
      $out/ida.run
    chmod +x $out/ida.run

    echo "Installing ida into" $out/opt/idapro
    $out/ida.run --prefix $out/opt/idapro --installpassword ${password} --mode unattended --python_version 3
    rm $out/ida.run

    echo "Setting up fhsenv runner"
    mkdir -p $out/bin
    ln -s ${env}/bin/ida $out/bin/ida

    echo "Setting libpython path: $(${python}/bin/python-config --prefix)/lib/libpython3.so"
    ${pkgs.patchelf}/bin/patchelf \
      --add-rpath ${rpath} \
      --set-interpreter "$(cat ${stdenv.cc}/nix-support/dynamic-linker)" \
      $out/opt/idapro/idapyswitch
    $out/opt/idapro/idapyswitch \
      --force-path "$(${python}/bin/python-config --prefix)/lib/libpython3.so"
  '';
}
