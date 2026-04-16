#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 [--profile personal|work] [--host <name>] [-h|--help]

Fresh-laptop bootstrap. Installs Xcode CLT, Nix (Determinate Systems), then
switches the nix-darwin configuration defined in this repo.

  --profile   Which flake attr to activate (default: auto-detect from
              LocalHostName, else "personal").
  --host      Override the hostname sent to the flake (advanced).
EOF
}

profile=""
host_override=""
while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--profile) profile="${2:-}"; shift 2 ;;
    --host)       host_override="${2:-}"; shift 2 ;;
    -h|--help)    usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "bootstrap.sh currently only supports macOS." >&2
  exit 1
fi

if [[ -z "$profile" ]]; then
  detected="$(scutil --get LocalHostName 2>/dev/null || true)"
  case "$detected" in
    *work*) profile="work" ;;
    *)      profile="personal" ;;
  esac
fi

case "$profile" in
  personal|work) ;;
  *) echo "Invalid --profile: $profile (want personal|work)" >&2; exit 1 ;;
esac

host="${host_override:-$profile}"

echo "==> bootstrap: profile=$profile host=$host"

echo "==> checking Xcode Command Line Tools"
if ! /usr/bin/xcode-select -p >/dev/null 2>&1; then
  echo "    installing CLT via softwareupdate (non-interactive)"
  placeholder="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  touch "$placeholder"
  label="$(softwareupdate -l 2>/dev/null \
    | awk -F'Label: ' '/\\* Label: .*Command Line Tools/ {print $2}' \
    | tail -n1 || true)"
  if [[ -n "$label" ]]; then
    sudo softwareupdate -i "$label" --verbose
  else
    echo "    softwareupdate did not list CLT; falling back to GUI prompt"
    xcode-select --install || true
    until /usr/bin/xcode-select -p >/dev/null 2>&1; do
      sleep 5
    done
  fi
  rm -f "$placeholder"
fi

echo "==> checking Nix"
if ! command -v nix >/dev/null 2>&1; then
  echo "    installing Nix via Determinate Systems installer"
  curl --proto '=https' --tlsv1.2 -sSfL \
    https://install.determinate.systems/nix \
    | sh -s -- install --determinate --no-confirm
fi

if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  # shellcheck disable=SC1091
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

repo_dir="$(cd "$(dirname "$0")" && pwd)"
cd "$repo_dir"

echo "==> activating nix-darwin configuration (.#${host})"
if command -v darwin-rebuild >/dev/null 2>&1; then
  sudo darwin-rebuild switch --flake ".#${host}"
else
  sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ".#${host}"
fi

cat <<EOF

==> done.
Next:
  - Open Ghostty. Cmd+D / Cmd+Shift+D split panes; run \`claude\` in any pane.
  - Verify:  which nix nvim claude ghostty starship
  - Re-run:  ./bootstrap.sh --profile ${profile}   (idempotent)
EOF
