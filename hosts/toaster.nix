{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./filesystems/btrfs-uefi-gpt-root.nix
  ];
  disko.devices.disk.root.device = lib.mkForce "/dev/sda";
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
    "usbhid"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "toaster";
    domain = "heyi7086.com";
    useDHCP = true;
  };
}
