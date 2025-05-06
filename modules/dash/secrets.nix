{ rootPath, ... }:
{
  sops.secrets.grafana_admin_password = {
    owner = "grafana";
    mode = "0400";
    sopsFile = rootPath + /secrets/secrets.yaml;
    restartUnits = [ "grafana.service" ];
  };
}
