{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.services.alloy.extraConfigs = mkOption {
    type = types.listOf types.str;
    default = [ ];
  };

  config = {
    services.alloy = {
      enable = true;
      configPath = pkgs.writeText "config.alloy" (
        ''
          loki.write "default" {
            endpoint {
              url = "https://loki.heyi7086.com/loki/api/v1/push"
              basic_auth {
                username = "admin"
                password_file = "/run/credentials/alloy.service/alloy_auth"
              }
            }
          }

          loki.source.journal "${config.networking.hostName}" {
            max_age = "24h"
            forward_to = [loki.write.default.receiver]
          }

          prometheus.remote_write "default" {
            endpoint {
              url = "https://prometheus.heyi7086.com/api/v1/write"
              basic_auth {
                username = "admin"
                password_file = "/run/credentials/alloy.service/alloy_auth"
              }
            }
          }

          prometheus.exporter.unix "${config.networking.hostName}" {
            enable_collectors = [ "cpu", "loadavg", "meminfo", "vmstat" ]
            disable_collectors = [
              "arp", "bcache", "bonding", "boottime", "btrfs", "conntrack", "cpufreq", "diskstats", "dmi", "edac",
              "entropy", "exec", "fibrechannel", "filfd", "filesystem", "hwmon", "infiniband", "ipvs", "mdadm",
              "netclass", "netdev", "netisr", "netstat", "nfs", "nfsd", "nvme", "os", "powersupplyclass", "pressure",
              "rapl", "schedstat", "sockstat", "softnet", "stat", "tapestats", "textfile", "thermal_zone", "thermal",
              "time", "timex", "udp_queues", "uname", "xfs", "zfs",
            ]
          }
          prometheus.scrape "${config.networking.hostName}" {
            targets = prometheus.exporter.unix.${config.networking.hostName}.targets
            forward_to = [prometheus.remote_write.default.receiver]
          }
        ''
        + strings.concatStrings config.services.alloy.extraConfigs
      );
    };

    # DynamicUser = true
    systemd.services.alloy.serviceConfig = {
      LoadCredential = "alloy_auth:${config.sops.secrets.alloy_auth.path}";
    };
  };
}
