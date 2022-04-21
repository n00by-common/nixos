{ stdenv
, xlibs
, pkgs
, pkg-config
, ncurses
, font_size
}:
stdenv.mkDerivation rec {
  name = "st";

  version = "0.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "n00by-common";
    repo = "st";
    rev = "f06de8ff44c088f6a262b0762ab2120f94cc2a0b";
    sha256 = "1i4rxdiz5iblf3zd796h86wvq2hkzl3bnb786sjy2ms961pbz77p";
  };

  preInstall = ''
    export TERMINFO=$out/share/terminfo
  '';

  makeFlags = [
    "PREFIX=$(out)"
    "FONT=mono:pixelsize=${toString font_size}"
  ];

  nativeBuildInputs = [
    pkg-config
    ncurses
  ];

  buildInputs = [ xlibs.libX11 xlibs.libXft ];
}
