{ pkgs, ... }:
{
  services.home-assistant.customComponents = with pkgs; [
    (callPackage buildHomeAssistantComponent rec {
      owner = "XiaoMi";
      domain = "xiaomi_home";
      version = "0.2.4";

      src = fetchFromGitHub {
        inherit owner;
        repo = "ha_xiaomi_home";
        rev = "v${version}";
        sha256 = "sha256-scKwqm/uJkLFHWNwLf7Plh4qy282LrCYN8cazjBafXY=";
        # nix shell 'nixpkgs#nix-prefetch-github' -c nix-prefetch-github --rev "v0.2.4" XiaoMi ha_xiaomi_home
      };

      # https://github.com/XiaoMi/ha_xiaomi_home/blob/main/custom_components/xiaomi_home/manifest.json
      dependencies = with home-assistant.python.pkgs; [
        construct
        paho-mqtt
        numpy
        cryptography
        psutil
      ];
      # ignoreVersionRequirement = [
      #   "construct"
      # ];
    })
  ];

  # https://github.com/NixOS/nixpkgs/issues/383276
  systemd.services.home-assistant.serviceConfig.SystemCallFilter = [
    "capset"
    "setuid"
  ];
}
