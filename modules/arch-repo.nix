{ pkgs, ... }: {
  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;
  };
  services.nginx.virtualHosts = {
    "repo.heyi7086.com" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/repo";
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "me@heyi7086.com";
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
