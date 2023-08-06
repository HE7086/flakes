{ inputs, lib, config, pkgs, sops-nix, ... }: {
  imports = [
    ./modules/sops.nix
    ./modules/ssh.nix
    ./modules/user.nix
  ];

  nixpkgs = {
    overlays = [];
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
  networking.hostName = "herd";
  networking.domain = "";

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = [ pkgs.zsh ];
  environment.binsh = "${pkgs.dash}/bin/dash";

  environment.systemPackages = with pkgs; [
    openssl
    binutils
    file
    zsh
    rsync
    git
    (neovim.override { vimAlias = true; })
    htop
    exa
    ranger
    bat
    aria2
    fd
    fzf
    ripgrep
    mtr
    inxi
    unar
    just
  ];
}
