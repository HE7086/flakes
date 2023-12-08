{ pkgs, ... }: {
  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "me@heyi7086.com";
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
