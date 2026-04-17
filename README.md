# dotfiles-v2

Personal macOS dotfiles and bootstrap script.

## Quick start (fresh Mac)

Run this one-liner — it installs Homebrew (triggering the Xcode Command Line
Tools installer if needed), clones this repo, and bootstraps the machine:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dambrisco/dotfiles-v2/main/bootstrap.sh)"
```

## Running from a checkout

Clone, then run `bootstrap.sh` directly:

```bash
git clone https://github.com/dambrisco/dotfiles-v2.git ~/src/dotfiles-v2
cd ~/src/dotfiles-v2
./bootstrap.sh [--debug] [--profile personal,work]
```

Every phase is idempotent, so re-running the script is safe.

### Flags

- `-d`, `--debug` — enable `set -x` tracing with line-numbered `PS4`.
- `-p`, `--profile <list>` — comma-separated profiles to install alongside
  `base`. Accepted values: `personal`, `work`.

### Environment variables

- `DOTFILES_BRANCH` — branch to check out (default: `main`).
- `DOTFILES_DIR` — clone destination (default: `$HOME/src/dotfiles-v2`).

## What it does

The script runs these phases, all idempotent:

1. Install Homebrew (triggers the Xcode CLT installer on a pristine Mac).
2. Install `git` via brew if missing.
3. Clone or update this repo — skipped when running from an existing checkout.
4. `brew bundle` against `brew/base.rb` plus any selected profile Brewfiles.
5. Symlink `dotfiles/*` into `$HOME` via `lib/link.sh`.
6. Install the Claude Code CLI globally via `lib/claude.sh`.
7. Apply macOS defaults and import Alfred preferences via `lib/defaults.sh`.

## Profiles

- `base` — always installed (`brew/base.rb`).
- `personal` — personal apps (`brew/personal.rb`).
- `work` — work apps (`brew/work.rb`).

## Repo layout

- `bootstrap.sh` — sole entrypoint.
- `brew/` — Brewfiles per profile.
- `dotfiles/` — files symlinked into `$HOME` (git, zsh, nvim, ghostty).
- `lib/` — helper scripts (`link.sh`, `claude.sh`, `defaults.sh`).
- `prefs/` — Alfred preference plists imported by `lib/defaults.sh`.

## Requirements

macOS with internet access. On a pristine machine the Homebrew installer will
prompt for Xcode Command Line Tools — accept and let it finish before the
script continues.
