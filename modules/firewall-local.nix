{
  networking = {
    nftables.enable = true;
    firewall = {
      enable = true;
      logRefusedConnections = false;
      extraInputRules = ''
        ip saddr 192.168.1.0/24 accept comment "allow local traffic"
        ip6 saddr fe80::/64 accept comment "allow local traffic"
      '';
    };
  };  
}
