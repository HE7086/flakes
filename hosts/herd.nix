{ disks, modulesPath, lib, sops-nix, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (import ../modules/bios-btrfs-gpt-disk.nix "/dev/sda")
    ../modules/ssh-host-key.nix
  ];
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 4 * 1024;
    }
  ];

  networking = {
    hostName = "herd";
    domain = "heyi7086.com";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    defaultGateway = "172.31.1.1";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
    dhcpcd.enable = false;
    interfaces = {
      ens3 = {
        ipv4 = {
          addresses = [{ address = "91.107.230.166"; prefixLength = 32; }];
          routes = [{ address = "172.31.1.1"; prefixLength = 32; }];
        };
        ipv6 = {
          addresses = [
            { address = "2a01:4f8:c0c:1be5::1"; prefixLength = 64; }
            { address = "fe80::9400:2ff:fe6d:8f82"; prefixLength = 64; }
          ];
          routes = [{ address = "fe80::1"; prefixLength = 128; }];
        };
      };
    };
  };
}
