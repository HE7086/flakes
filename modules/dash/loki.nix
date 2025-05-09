{ config, ... }:
{
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server.http_listen_port = 3100;
      common = {
        ring = {
          instance_addr = "localhost";
          kvstore.store = "inmemory";
        };
        replication_factor = 1;
        path_prefix = "/tmp/loki";
      };
      schema_config.configs = [
        {
          from = "2025-05-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];
      storage_config.filesystem.directory = "/tmp/loki/chunks";
    };
  };
  services.nginx.virtualHosts."loki.heyi7086.com" = {
    forceSSL = true;
    enableACME = true;
    basicAuthFile = config.sops.secrets.nginx_auth.path;

    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.loki.configuration.server.http_listen_port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
