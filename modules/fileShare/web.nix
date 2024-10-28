{ config, pkgs, ... }: {
  services.nginx.virtualHosts = {
    "share.${config.networking.hostName}.heyi7086.com" = {
      forceSSL = true;
      enableACME = true;
      root = "/share/Public";
      locations."/".extraConfig = ''
        fancyindex on;
        fancyindex_exact_size off;
        fancyindex_show_dotfiles on;
      '';
    };
  };
  services.nginx.additionalModules = [ pkgs.nginxModules.fancyindex ];
  systemd.tmpfiles.rules = [
    "d /share/Public 755 1000 100"
  ];
}
