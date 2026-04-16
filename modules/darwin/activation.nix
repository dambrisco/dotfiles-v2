{ pkgs, username, ... }:
{
  environment.systemPackages = [ pkgs.defaultbrowser ];

  system.activationScripts.alfredPrefs.text = ''
    echo "[activation] importing Alfred plists for ${username}"
    HOME_DIR="/Users/${username}"
    PREFS_DIR="$HOME_DIR/Library/Preferences"
    /bin/mkdir -p "$PREFS_DIR"
    /usr/bin/plutil -convert binary1 \
      -o "$PREFS_DIR/com.runningwithcrayons.Alfred-Preferences.plist" \
      ${../../prefs/alfred/Alfred-Preferences.plist}
    /usr/bin/plutil -convert binary1 \
      -o "$PREFS_DIR/com.runningwithcrayons.Alfred.plist" \
      ${../../prefs/alfred/Alfred.plist}
    /usr/sbin/chown ${username}:staff \
      "$PREFS_DIR/com.runningwithcrayons.Alfred-Preferences.plist" \
      "$PREFS_DIR/com.runningwithcrayons.Alfred.plist"
  '';

  system.activationScripts.defaultBrowser.text = ''
    echo "[activation] setting Firefox as default browser"
    if [ -x /run/current-system/sw/bin/defaultbrowser ]; then
      /run/current-system/sw/bin/defaultbrowser firefox || true
    fi
  '';
}
