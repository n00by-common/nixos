{ stdenv
, xorg
, pkgs
}:
stdenv.mkDerivation rec {
  name = "dmenu";

  version = "0.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "n00by-common";
    repo = "dmenu";
    rev = "551cb7e22d62311c62313b632271229f71935f5c";
    sha256 = "1gxygnmxpxrisca3p4yvdbbw4cd3cxjwl4y45wzp6bl1p4cbygkr";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  buildInputs = [ xorg.libX11 xorg.libXinerama xorg.libXft ];
}
