{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.services.rathole;
in
{
  options.services.rathole = {
    enable = mkEnableOption (mdDoc "rathole");
    role = mkOption {
      type = types.enum [ "server" "client" "" ];
      default = "";
    };
    configFile = mkOption {
      type = types.path;
      default = config.sops.secrets."${config.networking.hostName}/rathole.toml".path;
    };
    package = mkOption {
      type = types.package;
      default = pkgs.rathole;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.rathole = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "sops-nix.service" ];
      description = "rathole Daemon";

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "5s";
        LimitNOFILE = 1048576;
        ExecStart = "${cfg.package}/bin/rathole ${if cfg.role != "" then "--" + cfg.role else "" } ${cfg.configFile}";
      };

    };
    sops.secrets."${config.networking.hostName}/rathole.toml" = { };

    networking.firewall = mkIf (cfg.role == "server") {
      allowedTCPPorts = [ 7086 ];
      allowedTCPPortRanges = [ { from = 16380; to = 16390; } ];
    };
  };

}
