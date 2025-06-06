{ config, ... }: {
  services.geoipupdate = {
    enable = true;
    settings = {
      AccountID = 1180107;
      EditionIDs = [ "GeoLite2-ASN" "GeoLite2-City" "GeoLite2-Country" ];
      LicenseKey = { _secret = config.sops.secrets.maxmind_key.path; };
    };
  };
}
