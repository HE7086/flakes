{ config, ... }: {
  sops.secrets = {
    "${config.networking.hostName}/ssh_host_ed25519_key" = { };
    "${config.networking.hostName}/ssh_host_ed25519_key.pub" = { };
    "${config.networking.hostName}/ssh_host_ed25519_key-cert.pub" = {
      owner = "root";
      path = "/etc/ssh/ssh_host_ed25519_key-cert.pub";
    };
  };
}
