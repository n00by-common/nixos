{ stdenv
, zig
, xorg
, pkgs
, battery_path
, time_format
, time_zone
}:
let
  formatArg = var: prefix: if var != null then prefix + var else "";
in
stdenv.mkDerivation rec {
  name = "dwmstatus";

  version = "0.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "n00by-common";
    repo = "dwmstatus";
    rev = "39b3db771a15da778b21d8ebaf112c6b01980583";
    sha256 = "sha256-fqJIHTR0KUZLZSpzrDdFiXkRm7wZxGSiiVT+x2QYP6U=";
  };

  nativeBuildInputs = [ zig pkgs.autoPatchelfHook ];

  buildInputs = [ xorg.libX11 ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  installPhase = ''
    runHook preInstall
    zig build --prefix $out install\
      ${formatArg battery_path "-Dbattery_path="} \
      ${formatArg time_format "-Dtime_format="} \
      ${formatArg time_zone "-Dtime_zone="}
    runHook postInstall
  '';
}
