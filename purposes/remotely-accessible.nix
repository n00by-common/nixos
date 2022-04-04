{ config, pkgs, ... }:

{
  imports = [ ];

  services.openssh = {
    enable = true;
  };
}

