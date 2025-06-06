{ rootPath, ... }:
{
  sops.secrets.alloy_auth = {
    sopsFile = rootPath + /secrets/secrets.yaml;
    restartUnits = [ "alloy.service" ];
  };
  sops.secrets.maxmind_key = {
    sopsFile = rootPath + /secrets/secrets.yaml;
    restartUnits = [ "geoipupdate.service" ];
  };
}
