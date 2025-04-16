{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  version = "2.0.86";
  system = pkgs.system;
in
mkMerge [
  (mkIf config.boot.loader.systemd-boot.enable {
    boot.loader.systemd-boot = {
      extraFiles = mkMerge [
        (mkIf (system == "x86_64-linux") {
          "efi/netbootxyz/netboot.xyz.efi" = pkgs.fetchurl {
            url = "https://github.com/netbootxyz/netboot.xyz/releases/download/${version}/netboot.xyz.efi";
            hash = "sha256-D0UnGL0H+zua5fJAoBbfEyU4ZdjQXf6LeQ+475oVKow=";
          };
        })
        (mkIf (system == "aarch64-linux") {
          "efi/netbootxyz/netboot.xyz.efi" = pkgs.fetchurl {
            url = "https://github.com/netbootxyz/netboot.xyz/releases/download/${version}/netboot.xyz-arm64.efi";
            hash = "sha256-H3zrvh6HguL7Gl5WLGE+XSjpKtrzddMquk9orW/59no=";
          };
        })
      ];
      # nix store prefetch-file "https://github.com/netbootxyz/netboot.xyz/releases/download/${version}/netboot.xyz.efi"
      extraEntries = {
        "netbootxyz.conf" = ''
          title netboot.xyz
          efi /efi/netbootxyz/netboot.xyz.efi
          sort-key o_netbootxyz
        '';
      };
    };
  })

  # only use grub when uefi is not available
  (mkIf config.boot.loader.grub.enable {
    boot.loader.grub = {
      extraFiles = {
        "netboot.xyz.iso" = pkgs.fetchurl {
          url = "https://github.com/netbootxyz/netboot.xyz/releases/download/${version}/netboot.xyz-multiarch.iso";
          hash = "sha256-HbEy/b6lGQ8M11kWMhttsKSyPvnBjSNJAuA/Cnu9FZ8=";
        };
      };
      # extraEntries = {};
    };
  })
]
