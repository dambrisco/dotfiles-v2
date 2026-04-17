#!/bin/bash
# Marks every tracked file under dotfiles/local/ as skip-worktree so local
# edits are invisible to git. Files are committed empty upstream; the
# skip-worktree flag is per-clone state and must be re-applied on every
# fresh clone, hence this runs from bootstrap.sh.
#
# To edit the canonical (empty) version and push an upstream change:
#   git update-index --no-skip-worktree dotfiles/local/<file>
#   # edit, commit, push
#   # next bootstrap re-applies skip-worktree
set -eu -o pipefail

repo_root="$(cd "${0%/*}/.." && pwd)"
cd "$repo_root"

git ls-files -z dotfiles/local | while IFS= read -r -d '' file; do
  git update-index --skip-worktree -- "$file"
done
