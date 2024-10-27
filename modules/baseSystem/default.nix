{ config, inputs, lib, pkgs, self, ... }: {
  imports = [
    ./packages.nix
    ./sops.nix
    ./ssh-host-key.nix
    ./ssh.nix
    ./swap.nix
    ./user.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    self.overlays.unstable
    # self.overlays.master
  ];

  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.ip_forward" = 1;
    "net.core.default_qdisc" = "fq";
  };
  boot.tmp.cleanOnBoot = true;

  system.stateVersion = "24.05";
  time.timeZone = "Europe/Berlin";

  zramSwap.enable = true;
  services.logind.extraConfig = "RuntimeDirectorySize=50%";

  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];
  environment.binsh = "${pkgs.dash}/bin/dash";

  services.dbus.implementation = "broker";
}
