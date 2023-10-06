{ disks, modulesPath, lib, sops-nix, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (import ../modules/filesystems/btrfs-bios-gpt-disk.nix "/dev/sda")
    ../modules/ssh-host-key.nix
    ../modules/ddns.nix
    ../modules/swap.nix
    ../modules/rathole.nix
  ];
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];

  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "ens3";
    networkConfig.DHCP = "ipv4";
    address = [
      "2a01:4f8:c0c:1be5::1/64"
    ];
    routes = [
      { routeConfig.Gateway = "fe80::1"; }
    ];
  };
  networking = {
    hostName = "herd";
    domain = "heyi7086.com";
  };

  services.rathole = {
    enable = true;
    role = "server";
  };
}
