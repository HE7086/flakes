{
  disko.devices.disk.root = {
    device = "/dev/sda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1M";
          type = "EF02";
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "@root" = {
                mountOptions = [
                  "noatime"
                  "compress=zstd"
                ];
                mountpoint = "/";
              };
              "@home" = {
                mountOptions = [
                  "noatime"
                  "compress=zstd"
                ];
                mountpoint = "/home";
              };
              "@var_log" = {
                mountOptions = [
                  "noatime"
                  "compress=zstd"
                ];
                mountpoint = "/var/log";
              };
              "@nix" = {
                mountOptions = [
                  "noatime"
                  "compress=zstd"
                ];
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
  };
}
