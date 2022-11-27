{ stdenv
, fetchurl
, pkgs
}:
stdenv.mkDerivation rec {
  name = "zig-${version}";

  version = "0.10.0-dev.85+c0ae9647f";

  src = /root/tmp/2i4c9w58yykk2pa07dfx1gnf96agaf21-zig-0.10.0-dev.85+c0ae9647f;
  #src = pkgs.requireFile {
  #  name = "2i4c9w58yykk2pa07dfx1gnf96agaf21-zig-0.10.0-dev.85+c0ae9647f.zip";
  #  sha256 = "1rb3xprywhkq9zms1y738vbma63d45xcwmsz9kyplm6r3naa0pji";
  #  message = ''
  #    Zig not found
  #  '';
  #};
  #src = fetchurl {
  #  url = "https://ziglang.org/builds/zig-linux-x86_64-${version}.tar.xz";
  #  sha256 = "06a9rzv5vha2p9vmr425g7qx3ngaihpxq71vpif1r7bj7djqrcx9";
  #};

  nativeBuildInputs = [ ];

  #sourceRoot = "./zig-linux-x86_64-${version}/";

  installPhase = ''
    mkdir -p $out/bin
    cp bin/zig $out/bin/zig
    cp -r lib $out/lib
  '';
}
