{
  config,
  modulesPath,
  pkgs,
  self,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (import ./filesystems/btrfs-uefi-gpt-root.nix "/dev/disk/by-id/nvme-eui.0024cf014c003c56")
    (import ./filesystems/zfs-share.nix "/dev/disk/by-id/nvme-CT4000P3PSSD8_2328E6EEDF93")
    self.nixosModules.ddns
    self.nixosModules.fileShare
    self.nixosModules.suwayomi
    self.nixosModules.download
    self.nixosModules.hass
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelPackages = pkgs.linuxPackages_6_6;
  boot.kernelParams = [ "nohibernate" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.ip_forward" = 1;
  };

  powerManagement.cpuFreqGovernor = "performance";
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

  networking = {
    hostName = "fridge";
    domain = "heyi7086.com";
    search = [ "heyi7086.home.arpa" ];
    hostId = "83d9da0a";
    useDHCP = false;
    useNetworkd = true;
    firewall.enable = false;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "2606:4700:4700::1111"
      "2001:4860:4860::8888"
    ];
  };
  systemd.network.netdevs = {
    "10-br0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br0";
      };
      bridgeConfig.STP = true;
    };
  };
  systemd.network.networks = {
    "10-enp" = {
      matchConfig.Name = "enp*";
      bridge = [ "br0" ];
      DHCP = "no";
    };
    "10-br0" = {
      matchConfig.Name = "br0";
      address = [ "192.168.1.2/24" ];
      gateway = [ "192.168.1.1" ];
      DHCP = "ipv6";
      ipv6AcceptRAConfig.Token = "::2";
    };
  };

  services.fileShare = {
    local.enable = true;
    remote = {
      enable = true;
      rsyncd = true;
    };
  };
}
