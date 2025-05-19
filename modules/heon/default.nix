{ config, lib, self, ... }:
with lib;
let
  node = types.submodule {
    options = {
      id = mkOption { type = types.str; };
      key = mkOption { type = types.str; };
      section = mkOption { type = types.int; };
      token = mkOption { type = types.int; };
      endpoint = mkOption { type = types.str; };
    };
  };
in
{
  imports = [
    ./server.nix
    ./client.nix
    ./dns.nix
    ./secrets.nix
  ];
  options.services.heon = {
    clients = mkOption {
      type = types.listOf node;
      default = builtins.fromJSON (builtins.readFile ./clients.json);
    };
    server = mkOption {
      type = node;
      default = {
        id = "herd";
        key = "5tBj2GFA6GTqvPyy883y4bmDH0at3QJ/QIhCi4Gd6FQ=";
        endpoint = "herd.heyi7086.com:51820";
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
            id = k;
            key = vcfg.publicKey;
            section = vcfg.section;
            token = vcfg.token;
            endpoint = "${v.config.networking.fqdn}:${toString vcfg.port}";
          }
        ))
      ];
    };
  };
}
