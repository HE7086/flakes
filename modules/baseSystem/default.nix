{ pkgs, ... }:
{
  imports = [
    ./packages.nix
    ./sops.nix
    ./ssh-host-key.nix
    ./ssh.nix
    ./swap.nix
    ./user.nix
    ./nix.nix

    # disabled by default
    ./docker.nix
    ./nginx.nix
  ];

  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
    "net.ipv6.conf.default.forwarding" = 1;
    "net.ipv4.conf.default.forwarding" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  boot.tmp.cleanOnBoot = true;

  system.stateVersion = "24.11";
  time.timeZone = "Europe/Berlin";

  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];
  environment.binsh = "${pkgs.dash}/bin/dash";
  programs.command-not-found.enable = false;

  services.dbus.implementation = "broker";
  services.logind.extraConfig = "RuntimeDirectorySize=50%";
}
