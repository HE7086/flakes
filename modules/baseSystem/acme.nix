{
  config,
  lib,
  rootPath,
  ...
}: 
lib.mkIf config.services.nginx.enable {
  security.acme = {
    acceptTerms = true;
    defaults.email = "me@heyi7086.com";
  };

  security.acme.certs."${config.networking.fqdn}" = {
    domain = "*.${config.networking.fqdn}";
    dnsProvider = "cloudflare";
    credentialFiles = {
      CF_DNS_API_TOKEN_FILE = config.sops.secrets."cloudflare/token/acme".path;
      CF_ZONE_API_TOKEN_FILE = config.sops.secrets."cloudflare/token/acme".path;
      CF_API_EMAIL_FILE = config.sops.secrets."cloudflare/email".path;
    };
    group = "nginx";
  };

  sops.secrets."cloudflare/token/acme" = {
    sopsFile = rootPath + /secrets/secrets.yaml;
  };
  sops.secrets."cloudflare/email" = {
    sopsFile = rootPath + /secrets/secrets.yaml;
  };
}
