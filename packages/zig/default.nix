{ stdenv
, fetchurl
}:
stdenv.mkDerivation rec {
  name = "zig-${version}";

  version = "0.10.0-dev.85+c0ae9647f";

  src = fetchurl {
    url = "https://ziglang.org/builds/zig-linux-x86_64-${version}.tar.xz";
    sha256 = "06a9rzv5vha2p9vmr425g7qx3ngaihpxq71vpif1r7bj7djqrcx9";
  };

  nativeBuildInputs = [ ];

  sourceRoot = "./zig-linux-x86_64-${version}/";

  installPhase = ''
    mkdir -p $out/bin
    cp zig $out/bin/zig
    cp -r lib $out/lib
  '';
}
