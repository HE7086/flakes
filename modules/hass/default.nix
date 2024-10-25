{
  imports = [
    ../nginx.nix
    ./default_config.nix
    ./test.nix
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
      automation = "!include automations.yaml";
    };
  };

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

  sops.secrets."hass_secrets" = {
    owner = "hass";
    sopsFile = ../../secrets/hass.yaml;
    path = "/var/lib/hass/secrets.yaml";
    restartUnits = [ "home-assistant.service" ];
  };
}
