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
    };
    routeTable = mkOption {
      type = types.str;
      default = "7086";
    };
    publicKey = mkOption {
      type = types.str;
      default = "5tBj2GFA6GTqvPyy883y4bmDH0at3QJ/QIhCi4Gd6FQ=";
    };
    endpoint = mkOption {
      type = types.str;
      default = "herd.heyi7086.com:51820";
    };
    peer_name = mkOption {
      type = types.str;
      default = "herd";
    };

  };
  config =
    let
      gateway = net.cidr.host 1 cfg.ip6.internal;
    in
    mkIf cfg.enable {
      networking.wireguard.interfaces."${cfg.interface}" = {
        ips = [
          cfg.ip4.internal
          cfg.ip6.internal
          cfg.ip6.external
        ];

        privateKeyFile = cfg.privateKeyFile;

        postSetup = ''
          ${pkgs.iproute2}/bin/ip -6 rule add from ${cfg.ip6.external} lookup ${cfg.routeTable} priority 100
          ${pkgs.iproute2}/bin/ip -6 route add default via ${gateway} dev ${cfg.interface} table ${cfg.routeTable}
          ${pkgs.iproute2}/bin/ip -6 route add ${gateway}/128 dev ${cfg.interface}
        '';
        preShutdown = ''
          ${pkgs.iproute2}/bin/ip -6 rule del from ${cfg.ip6.external} lookup ${cfg.routeTable} priority 100
          ${pkgs.iproute2}/bin/ip -6 route flush table ${cfg.routeTable}
          ${pkgs.iproute2}/bin/ip -6 route del ${gateway}/128 dev ${cfg.interface}
        '';

        allowedIPsAsRoutes = false;
        peers = [
          {
            name = cfg.peer_name;
            publicKey = cfg.publicKey;
            endpoint = cfg.endpoint;
            allowedIPs = [
              (toString (net.cidr.canonicalize cfg.ip4.internal))
              (toString (net.cidr.canonicalize cfg.ip6.internal))
              "::/0"
            ];
            persistentKeepalive = 30;
          }
        ];
      };
    };
}
