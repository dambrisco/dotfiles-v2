#!/bin/bash
# Fresh-laptop entrypoint. Idempotent; safe to re-run.
#
# Usage (fresh Mac):
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/dambrisco/dotfiles-v2/main/bootstrap.sh)"
#
# Any trailing arguments are forwarded to setup/mac/install.sh, e.g.:
#   bash -c "$(curl -fsSL .../bootstrap.sh)" _ --profile personal
set -eu -o pipefail

REPO="dambrisco/dotfiles-v2"
BRANCH="${DOTFILES_BRANCH:-main}"
CLONE_DIR="${DOTFILES_DIR:-$HOME/src/dotfiles-v2}"

# 1. Homebrew (also triggers the Xcode Command Line Tools installer on a
#    pristine Mac -- the one unavoidable GUI prompt).
if ! hash brew 2>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 2. git (needed to clone the repo; may already be present via CLT).
if ! hash git 2>/dev/null; then
  brew install git
fi

# 3. Clone or update the repo.
mkdir -p "${CLONE_DIR%/*}"
if [[ -d "$CLONE_DIR/.git" ]]; then
  git -C "$CLONE_DIR" fetch origin "$BRANCH"
  git -C "$CLONE_DIR" checkout "$BRANCH"
  git -C "$CLONE_DIR" pull --ff-only origin "$BRANCH"
else
  git clone --branch "$BRANCH" "https://github.com/$REPO.git" "$CLONE_DIR"
fi

# 4. Hand off to the local installer, forwarding any remaining args.
exec bash "$CLONE_DIR/setup/mac/install.sh" "$@"
