{ config, ... }:
let
  port = toString config.services.home-assistant.config.http.server_port;
in
{
  imports = [
    ./default_config.nix
    ./secrets.nix
    ./google_assistant.nix
    ./wol.nix
    ./customComponents/xiaomi_home.nix
    ./customComponents/midea_ac.nix
  ];

  services.home-assistant = {
    enable = true;
    openFirewall = false;
    extraComponents = [
      "isal"
      "tuya"
      "smartthings"
    ];
    extraPackages =
      python3pkgs: with python3pkgs; [
        pychromecast
        google-nest-sdm
      ];
    config = {
      homeassistant = {
        external_url = "https://hass.heyi7086.com";
        internal_url = "http://192.168.1.2:${port}";
      };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
      };
      "automation ui" = "!include automations.yaml";
      logger = {
        filters = {
          "homeassistant" = [
            "ModuleNotFoundError"
            "No module named"
            "UnknownHandler"
            "Error doing job: Task exception was never retrieved"
          ];
          "homeassistant.loader" = [
            "ModuleNotFoundError"
            "No module named"
            "UnknownHandler"
          ];
          "homeassistant.setup" = [
            "ModuleNotFoundError"
            "No module named"
            "UnknownHandler"
          ];
          "homeassistant.config_entries" = [
            "ModuleNotFoundError"
            "No module named"
            "UnknownHandler"
          ];
          "homeassistant.data_entry_flow" = [
            "ModuleNotFoundError"
            "No module named"
            "UnknownHandler"
          ];
        };
      };
    };
  };
  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
  ];

  services.nginx.enable = true;
  services.nginx.virtualHosts."hass.heyi7086.com" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      proxy_buffering off;
    '';
    locations."/" = {
      proxyPass = "http://127.0.0.1:${port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
