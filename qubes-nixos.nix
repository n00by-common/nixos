{ config, pkgs, ... }:

{
  imports = [ ./common.nix ./hardware-configuration.nix ];

  time.timeZone = "Europe/Stockholm";

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/xvda";

  networking = {
    hostName = "qubes-nixos";
    useDHCP = false;
    interfaces = {
      eth0 = {
        useDHCP = false;
        ipv4.addresses = [{ address = "10.137.0.40"; prefixLength = 24; }];
      };
    };
    defaultGateway = "10.137.0.6";
    nameservers = ["10.139.1.1" "10.139.1.2"];
  };

  i18n.defaultLocale = "C.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };

  services.xserver.layout = "se";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}

