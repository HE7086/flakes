{ ... }: {
  # services.nginx.virtualHosts = {
  #   "repo.heyi7086.com" = {
  #     forceSSL = true;
  #     enableACME = true;
  #     root = "/var/www/repo";
  #     locations."/".extraConfig = ''
  #         fancyindex on;              # Enable fancy indexes.
  #         fancyindex_exact_size off;  # Output human-readable file sizes.
  #     '';
  #   };
  # };
  services.vsftpd = {
    enable = true;
    # forceLocalLoginsSSL = true;
    # forceLocalDataSSL = true;
    userlistDeny = false;
    localUsers = true;
    userlist = [ "he" ];
  };
}
