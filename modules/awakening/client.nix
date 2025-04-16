{ config, lib, ... }:
with lib;
let
  cfg = config.services.awakening.client;
in
{
  imports = [ ./secrets.nix ];
  options.services.awakening.client = {
    enable = mkEnableOption "awakening network client";
    interface = mkOption {
      type = types.str;
      default = "wg0";
    };
    privateKeyFile = mkOption {
      type = types.path;
      default = config.sops.secrets."awakening/private".path;
    };
    ip4.internal = mkOption {
      type = types.str;
      default = "10.1.2.2/16";
    };
    ip6 = {
      internal = mkOption {
        type = types.str;
        default = "fd00:4845:7086::2:2/64";
      };
      external = mkOption {
        type = types.str;
        default = "2a01:4f8:c0c:1be5::2:2/128";
      };
      gateway = mkOption {
        type = types.str;
        default = "fd00:4845:7086::1";
      };
    };
    routeTable = mkOption {
      type = types.str;
      default = "7086";
    };
  };
  config = mkIf cfg.enable {
    networking.wireguard.interfaces."${cfg.interface}" = {
      ips = [
        cfg.ip4.internal
        cfg.ip6.internal
        cfg.ip6.external
      ];

      privateKeyFile = cfg.privateKeyFile;

      postSetup = ''
        ip -6 rule add from ${cfg.ip6.external} lookup ${cfg.routeTable} priority 100
        ip -6 route add default via ${cfg.ip6.gateway} dev ${cfg.interface} table ${cfg.routeTable}
        ip -6 route add ${cfg.ip6.gateway}/128 dev ${cfg.interface}
      '';
      preShutdown = ''
        ip -6 rule del from ${cfg.ip6.external} lookup ${cfg.routeTable} priority 100
        ip -6 route flush table ${cfg.routeTable}
        ip -6 route del ${cfg.ip6.gateway}/128 dev ${cfg.interface}
      '';

      allowedIPsAsRoutes = false;
      peers = [
        {
          name = "herd";
          publicKey = "5tBj2GFA6GTqvPyy883y4bmDH0at3QJ/QIhCi4Gd6FQ=";
          endpoint = "herd.heyi7086.com:51820";
          allowedIPs = [
            "10.1.0.0/16"
            "fd00:4845:7086::/64"
            "::/0"
          ];
        }
      ];
    };
  };
}
