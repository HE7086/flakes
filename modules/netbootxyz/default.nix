{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.loader.systemd-boot.netbootxyz.enable = config.boot.loader.systemd-boot.enable;
}
// lib.mkIf config.boot.loader.grub.enable {
  boot.loader.grub = {
    extraFiles = {
      "netboot.xyz.iso" = pkgs.fetchurl {
        url = "https://github.com/netbootxyz/netboot.xyz/releases/download/2.0.86/netboot.xyz-multiarch.iso";
        hash = "sha256-HbEy/b6lGQ8M11kWMhttsKSyPvnBjSNJAuA/Cnu9FZ8=";
      };
    };
    # extraEntries = {};
  };
}
