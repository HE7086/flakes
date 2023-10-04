{ inputs, outputs, lib, config, pkgs, sops-nix, ... }: {
  imports = [
    ./modules/sops.nix
    ./modules/ssh.nix
    ./modules/user.nix
    ./modules/packages.nix
  ];

  nixpkgs = {
    overlays = [ outputs.overlays.unstable ];
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  system.stateVersion = "23.05";

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  services.logind.extraConfig = "RuntimeDirectorySize=50%";

  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];
  environment.binsh = "${pkgs.dash}/bin/dash";
}
