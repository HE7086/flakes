{ pkgs, ... }: {
  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;
  };
  services.nginx.recommendedOptimisation = true;
  services.nginx.recommendedTlsSettings = true;

  security.acme = {
    acceptTerms = true;
    defaults.email = "me@heyi7086.com";
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
