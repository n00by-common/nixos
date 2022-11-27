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
    rev = "a84fad9acce44171508e92a84b70cf7fd6edfbb8";
    sha256 = "16hc1nacigqk56dybfh7vzhf7s9yyi3ffyxddzy7g0g9m9573g10";
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
