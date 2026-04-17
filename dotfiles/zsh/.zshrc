# History.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY INC_APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

# Completions (brew-installed site-functions).
if [[ -n "$HOMEBREW_PREFIX" ]]; then
  fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
fi
autoload -Uz compinit && compinit

# Prompt: lightweight, no framework.
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST
PROMPT='%F{cyan}%~%f%F{yellow}${vcs_info_msg_0_}%f %# '

# Aliases.
alias cc='claude'
alias vi='nvim'
alias vim='nvim'
alias ls='ls -G'
alias ll='ls -lah'

# Ghostty ships shell integration it auto-injects via GHOSTTY_RESOURCES_DIR;
# source it explicitly as a belt-and-suspenders for non-login shells.
if [[ -n "$GHOSTTY_RESOURCES_DIR" && -r "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration" ]]; then
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi
