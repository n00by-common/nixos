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
    rev = "8fd5f9553209014db7cad7d8fb9ed57ed4a82016";
    sha256 = "0ky0ghzzcwl44nmam03cpkx7id45z98y05njl7yxkgyz3bxffqgz";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  buildInputs = [ xlibs.libX11 xlibs.libXft xlibs.libXinerama ];
}
