{ config, pkgs, lib, my_pkgs, ... }:
{
  options.my_cfg.remotely-accessible.enable = lib.mkEnableOption "Make this computer remotely accessible";

  config = lib.mkIf config.my_cfg.remotely-accessible.enable {
    services.openssh = {
      enable = true;
    };
  };
}
