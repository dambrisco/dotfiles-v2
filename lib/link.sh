#!/bin/bash
# Symlinks every file under dotfiles/ into $HOME, preserving relative paths.
#
# Mapping: dotfiles/<pkg>/<first>/<rest> -> $HOME/.<first>/<rest>
# Tracked files are stored without the leading `.` on the first path segment
# so they're easier to work with in editors/tooling; the dot is re-added here.
# Idempotent: ln -sfn replaces existing symlinks; regular files (non-symlinks)
# get backed up to <target>.backup-<ts> instead of being overwritten.
#
# NOTE: This is a lightweight stand-in. If the number of tracked files grows
# or package-scoped operations are needed, swap this for `stow -R <pkg>`
# against dotfiles/<pkg>/. `stow` is already installed via brew/base.rb.
set -eu -o pipefail

repo_root="$(cd "${0%/*}/.." && pwd)"
src_root="$repo_root/dotfiles"

if [[ ! -d "$src_root" ]]; then
  echo "link.sh: no dotfiles/ directory at $src_root" >&2
  exit 1
fi

ts="$(date +%Y%m%d%H%M%S)"

while IFS= read -r -d '' src; do
  rel="${src#"$src_root"/}"
  # Strip the leading <pkg>/ segment and prepend `.` to the first remaining
  # segment so dotfiles/nvim/config/nvim/init.lua maps to
  # $HOME/.config/nvim/init.lua.
  rel_no_pkg="${rel#*/}"
  target="$HOME/.$rel_no_pkg"
  target_dir="${target%/*}"

  mkdir -p "$target_dir"

  if [[ -L "$target" ]]; then
    ln -sfn "$src" "$target"
  elif [[ -e "$target" ]]; then
    mv "$target" "$target.backup-$ts"
    ln -sfn "$src" "$target"
  else
    ln -sfn "$src" "$target"
  fi
done < <(find "$src_root" -type f -print0)
