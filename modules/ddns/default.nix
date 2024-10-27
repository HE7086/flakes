{ config, rootPath, ... }: {
  sops.secrets."cloudflare/token/ddns" = {
    sopsFile = rootPath + /secrets/secrets.yaml;
    restartUnits = [ "cloudflare-dyndns.service" ];
  };

  services.cloudflare-dyndns = {
    enable = true;
    apiTokenFile = config.sops.secrets."cloudflare/token/ddns".path;
    domains = [ "${config.networking.hostName}.${config.networking.domain}" ];
    proxied = false;
    ipv4 = true;
    ipv6 = true;
    deleteMissing = false;
  };

  systemd.timers.cloudflare-dyndns = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };
}
