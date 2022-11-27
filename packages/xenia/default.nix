{ fetchFromGitHub
, gtk3
, llvmPackages_9
, lz4
, pkg-config
, python3
, SDL2
, vulkan-headers
, vulkan-loader
}:

let
  stdenv = llvmPackages_9.libcxxStdenv;
in

stdenv.mkDerivation {
  pname = "xenia";
  version = "v1.0.2677-master";

  src = fetchFromGitHub {
    owner = "xenia-project";
    repo = "xenia";
    rev = "820b7ba2178a88df564f516dca9aa6be64f8e99c";
    sha256 = "1iqfj37dfzbypf91hzrmilx9rzxmb496r0np8ls7famflacsb4jv";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    llvmPackages_9.bintools
    pkg-config
    python3
  ];

  buildInputs = [
    gtk3
    lz4
    SDL2
    vulkan-headers
    vulkan-loader
  ];

  patchPhase = ''
    runHook prePatch

    # Fixes "fatal error: 'sys/sysctl.h' file not found"
    #substituteInPlace third_party/libav/config_lin.h \
    #  --replace "#define HAVE_SYSCTL 1" "#define HAVE_SYSCTL 0"

    runHook postPatch
  '';

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    # TODO Look into using 'setup' argument
    python3 xenia-build build --config release -j $NIX_BUILD_CORES

    runHook postBuild
  '';

  NIX_CFLAGS_COMPILE = "-Wno-error-unused-result";

  enableParallelBuilding = true;
}
