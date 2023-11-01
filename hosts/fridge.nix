{ config, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (import ../modules/filesystems/btrfs-efi-gpt-disk.nix "/dev/disk/by-id/nvme-eui.0024cf014c003c56")
    (import ../modules/filesystems/zfs-share.nix "/dev/disk/by-id/nvme-CT4000P3PSSD8_2328E6EEDF93")
    ../modules/ssh-host-key.nix
    ../modules/samba.nix
    ../modules/avahi.nix
    ../modules/swap.nix
    # ../modules/rathole.nix
    ../modules/hosts.nix
    ../modules/ddns.nix
    # ../modules/firewall-local.nix
    ../modules/docker.nix
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelParams = [ "nohibernate" ];
  boot.kernelModules = [ "kvm-intel" ];

  powerManagement.cpuFreqGovernor = "performance";
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

  time.timeZone = "Europe/Berlin";

  networking = {
    hostName = "fridge";
    domain = "heyi7086.com";
    search = [ "heyi7086.lan" ];
    hostId = "83d9da0a";
    useDHCP = true;

    defaultGateway = "192.168.1.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" "2606:4700:4700::1111" "2001:4860:4860::8888" ];
    interfaces = {
      enp1s0.useDHCP = false;
      enp2s0.useDHCP = false;
      enp3s0.useDHCP = false;
      enp4s0.useDHCP = false;
      br0 = {
        useDHCP = true;
        ipv4.addresses = [{
          address = "192.168.1.2";
          prefixLength = 24;
        }];
      };
    };

    bridges.br0 = {
      interfaces = [
        "enp1s0"
        "enp2s0"
        "enp3s0"
        "enp4s0"
      ];
      rstp = true;
    };
  };

  # services.rathole = {
  #   enable = true;
  #   role = "client";
  # };
  services.fwupd.enable = true;
}
