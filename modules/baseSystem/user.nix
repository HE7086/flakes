{ config, pkgs, ... }:
let
  keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJgQ10239M1Ehw6nmY7mFxGyqfpCkfSHAjZzSZZZ7NLA" ];
in
{
  users.mutableUsers = false;
  users.defaultUserShell = pkgs.zsh;
  users.users = {
    he = {
      isNormalUser = true;
      home = "/home/he";
      extraGroups = [ "wheel" "shared-storage" ];
      uid = 1000;
      openssh.authorizedKeys.keys = keys;
    };
    root.openssh.authorizedKeys.keys = keys;
  };

  nix.settings.trusted-users = [ "he" ];
  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = "he";

  home-manager.users.he = { ... }: {
    home = {
      stateVersion = config.system.stateVersion;
      # file.dotfiles = {
      #   source = inputs.dotfiles.outPath;
      #   onChange = ''
      #     make -C /home/he/dotfiles all Submodules
      #   '';
      # };
    };
  };

  users.users.shared-storage = {
    isSystemUser = true;
    group = "shared-storage";
  };
  users.groups.shared-storage = { };
}
