{ config, sops-nix, ... }: {
  sops.secrets = {
    "${config.networking.hostName}/ssh_host_ed25519_key" = {
      path = "/etc/ssh/ssh_host_ed25519_key";
      mode = "0600";
    };
    "${config.networking.hostName}/ssh_host_ed25519_key.pub" = {
      path = "/etc/ssh/ssh_host_ed25519_key.pub";
      mode = "0644";
    };
  };
}
