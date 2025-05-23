{
  config,
  lib,
  self,
  ...
}:
with lib;
let
  node = types.submodule {
    options = {
      name = mkOption { type = types.str; };
      publicKey = mkOption { type = types.str; };
      section = mkOption { type = types.int; };
      token = mkOption { type = types.int; };
      endpoint = mkOption { type = types.str; };
      allowedIPs = mkOption { type = types.listOf types.str; };
    };
  };
  cfg = config.services.heon;
  genIP = section: token: [
    (net.cidr.hostCidr token (net.cidr.subnet 8 section cfg.ip4.internal))
    (net.cidr.hostCidr token (net.cidr.subnet 16 section cfg.ip6.internal))
    (net.cidr.hostCidr token (net.cidr.subnet 16 section cfg.ip6.external))
  ];
in
{
  imports = [
    ./server.nix
    ./client.nix
    ./dns.nix
    ./secrets.nix
  ];
  options.services.heon = {
    ip4 = {
      external = mkOption {
        type = types.net.cidrv4;
        default = "91.107.230.166/32";
      };
      internal = mkOption {
        type = types.net.cidrv4;
        default = "10.1.0.0/16";
      };
    };
    ip6 = {
      internal = mkOption {
        type = types.net.cidrv6;
        default = "fd00:4845:7086::/48";
      };
      external = mkOption {
        type = types.net.cidrv6;
        default = "2a01:4f8:c0c:1be5::/64";
      };
    };
    clients = mkOption {
      type = types.listOf node;
      default = map (
        c: with c; {
          inherit
            name
            publicKey
            section
            token
            endpoint
            ;
          allowedIPs = pipe (genIP section token) [
            (map (net.cidr.ip))
            (map (net.cidr.make 128))
          ];
        }
      ) (builtins.fromJSON (builtins.readFile ./clients.json));
    };
    serverNode = mkOption {
      type = node;
      default = {
        name = "herd";
        publicKey = "5tBj2GFA6GTqvPyy883y4bmDH0at3QJ/QIhCi4Gd6FQ=";
        section = 0;
        token = 1;
        endpoint = "herd.heyi7086.com:51820";
        allowedIPs = [
          (net.cidr.hostCidr 1 cfg.ip4.internal)
          (net.cidr.hostCidr 1 cfg.ip6.internal)
        ];
      };
    };
    members = mkOption {
      type = types.listOf node;
      default = pipe self.nixosConfigurations [
        (filterAttrs (k: _: k != config.networking.hostName))
        (filterAttrs (_: v: v.config.services.heon.client.enable))
        (filterAttrs (_: v: hasAttr "heon" v.config.services))
        (mapAttrsToList (
          k: v:
          let
            vcfg = v.config.services.heon.client;
          in
          {
            name = k;
            inherit (vcfg) publicKey section token;
            endpoint = "${v.config.networking.fqdn}:${toString vcfg.port}";
            allowedIPs = genIP vcfg.section vcfg.token;
          }
        ))
      ];
    };
  };
}
