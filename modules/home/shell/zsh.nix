{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 100000;
      save = 100000;
      ignoreDups = true;
      extended = true;
    };
    shellAliases = {
      ll = "eza -la --git --icons";
      la = "eza -a --icons";
      ls = "eza --icons";
      gs = "git status";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate";
      v = "nvim";
      cat = "bat --plain";
    };
    initContent = ''
      bindkey -e
      setopt AUTO_CD EXTENDED_HISTORY HIST_IGNORE_DUPS SHARE_HISTORY
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.eza.enable = true;
  programs.bat.enable = true;

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    tree
    htop
    wget
    curl
    colima
    docker-client
    docker-compose
  ];
}
