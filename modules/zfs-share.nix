diskDevice: {
  disko.devices.disk.disk1 = {
    type = "disk";
    device = diskDevice;
    content = {
      type = "gpt";
      partitions = {
        zshare = {
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
      relatime = "on";
      "com.sun:auto-snapshot" = "false";
    };
    mountpoint = "/share";
    datasets = {};
  };
}
