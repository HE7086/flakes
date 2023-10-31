{
  services.avahi = {
    enable = true;
    nssmdns = true;
    # openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
      addresses = true;
      hinfo = true;
      domain = true;
    };
  };
}
