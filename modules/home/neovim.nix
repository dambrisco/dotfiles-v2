{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      ripgrep
      fd
      lua-language-server
      nodejs_20
      nil
      tree-sitter
      gcc
    ];
  };

  xdg.configFile."nvim".source = ./nvim;
}
