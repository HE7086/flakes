{ pkgs, ... }: {
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    openRPCPort = true;
    openFirewall = true;
    settings = {
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist = "127.0.0.1,192.168.1.*";

      download-dir = "/share/Downloads";
      incomplete-dir = "/share/Downloads/Incomplete";
      watch-dir-enabled = true;
      watch-dir = "/share/Downloads/Torrent";
    };
  };
  users.users.transmission.extraGroups = [ "shared-storage" ];
}
