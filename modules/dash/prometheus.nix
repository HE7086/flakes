{ config, ... }:
{
  services.prometheus = {
    enable = true;
    webExternalUrl = "https://prometheus.heyi7086.com";
    extraFlags = [ "--web.enable-remote-write-receiver" ];
  };
  services.nginx.virtualHosts."prometheus.heyi7086.com" = {
    forceSSL = true;
    enableACME = true;
    basicAuthFile = config.sops.secrets.nginx_auth.path;

    locations."/" = {
      proxyPass = with config.services.prometheus; "http://localhost:${toString port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
