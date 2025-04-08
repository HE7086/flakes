{ pkgs, rootPath, ... }: {
  services.home-assistant.customComponents = [
    (pkgs.callPackage "${rootPath}/packages/hass/ha_xiaomi_home.nix" {})
  ];

  # https://github.com/NixOS/nixpkgs/issues/383276
  systemd.services.home-assistant.serviceConfig.SystemCallFilter = [
    "capset"
    "setuid"
  ];
}
