{
  config,
  lib,
  self,
  ...
}:
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
    externalInterface = mkOption {
      type = types.str;
      default = "ens3";
    };
    privateKeyFile = mkOption {
      type = types.path;
      default = config.sops.secrets."heon/private".path;
    };
    ip4 = {
      internal = mkOption {
        type = types.str;
        default = "10.1.0.1/16";
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
      default = builtins.fromJSON (builtins.readFile ./clients.json);
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
      default = (mapAttrsToList
          (k: v:
          let
            vcfg = v.config.services.heon.client;
          in
          {
            id = k;
            key = vcfg.publicKey;
            section = vcfg.section;
            token = vcfg.token;

            endpoint = "${v.config.networking.hostName}.${v.config.networking.domain}:${toString vcfg.port}";
          })
          (
            filterAttrs (
              _: v: (hasAttr "heon" v.config.services) && v.config.services.heon.client.enable
            ) self.nixosConfigurations
          )
        );
    };
  };
  config = mkIf cfg.enable {
    boot.kernel.sysctl = {
      "net.ipv6.conf.default.forwarding" = 1;
      "net.ipv4.conf.default.forwarding" = 1;
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
    networking.firewall.trustedInterfaces = [ cfg.interface ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];
    networking.wireguard.interfaces."${cfg.interface}" = {
      listenPort = cfg.port;
      ips = [
        cfg.ip4.internal
        cfg.ip6.internal
      ];
      privateKeyFile = cfg.privateKeyFile;
      peers = (map (
        client: with client; {
          name = id;
          publicKey = key;
          allowedIPs = [
            (net.cidr.make 32 (net.cidr.host (section * 256 + token) cfg.ip4.internal))
            (net.cidr.make 128 (net.cidr.host (section * 65536 + token) cfg.ip6.internal))
            (net.cidr.make 128 (net.cidr.host (section * 65536 + token) cfg.ip6.external))
          ];
        }
      ) cfg.clients)
      ++ (map (
        member: with member; {
          name = id;
          publicKey = key;
          endpoint = endpoint;
          allowedIPs = [
            (net.cidr.make 24 (net.cidr.host (section * 256) cfg.ip4.internal))
            (net.cidr.make 112 (net.cidr.host (section * 65536) cfg.ip6.internal))
            (net.cidr.make 112 (net.cidr.host (section * 65536) cfg.ip6.external))
          ];
        }
      ) cfg.members);
    };

    networking.nftables.ruleset =
      let
        snat_cidr = net.cidr.make 112 (net.cidr.host (3 * 65536) cfg.ip6.external);
      in
      ''
        table ip6 wireguard {
          chain postrouting {
            type nat hook postrouting priority srcnat; policy accept;
            oifname "${cfg.interface}" ip6 daddr ${snat_cidr} ip6 saddr != ${cfg.ip6.internal} snat ip6 to ${cfg.ip6.internal}
          }
        }
      '';
    networking.nat = {
      enable = true;
      externalInterface = cfg.externalInterface;
      externalIP = net.cidr.ip cfg.ip4.external;
      internalInterfaces = [ cfg.interface ];
      internalIPs = [ cfg.ip4.internal ];
    };
  };
}
