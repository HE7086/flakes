{ config, lib, ... }:
with lib;
let
  cfg = config.services.awakening.server;
in
{
  imports = [ ./secrets.nix ];
  options.services.awakening.server = {
    enable = mkEnableOption "awakening network server";
    port = mkOption {
      type = types.port;
      default = 51820;
    };
    interface = mkOption {
      type = types.str;
      default = "wg0";
    };
    privateKeyFile = mkOption {
      type = types.path;
      default = config.sops.secrets."awakening/private".path;
    };
    ip4 = {
      internal = mkOption {
        type = types.str;
        default = "10.1.1.1/16";
      };
      external = mkOption {
        type = types.str;
        default = "91.107.230.166/32";
      };
      pool = mkOption {
        type = types.str;
        default = "10.1";
      };
    };
    ip6 = {
      internal = mkOption {
        type = types.str;
        default = "fd00:4845:7086::1/64";
      };
      external = mkOption {
        type = types.str;
        default = "2a01:4f8:c0c:1be5::1/64";
      };
      pool = {
        internal = mkOption {
          type = types.str;
          default = "fd00:4845:7086";
        };
        external = mkOption {
          type = types.str;
          default = "2a01:4f8:c0c:1be5";
        };
      };
    };
    clients = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            id = mkOption { type = types.str; };
            key = mkOption { type = types.str; };
            section = mkOption { type = types.str; };
            token = mkOption { type = types.str; };
          };
        }
      );
      default = builtins.fromJSON (builtins.readFile ./awakening.json);
    };
  };
  config = mkIf cfg.enable {
    networking.nftables.ruleset = ''
      table ip6 wireguard {
        chain postrouting {
          type nat hook postrouting priority srcnat; policy accept;
          oifname "${cfg.interface}" ip6 daddr ${cfg.ip6.pool.external}::3:0/112 ip6 saddr != ${cfg.ip6.internal} snat ip6 to ${cfg.ip6.internal}
        }
      }
    '';
    boot.kernel.sysctl = {
      "net.ipv6.conf.default.forwarding" = 1;
      "net.ipv4.conf.default.forwarding" = 1;
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
    networking.firewall.allowedUDPPorts = [ cfg.port ];
    networking.wireguard.interfaces."${cfg.interface}" = {
      listenPort = cfg.port;
      ips = [
        cfg.ip4.internal
        cfg.ip6.internal
      ];

      privateKeyFile = cfg.privateKeyFile;

      peers = map (client: {
        name = client.id;
        publicKey = client.key;
        allowedIPs = [
          "${cfg.ip4.pool}.${client.section}.${client.token}/32"
          "${cfg.ip6.pool.internal}::${client.section}:${client.token}/128"
          "${cfg.ip6.pool.external}::${client.section}:${client.token}/128"
        ];
      }) cfg.clients;
    };
  };
}
