# set arguments for all 'brew install --cask' commands
cask_args appdir: "~/Applications", require_sha: true
tap "homebrew/bundle"

brew "git"
brew "jq"

cask "iterm2"
cask "alfred"
cask "rectangle"
cask "firefox"
cask "bitwarden"
cask "spotify"
cask "docker"
cask "visual-studio-code"

brew "defaultbrowser"
