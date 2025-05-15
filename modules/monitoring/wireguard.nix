{ config, lib, ... }:
{
  services.prometheus.exporters.wireguard =
    lib.mkIf (config.networking.wireguard.enable || config.networking.wg-quick.interfaces != {})
      {
        enable = true;
        withRemoteIp = true;
        singleSubnetPerField = true;
      };
  services.alloy.extraConfigs = with config.services.prometheus.exporters.wireguard; [
    ''
      prometheus.scrape "wireguard" {
        targets = [
          {"__address__" = "localhost:${toString port}", "job" = "wireguard", "instance" = "${config.networking.hostName}"},
        ]
        forward_to = [prometheus.remote_write.default.receiver]
      }
    ''
  ];
}
