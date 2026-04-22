# dotfiles-v2

Personal macOS dotfiles and bootstrap script.

## Quick start (fresh Mac)

Run this one-liner — it installs Homebrew (triggering the Xcode Command Line
Tools installer if needed), clones this repo into `~/dotfiles`, and
bootstraps the machine:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dambrisco/dotfiles-v2/main/bootstrap.sh)"
```

## Running from a checkout

Clone, then run `bootstrap.sh` directly:

```bash
git clone https://github.com/dambrisco/dotfiles-v2.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh [--debug] [--profile personal,work]
```

Every phase is idempotent, so re-running the script is safe. When run
interactively from a TTY, the script execs a fresh login shell at the end so
new env/aliases take effect immediately.

### Flags

- `-d`, `--debug` — enable `set -x` tracing with line-numbered `PS4`.
- `-p`, `--profile <list>` — comma-separated profiles to install alongside
  `base`. Accepted values: `personal`, `work`.

### Environment variables

- `DOTFILES_BRANCH` — branch to check out (default: `main`).
- `DOTFILES_DIR` — clone destination (default: `$HOME/dotfiles`).

## What it does

The script runs these phases, all idempotent:

1. Install Homebrew (triggers the Xcode CLT installer on a pristine Mac).
2. Install `git` via brew if missing.
3. Clone or update this repo — skipped when running from an existing checkout.
4. `brew bundle` against `brew/base.rb` plus any selected profile Brewfiles.
5. Seed machine-local override files from `dotfiles/local/*.template`
   (`lib/local.sh`).
6. Symlink `dotfiles/*` into `$HOME` via `lib/link.sh`.
7. Regenerate `~/.gitconfig.d/includes` with per-directory `includeIf` blocks
   (`lib/gen-gitconfig-includes.sh`).
8. Install the Claude Code CLI globally via `lib/claude.sh`.
9. Apply macOS defaults, remap Caps Lock → Escape, set Firefox as default
   browser, and import Alfred/Rectangle preferences (`lib/defaults.sh`).
10. `exec $SHELL -l` to reload the shell (interactive runs only).

## Profiles

- `base` — always installed (`brew/base.rb`).
- `personal` — personal apps (`brew/personal.rb`).
- `work` — work apps (`brew/work.rb`).

## Machine-local overrides

`dotfiles/local/` holds committed `*.template` files (e.g.
`zshrc.local.template`, `gitconfig.local.template`). On bootstrap, each
template is copied to its stripped filename if the target doesn't already
exist; the stripped copies are gitignored and safe to edit with
machine-specific secrets or overrides. `lib/link.sh` links the stripped
files into `$HOME` (e.g. `~/.zshrc.local`) and skips the `.template`
originals.

Per-directory git identity lives in `~/.gitconfig.<dirname>` alongside
`~/src/<dirname>/`; `lib/gen-gitconfig-includes.sh` scans `~/src/*/` and
wires matching configs into `~/.gitconfig.d/includes`, which the tracked
`~/.gitconfig` includes unconditionally.

## Repo layout

- `bootstrap.sh` — sole entrypoint.
- `brew/` — Brewfiles per profile.
- `dotfiles/` — files symlinked into `$HOME` (claude, ghostty, git, local,
  nvim, zsh). A file at `dotfiles/<pkg>/<first>/<rest>` maps to
  `$HOME/.<first>/<rest>`.
- `lib/` — helper scripts: `local.sh`, `link.sh`,
  `gen-gitconfig-includes.sh`, `claude.sh`, `defaults.sh`,
  `default-browser.py`.
- `prefs/` — Alfred and Rectangle preference plists imported by
  `lib/defaults.sh`.

## Requirements

macOS with internet access. On a pristine machine the Homebrew installer
will prompt for Xcode Command Line Tools — accept and let it finish before
the script continues.
