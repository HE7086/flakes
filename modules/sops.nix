{ sops-nix, ... }: {
  sops.defaultSopsFile = ../secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.secrets."herd/ssh_host_ed25519_key" = {};
  sops.secrets."herd/ssh_host_ed25519_key.pub" = {};
}
