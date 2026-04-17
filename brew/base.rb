# set arguments for all 'brew install --cask' commands
cask_args appdir: "~/Applications", require_sha: true
tap "homebrew/bundle"

brew "git"
brew "jq"
brew "docker"
brew "colima"

# Terminal + editor stack
brew "neovim"
brew "node"
brew "ripgrep"
brew "fd"
# `stow` is installed but not used by default; link.sh is the active linker.
# Kept available so lib/link.sh can be swapped for `stow -R <pkg>` later.
brew "stow"

cask "ghostty"
cask "font-jetbrains-mono"

cask "alfred"
cask "bitwarden"
cask "firefox"
# `force: true` required to handle no sha
cask "google-chrome", args: { force: true }
cask "rectangle"
cask "slack"
cask "spotify"
cask "visual-studio-code"
cask "zoom"

brew "defaultbrowser"
