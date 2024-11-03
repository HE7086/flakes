{ config, lib, ... }: {
  imports = [
    ./web.nix
    ./rsyncd.nix
    ./avahi.nix
    ./samba.nix
  ];
  options = {
    services.fileShare.remote = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      dir = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "/share/Public";
      };
      createDir = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      virtualHost = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "share.${config.networking.hostName}.heyi7086.com";
      };
      mode = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "755";
      };
      user = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "1000";
      };
      group = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "100";
      };
      rsyncd = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
    services.fileShare.local = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };
}
