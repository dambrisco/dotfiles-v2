# set arguments for all 'brew install --cask' commands
cask_args appdir: "~/Applications", require_sha: true
tap "homebrew/bundle"

brew "git"
brew "jq"
brew "docker"
brew "colima"

cask "alfred"
cask "bitwarden"
cask "firefox"
# `force: true` required to handle no sha
cask "google-chrome", args: { force: true }
cask "iterm2"
cask "rectangle"
cask "slack"
cask "spotify"
cask "visual-studio-code"
cask "zoom"

brew "defaultbrowser"
