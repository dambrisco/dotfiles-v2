#!/bin/bash
# For every dotfiles/local/<path>.template, create dotfiles/local/<path>
# (stripped of the .template suffix) if it doesn't already exist. The
# templates are the committed, canonical versions; the stripped copies are
# gitignored and hold user-local overrides.
#
# Must run before lib/link.sh so the stripped files exist when link.sh
# walks dotfiles/ to create the $HOME symlinks.
set -eu -o pipefail

repo_root="$(cd "${0%/*}/.." && pwd)"
local_dir="$repo_root/dotfiles/local"

[[ -d "$local_dir" ]] || exit 0

while IFS= read -r -d '' template; do
  target="${template%.template}"
  [[ -e "$target" ]] && continue
  cp "$template" "$target"
done < <(find "$local_dir" -type f -name '*.template' -print0)
