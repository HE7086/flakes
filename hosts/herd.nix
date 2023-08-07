{ disks, modulesPath, lib, sops-nix, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (import ../modules/bios-btrfs-gpt-disk.nix "/dev/sda")
    ../modules/ssh-host-key.nix
  ];
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];

  networking = {
    hostName = "herd";
    domain = "heyi7086.com";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    defaultGateway = "172.31.1.1";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4 = {
          addresses = [ { address="91.107.230.166"; prefixLength = 32; } ];
          routes = [ { address = "172.31.1.1"; prefixLength = 32; } ];
        };
        ipv6 = {
          addresses = [
            { address="2a01:4f8:c0c:1be5::1"; prefixLength = 64; }
            { address="fe80::9400:2ff:fe6d:8f82"; prefixLength = 64; }
          ];
          routes = [ { address = "fe80::1"; prefixLength = 128; } ];
        };
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="96:00:02:6d:8f:82", NAME="eth0"
  '';
}
