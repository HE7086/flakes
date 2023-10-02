diskDevice: {
  config = {
    disko.devices.disk.${diskDevice} = {
      device = diskDevice;
      type = "disk";
      content = {
        type = "gpt";
        partitions = [
          {
            name = "EFI";
            start = "0";
            end = "1GiB";
            fs-type = "fat32";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "nofail" ];
            };
          }
          {
            name = "zfs";
            start = "1GiB";
            end = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          }
        ];
      };
    };
    zpool = {
      zroot = {
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
          "docker".type = "zfs_fs";
          "root".type = "zfs_fs";
          "root/nixos" = {
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
  };
}
