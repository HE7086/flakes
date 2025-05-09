{ rootPath, ... }:
{
  sops.secrets.alloy_auth = {
    sopsFile = rootPath + /secrets/secrets.yaml;
    restartUnits = [ "alloy.service" ];
  };
}
