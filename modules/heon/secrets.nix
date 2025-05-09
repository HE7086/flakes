{ config, rootPath, ... }:
{
  sops.secrets."heon/private" = {
    sopsFile = rootPath + /secrets/${config.networking.hostName}.yaml;
    restartUnits = [ "wireguard-he0.service" ];
  };
}
