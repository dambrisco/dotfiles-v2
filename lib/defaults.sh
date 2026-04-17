#!/bin/bash
# macOS defaults + preference plist imports. All calls are naturally idempotent.
set -eu -o pipefail

script_dir="$(cd "${0%/*}" && pwd)"
prefs_dir="$script_dir/../prefs"

defaults write -g ApplePressAndHoldEnabled -bool false

if hash defaultbrowser 2>/dev/null; then
  defaultbrowser firefox
fi

plutil -convert binary1 \
  -o "$HOME/Library/Preferences/com.runningwithcrayons.Alfred-Preferences.plist" \
  "$prefs_dir/alfred/Alfred-Preferences.plist"
plutil -convert binary1 \
  -o "$HOME/Library/Preferences/com.runningwithcrayons.Alfred.plist" \
  "$prefs_dir/alfred/Alfred.plist"
