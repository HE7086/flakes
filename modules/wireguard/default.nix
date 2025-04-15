{ config, ... }:
{
  imports = [
    ./secrets.nix
  ];
  networking.nftables.ruleset = ''
    table ip6 wireguard {
      chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
        oifname "wg0" ip6 daddr 2a01:4f8:c0c:1be5::3:0/112 ip6 saddr != fd01::1 snat ip6 to fd01::1
      }
    }
  '';
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.wireguard.interfaces.wg0 = {
    listenPort = 51820;
    ips = [
      "10.1.1.1/16"
      "fd01::1/16"
    ];

    privateKeyFile = config.sops.secrets."server/private".path;

    peers = [
      {
        # home
        publicKey = "Ao46pdDwpGZRXu4XveQZaRtsf57SYIoT/BnpnJJlcEo=";
        allowedIPs = [
          "10.1.2.1/32"
          "fd01::2:1/128"
          "2a01:4f8:c0c:1be5::2:1/128"
        ];
      }
      {
        # fridge
        publicKey = "Ry1T28Xmn9GnoSEOWjJqsw1gb9Moy59imbgjaPMOmCg=";
        allowedIPs = [
          "10.1.2.2/32"
          "fd01::2:2/128"
          "2a01:4f8:c0c:1be5::2:2/128"
        ];
      }
      {
        # vault
        publicKey = "ZXhfJ6rfqMhFa/X7aNcjnb5T5WPG4TqfuqecGp1VN3Q=";
        allowedIPs = [
          "10.1.2.3/32"
          "fd01::2:3/128"
          "2a01:4f8:c0c:1be5::2:3/128"
        ];
      }
      {
        # mobile
        publicKey = "xORMnqdh6UjxP2WQ+cOwza6ZFv7QZra49IRv0BrEcjo=";
        allowedIPs = [
          "10.1.3.1/32"
          "fd01::3:1/128"
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
