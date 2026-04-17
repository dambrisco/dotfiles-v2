#!/bin/bash
# macOS defaults + preference plist imports. All calls are naturally idempotent.
set -eu -o pipefail

script_dir="$(cd "${0%/*}" && pwd)"
prefs_dir="$script_dir/../prefs"

defaults write -g ApplePressAndHoldEnabled -bool false

# Finder: show hidden files + path bar. Writes don't take effect until Finder
# is relaunched, done at the bottom of this block.
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true

# Skip .DS_Store droppings on network and USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

killall Finder 2>/dev/null || true

# Route screenshots to ~/Screenshots instead of the Desktop. SystemUIServer
# caches the location, so bounce it after writing.
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
killall SystemUIServer 2>/dev/null || true

# Dock: left side, autohide, subtle magnification. largesize only slightly
# above tilesize so hover bumps the icon rather than ballooning it.
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock largesize -int 56

# Mission Control / Expose: snappier animations (default ~0.2s).
defaults write com.apple.dock expose-animation-duration -float 0.1

killall Dock 2>/dev/null || true

# Set Firefox as default browser, but only when the current default is Safari
# (or unset on a fresh install). lib/default-browser.py edits the LaunchServices
# plist directly, replacing the unmaintained brew `defaultbrowser` binary.
current_browser="$("$script_dir/default-browser.py" get 2>/dev/null || true)"
if [[ -z "$current_browser" || "$current_browser" == "com.apple.safari" ]]; then
  "$script_dir/default-browser.py" set org.mozilla.firefox
fi

# Remap Caps Lock -> Escape. hidutil applies immediately but resets on reboot,
# so install a LaunchAgent that reapplies the mapping at each login.
caps_to_esc_map='{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}'
hidutil property --set "$caps_to_esc_map" >/dev/null

agent_label="local.caps-to-escape"
agent_plist="$HOME/Library/LaunchAgents/$agent_label.plist"
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$agent_plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$agent_label</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/hidutil</string>
    <string>property</string>
    <string>--set</string>
    <string>$caps_to_esc_map</string>
  </array>
  <key>RunAtLoad</key><true/>
</dict>
</plist>
PLIST
launchctl unload "$agent_plist" 2>/dev/null || true
launchctl load "$agent_plist"

plutil -convert binary1 \
  -o "$HOME/Library/Preferences/com.runningwithcrayons.Alfred-Preferences.plist" \
  "$prefs_dir/alfred/Alfred-Preferences.plist"
plutil -convert binary1 \
  -o "$HOME/Library/Preferences/com.runningwithcrayons.Alfred.plist" \
  "$prefs_dir/alfred/Alfred.plist"

# Rectangle reads prefs at launch and writes them back on exit, so kill it
# before overwriting or a running instance will clobber our changes.
killall Rectangle 2>/dev/null || true
plutil -convert binary1 \
  -o "$HOME/Library/Preferences/com.knollsoft.Rectangle.plist" \
  "$prefs_dir/rectangle/Rectangle.plist"
open -a Rectangle 2>/dev/null || true
