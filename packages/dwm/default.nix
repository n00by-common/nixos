{ stdenv
, xlibs
, pkgs
}:
stdenv.mkDerivation rec {
  name = "dwm";

  version = "0.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "n00by-common";
    repo = "dwm";
    rev = "5e58eea46921c434cac22b14020172249b12bb73";
    sha256 = "1k62i15fbkh9czca6673fx06717q7jqpjxmzlvnb1q6gkad25spi";
  };

  makeFlags = [ "PREFIX=$(out)" "FONTSIZE=10" ];

  buildInputs = [ xlibs.libX11 xlibs.libXft xlibs.libXinerama ];
}
