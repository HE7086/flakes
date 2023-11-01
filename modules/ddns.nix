{ config, lib, ... }: {
  sops.secrets."cloudflare/token/ddns" = {
    sopsFile = ../secrets/secrets.yaml;
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
    timerConfig = {
      OnBootSec = "10s";
      OnCalendar = lib.mkForce "*-*-* *:00/2:00";
      RandomizedDelaySec = "10m";
    };
  };
}
