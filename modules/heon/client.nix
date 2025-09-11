{
  config,
  lib,
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
  };
  config =
    let
      gateway = net.cidr.host 1 cfg.ip6.internal;
      ip6_forward = net.cidr.subnet 16 cfgc.section cfg.ip6.external;
      f_subnet4 = net.cidr.subnet 8 255 cfg.ip4.internal;
      f_subnet6 = net.cidr.subnet 16 65535 cfg.ip6.internal;
    in
    mkIf cfgc.enable {
      # networking.firewall.trustedInterfaces = [ cfgc.interface ];
      networking.firewall.extraInputRules = ''
        ip saddr ${cfg.ip4.internal} accept
        ip6 saddr ${cfg.ip6.internal} accept
        ip6 saddr ${cfg.ip6.external} accept
      '';
      networking.firewall.allowedUDPPorts = [ cfgc.port ];
      networking.wireguard.interfaces."${cfgc.interface}" = {
        listenPort = cfgc.port;
        # TODO: simplify this
        ips = with net.cidr; [
          (
            (host cfgc.token (subnet 8 cfgc.section cfg.ip4.internal))
            + "/${toString (length cfg.ip4.internal)}"
          )
          (
            (host cfgc.token (subnet 16 cfgc.section cfg.ip6.internal))
            + "/${toString (length cfg.ip6.internal)}"
          )
          ((host cfgc.token (subnet 16 cfgc.section cfg.ip6.external)) + "/128")
        ];
        privateKeyFile = cfgc.privateKeyFile;
        allowedIPsAsRoutes = false;
        # table = "off";
        # dns = [ gateway ];

        peers = [
          {
            inherit (cfg.serverNode) name publicKey endpoint;
            allowedIPs = (map (net.cidr.canonicalize) cfg.serverNode.allowedIPs) ++ [ "::/0" ];
            persistentKeepalive = 25;
          }
        ]
        ++ map (member: {
          inherit (member) name publicKey endpoint;
          allowedIPs = map (net.cidr.canonicalize) (sublist 0 2 member.allowedIPs);
          persistentKeepalive = 25;
        }) cfg.members
        ++ (map (client: {
          inherit (client) name publicKey allowedIPs;
        }) (filter (client: client.section == cfgc.section) cfg.clients))
        # floating clients
        ++ (map (client: {
          inherit (client) name publicKey;
          allowedIPs = with client; [
            (net.cidr.make 32 (net.cidr.host token f_subnet4))
            (net.cidr.make 128 (net.cidr.host token f_subnet6))
          ];
        }) (filter (client: client.section == 1) cfg.clients));
      };
      systemd.network.networks.${cfgc.interface} = {
        routes = [
          {
            Destination = ip6_forward;
          }
          {
            Destination = net.cidr.make 128 gateway;
          }
          {
            Destination = "::/0";
            Gateway = gateway;
            Table = cfgc.routeTable;
          }
        ];
        routingPolicyRules = [
          {
            From = ip6_forward;
            Table = cfgc.routeTable;
          }
        ];
        dns = [ gateway ];
        domains = [
          "~l"
          "~r"
        ];
        networkConfig = {
          DNSOverTLS = "no";
          DNSSEC = "no";
        };
      };
      networking.nat = {
        enable = true;
        enableIPv6 = true;
        internalIPs = [ f_subnet4 ];
        internalIPv6s = [ f_subnet6 ];
      };
    };
}
