{ config, pkgs, libs, ... }:

let
  sources = import ../nix/sources.nix;
in
{
  home.packages = with pkgs; [
    awscli
    bat
    coreutils
    curl
    direnv
    du-dust
    exa
    fd
    ffsend
    fzf
    gnupg
    gnutls
    htop
    keychain
    mosh
    nix-zsh-completions
    nmap
    nnn
    ripgrep
    rsync
    sd
    socat
    sources.LS_COLORS
    termshark
    tldr
    tmux
    tree
    universal-ctags
    unzip
    watch
    watchman
    xsv
    ytop
    z-lua
    zsh
    zsh-powerlevel10k
  ];

  home.file.".gitconfig".source = ../configs/git/gitconfig;
  home.file.".aws/config".source = ../configs/aws/aws_config;
  home.file.".dircolors".source = sources.LS_COLORS.outPath + "/LS_COLORS";
  home.file.".tmux.conf".source = ../configs/tmux/tmux.conf;
  xdg.configFile."direnv/direnvrc".source = ../configs/direnv/direnvrc;
}
