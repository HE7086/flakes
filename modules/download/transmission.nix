{ config, pkgs, ... }:
{
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    # openRPCPort = true;
    openFirewall = true;
    settings = {
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist = "127.0.0.1,192.168.1.*";
      rpc-host-whitelist-enabled = false;

      download-dir = "/share/Downloads";
      incomplete-dir = "/share/Downloads/Incomplete";
      watch-dir-enabled = true;
      watch-dir = "/share/Downloads/Torrent";
    };
  };
  users.users.transmission.extraGroups = [ "shared-storage" ];

  services.nginx.enable = true;
  services.nginx.virtualHosts."transmission.${config.networking.fqdn}" = {
    forceSSL = true;
    useACMEHost = config.networking.fqdn;
    # listenAddresses = [
    #   "127.0.0.1"
    #   "[::1]"
    #
    #   "192.168.1.2"
    # ];
    extraConfig = ''
      proxy_buffering off;
    '';
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.transmission.settings.rpc-port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;

      extraConfig = ''
        proxy_set_header X-Transmission-Session-Id $http_x_transmission_session_id;
      '';
    };
  };
}
