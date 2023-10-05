{ config, lib, pkgs, modulesPath, disko, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (import ../modules/filesystems/btrfs-efi-gpt-disk.nix "/dev/disk/by-id/nvme-eui.0024cf014c003c56")
    (import ../modules/filesystems/zfs-share.nix "/dev/disk/by-id/nvme-CT4000P3PSSD8_2328E6EEDF93")
    ../modules/ssh-host-key.nix
    ../modules/samba.nix
    ../modules/avahi.nix
    ../modules/swap.nix
    ../modules/rathole.nix
    ../modules/hosts.nix
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
    hostId = "83d9da0a";
    useDHCP = true;
  };

  networking.nftables = {
    enable = true;
  };
  networking.firewall = {
    enable = true;
    logRefusedConnections = false;
  };
  services.rathole = {
    enable = true;
    role = "client";
  };
}
