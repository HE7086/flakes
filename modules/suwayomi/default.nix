{ config, pkgs, ... }:
{
  imports = [ ./flaresolverr.nix ];
  services.suwayomi-server = {
    enable = true;
    package = pkgs.suwayomi-server;
    settings = {
      server = {
        port = 7375;
        extensionRepos = [
          "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
          "https://raw.githubusercontent.com/suwayomi/tachiyomi-extension/repo/index.min.json"
        ];
        flareSolverrEnabled = true;
      };
    };
    # openFirewall = true;
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."suwayomi.${config.networking.fqdn}" = {
    forceSSL = true;
    useACMEHost = config.networking.fqdn;
    # listenAddresses = [
    #   "127.0.0.1"
    #   "[::1]"
    #
    #   "192.168.1.2"
    #   "10.1.2.2"
    #   "[fd00:4845:7086:2::2]"
    # ];
    extraConfig = ''
      proxy_buffering off;
    '';
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.suwayomi-server.settings.server.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
