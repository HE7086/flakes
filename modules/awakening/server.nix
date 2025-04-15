{ config, lib, ... }:
with lib;
let
  cfg = config.services.awakening.server;
in
{
  imports = [ ./secrets.nix ];
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
    networking.wireguard.enable = true;
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
