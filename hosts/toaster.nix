{ modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (import ../modules/filesystems/btrfs-efi-gpt-disk.nix "/dev/sda")
    ../modules/swap.nix
    ../modules/ssh-host-key.nix
  ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "toaster";
    domain = "heyi7086.com";
    useDHCP = true;
  };
}
