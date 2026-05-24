#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v git >/dev/null 2>&1; then
  echo "git is not installed or not on PATH."
  exit 1
fi

if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Config directory is not inside a Git work tree: $ROOT_DIR"
  exit 1
fi

if ! worktrees="$(git -C "$ROOT_DIR" worktree list 2>&1)"; then
  echo "git worktree check failed."
  echo "Installed version: $(git --version)"
  echo "$worktrees"
  exit 1
fi

echo "git worktree is available: $(git --version)"
echo
echo "Current config repo worktrees:"
echo "$worktrees"
