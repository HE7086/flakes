{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    openssl
    binutils
    coreutils
    file
    zsh
    rsync
    git
    (unstable.neovim.override { vimAlias = true; })
    htop
    eza
    ranger
    bat
    aria2
    fd
    fzf
    ripgrep
    mtr
    inxi
    unar
    unzip
    just
    tmux
    jq
    unstable.yazi
    direnv
    zoxide

    lm_sensors
    ethtool
    smartmontools
    pciutils
    usbutils

    nix-output-monitor
    nh
    gnumake
    stow
    kitty.terminfo
    unstable.ghostty.terminfo

    gcc
  ];
}
