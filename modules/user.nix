{ ... }: {
  users.users.he = {
    isNormalUser = true;
    home = "/home/he";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJgQ10239M1Ehw6nmY7mFxGyqfpCkfSHAjZzSZZZ7NLA"
    ];
  };
}
