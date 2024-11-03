{ config, lib, ... }:
let
  cfg = config.services.fileShare.local;
in
lib.mkIf cfg.enable {
  services.avahi = {
    enable = true;
    ipv6 = true;
    nssmdns4 = true;
    nssmdns6 = true;
    openFirewall = true;
    publish = {
      enable = true;
      hinfo = true;
      domain = true;
      addresses = true;
      userServices = true;
    };
  };
}
