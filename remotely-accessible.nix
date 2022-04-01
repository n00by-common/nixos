{ config, pkgs, ... }:

{
  imports = [ ];

  #environment.systemPackages = with pkgs; [
  #  firefox st dmenu
  #];

  services.openssh = {
    enable = true;
  };
}

