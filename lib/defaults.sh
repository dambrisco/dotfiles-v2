#!/bin/bash
# macOS defaults + preference plist imports. All calls are naturally idempotent.
set -eu -o pipefail

script_dir="$(cd "${0%/*}" && pwd)"
prefs_dir="$script_dir/../prefs"

defaults write -g ApplePressAndHoldEnabled -bool false

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
