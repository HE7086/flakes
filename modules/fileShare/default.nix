{ config, lib, ... }:
with lib;
{
  imports = [
    ./web.nix
    ./rsyncd.nix
    ./avahi.nix
    ./samba.nix
  ];
  options = {
    services.fileShare.remote = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      dir = mkOption {
        type = types.singleLineStr;
        default = "/share/Public";
      };
      createDir = mkOption {
        type = types.bool;
        default = true;
      };
      virtualHost = mkOption {
        type = types.singleLineStr;
        default = "share.${config.networking.fqdn}";
      };
      mode = mkOption {
        type = types.singleLineStr;
        default = "755";
      };
      user = mkOption {
        type = types.singleLineStr;
        default = "1000";
      };
      group = mkOption {
        type = types.singleLineStr;
        default = "100";
      };
      rsyncd = mkOption {
        type = types.bool;
        default = false;
      };
      acmeHost = mkOption {
        type = types.bool;
        default = true;
      };
    };
    services.fileShare.local = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
}
