# This module defines a small NixOS installation CD.  It does not
# contain any graphical stuff.
{config, pkgs, ...}:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>

    ../modules
  ];

  my_cfg = {
    graphical = {
      enable = true;
      wm_font_size = 20;
      terminal_font_size = 32;
    };
  };

  time.timeZone = "Europe/Stockholm";

  networking = {
    # I don't like wpa_supplicant, use `nmtui` to configure wifi
    wireless.enable = false;
    networkmanager.enable = true;
  };

  services.xserver.synaptics.enable = true;
}
