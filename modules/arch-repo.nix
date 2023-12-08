{
  services.nginx.virtualHosts = {
    "repo.heyi7086.com" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/repo";
    };
  };
}
