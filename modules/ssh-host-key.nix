{ config, sops-nix, ... }: {
  sops.secrets = {
    "${config.networking.hostName}/ssh_host_ed25519_key" = { };
    "${config.networking.hostName}/ssh_host_ed25519_key.pub" = { };
  };
}
