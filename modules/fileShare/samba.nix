{ config, lib, ... }:
let
  cfg = config.services.fileShare.local;
in
lib.mkIf cfg.enable {
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        workgroup = "heyi7086.home.arpa";
        "server string" = "${config.networking.hostName}-samba";
        "netbios name" = "${config.networking.hostName}";
        security = "user";
        "hosts allow" = "192.168.1. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
        "veto files" = "/._*/.DS_Store/";
        "delete veto files" = "yes";
      };
      share = {
        path = "/share";
        browseable = "yes";
        writeable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "he";
        "force group" = "users";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
