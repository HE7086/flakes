{ config, lib, ... }:
let
  cfg = config.services.fileShare.remote;
in
lib.mkIf (cfg.enable && cfg.rsyncd) {
  services.rsyncd = {
    enable = true;
    settings = {
      global = {
        user = "rsyncd";
        group = "rsyncd";
        "use chroot" = false;
      };
      public = {
        comment = "rsyncd public share";
        path = cfg.dir;
        "read only" = "yes";
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 873 ];

  users = {
    users.rsyncd = {
      isSystemUser = true;
      group = "rsyncd";
    };
    groups.rsyncd = { };
  };

  systemd.services.rsyncd.serviceConfig = {
    AmbientCapabilities = "cap_net_bind_service";
  };
}
