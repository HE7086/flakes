{ config, lib, ... }:
with lib;
let
  cfg = config.services.heon.server;

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
          concatStringsSep "."
          <| reverseList
          <| take (prefix / 4)
          <| stringToCharacters
          <| concatStrings
          <| map (fixedWidthString 4 "0") (
            if !strings.hasInfix "::" ip then
              splitString ":" ip
            else
              let
                parts = splitString "::" ip;
                prefix = filter isString <| splitString ":" <| head parts;
                suffix = filter isString <| splitString ":" <| last parts;
                num = 8 - (length prefix) - (length suffix);
              in
              prefix ++ (replicate num "") ++ suffix
          );
      in
      "${reversed}.ip6.arpa"
    else
      let
        reversed = strings.concatStringsSep "." <| reverseList <| take (prefix / 8) <| splitString "." ip;
      in
      "${reversed}.in-addr.arpa";

in
mkIf cfg.enable {
  services.unbound =
    let
      hostName = config.networking.hostName;
      clients = config.networking.wireguard.interfaces.${cfg.interface}.peers;
      ip4_int = map (c: {
        host = c.name;
        addr = net.cidr.ip (elemAt c.allowedIPs 0);
      }) clients;
      ip6_int = map (c: {
        host = c.name;
        addr = net.cidr.ip (elemAt c.allowedIPs 1);
      }) clients;
      ip6_ext = map (c: {
        host = c.name;
        addr = net.cidr.ip (elemAt c.allowedIPs 2);
      }) clients;
    in
    {
      enable = true;
      settings = {
        server = {
          interface = [
            "127.0.0.1"
            "::1"

            "${net.cidr.ip cfg.ip4.internal}"
            "${net.cidr.ip cfg.ip6.internal}"
          ];

          access-control = [
            "127.0.0.0/8 allow"
            "::1/128 allow"

            "${net.cidr.canonicalize cfg.ip4.internal} allow"
            "${net.cidr.canonicalize cfg.ip6.internal} allow"
          ];

          local-data = map (s: "'${s}'") (
            [
              "${hostName}.l. IN A ${net.cidr.ip cfg.ip4.internal}"
              "${hostName}.l. IN AAAA ${net.cidr.ip cfg.ip6.internal}"
              "${hostName}.r. IN AAAA ${net.cidr.ip cfg.ip6.external}"
            ]
            ++ (map (c: "${c.host}.l. IN A ${c.addr}") ip4_int)
            ++ (map (c: "${c.host}.l. IN AAAA ${c.addr}") ip6_int)
            ++ (map (c: "${c.host}.r. IN AAAA ${c.addr}") ip6_ext)
          );

          local-data-ptr = map (s: "'${s}'") (
            [
              "${net.cidr.ip cfg.ip4.internal} ${hostName}.l"
              "${net.cidr.ip cfg.ip6.internal} ${hostName}.l"
              "${net.cidr.ip cfg.ip6.external} ${hostName}.r"
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
