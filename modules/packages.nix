{ pkgs, outputs, ... }: {
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
    unstable.eza
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
    unzip
    just
    tmux
    jq

    lm_sensors
    ethtool
    smartmontools
    pciutils
    usbutils

    nix-output-monitor
  ];
}
