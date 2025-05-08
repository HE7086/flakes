{ config, pkgs, ... }:
let
  domain = "dash.heyi7086.com";
in
{
  imports = [
    ./secrets.nix
  ];
  services.grafana = {
    enable = true;
    settings = {
      server = {
        enforce_domain = true;
        domain = domain;
      };
      security = {
        admin_password = "$__file{${config.sops.secrets.grafana_admin_password.path}}";
      };
    };
  };
  services.loki = {
    enable = true;
    configFile = (pkgs.formats.yaml {}).generate "loki-config.yaml" {
      server = {
        http_listen_port = 3100;
      };
    };
  };

  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = with config.services.grafana.settings.server; "http://${http_addr}:${toString http_port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
