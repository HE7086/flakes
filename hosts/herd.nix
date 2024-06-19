{ modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (import ../modules/filesystems/btrfs-bios-gpt-disk.nix "/dev/sda")
    ../modules/ssh-host-key.nix
    # ../modules/ddns.nix
    ../modules/swap.nix
    # ../modules/rathole.nix
    ../modules/docker.nix
    ../modules/nginx.nix
    ../modules/arch-repo.nix
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
  networking.firewall = {
    enable = true;
  };

  # services.rathole = {
  #   enable = true;
  #   role = "server";
  # };
}
