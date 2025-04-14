{ config, ... }:
{
  imports = [
    ./secrets.nix
  ];
  networking.nat = {
    enable = true;
    externalInterface = "ens3";
    internalInterfaces = [ "wg0" ];
  };
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.wireguard.interfaces.wg0 = {
    listenPort = 51820;
    ips = [
      "10.1.1.1/16"
      "2a01:4f8:c0c:1be5::1:1/64"
    ];

    privateKeyFile = config.sops.secrets."server/private".path;

    # preSetup = "";
    # postShutdown = "";

    peers = [
      {
        # home
        publicKey = "Ao46pdDwpGZRXu4XveQZaRtsf57SYIoT/BnpnJJlcEo=";
        allowedIPs = [
          "10.1.2.1/32"
          "2a01:4f8:c0c:1be5::2:1/128"
        ];
      }
      {
        # fridge
        publicKey = "Ry1T28Xmn9GnoSEOWjJqsw1gb9Moy59imbgjaPMOmCg=";
        allowedIPs = [
          "10.1.2.2/32"
          "2a01:4f8:c0c:1be5::2:2/128"
        ];
      }
      {
        # vault
        publicKey = "ZXhfJ6rfqMhFa/X7aNcjnb5T5WPG4TqfuqecGp1VN3Q=";
        allowedIPs = [
          "10.1.2.3/32"
          "2a01:4f8:c0c:1be5::2:3/128"
        ];
      }
      {
        # mobile
        publicKey = "xORMnqdh6UjxP2WQ+cOwza6ZFv7QZra49IRv0BrEcjo=";
        allowedIPs = [
          "10.1.3.1/32"
          "2a01:4f8:c0c:1be5::3:1/128"
        ];
      }
    ];
  };
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
