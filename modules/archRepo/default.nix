{ pkgs, ... }: {
  services.nginx.virtualHosts = {
    "repo.heyi7086.com" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/repo";
      locations."/".extraConfig = ''
        fancyindex on;
        fancyindex_exact_size off;
      '';
    };
  };
  services.nginx.additionalModules = [ pkgs.nginxModules.fancyindex ];
  systemd.tmpfiles.rules = [
    "d /var/www/repo 755 root root"
  ];
}
