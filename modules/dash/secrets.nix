{ rootPath, ... }:
{
  sops.secrets.grafana_admin_password = {
    owner = "grafana";
    mode = "0400";
    sopsFile = rootPath + /secrets/secrets.yaml;
    restartUnits = [ "grafana.service" ];
  };
  sops.secrets.nginx_auth = {
    owner = "nginx";
    mode = "0400";
    sopsFile = rootPath + /secrets/secrets.yaml;
    restartUnits = [ "nginx.service" ];
  };
  sops.secrets.contact_points = {
    owner = "grafana";
    mode = "0400";
    sopsFile = rootPath + /secrets/secrets.yaml;
    restartUnits = [ "grafana.service" ];
  };
}
