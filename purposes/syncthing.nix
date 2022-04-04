{ config, pkgs, ... }:

let
  devices = {
    Orion = { id = "OG44L7N-BQ42XYO-WVA5FAJ-VRGU2J4-VPVJSDX-WJTFQKK-UCGMAC2-5ZMPXAC"; };
    it23  = { id = "GQTGIBI-LI3AUQ2-FZVSSB7-QKG64IF-SZS5RQX-D4X6FTZ-AMCUSNA-B5OBBAT"; };
  };
in {
  services.syncthing = {
    enable = true;

    group = "root";
    user = "root";

    overrideDevices = true;

    devices = devices;

    overrideFolders = true;

    folders = {
      fs = {
        id = "vksaj-avrho";
        devices = builtins.attrNames devices;
      };
    };

    extraOptions = {
      gui = { theme = "black"; };
      crashReportingEnabled = "false";
      urAccepted = "-1"; # Disable usage reporting
    };
  };
}

