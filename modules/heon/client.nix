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
      ip6_forward = net.cidr.make 112 (net.cidr.host (cfgc.section * 65536) cfg.ip6.external);
      ip = "${pkgs.iproute2}/bin/ip";
      rc = "${pkgs.systemd}/bin/resolvectl";
    in
    mkIf cfgc.enable {
      # networking.firewall.trustedInterfaces = [ cfgc.interface ];
      networking.firewall.extraInputRules = ''
        ip saddr ${cfg.ip4.internal} accept
        ip6 saddr ${cfg.ip6.internal} accept
      '';
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
          ${ip} -6 route add ${ip6_forward} dev ${cfgc.interface}
          ${ip} -6 rule add from ${ip6_forward} lookup ${cfgc.routeTable} priority 100
          ${ip} -6 route add default via ${gateway} dev ${cfgc.interface} table ${cfgc.routeTable}
          ${ip} -6 route add ${gateway}/128 dev ${cfgc.interface}
          ${rc} dns ${cfgc.interface} ${gateway}
          ${rc} domain ${cfgc.interface} ~l ~r
        '';
        preShutdown = ''
          ${ip} -6 route del ${ip6_forward} dev ${cfgc.interface}
          ${ip} -6 rule del from ${ip6_forward} lookup ${cfgc.routeTable} priority 100
          ${ip} -6 route flush table ${cfgc.routeTable}
          ${ip} -6 route del ${gateway}/128 dev ${cfgc.interface}
          ${rc} revert ${cfgc.interface}
        '';

        allowedIPsAsRoutes = false;
        # table = "off";
        # dns = [ gateway ];

        peers =
          [
            {
              inherit (cfg.serverNode) name publicKey endpoint;
              allowedIPs = (map (net.cidr.canonicalize) cfg.server.allowedIPs) ++ [ "::/0" ];
              persistentKeepalive = 25;
            }
          ]
          ++ map (
            member: with member; {
              inherit name publicKey endpoint;
              allowedIPs = map (net.cidr.canonicalize) (sublist 0 2 allowedIPs);
              persistentKeepalive = 25;
            }
          ) cfg.members
          ++ (map (
            client: with client; {
              inherit name publicKey allowedIPs;
            }
          ) (filter (client: client.section == cfgc.section) cfg.clients));
      };
    };
}
