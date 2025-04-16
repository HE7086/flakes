{ config, rootPath, ... }:
{
  sops.secrets."awakening/private" = {
    sopsFile = rootPath + /secrets/${config.networking.hostName}.yaml;
    restartUnits = [ "wireguard-wg0.service" ];
  };
}
