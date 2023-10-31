{ config, ... }: {
  services.samba = {
    enable = true;
    securityType = "user";
    # openFirewall = true;
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${config.networking.hostName}-samba
      netbios name = ${config.networking.hostName}
      security = user 
      hosts allow = 192.168.1. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      public = {
        path = "/share";
        browseable = "yes";
        writeable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "he";
        "force group" = "users";
      };
    };
  };

  services.samba-wsdd.enable = true;
  ## TODO: update unstable
  # services.samba-wsdd = {
  #   enable = true;
  #   openFirewall = true;
  # };
  # networking.firewall = {
  #   allowedTCPPorts = [
  #     5357 # wsdd
  #   ];
  #   allowedUDPPorts = [
  #     3702 # wsdd
  #   ];
  # };
}
