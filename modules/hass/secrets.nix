{ rootPath, ... }: {
  sops.secrets."hass_secrets/data" = {
    owner = "hass";
    mode = "0400";
    sopsFile = rootPath + /secrets/hass.yaml;
    path = "/var/lib/hass/secrets.yaml";
    restartUnits = [ "home-assistant.service" ];
  };
  sops.secrets."hass_secrets/ssh-hass" = {
    owner = "hass";
    mode = "0400";
    sopsFile = rootPath + /secrets/hass.yaml;
    path = "/var/lib/hass/id_ed25519";
  };
  sops.secrets."hass_secrets/ssh-hass.pub" = {
    owner = "hass";
    mode = "0400";
    sopsFile = rootPath + /secrets/hass.yaml;
    path = "/var/lib/hass/id_ed25519.pub";
  };
  sops.secrets."hass_secrets/ssh-hass-cert.pub" = {
    owner = "hass";
    mode = "0400";
    sopsFile = rootPath + /secrets/hass.yaml;
    path = "/var/lib/hass/id_ed25519-cert.pub";
  };
  sops.secrets."hass_secrets/SERVICE_ACCOUNT.JSON" = {
    owner = "hass";
    mode = "0400";
    sopsFile = rootPath + /secrets/hass.yaml;
    path = "/var/lib/hass/SERVICE_ACCOUNT.JSON";
  };
}
