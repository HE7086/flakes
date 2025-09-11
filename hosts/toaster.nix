{
  lib,
  modulesPath,
  self,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./filesystems/btrfs-uefi-gpt-root.nix
    self.nixosModules.netbootxyz
    self.nixosModules.monitoring
    self.nixosModules.tailscale
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
    useNetworkd = true;
    nftables.enable = true;
    firewall.enable = true;
  };

  # services.heon.client = {
  #   enable = true;
  #   section = 3;
  #   token = 1;
  #   publicKey = "jotrh61rV9hW1/5H+rzxWZNjzFZkIfFJOupmflA5jHQ=";
  # };
}
