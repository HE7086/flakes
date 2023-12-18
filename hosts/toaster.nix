{ modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (import ../modules/filesystems/btrfs-efi-gpt-disk.nix "/dev/sda")
    ../modules/swap.nix
  ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/12a35f9e-05e9-42fc-b6d6-45c36d5edf97";
      fsType = "btrfs";
      options = [ "subvol=@root" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/74E3-662D";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/12a35f9e-05e9-42fc-b6d6-45c36d5edf97";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/12a35f9e-05e9-42fc-b6d6-45c36d5edf97";
      fsType = "btrfs";
      options = [ "subvol=@var_log" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/12a35f9e-05e9-42fc-b6d6-45c36d5edf97";
      fsType = "btrfs";
      options = [ "subvol=@nix" ];
    };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "toaster";
    domain = "heyi7086.com";
    useDHCP = true;
  };
}
