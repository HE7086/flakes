{ rootPath, ... }:
{
  sops.secrets."server/private" = {
    sopsFile = rootPath + /secrets/wireguard.yaml;
    restartUnits = [ "wireguard-wg0.service" ];
  };
}
