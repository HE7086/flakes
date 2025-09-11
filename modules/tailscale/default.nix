{ config, pkgs, ... }:
{
  services.tailscale = {
    package = pkgs.unstable.tailscale;
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = true;
  };
  networking.firewall.trustedInterfaces = [
    config.services.tailscale.interfaceName
  ];
}
