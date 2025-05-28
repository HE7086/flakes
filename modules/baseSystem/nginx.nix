{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.services.nginx.enable {
  services.nginx.package = pkgs.nginxQuic;
  services.nginx.recommendedOptimisation = true;
  services.nginx.recommendedTlsSettings = true;

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
