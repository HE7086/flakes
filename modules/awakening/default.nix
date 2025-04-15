{ config, lib, ... }:
with lib;
{
  imports = [
    ./server.nix
    ./client.nix
  ];
  options.services.awakening.server = {
    enable = mkEnableOption "awakening network server";
    port = mkOption {
      type = types.port;
      default = 51820;
    };
    interface = mkOption {
      type = types.str;
      default = "wg0";
    };
    privateKeyFile = mkOption {
      type = types.path;
      default = config.sops.secrets."server/private".path;
    };
    ip4 = {
      internal = mkOption {
        type = types.str;
        default = "10.1.1.1/16";
      };
      external = mkOption {
        type = types.str;
        default = "91.107.230.166/32";
      };
      pool = mkOption {
        type = types.str;
        default = "10.1";
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
      pool = {
        internal = mkOption {
          type = types.str;
          default = "fd00:4845:7086";
        };
        external = mkOption {
          type = types.str;
          default = "2a01:4f8:c0c:1be5";
        };
      };
    };
    clients = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            id = mkOption { type = types.str; };
            key = mkOption { type = types.str; };
            section = mkOption { type = types.str; };
            token = mkOption { type = types.str; };
          };
        }
      );
      default = builtins.fromJSON (builtins.readFile ./awakening.json);
    };
  };
  options.services.awakening.client = {
    enable = mkEnableOption "awakening network client";
  };
}
