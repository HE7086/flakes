{ config, ... }:
{
  imports = [
    ./default_config.nix
    ./secrets.nix
    ./google_assistant.nix
    ./wol.nix
    ./xiaomi.nix
  ];

  services.home-assistant = {
    enable = true;
    openFirewall = false;
    extraComponents = [
      "tuya"
    ];
    config = {
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
      };
      "automation ui" = "!include automations.yaml";
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
      proxyPass = "http://127.0.0.1:8123";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
