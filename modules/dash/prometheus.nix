{ config, ... }:
{
  services.prometheus = {
    enable = true;
    webExternalUrl = "https://prometheus.heyi7086.com";
    extraFlags = [ "--web.enable-remote-write-receiver" ];
  };
  services.grafana.provision.datasources.settings.datasources = [
    {
      name = "prometheus";
      type = "prometheus";
      url = "http://localhost:${toString config.services.prometheus.port}";
    }
  ];
  services.nginx.virtualHosts."prometheus.heyi7086.com" = {
    forceSSL = true;
    enableACME = true;
    basicAuthFile = config.sops.secrets.nginx_auth.path;

    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.prometheus.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
