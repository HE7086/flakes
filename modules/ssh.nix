{ ... }: {
  services.openssh = {
    enable = true;
    hostKeys = [{ type = "ed25519"; path = "/etc/ssh/ssh_host_ed25519_key"; }];
    settings = {
      Ciphers = [ "aes256-gcm@openssh.com" ];
      KbdInteractiveAuthentication = false;
      KexAlgorithms = [
        "sntrup761x25519-sha512@openssh.com"
        "curve25519-sha256@libssh.org"
      ];
      Macs = [ "hmac-sha2-512-etm@openssh.com" ];
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
    extraConfig = ''
      HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-ed25519
      PubkeyAcceptedAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-ed25519
      HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
      TrustedUserCAKeys /etc/ssh/ca.pub
    '';
    knownHosts."heyi7086.com" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICETRx1nrSVwLdwod4KaDIZYVf6La97GjbwMSza6/Put";
      hostNames = [ "*.heyi7086.com" ];
      certAuthority = true;
    };
  };
}
