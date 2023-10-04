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
      default = "";
    };
    package = mkOption {
      type = types.package;
      default = pkgs.rathole;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.rathole = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "rathole Daemon";

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = "5s";
        LimitNOFILE = 1048576;
        ExecStart = "${lib.getBin cfg.package}/bin/rathole ${if cfg.role != "" then "--" + cfg.role else "" } ${cfg.configFile}";
      };
    };
  };
}
