# Template for actual contents
{ pkgs
}:
{
    enable = true;
    installer = pkgs.requireFile {
      name = "idapronl_000000_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.run";
      sha256 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
      message = ''
        Installer not found
      '';
    };
    password = "aaaaaaaaaaaaaa";
}
