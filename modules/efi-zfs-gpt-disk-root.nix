diskDevice: {
  disko.devices = {
    disk.disk0 = {
      device = diskDevice;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };
        };
      };
    };
    zpool.zroot = {
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
      datasets = {
        "root" = {
          type = "zfs_fs";
          mountpoint = "/";
          options."com.sun:auto-snapshot" = "true";
        };
        "home" = {
          type = "zfs_fs";
          mountpoint = "/home";
          options."com.sun:auto-snapshot" = "true";
        };
      };
    };
  };
}
