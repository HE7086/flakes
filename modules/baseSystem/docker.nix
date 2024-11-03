{ config, lib, ... }:
lib.mkIf config.virtualisation.docker.enable {
  virtualisation.docker = {
    storageDriver = "btrfs";
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  users.users.he.extraGroups = [ "docker" ];
}
