{ config, ... }: {
  users.users = {
    help = {
      isNormalUser = true;
      home = "/home/help";
      description = "User reserved for help";
      uid = 2000;
      openssh.authorizedKeys.keys = config.users.users.he.openssh.authorizedKeys.keys;
    };
  };

  services.nginx.virtualHosts = {
    "help.heyi7086.com" = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/help";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/www/help 755 root root"
  ];
}
