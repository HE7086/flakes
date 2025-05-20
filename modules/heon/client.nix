{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.heon;
  cfgc = config.services.heon.client;
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
    routeTable = mkOption {
      type = types.str;
      default = "7086";
    };
    section = mkOption {
      type = types.int;
      default = 0;
    };
    token = mkOption {
      type = types.int;
      default = 0;
    };
    externalInterface = mkOption {
      type = types.str;
      default = "ens3";
    };
  };
  config =
    let
      gateway = net.cidr.host 1 cfg.ip6.internal;
      ip4_int = net.cidr.hostCidr (cfgc.section * 256 + cfgc.token) cfg.ip4.internal;
      ip6_int = net.cidr.hostCidr (cfgc.section * 65536 + cfgc.token) cfg.ip6.internal;
      ip6_ext = net.cidr.make 128 (net.cidr.host (cfgc.section * 65536 + cfgc.token) cfg.ip6.external);
    in
    mkIf cfgc.enable {
      boot.kernel.sysctl = {
        "net.ipv6.conf.default.forwarding" = 1;
        "net.ipv4.conf.default.forwarding" = 1;
        "net.ipv4.conf.all.forwarding" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
      };
      networking.firewall.trustedInterfaces = [ cfgc.interface ];
      networking.firewall.allowedUDPPorts = [ cfgc.port ];
      networking.wireguard.interfaces."${cfgc.interface}" = {
        listenPort = cfgc.port;
        ips = [
          ip4_int
          ip6_int
          ip6_ext
        ];

        privateKeyFile = cfgc.privateKeyFile;

        postSetup = ''
          ${pkgs.iproute2}/bin/ip -6 rule add from ${ip6_ext} lookup ${cfgc.routeTable} priority 100
          ${pkgs.iproute2}/bin/ip -6 route add default via ${gateway} dev ${cfgc.interface} table ${cfgc.routeTable}
          ${pkgs.iproute2}/bin/ip -6 route add ${gateway}/128 dev ${cfgc.interface}
          ${pkgs.systemd}/bin/resolvectl dns ${cfgc.interface} ${gateway}
          ${pkgs.systemd}/bin/resolvectl domain ${cfgc.interface} ~l ~r
        '';
        preShutdown = ''
          ${pkgs.iproute2}/bin/ip -6 rule del from ${ip6_ext} lookup ${cfgc.routeTable} priority 100
          ${pkgs.iproute2}/bin/ip -6 route flush table ${cfgc.routeTable}
          ${pkgs.iproute2}/bin/ip -6 route del ${gateway}/128 dev ${cfgc.interface}
          ${pkgs.systemd}/bin/resolvectl revert ${cfgc.interface}
        '';

        allowedIPsAsRoutes = false;
        # table = "off";
        # dns = [ gateway ];

        peers =
          [
            {
              name = "server";
              publicKey = cfg.server.key;
              endpoint = cfg.server.endpoint;
              allowedIPs = [
                (toString cfg.ip4.internal)
                (toString cfg.ip6.internal)
                # "::/0"
              ];
              persistentKeepalive = 30;
            }
          ]
          ++ map (
            member: with member; {
              name = id;
              publicKey = key;
              endpoint = endpoint;
              allowedIPs = [
                (net.cidr.make 24 (net.cidr.host (section * 256) cfg.ip4.internal))
                (net.cidr.make 112 (net.cidr.host (section * 65536) cfg.ip6.internal))
              ];
            }
          ) cfg.members
          ++ (map (
            client: with client; {
              name = id;
              publicKey = key;
              allowedIPs = [
                (net.cidr.make 32 (net.cidr.host (section * 256 + token) cfg.ip4.internal))
                (net.cidr.make 128 (net.cidr.host (section * 65536 + token) cfg.ip6.internal))
              ];
            }
          ) (filter (client: client.section == cfgc.section) cfg.clients));
      };
    };
}
