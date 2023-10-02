# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, lib, pkgs, modulesPath, disko, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
      (import ../modules/efi-zfs-gpt-disk-root.nix "/dev/disk/by-id/nvme-eui.0024cf014c003c56")
      ../modules/ssh-host-key.nix
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.device = "nodev";

  networking.hostName = "fridge";
  networking.hostId = "83d9da0a";

  time.timeZone = "Europe/Berlin";

  # fileSystems."/" =
  #   { device = "zroot/root/nixos";
  #     fsType = "zfs";
  #   };

  # fileSystems."/home" =
  #   { device = "zroot/home";
  #     fsType = "zfs";
  #   };

  # fileSystems."/boot" =
  #   { device = "/dev/disk/by-uuid/1D4A-3A59";
  #     fsType = "vfat";
  #   };

  # swapDevices =
  #   [ { device = "/dev/disk/by-uuid/4e0920bd-6a33-4cdc-90e6-317efac7b2b0"; }
  #   ];

  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # disko.devices = {
  #   disk.disk1 = {
  #     type = "disk";
  #     device = "/dev/disk/by-id/nvme-CT4000P3PSSD8_2328E6EEDF93";
  #     content = {
  #       type = "gpt";
  #       partitions = {
  #         zfs = {
  #           size = "100%";
  #           content = {
  #             type = "zfs";
  #             pool = "zshare";
  #           };
  #         };
  #       };
  #     };
  #   };
  #   zpool.zshare = {
  #     type = "zpool";
  #     rootFsOptions = {
  #       compression = "zstd";
  #       xattr = "sa";
  #       atime = "off";
  #       acltype = "posixacl";
  #       dnodesize = "auto";
  #       normalization = "formD";
  #       relatime = "on";
  #       "com.sun:auto-snapshot" = "false";
  #     };
  #     mountpoint = "/share";
  #     datasets = {};
  #   };
  # };
}
