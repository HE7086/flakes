{ config, rootPath, ... }: {
  sops.defaultSopsFile = rootPath + /secrets/${config.networking.hostName}.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
