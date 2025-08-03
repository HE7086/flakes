{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.prometheus.exporters.wireguard;
in
{
  services.prometheus.exporters.wireguard =
    mkIf (config.networking.wireguard.enable || config.networking.wg-quick.interfaces != { })
      {
        enable = true;
        withRemoteIp = true;
        singleSubnetPerField = true;
        extraFlags = [ "-d true" ];
      };
  services.alloy.settings = with config.services.prometheus.exporters.wireguard; {
    "prometheus.scrape".wireguard = {
      targets = [
        ''{"__address__" = "localhost:${toString port}", "job" = "wireguard", "instance" = "${config.networking.hostName}"}''
      ];
      forward_to = [ "prometheus.remote_write.default.receiver" ];
    };
  };

  systemd.services.prometheus-wireguard-exporter = {
    serviceConfig.ExecStart = mkForce ''
      ${pkgs.prometheus-wireguard-exporter}/bin/prometheus_wireguard_exporter \
      -p ${toString cfg.port} \
      -l ${cfg.listenAddress} \
      ${optionalString cfg.verbose "-v true"} \
      ${optionalString cfg.singleSubnetPerField "-s true"} \
      ${optionalString cfg.withRemoteIp "-r true"} \
      ${optionalString (cfg.wireguardConfig != null) "-n ${escapeShellArg cfg.wireguardConfig}"} \
      ${optionalString (cfg.extraFlags != [ ]) (concatStringsSep " " cfg.extraFlags)}
    '';
  };
}
