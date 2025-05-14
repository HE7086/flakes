{ config, lib, ... }:
lib.mkIf config.services.heon.server.enable {
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [
          "0.0.0.0"
          "::"
        ];

        access-control = [
          "127.0.0.0/8 allow"
          "::1/128 allow"

          "10.1.0.0/16 allow"
          "fd00:4845:7086::/64 allow"
        ];


        local-data = map (s: "'${s}'") [
          "herd.l. IN A 10.1.1.1"
          "herd.l. IN AAAA fd00:4845:7086::1"
          "herd.r. IN AAAA 2a01:4f8:c0c:1be5::1"
          "fridge.l. IN A 10.1.2.2"
          "fridge.l. IN AAAA fd00:4845:7086::2:2"
          "fridge.r. IN AAAA 2a01:4f8:c0c:1be5::2:2"
          "vault.l. IN A 10.1.2.3"
          "vault.l. IN AAAA fd00:4845:7086::2:3"
          "vault.r. IN AAAA 2a01:4f8:c0c:1be5::2:3"
        ];

        local-data-ptr = map (s: "'${s}'") [
          "10.1.1.1 herd.l"
          "fd00:4845:7086::1 herd.l"
          "2a01:4f8:c0c:1be5::1 herd.r"
          "10.1.2.2 fridge.l"
          "fd00:4845:7086::2:2 fridge.l"
          "2a01:4f8:c0c:1be5::2:2 fridge.r"
          "10.1.2.3 vault.l"
          "fd00:4845:7086::2:3 vault.l"
          "2a01:4f8:c0c:1be5::2:3 vault.r"
        ];

        local-zone = [
          "1.10.in-addr.arpa. nodefault"
          "6.8.0.7.5.4.8.4.0.0.d.f.ip6.arpa. nodefault"
        ];

        private-domain = [ "l." "r." ];

        hide-identity = true;
        hide-version = true;

        harden-glue = true;
        harden-dnssec-stripped = true;

        prefetch = true;
      };

      forward-zone = [{
        name = ".";
        forward-addr = [
          "1.1.1.1@853#cloudflare-dns.com"
          "1.0.0.1@853#cloudflare-dns.com"
        ];
        forward-tls-upstream = true;
      }];
    };
  };
}
