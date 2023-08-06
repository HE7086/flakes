{ ... } : {
  services.openssh = {
    enable = true;
    hostKeys = [ { type = "ed25519"; path = "/etc/ssh/ssh_host_ed25519_key"; } ];
    settings = {
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
      ];
      KbdInteractiveAuthentication = false;
      KexAlgorithms = [
        "sntrup761x25519-sha512@openssh.com"
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
      ];
      Macs = [ "hmac-sha2-512-etm@openssh.com" ];
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    extraConfig = ''
      HostKeyAlgorithms ssh-ed25519
      PubkeyAcceptedAlgorithms ssh-ed25519
    '';
  };
}
