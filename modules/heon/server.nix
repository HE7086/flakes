{ config, lib, ... }:
with lib;
let
  cfg = config.services.heon.server;
in
{
  options.services.heon.server = {
    enable = mkEnableOption "heon network server";
    port = mkOption {
      type = types.port;
      default = 51820;
    };
    interface = mkOption {
      type = types.str;
      default = "he0";
    };
    privateKeyFile = mkOption {
      type = types.path;
      default = config.sops.secrets."heon/private".path;
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
    };
    clients = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            id = mkOption { type = types.str; };
            key = mkOption { type = types.str; };
            section = mkOption { type = types.int; };
            token = mkOption { type = types.int; };
          };
        }
      );
      default = builtins.fromJSON (builtins.readFile ./heon.json);
    };
  };
  config =
    let
      snat_cidr = net.cidr.make 112 (net.cidr.host (3 * 65536) cfg.ip6.external);
    in
    mkIf cfg.enable {
      networking.firewall.trustedInterfaces = [ cfg.interface ];
      networking.nftables.ruleset = ''
        table ip6 wireguard {
          chain postrouting {
            type nat hook postrouting priority srcnat; policy accept;
            oifname "${cfg.interface}" ip6 daddr ${snat_cidr} ip6 saddr != ${cfg.ip6.internal} snat ip6 to ${cfg.ip6.internal}
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

        peers = map (
          client: with client; {
            name = id;
            publicKey = key;
            allowedIPs = [
              (net.cidr.make 32 (net.cidr.host (section * 256 + token) cfg.ip4.internal))
              (net.cidr.make 128 (net.cidr.host (section * 65536 + token) cfg.ip6.internal))
              (net.cidr.make 128 (net.cidr.host (section * 65536 + token) cfg.ip6.external))
            ];
          }
        ) cfg.clients;
      };
    };
}
