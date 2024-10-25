{
  services.home-assistant.config = {
    "automation manual" = [
      {
        alias = "Wake On Lan";
        description = "";
        trigger = [
          {
            platform = "state";
            entity_id = [
              "input_boolean.wol"
            ];
            from = "off";
            to = "on";
          }
        ];
        condition = [];
        action = [
          {
            service = "shell_command.wol_command";
            metadata = {};
            data = {};
          }
        ];
        mode = "single";
      }
    ];

    input_boolean = {
      wol = {
        name = "WOL";
        icon = "mdi:desktop-classic";
      };
    };

    shell_command = {
      # do not use multi-line string here
      wol_command = "/run/current-system/sw/bin/ssh -o User=he -i /var/lib/hass/id_ed25519 -o CertificateFile=/var/lib/hass/id_ed25519-cert.pub -o Ciphers=aes256-gcm@openssh.com -o MACs=hmac-sha2-512-etm@openssh.com -o KexAlgorithms=sntrup761x25519-sha512@openssh.com -o HostKeyAlgorithms=ssh-ed25519-cert-v01@openssh.com -o PubkeyAcceptedAlgorithms=ssh-ed25519-cert-v01@openssh.com,ssh-ed25519 -o CASignatureAlgorithms=ssh-ed25519 -o StrictHostKeyChecking=yes -o ControlMaster=no fridge.heyi7086.com";
    };
  };
}
