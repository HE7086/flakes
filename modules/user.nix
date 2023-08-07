{ pkgs, ... }:
let
  keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJgQ10239M1Ehw6nmY7mFxGyqfpCkfSHAjZzSZZZ7NLA" ];
in
{
  users.defaultUserShell = pkgs.zsh;
  users.users = {
    he = {
      isNormalUser = true;
      home = "/home/he";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = keys;
    };
    root.openssh.authorizedKeys.keys = keys;
  };
}
