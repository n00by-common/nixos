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
    rev = "f7243df41c31b702e7e7234a8656be26b566caff";
    sha256 = "1g1j76jp9v90jlky2vw28ixpilb7a2x77gfiv8xr6j10v6bhnhjk";
  };

  nativeBuildInputs = [ zig pkgs.autoPatchelfHook ];

  buildInputs = [ xlibs.libX11 ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  installPhase = ''
    runHook preInstall
    zig build --prefix $out install
    runHook postInstall
  '';
}
