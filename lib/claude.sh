#!/bin/bash
# Installs Claude Code CLI globally via npm. Idempotent: skipped if `claude`
# is already on PATH. Relies on `brew "node"` having installed npm first.
set -eu -o pipefail

if hash claude 2>/dev/null; then
  exit 0
fi

if ! hash npm 2>/dev/null; then
  echo "claude.sh: npm not found; ensure brew installed node" >&2
  exit 1
fi

npm install -g @anthropic-ai/claude-code
