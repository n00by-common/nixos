{ stdenv
, xorg
, pkgs
, st
, font_size
}:
stdenv.mkDerivation rec {
  name = "dwm";

  version = "0.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "n00by-common";
    repo = "dwm";
    rev = "bc3440c017cc79fbb2b9a1c7ffadf24465eea9f1";
    sha256 = "0wrh8rb9j19z6frb1rf6vk5qj776xk1kqa4yh354vqnp6xq50liq";
  };

  makeFlags = [ "PREFIX=$(out)" "FONTSIZE=${toString font_size}" "ST=${st}/bin/st" ];

  buildInputs = [ xorg.libX11 xorg.libXft xorg.libXinerama ];
}
