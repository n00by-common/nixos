{ config, pkgs, lib, my_pkgs, ... }:
let
  my_devices = {
    Orion = { id = "OG44L7N-BQ42XYO-WVA5FAJ-VRGU2J4-VPVJSDX-WJTFQKK-UCGMAC2-5ZMPXAC"; };
    it23  = { id = "GQTGIBI-LI3AUQ2-FZVSSB7-QKG64IF-SZS5RQX-D4X6FTZ-AMCUSNA-B5OBBAT"; };
    it34  = { id = "UNPHR4Q-2EPW56V-QMJ37JZ-JMASPHZ-D3MSQ3Z-7ZUNPRY-2YXDB6G-Z4GXXAT"; };
    rs07  = { id = "YVB4CFE-2VDPJG4-2KQFSMS-3QHU25B-OUXZEPK-V5WXW46-JS2HEDX-YOJLTAG"; };
  };
  all_devices = {

  } // my_devices;
in {
  options.my_cfg.sync-fs = {
    enable = lib.mkEnableOption "Sync the fs dir on this computer";
    path = lib.mkOption {
      type = lib.types.str;
      default = "/root/fs";
      description = "Path for the fs sync directory";
    };
  };

  config = lib.mkIf config.my_cfg.sync-fs.enable {
    services.syncthing = {
      enable = true;

      group = "root";
      user = "root";

      overrideDevices = true;

      devices = all_devices;

      overrideFolders = false;

      folders = {
        fs = {
          id = "vksaj-avrho";
          path = config.my_cfg.sync-fs.path;
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

