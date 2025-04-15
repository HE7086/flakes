{ rootPath, ... }:
{
  sops.secrets."server/private" = {
    sopsFile = rootPath + /secrets/awakening.yaml;
    restartUnits = [ "wireguard-wg0.service" ];
  };
}
