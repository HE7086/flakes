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
    boot.kernel.sysctl = {
      "net.ipv6.conf.default.forwarding" = 1;
      "net.ipv4.conf.default.forwarding" = 1;
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
    # networking.firewall.trustedInterfaces = [ cfgs.interface ];
    networking.firewall.allowedUDPPorts = [ cfgs.port ];
    networking.wireguard.interfaces."${cfgs.interface}" = {
      listenPort = cfgs.port;
      ips = [
        (net.cidr.hostCidr 1 cfg.ip4.internal)
        (net.cidr.hostCidr 1 cfg.ip6.internal)
      ];
      privateKeyFile = cfgs.privateKeyFile;
      peers =
        (map (
          client: with client; {
            name = id;
            publicKey = key;
            allowedIPs = [
              (net.cidr.make 32 (net.cidr.host (section * 256 + token) cfg.ip4.internal))
              (net.cidr.make 128 (net.cidr.host (section * 65536 + token) cfg.ip6.internal))
              (net.cidr.make 128 (net.cidr.host (section * 65536 + token) cfg.ip6.external))
            ];
          }
        ) (filter (c: !elem c.section (map (m: m.section) cfg.members)) cfg.clients))
        ++ (map (
          member: with member; {
            name = id;
            publicKey = key;
            endpoint = endpoint;
            allowedIPs = [
              (net.cidr.make 24 (net.cidr.host (section * 256) cfg.ip4.internal))
              (net.cidr.make 112 (net.cidr.host (section * 65536) cfg.ip6.internal))
              (net.cidr.make 112 (net.cidr.host (section * 65536 + token) cfg.ip6.external))
            ];
            persistentKeepalive = 25;
          }
        ) cfg.members);
    };

    networking.nftables.ruleset =
      let
        snat_cidr = net.cidr.make 112 (net.cidr.host (1 * 65536) cfg.ip6.external);
      in
      ''
        table ip6 wireguard {
          chain postrouting {
            type nat hook postrouting priority srcnat; policy accept;
            oifname "${cfgs.interface}" ip6 daddr ${snat_cidr} ip6 saddr != ${cfg.ip6.internal} snat ip6 to ${cfg.ip6.internal}
          }
        }
      '';
    networking.nat = {
      enable = true;
      externalInterface = cfgs.externalInterface;
      externalIP = net.cidr.ip cfg.ip4.external;
      internalInterfaces = [ cfgs.interface ];
      internalIPs = [ cfg.ip4.internal ];
    };
  };
}
