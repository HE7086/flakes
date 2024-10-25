{ config, ... }: {
  imports = [
    ../nginx.nix
    ./default_config.nix
    ./test.nix
    ./automations.nix
    ./secrets.nix
  ];

  services.home-assistant = {
    enable = true;
    openFirewall = false;
    extraComponents = [];
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

  services.nginx.recommendedProxySettings = true;
  services.nginx.virtualHosts."hass.heyi7086.com" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      proxy_buffering off;
    '';
    locations."/" = {
      proxyWebsockets = true;
      proxyPass = "http://127.0.0.1:8123";
    };
  };
}
