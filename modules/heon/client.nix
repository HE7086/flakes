{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.heon.client;
in
{
  options.services.heon.client = {
    enable = mkEnableOption "heon network client";
    interface = mkOption {
      type = types.str;
      default = "he0";
    };
    privateKeyFile = mkOption {
      type = types.path;
      default = config.sops.secrets."heon/private".path;
    };
    publicKey = mkOption {
      type = types.str;
      default = null;
    };
    ip4.internal = mkOption {
      type = types.net.cidrv4;
      default = "10.1.0.0/16";
    };
    ip6 = {
      internal = mkOption {
        type = types.net.cidrv6;
        default = "fd00:4845:7086::/64";
      };
      external = mkOption {
        type = types.net.cidrv6;
        default = "2a01:4f8:c0c:1be5::/64";
      };
    };
    routeTable = mkOption {
      type = types.str;
      default = "7086";
    };
    peer_publicKey = mkOption {
      type = types.str;
      default = "5tBj2GFA6GTqvPyy883y4bmDH0at3QJ/QIhCi4Gd6FQ=";
    };
    endpoint = mkOption {
      type = types.str;
      default = "herd.heyi7086.com:51820";
    };
    section = mkOption {
      type = types.int;
      default = 0;
    };
    token = mkOption {
      type = types.int;
      default = 0;
    };
  };
  config =
    let
      gateway = net.cidr.host 1 cfg.ip6.internal;
      ip4_int = net.cidr.hostCidr (cfg.section * 256 + cfg.token) cfg.ip4.internal;
      ip6_int = net.cidr.hostCidr (cfg.section * 65536 + cfg.token) cfg.ip6.internal;
      ip6_ext = net.cidr.make 128 (net.cidr.host (cfg.section * 65536 + cfg.token) cfg.ip6.external);
    in
    mkIf cfg.enable {
      networking.firewall.trustedInterfaces = [ cfg.interface ];
      networking.wg-quick.interfaces."${cfg.interface}" = {
        address = [
          ip4_int
          ip6_int
          ip6_ext
        ];

        privateKeyFile = cfg.privateKeyFile;

        postUp = ''
          ${pkgs.iproute2}/bin/ip -6 rule add from ${ip6_ext} lookup ${cfg.routeTable} priority 100
          ${pkgs.iproute2}/bin/ip -6 route add default via ${gateway} dev ${cfg.interface} table ${cfg.routeTable}
          ${pkgs.iproute2}/bin/ip -6 route add ${gateway}/128 dev ${cfg.interface}
        '';
        preDown = ''
          ${pkgs.iproute2}/bin/ip -6 rule del from ${ip6_ext} lookup ${cfg.routeTable} priority 100
          ${pkgs.iproute2}/bin/ip -6 route flush table ${cfg.routeTable}
          ${pkgs.iproute2}/bin/ip -6 route del ${gateway}/128 dev ${cfg.interface}
        '';

        table = "off";
        dns = [
          (toString (net.cidr.host 1 (net.cidr.canonicalize cfg.ip6.internal)))
        ];

        peers = [
          {
            publicKey = cfg.peer_publicKey;
            endpoint = cfg.endpoint;
            allowedIPs = [
              (toString cfg.ip4.internal)
              (toString cfg.ip6.internal)
              "::/0"
            ];
            persistentKeepalive = 30;
          }
        ];
      };
    };
}
