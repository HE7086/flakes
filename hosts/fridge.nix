{
  config,
  lib,
  modulesPath,
  pkgs,
  self,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./filesystems/btrfs-uefi-gpt-root.nix
    ./filesystems/zfs-share.nix
    self.nixosModules.ddns
    self.nixosModules.fileShare
    self.nixosModules.suwayomi
    self.nixosModules.download
    self.nixosModules.hass
    self.nixosModules.netbootxyz
    self.nixosModules.heon
    self.nixosModules.monitoring
  ];

  disko.devices.disk.root.device = lib.mkForce "/dev/disk/by-id/nvme-eui.0024cf014c003c56";
  disko.devices.disk.share.device = lib.mkForce "/dev/disk/by-id/nvme-CT4000P3PSSD8_2328E6EEDF93";

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
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.kernelParams = [ "nohibernate" ];
  boot.kernelModules = [ "kvm-intel" ];

  powerManagement.cpuFreqGovernor = "performance";
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

  networking = {
    hostName = "fridge";
    domain = "heyi7086.com";
    search = [ "heyi7086.home.arpa" ];
    hostId = "83d9da0a";
    useDHCP = false;
    useNetworkd = true;
    bridges.br0.interfaces = [
      "enp1s0"
      "enp2s0"
      "enp3s0"
      "enp4s0"
    ];
    interfaces = {
      enp1s0.mtu = 1492;
      enp2s0.mtu = 1492;
      enp3s0.mtu = 1492;
      enp4s0.mtu = 1492;
    };
  };
  networking.nftables.enable = true;
  # networking.nftables.tables = {
  #   nixos-fw.enable = false;
  #   # HACK: bypass NFTSet "Invalid table name nixos-fw"
  #
  #   filter = with config.networking.nftables.tables.nixos-fw; {
  #     inherit family;
  #     content =
  #       ''
  #         set lan_prefix {
  #           type ipv6_addr
  #           flags interval
  #         }
  #       ''
  #       + content;
  #   };
  # };
  networking.firewall.enable = true;
  networking.firewall.extraInputRules = ''
    ip6 saddr fe80::/10 accept
    ip saddr 192.168.1.0/24 accept
  '';
  # networking.firewall.extraInputRules = ''
  #   ip6 saddr @lan_prefix accept
  #   ip6 saddr fe80::/10 accept
  #   ip saddr 192.168.1.0/24 accept
  # '';
  systemd.network.networks = {
    "10-br0" = {
      matchConfig.Name = "br0";
      address = [ "192.168.1.2/24" ];
      gateway = [ "192.168.1.1" ];
      # dns = [ "192.168.1.1" ];
      DHCP = "ipv6";
      ipv6AcceptRAConfig = {
        Token = "::2";
        # FIXME: this causes journal being flooded some time after restart systemd-networkd
        # Failed to add NFT set: ... ignoring: No buffer space available
        #
        # NFTSet = [
        #   "prefix:inet:filter:lan_prefix"
        # ];
      };
      linkConfig.MTUBytes = 1492;
    };
  };
  services.resolved = {
    dnssec = "false";
    dnsovertls = "true";
    domains = [ "~." ];
    extraConfig = ''
      DNS=1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com
      FallbackDNS=8.8.8.8#dns.google 8.8.4.4#dns.google
    '';
  };

  services.fileShare = {
    local.enable = true;
    remote = {
      enable = true;
      rsyncd = false;
    };
  };
  services.heon.client = {
    enable = true;
    section = 2;
    token = 2;
    publicKey = "Ry1T28Xmn9GnoSEOWjJqsw1gb9Moy59imbgjaPMOmCg=";
  };
}
