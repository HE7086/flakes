{
  config,
  lib,
  ...
}:
with lib;
let
  cfgs = config.services.heon.server;
  cfg = config.services.heon;
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
    externalInterface = mkOption {
      type = types.str;
      default = "ens3";
    };
    privateKeyFile = mkOption {
      type = types.path;
      default = config.sops.secrets."heon/private".path;
    };
  };
  config = mkIf cfgs.enable {
    networking.wireguard.interfaces."${cfgs.interface}" = {
      listenPort = cfgs.port;
      ips = cfg.serverNode.allowedIPs;
      privateKeyFile = cfgs.privateKeyFile;
      peers =
        (map (client: {
          inherit (client) name publicKey allowedIPs;
        }) (filter (c: !elem c.section (map (m: m.section) cfg.members)) cfg.clients))
        ++ (map (member: {
          inherit (member) name publicKey endpoint;
          allowedIPs = map (net.cidr.canonicalize) member.allowedIPs;
          persistentKeepalive = 25;
        }) cfg.members);
    };

    # networking.firewall.trustedInterfaces = [ cfgs.interface ];
    networking.firewall.allowedUDPPorts = [ cfgs.port ];
    networking.firewall.extraInputRules = ''
      ip saddr ${cfg.ip4.internal} accept
      ip6 saddr ${cfg.ip6.internal} accept
    '';
    networking.nftables.tables.wireguard = {
      family = "ip6";
      content =
        let
          snat_cidr = net.cidr.subnet 16 1 cfg.ip6.external;
        in
        ''
          chain postrouting {
            type nat hook postrouting priority srcnat; policy accept;
            oifname "${cfgs.interface}" ip6 daddr ${snat_cidr} ip6 saddr != ${cfg.ip6.internal} snat ip6 to ${cfg.ip6.internal}
          }
        '';
    };

    networking.nat = {
      enable = true;
      externalInterface = cfgs.externalInterface;
      externalIP = net.cidr.ip cfg.ip4.external;
      internalInterfaces = [ cfgs.interface ];
      internalIPs = [ cfg.ip4.internal ];
    };
  };
}
