{ stdenv
, zig
, xlibs
, pkgs
}:
stdenv.mkDerivation rec {
  name = "dwmstatus";

  version = "0.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "n00by-common";
    repo = "dwmstatus";
    rev = "5322eaf11c1c121f4e6af99aa9410eaa16bfec96";
    sha256 = "1wa2xps0hg3fkfjchwwj7i3216ivgrdq2j9diaqfahwcd713pp3w";
  };

  buildInputs = [ zig xlibs.libX11 ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  installPhase = ''
    runHook preInstall
    zig build --prefix $out install
    runHook postInstall
  '';
}
