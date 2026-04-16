{ username, ... }:
{
  imports = [
    ./shell/zsh.nix
    ./shell/env.nix
    ./git.nix
    ./ghostty.nix
    ./neovim.nix
    ./claude.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
