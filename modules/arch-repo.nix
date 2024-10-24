{ pkgs, ... }: {
  imports = [
    ./nginx.nix
  ];

  services.nginx.virtualHosts = {
    "repo.heyi7086.com" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/repo";
      locations."/".extraConfig = ''
        fancyindex on;              # Enable fancy indexes.
        fancyindex_exact_size off;  # Output human-readable file sizes.
      '';
    };
  };
  services.nginx.additionalModules = [ pkgs.nginxModules.fancyindex ];
  systemd.tmpfiles.rules = [
    "d /var/www/repo 755 root root"
  ];
}
