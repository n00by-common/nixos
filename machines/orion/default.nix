# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  display-setup = ''
    xsetroot -solid "#000000"
    LEFT='DP-0'
    CENTER='DP-2'
    RIGHT='HDMI-0'
    ${pkgs.xorg.xrandr}/bin/xrandr --output $CENTER --primary --output $LEFT --left-of $CENTER --output $RIGHT --right-of $CENTER
    setxkbmap -layout se
    ${pkgs.xorg.xhost}/bin/xhost +
  '';
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules
    ];

  my_cfg = {
    dev.enable = true;
    syncthing.enable = true;
    remotely-accessible.enable = true;
    gamering.enable = true;

    graphical = {
      enable = true;
      wm_font_size = 10;
      terminal_font_size = 32;
    };

    ida = import ../../secret/ida.nix {inherit pkgs;};
    pida = import ../../secret/pida.nix {inherit pkgs;};
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.xpadneo.enable = true;

  networking.firewall.allowedTCPPorts = [80 443];
  services.nginx = {
    enable = true;
    virtualHosts."gurrasnurra.se" = {
      enableACME = true;
      forceSSL = true;
      root = "/zpool/gurrasnurra/public_html";
    };

    virtualHosts."badcode.se" = {
      enableACME = true;
      forceSSL = true;
      root = "/zpool/badcode/public_html";
    };
  };

  services.owncast = {
    enable = true;
    dataDir = "/zpool/owncast";
    openFirewall = true;
    user = "root";
    group = "root";
    port = 8080;
    rtmp-port = 1935;
    listen = "0.0.0.0";
  };

  nixpkgs.overlays = [ (self: super: {
    owncast = with super; buildGoModule rec {
      pname = "owncast";
      version = "0.0.12";

      src = fetchFromGitHub {
        owner = "owncast";
        repo = "owncast";
        rev = "v${version}";
        sha256 = "sha256-i/MxF+8ytpbVzGyRLbfHx7sR2bHEvAYdiwAc5TNrafc=";
      };

      vendorSha256 = "sha256-sQRNf+eT9JUbYne/3E9LoY0K+c7MlxtIbGmTa3VkHvI=";

      propagatedBuildInputs = [ ffmpeg ];

      nativeBuildInputs = [ makeWrapper ];

      preInstall = ''
        mkdir -p $out
        cp -r $src/{static,webroot} $out
      '';

      postInstall = let

        setupScript = ''
          [ ! -d "$PWD/webroot" ] && (
            ${coreutils}/bin/cp --no-preserve=mode -r "${placeholder "out"}/webroot" "$PWD"
          )
          [ ! -d "$PWD/static" ] && (
            ${coreutils}/bin/ln -s "${placeholder "out"}/static" "$PWD"
          )
        '';
      in ''
        wrapProgram $out/bin/owncast \
          --run '${setupScript}' \
          --prefix PATH : ${lib.makeBinPath [ bash which ffmpeg ]}
      '';

      installCheckPhase = ''
        runHook preCheck
        $out/bin/owncast --help
        runHook postCheck
      '';

      passthru.tests.owncast = nixosTests.testOwncast;

      meta = with lib; {
        description = "self-hosted video live streaming solution";
        homepage = "https://owncast.online";
        license = licenses.mit;
        platforms = platforms.unix;
        maintainers = with maintainers; [ MayNiklas ];
      };
    };
  } ) ];

  environment.systemPackages = [
    pkgs.xorg.xsetroot
    pkgs.wineWowPackages.stable
    (pkgs.writeShellScriptBin "bzui" ''
      WINEARCH=win64 WINEPREFIX=/zpool/.wine wine /zpool/.wine/drive_c/Program\ Files\ \(x86\)/Backblaze/bzbui.exe
    '')
  ];

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;

  networking.hostName = "orion";
  networking.hostId = "69696969"; # for zfs

  i18n.defaultLocale = "C.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };
  services.xserver.layout = "se";

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;

  hardware.video.hidpi.enable = true;

  system.stateVersion = "21.11";

  services.xserver.displayManager.setupCommands = display-setup;
  services.xserver.displayManager.sessionCommands = display-setup;
}

