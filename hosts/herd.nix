{ modulesPath, self, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (import ./filesystems/btrfs-bios-gpt-root.nix "/dev/sda")
    self.nixosModules.fileShare
    self.nixosModules.hass
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
    dns = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
    linkConfig.RequiredForOnline = "routable";
  };
  networking = {
    hostName = "herd";
    domain = "heyi7086.com";
    useDHCP = false;
    useNetworkd = true;
  };
  networking.nftables.enable = true;
  networking.firewall.enable = true;

  services.fileShare.remote = {
    enable = true;
    dir = "/var/www/repo";
    virtualHost = "repo.heyi7086.com";
    user = "root";
    group = "root";
    rsyncd = true;
  };

}
