diskDevice: {
  disko.devices.disk.disk0 = {
    device = diskDevice;
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "512M";
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
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "@root" = {
                mountOptions = [ "noatime" "compress=zstd" ];
                mountpoint = "/";
              };
              "@home" = {
                mountOptions = [ "noatime" "compress=zstd" ];
                mountpoint = "/home";
              };
              "@var_log" = {
                mountOptions = [ "noatime" "compress=zstd" ];
                mountpoint = "/var/log";
              };
              "@nix" = {
                mountOptions = [ "noatime" "compress=zstd" ];
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
  };
}
