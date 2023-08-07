{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    openssl
    binutils
    coreutils
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
    tmux
    jq
  ];
}
