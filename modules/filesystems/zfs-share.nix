diskDevice: {
  disko.devices.disk.disk1 = {
    type = "disk";
    device = diskDevice;
    content = {
      type = "gpt";
      partitions = {
        share = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "share";
          };
        };
      };
    };
  };
  disko.devices.zpool.share = {
    type = "zpool";
    rootFsOptions = {
      compression = "zstd";
      xattr = "sa";
      atime = "off";
      acltype = "posixacl";
      dnodesize = "auto";
      normalization = "formD";
      relatime = "off";
      "com.sun:auto-snapshot" = "false";
      canmount="off";
    };
    mountpoint = null;
    datasets = {
      shared = {
        type = "zfs_fs";
        options.mountpoint = "legacy";
        mountpoint = "/share";
      };
    };
  };

  boot.zfs.extraPools = [ "share" ];
  fileSystems."/share" = {
    device = "share/shared";
    fsType = "zfs";
    options = [ "noatime" "norelatime" ];
  };

  services.zfs.autoScrub.enable = true;
}
