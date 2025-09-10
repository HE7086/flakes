{ pkgs, ... }: {
  services.tailscale = {
    package = pkgs.unstable.tailscale;
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = true;
  };
}
