{
  lib,
  modulesPath,
  self,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./filesystems/btrfs-bios-gpt-root.nix
    self.nixosModules.fileShare
    self.nixosModules.heon
    self.nixosModules.netbootxyz
    self.nixosModules.dash
    self.nixosModules.monitoring
    self.nixosModules.tailscale
  ];
  disko.devices.disk.root.device = lib.mkForce "/dev/sda";
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
  ];
  boot.initrd.kernelModules = [ "nvme" ];

  networking = {
    hostName = "herd";
    domain = "heyi7086.com";
    useDHCP = false;
    useNetworkd = true;
    nameservers = [ "127.0.0.1" ];
    interfaces.ens3 = {
      useDHCP = true;
      ipv6.addresses = [
        {
          address = "2a01:4f8:c0c:1be5::1";
          prefixLength = 64;
        }
      ];
      ipv6.routes = [
        {
          address = "::";
          prefixLength = 0;
          via = "fe80::1";
        }
      ];
    };
  };
  networking.nftables.enable = true;
  networking.firewall.enable = true;

  services.fileShare.remote = {
    enable = true;
    dir = "/var/www/repo";
    virtualHost = "repo.heyi7086.com";
    user = "root";
    group = "root";
    rsyncd = false;
    acmeHost = false;
  };

  services.heon.server.enable = true;
}
