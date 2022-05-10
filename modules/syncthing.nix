{ config, pkgs, lib, my_pkgs, ... }:
let
  my_devices = {
    orion = { id = "4U6OJN3-4EBEN7H-OPQG7Q2-VTWTLXT-N7RSW7W-S43PQ3Q-23SI67E-GTUC7AD"; };
    it23  = { id = "GQTGIBI-LI3AUQ2-FZVSSB7-QKG64IF-SZS5RQX-D4X6FTZ-AMCUSNA-B5OBBAT"; };
    it34  = { id = "UNPHR4Q-2EPW56V-QMJ37JZ-JMASPHZ-D3MSQ3Z-7ZUNPRY-2YXDB6G-Z4GXXAT"; };
    rs07  = { id = "YVB4CFE-2VDPJG4-2KQFSMS-3QHU25B-OUXZEPK-V5WXW46-JS2HEDX-YOJLTAG"; };
  };
  all_devices = {

  } // my_devices;
in {
  options.my_cfg = {
    syncthing = {
      enable = lib.mkEnableOption "Sync-things on this computer";
      fs-path = lib.mkOption {
        type = lib.types.str;
        default = "/root/fs";
        description = "Path for the fs sync directory";
      };
    };
  };

  config = lib.mkIf config.my_cfg.syncthing.enable {
    services.syncthing = {
      enable = true;

      group = "root";
      user = "root";

      overrideDevices = true;

      devices = all_devices;

      overrideFolders = true;

      folders = {
        fs = {
          enable = true;
          id = "vksaj-avrho";
          path = config.my_cfg.syncthing.fs-path;
          devices = builtins.attrNames my_devices;
        };

        nixos-hanus = {
          enable = true;
          id = "nixos-hanus";
          path = "/etc/nixos";
          devices = builtins.attrNames my_devices;
        };
      };

      extraOptions = {
        gui = { theme = "black"; };
        crashReportingEnabled = "false";
        urAccepted = "-1"; # Disable usage reporting
      };
    };
  };
}

