{
  config,
  lib,
  pkgs,
  self,
  ...
}:
with lib;
let
  cfg = config.services.heon.client;
in
{
  options.services.heon.client = {
    enable = mkEnableOption "heon network client";
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
    server_publicKey = mkOption {
      type = types.str;
      default = "5tBj2GFA6GTqvPyy883y4bmDH0at3QJ/QIhCi4Gd6FQ=";
    };
    server_endpoint = mkOption {
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
    members = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            id = mkOption { type = types.str; };
            key = mkOption { type = types.str; };
            section = mkOption { type = types.int; };
            token = mkOption { type = types.int; };

            endpoint = mkOption { type = types.str; };
          };
        }
      );
      default =
        pipe self.nixosConfigurations [
          (filterAttrs (k: _: k != config.networking.hostName))
          (filterAttrs (_: v: v.config.services.heon.client.enable))
          (filterAttrs (_: v: hasAttr "heon" v.config.services))
          (mapAttrsToList
            (k: v: let
              vcfg = v.config.services.heon.client;
            in {
              id = k;
              key = vcfg.publicKey;
              section = vcfg.section;
              token = vcfg.token;
              endpoint = "${v.config.networking.hostName}.${v.config.networking.domain}:${toString vcfg.port}";
            })
          )
        ];
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
      networking.firewall.allowedUDPPorts = [ cfg.port ];
      networking.wireguard.interfaces."${cfg.interface}" = {
        listenPort = cfg.port;
        ips = [
          ip4_int
          ip6_int
          ip6_ext
        ];

        privateKeyFile = cfg.privateKeyFile;

        postSetup = ''
          ${pkgs.iproute2}/bin/ip -6 rule add from ${ip6_ext} lookup ${cfg.routeTable} priority 100
          ${pkgs.iproute2}/bin/ip -6 route add default via ${gateway} dev ${cfg.interface} table ${cfg.routeTable}
          ${pkgs.iproute2}/bin/ip -6 route add ${gateway}/128 dev ${cfg.interface}
          ${pkgs.systemd}/bin/resolvectl dns ${cfg.interface} ${gateway}
          ${pkgs.systemd}/bin/resolvectl domain ${cfg.interface} ~l ~r
        '';
        preShutdown = ''
          ${pkgs.iproute2}/bin/ip -6 rule del from ${ip6_ext} lookup ${cfg.routeTable} priority 100
          ${pkgs.iproute2}/bin/ip -6 route flush table ${cfg.routeTable}
          ${pkgs.iproute2}/bin/ip -6 route del ${gateway}/128 dev ${cfg.interface}
          ${pkgs.systemd}/bin/resolvectl revert ${cfg.interface}
        '';

        allowedIPsAsRoutes = false;
        # table = "off";
        # dns = [ gateway ];

        peers = [
          {
            publicKey = cfg.server_publicKey;
            endpoint = cfg.server_endpoint;
            allowedIPs = [
              (toString cfg.ip4.internal)
              (toString cfg.ip6.internal)
              "::/0"
            ];
            persistentKeepalive = 30;
          }
        ] ++ map (member: with member; {
          name = id;
          publicKey = key;
          endpoint = endpoint;
          allowedIPs = [
            (net.cidr.make 24 (net.cidr.host (section * 256) cfg.ip4.internal))
            (net.cidr.make 112 (net.cidr.host (section * 65536) cfg.ip6.internal))
            (net.cidr.make 112 (net.cidr.host (section * 65536) cfg.ip6.external))
          ];
        }) cfg.members;
      };
    };
}
