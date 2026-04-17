#!/bin/bash
# Sole entrypoint. Safe to run in either mode:
#
#   Fresh laptop (no clone yet):
#     bash -c "$(curl -fsSL https://raw.githubusercontent.com/dambrisco/dotfiles-v2/main/bootstrap.sh)"
#
#   From an existing checkout:
#     ./bootstrap.sh [--debug] [--profile personal,work]
#
# Phases (all idempotent):
#   1. Install Homebrew (triggers Xcode CLT installer on a pristine Mac).
#   2. Install git (via brew) if missing.
#   3. Clone/update the repo -- skipped if already running from a checkout.
#   4. `brew bundle` against base + selected profiles.
#   5. Link dotfiles into $HOME.
#   6. Install Claude Code CLI globally.
#   7. Apply macOS defaults and Alfred prefs.
set -eu -o pipefail

REPO="dambrisco/dotfiles-v2"
BRANCH="${DOTFILES_BRANCH:-main}"
CLONE_DIR="${DOTFILES_DIR:-$HOME/src/dotfiles-v2}"

# --- Detect execution mode -------------------------------------------------
# If this script sits next to brew/base.rb we're running from a checkout;
# otherwise we were piped in via curl|bash and need to clone first.
script_path="${BASH_SOURCE[0]:-}"
if [[ -n "$script_path" && -f "$(dirname "$script_path")/brew/base.rb" ]]; then
  repo_root="$(cd "$(dirname "$script_path")" && pwd)"
else
  repo_root=""
fi

# --- Phase 1: Homebrew -----------------------------------------------------
if ! hash brew 2>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# --- Phase 2 + 3: git, clone, re-exec from checkout ------------------------
if [[ -z "$repo_root" ]]; then
  hash git 2>/dev/null || brew install git
  mkdir -p "${CLONE_DIR%/*}"
  if [[ -d "$CLONE_DIR/.git" ]]; then
    git -C "$CLONE_DIR" fetch origin "$BRANCH"
    git -C "$CLONE_DIR" checkout "$BRANCH"
    git -C "$CLONE_DIR" pull --ff-only origin "$BRANCH"
  else
    git clone --branch "$BRANCH" "https://github.com/$REPO.git" "$CLONE_DIR"
  fi
  exec bash "$CLONE_DIR/bootstrap.sh" "$@"
fi

cd "$repo_root"

# --- Args ------------------------------------------------------------------
personal=
work=
while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--debug)
      filelength="$(wc -l < "$0" | awk '{print $1}')"
      PS4="> \$(printf \"$0:L%0${#filelength}d\" \${LINENO}) + "
      set -x
      shift
      ;;
    -p|--profile)
      shift
      if [[ $# -gt 0 ]]; then
        read -a profiles <<< $(echo "$1" | xargs | tr "," "\n")
        for v in "${profiles[@]}"; do
          case $v in
            personal) personal=1 ;;
            work)     work=1 ;;
            *)
              echo "Profile \"$v\" is unknown" >&2
              exit 1
              ;;
          esac
        done
        shift
      fi
      ;;
    -*|--*)
      echo "Unknown option $1" >&2
      exit 1
      ;;
    *)
      shift
      ;;
  esac
done

# --- Phase 4: brew bundle --------------------------------------------------
brew bundle --file=brew/base.rb install
[[ -n "$personal" ]] && brew bundle --file=brew/personal.rb install
[[ -n "$work"     ]] && brew bundle --file=brew/work.rb install

# --- Phases 5-7: link + claude + macOS defaults ----------------------------
bash lib/link.sh
bash lib/claude.sh
bash lib/defaults.sh
