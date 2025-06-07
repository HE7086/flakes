{ config, ... }:
let
  domain = "dash.heyi7086.com";
in
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        protocol = "socket";
        enforce_domain = true;
        domain = domain;
        root_url = "https://${domain}";
      };
      security = {
        admin_password = "$__file{${config.sops.secrets.grafana_admin_password.path}}";
        cookie_secure = true;
      };
    };
    # https://github.com/grafana/grafana/issues/69950#event-14536420532
    provision.alerting.contactPoints.path = config.sops.secrets.contact_points.path;
  };

  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://unix:${config.services.grafana.settings.server.socket}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

  users.users.nginx.extraGroups = [ "grafana" ];
}
