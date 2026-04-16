{ ... }:
{
  homebrew.casks = [
    "headlamp"
    "notion"
    "zoom"
  ];

  system.activationScripts.headlampUnquarantine.text = ''
    if [ -d /Applications/Headlamp.app ]; then
      echo "[activation] removing quarantine from Headlamp.app"
      /usr/bin/xattr -dr com.apple.quarantine /Applications/Headlamp.app || true
    fi
  '';
}
