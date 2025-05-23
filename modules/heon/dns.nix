{ config, lib, ... }:
with lib;
let
  cfgs = config.services.heon.server;
  cfg = config.services.heon;

  # assume prefix is a multiple of 8/4 (ipv4/ipv6)
  reverseDNSFromCidr =
    cidr:
    let
      ip = net.cidr.ip cidr;
      prefix = net.cidr.length cidr;
    in
    if net.ip.isv6 cidr then
      let
        reversed =
          pipe
            (
              if !hasInfix "::" ip then
                splitString ":" ip
              else
                let
                  parts = splitString "::" ip;
                  prefix = filter isString (splitString ":" (head parts));
                  suffix = filter isString (splitString ":" (last parts));
                  num = 8 - (length prefix) - (length suffix);
                in
                prefix ++ (replicate num "") ++ suffix
            )
            [
              (map (fixedWidthString 4 "0"))
              concatStrings
              stringToCharacters
              (take (prefix / 4))
              reverseList
              (concatStringsSep ".")
            ];
      in
      "${reversed}.ip6.arpa"
    else
      let
        reversed = pipe ip [
          (splitString ".")
          (take (prefix / 8))
          reverseList
          (concatStringsSep ".")
        ];
      in
      "${reversed}.in-addr.arpa";

in
mkIf cfgs.enable {
  services.unbound =
    let
      hostName = config.networking.hostName;
      ips = map (client: {
        name = client.name;
        ip = map (net.cidr.ip) client.allowedIPs;
      }) (cfg.clients ++ cfg.members);
      ip4_int = map (c: {
        host = c.name;
        addr = elemAt c.ip 0;
      }) ips;
      ip6_int = map (c: {
        host = c.name;
        addr = elemAt c.ip 1;
      }) ips;
      ip6_ext = map (c: {
        host = c.name;
        addr = elemAt c.ip 2;
      }) ips;
    in
    {
      enable = true;
      settings = {
        server = {
          interface = [
            "127.0.0.1"
            "::1"

            "${net.cidr.host 1 cfg.ip4.internal}"
            "${net.cidr.host 1 cfg.ip6.internal}"
          ];

          access-control = [
            "127.0.0.0/8 allow"
            "::1/128 allow"

            "${net.cidr.canonicalize cfg.ip4.internal} allow"
            "${net.cidr.canonicalize cfg.ip6.internal} allow"
          ];

          local-data = map (s: "'${s}'") (
            [
              "${hostName}.l. IN A    ${net.cidr.host 1 cfg.ip4.internal}"
              "${hostName}.l. IN AAAA ${net.cidr.host 1 cfg.ip6.internal}"
              "${hostName}.r. IN AAAA ${net.cidr.host 1 cfg.ip6.external}"
            ]
            ++ (map (c: "${c.host}.l. IN A    ${c.addr}") ip4_int)
            ++ (map (c: "${c.host}.l. IN AAAA ${c.addr}") ip6_int)
            ++ (map (c: "${c.host}.r. IN AAAA ${c.addr}") ip6_ext)
          );

          local-data-ptr = map (s: "'${s}'") (
            [
              "${net.cidr.host 1 cfg.ip4.internal} ${hostName}.l"
              "${net.cidr.host 1 cfg.ip6.internal} ${hostName}.l"
              "${net.cidr.host 1 cfg.ip6.external} ${hostName}.r"
            ]
            ++ (map (c: "${c.addr} ${c.host}.l") ip4_int)
            ++ (map (c: "${c.addr} ${c.host}.l") ip6_int)
            ++ (map (c: "${c.addr} ${c.host}.r") ip6_ext)
          );

          local-zone = [
            "${reverseDNSFromCidr cfg.ip4.internal}. nodefault"
            "${reverseDNSFromCidr cfg.ip6.internal}. nodefault"
          ];

          private-domain = [
            "l."
            "r."
          ];

          hide-identity = true;
          hide-version = true;

          harden-glue = true;
          harden-dnssec-stripped = true;

          prefetch = true;
        };

        forward-zone = [
          {
            name = ".";
            forward-addr = [
              "1.1.1.1@853#cloudflare-dns.com"
              "1.0.0.1@853#cloudflare-dns.com"
            ];
            forward-tls-upstream = true;
          }
        ];
      };
    };
}
