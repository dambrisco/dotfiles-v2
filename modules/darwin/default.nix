{ ... }:
{
  imports = [
    ./system.nix
    ./homebrew.nix
    ./fonts.nix
    ./activation.nix
  ];

  nix.enable = false;

  programs.zsh.enable = true;

  system.stateVersion = 5;
  system.configurationRevision = null;
}
