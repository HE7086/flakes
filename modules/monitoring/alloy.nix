{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  parse_top =
    conf:
    concatMapAttrsStringSep "\n" (
      key: value:
      concatMapAttrsStringSep "\n" (k: v: ''
        ${key} "${k}" {
        ${parse_config 1 v}
        }'') value
    ) conf;
  parse_config =
    depth: conf:
    let
      indent = strings.replicate depth "  ";
      indent2 = strings.replicate (depth + 1) "  ";
    in
    concatMapAttrsStringSep "\n" (
      key: value:
      if isAttrs value then
        ''
          ${indent}${key} {
          ${parse_config (depth + 1) value}
          ${indent}}''
      # INFO: don't add quotes in lists
      else if isList value then
        if value == [ ] then
          ''${indent}${key} = []''
        else if isAttrs (head value) then
          concatMapStringsSep "\n" (v: ''
            ${indent}${key} {
            ${parse_config (depth + 1) v}
            ${indent}}'') value
        else if (length value) == 1 then
          ''${indent}${key} = [${head value}]''
        else
          ''
            ${indent}${key} = [
            ${indent2}${concatMapStringsSep ",\n${indent2}" (v: "${v}") value},
            ${indent}]''
      # INFO: add quotes for plain values with blacklist
      else if
        elem key [
          "relabel_rules"
          "targets"
        ]
      then
        ''${indent}${key} = ${value}''
      else
        ''${indent}${key} = "${value}"''
    ) conf;
  quote = str: "\"${str}\"";
in
{
  options.services.alloy = with types; {
    parse = mkOption {
      type = anything;
      default = parse_top;
    };
    settings = mkOption {
      type = attrsOf (
        attrsOf (submodule {
          freeformType = anything;
        })
      );
      default = { };
    };
  };
  config.services.alloy.settings = {
    "loki.write".default = {
      endpoint = {
        url = "https://loki.heyi7086.com/loki/api/v1/push";
        basic_auth = {
          username = "admin";
          password_file = "/run/credentials/alloy.service/alloy_auth";
        };
      };
    };
    "loki.relabel".journal = {
      forward_to = [ ];
      rule = [
        {
          source_labels = map quote [ "__journal__systemd_unit" ];
          target_label = "unit";
        }
        {
          source_labels = map quote [ "__journal__systemd_priority" ];
          target_label = "level";
        }
      ];
    };
    "loki.source.journal".${config.networking.hostName} = {
      relabel_rules = "loki.relabel.journal.rules";
      max_age = "24h";
      forward_to = [ "loki.write.default.receiver" ];
    };
    "prometheus.remote_write".default = {
      endpoint = {
        url = "https://prometheus.heyi7086.com/api/v1/write";
        basic_auth = {
          username = "admin";
          password_file = "/run/credentials/alloy.service/alloy_auth";
        };
      };
    };
    "prometheus.exporter.unix".${config.networking.hostName} = {
      enable_collectors = map quote [
        "boottime"
        "cpu"
        "loadavg"
        "meminfo"
        "vmstat"
        "filesystem"
      ];
      disable_collectors = map quote [
        "arp"
        "bcache"
        "bonding"
        "btrfs"
        "conntrack"
        "cpufreq"
        "diskstats"
        "dmi"
        "edac"
        "entropy"
        "exec"
        "fibrechannel"
        "filfd"
        "hwmon"
        "infiniband"
        "ipvs"
        "mdadm"
        "netclass"
        "netdev"
        "netisr"
        "netstat"
        "nfs"
        "nfsd"
        "nvme"
        "os"
        "powersupplyclass"
        "pressure"
        "rapl"
        "schedstat"
        "sockstat"
        "softnet"
        "stat"
        "tapestats"
        "textfile"
        "thermal_zone"
        "thermal"
        "time"
        "timex"
        "udp_queues"
        "uname"
        "xfs"
        "zfs"
      ];
    };
    "prometheus.scrape".${config.networking.hostName} = {
      targets = "prometheus.exporter.unix.${config.networking.hostName}.targets";
      forward_to = [ "prometheus.remote_write.default.receiver" ];
    };
  };

  config.services.alloy.enable = true;
  config.services.alloy.configPath =
    with config.services.alloy;
    pkgs.writeText "config.alloy" (parse settings);

  # DynamicUser = true
  config.systemd.services.alloy.serviceConfig = {
    LoadCredential = "alloy_auth:${config.sops.secrets.alloy_auth.path}";
  };
}
