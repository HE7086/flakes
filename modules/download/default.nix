{ pkgs, ... }:
{
  imports = [ ./transmission.nix ];

  environment.systemPackages = [ pkgs.megacmd ];

  systemd.tmpfiles.rules = [
    "d /share/Downloads            775 shared-storage shared-storage"
    "d /share/Downloads/Incomplete 775 shared-storage shared-storage"
    "d /share/Downloads/Torrent    775 shared-storage shared-storage"
  ];
}
