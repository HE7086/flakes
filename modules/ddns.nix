{ ... }: {
  sops.secrets."cloudflare/token/ddns" = {};
  sops.secrets."cloudflare/id/zone" = {};
  sops.secrets."cloudflare/id/account" = {};

}
