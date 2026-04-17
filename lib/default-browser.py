#!/usr/bin/env python3
"""Read or set the macOS default web browser.

Edits the LaunchServices preferences plist
(~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist)
directly, then nudges cfprefsd so the change takes effect in newly launched
apps without a logout/reboot. Replaces the unmaintained brew `defaultbrowser`.

Usage:
    lib/default-browser.py get
    lib/default-browser.py set <bundle-id>

Common bundle IDs:
    Safari   com.apple.safari
    Firefox  org.mozilla.firefox
    Chrome   com.google.chrome
    Brave    com.brave.browser
    Arc      company.thebrowser.browser
"""
import pathlib
import plistlib
import subprocess
import sys

PLIST = (
    pathlib.Path.home()
    / "Library/Preferences/com.apple.LaunchServices"
    / "com.apple.launchservices.secure.plist"
)
SCHEMES = ("http", "https")


def load():
    try:
        return plistlib.loads(PLIST.read_bytes())
    except FileNotFoundError:
        return {"LSHandlers": []}


def save(data):
    PLIST.parent.mkdir(parents=True, exist_ok=True)
    PLIST.write_bytes(plistlib.dumps(data, fmt=plistlib.FMT_BINARY))
    subprocess.run(["killall", "cfprefsd"], check=False)


def current(data, scheme):
    for h in data.get("LSHandlers", []):
        if h.get("LSHandlerURLScheme") == scheme:
            return (h.get("LSHandlerRoleAll") or "").lower()
    return ""


def set_scheme(data, scheme, bundle):
    handlers = data.setdefault("LSHandlers", [])
    handlers[:] = [h for h in handlers if h.get("LSHandlerURLScheme") != scheme]
    handlers.append({
        "LSHandlerURLScheme": scheme,
        "LSHandlerRoleAll": bundle,
        "LSHandlerPreferredVersions": {"LSHandlerRoleAll": "-"},
    })


def main(argv):
    if len(argv) < 2:
        sys.stderr.write(__doc__)
        return 2
    cmd = argv[1]
    data = load()
    if cmd == "get":
        print(current(data, "https"))
        return 0
    if cmd == "set":
        if len(argv) != 3:
            sys.stderr.write("usage: default-browser.py set <bundle-id>\n")
            return 2
        bundle = argv[2].lower()
        for scheme in SCHEMES:
            set_scheme(data, scheme, bundle)
        save(data)
        print(f"set default browser to {bundle}")
        return 0
    sys.stderr.write(f"unknown command: {cmd}\n")
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
